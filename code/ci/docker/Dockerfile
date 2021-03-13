FROM hashicorp/terraform:latest

WORKDIR /home/nonroot/
USER root

# Install the AWS CLI
RUN apt-get update
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# Install CURL
RUN apt-get install curl -y

# Install Python
RUN apt-get install -y python3-minimal
RUN apt-get install python3-pip -y

USER nonroot

RUN terraform -v
