# DGX Spark (Day01B)：Local Access from Same Subnet Guide 20251220B
## 🟩 English
> ## Scenarios & Pros/Cons
> **From a local network on Mac/PC → SSH login to DGX Spark at the same subnet**
> - Simple one-line **SSH** command **login to DGX Spark**
>   - Use DGX Spark as Server. (Mac/PC = Client)
>   - After rebooting, simply have the Mac/PC Client run this SHH command in step 3.1 - it's super easy.
> - **Same Subnet LAN Access**
>   - Refers to the situation where the Mac/PC (Client) and DGX Spark (Server) must be located under the same intranet IP segment (192.168.x.x) assigned by the same router. 
>   - This severely limits the physical distance between Client and Server.
>     - If this cannot meet your needs, please skip this: (Day01B) Local Access from Same Subnet Guide.
>       - What you need is: [(Day01A) Remote Access from Internet Guide](https://github.com/Sniper711/DGX-Spark-Day01A-Remote-Access-from-Internet-Guide-20251220A/blob/main/DGX%20Spark%20(Day01A)%20Remote%20Access%20Guide%2020251220A.md), which breaks the physical distance limitation.

---

## 1. Confirm the Network Topology 

Mac/PC (Client) and DGX Spark (Server) **must be located under the same intranet IP segment (192.168.x.x) assigned by the same router**.

This severely limits the physical distance between Client and Server.

---

## 2. On the DGX Spark server, query its intranet IP address on the same subnet
Method 1

Find the DGX Spark's IP address that starts with (192.168.x.x), and make a note of it.
```
jostname -I
```

Method 2

Find the text `inet addr:` or `inet`, followed by an address that starts with (192.168.x.x)—this is the DGX Spark's intranet IP address on the same subnet—and make a note of it.
```
ifconfig
```

---

## 3. Login and Command the DGX Spark Server
### 3.1 SHH Login to the DGX Spark Server from your Mac/PC Client
Use the following simple one-line **SSH** to login DGX Spark Server. (you'll need to enter the DGX Spark boot password)

<sub><sup>＊After rebooting, simply have the Mac/PC Client run this SHH command in step 3.1 - it's super easy.</sup></sub>
```
# Remove `<DGX Spark username>`, and replace it with the username used to log in after DGX Spark boots
# Remove `<192.168.x.x>`, and replace it with DGX Spark intranet IP address (192.168.x.x)
ssh <DGX Spark username>@<192.168.x.x>
```

### 3.2 Two Example Methods to Command the DGX Spark Server from your Mac/PC Client
**On your Mac/PC Client**

Method 1: 

Command the DGX Spark server to report GPU temperature (GPU Temp column) and GPU utilization (GPU-Util column) once per second.
```
watch -n 1 nvidia-smi
```

Method 2: 

Command the DGX Spark server to report total system memory (total column) and current usage (used column) once per second.
```
watch -n 1 free -h
```
You should see both methods working correctly.  

---

# **Congratulations — your Mac/PC can now reach your DGX Spark from the same subnet.**
<sub><sup>＊After rebooting, simply have the Mac/PC Client run this SHH command in step 9.1 - it's super easy.</sup></sub>