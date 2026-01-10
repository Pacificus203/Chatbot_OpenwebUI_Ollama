# DGX Spark (Day03): Local Network Access, SSH, and Open WebUI with Ollama

## 🟩 English

This guide combines and expands on the official NVIDIA documentation for setting up local network access, SSH, and deploying Open WebUI with Ollama on your DGX Spark. It covers both NVIDIA Sync and manual SSH approaches, and provides troubleshooting tips for common issues.

---

## Table of Contents
- [1. Overview](#1-overview)
- [2. Set Up Local Network Access](#2-set-up-local-network-access)
  - [2.1 Using NVIDIA Sync (Recommended)](#21-using-nvidia-sync-recommended)
  - [2.2 Using Manual SSH](#22-using-manual-ssh)
- [3. Set Up Open WebUI with Ollama](#3-set-up-open-webui-with-ollama)
  - [3.1 With NVIDIA Sync](#31-with-nvidia-sync)
  - [3.2 Manual Setup](#32-manual-setup)
- [4. Troubleshooting](#4-troubleshooting)
- [5. Cleanup and Rollback](#5-cleanup-and-rollback)

---

## 1. Overview

- **Local network access** allows you to securely connect to your DGX Spark from your laptop/PC using SSH, either via NVIDIA Sync (GUI) or manual SSH (CLI).
- **Open WebUI with Ollama** provides a web-based AI interface running on your DGX Spark, accessible from your browser.

---

## 2. Set Up Local Network Access

### 2.1 Using NVIDIA Sync (Recommended)
1. **Install NVIDIA Sync**
   - Download and install NVIDIA Sync for your OS ([Windows](https://workbench.download.nvidia.com/stable/windows/nvidia-sync.exe), [macOS](https://workbench.download.nvidia.com/stable/macos/nvidia-sync.dmg)).
   - For Linux, follow the official instructions to add the repo and install via apt.
2. **Configure Apps**
   - Default: DGX Dashboard, Terminal
   - Optional: VS Code, Cursor, NVIDIA AI Workbench
3. **Add your DGX Spark device**
   - Enter a name, hostname/IP, username, and password (used only for initial SSH key setup).
   - NVIDIA Sync will generate SSH keys, configure access, and create an SSH alias.
4. **Access your DGX Spark**
   - Use the NVIDIA Sync tray icon to connect/disconnect, launch apps, and set working directories.
5. **Validate SSH setup**
   - Open a terminal and run:
     ```bash
     ssh <SPARK_HOSTNAME>.local
     # or
     ssh <IP>
     hostname
     whoami
     exit
     ```

### 2.2 Using Manual SSH
1. **Verify SSH client**
   - Run `ssh -V` to check for OpenSSH.
2. **Gather connection info**
   - Username, password, hostname (e.g., spark-abcd.local), or IP address.
   - Test mDNS with `ping spark-abcd.local`.
3. **Test initial connection**
   - ```bash
     ssh <YOUR_USERNAME>@<SPARK_HOSTNAME>.local
     # or
     ssh <YOUR_USERNAME>@<DEVICE_IP_ADDRESS>
     ```
   - Accept the fingerprint and enter your password.
4. **Verify remote connection**
   - Run `hostname`, `uname -a`, then `exit`.
5. **SSH tunneling for web apps**
   - Example for DGX Dashboard:
     ```bash
     ssh -L 11000:localhost:11000 <YOUR_USERNAME>@<SPARK_HOSTNAME>.local
     # Access http://localhost:11000 in your browser
     ```

---

## 3. Set Up Open WebUI with Ollama

### 3.1 With NVIDIA Sync
1. **Configure Docker permissions**
   - In a terminal (via NVIDIA Sync), run:
     ```bash
     docker ps
     # If permission denied:
     sudo usermod -aG docker $USER
     newgrp docker
     ```
2. **Pull the container**
   - ```bash
     docker pull ghcr.io/open-webui/open-webui:ollama
     ```
3. **Add Open WebUI as a Custom App in NVIDIA Sync**
   - Go to Settings > Custom tab > Add New
   - Name: Open WebUI
   - Port: 12000
   - Auto open in browser: checked
   - Start Script: (see official docs for full script)
4. **Launch Open WebUI**
   - Click "Open WebUI" in NVIDIA Sync. Browser opens at http://localhost:12000
5. **Create admin account and download a model**
   - Register, then pull a model (e.g., gpt-oss:20b) in the UI.

### 3.2 Manual Setup
1. **Configure Docker permissions**
   - As above.
2. **Pull the container**
   - ```bash
     docker pull ghcr.io/open-webui/open-webui:ollama
     ```
3. **Start the container**
   - ```bash
     docker run -d -p 8080:8080 --gpus=all \
       -v open-webui:/app/backend/data \
       -v open-webui-ollama:/root/.ollama \
       --name open-webui ghcr.io/open-webui/open-webui:ollama
     ```
   - Access at http://<DGX_Spark_IP>:8080 or via SSH tunnel:
     ```bash
     ssh -L 8080:localhost:8080 <YOUR_USERNAME>@<SPARK_HOSTNAME>.local
     # Then open http://localhost:8080
     ```
4. **Create admin account and download a model**
   - As above.

---

## 4. Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Device name doesn't resolve | mDNS blocked | Use IP address |
| Permission denied on docker ps | Not in docker group | Add user to docker group, restart terminal |
| Model download fails | Network issues | Check connection, retry |
| GPU not detected | Missing --gpus=all | Recreate container with correct flag |
| Port already in use | Conflict | Change port or stop conflicting service |

---

## 5. Cleanup and Rollback

**To remove Open WebUI and all data:**
```bash
docker stop open-webui
docker rm open-webui
docker rmi ghcr.io/open-webui/open-webui:ollama
docker volume rm open-webui open-webui-ollama
```
Remove the Custom App from NVIDIA Sync if used.

---

> For more details, see the official NVIDIA documentation and previous Day01A/Day01B/Day02 guides.
