#!/bin/bash

set -e

exec > >(tee /var/log/sonarqube-install.log | logger -t sonarqube-install -s 2>/dev/console) 2>&1

echo "=========================================="
echo "Starting SonarQube installation"
echo "=========================================="

# --------------------------------------------------
# Variables
# --------------------------------------------------

SONAR_VERSION="26.9.0.129388"
SONAR_HOME="/opt/sonarqube"
SONAR_USER="sonarqube"
SONAR_GROUP="sonarqube"

POSTGRES_DB="sonarqube"
POSTGRES_USER="sonarqube"

SONAR_ZIP="sonarqube-${SONAR_VERSION}.zip"
SONAR_URL="https://binaries.sonarsource.com/Distribution/sonarqube/${SONAR_ZIP}"

# --------------------------------------------------
# 1. Update packages
# --------------------------------------------------

echo "Installing prerequisite packages..."

dnf install -y \
    wget \
    curl \
    unzip \
    tar \
    gzip \
    vim \
    git \
    fontconfig \
    policycoreutils-python-utils \
    lvm2 \
    xfsprogs

# --------------------------------------------------
# 2. Install Java 21
# --------------------------------------------------

echo "Installing Java 21..."

dnf install -y java-21-openjdk java-21-openjdk-devel

java -version

# --------------------------------------------------
# 3. Install PostgreSQL 16
# --------------------------------------------------

echo "Installing PostgreSQL 16..."

dnf module reset postgresql -y
dnf module enable postgresql:16 -y

dnf install -y postgresql-server postgresql-contrib

if [ ! -f /var/lib/pgsql/data/PG_VERSION ]; then
    echo "Initializing PostgreSQL..."
    postgresql-setup --initdb
fi

systemctl enable postgresql
systemctl start postgresql

systemctl status postgresql --no-pager

# --------------------------------------------------
# 4. Configure PostgreSQL authentication
# --------------------------------------------------

echo "Configuring PostgreSQL authentication..."

PG_HBA="/var/lib/pgsql/data/pg_hba.conf"

sed -i 's/^host[[:space:]]\+all[[:space:]]\+all[[:space:]]\+127.0.0.1\/32[[:space:]]\+.*/host    all    all    127.0.0.1\/32    scram-sha-256/' "$PG_HBA"

sed -i 's/^host[[:space:]]\+all[[:space:]]\+all[[:space:]]\+::1\/128[[:space:]]\+.*/host    all    all    ::1\/128         scram-sha-256/' "$PG_HBA"

systemctl restart postgresql

# --------------------------------------------------
# 5. Create SonarQube database/user
# --------------------------------------------------

echo "Creating SonarQube PostgreSQL database..."

# Generate a random password if one isn't supplied.
# IMPORTANT: For production, pass this through Secrets Manager
# rather than storing it directly in this script.

SONAR_DB_PASSWORD="${SONAR_DB_PASSWORD:-CHANGE_ME}"

if [ "$SONAR_DB_PASSWORD" = "CHANGE_ME" ]; then
    echo "ERROR: SONAR_DB_PASSWORD is not configured."
    echo "Set the database password securely before running this script."
    exit 1
fi

sudo -u postgres psql <<EOF
DO \$\$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles
        WHERE rolname = '${POSTGRES_USER}'
    ) THEN
        CREATE ROLE ${POSTGRES_USER} LOGIN PASSWORD '${SONAR_DB_PASSWORD}';
    ELSE
        ALTER ROLE ${POSTGRES_USER} WITH PASSWORD '${SONAR_DB_PASSWORD}';
    END IF;
END
\$\$;

SELECT 'CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER}'
WHERE NOT EXISTS (
    SELECT FROM pg_database WHERE datname = '${POSTGRES_DB}'
)\gexec

GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};
EOF

# --------------------------------------------------
# 6. Test PostgreSQL connection
# --------------------------------------------------

echo "Testing PostgreSQL connection..."

PGPASSWORD="$SONAR_DB_PASSWORD" \
psql -h 127.0.0.1 \
     -U "$POSTGRES_USER" \
     -d "$POSTGRES_DB" \
     -c "SELECT version();"

# --------------------------------------------------
# 7. Configure Linux kernel parameters
# --------------------------------------------------

echo "Configuring kernel parameters..."

