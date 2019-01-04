FROM signiant/docker-jenkins-centos-base:centos7-java8
MAINTAINER devops@signiant.com

ENV BUILD_USER bldmgr
ENV BUILD_USER_GROUP users

# Set the timezone
RUN unlink /etc/localtime \
  && ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

# Install yum packages required for build node
COPY yum-packages.list /tmp/yum.packages.list
RUN chmod +r /tmp/yum.packages.list \
  && yum install -y -q `cat /tmp/yum.packages.list` && yum clean all

# Update node and npm
# - We have to use fixed grunt-connect-proxy version otherwise we get fatal error: socket hang up errors

ENV NPM_VERSION "6.5.0"

RUN npm version && npm install -g n && n stable
RUN npm install -g npm@$NPM_VERSION && npm version \
  && npm install -g grunt grunt-cli whitesource gatsby-cli

# Install the AWS CLI - used by some build processes
RUN pip install awscli maestroops slackclient

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
