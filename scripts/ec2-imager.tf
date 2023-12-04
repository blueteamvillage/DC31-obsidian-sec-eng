provider "aws" {
  region = "us-east-2"
}

terraform {
  required_version = ">= 1.3.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.29.0"
    }
  }
}



data "aws_ebs_snapshot_ids" "project_snapshot_ids" {
  filter {
    name   = "tag:Project"
    values = ["DEFCON_2023_OBSIDIAN"]
  }
  # filter {
  #   name   = "tag:ec2-imager"
  #   values = ["True"]
  # }
}

locals {
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html#available-ec2-device-names
  # EC2 only allows for 31 drives to be mounted per instance
  # and "/dev/sda1" is taken by root
  max_mounts         = 31
  ec2_instance_count = ceil(length(toset(data.aws_ebs_snapshot_ids.project_snapshot_ids.ids)) / local.max_mounts)
  s3_bucket          = "defcon-2023-obsidian-zkx4p"
}


data "aws_ebs_snapshot" "project_snapshots" {
  for_each     = toset(data.aws_ebs_snapshot_ids.project_snapshot_ids.ids)
  snapshot_ids = [each.value]
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "this" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  description       = "Allow SSH"
  from_port         = 22
  to_port           = 22
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "win_client_allow_outbound" {
  type              = "egress"
  description       = "Allow outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}


resource "aws_iam_role" "ec2_imager_instance_role" {
  name = "ec2-imager-instance-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })

  tags = {
    Tool = "ec2-imager"
    Team = "seceng"
  }
}

resource "aws_iam_instance_profile" "ec2_imager_instance_profile" {
  name = "ec2-imager-instance-profile"
  role = aws_iam_role.ec2_imager_instance_role.name
  tags = {
    Tool = "ec2-imager"
    Team = "seceng"
  }
}

resource "aws_iam_role_policy" "ec2_imager_role_policy" {
  name = "ec2-imager-role-policy"
  role = aws_iam_role.ec2_imager_instance_role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "ec2:DescribeVolumes",
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "s3:List*",
          "s3:PutObject",
          "s3:PutObjectTagging",
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:s3:::${local.s3_bucket}/*"
      },
      {
        "Action" : [
          "s3:List*"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:s3:::${local.s3_bucket}"
      }
    ]
  })

}


resource "aws_instance" "ec2" {
  count             = local.ec2_instance_count
  ami               = "ami-0e83be366243f524a"
  instance_type     = "t3.2xlarge"
  key_name          = "bbornholm"
  availability_zone = "us-east-2b"

  iam_instance_profile = aws_iam_instance_profile.ec2_imager_instance_profile.name

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_type           = "gp3" # Faster SSD
    volume_size           = 300
  }


  vpc_security_group_ids = [aws_security_group.this.id]

  tags = {
    Name = "ec2-imager-tool-${count.index}"
    Tool = "ec2-imager"
    Team = "seceng"
  }
}


resource "aws_ebs_volume" "snapshot_to_volume" {
  for_each = data.aws_ebs_snapshot.project_snapshots

  snapshot_id       = each.value.snapshot_id
  availability_zone = "us-east-2b"
  encrypted         = false
  type              = "gp3" # Faster SSD
  iops              = 10000

  tags = {
    Name             = each.value.description
    Project          = "DEFCON_2023_OBSIDIAN"
    Tool             = "ec2-imager"
    Description      = each.value.description
    OriginalVolumeId = each.value.volume_id
    SnapshotId       = each.value.snapshot_id
  }
}

locals {
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html
  # EC2 only allows for 31 drives to be mounted per instance
  # and "/dev/sda1" is taken by root
  #
  # [ f"/dev/xvd{a:b}{a:z}" for c in string.ascii_lowercase]
  volume_names = [
    "/dev/xvdab",
    "/dev/xvdac",
    "/dev/xvdad",
    "/dev/xvdae",
    "/dev/xvdaf",
    "/dev/xvdag",
    "/dev/xvdah",
    "/dev/xvdai",
    "/dev/xvdaj",
    "/dev/xvdak",
    "/dev/xvdal",
    "/dev/xvdam",
    "/dev/xvdan",
    "/dev/xvdao",
    "/dev/xvdap",
    "/dev/xvdaq",
    "/dev/xvdar",
    "/dev/xvdas",
    "/dev/xvdat",
    "/dev/xvdau",
    "/dev/xvdav",
    "/dev/xvdaw",
    "/dev/xvdax",
    "/dev/xvday",
    "/dev/xvdaz",
    "/dev/xvdba",
    "/dev/xvdbb",
    "/dev/xvdbc",
    "/dev/xvdbd",
    "/dev/xvdbe",
    "/dev/xvdbf",
  ]
}

resource "aws_volume_attachment" "ebs_att" {
  ##############################################################################
  # DO NOT TOUCH
  # DO NOT TOUCH
  # DO NOT TOUCH
  #
  # This function does some cool mapping using the modulis operator. TL;DR modulis
  # is used to perform a round-robbin approach of mount a volume to one instance
  # with just a single for loop.
  #
  # DO NOT TOUCH
  # DO NOT TOUCH
  # DO NOT TOUCH
  ##############################################################################
  for_each = { for idx, volume in keys(aws_ebs_volume.snapshot_to_volume) :
    idx => {
      volume_id = aws_ebs_volume.snapshot_to_volume[volume].id
    }
  }

  device_name = local.volume_names[tonumber(each.key) % local.max_mounts]
  instance_id = aws_instance.ec2[tonumber(each.key) % local.ec2_instance_count].id
  volume_id   = each.value.volume_id
}
