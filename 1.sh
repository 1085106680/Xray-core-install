#!/bin/bash
xray_core="/root/xray/xray"
if  [ -f "$xray_core" ]; then
   xray_is_installed=1
else 
    xray_is_installed=0
fi

xray() {    bash /root/1.sh
}

green()                            #原谅绿
{
    echo -e "\\033[32;1m${*}\\033[0m"
}

tyblue()                           #天依蓝
{
    echo -e "\\033[36;1m${*}\\033[0m"
}

red()                              #姨妈红
{
    echo -e "\\033[31;1m${*}\\033[0m"
}


chmod +x /root/1.sh


    echo
    [ $xray_is_installed -eq 1 ] && xray_status="\\033[32m已安装" || xray_status="\\033[31m未安装"
    systemctl -q is-active xray && xray_status+="                \\033[32m运行中" || xray_status+="                \\033[31m未运行"
    echo
    tyblue "           Xray-core 服务状态   ：      ${xray_status}"
    echo
    echo
    green   "   1. 安装xray-core"
    green   "   2. 导入 | 更换xray配置"
    green   "   3. acme安装|更新 证书"
    green   "   4. systemd xray"
    green   "   5. 重启 xray-core"
    green   "   6. 关闭 xray-core"
    green   "   7. 开启 原版BBR"
    green   "   0. 创建脚本快捷启动~~~执行 xray"
    echo
    red    "  按q 退出  "
    echo
    echo




    read -p "请选择：" choice
if [ $choice == 1 ]; then

        green " 开始安装 xray-core ~~~~~ "
        green "apt update ~~~~"
        apt update & apt install lsof unzip curl socat -y
        echo
        cd & mkdir xray 
        green " 创建程序目录 “xray” "
        cd xray
        wget https://github.com/XTLS/Xray-core/releases/download/v1.6.0/Xray-linux-64.zip 
        unzip Xray-linux-64.zip  
        rm Xray-linux-64.zip
        echo
        green "创建systemd服务ing~~~~~"
        echo
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
xray_is_installed=1
systemctl enable --now xray
xray



    elif [ $choice == 2 ]; then

        echo
        tyblue "    1.Trojan+tls"
        tyblue "    2.vless+tcp+xtls"
        tyblue "    3.vless+tcp+tls"
        tyblue "    4.vless+ws+tls"
        tyblue "    0.返回主菜单"
        echo

        read -p "请选择要导入的配置：" choice1
        if [ $choice1 == 1 ]; then
            red "  选择的配置是 Trojan+tls"
            cd & cd xray
            touch config.json
            cat > config.json << EOF
            {
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "port": 443,
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password":"haoyue123123",
                        "email": "love@example.com"
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "tls",
                "tlsSettings": {
                    "alpn": [
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
            "protocol": "freedom"
        }
    ]
}

EOF
systemctl restart xray
xray
    elif [ $choice1 == 2 ]; then
        red "  选择的配置是 vless+tcp+xtls"
            cd & cd xray
            touch config.json
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
                        "flow": "xtls-rprx-direct",
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
                "security": "xtls",
                "xtlsSettings": {
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
systemctl restart xray
xray


        elif [ $choice1 == 3 ]; then
            red "  选择的配置是 vless+tcp+tls"
            cd & cd xray
            touch config.json
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

systemctl restart xray
xray
    elif [ $choice1 == 4 ]; then
        red "  选择的配置是 vless+ws+tls"
            cd & mkdir /ws
            cd & cd xray
            touch config.json
            cat > config.json << EOF
            
            {
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "port": 443,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "0bd96194-9926-47b1-8e58-0ede8d96b7d4", // 填写你的 UUID
                        "level": 0,
                        "email": "love@example.com"
                    }
                ],
                "decryption": "none",
                "fallbacks": [
                    {
                        "dest": 80
                    },
                    {
                        "path": "/ws", // 必须换成自定义的 PATH
                        "dest": 1234,
                        "xver": 1
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "tls",
                "tlsSettings": {
                    "alpn": [
                        "http/1.1"
                    ],
                    "certificates": [
                        {
                            "certificateFile": "/cert/server.crt", // 换成你的证书，绝对路径
                            "keyFile": "/cert/server.key" // 换成你的私钥，绝对路径
                        }
                    ]
                }
            }
        },
        {
            "port": 1234,
            "listen": "127.0.0.1",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "0bd96194-9926-47b1-8e58-0ede8d96b7d4", // 填写你的 UUID
                        "level": 0,
                        "email": "love@example.com"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "acceptProxyProtocol": true, // 提醒：若你用 Nginx/Caddy 等反代 WS，需要删掉这行
                    "path": "/ws" // 必须换成自定义的 PATH，需要和上面的一致
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}

EOF

systemctl restart xray
xray
    elif [ $choice1 == 0 ]; then
        xray
    fi


    elif  [ $choice == 3 ]; then
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
        xray
    elif  [ $choice == 4 ]; then
        tyblue "    systemd xray-core服务状态"
        systemctl status xray
        sleep 1s
        xray
    elif  [ $choice == 5 ]; then
        tyblue "    重启 xray-core成功"
        systemctl restart xray
        xray

    elif  [ $choice == 6 ]; then
        tyblue  "   关闭xray-core"
        systemctl stop xray
        xray
    elif  [ $choice == 7 ]; then
        tyblue  "   开启原版BBR"
        echo net.core.default_qdisc=fq >> /etc/sysctl.conf
        echo net.ipv4.tcp_congestion_control=bbr >> /etc/sysctl.conf
        sudo sysctl -p
        tyblue  "   检测是否开启~~~"
        sudo sysctl net.ipv4.tcp_available_congestion_control
        xray
    elif [ $choice == 0 ]; then
            tyblue  "   创建脚本快捷启动~~~执行xray"
            echo  "alias xray='bash /root/1.sh'" >> /etc/bash.bashrc && source /etc/bash.bashrc
            xray
    elif [ $choice == q ]; then
            ctrl-c
    fi




