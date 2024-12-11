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
Begin here: 
## Installation
STEP 1.
```bash
sudo apt update && sudo apt upgrade
```
STEP 2.
```bash
mkdir $HOME/.nexus
```
STEP 3.
```bash
cd $HOME/.nexus
```
STEP 4.
```bash
echo "Your Node ID" > prover-id
```
STEP 5.
```bash
sudo apt install curl && [ -f "nexus.sh" ] && rm nexus.sh; curl -sSL https://raw.githubusercontent.com/zunxbt/nexus-prover/main/nexus.sh | bash
```
## Status
STEP 6.
```bash
journalctl -u nexus.service -f -n 50
```
Run this command if you forgot your node ID:
```bash
cat ~/.nexus/prover-id
```
