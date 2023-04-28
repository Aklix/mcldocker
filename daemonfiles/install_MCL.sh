##!/bin/bash
STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

CUR_DIR=$(pwd)
echo Current directory: $CUR_DIR
echo -e "$STEP_START[ Step 1 ]$STEP_END Installing dependencies"
sudo apt --yes install build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool libncurses-dev unzip git python zlib1g-dev wget curl bsdmainutils automake cmake clang ntp ntpdate nano
sudo apt --yes install python3-zmq  # python3-zmq for ubuntu 20 ubuntu 18 python-zmq
echo -e "$STEP_START[ Step 2 ]$STEP_END Cloning Marmara from MarmaraChain repository"
git clone https://github.com/marmarachain/marmara.git
echo -e "$STEP_START[ Step 3 ]$STEP_END Building marmara"
cd marmara
./zcutil/build.sh -j$(nproc)
cd $CUR_DIR
                                                                                                                
