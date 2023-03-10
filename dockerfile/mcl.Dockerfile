FROM ubuntu:18.04
USER root
RUN apt-get update && apt-get upgrade -y
ARG TZ
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool ncurses-dev unzip git python python-zmq zlib1g-dev wget curl bsdmainutils automake cmake clang ntp ntpdate nano -y
WORKDIR /root
ARG repourl
RUN git clone $repourl
ARG branch
RUN cd /root/marmara && git fetch && git checkout $branch
RUN /root/marmara/zcutil/build.sh -j$(nproc)
COPY run_mcl .
RUN chmod +x /root/run_mcl
