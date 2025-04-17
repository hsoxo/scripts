#!/bin/sh

# Set root password here
ROOT_PASSWORD="YourSecurePasswordHere"

echo "[1/6] Configuring network (DHCP)..."
cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

rc-update add networking default
/etc/init.d/networking restart

echo "[2/6] Updating APK repositories..."
ALPINE_VER=$(cut -d. -f1,2 /etc/alpine-release)
echo "http://dl-cdn.alpinelinux.org/alpine/v$ALPINE_VER/main" > /etc/apk/repositories
echo "http://dl-cdn.alpinelinux.org/alpine/v$ALPINE_VER/community" >> /etc/apk/repositories

apk update

echo "[3/6] Installing OpenSSH..."
apk add openssh

echo "[4/6] Enabling root login for SSH..."
if grep -q "^#PermitRootLogin" /etc/ssh/sshd_config; then
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
elif ! grep -q "^PermitRootLogin" /etc/ssh/sshd_config; then
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
fi

echo "[5/6] Enabling and starting sshd..."
rc-update add sshd default
/etc/init.d/sshd restart

echo "[6/6] Setting root password..."
echo "root:$ROOT_PASSWORD" | chpasswd

echo "Initialization complete. SSH should now be available."
