#!/bin/sh
set -e
PORT=${PORT:-8080}
if [ -z "$UUID" ]; then echo "UUID env missing" >&2; exit 1; fi
if [ -z "$WS_PATH" ]; then echo "WS_PATH env missing" >&2; exit 1; fi
echo "Downloading xray-core official release..."
curl -fsSL -o /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip"
unzip -o /tmp/xray.zip -d /usr/local/bin/ xray
chmod +x /usr/local/bin/xray
mkdir -p /etc/xray
cat > /etc/xray/config.json <<EOF
{
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vless",
      "settings": {
        "clients": [{ "id": "$UUID", "flow": "" }],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "$WS_PATH" }
      }
    }
  ],
  "outbounds": [{ "protocol": "freedom" }]
}
EOF
echo "Starting xray on port $PORT ws $WS_PATH"
exec /usr/local/bin/xray run -c /etc/xray/config.json
