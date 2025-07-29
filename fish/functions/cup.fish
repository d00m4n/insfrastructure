function cup
    docker run -tv /var/run/docker.sock:/var/run/docker.sock ghcr.io/sergi0g/cup check -i
end
