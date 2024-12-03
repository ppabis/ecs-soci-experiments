#!/bin/sh

# Create hashes directory
mkdir -p /tmp/hashes

# Process each file in the nginx html directory
for file in /usr/share/nginx/html/*; do
    if [ -f "$file" ]; then
        # Generate hashes and save to a file named after the original file
        filename=$(basename "$file")
        hasher "$file" >> "/tmp/hashes.txt"
        echo "Generated hashes for $filename"
        echo "" >> "/tmp/hashes.txt"
    fi
done

# Get the container ARN "TaskARN":"arn:aws:ecs:eu-west-2:123456789012:task/demo-cluster/0123abcd0123abcd0123abcd"
curl -X GET ${ECS_CONTAINER_METADATA_URI_V4}/task | grep -oE "TaskARN\":\"arn:aws:ecs:${AWS_DEFAULT_REGION}:[0-9]+:task/[a-z0-9\\-]+/[a-z0-9]+" | cut -d':' -f 2- | tr -d '"' >> "/tmp/hashes.txt"
echo -n " Finished at " >> "/tmp/hashes.txt"
date >> "/tmp/hashes.txt"
echo "" >> "/tmp/hashes.txt"

# Move the hash files to nginx html directory
mv /tmp/hashes.txt /usr/share/nginx/html/

# Clean up
rmdir /tmp/hashes 