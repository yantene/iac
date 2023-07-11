# Infrastructure as Code

## install debian in a VPS

Boot the following ISO file on the VPS.

https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.0.0-amd64-netinst.iso

The following points should be noted during the OS installation process.

- Create "system" user as a general user.

## initial setup

Login as root.

```bash
apt install -y curl
curl -sSL raw.githubusercontent.com/yantene/iac/main/setup.sh -o /tmp/setup.sh
bash /tmp/setup.sh
```
