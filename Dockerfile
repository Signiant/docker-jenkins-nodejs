FROM signiant/docker-slave
MAINTAINER devops@signiant.com

ENV BUILD_USER bldmgr
ENV BUILD_USER_GROUP users

# Set the timezone
RUN echo "America/New_York" > /etc/timezone \
  && dpkg-reconfigure -f noninteractive tzdata

# Install packages required for build node
COPY apt-get-packages.list /tmp/apt-get-packages.list
RUN apt-get update \
    && chmod +r /tmp/apt-get-packages.list \
    && apt-get install -y `cat /tmp/apt-get-packages.list`

# Update node and npm
# - We have to use fixed grunt-connect-proxy version otherwise we get fatal error: socket hang up errors

ENV NPM_VERSION 5

RUN npm version && npm install -g npm@$NPM_VERSION && npm version \
  && npm install -g grunt grunt-cli n whitesource gatsby-cli

# Install the AWS CLI - used by some build processes
RUN pip install awscli maestroops slackclient

# Make sure anything/everything we put in the build user's home dir is owned correctly
RUN chown -R $BUILD_USER:$BUILD_USER_GROUP /home/$BUILD_USER
