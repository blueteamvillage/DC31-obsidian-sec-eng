from typing import List
import argparse
import boto3


def get_volume_id(session: boto3.Session, instance_id: str) -> str:
    ec2_resource = session.client("ec2")
    volumes = ec2_resource.describe_instance_attribute(
        InstanceId=instance_id, Attribute="blockDeviceMapping"
    )
    return volumes["BlockDeviceMappings"][0]["Ebs"]["VolumeId"]


def get_ec2_instance_name(session: boto3.Session, instance_id: str) -> str:
    ec2_resource = session.client("ec2")
    instance_details = ec2_resource.describe_instances(InstanceIds=[instance_id])
    for tag in instance_details["Reservations"][0]["Instances"][0]["Tags"]:
        if tag["Key"] == "Name":
            return tag["Value"]


def create_snapshot(
    session: boto3.Session,
    project_tag: str,
    volume_id: str,
    snapshot_name: str,
    instance_id: str,
    dryrun: bool,
) -> None:
    ec2_resource = session.client("ec2")
    instance_name = get_ec2_instance_name(session, instance_id)
    try:
        snapshot_response = ec2_resource.create_snapshot(
            VolumeId=volume_id,
            Description=f"{project_tag}_{snapshot_name} for {instance_name}:{instance_id} for {volume_id}",  # pylint: line-too-long noqa: E501
            DryRun=dryrun,
            TagSpecifications=[
                {
                    "ResourceType": "snapshot",
                    "Tags": [
                        {
                            "Key": "Name",
                            # pylint: line-too-long
                            "Value": f"{project_tag}_{instance_name.removeprefix(project_tag + '_')}_{snapshot_name}",  # noqa: E501
                        },
                        {"Key": "Project", "Value": project_tag},
                        {"Key": "SnapshotName", "Value": snapshot_name},
                        {"Key": "InstanceID", "Value": instance_id},
                        {"Key": "InstanceName", "Value": instance_name},
                    ],
                },
            ],
        )
        # response is a dictionary containing ResponseMetadata and SnapshotId
        status_code = snapshot_response["ResponseMetadata"]["HTTPStatusCode"]
        snapshot_id = snapshot_response["SnapshotId"]
        # check if status_code was 200 or not to ensure the
        # snapshot was created successfully
        if status_code == 200:
            print(
                f"[+] - Successful snapshot created for volume ID: {volume_id} for instance ID: {instance_id} -> Snapshot ID: {snapshot_id}"  # noqa: E501 # pylint: line-too-long
            )
    except Exception as e:
        print(e)
        # exception_message = f"There was error in creating snapshot {snapshot_response['SnapshotId']} with volume id {volume_id} and error is: \n"\ # noqa: E501
        #                    + str(e)


def get_project_ec2_instances(session, project_tag: str) -> List[str]:
    ec2_resource = session.client("ec2")
    custom_filter = [{"Name": "tag:Project", "Values": [project_tag]}]

    project_ec2_instances: List[str] = []
    for reservation in ec2_resource.describe_instances(Filters=custom_filter)[
        "Reservations"
    ]:
        for instance in reservation["Instances"]:
            project_ec2_instances.append(instance["InstanceId"])
            for tag in instance["Tags"]:
                if tag["Key"] == "Name":
                    print(instance["InstanceId"] + ": " + tag["Value"])
    return project_ec2_instances


if __name__ == "__main__":
    my_parser = argparse.ArgumentParser(description="List the content of a folder")
    my_parser.add_argument(
        "--profile", type=str, default="default", help="Define an AWS prfoile to use"
    )
    my_parser.add_argument(
        "--region", type=str, default="us-east-2", help="Define an AWS region"
    )
    my_parser.add_argument(
        "--project_tag", type=str, required=True, help="Define an AWS tag for project"
    )
    my_parser.add_argument(
        "--snapshot_name", type=str, required=True, help="Define an AWS snapshot name"
    )
    my_parser.add_argument(
        "--dryrun",
        type=bool,
        default=False,
        required=False,
        help="Define if create snapshot shoould be a dryrun - default false",
    )
    args = my_parser.parse_args()

    # Create boto3 session
    session = boto3.Session(profile_name=args.profile)

    project_ec2_instances = get_project_ec2_instances(session, args.project_tag)
    for instance_id in project_ec2_instances:
        vol_id = get_volume_id(session, instance_id)
        create_snapshot(
            session,
            args.project_tag,
            vol_id,
            args.snapshot_name,
            instance_id,
            args.dryrun,
        )
