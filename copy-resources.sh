#!/bin/bash

echo "Use this script only if you plan to use bastion host via SSM. Change the EXCHANGE_BUCKET variable to your own bucket."

EXCHANGE_BUCKET="491c-8c9f-b545bbd4c877"

tar --exclude "image/*.mov" -czf "bastion.tar.gz" image/ infrastructure/outputs.env *.sh
aws s3 cp bastion.tar.gz s3://${EXCHANGE_BUCKET}/bastion.tar.gz