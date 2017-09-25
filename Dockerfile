# Dockerfile
# using debian:jessie for it's smaller size over ubuntu
FROM debian:jessie

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set environment variables
ENV appDir /var/www/app/current

ENV PORT 4096
# Run updates and install deps
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y -q --no-install-recommends \
    apt-transport-https \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    curl \
    gcc \
    g++ \
    git \
    libssl-dev \
    libsqlite3-dev \
    libtool \
    make \
    openssl \
    python \
    sqlite3 \
    sudo \
    wget \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get -y autoclean

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 8.5.0

# Install nvm with node and npm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# Set up our PATH correctly so we don't have to long-reference npm, node, &c.
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Set the work directory
RUN mkdir -p /var/www/app/current
WORKDIR ${appDir}

# Add our package.json and install *before* adding our application files
ADD package.json ./

# Install global dependencies so we can run our application

RUN npm i -g yarn

RUN yarn global add node-gyp gulp browserify pm2
# Add application files
ADD . /var/www/app/current

RUN yarn install --production=true

#Expose the port
EXPOSE ${PORT}

CMD ["pm2-docker","app.js"]
