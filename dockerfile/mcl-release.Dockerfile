FROM ubuntu:18.04
USER root
RUN apt-get update && apt-get upgrade -y 
RUN apt-get install unzip libgomp1 nano wget -y
RUN mkdir /root/marmara && mkdir /root/marmara/src
ARG CHAINLINK
RUN cd /root/marmara/src && wget $CHAINLINK && unzip MCL-linux.zip && chmod +x komodod komodo-cli fetch-params.sh
COPY run_mcl ./root/
RUN chmod +x /root/run_mcl
WORKDIR /root