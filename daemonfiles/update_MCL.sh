##!/bin/bash
STEP_START='\e[1;47;42m'
STEP_END='\e[0m'
CUR_DIR=$(pwd)
. $(cd ../ $CUR_DIR && pwd)/.env
target_DIR=$1
echo $target_DIR
if [$target_DIR == ""]
then
    echo "folder not found!"
    echo "example usage : ./update_MCL.sh foldername"
    exit 1
fi
cd $target_DIR
echo  "$STEP_START[ Step 1 ]$STEP_END downloadin mcl relase $mcl_releaseurl"
sudo wget $mcl_releaseurl -o MCL-linux.zip
echo  "$STEP_START[ Step 2 ]$STEP_END extracting zip"
sudo unzip -o MCL-linux.zip
echo "$STEP_START[ Step 3 ]$STEP_END giving permissions"
sudo chmod +x komodod komodo-cli fetch-params.sh
echo "done"
cd $CUR_DIR
                                                                                                                
