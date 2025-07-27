#!/bin/bash
# Release v1.0.9
# Llegir directament del terminal
read -p "Username: " USERNAME < /dev/tty

# Validar que s'ha introduït un usuari
if [ -z "$USERNAME" ]; then
    echo "Error: Cal introduir un nom d'usuari"
    exit 1
fi

read -s -p "Password: " PASSWORD < /dev/tty
# Descarregar setup.sh
echo "Downloading setup"
apt update && apt install -y p7zip-full
curl -L https://github.com/d00m4n/insfrastructure/archive/refs/heads/main.zip -o temp.zip && 7z x temp.zip -y && mv insfrastructure-main insfrastructure && rm temp.zip
cd insfrastructure
# select services to install
bash select-services.sh
chmod +x setup.sh

# run setup with the user
sudo ./setup.sh "$USERNAME" "$PASSWORD"
