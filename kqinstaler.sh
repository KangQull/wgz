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

# Mengonfigurasi skrip yang akan dijalankan di Windows
cat > "$MOUNT_POINT/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/setup.bat" <<EOF
@ECHO OFF
REM Konfigurasi IP statis
netsh interface ip set address "Ethernet Instance 0 2" static YOUR_IP_ADDRESS 255.255.240.0 YOUR_GATEWAY
netsh interface ip add dns "Ethernet Instance 0 2" addr=1.1.1.1
netsh interface ip add dns "Ethernet Instance 0 2" addr=8.8.8.8
EXIT
EOF

# Membersihkan dan mematikan server
umount "$MOUNT_POINT"
echo "Instalasi selesai. Server akan dimatikan dalam 30 detik."
sleep 30
poweroff
