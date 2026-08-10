#!/bin/bash
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z0580926234LLG39XOC6H" ## replace with zone id of your hosted zone
DOMAIN_NAME="azdevopsvenkat.site" ## replace with your domain name

for instance in $@
do
    echo "Creating EC2 instance for $instance"
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id ami-0220d79f3f480ecf5 \
        --instance-type t3.micro \
        --security-groups "roboshop-common","roboshop-$instance" \
        --count 1 \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value="roboshop-$instance"}]' \
        --query 'Instances[0].InstanceId' \
        --output text
  )
   echo "Instance ID for $instance is $INSTANCE_ID"
   if [ $instance == "frontend"];then
   IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress[]' --output text)
        R53_record=$($DOMAIN_NAME) ##if frontend instance then public ip address is used to create record in route53
   else 
    IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PrivateIpAddress[]' --output text)
         R53_record=$($instance.$DOMAIN_NAME) ## if other than frontend instance then private ip address is used to create record in route53
   fi
   ## Update the route53 record with the instance ip address
    aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --change-batch '{
            "Changes": [
                {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": "'$R53_record'",
                        "Type": "A",
                        "TTL": 1,
                        "ResourceRecords": [
                            {
                                "Value": "'$IP'"
                            }
                        ]
                    }
                }
            ]
        }'
done

