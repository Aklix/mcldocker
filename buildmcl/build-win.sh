##!/bin/bash
sudo docker-compose --env-file config-win up --build

if [ $? -eq 0 ]; then
    echo "Build successfull"
    cp volumes/marmara/src/marmarad.exe volumes/
    cp volumes/marmara/src/marmara-cli.exe volumes/
else
    echo "Build failed with exit status $?"
fi

sudo docker-compose down