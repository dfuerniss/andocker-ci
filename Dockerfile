# andocker-ci
#
# VERSION	1.0
#
# When using docker via VM make sure to have jenkins 
# port 8080 be forwarded to your host machine.

# use ubuntu 12.04 as the base image
FROM ubuntu:12.04

# define maintainer
MAINTAINER Danny Fürniß <dfuerniss@gmail.com>

# update package repository
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

# install wget
RUN apt-get install -y wget

# install jenkins 
RUN echo deb http://pkg.jenkins-ci.org/debian binary/ >> /etc/apt/sources.list
RUN wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN apt-get update
RUN apt-get install -y jenkins=1.552

# install git
RUN apt-get install -y git

# downgrade java to Oracle JDK Version 1.6
RUN apt-get install -y python-software-properties
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN apt-get install -y oracle-java6-installer
RUN update-java-alternatives -s java-6-oracle
RUN apt-get install -y oracle-java6-set-default

# install android sdk and prerequisites
RUN apt-get install -y ia32-libs
# TODO complete statements wget android, etc.

# set environment
ENV ANDROID_HOME=/root/.jenkins/tools/android-sdk

ENTRYPOINT exec su jenkins -c "java -jar /usr/share/jenkins/jenkins.war"
