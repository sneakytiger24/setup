sudo dnf update

sudo dnf install dnf5-plugins -y
sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo -y
sudo dnf install gh --repo gh-cli -y

sudo dnf copr enable sneexy/zen-browser
sudo dnf install zen-browser -y

sudo dnf install google-chrome-stable -y

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
sudo dnf check-update
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Fedora 42 setup script (idempotent and safer)
# Run as a normal user. Some commands require sudo and will prompt.

echo "Starting Fedora 42 setup..."

# Prefer dnf5 if available, otherwise fall back to dnf
if command -v dnf5 >/dev/null 2>&1; then
    DNF=dnf5
else
    DNF=dnf
fi

echo "Using $DNF for package management"

sudo $DNF upgrade --refresh -y

# Install GitHub CLI (uses their repo file)
if ! command -v gh >/dev/null 2>&1; then
    sudo $DNF install -y dnf-plugins-core || true
    sudo curl -fsSL https://cli.github.com/packages/rpm/gh-cli.repo -o /etc/yum.repos.d/gh-cli.repo
    sudo $DNF makecache
    sudo $DNF install -y gh || true
else
    echo "gh already installed"
fi

# Enable and install zen-browser from COPR if not installed
if ! rpm -q zen-browser >/dev/null 2>&1; then
    sudo dnf copr enable -y sneexy/zen-browser || true
    sudo $DNF install -y zen-browser || true
else
    echo "zen-browser already installed"
fi

# Chrome: ensure repository is configured via fedora's repos or install package if available
if ! rpm -q google-chrome-stable >/dev/null 2>&1; then
    sudo $DNF install -y fedora-workstation-repositories || true
    # Add the Chrome repo if package not available from enabled repos
    if ! sudo $DNF list available google-chrome-stable >/dev/null 2>&1; then
        cat <<'EOF' | sudo tee /etc/yum.repos.d/google-chrome.repo >/dev/null
[google-chrome]
name=google-chrome - x86_64
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
EOF
        sudo $DNF makecache
    fi
    sudo $DNF install -y google-chrome-stable || true
else
    echo "google-chrome-stable already installed"
fi

# Visual Studio Code repo and install
if ! command -v code >/dev/null 2>&1; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc || true
    cat <<'EOF' | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
    sudo $DNF check-update || true
    sudo $DNF install -y code || true
else
    echo "Visual Studio Code already installed"
fi

# .NET SDK (9.0) - only attempt if not present
if ! command -v dotnet >/dev/null 2>&1; then
    sudo $DNF install -y dotnet-sdk-9.0 || true
    if command -v dotnet >/dev/null 2>&1; then
        dotnet --version || true
    fi
else
    echo "dotnet already installed: $(dotnet --version)"
fi

# Node.js (install from distro packages)
if ! command -v node >/dev/null 2>&1; then
    sudo $DNF install -y nodejs || true
else
    echo "node already installed: $(node --version)"
fi

# Docker: remove old packages, add Docker repo, and install latest
echo "Configuring Docker..."
sudo $DNF remove -y docker docker-client docker-client-latest docker-common \
    docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine || true

sudo $DNF -y install dnf-plugins-core || true

# Use the official Docker repo file
if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
    sudo curl -fsSL https://download.docker.com/linux/fedora/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
fi

sudo $DNF makecache || true
sudo $DNF install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || true

sudo systemctl enable --now docker || true
sudo usermod -aG docker "$USER" || true
echo "If you added yourself to the docker group, run 'newgrp docker' or log out/in for it to take effect."

# Cleanup
sudo $DNF autoremove -y || true
sudo $DNF clean all || true

# SSH key generation (idempotent)
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "" || true
else
    echo "SSH key already exists at $HOME/.ssh/id_ed25519"
fi

# JetBrains Toolbox: download latest stable link and install into ~/.local/share/JetBrains
JETBRAINS_DIR="$HOME/.local/share/JetBrains"
mkdir -p "$JETBRAINS_DIR"
TOOLBOX_TAR="$HOME/jetbrains-toolbox-latest.tar.gz"
if [ ! -d "$JETBRAINS_DIR/jetbrains-toolbox" ]; then
    echo "Downloading JetBrains Toolbox..."
    curl -fsSL https://data.services.jetbrains.com/products/download?platform=linux&code=TBA -o "$TOOLBOX_TAR" || true
    if [ -f "$TOOLBOX_TAR" ]; then
        tar -xzf "$TOOLBOX_TAR" -C "$HOME"
        rm -f "$TOOLBOX_TAR"
        # Move the extracted folder (it usually starts with jetbrains-toolbox-*)
        EXTRACTED=$(find "$HOME" -maxdepth 1 -type d -name 'jetbrains-toolbox-*' | sort -r | head -n1 || true)
        if [ -n "$EXTRACTED" ]; then
            mv "$EXTRACTED" "$JETBRAINS_DIR/jetbrains-toolbox" || true
            echo "JetBrains Toolbox moved to $JETBRAINS_DIR/jetbrains-toolbox"
            # Attempt to run it in background (non-blocking)
            if [ -x "$JETBRAINS_DIR/jetbrains-toolbox/jetbrains-toolbox" ]; then
                nohup "$JETBRAINS_DIR/jetbrains-toolbox/jetbrains-toolbox" >/dev/null 2>&1 &
            fi
        fi
    else
        echo "Failed to download JetBrains Toolbox tarball; please install manually."
    fi
else
    echo "JetBrains Toolbox already present at $JETBRAINS_DIR/jetbrains-toolbox"
fi

echo "Setup finished. Review any 'failed' messages above and re-run if needed." 
