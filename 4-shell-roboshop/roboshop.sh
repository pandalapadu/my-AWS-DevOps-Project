#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z0580926234LLG39XOC6H"
DOMAIN_NAME="azdevopsvenkat.site"
## we have to pass like sh roboshop.sh frontend backend database ... etc 
for instance in "$@"
do

    echo "Creating EC2 instance for $instance"

    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type t3.micro \
        --security-groups "roboshop-common" "roboshop-$instance" \
        --count 1 \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text
    )

    echo "Instance ID for $instance is $INSTANCE_ID"

    if [ "$INSTANCE_ID" == "None" ] || [ -z "$INSTANCE_ID" ]; then
        echo "ERROR: EC2 instance creation failed for $instance"
        exit 1
    fi

    if [ "$instance" == "frontend" ]; then

        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)

        R53_record="$DOMAIN_NAME"

    else

        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)

        R53_record="$instance.$DOMAIN_NAME"

    fi

    echo "Instance IP: $IP"
    echo "Route53 record: $R53_record"

    echo "Updating Route53 record..."

    aws route53 change-resource-record-sets \
        --hosted-zone-id "$ZONE_ID" \
        --change-batch '{
            "Changes": [
                {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": "'"$R53_record"'",
                        "Type": "A",
                        "TTL": 1,
                        "ResourceRecords": [
                            {
                                "Value": "'"$IP"'"
                            }
                        ]
                    }
                }
            ]
        }'

    echo "Route53 record updated successfully for $instance"

done