cat > /etc/sysctl.d/99-sonarqube.conf <<EOF
vm.max_map_count=524288
fs.file-max=131072
EOF

sysctl --system

echo "Kernel settings:"
sysctl vm.max_map_count
sysctl fs.file-max

# --------------------------------------------------
# 8. Configure SonarQube limits
# --------------------------------------------------

echo "Configuring SonarQube system limits..."

cat > /etc/security/limits.d/99-sonarqube.conf <<EOF
${SONAR_USER}   -   nofile   131072
${SONAR_USER}   -   nproc    8192
EOF

# --------------------------------------------------
# 9. Create SonarQube user
# --------------------------------------------------

echo "Creating SonarQube user..."

if ! id "$SONAR_USER" >/dev/null 2>&1; then
    useradd --system --create-home --shell /bin/bash "$SONAR_USER"
fi

# --------------------------------------------------
# 10. Create SonarQube directory
# --------------------------------------------------

mkdir -p "$SONAR_HOME"

# --------------------------------------------------
# 11. Download SonarQube
# --------------------------------------------------

echo "Downloading SonarQube ${SONAR_VERSION}..."

cd /tmp

if [ ! -f "$SONAR_ZIP" ]; then
    wget -O "$SONAR_ZIP" "$SONAR_URL"
fi

# --------------------------------------------------
# 12. Extract SonarQube
# --------------------------------------------------

echo "Extracting SonarQube..."

rm -rf "/tmp/sonarqube-${SONAR_VERSION}"

unzip -q "$SONAR_ZIP" -d /tmp

rm -rf "$SONAR_HOME"

mv "/tmp/sonarqube-${SONAR_VERSION}" "$SONAR_HOME"

# --------------------------------------------------
# 13. Configure SonarQube
# --------------------------------------------------

echo "Configuring SonarQube..."

SONAR_PROPERTIES="$SONAR_HOME/conf/sonar.properties"

cat >> "$SONAR_PROPERTIES" <<EOF

# Database configuration
sonar.jdbc.username=${POSTGRES_USER}
sonar.jdbc.password=${SONAR_DB_PASSWORD}
sonar.jdbc.url=jdbc:postgresql://127.0.0.1:5432/${POSTGRES_DB}

# Web configuration
sonar.web.port=9000
EOF

# --------------------------------------------------
# 14. Fix ownership
# --------------------------------------------------

echo "Setting SonarQube ownership..."

chown -R "${SONAR_USER}:${SONAR_GROUP}" "$SONAR_HOME"

# --------------------------------------------------
# 15. Ensure SonarQube scripts are executable
# --------------------------------------------------

find "$SONAR_HOME/bin" \
    -type f \
    -name "*.sh" \
    -exec chmod +x {} \;

# --------------------------------------------------
# 16. Create systemd service
# --------------------------------------------------

echo "Creating SonarQube systemd service..."

cat > /etc/systemd/system/sonarqube.service <<EOF
[Unit]
Description=SonarQube Service
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=forking

User=${SONAR_USER}
Group=${SONAR_GROUP}

ExecStart=${SONAR_HOME}/bin/linux-x86-64/sonar.sh start
ExecStop=${SONAR_HOME}/bin/linux-x86-64/sonar.sh stop

LimitNOFILE=131072
LimitNPROC=8192

Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# --------------------------------------------------
# 17. Enable and start SonarQube
# --------------------------------------------------

echo "Starting SonarQube..."

systemctl daemon-reload

systemctl enable sonarqube

systemctl start sonarqube

# --------------------------------------------------
# 18. Wait for SonarQube
# --------------------------------------------------

echo "Waiting for SonarQube to start..."

for i in {1..30}; do

    if curl -s http://127.0.0.1:9000/api/system/status >/dev/null 2>&1; then
        echo "SonarQube HTTP endpoint is responding."
        break
    fi

    echo "Waiting... $i/30"
    sleep 10

done

# --------------------------------------------------
# 19. Status
# --------------------------------------------------

echo "=========================================="
echo "SonarQube service status"
echo "=========================================="

systemctl status sonarqube --no-pager || true

echo "=========================================="
echo "PostgreSQL status"
echo "=========================================="

systemctl status postgresql --no-pager || true

echo "=========================================="
echo "SonarQube installation completed"
echo "=========================================="

echo "SonarQube URL:"
echo "http://$(hostname -I | awk '{print $1}'):9000"