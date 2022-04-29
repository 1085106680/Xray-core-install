#! /root/xray/bash
green()                            #原谅绿
{
    echo -e "\\033[32;1m${*}\\033[0m"
}
green "~~~~~~~正在下载ing~~~~~~~"
wget https://ghproxy.com/https://github.com/XTLS/Xray-core/releases/download/v1.5.4/Xray-linux-64.zip
green "~~~~~安装unzip~~~~~ing~~~~"
apt install unzip -y
green "~~~~解压ing~~~~"
mkdir xray
unzip -o -d xray  Xray-linux-64.zip
cd xray
touch config.json
green "创建systemd服务ing~~~~~"
cat > /etc/systemd/system/xray.service << EOF
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/root/xray/xray run -config /root/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

green "写入Ok!，执行 systemctl enable --now xray 开启服务"
systemctl enable --now xray
green "写入Ok!，执行 systemctl status xray 查看服务状态"
systemctl status xray
green "请编辑目录下config.json,然后 systemctl restart xray"