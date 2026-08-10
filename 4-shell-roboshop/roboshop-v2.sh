#!/bin/bash

# --------------------------------------------------
# Configuration
# --------------------------------------------------
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z0580926234LLG39XOC6H"
DOMAIN_NAME="azdevopsvenkat.site"
LOGS_FOLDER="/var/log/roboshop"
# sudo may reset PATH, so explicitly include common AWS CLI locations
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
# --------------------------------------------------
# Logging setup
# --------------------------------------------------
sudo mkdir -p "$LOGS_FOLDER"
sudo chmod 755 "$LOGS_FOLDER"
LOGS_FILE="$LOGS_FOLDER/$(basename "$0").log"
# --------------------------------------------------
# Colors
# --------------------------------------------------
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
# --------------------------------------------------
# Check AWS CLI
# --------------------------------------------------
if ! command -v aws >/dev/null 2>&1; then
    echo -e "$TIMESTAMP [ERROR] ${R}AWS CLI not found in PATH${N}" | tee -a "$LOGS_FILE"
    echo "PATH=$PATH" | tee -a "$LOGS_FILE"
    exit 1
fi
echo -e "$TIMESTAMP [INFO] ${G}AWS CLI found: $(command -v aws)${N}" | tee -a "$LOGS_FILE"
# --------------------------------------------------
# Validate input arguments
# --------------------------------------------------
if [ "$#" -lt 2 ]; then

    echo -e "$TIMESTAMP [ERROR] ${R}At least 2 arguments are required${N}" | tee -a "$LOGS_FILE"

    echo "USAGE: $0 [create/delete] [instance1] [instance2] ..." | tee -a "$LOGS_FILE"

    exit 1
fi
# --------------------------------------------------
# Get action
# --------------------------------------------------
ACTION="$1"

shift

if [ "$ACTION" != "create" ] && [ "$ACTION" != "delete" ]; then
    echo -e "$TIMESTAMP [ERROR] ${R}First argument must be either create or delete${N}" | tee -a "$LOGS_FILE"
    echo "USAGE: $0 [create/delete] [instance1] [instance2] ..." | tee -a "$LOGS_FILE"
    exit 1
fi
# --------------------------------------------------
# Function: Get running instance ID
# --------------------------------------------------
get_instance_id() {
    local name="$1"
    aws ec2 describe-instances \
        --filters \
        "Name=tag:Name,Values=roboshop-$name" \
        "Name=instance-state-name,Values=running" \
        --query "Reservations[0].Instances[0].InstanceId" \
        --output text
        }
