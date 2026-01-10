#!/bin/bash
# Script tự động cài cloudflared, login, tạo tunnel và add DNS cho 3 subdomain: grafana, chat, openapi

set -e

# 1. Cài đặt cloudflared nếu chưa có
if ! command -v cloudflared &> /dev/null; then
  echo "cloudflared chưa được cài, tiến hành cài đặt..."
  if [[ "$(uname -s)" == "Linux" ]]; then
    wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    brew install cloudflared
  else
    echo "Vui lòng tự cài cloudflared cho hệ điều hành này!"
    exit 1
  fi
else
  echo "cloudflared đã được cài."
fi

# 2. Đăng nhập Cloudflare
cloudflared tunnel login

# 3. Nhập domain chính
read -p "Nhập domain chính (ví dụ: example.com): " DOMAIN

# 4. Tạo tunnel cho từng service
cloudflared tunnel create grafana-tunnel
cloudflared tunnel create chat-tunnel
cloudflared tunnel create openapi-tunnel

# 5. Lấy tunnel ID
grafana_id=$(cloudflared tunnel list | grep grafana-tunnel | awk '{print $1}')
chat_id=$(cloudflared tunnel list | grep chat-tunnel | awk '{print $1}')
openapi_id=$(cloudflared tunnel list | grep openapi-tunnel | awk '{print $1}')

# 6. Sinh file cấu hình cho từng tunnel
echo "url: http://localhost:3000
ingress:
  - hostname: grafana.$DOMAIN
    service: http://localhost:3000
  - service: http_status:404" > grafana-tunnel.yml

echo "url: http://localhost:8080
ingress:
  - hostname: chat.$DOMAIN
    service: http://localhost:8080
  - service: http_status:404" > chat-tunnel.yml

echo "url: http://localhost:11434
ingress:
  - hostname: openapi.$DOMAIN
    service: http://localhost:11434
  - service: http_status:404" > openapi-tunnel.yml

# 7. Tự động add public hostname (DNS) cho từng tunnel
cloudflared tunnel route dns $grafana_id grafana.$DOMAIN
cloudflared tunnel route dns $chat_id chat.$DOMAIN
cloudflared tunnel route dns $openapi_id openapi.$DOMAIN

# 8. Hướng dẫn tiếp theo
echo "\nĐã tạo xong tunnel, file cấu hình và tự động add DNS cho 3 subdomain."
echo "Chạy các lệnh sau để khởi động tunnel:\ncloudflared tunnel --config grafana-tunnel.yml run grafana-tunnel"
echo "cloudflared tunnel --config chat-tunnel.yml run chat-tunnel"
echo "cloudflared tunnel --config openapi-tunnel.yml run openapi-tunnel"
