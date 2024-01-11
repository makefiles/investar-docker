FROM ubuntu:20.04

RUN apt update -y
RUN apt install python3.8 -y
RUN apt install vim -y
RUN apt install net-tools -y
RUN apt install iputils-ping -y
RUN apt install python3-pip -y

# FIXME: Hangul
#ENV DEBIAN_FORNTEND="noninteractive"
#RUN apt update && \ 
#    apt install -y --no-install-recommends apt-utils && \
#    apt upgrade -y
#RUN apt install -y language-pack-ko && \
#    dpkg-reconfigure locales && \
#    locale-gen ko_KR.UTF-8 && \
#    /usr/sbin/update-locale LANG=ko_KR.UTF-8  && \
#    apt install -y fonts-nanum fonts-nanum-coding 
#ENV LANG=ko_KR.UTF-8 
#ENV LANGUAGE=ko_KR.UTF-8 
#ENV LC_ALL=ko_KR.UTF-8

# Timezone
ENV TZ Asia/Seoul 
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt install -y vim net-tools iputils-ping curl wget tree jq

# Package
COPY ./init/requirements.txt /requirements.txt
RUN pip3 install -r /requirements.txt

WORKDIR /root
RUN echo 'alias python=python3.8' >> .bashrc

WORKDIR /script
CMD python3.8 DBUpdater.py >> DBUpdater.log
