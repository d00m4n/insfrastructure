
#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
CYAN='\033[0;36m'
# echo -e "I ${RED}love${NC} Stack Overflow"

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "- ${RED}This script must be run as root${NC}" 1>&2
   exit 1
fi
user="$1"

if [ -z "$user" ]; then
	echo -e "- ${RED}Please specify user${NC}"
	exit 1
fi

echo -e "User: ${CYAN}$user${NC}"

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


apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
# install cockpit
echo -e "- ${CYAN}Installing extra software${NC}"
echo -e " * ${CYAN}Cockpit${NC}"
. /etc/os-release
echo "deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" > \
    /etc/apt/sources.list.d/backports.list
apt update && apt install -t ${VERSION_CODENAME}-backports cockpit -y

# install dry to manage docker
echo -e " * ${CYAN}Dry for Docker${NC}"
curl -sSf https://moncho.github.io/dry/dryup.sh | sh
chmod 755 /usr/local/bin/dry

echo -e "- ${GREEN}Job done. Remember to log off to apply sudo permissions.${NC}"
exit
# todo imports from github
path="../bots"
fitxer="repos.txt" # Aquest és el fitxer que conté els noms dels repositoris

while IFS= read -r repo
do
    echo "$path/$repo"
    git clone --progress git@github.com:d00m4n/$repo.git "$path/$repo"
done < "$fitxer"