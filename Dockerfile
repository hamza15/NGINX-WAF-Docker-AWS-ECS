FROM ubuntu:latest
MAINTAINER Hamza Naqi, sardan5@vt.edu

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y tzdata locales

# Set the timezone
RUN echo "America/New_York" | tee /etc/timezone && \
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Set the locale for UTF-8 support
RUN echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && \
    locale-gen && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# AWS CLI needs the PYTHONIOENCODING environment varialbe to handle UTF-8 correctly:
ENV PYTHONIOENCODING=UTF-8

# man and less are needed to view 'aws <command> help'
# ssh allows us to log in to new instances
# nano is useful to read and write files in linux
# python* is needed to install aws cli using pip install

RUN apt-get install -y \
    less \
    man \
    ssh \
    python \
    python-pip \
    python-virtualenv \
    vim \
    wget \
    zip

USER root

#Create directory
RUN mkdir /script

#Add file from host to container
ADD bootstrap.sh /script/bootstrap.sh

#Change permissions on file to make it executable
RUN chmod +x /script/bootstrap.sh

#Launches this script at launch time for container.
ENTRYPOINT ["/script/bootstrap.sh"]
