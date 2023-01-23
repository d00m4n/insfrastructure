user="$1"
if [ ! -n "$user" ]
then
	echo "Please specify user"
	exit
else
	echo "User:" $user
fi

apt-get install -y ca-certificates /
	curl /
	gnupg /
	lsb-release /
	sudo /
	unzip

echo "Adding dockers keys"
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "Setup repository"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo Addind $user to Sudors grop
# usermod -a -G sudo $user
apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y


exit
repos="majord00m tuitBot tabout bittrexBot cmcairbot dtools dropBot "
path="../bots"
for repo in $repos
do
    echo "$path/$repo"
    git clone  --progress git@github.com:d00m4n/$repo.git "$path/$repo"
done

# git clone git@github.com:d00m4n/majord00m.git ../majord00m
# git clone git@github.com:d00m4n/tuitBot.git
