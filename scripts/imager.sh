#!/bin/bash
set -e

IFS=$'\n'

apt update -y
apt install awscli pbzip2 jq linux-aws amazon-ec2-utils pv -y



############################################################################################################
# Mount all disks
############################################################################################################
for disk in $(lsblk | grep disk | grep -v 'nvme0n1')
do
    device_name="$(echo $disk | awk '{print $1}')"
    # Create and compress image
    echo "[*] - $(date) - Create image for /dev/${device_name}"
    pv -p -E < /dev/${device_name} | pbzip2 -9 > ${device_name}.image.bz2
    echo "[+] - $(date) - Image created for /dev/${device_name}"

    # Copy image to S3
    echo "[*] - $(date) - Uploading image ${device_name}.image.bz2 to S3"
    volume_id=$(ebsnvme-id /dev/${device_name} | grep 'Volume ID' | awk '{print $3}')
    image_name=$(aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) --region us-east-2 | jq --arg jq_volume_id $volume_id '.Volumes[] | select(.VolumeId==$jq_volume_id) | .Tags[] | select(.Key=="Description").Value' -r | tr ' ' '-')
    tags=$(aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) --region us-east-2 | jq --arg jq_volume_id $volume_id '.Volumes[] | select(.VolumeId==$jq_volume_id).Tags' -r | sed -E 's/(^ *)"([^"]*)":/\1\2:/' | sed -e 's#Key: #Key=#g' | sed -e 's#Value: #Value=#g')

    aws s3 cp ${device_name}.image.bz2 s3://defcon-2022-obsidian-bq2am/forensics/disk_images/${image_name}.image.bz2
    # Best effort try to apply tags to new image.
    # However, some tags and not properly formatted
    # and will create issues.
    aws s3api put-object-tagging --bucket defcon-2022-obsidian-bq2am --tagging "TagSet=${tags}" --key forensics/disk_images/${image_name}.image.bz2 || true
    echo "[+] - $(date) - Upload complete"

    # Delete image
    echo "[*] - $(date) - Deleting image"
    rm ${device_name}.image.bz2
done


############################################################################################################
#                                           TERMINATE INSTANCE                                             #
############################################################################################################
sudo shutdown -h now
