# Based on https://github.com/NeonDistrict/loom-ubuntu-docker
FROM ubuntu:16.04

RUN apt-get update -y && \
	apt-get -y install curl unzip make git

# Download Go packages
RUN curl -O https://dl.google.com/go/go1.10.2.linux-amd64.tar.gz && \
	tar -C /usr/local -xzf go1.10.2.linux-amd64.tar.gz
RUN echo -n "\nexport PATH=\$PATH:/usr/local/go/bin:/gopath/bin" >> ~/.bashrc && \
	/bin/bash -c "source ~/.bashrc"
ENV PATH ${PATH}:/usr/local/go/bin:/gopath/bin

# Protobuf
ENV PROTOBUF_VERSION 3.5.1
RUN curl -OL https://github.com/google/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip && \
	unzip protoc-${PROTOBUF_VERSION}-linux-x86_64.zip -d /usr/local && \
	chmod +x /usr/local/bin/protoc

# Install Golang
RUN mkdir -p /gopath/bin
ENV GOPATH /gopath
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh


# Optional: Install Node.JS, NPM & Truffle
RUN apt-get install -y build-essential
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g truffle


# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn

## Loom - leave this at the end, it's the most likely to change,
## and we don't want to constantly reinstall / rebuild everything

# Loom Latest
#ENV LOOM_VERSION 327

# Loom Stable
ENV LOOM_VERSION 288
ADD https://private.delegatecall.com/loom/linux/build-${LOOM_VERSION}/loom /usr/local/bin/loom
RUN chmod +x /usr/local/bin/loom

WORKDIR /opt/go-cook

EXPOSE 9999 9000 46656 46657 46658

ENTRYPOINT ["tail", "-f", "/dev/null"]