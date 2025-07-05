
#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
CYAN='\033[0;36m'
# Package list file
APT_LIST_FILE="apt.list"


#Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "- ${RED}This script must be run as root${NC}" 1>&2
   exit 1
fi

if [ -z "$1" ]; then
    echo -e "- ${RED}Please specify user${NC}"
    read -p "Enter username: " user
    if [ -z "$user" ]; then
        echo -e "- ${RED}No username provided. Exiting.${NC}"
        exit 1
    fi
else
 user="$1"
fi


#if [ -z "$user" ]; then
#	echo -e "- ${RED}Please specify user${NC}"
#	exit 1
#fi

#echo "Add usEr: ${CYAN}$user${NC}"
#adduser $1
echo -e "- ${GREEN}Creating user $user...${NC}"
sudo adduser --gecos "$user" $user

if [ $? -eq 0 ]; then
    echo -e "- ${GREEN}User $user successfully created${NC}"
else
    echo -e "- ${RED}Error creating user $user${NC}"
    # exit 1
fi

# Install necessary packages
apt-get update && apt-get install -y \
	ca-certificates \
	curl \
	gnupg \
	lsb-release \
	sudo \
	unzip
# adding user to sudoers group
echo -e "- ${CYAN}Adding $user to Sudoers group${NC}"
/usr/sbin/usermod -a -G sudo $user

# intall dockers
echo -e "- ${CYAN}Adding dockers keys${NC}"
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes

echo -e "- ${CYAN}Setup dockers repository${NC}"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

curl -sSL https://raw.githubusercontent.com/d00m4n/insfrastructure/refs/heads/main/apt.list -o "$APT_LIST_FILE"
# Check if file exists and proceed only if it does
if [ -f "$APT_LIST_FILE" ]; then
    echo -e "- ${CYAN}Reading packages from $APT_LIST_FILE...${NC}"

    # Update package list
    echo -e "- ${CYAN}APT UPDATE${NC}"
    sudo apt update

    # Read file line by line and install each package
    while IFS= read -r package || [[ -n "$package" ]]; do
        # Skip empty lines and comments (starting with #)
        if [[ -z "$package" || "$package" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        # Remove leading/trailing whitespace
        package=$(echo "$package" | xargs)
        echo -e "- ${CYAN}Installing $package...${NC}"

        
        # Install package
        if sudo apt install -y "$package"; then
            echo "✓ $package installed successfully"
        else
            echo "✗ Error installing $package"
        fi
        
        echo "---"
    done < "$APT_LIST_FILE"

    echo "Process completed!"
fi

# install cockpit
echo "- ${CYAN}Installing extra software${NC}"
echo "- ${CYAN}Cockpit${NC}"
. /etc/os-release
echo "deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" > \
    /etc/apt/sources.list.d/backports.list
apt update && apt install -t ${VERSION_CODENAME}-backports cockpit -y

# install dry to manage docker
echo "- ${CYAN}Dry for Docker${NC}"
curl -sSf https://moncho.github.io/dry/dryup.sh | sh
chmod 755 /usr/local/bin/dry

# install Atuin 
echo "- ${CYAN}Atuin${NC}"
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
#echo 'eval "$(atuin init bash)"' >> /home/$user/.bashrc

# install startship
echo "- ${CYAN}StartShip${NC}"
curl -sS https://starship.rs/install.sh | sh -s -- --force
if ! grep -q "starship init bash" /home/$user/.bashrc; then
    echo 'eval "$(starship init bash)"' >> /home/$user/.bashrc
fi

echo "- ${CYAN}Configuring startShip${NC}"
mkdir -p /home/$user/.config/starship
chown $user:$user /home/$user/.config -R
curl -sSL https://raw.githubusercontent.com/d00m4n/Starship/refs/heads/main/starship.toml -o /home/$user/.config/starship.toml

# Generate SSH keys
echo "- ${CYAN}Generating SSH keys${NC}"
[ ! -f /home/$user/.ssh/id_ed25519 ] && ssh-keygen -t ed25519 -f /home/$user/.ssh/id_ed25519 -q

echo "- ${GREEN}Job done. Remember to log off to apply sudo permissions.${NC}"

exit
# todo imports from github
path="../bots"
fitxer="repos.txt" # Aquest és el fitxer que conté els noms dels repositoris

while IFS= read -r repo
do
    echo "$path/$repo"
    git clone --progress git@github.com:d00m4n/$repo.git "$path/$repo"
done < "$fitxer"
