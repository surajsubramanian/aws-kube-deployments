## Finding image names:
```
aws ec2 describe-images --region us-east-1  --owners amazon --filters "Name=name,Values=amzn2-ami-hvm*20221004*" "Name=root-device-type,Values=ebs" "Name=architecture,Values=x86_64" "Name=block-device-mapping.volume-type,Values=gp2"

{
    "Images": [
        {
            "Architecture": "x86_64",
            "CreationDate": "2022-10-13T21:02:22.000Z",
            "ImageId": "ami-0c4e4b4eb2e11d1d4",
            "ImageLocation": "amazon/amzn2-ami-hvm-2.0.20221004.0-x86_64-gp2",
            "ImageType": "machine",
            "Public": true,
            "OwnerId": "137112412989",
            "PlatformDetails": "Linux/UNIX",
            "UsageOperation": "RunInstances",
            "State": "available",
            "BlockDeviceMappings": [
                {
                    "DeviceName": "/dev/xvda",
                    "Ebs": {
                        "DeleteOnTermination": true,
                        "SnapshotId": "snap-079f0214a68e0b6db",
                        "VolumeSize": 8,
                        "VolumeType": "gp2",
                        "Encrypted": false
                    }
                }
            ],
            "Description": "Amazon Linux 2 AMI 2.0.20221004.0 x86_64 HVM gp2",
            "EnaSupport": true,
            "Hypervisor": "xen",
            "ImageOwnerAlias": "amazon",
            "Name": "amzn2-ami-hvm-2.0.20221004.0-x86_64-gp2",
            "RootDeviceName": "/dev/xvda",
            "RootDeviceType": "ebs",
            "SriovNetSupport": "simple",
            "VirtualizationType": "hvm",
            "DeprecationTime": "2024-10-13T21:02:22.000Z"
        }
    ]
}
```
```
% aws ec2 describe-images --filters "Name=description,Values=[Amazon Linux 2 AMI 2.0.20221004.0 x86_64 HVM gp2]"
{
    "Images": [
        {
            "Architecture": "x86_64",
            "CreationDate": "2022-10-13T21:02:22.000Z",
            "ImageId": "ami-0c4e4b4eb2e11d1d4",
            "ImageLocation": "amazon/amzn2-ami-hvm-2.0.20221004.0-x86_64-gp2",
            "ImageType": "machine",
            "Public": true,
            "OwnerId": "137112412989",
            "PlatformDetails": "Linux/UNIX",
            "UsageOperation": "RunInstances",
            "State": "available",
            "BlockDeviceMappings": [
                {
                    "DeviceName": "/dev/xvda",
                    "Ebs": {
                        "DeleteOnTermination": true,
                        "SnapshotId": "snap-079f0214a68e0b6db",
                        "VolumeSize": 8,
                        "VolumeType": "gp2",
                        "Encrypted": false
                    }
                }
            ],
            "Description": "Amazon Linux 2 AMI 2.0.20221004.0 x86_64 HVM gp2",
            "EnaSupport": true,
            "Hypervisor": "xen",
            "ImageOwnerAlias": "amazon",
            "Name": "amzn2-ami-hvm-2.0.20221004.0-x86_64-gp2",
            "RootDeviceName": "/dev/xvda",
            "RootDeviceType": "ebs",
            "SriovNetSupport": "simple",
            "VirtualizationType": "hvm",
            "DeprecationTime": "2024-10-13T21:02:22.000Z"
        }
    ]
}
```

## Documentation

[describe-images](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html)