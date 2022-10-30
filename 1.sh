#!/bin/bash
alias xray='bash /root/1.sh'
xray_config="/root/xray/config.json"
if  [ -f "$xray_config" ]; then
   xray_is_installed=1
else 
    xray_is_installed=0
fi


green()                            #原谅绿
{
    echo -e "\\033[32;1m${*}\\033[0m"
}

tyblue()                           #天依蓝
{
    echo -e "\\033[36;1m${*}\\033[0m"
}

    echo
    [ $xray_is_installed -eq 1 ] && xray_status="\\033[32m已安装" || xray_status="\\033[31m未安装"
    systemctl -q is-active xray && xray_status+="                \\033[32m运行中" || xray_status+="                \\033[31m未运行"
    echo
    tyblue "           Xray-core 服务状态   ：      ${xray_status}"
    echo
    echo
    green   "   1. 安装xray-core并导入vless+xtls配置"
    green   "   2. acme安装|更新 证书"
    green   "   3. systemd xray"
    green   "   4. 重启 xray-core"
    green   "   5. 关闭 xray-core"
    green   "   6. 开启 原版BBR"
    echo
    echo



    while [[ ! "$choice" =~ ^(0|[1-9][0-9]*)$ ]] || ((choice>27))
    do
        read -p "请选择：" choice
    done
if [ $choice == 1 ]; then

        tyblue " 安装xray-core并导入vless+xtls配置"
        green " 开始安装 xray-core ~~~~~ "
        green "apt update ~~~~"
        apt update & apt install lsof unzip curl socat -y
        mkdir xray 
        green " 创建程序目录 “xray” "
        cd xray
        wget https://github.com/XTLS/Xray-core/releases/download/v1.6.0/Xray-linux-64.zip 
        unzip Xray-linux-64.zip  
        rm Xray-linux-64.zip
        green "导入vless-tcp-xtls配置"
        touch config .json
        cat > config.json << EOF
                {
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "listen": "0.0.0.0",
            "port": 443,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "0bd96194-9926-47b1-8e58-0ede8d96b7d4",
                        "level": 0,
                        //"flow": "xtls-rprx-direct",
                        "email": "love@example.com"
                    }
                ],
                "decryption": "none",
                "fallbacks": [
                    {
                        "dest": 8001,
                        "xver": 1
                    },
                    {
                        "alpn": "h2",
                        "dest": 8002,
                        "xver": 1
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "tls",
                "tlsSettings": {
                    //"serverName": "jp.haodigtal.xyz",   //sni
                    "alpn": [
                                "h2",
                                 "http/1.1"
                    ],
                    "certificates": [
                        {
                            "certificateFile": "/cert/server.crt",
                            "keyFile": "/cert/server.key"
                        }
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ]
}


EOF
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
xray_is_installed=1
systemctl enable --now xray
green "写入Ok!，执行 systemctl status xray 查看服务状态"
systemctl status xray
green "请编辑目录下config.json,然后 systemctl restart xray"

    elif  [ $choice == 2 ]; then
        tyblue  "    acme安装|更新 证书" 
        apt update & apt install socat
        curl https://get.acme.sh | sh -s email=gg@gg.com
        cd & mkdir /cert
        tyblue "        在使用 80 端口申请证书~~~~~"
        url=0
        read -p "输入域名：" url
        cd & cd .acme.sh
        bash acme.sh --set-default-ca --server letsencrypt
        bash acme.sh --issue --standalone -d  $url  --force && bash acme.sh --install-cert -d $url   --key-file       /cert/server.key    --fullchain-file /cert/server.crt
        tyblue "        证书已经生成在 /root/cert"

    elif  [ $choice == 3 ]; then
        tyblue "    systemd xray-core服务状态"
        systemctl status xray

    elif  [ $choice == 4 ]; then
        tyblue "    重启 xray-core成功"
        systemctl restart xray

    elif  [ $choice == 5 ]; then
        tyblue  "   关闭xray-core"
        systemctl stop xray
    elif  [ $choice == 6 ]; then
        tyblue  "   开启原版BBR"
        echo net.core.default_qdisc=fq >> /etc/sysctl.conf
        echo net.ipv4.tcp_congestion_control=bbr >> /etc/sysctl.conf
        sudo sysctl -p
        tyblue  "   检测是否开启~~~"
        sudo sysctl net.ipv4.tcp_available_congestion_control

    fi




