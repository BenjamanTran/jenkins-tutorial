# 🚀 Jenkins Workshop 1 - Deploy Automation

## 📋 Description
This project implements a CI/CD system using Jenkins and Ansible to automate the deployment of web applications to both local and remote servers.

## 🎯 Key Features
- ✅ **Complete Build Steps** (5 points)
- ✅ **Ansible Configuration** (2 points) 
- ✅ **Role Management** (1 point)
- ✅ **Email Notification** (1 point)
- ✅ **Symlink & Cleanup** (1 point)
- **Total Score: 10/10**

## 🏗️ Project Structure
```
tantt/
├── app/
│   └── index.html              # Main application
├── test/
│   └── test.sh                # Test script
├── deploy/                    # Release directory
├── html/
│   └── jenkins/tantt/         # Web interface
├── hosts                     # Ansible inventory
├── ansible.cfg              # Ansible configuration
├── deploy-local.yml         # Local deployment playbook
├── deploy.sh                # Main deployment script
├── docker-compose.yml       # Docker services
├── nginx.conf              # Nginx configuration
├── start.sh                # Startup script
└── README.md               # This file
```

## 🚀 Installation and Setup

### System Requirements
- Docker (version 20.10+)
- Docker Compose (version 2.0+)
- Git

### Step 1: Clone and Setup
```bash
# Navigate to project directory
cd tantt/

# Make scripts executable
chmod +x *.sh

# Start the system
./start.sh
```

### Step 2: Access Jenkins
1. Open browser: http://localhost:8080
2. Enter admin password (displayed in terminal)
3. Install suggested plugins
4. Create admin user

### Step 3: Configure Jenkins
1. **Install required plugins:**
   - Ansible Plugin
   - Extended Email Plugin
   - Role-based Authorization Strategy
   - SSH Agent Plugin

2. **Configure Role Strategy:**
   - Admin: full access
   - Writer: build and deploy jobs
   - Reader: view logs only

3. **Configure Email:**
   - SMTP: smtp.gmail.com:587
   - Username: your-email@gmail.com
   - Password: your-app-password

## 🎮 Usage

### Run Deploy Job (CI/CD Firebase + Remote)
1. Go to Jenkins Dashboard
2. Select job "deploy-application"
3. **Build with Parameters:**
   - **REPO_URL:** URL repo landing page (fork của bạn)
   - **BRANCH:** nhánh build, mặc định `main`
   - **DEPLOY_ENV:** local/remote/both
   - **KEEP_RELEASES:** 5 (default)
   - **FIREBASE_PROJECT_ID:** Project ID Firebase (tùy chọn)
4. Cấu hình môi trường trước khi build:
   - Sử dụng một trong hai cách xác thực Firebase:
     - ADC: export `GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/file.json`
     - Token: export `FIREBASE_TOKEN=xxxx` (nếu không dùng ADC)
   - Mount SSH private key `~/.ssh/newbie_id_rsa` (đã mount sẵn trong compose)
5. Click **Build**

### Check Results
- **Web Interface:** http://localhost
- **Local Deployed App:** http://localhost/jenkins/tantt/deploy/current/
- **Remote Deployed App:** http://118.69.34.46/jenkins/tantt/deploy/current/
- **Firebase Hosting:** theo domain project Firebase của bạn
- **Jenkins Logs:** View console output of job

## 🔧 Deployment Commands

### Local Deployment
```bash
DEPLOY_ENV=local ./deploy.sh
```

### Remote Deployment (Direct)
```bash
DEPLOY_ENV=remote ./deploy.sh
```

### Remote Deployment (via Jump Host)
```bash
DEPLOY_ENV=remote-jump ./deploy.sh
```

### Both Environments (Local + Remote Direct)
```bash
DEPLOY_ENV=both ./deploy.sh
```

### Both Environments (Local + Remote via Jump Host)
```bash
DEPLOY_ENV=both-jump ./deploy.sh
```

## 🔧 Troubleshooting

### Docker Issues
```bash
# Check Docker service
sudo systemctl status docker
sudo systemctl start docker
```

### Jenkins Issues
```bash
# View logs
docker logs jenkins-workshop

# Restart container
docker restart jenkins-workshop
```

### SSH Issues
```bash
# Check SSH key
ls -la ~/.ssh/

# Set SSH key permissions
chmod 600 ~/.ssh/newbie_id_rsa
```

## 📧 Email Notification
The system will send email notifications to `tantt@zigexn.vn` when:
- ✅ Deployment successful
- ❌ Deployment failed

## 🔐 Role Management
- **Admin:** Full Jenkins management access
- **Writer:** Can build and configure jobs
- **Reader:** View logs and status only

## 📊 Monitoring
- **Jenkins:** http://localhost:8080
- **Nginx Status:** Check in container
- **Deploy History:** View in deploy/ directory

## 🎥 Video Demo
Record demo video following script in `HUONG_DAN_CHI_TIET.md` with maximum 10 minutes duration.

## 📝 Notes
- Ensure SSH key is properly configured
- Check network connection before remote deployment
- Backup important data before testing
- Test script checks for app/index.html existence
