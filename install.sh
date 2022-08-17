#!/bin/bash

linux_install_with_package_manager() {
  # if the OS is debian/ubuntu use apt-get to install $1
    if [ -f /etc/debian_version ]; then
        sudo apt-get install -y $1
    # elif the OS is archlinux use pacman to install $1
    elif [ -f /etc/arch-release ]; then
        sudo pacman -S --noconfirm $1
    # elif the OS is redhat/fedora use yum to install $1
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y $1
    else
        echo "OS not supported"
        exit 1
    fi
}

linux_update_package_manager(){
    if [ -f /etc/debian_version ]; then
        sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
    elif [ -f /etc/arch-release ]; then
        sudo pacman -Syu
    elif [ -f /etc/redhat-release ]; then
        sudo yum update
    else
        echo "OS not supported"
        exit 1
    fi
}

install_pip3_in_function_of_OS() {
    if [ -f /etc/debian_version ]; then
        sudo apt-get install -y python3-pip
    elif [ -f /etc/arch-release ]; then
        sudo pacman -S --noconfirm python3-pip
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y python3-pip
    else
        echo "OS not supported"
        exit 1
    fi
}


# update the packager appropriately for the OS and architecture
if [ "$(uname)" == "Darwin" ]; then
    export PACKAGER="macosx"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    export PACKAGER="linux"
fi

# update the architecture appropriately for the OS and architecture
if [ "$(uname -m)" == "x86_64" ]; then
    export ARCH="amd64"
elif [ "$(uname -m)" == "i686" ]; then
    export ARCH="386"
fi

# if the var $PACKAGER is not set, exit with an error
if [ -z "$PACKAGER" ]; then
    echo "Unable to determine the packager for this OS and architecture."
    exit 1
else
# else call the appropriate package manager to install
    if [[ "$PACKAGER" == "linux" ]]; then
        echo 'linux package manager update...'
        linux_update_package_manager
        echo 'linux package manager install...'
        linux_install_with_package_manager python3
        install_pip3_in_function_of_OS
    elif [[ "$PACKAGER" == "macosx" ]]; then
        if [ -f /usr/local/bin/brew ]; then
            echo "Homebrew is already installed so brew update and brew upgrade"
            echo "Homebrew installation skipped."
            brew update
            brew install python@3.9 pipenv
        else
            echo "Homebrew is not installed. Installation of homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            echo "Now installing, brew update and install python@3.9 and pipenv..."
            brew update
            brew install python@3.9 pipenv
        fi
    fi
fi

# install dependencies of twint-explorer in function of the OS and architecture
# dependencies is [libsqlite3-dev libxss1 libx11-xcb-dev libxtst-dev libgconf-2-4 libnss3 libasound-dev]
# Darwin not supported
if [ "$PACKAGER" == "Darwin" ]; then
    echo "OS not supported"
    exit 1
elif [ "$PACKAGER" == "Linux" ]; then
    # install [libsqlite3-dev libxss1 libx11-xcb-dev libxtst-dev libgconf-2-4 libnss3 libasound-dev] with the linux_install_with_package_manager() function
    linux_install_with_package_manager libsqlite3-dev
    linux_install_with_package_manager libxss1
    linux_install_with_package_manager libx11-xcb-dev
    linux_install_with_package_manager libxtst-dev
    linux_install_with_package_manager libgconf-2-4
    linux_install_with_package_manager libnss3
    linux_install_with_package_manager libasound-dev
    # install [nodejs npm] with the linux_install_with_package_manager() function
    linux_install_with_package_manager nodejs
    linux_install_with_package_manager npm
    
fi

pip3 install twint
pip3 install --user --upgrade git+https://github.com/twintproject/twint.git@origin/master#egg=twint
cp patch/cli.py ~/.local/lib/python3.10/site-packages/twint/cli.py

# install nodeJS
sudo apt install nodejs -y
sudo apt install npm -y
git clone https://github.com/twintproject/twint-explorer.git
cd twint-explorer
chmod +x install.sh
./install.sh
cd ..
rm -rf twint-explorer
