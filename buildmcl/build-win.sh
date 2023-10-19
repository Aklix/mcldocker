##!/bin/bash
source config-win
sudo docker-compose --env-file config-win up --build

if [ $? -eq 0 ]; then
    echo "Build successfull"
    cp volumes/$repolocation/marmara/src/marmarad.exe volumes/
    cp volumes/$repolocation/marmara/src/marmara-cli.exe volumes/
else
    echo "Build failed with exit status $?"
fi

sudo docker-compose --env-file config-win down