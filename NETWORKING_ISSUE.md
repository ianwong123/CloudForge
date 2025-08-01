# Networking Issue Between WSL2 and Windows

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

WSL2 involves NAT, which causes a one way communication barrier, and mking it difficult to directly access applications running within WSL2


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
_To be attempted and updated_

The fundamental solution would be to **bridge WSL2 and Windows LAN** to elimated NAT isolation. By assigning WSL2 with a static ip from the LAN network range, direct communication between Windows and WSL2 can take place. 

## Last Updated
1.8.2025