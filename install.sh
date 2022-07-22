#!/bin/bash
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
sudo apt install python3 python3-pip
pip3 install twint
pip3 install --user --upgrade git+https://github.com/twintproject/twint.git@origin/master#egg=twint
cp patch/cli.py ~/.local/lib/python3.10/site-packages/twint/cli.py
