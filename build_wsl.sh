#!/bin/bash
# WSL 构建脚本 - 在 WSL Ubuntu 中运行
set -e

# 清除 PATH，使用 WSL 默认值
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 设置 THEOS
export THEOS=/mnt/d/codexData/Theos
export PATH=$THEOS/bin:$PATH

echo "=== 环境检查 ==="
echo "THEOS=$THEOS"
echo ""

echo "=== 检查工具 ==="
which clang && clang --version | head -2
which make && make --version | head -2
which dpkg-deb && echo "dpkg-deb found"
echo ""

echo "=== 检查 SDK ==="
ls -la $THEOS/sdks/iPhoneOS16.5.sdk/ | head -10
echo ""

echo "=== 检查 ldid ==="
if ! which ldid 2>/dev/null; then
    echo "ldid 未找到，正在安装..."
    sudo apt-get install -y libssl-dev
    cd /tmp
    if [ ! -d ldid ]; then
        git clone https://github.com/ProcursusTeam/ldid.git
    fi
    cd ldid
    make
    sudo cp ldid /usr/local/bin/
fi
ldid --version
echo ""

echo "=== 开始构建 ==="
cd /mnt/c/Users/zjc/.hermes-web-ui/upload/default/stheno-boundary

# 清理
make clean 2>/dev/null || true

# 构建
make package

echo ""
echo "=== 构建完成 ==="
ls -la packages/ 2>/dev/null || ls -la *.deb 2>/dev/null || (echo "检查当前目录:" && ls -la)
