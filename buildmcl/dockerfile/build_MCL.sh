##!/bin/bash
STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

CUR_DIR=$(pwd)
echo Current directory: $CUR_DIR

if [ -d "marmara/src" ]; then
    echo -e "$STEP_START[ Step 1 ]$STEP_END Repository already exists, fetching updates..."
    cd "marmara"
    git pull
    cd $CUR_DIR
else
    echo -e "$STEP_START[ Step 1 ]$STEP_END Cloning Marmara from MarmaraChain repository"
    git clone $repourl
fi

echo -e "$STEP_START[ Step 2 ]$STEP_END Switching Branch $branch"

cd marmara
git checkout $branch

echo $build
echo -e "$STEP_START[ Step 3 ]$STEP_END Building marmara"
make clean
$build -j$(nproc)
cd $CUR_DIR

                                                                                                                
