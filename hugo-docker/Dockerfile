FROM alpine

# install glibc compatibility for alpine
RUN apk --no-cache add binutils curl git && \
    GLIBC_VER=$(curl -s https://api.github.com/repos/sgerrand/alpine-pkg-glibc/releases/latest | grep tag_name | cut -d : -f 2,3 | tr -d \",' ') && \
    curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub && \
    curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk && \
    curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk && \
    apk add --no-cache glibc-${GLIBC_VER}.apk glibc-bin-${GLIBC_VER}.apk && \
    curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
    aws/install && \
    rm -rf awscliv2.zip aws /usr/local/aws-cli/v2/*/dist/aws_completer \
    /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
    /usr/local/aws-cli/v2/*/dist/awscli/examples && \
    wget https://github.com/gohugoio/hugo/releases/download/v0.80.0/hugo_0.80.0_Linux-64bit.tar.gz && \
    tar zxvf hugo_0.80.0_Linux-64bit.tar.gz && \
    mv hugo /usr/local/bin/ && \
    rm -rf LICENSE README.md hugo_0.80.0_Linux-64bit.tar.gz && \
    apk --no-cache del binutils && \ 
    rm glibc-${GLIBC_VER}.apk && \
    rm glibc-bin-${GLIBC_VER}.apk && \
    rm -rf /var/cache/apk/*