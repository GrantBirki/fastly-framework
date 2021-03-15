FROM alpine:3.12

ARG TF_VER=0.14.8

# Update and add curl
RUN apk update
RUN apk add curl
RUN apk add --no-cache --upgrade grep

# Install Terraform - Pinned version
RUN curl "https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_amd64.zip" -o "tf_${TF_VER}.zip"
RUN unzip tf_${TF_VER}.zip && mv terraform /usr/local/bin/terraform

# Install the AWS CLI and Python3
RUN apk add --no-cache \
        python3 \
        py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install \
        awscli \
    && rm -rf /var/cache/apk/*

# For tightened security we use a nonroot user
RUN adduser -D nonroot
WORKDIR /home/nonroot/
USER nonroot
