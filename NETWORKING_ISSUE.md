# Networking Issue Between WSL2 and Windows
*The limitation does not diminish the learning value of this setup, but rather provides insight into the networking complexities that cloud providers abstract away in managed Kubernetes services.*

One of the problems encountered in the early stage after setting up Ingress was the networking issue between WSL2 and Windows Host System

## Problem Description

When running the Kubernetes cluster using Kind inside WSL2, the network stack creates multiple layers of isolation such that:

```
Windows Host (192.168..0.x LAN)

NAT

WSL2 (172.31.155.x Virtual Network)

Kind Docker Network (172.19.0.x Container Network)

Kubernetes Pods (10.244.x.x Pod Network)
```

## Further Clarification

WSL2 involves NAT, which causes a one way communication barrier, and making it difficult to directly access applications running within WSL2


## Outputs
- `curl` commands from WSL2 to ingress services fail with "No route to host"
- DNS resolution works correctly, but connection attempts timeout
- Direct pod access via `kubectl port-forward` works (bypasses ingress networking)
- Ping to router works, but ping to LoadBalancer IPs fails

## Error Sample
```bash
$ curl -v http://dashboard.cloudforge.local
* Host dashboard.cloudforge.local:80 was resolved.
* IPv4: 172.31.155.130
* connect to 172.31.155.130 port 80 from 172.31.155.224 port 51752 failed: No route to host
* Failed to connect to dashboard.cloudforge.local port 80: Couldn't connect to server
```

## Attempted Solutions

### Using WSL2 network range
- Changed MetalLB pool to `172.31.155.130-172.31.155.140`
- **Result**: Still failed with "no route to host"

### Using Kind Docker network range
- Changed MetalLB pool to `172.19.255.1-172.19.255.10`
- **Result**: Still failed. Host unreachable 

### Using local network range
- Changed MetalLB pool to `192.168.0.100-192.168.0.120`
- **Result**: Still failed. Host unreachable 

### Stopping Local Services 
- Stopped local nginx service to prevent port conflicts
- **Result**: Elimated port binding issues but networking problem persisted


## Solution 

The fundamental solution would be to **bridge WSL2 and Windows LAN** to elimated NAT isolation. By assigning WSL2 with a static ip from the LAN network range, direct communication between Windows and WSL2 can take place. 

A custom bridge is created on adapter vEthernet (WSL Hyper-V firewall). The adapter will act as a bridge bewtween Windows and WSL2.

Then assigning a static ip to WSL2

Windows WSL Bridge assigned static ip: `192.168.80.1`

WSL assigned static ip: `192.168.80.2`

The old NAT ip was replaced and removed with the static ip `192.168.80.2`

```bash
@echo off
echo Setting up WSL2 static IP...
date /t
time /t

echo Removing existing WSL2 IP...
wsl -d Ubuntu -u root ip addr del $(ip addr show eth0 ^| grep 'inet\b' ^| awk '{print $2}' ^| head -n 1) dev eth0

echo Assigning static IP 192.168.80.2 to WSL2...
wsl -d Ubuntu -u root ip addr add 192.168.80.2/24 broadcast 192.168.80.255 dev eth0

echo Setting up WSL2 routing...
wsl -d Ubuntu -u root ip route add 0.0.0.0/0 via 192.168.80.1 dev eth0

echo Configuring WSL2 DNS...
wsl -d Ubuntu -u root echo nameserver 8.8.8.8 ^> /etc/resolv.conf

echo Configuring Windows WSL network adapter...
powershell -c "Get-NetAdapter 'vEthernet (WSL (Hyper-V firewall))' | Get-NetIPAddress | Remove-NetIPAddress -Confirm:$False; New-NetIPAddress -IPAddress 192.168.80.1 -PrefixLength 24 -InterfaceAlias 'vEthernet (WSL (Hyper-V firewall))'; Get-NetNat | ? Name -Eq WSLNat | Remove-NetNat -Confirm:$False; New-NetNat -Name WSLNat -InternalIPInterfaceAddressPrefix 192.168.80.0/24;"

echo WSL2 static IP setup complete!
date /t
time /t

echo Testing connectivity...
echo Pinging WSL2 from Windows...
ping -n 3 192.168.80.2

pause
```

### Windows Firewall blocking WSL2
After succesful configuration, Windows was able to reach WSL2 but WSL2 was still unable to reach Windows.

Temporarily disabling Windows firewall seem to work since the virtual adapter seems to be treated as a public network.

Firewall rules were created instead of changing the network profile

```bash
# Create an inbound rule for WSL2 subnet
netsh advfirewall firewall add rule name="WSL2-Inbound" dir=in action=allow protocol=any remoteip=192.168.80.0/24 localip=192.168.80.1

# Creates an outbound rule for WSL2 subnet  
netsh advfirewall firewall add rule name="WSL2-Outbound" dir=out action=allow protocol=any remoteip=192.168.80.0/24 localip=192.168.80.1

# Allow ICMP (ping) 
netsh advfirewall firewall add rule name="WSL2-ICMP" dir=in action=allow protocol=icmpv4 remoteip=192.168.80.0/24
```

MetalLB then assigns ip pool of `192.168.80.10 - 192.168.80.20` to the LoadBalancer service.
Windows and WSL2 are able to communicate directly

## Further Notes
After extensive troubleshooting and testing multiple solutions, the following fundamental limitation was identified:

MetalLB assigns external IPs (e.g., `192.168.80.10`) that exist only within Kind's isolated Docker network. These IPs are not routable from the WSL2 host machine. 

The root cause points to the network isolation, where Kind runs in Docker containers with isolated networking


```bash
# MetalLB assigns IP successfully
kubectl get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.96.154.229   192.168.80.10   80:31630/TCP,443:31091/TCP   2d23h
# WSL2 cannot reach the IP
ping 192.168.80.10
# Result: Destination Host Unreachable
```

The WSL2 machine has **NO** network interface binded to the ip `192.168.80.10`.

It exists in the MetalLB's ARP table but not on any real interface on where WSL2 can route to.


## Last Updated
- 1.8.2025
- 3.8.2025