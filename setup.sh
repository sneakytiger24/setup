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
sudo dnf install code -y 

sudo dnf install dotnet-sdk-9.0 -y
dotnet --version

sudo dnf install nodejs

sudo dnf autoremove -y && sudo dnf clean all

ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""

wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.8.1.52155.tar.gz
tar -xvzf jetbrains-toolbox*.tar.gz
rm jetbrains-toolbox*.tar.gz
# Move the extracted folder to ~/.local/share/Jetbrains/
mkdir -p ~/.local/share/JetBrains
mv jetbrains-toolbox-* ~/.local/share/JetBrains/
# Run the JetBrains Toolbox
cd ~/.local/share/JetBrains/jetbrains-toolbox-* && ./jetbrains-toolbox &
