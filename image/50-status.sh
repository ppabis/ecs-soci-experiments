#!/bin/sh

echo -n "return 200 \"" > /etc/nginx/status.conf
curl -X GET ${ECS_CONTAINER_METADATA_URI_V4}/task | sed 's/"/\\"/g' >> /etc/nginx/status.conf
echo -n "\";" >> /etc/nginx/status.conf

