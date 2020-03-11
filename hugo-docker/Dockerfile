FROM alpine:latest
MAINTAINER Maish Saidel-Keesing (maishsk@gmail.com)
RUN apk update && \
    apk add --no-cache python3 git curl && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel boto boto3 awscli && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    wget https://github.com/gohugoio/hugo/releases/download/v0.62.0/hugo_0.62.0_Linux-64bit.tar.gz && \
    tar zxvf hugo_0.62.0_Linux-64bit.tar.gz && \
    mv hugo /usr/local/bin/ && \
    rm -rf LICENSE README.md hugo_0.62.0_Linux-64bit.tar.gz  

