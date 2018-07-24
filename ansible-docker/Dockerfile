FROM alpine:3.8
MAINTAINER Maish Saidel-Keesing (maishsk@gmail.com)
RUN apk --update add --no-cache python py-pip openssl ca-certificates && \
    apk --update add --no-cache --virtual build-dependencies \
        python-dev \
        libffi-dev \
        openssl-dev \
        build-base && \
    pip install --upgrade boto boto3 ansible && \
    apk -v --purge del py-pip py-setuptools py2-pip && \
    apk -v --purge del ca-certificates build-dependencies && \
    apk -v --purge del pkgcon python2-dev libffi-dev zlib-dev && \
    apk -v --purge del openssl-dev binutils-libs binutils gmp && \
    apk -v --purge del isl libgomp libatomic libgcc mpfr3 mpc1 && \
    apk -v --purge del libstdc++ gcc musl-dev libc-dev g++ make && \
    apk -v --purge del fortify-headers build-base && \
    rm /var/cache/apk/*
