#!/bin/bash

# You can alternatively use $(terraform output -raw) but this is easier to read
source infrastructure/outputs.env

ECR_REGION=$(echo $ECR_REPO_URL | cut -d '.' -f 4)

TAG=$(date "+%y%m%d%H%M")

# download some files from huggingface to make image larger
HF_FILES=(\
 "https://huggingface.co/datasets/HuggingFaceTB/smoltalk/resolve/main/data/all/test-00000-of-00001.parquet" \
 "https://huggingface.co/datasets/HuggingFaceTB/smoltalk/resolve/main/data/all/train-00000-of-00009.parquet" \
 "https://huggingface.co/datasets/HuggingFaceTB/smoltalk/resolve/main/data/all/train-00001-of-00009.parquet" \
 "https://huggingface.co/datasets/HuggingFaceTB/smoltalk/resolve/main/data/all/train-00002-of-00009.parquet" \
)

for file in "${HF_FILES[@]}"; do
    if [ ! -f "image/${file##*/}" ]; then
        wget $file -O "image/${file##*/}"
    fi
done

aws ecr get-login-password --region $ECR_REGION | docker login --username AWS --password-stdin $ECR_REPO_URL
docker build -f image/Dockerfile.v2 -t $ECR_REPO_URL:$TAG image
docker push $ECR_REPO_URL:$TAG

echo "Pushed $ECR_REPO_URL:$TAG"

echo "$TAG" > infrastructure/tag.txt