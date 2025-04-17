#!/bin/sh

# 你可以修改这个密码为你自己的
ROOT_PASSWORD="YourSecurePasswordHere"

echo "[1/5] 设置网络为 DHCP..."
cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

rc-update add networking default
/etc/init.d/networking restart

echo "[2/5] 更新包源..."
# 检查当前版本
ALPINE_VER=$(cut -d. -f1,2 /etc/alpine-release)
echo "http://dl-cdn.alpinelinux.org/alpine/v$ALPINE_VER/main" > /etc/apk/repositories
echo "http://dl-cdn.alpinelinux.org/alpine/v$ALPINE_VER/community" >> /etc/apk/repositories

apk update

echo "[3/5] 安装 openssh..."
apk add openssh

echo "[4/5] 启用 sshd 服务..."
rc-update add sshd default
/etc/init.d/sshd start

echo "[5/5] 设置 root 密码..."
echo "root:$ROOT_PASSWORD" | chpasswd

echo "✅ 初始化完成！你现在可以用 root@$IP 登录了。"
