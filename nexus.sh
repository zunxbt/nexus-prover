#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

task() {
    echo -e "${MAGENTA}[TASK]${NC} $1"
}


task "Installing system packages"
packages=(curl wget build-essential pkg-config libssl-dev unzip git-all screen)
for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q "^ii  $pkg "; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $pkg
    else
        info "$pkg is already installed"
    fi
done

task "Checking Rust installation"
if ! command -v rustc &> /dev/null; then
    info "Installing Rust"
    curl -sSL https://raw.githubusercontent.com/zunxbt/installation/main/rust.sh | bash || error "Failed to install Rust"
    sleep 2
    . "$HOME/.cargo/env"
    sleep 1
    rustup target add riscv32i-unknown-none-elf
else
    info "Rust is already installed"
fi

task "Installing Protocol Buffers"
if ! command -v protoc &> /dev/null; then
    wget https://github.com/protocolbuffers/protobuf/releases/download/v21.5/protoc-21.5-linux-x86_64.zip
    
    task "Extracting Protocol Buffers"
    if ! unzip -o protoc-21.5-linux-x86_64.zip -d protoc; then
        error "Failed to extract Protocol Buffers"
    fi

    task "Installing Protocol Buffers"
    sudo rm -rf /usr/local/include/google 2>/dev/null
    sudo mv protoc/bin/protoc /usr/local/bin/ || error "Failed to move protoc binary"
    sudo mv protoc/include/* /usr/local/include/ || error "Failed to move protoc headers"
    
    rm -rf protoc*
    success "Protocol Buffers installed"
else
    info "Protocol Buffers is already installed"
fi

task "Running Nexus CLI"
curl https://cli.nexus.xyz/ | sh
