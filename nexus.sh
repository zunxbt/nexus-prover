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

run_with_spinner() {
    local msg="$1"
    shift
    local cmd=("$@")
    local pid
    local spin_chars='🕘🕛🕒🕡'
    local delay=0.1
    local i=0

    "${cmd[@]}" > /dev/null 2>&1 &
    pid=$!

    printf "${MAGENTA}[TASK]${NC} %s...  " "$msg"

    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r${MAGENTA}[TASK]${NC} %s... ${CYAN}%s${NC}" "$msg" "${spin_chars:$i:1}"
        sleep "$delay"
    done

    wait "$pid"
    local exit_status=$?

    printf "\r\033[K"
    return $exit_status
}

task "Installing system packages"
packages=(curl wget build-essential pkg-config libssl-dev unzip git-all screen)
for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q "^ii  $pkg "; then
        run_with_spinner "Installing $pkg" sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $pkg
    else
        info "$pkg is already installed"
    fi
done

task "Checking Rust installation"
if ! command -v rustc &> /dev/null; then
    info "Installing Rust"
    curl -sSL https://raw.githubusercontent.com/zunxbt/installation/main/rust.sh | bash || error "Failed to install Rust"
    source "$HOME/.cargo/env"
else
    info "Rust is already installed"
fi

task "Installing Protocol Buffers"
if ! command -v protoc &> /dev/null; then
    run_with_spinner "Downloading Protocol Buffers" wget https://github.com/protocolbuffers/protobuf/releases/download/v21.5/protoc-21.5-linux-x86_64.zip
    
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

NEXUS_HOME=$HOME/.nexus
REPO_PATH=$NEXUS_HOME/network-api

task "Setting up Nexus"
[ -d "$NEXUS_HOME" ] || mkdir -p "$NEXUS_HOME"

if [ -d "$REPO_PATH" ]; then
    task "Updating existing repository"
    (cd "$REPO_PATH" && git stash && git fetch --tags)
else
    task "Cloning repository"
    git clone https://github.com/nexus-xyz/network-api "$REPO_PATH" || error "Failed to clone repository"
fi

task "Checking out latest release"
(cd "$REPO_PATH" && git -c advice.detachedHead=false checkout $(git rev-list --tags --max-count=1)) || error "Failed to checkout latest version"


task "Managing Nexus screen session"
if screen -list | grep -q "Nexus"; then
    task "Stopping existing Nexus session"
    screen -XS Nexus quit || warn "Failed to stop existing session"
fi

success "Installation completed successfully"
info "Now to run the prover ${YELLOW}follow the commands in the Readme file${NC}"
