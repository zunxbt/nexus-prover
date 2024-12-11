#!/bin/bash

curl -s https://raw.githubusercontent.com/zunxbt/logo/main/logo.sh | bash
sleep 2

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
PINK='\033[1;35m'

show() {
    case $2 in
        "error")
            echo -e "${PINK}${BOLD}❌ $1${NORMAL}"
            ;;
        "progress")
            echo -e "${PINK}${BOLD}⏳ $1${NORMAL}"
            ;;
        *)
            echo -e "${PINK}${BOLD}✅ $1${NORMAL}"
            ;;
    esac
}

SERVICE_NAME="nexus"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

check_and_install() {
    PACKAGE=$1
    if ! dpkg -l | grep -q "$PACKAGE"; then
        show "$PACKAGE is not installed. Installing..." "progress"
        if ! sudo apt install -y "$PACKAGE"; then
            show "Failed to install $PACKAGE." "error"
            exit 1
        fi
    else
        show "$PACKAGE is already installed."
    fi
}

show "Installing Rust..." "progress"
if ! source <(wget -O - https://raw.githubusercontent.com/zunxbt/installation/main/rust.sh); then
    show "Failed to install Rust." "error"
    exit 1
fi

show "Updating package list..." "progress"
if ! sudo apt update; then
    show "Failed to update package list." "error"
    exit 1
fi

show "Installing git.." "progress"
sudo apt install git

check_and_install wget
check_and_install build-essential
check_and_install pkg-config
check_and_install libssl-dev
check_and_install unzip

if [ -d "$HOME/network-api" ]; then
    show "Deleting existing repository..." "progress"
    sudo rm -rf "$HOME/network-api"
fi

sleep 2

show "Cloning Nexus-XYZ network API repository..." "progress"
if ! git clone https://github.com/nexus-xyz/network-api.git "$HOME/network-api"; then
    show "Failed to clone the repository." "error"
    exit 1
fi

cd $HOME/network-api/clients/cli

show "Downloading Protocol Buffers..." "progress"
if ! wget https://github.com/protocolbuffers/protobuf/releases/download/v21.5/protoc-21.5-linux-x86_64.zip; then
    show "Failed to download Protocol Buffers." "error"
    exit 1
fi

show "Extracting Protocol Buffers..." "progress"
if ! unzip -o protoc-21.5-linux-x86_64.zip -d protoc; then
    show "Failed to extract Protocol Buffers." "error"
    exit 1
fi

show "Installing Protocol Buffers..." "progress"

if [ -d "/usr/local/include/google" ]; then
    sudo rm -rf /usr/local/include/google || { show "Failed to remove existing /usr/local/include/google directory." "error"; exit 1; }
fi

if ! sudo mv protoc/bin/protoc /usr/local/bin/ || ! sudo mv protoc/include/* /usr/local/include/; then
    show "Failed to move Protocol Buffers binaries." "error"
    exit 1
fi

if systemctl is-active --quiet nexus.service; then
    show "nexus.service is currently running. Stopping and disabling it..."
    sudo systemctl stop nexus.service
    sudo systemctl disable nexus.service
else
    show "nexus.service is not running."
fi

show "Creating systemd service..." "progress"
if ! sudo bash -c "cat > $SERVICE_FILE <<EOF
[Unit]
Description=Nexus XYZ Prover Service
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/network-api/clients/cli
Environment=NONINTERACTIVE=1
ExecStart=$HOME/.cargo/bin/cargo run --release --bin prover -- beta.orchestrator.nexus.xyz
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"; then
    show "Failed to create the systemd service file." "error"
    exit 1
fi

show "Reloading systemd and starting the service..." "progress"
if ! sudo systemctl daemon-reload; then
    show "Failed to reload systemd." "error"
    exit 1
fi

if ! sudo systemctl start $SERVICE_NAME.service; then
    show "Failed to start the service." "error"
    exit 1
fi

if ! sudo systemctl enable $SERVICE_NAME.service; then
    show "Failed to enable the service." "error"
    exit 1
fi

show "Check your Nexus Prover logs using this command : journalctl -u nexus.service -fn 50"
echo
