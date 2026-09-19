# Jenkins Installation steps
RHEL       : 9.7
Architecture: x86_64
Instance   : t3.small
Java       : Not installed
########Long Term Support release##########
sudo curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo
# Add required dependencies for the jenkins package
sudo yum install fontconfig java-21-openjdk -y
sudo yum install jenkins
sudo systemctl daemon-reload