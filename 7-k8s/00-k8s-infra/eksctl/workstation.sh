################# Docker ################
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

####################### eksctl ###########################
# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

sudo curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
sudo tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl

###for checking version --> eksctl version
############### kubectl ##############
sudo curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.35.3/2026-04-08/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo cp kubectl /usr/local/bin/kubectl

##for checkingversion # kubectl version --client
####################### AWS Configure ################
###by default we have AWS CLI configure installed in all VM's
#aws configure  ### for configuring AWS security credentials 
###################################### Kube NS ##########
### for switching between namespaces in kubectl, install kubens (from kubectx project, pure bash version)
# kubens (from kubectx project, pure bash version)
sudo curl -sLo /tmp/kubens https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens
sudo install -m 0755 /tmp/kubens /usr/local/bin/kubens && rm /tmp/kubens
### to list all namespaces: kubens
#### to switch to a namespace: kubens <namespace> eg: kubens roboshop
###########kubernets 9s k9s installation ########
# k9s
curl -sLO https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
tar -xzf k9s_Linux_amd64.tar.gz -C /tmp k9s && rm k9s_Linux_amd64.tar.gz
install -m 0755 /tmp/k9s /usr/local/bin/k9s && rm /tmp/k9s
## for accessing k9s, run the command: k9s