# andocker-ci
#
# VERSION	1.0
#
# When using docker via VM make sure to have jenkins 
# port 8080 be forwarded to your host machine.

# use ubuntu 12.04 (LTS) as the base image
FROM ubuntu:12.04

# define maintainer
MAINTAINER Danny Fürniß <dfuerniss@gmail.com>

# configure non-interactive frontend
ENV DEBIAN_FRONTEND noninteractive

# update package repository
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

# install wget and curl
RUN apt-get install -y wget
RUN apt-get install -y curl

# install jenkins 
RUN echo deb http://pkg.jenkins-ci.org/debian binary/ >> /etc/apt/sources.list
RUN wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN apt-get update
RUN apt-get install -y jenkins

# install jenkins plugins
RUN mkdir /root/.jenkins
RUN mkdir /root/.jenkins/plugins
RUN curl -sf -o /root/.jenkins/plugins/ssh-credentials.hpi -L http://mirrors.jenkins-ci.org/plugins/ssh-credentials/latest/ssh-credentials.hpi
RUN curl -sf -o /root/.jenkins/plugins/git-client.hpi -L http://mirrors.jenkins-ci.org/plugins/git-client/latest/git-client.hpi
RUN curl -sf -o /root/.jenkins/plugins/scm-api.hpi -L http://mirrors.jenkins-ci.org/plugins/scm-api/latest/scm-api.hpi
RUN curl -sf -o /root/.jenkins/plugins/credentials.hpi -L http://mirrors.jenkins-ci.org/plugins/credentials/latest/credentials.hpi
RUN curl -sf -o /root/.jenkins/plugins/git.hpi -L http://mirrors.jenkins-ci.org/plugins/git/latest/git.hpi
RUN curl -sf -o /root/.jenkins/plugins/gradle.hpi -L http://mirrors.jenkins-ci.org/plugins/gradle/latest/gradle.hpi
RUN curl -sf -o /root/.jenkins/plugins/analysis-core.hpi -L http://mirrors.jenkins-ci.org/plugins/analysis-core/latest/analysis-core.hpi
RUN curl -sf -o /root/.jenkins/plugins/android-lint.hpi -L http://mirrors.jenkins-ci.org/plugins/android-lint/latest/android-lint.hpi
RUN curl -sf -o /root/.jenkins/plugins/port-allocator.hpi -L http://mirrors.jenkins-ci.org/plugins/port-allocator/latest/port-allocator.hpi
RUN curl -sf -o /root/.jenkins/plugins/android-emulator.hpi -L http://mirrors.jenkins-ci.org/plugins/android-emulator/latest/android-emulator.hpi
RUN curl -sf -o /root/.jenkins/plugins/scm-sync-configuration.hpi -L http://mirrors.jenkins-ci.org/plugins/scm-sync-configuration/latest/scm-sync-configuration.hpi

# install git
RUN apt-get install -y git

# downgrade java to Oracle JDK Version 1.6
RUN apt-get install -y python-software-properties
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN echo oracle-java6-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java6-installer && apt-get clean
RUN update-java-alternatives -s java-6-oracle
RUN apt-get install -y oracle-java6-set-default
ENV JAVA_HOME /usr/lib/jvm/java-6-oracle

# fake a fuse install (to prevent ia32-libs package from producing errors)
# this one is from https://index.docker.io/u/ahazem/android/
RUN apt-get install libfuse2
RUN cd /tmp ; apt-get download fuse
RUN cd /tmp ; dpkg-deb -x fuse_* .
RUN cd /tmp ; dpkg-deb -e fuse_*
RUN cd /tmp ; rm fuse_*.deb
RUN cd /tmp ; echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst
RUN cd /tmp ; dpkg-deb -b . /fuse.deb
RUN cd /tmp ; dpkg -i /fuse.deb

#ADD https://raw.github.com/dfuerniss/andocker-ci/master/README.md /

# install android sdk and prerequisites
RUN apt-get install -y ia32-libs
RUN wget http://dl.google.com/android/android-sdk_r22.6-linux.tgz
RUN tar -xvzf android-sdk_r22.6-linux.tgz
RUN mv android-sdk-linux /usr/local/android-sdk

# set environment
ENV ANDROID_HOME /usr/local/android-sdk
ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools

# update SDK tools, platform tools and build-tools to latest revision
#RUN BUILD_TOOLS_VERSION=`android list sdk -a -e | grep -Po 'build-tools-\d*\.\d*\.\d*' | head -n 1`
#RUN echo "y" | android update sdk --no-ui --force --filter tool,platform-tool

# install build-tools
RUN echo "y" | android update sdk --no-ui -a --force --filter build-tools-19.0.1
RUN echo "y" | android update sdk --no-ui -a --force --filter build-tools-19.0.2
RUN echo "y" | android update sdk --no-ui -a --force --filter build-tools-19.0.3 

# install android-19
RUN echo "y" | android update sdk --no-ui -a --force --filter android-19
# install android-18
#RUN echo "y" | android update sdk --no-ui --force --filter android-18
# install android-17
#RUN echo "y" | android update sdk --no-ui --force --filter android-17
# install android-16
#RUN echo "y" | android update sdk --no-ui --force --filter android-16
# install android-15
#RUN echo "y" | android update sdk --no-ui --force --filter android-15
# install android-14
#RUN echo "y" | android update sdk --no-ui --force --filter android-14

# install android extras
RUN echo "y" | android update sdk --no-ui -a --force --filter extra-android-m2repository,extra-android-support,extra-google-analytics_sdk_v2,extra-google-google_play_services,extra-google-m2repository,extra-google-play_apk_expansion,extra-google-play_billing,extra-google-play_licensing

# install Google APIs
RUN echo "y" | android update sdk --no-ui -a --force --filter addon-google_apis_x86-google-19,addon-google_apis-google-19

# clean up temporary files
RUN cd /; rm android-sdk_r22.6-linux.tgz 

EXPOSE 8080

CMD ["java", "-jar", "/usr/share/jenkins/jenkins.war"]
#ENTRYPOINT exec su jenkins -c "java -jar /usr/share/jenkins/jenkins.war"
