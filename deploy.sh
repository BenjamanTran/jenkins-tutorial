#!/bin/bash
# Strict mode for safer bash execution
set -Eeuo pipefail
IFS=$'\n\t'

echo "=== 🚀 Starting deployment process ==="

# Global error handling
trap 'echo "❌ Deployment failed! Please check the logs above."; exit 1' ERR

# Function to verify Ansible availability (no auto-install)
# Ensures ansible-playbook exists in PATH before proceeding
check_ansible() {
    echo "🔍 Checking Ansible..."
    if ! command -v ansible-playbook >/dev/null 2>&1; then
        echo "❌ Ansible not found in PATH inside Jenkins container."
        echo "   Please install it, e.g.:"
        echo "   apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip python3-venv"
        echo "   python3 -m venv /opt/ansible && /opt/ansible/bin/pip install --upgrade pip ansible"
        echo "   ln -sf /opt/ansible/bin/ansible /usr/local/bin/ansible"
        echo "   ln -sf /opt/ansible/bin/ansible-playbook /usr/local/bin/ansible-playbook"
        exit 1
    fi
    echo "✅ Ansible ready: $(ansible-playbook --version | head -n1)"
}

# Check Ansible
check_ansible

# Set environment variables
# RELEASE_DATE: the release folder name (YYYYMMDD)
# WORKSPACE: current working directory (Jenkins workspace)
# KEEP_RELEASES: how many releases to keep locally
export RELEASE_DATE=$(date +%Y%m%d)
export WORKSPACE=$(pwd)
export KEEP_RELEASES=${KEEP_RELEASES:-5}

echo "📅 Release Date: $RELEASE_DATE"
echo "📁 Workspace: $WORKSPACE"
echo "💾 Keep Releases: $KEEP_RELEASES"

# Set deployment environment (local, remote, or both)
DEPLOY_ENV=${DEPLOY_ENV:-"both"}
echo "🌍 Deploy Environment: $DEPLOY_ENV"

# Create local deployment directory only when deploying to local or both
if [ "$DEPLOY_ENV" = "local" ] || [ "$DEPLOY_ENV" = "both" ]; then
    echo "📂 Creating local deployment directory..."
    mkdir -p "deploy/$RELEASE_DATE"
    cp "app/index.html" "deploy/$RELEASE_DATE/"

    echo "🔗 Creating current symlink for local..."
    # Ensure previous 'current' directory does not block symlink creation
    if [ -d "deploy/current" ] && [ ! -L "deploy/current" ]; then
        rm -rf deploy/current
    fi
    ln -sfn "$RELEASE_DATE" "deploy/current"

    if [ -L "deploy/current" ] && [ "$(readlink deploy/current)" = "$RELEASE_DATE" ]; then
        echo "✅ Symlink current created successfully"
    else
        echo "❌ Failed to create symlink current"
        exit 1
    fi

    echo "🧹 Cleaning up old releases..."
    (
        cd deploy
        total_releases=$(ls -dt 20* 2>/dev/null | wc -l | tr -d ' ')
        if [ "$total_releases" -gt "$KEEP_RELEASES" ]; then
            remove_count=$(( total_releases - KEEP_RELEASES ))
            # Remove the oldest ones while keeping the most recent KEEP_RELEASES
            old_releases=$(ls -dt 20* 2>/dev/null | tail -n "$remove_count")
            for release in $old_releases; do
                echo "   ➤ Removing old release: $release"
                rm -rf "$release"
            done
        else
            echo "   No releases to remove."
        fi
    )
else
    echo "📂 Skipping local directory creation (remote only deployment)"
fi
cd "$WORKSPACE"

# Execute deployment based on environment
INVENTORY_FILE="${INVENTORY_FILE:-$WORKSPACE/hosts}"
EXTRA_VARS="-e app_src_path=$WORKSPACE/app/index.html"
case "$DEPLOY_ENV" in
    "local")
        echo "🏠 Deploying to local server..."
        ansible-playbook -i "$INVENTORY_FILE" deploy-local.yml $EXTRA_VARS
        ;;
    "remote")
        echo "🌐 Deploying to remote server..."
        ansible-playbook -i "$INVENTORY_FILE" deploy-remote.yml $EXTRA_VARS
        ;;
    "both")
        echo "🌍 Deploying to both servers (local + remote)..."
        echo "🏠 Deploying to local server first..."
        ansible-playbook -i "$INVENTORY_FILE" deploy-local.yml $EXTRA_VARS
        echo "⏳ Waiting 10 seconds before deploying to remote..."
        sleep 10
        echo "🌐 Deploying to remote server..."
        ansible-playbook -i "$INVENTORY_FILE" deploy-remote.yml $EXTRA_VARS
        ;;
    *)
        echo "❌ Invalid DEPLOY_ENV: $DEPLOY_ENV"
        echo "Valid options: local, remote, both"
        echo "  - local: Deploy to local server only"
        echo "  - remote: Deploy to remote server (direct connection)"
        echo "  - both: Deploy to local + remote (direct connection)"
        exit 1
        ;;
esac

# If we reach here, deployment was successful
echo "✅ Deploy completed successfully!"
echo "📊 Release: $RELEASE_DATE"
echo "🔗 Current symlink updated"
