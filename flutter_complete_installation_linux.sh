#!/bin/bash

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

# Extend sudo timeout
sudo -v

# Check if Android Studio is already installed
if is_package_installed android-studio; then
    version=$(snap info android-studio | grep "installed:" | awk '{print $2}')
    echo "Android Studio $version is already installed."
else
    # Install Android Studio from Snapcrafters
    sudo snap install --classic android-studio
fi

# Check if Flutter is already installed
if is_package_installed flutter; then
    version=$(snap info flutter | grep "installed:" | awk '{print $2}')
    echo "Flutter $version is already installed."
else
    # Install Flutter using snapd
    sudo snap install flutter --classic

    # Add Flutter to the PATH
    echo 'export PATH="$PATH:/snap/bin"' >> ~/.bashrc
    source ~/.bashrc

    # Accept Flutter licenses
    flutter doctor --android-licenses
fi

# Check if Git is already installed
if is_package_installed git; then
    version=$(git --version | awk '{print $3}')
    echo "Git $version is already installed."
else
    # Install Git
    sudo apt install -y git
fi

# Check if Visual Studio Code is already installed
if is_package_installed code; then
    version=$(code --version | awk '{print $1}')
    echo "Visual Studio Code $version is already installed."
else
    # Install Visual Studio Code using snapd
    sudo snap install --classic code
fi

# Prompt user for manual installation of Android SDK, Platform Tools, and Command-Line Tools
read -p "Please manually install Android SDK, Platform Tools, and Command-Line Tools through the Android Studio GUI. Press [Enter] when done."

# Prompt user for confirmation
read -p "Have you installed Android SDK, Platform Tools, and Command-Line Tools? (Y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Check Flutter installation and add paths if successful
    output=$(flutter doctor -v)

    # Check if "No issues found!" line exists
    if [[ $output == *"• No issues found!"* ]]; then
        echo "All checks pass. No issues found!"
        echo "Running 'flutter doctor' command for detailed report:"
        flutter doctor

        # Extract Android SDK path from the output
        android_sdk_path=$(echo "$output" | grep -oP '(?<=Android SDK at )[^ ]+')

        if [[ -n $android_sdk_path ]]; then
            echo "Android SDK path: $android_sdk_path"
            export ANDROID_HOME="$android_sdk_path"
            export PATH="$PATH:$ANDROID_HOME/platform-tools"

            # Check if the export statements already exist in ~/.bashrc
            if ! line_exists "export ANDROID_HOME=\"$android_sdk_path\""; then
                echo "export ANDROID_HOME=\"$android_sdk_path\"" >> ~/.bashrc
            fi
            if ! line_exists "export PATH=\"\$PATH:\$ANDROID_HOME/platform-tools\""; then
                echo "export PATH=\"\$PATH:\$ANDROID_HOME/platform-tools\"" >> ~/.bashrc
            fi
        else
            echo "Android SDK path not found."
        fi

        # Extract Java binary path from the output
        java_binary=$(echo "$output" | grep -oP '(?<=Java binary at: )[^ ]+(?=/bin/java)')

        if [[ -n $java_binary ]]; then
            echo "Java binary path: $java_binary"
            export JAVA_HOME="$java_binary"

            # Check if the export statement already exists in ~/.bashrc
            if ! line_exists "export JAVA_HOME=\"$java_binary\""; then
                echo "export JAVA_HOME=\"$java_binary\"" >> ~/.bashrc
            fi
        else
            echo "Java binary path not found."
        fi

        # Reload the ~/.bashrc file to apply the changes in the current session
        source ~/.bashrc

    else
        echo "Flutter doctor check failed. Please make sure all required dependencies are installed."
    fi
else
    echo "Please manually install Android SDK, Platform Tools, and Command-Line Tools."
fi
