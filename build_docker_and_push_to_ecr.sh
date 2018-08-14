#!/bin/bash

DEPLOY_ENV_FILENAME="aws_deploy_env.sh"

if [ ! -f $DEPLOY_ENV_FILENAME ]; then
    echo "$DEPLOY_ENV_FILENAME required"
    exit 1
else
    source $DEPLOY_ENV_FILENAME
fi

if [ ! $(which aws) ]; then
    echo "AWS CLI utilities not installed"
    exit 1
fi

if [ ! $(which docker) ]; then
    echo "Docker not installed"
    exit 1
fi

#login
$(aws ecr get-login --no-include-email --region $AWS_REGION)

#build
docker build -t $APP_NAME .

#tag
docker tag $DOCKER_TAG $ECR_REPOSITORY/$DOCKER_TAG

#push
docker push $ECR_REPOSITORY/$DOCKER_TAG

