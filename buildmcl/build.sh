##!/bin/bash
sudo docker-compose --env-file config-linux up --build

if [ $? -eq 0 ]; then
    echo "Build successfull"
    cp volumes/marmara/src/marmarad volumes/
    cp volumes/marmara/src/marmara-cli volumes/
else
    echo "Build failed with exit status $?"
fi

sudo docker-compose down