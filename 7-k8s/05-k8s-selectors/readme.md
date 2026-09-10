Welcome to my DevOps project.
# Roboshop Project
for Creation of tags 1A--> kubectl label node ip-192-168-19-57.ec2.internal project=roboshop
for Deletion of tag --> kubectl label node ip-192-168-19-57.ec2.internal project-
for Taint nodes if we pass NoSchedule  (No upcomming pods scheduled on this node) 
        -> kubectl taint node ip-192-168-19-57.ec2.internal hardware=gpu:NoSchedule 
for Taint nodes if we pass NoExecute  (already running pods on this node evicted) 
        -> kubectl taint node ip-192-168-19-57.ec2.internal project=roboshop:NoExecute


1A-> ip-192-168-19-57.ec2.internal   192.168.19.57    <none>   7m1s   v1.34.10-eks-cb19647 
1C-> ip-192-168-38-70.ec2.internal   192.168.38.70    <none>   7m1s   v1.34.10-eks-cb19647

here is the Labels are attached for each Node : by executing command as : kubectl get nodes --show-labels
    alpha.eksctl.io/cluster-name=roboshop,
    alpha.eksctl.io/nodegroup-name=managed,
    beta.kubernetes.io/arch=amd64,
    beta.kubernetes.io/instance-type=t3.small,
    beta.kubernetes.io/os=linux,
    eks.amazonaws.com/capacityType=SPOT,
    eks.amazonaws.com/nodegroup-image=ami-0d03b1fae3e52a3bb,
    eks.amazonaws.com/nodegroup=managed,
    eks.amazonaws.com/sourceLaunchTemplateId=lt-02b940047af666f83,
    eks.amazonaws.com/sourceLaunchTemplateVersion=1,
    failure-domain.beta.kubernetes.io/region=us-east-1,
    failure-domain.beta.kubernetes.io/zone=us-east-1a,
    k8s.io/cloud-provider-aws=d573a2d478e01899d878f9c9cc3fcc2a,
    kubernetes.io/arch=amd64,
    kubernetes.io/hostname=ip-192-168-19-57.ec2.internal,
    kubernetes.io/os=linux,
    node.kubernetes.io/instance-type=t3.small,
    topology.k8s.aws/zone-id=use1-az1,
    topology.kubernetes.io/region=us-east-1,
    topology.kubernetes.io/zone=us-east-1a
