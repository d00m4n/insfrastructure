apt install docker sudo -y

repos="majord00m tuitBot tabout bittrexBot cmcairbot dtools dropBot "
path="../bots"
for repo in $repos
do
    echo "$path/$repo"
    git clone  --progress git@github.com:d00m4n/$repo.git "$path/$repo"
done

# git clone git@github.com:d00m4n/majord00m.git ../majord00m
# git clone git@github.com:d00m4n/tuitBot.git
