FROM ubuntu:18.04
USER root
RUN apt-get update && apt-get upgrade -y 
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd

ARG PW
RUN echo $PW
RUN echo root:$PW |chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN mkdir /root/.ssh
RUN apt-get install unzip libgomp1 nano curl wget cron -y

COPY crontab-config /etc/cron.d/crontab
RUN  chmod 0644 /etc/cron.d/crontab
RUN /usr/bin/crontab /etc/cron.d/crontab

COPY start_mcl_cron ./root/
RUN chmod +x /root/start_mcl_cron
WORKDIR /root
EXPOSE 22
CMD    ["/usr/sbin/sshd", "-D"]