# Jenkins Installation on RHEL 9.7

## Environment

| Item | Value |
|---|---|
| Operating System | Red Hat Enterprise Linux 9.7 |
| Architecture | x86_64 |
| EC2 Instance | t3.small |
| Java | OpenJDK 21 LTS |
| Jenkins | Jenkins LTS |
| Jenkins Port | 8080 |

---

## Jenkins Installation

| Step | Purpose | Command |

| 2 | Install Java 21 and required dependency | `sudo dnf install -y fontconfig java-21-openjdk` |
| 3 | Verify Java version | `java -version` |
| 4 | Verify Java binary location | `which java` |
| 5 | Download Jenkins LTS repository | `sudo curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo` |
| 6 | Import Jenkins repository signing key | `sudo rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key` |
| 7 | Verify Jenkins repository | `dnf repolist | grep -i jenkins` |
| 8 | Install Jenkins | `sudo dnf install -y jenkins` |
| 9 | Reload systemd configuration | `sudo systemctl daemon-reload` |
| 10 | Enable Jenkins at boot | `sudo systemctl enable jenkins` |
| 11 | Start Jenkins | `sudo systemctl start jenkins` |
| 12 | Enable and start Jenkins together | `sudo systemctl enable --now jenkins` |
| 13 | Check Jenkins service status | `sudo systemctl status jenkins` |
| 14 | Check Jenkins listening port | `sudo ss -lntp | grep 8080` |
| 15 | Configure RHEL firewall | `sudo firewall-cmd --permanent --add-port=8080/tcp` |
| 16 | Reload RHEL firewall | `sudo firewall-cmd --reload` |
| 17 | Verify firewall port | `sudo firewall-cmd --list-ports` |
| 18 | Get Jenkins initial password | `sudo cat /var/lib/jenkins/secrets/initialAdminPassword` |

---

## Java Verification

```bash
java -version

## Jenkins input fields
| Jenkins field  | Value                                                  |
| -------------- | ------------------------------------------------------ |
| Definition     | Pipeline script from SCM                               |
| SCM            | Git                                                    |
| Repository URL | `git@github.com:pandalapadu/my-AWS-DevOps-Project.git` |
| Branch         | `*/main`                                               |
| Script Path    | `8-Jenkins/Jenkinsfile`                                |

## increse volume size 
step 1: sudo growpart /dev/nvme0n1 4
    this means Expand partition 4 to use the remaining available space on the 50G disk.
Step 2: sudo lvextend -r -L +10G /dev/RootVG/varVol
        sudo lvextend -r -L +10G /dev/mapper/RootVG-homeVol
        sudo lvextend -r -L +10G /dev/mapper/RootVG-rootVol
    What it does
    lvextend → increases the logical volume size
    -r → automatically resizes the filesystem too
    -L +10G → adds 10 GB to the existing size
    /dev/RootVG/VarVol → your /var logical volume
Step 3 :
    sudo xfs_growfs /var
    sudo xfs_growfs /home
    sudo xfs_growfs /

## Jenkins Webhook URL access
Webhooks -> we have to pass Jenkins server Public URL end with github-webhook/ Must and should
Payload URL   : http://100.53.185.232:8080/github-webhook/ 
Content type :: application/json
SSL verification : Disabled
Which events would you like to trigger this webhook: just select the Push the event 
## Jenkins Agents we have to install following 
1. Install Java 21 and required dependency | `sudo dnf install -y fontconfig java-21-openjdk` |
2. Node Js 
     sudo dnf module disable nodejs -y    # disabled default version
     sudo dnf module enable nodejs:20 -y   # enable 20 version
     sudo dnf install nodejs -y          # installing NodeJs version 
3. NPM installation 
    sudo dnf install npm -y
4. Docker Installation 
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
after docker installation in to vm we have to disconnect from jenkins and reconnect it .

#### Credentials for Jenkins 
1. ssh key based for authenticating our VM 
2. AWS acces key and secret key for Authenticateing AWS by downloding plugins

## Plugins we downloaded
1. Pipeline Stage View Plugin. ---> to view the multiple stages in pipeline
2. Pipeline Utility Steps ---> to read file content
3. AWS Credentials   --> for storing AWS credentials 
4. Pipeline: AWS Steps  (1.45)    -----> this will call jenkins to AWS API server 
5. sonarqube scanner (2.18.3)  --> plugin to push to server

## tolls used in jenkins
# Scans 
1. [sonarscan tool used ]static source code analysis  --> following coding standards or not
2. [sonarscan tool used ]static application security testing --> if there any security loop holes are there in the code
3. dependency scanning  -----------> librarery are used correct or not 
4. docker image scanning ----------. if we are used open source image if we have any vulnaribility 
5. dynamic application security testing ----> if any 3rd persion attack on live application 

# sonarqube server installation is tough process so we are using existing sonar AMI from MARKET places
under AWS market place AMI Select this --> SonarQube CE on AWS - Tuned, CloudWatch & SSM Ready 
                    Ver SonarQube:26.6.0.123539, Ubuntu:24.04, Build:20260612 (Select this)
Image ID : ami-0f31bd7e406ed0351  (for this AMi)
Name : SolveDevOps-SonarQube-Server-Ubuntu24.04-20260612-938693e4-e3336ad7-93a2-4e7c-8ed8-227cfbf25da4