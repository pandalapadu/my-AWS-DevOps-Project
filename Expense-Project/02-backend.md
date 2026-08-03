# Backend

The backend service is responsible for handling API requests and persisting data to the database. It is written in Node.js.

> **Check with the developer for the exact version required. This setup requires Node.js >= 20.**

---

## Install Node.js

By default, Node.js 16 is available on the system. Enable and install version 20:

```bash
dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y
```

Verify:

```bash
node -v
```

---

## Set Up Application Directory

```bash
mkdir /app
```

---

## Create Application User

Add a system user to run the application:

```bash
useradd --system --home /app --shell /sbin/nologin --comment "expense system user" expense
```

**Why a system user?**

System users (UID 1–999) are created exclusively to run services — not for human login. Compared to normal users they provide:

- **No login access** — `/sbin/nologin` shell blocks any interactive login, reducing attack surface.
- **No password** — cannot be brute-forced via SSH.
- **Least privilege** — only owns the files it needs; a compromised service can't touch the rest of the system.
- **Process accountability** — `ps aux` clearly shows `expense` owns the backend process, making auditing easy.

Normal users start at UID 1000. You can verify this user was created as a system user:

```bash
id expense
grep expense /etc/passwd
```
---

## Download and Extract Application

```bash
curl -o /tmp/backend.tar.gz https://raw.githubusercontent.com/daws-90s/expense-documentation/refs/heads/main/artifacts/expense-backend-v3.tar.gz
```

Extract files directly into `/app` (no subfolder):

```bash
cd /app
tar -xzf /tmp/backend.tar.gz --strip-components=1
```

---

## Install Dependencies

```bash
cd /app
npm install
```

---
## We have to install mysql DB client software to connect our mySQL DB for executing Schema ##
```bash
dnf install mysql -y
```
> **Replace `<MYSQL-SERVER-IPADDRESS>` with the private IP of the MySQL EC2 instance.**
###### Once DB clint install we have to connect DB from Application server using below command 
```bash
    mysql -h 172.31.19.66 -uroot -pExpenseApp@1
    mysql -h <if it is sam vnet use same Privae IP>
 Once mySQL created we have to exit from mysql DB and execute below command to load schema
```
---
## Load Database Schema
```bash
mysql -h <MYSQL-SERVER-IPADDRESS> -u root -pExpenseApp@1 < /app/schema/backend.sql
 mysql -h 172.31.19.66 -uroot -pExpenseApp@1 < /app/schema/backend.sql
 ###To view the schema we have to execute below 
     mysql -h 172.31.19.66 -uroot -pExpenseApp@1
     show databases; # it will show all the default and created Databases 
         show tables;  # it will show all the list of tables 
         select * from transactions; #so will not have any transactions to see here 
```
---
## Configure SystemD Service
Create the service file:
```bash
vim /etc/systemd/system/backend.service
````

```bash
[Unit]
Description=Expense Backend Service
After=network.target

[Service]
User=expense
Environment=DB_HOST=<MYSQL-SERVER-IPADDRESS>
Environment=DB_USER=expense
Environment=DB_PWD=ExpenseApp@1
Environment=DB_DATABASE=transactions
ExecStart=/bin/node /app/index.js
SyslogIdentifier=backend
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```
## when our Linux VM Started, by default it will see the folder /etc/systemd/system/*.service it will start all the files by end with .services 
## we execute below commands it will goto below path 
---
## Start the Service

```bash
systemctl daemon-reload
systemctl enable backend
systemctl start backend
```

---

## Verification

Check service status:

```bash
systemctl status backend
```

Check application logs:

```bash
journalctl -u backend -f
```

Test the health endpoint (from the same server):

```bash
curl http://localhost:8080/health
```
---
## Security Group
Ensure the backend EC2 security group allows **inbound TCP on port 8080** from the frontend EC2's security group only (not from the internet).
