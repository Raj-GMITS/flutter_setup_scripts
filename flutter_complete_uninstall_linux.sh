#!/bin/bash

# Extend sudo timeout
sudo -v

# Function to check if a package is installed
function is_package_installed() {
    if dpkg -s "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to check if a line exists in the ~/.bashrc file
line_exists() {
    grep -Fxq "$1" ~/.bashrc
}

# Remove Flutter and Dart
sudo snap remove flutter
sudo snap remove dart

# Remove Git
sudo apt purge -y git

# Remove Visual Studio Code
sudo snap remove code

# Remove Android Studio and its configuration
sudo snap remove android-studio
rm -rf ~/snap/android-studio
rm -rf ~/.android
rm -rf ~/.AndroidStudio*
rm -rf ~/.local/share/applications/jetbrains-studio.desktop
rm -rf ~/.config/google-android-studio

# Remove Flutter and Dart paths from ~/.bashrc
sed -i '/export PATH=\$PATH:\/snap\/bin/d' ~/.bashrc
sed -i '/export ANDROID_HOME=/d' ~/.bashrc
sed -i '/export JAVA_HOME=/d' ~/.bashrc

# Clear package cache
sudo apt clean

echo "Flutter and related dependencies have been completely removed."
