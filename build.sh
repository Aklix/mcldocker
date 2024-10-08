##!/bin/bash
sudo docker-compose up --build build-mcl-linux

if [ $? -eq 0 ]; then
    echo "Build successfull"
    sudo cp volumes/mcl-linux/marmara/src/marmarad volumes/
    sudo cp volumes/mcl-linux/marmara/src/marmara-cli volumes/
else
    echo "Build failed with exit status $?"
fi
