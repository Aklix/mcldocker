FROM ubuntu:18.04
USER root
RUN apt-get update
RUN apt-get upgrade -y
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool ncurses-dev unzip git python python-zmq zlib1g-dev wget curl bsdmainutils automake cmake clang ntp ntpdate nano -y
RUN git clone https://github.com/marmarachain/marmara ~/marmara 
RUN ~/marmara/zcutil/build.sh -j$(nproc)
