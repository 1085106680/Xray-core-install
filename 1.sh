#!/bin/bash
xray_core="/root/xray/xray"
tag=0
if  [ -f "$xray_core" ]; then
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

red()                              #姨妈红
{
    echo -e "\\033[31;1m${*}\\033[0m"
}

first-install() {
        chmod +x /root/1.sh
        apt update && apt install lsof unzip curl socat -y
}

aliass() {
        echo "alias xray='bash /root/1.sh' " >> ~/.bashrc
        source ~/.bashrc
}

menu() {
    echo
    [ $xray_is_installed -eq 1 ] && xray_status="\\033[32m已安装   " || xray_status="\\033[31m未安装   "
    systemctl -q is-active xray && xray_status+="\\033[32m运行中  " || xray_status+="\\033[31m未运行  "
    echo
    tyblue "           Xray-core 服务状态：    ${xray_status} "
    echo
    echo
    green   "   1. 安装xray-core"
    green   "   2. 导入 | 更换xray配置"
    green   "   3. acme安装|更新 证书"
    green   "   4. systemd xray"
    green   "   5. 重启 xray-core"
    green   "   6. 关闭 xray-core"
    green   "   7. 开启 原版BBR+pie"
    green   "   0. 查看日志"
    echo
    echo
		}
while true; do
	menu
	read -p "请选择：" choice
	case $choice in
		1)
		first-install && clear
		aliass
		echo
		cd ~ && mkdir xray 
		green " 创建程序目录 “xray” "
		cd xray
		tag=$(wget -qO- -t1 -T2 https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
		echo "$tag"
		download() {
					wget  https://github.com/XTLS/Xray-core/releases/download/$tag/Xray-linux-64.zip
					}
		download
		echo
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
		;;
		2)
		echo
		tyblue "    1.Trojan+tcp+tls+回落80 caddy"
		tyblue "    2.vless+ws反代"
		tyblue "    3.vless+tcp+tls"
		tyblue "    4.vless+ws+tls"
		tyblue "    5.Trojan+ws+tls"
		tyblue "    6.vmess+ws+nginx "
		tyblue "    0.返回主菜单"
		echo
		read -p "请选择要导入的配置：" choice1
		case $choice1 in
		1)
		red "  选择的配置是 Trojan+tls"
		cd ~ && cd xray
		touch config.json
		cat > config.json << EOF
 {
    "log": {
        "loglevel": "info",
		"access":"/root/xray/access.log"
    },
    "inbounds": [
        {
            "port": 12139,
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password":"haoyue123123",
                        "email": "love@example.com"
                    }
                ],
                "fallbacks": [ {
                                "dest": "80"
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
            "protocol": "freedom"
        }
    ]
}
EOF
		systemctl restart xray
		;;
		2)
		red "  选择的配置是 vless+ws反代"
		cd ~ && cd xray
		touch config.json
		cat > config.json << EOF
{
  "log": {
    "loglevel": "warning",
	"access": "/root/xray/access.log"
	
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 8888,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "c707c459-e368-5297-8a44-c5e4cbcde9d8"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/fullcone"
        }
      },
			"sniffing": {
				"enabled": true,
				"destOverride": [
					"http",
					"tls"
				]
			}
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {}
    },
    {
      "tag": "blocked",
      "protocol": "blackhole",
      "settings": {}
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "ip": [
          "geoip:cn",
          "geoip:private"
        ],
        "outboundTag": "blocked"
      }
    ]
  }
}


EOF
		systemctl restart xray
		;;
		3)
		red "  选择的配置是 vless+tcp+tls"
		cd ~ && cd xray
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
		;;
		4)
        red "  选择的配置是 vless+ws+tls"
        cd ~ && mkdir /ws
        cd ~ && cd xray
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
		echo
		systemctl restart xray
		;;
		5)
		red "  选择的配置是 Trojan+ws+tls"
		cd ~ && mkdir /ws
		cd ~ && cd xray
		touch config.json
		cat > config.json << EOF

{
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "port": 20000,
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
                "network": "ws",
                "security": "tls",
                "wsSettings": {
                                "acceptProxyProtocol": false,
                                "path": "/ws",
                                "headers": {
                                   "Host": "qq.com"
                                 }
                                    },
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
		echo
		systemctl restart xray
		;;
		6)
		red "  选择的配置是 vmess+ws+nginx"
        cd ~ && mkdir /fullcone
        cd ~ && cd xray
        touch config.json
        cat > config.json << EOF
{
    "log": {
        "loglevel": "warning",
        "access": "/root/xray/access.log"
    },
    "routing": {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "type": "field",
                "ip": [
                    "geoip:private"
                ],
                "outboundTag": "block"
            }
        ]
    },
    "inbounds": [
        {
            "listen": "127.0.0.1",
            "port": 8888,
            "protocol": "vmess",
            "security": "auto", 
            "settings": {
                "clients": [
                    {
                        "id": "c707c459-e368-5297-8a44-c5e4cbcde9d8"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                 "path": "/fullcone"
        }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        },
        {
            "protocol": "blackhole",
            "tag": "block"
        }
    ]
}

EOF
		echo
		apt install nginx -y
		cd ~ && cd xray &&touch nginx.conf 
		echo
		cat > nginx.conf << EOF
events {
        worker_connections 1024;
        }
http {
    server {
        # 监听端口
        listen 25565 fastopen=256;

        # 配置根目录
        root /var/www/html;

        # 配置索引文件
       # index index.html;
        tcp_nopush on;
        tcp_nodelay on;
        # 配置访问权限
        location / {
        proxy_pass http://127.0.0.1:8888;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    }

}
EOF
		echo
		cp /root/xray/nginx.conf /etc/nginx/nginx.conf
		systemctl restart nginx
		systemctl restart xray
		;;
		esac
		;;
		3)
		tyblue  "    acme安装|更新 证书"
		first-install
		curl https://get.acme.sh | sh -s email=gg@gg.com
		cd ~ && mkdir /cert
		tyblue "        在使用 80 端口申请证书~~~~~"
		url=0
		read -p "输入域名：" url
		cd ~ && cd .acme.sh
		bash acme.sh --set-default-ca --server letsencrypt
		bash acme.sh --issue --standalone -d  $url  --force && bash acme.sh --install-cert -d $url   --key-file       /cert/server.key    --fullchain-file /cert/server.crt
		tyblue "        证书已经生成在 /root/cert"
		;;
		4)
		tyblue "    systemd xray-core服务状态"
		systemctl status xray
		;;
		5)
		tyblue "    重启 xray-core成功"
		systemctl restart xray
		;;
		6)
		tyblue  "   关闭xray-core"
		systemctl stop xray
		;;
		7)
		tyblue  "   开启BBR-fq_pie"
		echo net.core.default_qdisc=fq_pie >> /etc/sysctl.conf
		echo net.ipv4.tcp_congestion_control=bbr >> /etc/sysctl.conf
		sudo sysctl -p
		tyblue  "   检测是否开启~~~"
		sudo sysctl net.ipv4.tcp_available_congestion_control
		red " 手动重启生效"
		;;
		0)
		tail -f -n100 /root/xray/access.log
		;;
		*)
		echo "输入无效"
		;;
	esac
done

