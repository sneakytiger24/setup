sudo dnf upgrade --refresh -y

# NVM AND NODEJS INSTALLATION SCRIPT
# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"
# Download and install Node.js:
nvm install 22
# Verify the Node.js version:
node -v # Should print "v22.19.0".
# Verify npm version:
npm -v # Should print "10.9.3".
#########################################################################################################
# JETBRAINS TOOLBOX INSTALLATION SCRIPT
wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.8.1.52155.tar.gz
tar -xvzf jetbrains-toolbox*.tar.gz
rm jetbrains-toolbox*.tar.gz
# Move the extracted folder to ~/.local/share/Jetbrains/
mkdir -p ~/.local/share/JetBrains
mv jetbrains-toolbox-* ~/.local/share/JetBrains/
~/.local/share/JetBrains/jetbrains-toolbox-*/jetbrains-toolbox &
#########################################################################################################
# Google chrome Installation Script
sudo dnf install google-chrome-stable -y
# OR
# sudo dnf install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -y
# OR
# wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
# sudo dnf install ./google-chrome-stable_current_x86_64.rpm -y
# rm google-chrome-stable_current_x86_64.rpm    
#########################################################################################################
# Visual Studio Code Installation Script
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
sudo dnf check-update
sudo dnf install code -y # or code-insiders
#########################################################################################################
# Java Installation Script
sudo dnf install java-21-openjdk-devel.x86_64 -y && sudo dnf install java-25-openjdk-devel.x86_64 -y
java -version
javac -version
#########################################################################################################
# Clean up
sudo dnf autoremove -y && sudo dnf clean all
