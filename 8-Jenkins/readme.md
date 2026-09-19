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
| 7 | Verify Jenkins repository | `dnf repolist \| grep -i jenkins` |
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