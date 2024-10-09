<h2 align=center>Run Nexus Prover Beta</h2>

## Info
- You need to have min 4 RAM in your system (VPS)
- Recommended : 6 GB RAM
- You can buy VPS from [PQ Hosting](https://pq.hosting/?from=622403&lang=en) using cryptocurrency
---
This script is compatible with Ubuntu on local system as well as on VPS
- If you run on VPS, u don't need to do anything after running the installation commands
- If you run on Local system (Ubuntu), u just need to open the terminal after turning on your system to start this prover, it will start running automatically again, if it is not running then use this command to run
```bash
sudo systemctl start nexus.service
```

## Installation
- You can use either this command
```bash
curl -sSL https://raw.githubusercontent.com/zunxbt/nexus-prover/main/nexus.sh | bash
```
- Or this command to run this script
```bash
wget -qO - https://raw.githubusercontent.com/zunxbt/nexus-prover/main/nexus.sh | bash
```

## Status
- You can check prover status using this command
```bash
systemctl status nexus.service
```
- To check logs, use the below command
```bash
journalctl -u nexus.service -f -n 50
```
- You will see something like this, it means, it is fine

![Screenshot 2024-10-09 115039](https://github.com/user-attachments/assets/3d3065d8-cb88-44ca-88b8-ac072bcf9eff)
