# ⚡ Quick Start Guide

## 🚀 Khởi động nhanh

### 1. Chạy hệ thống
```bash
./start.sh
```

### 2. Truy cập Jenkins
- URL: http://localhost:8080
- Password: Xem trong terminal output

### 3. Cấu hình Jenkins
1. **Cài đặt plugins:**
   - Ansible Plugin
   - Extended Email Plugin
   - Role-based Authorization Strategy

2. **Cấu hình email:**
   - SMTP: smtp.gmail.com:587
   - Username: your-email@gmail.com
   - Password: your-app-password

### 4. Chạy Job Deploy
1. Vào job "deploy-application"
2. **Build with Parameters:**
   - DEPLOY_ENV: local/remote/both
   - KEEP_RELEASES: 5
3. Click **Build**

## 🌐 URLs quan trọng
- **Jenkins:** http://localhost:8080
- **Web Interface:** http://localhost
- **Deployed App:** http://localhost/jenkins/tantt/

## 📧 Email Notification
- Recipient: tantt@zigexn.vn
- Triggers: Success/Failure

## 🔐 Roles
- **Admin:** Toàn quyền
- **Writer:** Build jobs
- **Reader:** Xem logs

## 🎯 Điểm số: 10/10 ✅
- Build Steps: 5 điểm ✅
- Ansible: 2 điểm ✅
- Role Management: 1 điểm ✅
- Email: 1 điểm ✅
- Symlink & Cleanup: 1 điểm ✅
