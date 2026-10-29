# Pi-hole on Windows

Pi-hole does not run natively on Windows. This setup runs the official Pi-hole Linux container with Docker Desktop using its WSL 2 backend. It is an optional deployment guide; the Pi-hole core installer and DNS engine remain Linux software.

## Requirements

- Windows 10/11 with WSL 2 enabled. From an Administrator PowerShell, run `wsl --install` and `wsl --update`, then restart if prompted.
- Docker Desktop for Windows installed and running with the WSL 2 based engine enabled. A separate Ubuntu distribution is not required.
- For other LAN devices, reserve a stable LAN IP for this PC.

Install Docker Desktop from https://docs.docker.com/desktop/setup/install/windows-install/ and accept its terms when launching it.

## Start

Open PowerShell in this directory and run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\setup-windows.ps1
```

On first run, the script creates `.env` with a random admin password, pulls the pinned official image, and starts Pi-hole. Read the password using `Get-Content .env`. Open `http://localhost/admin/` on this PC.

To stop Pi-hole, run:

```powershell
.\setup-windows.ps1 -Down
```

Docker Desktop must be running to start or manage the container.

## Use from your LAN

First test one device by setting its DNS server to this PC's reserved LAN IP. Allow inbound TCP and UDP port 53 in Windows Defender Firewall if needed. Confirm DNS resolution and internet access before changing router settings. Then set the router's DHCP DNS server to this same IP and leave router DHCP enabled. This setup does not enable Pi-hole DHCP.

Do not forward ports 53, 80, or 443 from the internet to this PC. Docker Desktop port forwarding and Windows Firewall rules can affect LAN reachability; verify access from another device before rolling out router DNS changes.

## Upgrade

Review https://github.com/pi-hole/docker-pi-hole/releases, update the image tag in `compose.yaml`, then run `docker compose pull` followed by `docker compose up -d`.
