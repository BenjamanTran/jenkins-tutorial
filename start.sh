#!/bin/bash

# Strict mode for safer bash execution
set -Eeuo pipefail
IFS=$'\n\t'

echo "=== 🚀 Jenkins Workshop 1 - Start Script ==="

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose found"

# Setup Jenkins configuration
echo "🔧 Setting up Jenkins configuration..."
./setup-jenkins.sh

# Start containers
echo "🐳 Starting Docker containers..."
docker-compose up -d

# Wait for Jenkins to start
echo "⏳ Waiting for Jenkins to start..."
sleep 30

# Show initial admin password (if setup wizard not skipped)
echo "🔑 Jenkins Admin Password:"
docker exec jenkins-workshop cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "Password not available yet, please check Jenkins logs"

# Ensure Ansible in Jenkins container (idempotent)
echo "📦 Ensuring Ansible in Jenkins container..."
docker exec --user root jenkins-workshop bash -lc '
set -Eeuo pipefail
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip openssh-client sshpass python3-venv >/dev/null 2>&1 || true
python3 -m venv /opt/ansible || true
/opt/ansible/bin/pip install --upgrade pip >/dev/null 2>&1 || true
/opt/ansible/bin/pip install ansible >/dev/null 2>&1 || true
ln -sf /opt/ansible/bin/ansible-playbook /usr/local/bin/ansible-playbook
ln -sf /opt/ansible/bin/ansible /usr/local/bin/ansible
'

echo "✅ System started successfully!"
echo ""
echo "🌐 Access URLs:"
echo "   Jenkins: http://localhost:8080"
echo "   Web Interface: http://localhost"
echo "   Deployed App: http://localhost/jenkins/tantt/"
echo ""
echo "📋 Next steps:"
echo "   1. Access Jenkins at http://localhost:8080"
echo "   2. Complete initial setup"
echo "   3. Install required plugins"
echo "   4. Configure email settings"
echo "   5. Run the deploy job"
