# EC2-imager
The goal of this ephemeral infrastructure that can be spun up to create hard disk images from AWS EBS volumes.

At a high level, you tag all snapshots

1. `cd ../scripts/ec2-imager.tf`
1. Open `ec2-imager.tf` and modify:
    1. The filter `data.aws_ebs_snapshot_ids` to a relevant tag
    1. `locals.s3_bucket` to the bucket you want to write too
    1. `aws_instance.key_name` to a key you own in AWS
1. `terraform apply`
1. Open the AWS console and get the IP addresses of each EC2 instance
1. `scp imager.sh ubuntu@<ip addr>:~`
1. `ssh ubuntu@<ip addr>`
1. `sudo apt update -y && sudo apt install tmux -y`
1. `tmux`
1. `sudo su`
1. `chmod +x imager.sh`
1. `./imager.sh`

## References
* [Resource: aws_ebs_volume](https://registry.terraform.io/providers/hashicorp/aws/3.75.1/docs/resources/ebs_volume)
* [Amazon EBS volume types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html)
* [Resource: aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
* [How to Make Disk Images in Linux with DD Command](https://linuxhint.com/make-disk-images-dd-command-linux/)
* [Amazon EBS pricing](https://aws.amazon.com/ebs/pricing/)
* [How to make disk image with dd on Linux](https://dev.to/texe/how-to-make-disk-image-with-dd-on-linux-2fgg)
* [How do I determine the block size of an ext3 partition on Linux?](https://serverfault.com/questions/29887/how-do-i-determine-the-block-size-of-an-ext3-partition-on-linux)
* [Determine the size of a block device](https://unix.stackexchange.com/questions/52215/determine-the-size-of-a-block-device)
* [Using the find -exec Command Option](https://www.baeldung.com/linux/find-exec-command)
* [How to compare strings in Bash](https://byby.dev/bash-compare-strings#:~:text=Equality%20checks,of%20them%20are%20case%2Dsensitive.)
* [How To List Disks on Linux](https://devconnected.com/how-to-list-disks-on-linux/)
* [blkid(8) - Linux man page](https://linux.die.net/man/8/blkid)
* [Is there a way to retrieve UUID information of an unmounted hard drive?](https://unix.stackexchange.com/questions/638633/is-there-a-way-to-retrieve-uuid-information-of-an-unmounted-hard-drive)
* [How to List Unmounted partition of a harddisk and Mount them?](https://askubuntu.com/questions/626353/how-to-list-unmounted-partition-of-a-harddisk-and-mount-them)
* [tonumber Function](https://developer.hashicorp.com/terraform/language/functions/tonumber)
* [Access the index of a map in for_each](https://stackoverflow.com/questions/69100843/access-the-index-of-a-map-in-for-each)
* [Terraform get list index on for_each](https://devops.stackexchange.com/questions/11398/terraform-get-list-index-on-for-each)
* [Terraform tips & tricks: loops, if-statements, and gotchas](https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9)
* [Unknown values in for_each](https://discuss.hashicorp.com/t/unknown-values-in-for-each/51061/2)
* [Terraform get list index on for_each](https://devops.stackexchange.com/questions/11398/terraform-get-list-index-on-for-each)
* [Terraform: count, for_each, and for loops](https://itnext.io/terraform-count-for-each-and-for-loops-1018526c2047)
* [How to iterate multiple resources over the same list?](https://stackoverflow.com/questions/56137102/how-to-iterate-multiple-resources-over-the-same-list)
* [Attach EBS volumes to EC2 instances for each terraform](https://stackoverflow.com/questions/63510018/attach-ebs-volumes-to-ec2-instances-for-each-terraform)
* [Creating Multiple EBS Volumes, Multiple EC2 Instances and then doing multiple attachments to the correct Instances](https://www.reddit.com/r/Terraform/comments/oso3w9/creating_multiple_ebs_volumes_multiple_ec2/)
* [Resource: aws_volume_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment)
* [Terraform get list index on for_each](https://stackoverflow.com/questions/61343796/terraform-get-list-index-on-for-each)
* [Terraform 0.12 nested for loops](https://stackoverflow.com/questions/56047306/terraform-0-12-nested-for-loops)
* [Resource: aws_ebs_snapshot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_snapshot)
* [Terraform - creating multiple EBS volumes](https://stackoverflow.com/questions/56225212/terraform-creating-multiple-ebs-volumes)
* [Using Terraform to create multiple AWS EBS volumes from shared snapshot and tagging them with snapshot description](https://stackoverflow.com/questions/61219088/using-terraform-to-create-multiple-aws-ebs-volumes-from-shared-snapshot-and-tagg)
* [Terraform - Create Snapshot of EBS and then convert Snapshot to EBS and attach to an EC2](https://stackoverflow.com/questions/49488416/terraform-create-snapshot-of-ebs-and-then-convert-snapshot-to-ebs-and-attach-t)
* [Uploading Files to S3 using AWS CLI](https://stackoverflow.com/questions/60941353/uploading-files-to-s3-using-aws-cli)
* [Create EBS Volume Snapshot and Attached to Another EC2 Instance in AWS](https://www.ktexperts.com/create-ebs-volume-snapshot-and-attached-to-another-ec2-instance-in-aws/)
* [Instance volume limits](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/volume_limits.html)
* [How to make disk image with dd on Linux or Unix](https://www.cyberciti.biz/faq/unix-linux-dd-create-make-disk-image-commands/)
* [Performing Digital Forensics on an AWS EBS Volume](https://technology.customink.com/blog/2019/08/05/performing-digital-forensics-on-an-aws-ebs-volume/)
* [SANs: Digital Forensics Analysis of Amazon Linux EC2 Instances](https://sansorg.egnyte.com/dl/gU1lNk177L)
* [How to get alphabets in order through loop in Python? Is it possible of getting alphabets through looping condition.](https://www.sololearn.com/en/discuss/1947743/how-to-get-alphabets-in-order-through-loop-in-python-is-it-possible-of-getting-alphabets-through)
* [Available device names](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html)
* [How to Get Current Date and Time in Bash Script](https://tecadmin.net/get-current-date-and-time-in-bash/)
* [Guide to Passing Bash Variables to jq](https://www.baeldung.com/linux/jq-passing-bash-variables#:~:text=Using%20%24ENV%20or%20the%20env,variable%20or%20the%20env%20function.)
* [converting spaces into dashes](https://unix.stackexchange.com/questions/290242/converting-spaces-into-dashes)
* [User and role policy examples](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-policies-s3.html)
* [Resource: aws_iam_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy.html)
* [selecting an array element, based on subelement value -> jq: error: Cannot index array with string #370](https://github.com/jqlang/jq/issues/370)
* [how to get volume id attached to instance from AWS CLI](https://serverfault.com/questions/888199/how-to-get-volume-id-attached-to-instance-from-aws-cli)
* [Removing Quotation Marks from Keys: A Guide](https://copyprogramming.com/howto/jq-how-to-remove-quotes-from-keys)
* [How to tag all objects in a S3 bucket using AWS CLI?](https://www.learnaws.org/2022/08/22/tag-objects-s3/)
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()
