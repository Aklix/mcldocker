##!/bin/bash
sudo docker-compose up --build build-mcl-win

if [ $? -eq 0 ]; then
    echo "Build successfull"
    sudo cp volumes/mcl-win/marmara/src/marmarad.exe volumes/
    sudo cp volumes/mcl-win/marmara/src/marmara-cli.exe volumes/
else
    echo "Build failed with exit status $?"
fi
