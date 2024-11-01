#!/bin/bash

# Menentukan URL image Windows
WINDOWS_IMAGE_URL="https://example.com/windows_image.gz"
MOUNT_POINT="/mnt/windows"

# Mengunduh image Windows
wget --no-check-certificate -O windows_image.gz "$WINDOWS_IMAGE_URL"

# Mengekstrak image ke disk
gunzip -c windows_image.gz | dd of=/dev/vda bs=3M status=progress

# Membuat direktori mount jika belum ada
mkdir -p "$MOUNT_POINT"

# Memount partisi Windows
mount.ntfs-3g /dev/vda2 "$MOUNT_POINT"

# Menentukan variabel untuk IP dan pengguna
IP_ADDRESS="192.168.1.100"  # Ganti dengan IP yang diinginkan
GATEWAY="192.168.1.1"        # Ganti dengan gateway yang sesuai
USERNAME="newuser"
PASSWORD="yourpassword"

# Skrip untuk mengatur IP statis
cat > "$MOUNT_POINT/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/config_ip.bat" <<EOF
@ECHO OFF
cd /d "%ProgramData%\\Microsoft\\Windows\\Start Menu\\Programs\\Startup"
netsh interface ip set address "Ethernet" static $IP_ADDRESS 255.255.255.0 $GATEWAY
netsh interface ip add dns "Ethernet" addr=1.1.1.1
netsh interface ip add dns "Ethernet" addr=8.8.8.8
EXIT
EOF

# Skrip untuk menambahkan pengguna dan password
cat > "$MOUNT_POINT/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/setup_user.bat" <<EOF
@ECHO OFF
net user $USERNAME $PASSWORD /add
net localgroup Administrators $USERNAME /add
EXIT
EOF

# Mengonfigurasi auto login jika diperlukan
cat > "$MOUNT_POINT/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/registry.bat" <<EOF
@ECHO OFF
reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Authentication\\LogonUI" /v "AutoAdminLogon" /t REG_SZ /d "1" /f
reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon" /v "DefaultUserName" /t REG_SZ /d "$USERNAME" /f
reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon" /v "DefaultPassword" /t REG_SZ /d "$PASSWORD" /f
EXIT
EOF

# Membersihkan dan mematikan server
umount "$MOUNT_POINT"
echo "Skrip selesai. Server akan dimatikan dalam 30 detik."
sleep 30
poweroff
