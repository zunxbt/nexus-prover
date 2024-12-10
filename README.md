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
sudo apt update && sudo apt upgrade
2. mkdir $HOME/.nexus
3. cd $HOME/.nexus

4. Then
echo "Your Node ID" > prover-id
5. sudo apt install curl && [ -f "nexus.sh" ] && rm nexus.sh; curl -sSL https://raw.githubusercontent.com/zunxbt/nexus-prover/main/nexus.sh | bash

## Status
6. journalctl -u nexus.service -f -n 50
7. Run this command if you forgot your node ID: cat ~/.nexus/prover-id
