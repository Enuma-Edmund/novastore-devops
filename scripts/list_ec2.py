import boto3

REGION = "us-east-2"

ec2 = boto3.client("ec2", region_name=REGION)

response = ec2.describe_instances()

print(f"EC2 instances in {REGION}:")
print("-" * 60)

count = 0

for reservation in response["Reservations"]:
    for instance in reservation["Instances"]:
        count += 1

        name = "No Name"
        for tag in instance.get("Tags", []):
            if tag["Key"] == "Name":
                name = tag["Value"]

        print(
            f"Name: {name} | "
            f"ID: {instance['InstanceId']} | "
            f"State: {instance['State']['Name']} | "
            f"Type: {instance['InstanceType']}"
        )

print("-" * 60)
print(f"Total instances found: {count}")
