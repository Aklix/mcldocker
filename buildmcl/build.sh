##!/bin/bash
source config-linux
sudo docker-compose --env-file config-linux up --build

if [ $? -eq 0 ]; then
    echo "Build successfull"
    sudo cp volumes/$repolocation/marmara/src/marmarad volumes/
    sudo cp volumes/$repolocation/marmara/src/marmara-cli volumes/
else
    echo "Build failed with exit status $?"
fi

sudo docker-compose --env-file config-linux down