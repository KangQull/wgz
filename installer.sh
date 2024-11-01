#!/bin/bash

# Menentukan URL image Windows
WINDOWS_IMAGE_URL="https://cloudshydro.tech/s/7f7JCBDBQzGffyq/download?path=windows10lite.gz"
MOUNT_POINT="/mnt/windows"

# Mengunduh image Windows
wget -O- --no-check-certificate $WINDOWS_IMAGE_URL | gunzip | dd of=/dev/vda bs=3M status=progress

# Membuat direktori mount jika belum ada
mkdir -p "$MOUNT_POINT"

# Memount partisi Windows
mount.ntfs-3g /dev/vda2 "$MOUNT_POINT"

ip4=$(curl -4 -s ipv4.webshare.io)
gateway=$(ip route | awk '/default/ { print $3 }')

# Mengonfigurasi skrip yang akan dijalankan di Windows
cat > "$MOUNT_POINT/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/setup.bat" <<EOF
@ECHO OFF
REM Meminta input nama pengguna dan kata sandi
set /p username=Masukkan nama pengguna: 
set /p password=Masukkan kata sandi: 

REM Konfigurasi IP statis
netsh interface ip set address "Ethernet Instance 0 2" static $ip4 255.255.240.0 $gateway
netsh interface ip add dns "Ethernet Instance 0 2" addr=1.1.1.1
netsh interface ip add dns "Ethernet Instance 0 2" addr=8.8.8.8

REM Menambahkan pengguna baru
net user %username% %password% /add
net localgroup Administrators %username% /add

EXIT
EOF

# Membersihkan dan mematikan server
umount "$MOUNT_POINT"
echo "Instalasi selesai. Server akan dimatikan dalam 30 detik."
sleep 30
poweroff
