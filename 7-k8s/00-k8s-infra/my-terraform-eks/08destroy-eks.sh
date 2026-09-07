# --------------------------------------------------
# 13. Create EKS destroy script
# --------------------------------------------------

echo "Creating EKS destroy script..."

cat > /home/ec2-user/destroy-eks.sh <<'EOF'
#!/bin/bash

set -e

REGION="us-east-1"
CLUSTER_NAME="roboshop"
EKS_CONFIG="/home/ec2-user/eksctl/eksctl.yaml"

echo "=============================================="
echo " Roboshop EKS Cluster Destruction"
echo "=============================================="

echo ""
echo "Checking AWS identity..."
aws sts get-caller-identity

echo ""
echo "Checking EKS cluster..."

if aws eks describe-cluster \
    --region "$REGION" \
    --name "$CLUSTER_NAME" \
    >/dev/null 2>&1
then

    echo "EKS cluster $CLUSTER_NAME exists."

    echo ""
    echo "Starting EKS cluster deletion..."

    eksctl delete cluster \
        -f "$EKS_CONFIG" \
        --wait

    echo ""
    echo "EKS cluster deletion completed."

else

    echo "EKS cluster $CLUSTER_NAME does not exist."

fi

echo ""
echo "=============================================="
echo " EKS destruction completed"
echo "=============================================="
EOF

chmod +x /home/ec2-user/destroy-eks.sh

chown ec2-user:ec2-user /home/ec2-user/destroy-eks.sh

echo "Destroy script created:"
ls -l /home/ec2-user/destroy-eks.sh