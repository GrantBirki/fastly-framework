echo "\033[34;1m ########## Starting METRICS BUILD-AND-PUSH stage ##########\033[0;m"

cd code/logs/fastly-to-insights

# -------------- This whole block is for installing the AWS CLI in Alpine --------------
# Please feel free to use a better base Docker image than I did. All you need is the AWS
# CLI to continue with this script.

export GLIBC_VER=2.31-r0

apk --no-cache add \
        binutils \
        curl \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip -q awscliv2.zip \
    && aws/install \
    && rm -rf \
        awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples \
    && apk --no-cache del \
        binutils \
        curl \
    && rm glibc-${GLIBC_VER}.apk \
    && rm glibc-bin-${GLIBC_VER}.apk \
    && rm -rf /var/cache/apk/*

# -------------- END AWS CLI INSTALL BLOCK --------------

# Push Changes to GitLab Container Registry
docker login $CI_REGISTRY -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD
docker build . -t ${CI_REGISTRY_IMAGE}/fastly-to-insights:latest
docker images
docker push ${CI_REGISTRY_IMAGE}/fastly-to-insights:latest

# #### Setup AWS Creds Here ####
# Set your AWS creds here. I will not supply code for how to do this as it can be done in countless ways
# You can set access/secret keys from CICD variables, use a service like Vault, or another solution
# You will need to configure AWS to authenticate with ECR (AWS)

# Push Image to AWS ECR
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <accountID>.dkr.ecr.<region>.amazonaws.com
docker build -t fastly-to-insights .
docker tag fastly-to-insights:latest <accountID>.dkr.ecr.<region>.amazonaws.com/fastly-to-insights:latest
docker push <accountID>.dkr.ecr.<region>.amazonaws.com/fastly-to-insights:latest