FROM signiant/docker-jenkins-centos-base:centos7
MAINTAINER devops@signiant.com

ENV BUILD_USER bldmgr
ENV BUILD_USER_GROUP users

# Set the timezone
RUN unlink /etc/localtime
RUN ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

# Install yum packages required for build node
COPY yum-packages.list /tmp/yum.packages.list
RUN chmod +r /tmp/yum.packages.list
RUN yum install -y -q `cat /tmp/yum.packages.list`

# Install NodeJS
RUN wget http://nodejs.org/dist/v5.1.0/node-v5.1.0-linux-x64.tar.gz 
RUN tar --strip-components 1 -xzvf node-v* -C /usr/local

# Update node and npm
#RUN npm install -g npm
RUN npm install -g grunt
RUN npm install -g grunt-cli

# We have to use this fixed version otherwise we get fatal error: socket hang up errors
RUN npm install -g grunt-connect-proxy@0.1.10

# Install the AWS CLI - used by some build processes
RUN pip install awscli

# Make sure anything/everything we put in the build user's home dir is owned correctly
RUN chown -R $BUILD_USER:$BUILD_USER_GROUP /home/$BUILD_USER  

EXPOSE 22

# This entry will either run this container as a jenkins slave or just start SSHD
# If we're using the slave-on-demand, we start with SSH (the default)

# Default Jenkins Slave Name
ENV SLAVE_ID JAVA_NODE
ENV SLAVE_OS Linux

ADD start.sh /
RUN chmod 777 /start.sh

CMD ["sh", "/start.sh"]