# --------------------------------------------------
# Process instances
# --------------------------------------------------
for instance in "$@"
do
    echo "----------------------------------------" | tee -a "$LOGS_FILE"
    echo -e "$TIMESTAMP [INFO] Processing: $instance" | tee -a "$LOGS_FILE"
    # --------------------------------------------------
    # Get existing running instance
    # --------------------------------------------------
    INSTANCE_ID=$(get_instance_id "$instance")
    # ==================================================
    # CREATE
    # ==================================================
    if [ "$ACTION" == "create" ]; then
        # ----------------------------------------------
        # Instance does not exist
        # ----------------------------------------------
        if [ "$INSTANCE_ID" == "None" ] || [ -z "$INSTANCE_ID" ]; then
            echo -e "$TIMESTAMP [INFO] ${G}Launching Instance: roboshop-$instance${N}" | tee -a "$LOGS_FILE"
            INSTANCE_ID=$(aws ec2 run-instances \
                --image-id "$AMI_ID" \
                --instance-type t3.micro \
                --security-groups "roboshop-common" "roboshop-$instance" \
                --count 1 \
                --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
                --query 'Instances[0].InstanceId' \
                --output text
            )
            # ------------------------------------------
            # Check EC2 creation
            # ------------------------------------------
            if [ "$INSTANCE_ID" == "None" ] || [ -z "$INSTANCE_ID" ]; then
                echo -e "$TIMESTAMP [ERROR] ${R}Failed to create EC2 instance for $instance${N}" | tee -a "$LOGS_FILE"
                exit 1
            fi
            echo -e "$TIMESTAMP [INFO] ${G}Launched Instance: $INSTANCE_ID${N}" | tee -a "$LOGS_FILE"
            # ------------------------------------------
            # Wait until instance is running
            # ------------------------------------------
            echo -e "$TIMESTAMP [INFO] Waiting for instance to become running..." | tee -a "$LOGS_FILE"
            aws ec2 wait instance-running \
                --instance-ids "$INSTANCE_ID"
            echo -e "$TIMESTAMP [INFO] ${G}Instance is running: $INSTANCE_ID${N}" | tee -a "$LOGS_FILE"
        else
            echo -e "$TIMESTAMP [INFO] ${Y}roboshop-$instance already running: $INSTANCE_ID${N}" | tee -a "$LOGS_FILE"
        fi
        # ----------------------------------------------
        # Get IP address
        # ----------------------------------------------
        if [ "$instance" == "frontend" ]; then
            IP=$(aws ec2 describe-instances \
                --instance-ids "$INSTANCE_ID" \
                --query 'Reservations[0].Instances[0].PublicIpAddress' \
                --output text
            )
            R53_RECORD="$DOMAIN_NAME"
        else
            IP=$(aws ec2 describe-instances \
                --instance-ids "$INSTANCE_ID" \
                --query 'Reservations[0].Instances[0].PrivateIpAddress' \
                --output text
            )
            R53_RECORD="$instance.$DOMAIN_NAME"
        fi
        # ----------------------------------------------
        # Validate IP
        # ----------------------------------------------
        if [ -z "$IP" ] || [ "$IP" == "None" ]; then
            echo -e "$TIMESTAMP [ERROR] ${R}Unable to get IP address for $instance${N}" | tee -a "$LOGS_FILE"
            exit 1
        fi
        echo -e "$TIMESTAMP [INFO] IP Address: $IP" | tee -a "$LOGS_FILE"
        echo -e "$TIMESTAMP [INFO] Route53 Record: $R53_RECORD" | tee -a "$LOGS_FILE"
        # ----------------------------------------------
        # Update Route53
        # ----------------------------------------------
        aws route53 change-resource-record-sets \
            --hosted-zone-id "$ZONE_ID" \
            --change-batch '{
                "Comment": "Update RoboShop DNS record",
                "Changes": [
                    {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                            "Name": "'"$R53_RECORD"'",
                            "Type": "A",
                            "TTL": 60,
                            "ResourceRecords": [
                                {
                                    "Value": "'"$IP"'"
                                }
                            ]
                        }
                    }
                ]
            }'
        if [ "$?" -eq 0 ]; then
            echo -e "$TIMESTAMP [INFO] ${G}Updated Route53 record: $R53_RECORD -> $IP${N}" | tee -a "$LOGS_FILE"
        else
            echo -e "$TIMESTAMP [ERROR] ${R}Failed to update Route53 record${N}" | tee -a "$LOGS_FILE"
            exit 1
        fi
    # ==================================================
    # DELETE
    # ==================================================
    else
        if [ "$INSTANCE_ID" == "None" ] || [ -z "$INSTANCE_ID" ]; then
            echo -e "$TIMESTAMP [INFO] ${Y}$instance is already destroyed, nothing to do${N}" | tee -a "$LOGS_FILE"
        else
            echo -e "$TIMESTAMP [INFO] Terminating Instance: $INSTANCE_ID" | tee -a "$LOGS_FILE"
            aws ec2 terminate-instances \
                --instance-ids "$INSTANCE_ID"
            if [ "$?" -eq 0 ]; then
                echo -e "$TIMESTAMP [INFO] ${G}Terminating Instance: $instance${N}" | tee -a "$LOGS_FILE"
            else
                echo -e "$TIMESTAMP [ERROR] ${R}Failed to terminate $instance${N}" | tee -a "$LOGS_FILE"
                exit 1
            fi
        fi
    fi
done