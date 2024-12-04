#!/bin/bash

# You can alternatively use $(terraform output -raw) but this is easier to read
source infrastructure/outputs.env

ECR_REGION=$(echo $ECR_REPO_URL | cut -d '.' -f 4)

TAG=$(date "+%y%m%d%H%M")

# if the movie does not exist, download it
if [ ! -f "image/big_buck_bunny_1080p_h264.mov" ]; then
    wget https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_1080p_h264.mov -O image/big_buck_bunny_1080p_h264.mov
fi

aws ecr get-login-password --region $ECR_REGION | docker login --username AWS --password-stdin $ECR_REPO_URL
docker build -f image/Dockerfile.v1 -t $ECR_REPO_URL:$TAG image
docker push $ECR_REPO_URL:$TAG

echo "Pushed $ECR_REPO_URL:$TAG"

echo "$TAG" > infrastructure/tag.txt