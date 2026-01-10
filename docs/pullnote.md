## Docker Pull Ollma
docker exec -it ollama olloma pull phi3:4k-q4_K_M
docker exec -it ollama ollama run hf.co/QingHong258/Deepseek-R1-8b-JiangPing-v1/resolve/main/Deepseek-R1-8b-JiangPing-v1.gguf
https://huggingface.co/modelshttps://huggingface.co/models
docker exec -it ollama olloma list
curl http://localhost:11434/api/tags
1️⃣ Dừng toàn bộ container
docker compose down
2️⃣ Dừng + xoá network (KHÔNG xoá volume)
docker compose down --remove-orphans
3️⃣ Khởi động lại từ đầu (recreate container)
docker compose up -d --force-recreate
4️⃣ Dừng → chạy lại sạch sẽ (hay dùng khi lỗi lặt vặt)
docker compose down
docker compose up -d
5️⃣ Xem container nào đang chạy
docker compose ps
6️⃣ Xem log toàn bộ
docker compose logs -f
Tuy vào GPU nếu quá load
8. Xoa container all
docker rm -f $(docker ps -aq)
🧱 Xoá TOÀN BỘ image
docker rmi -f $(docker images -aq)

environment:
  OLLAMA_NUM_THREADS: 2
  OLLAMA_MAX_LOADED_MODELS: 1

=> docker compose restart ollama
## elastic
user: elastic
docker exec -it elasticsearch bin/elasticsearch-reset-password -u elastic
curl -u elastic:Q3c5iarNaqaJtuYVBf5A -X POST "http://localhost:9200/_security/api_key" -H "Content-Type: application/json" -d '{"name": "my-api-key"}'

## Json Dash

{
  "title": "Open WebUI – Overview",
  "panels": [
    {
      "type": "timeseries",
      "title": "Request Rate (RPS)",
      "targets": [
        {
          "expr": "sum(rate(http_server_requests_total[1m]))"
        }
      ]
    },
    {
      "type": "timeseries",
      "title": "Error Rate (%)",
      "targets": [
        {
          "expr": "sum(rate(http_server_requests_total{http_status_code=~\"5..\"}[1m])) / sum(rate(http_server_requests_total[1m])) * 100"
        }
      ]
    },
    {
      "type": "timeseries",
      "title": "P95 Latency (ms)",
      "targets": [
        {
          "expr": "histogram_quantile(0.95, sum(rate(http_server_duration_bucket[5m])) by (le))"
        }
      ]
    }
  ],
  "schemaVersion": 38,
  "version": 1
}
 ## LibreTranslate Action

https://openwebui.com/posts/0f4323ab-9059-4bf9-bf47-7580b96af39a

---
## LibreTranslate Integration (Dịch máy tự host)

### 1. Thêm service LibreTranslate vào docker-compose.yml:
```yaml
  libretranslate:
    container_name: libretranslate
    image: libretranslate/libretranslate:v1.6.0
    restart: unless-stopped
    ports:
      - "5000:5000"
    env_file:
      - stack.env
    volumes:
      - libretranslate_api_keys:/app/db
      - libretranslate_models:/home/libretranslate/.local:rw
    tty: true
    stdin_open: true
    healthcheck:
      test: ['CMD-SHELL', './venv/bin/python scripts/healthcheck.py']

volumes:
  libretranslate_models:
  libretranslate_api_keys:
```

### 2. Tạo file stack.env (cùng thư mục với docker-compose.yml):
```env
# LibreTranslate
LT_DEBUG="false"
LT_UPDATE_MODELS="true"
LT_SSL="false"
LT_SUGGESTIONS="false"
LT_METRICS="false"
LT_HOST="0.0.0.0"
LT_API_KEYS="false"
LT_THREADS="12"
LT_FRONTEND_TIMEOUT="2000"
```

### 3. Khởi động LibreTranslate:
```sh
docker compose up -d libretranslate
```

### 4. Tích hợp vào Open WebUI
- Truy cập LibreTranslate API tại: http://localhost:5000
- Trong Open WebUI, cấu hình endpoint dịch máy về http://libretranslate:5000 nếu chạy cùng network Docker.
- Có thể dùng các community pipeline/filter/action cho LibreTranslate (xem tài liệu Open WebUI community).

### 5. Troubleshooting
- Kiểm tra log: `docker logs libretranslate`
- Đảm bảo port 5000 không bị trùng.
- Nếu cần API key, bật LT_API_KEYS và cấu hình thêm.

### 6. Lợi ích
- Dịch máy đa ngôn ngữ, không phụ thuộc Google/Azure.
- Có thể chạy offline, tự chủ dữ liệu.

---
## Image Generation với AUTOMATIC1111 (Stable Diffusion WebUI)

### 1. Thêm service AUTOMATIC1111 vào docker-compose.yml:
```yaml
  automatic1111:
    image: ghcr.io/abhinavxd/stable-diffusion-webui:latest
    container_name: automatic1111
    restart: unless-stopped
    ports:
      - "7860:7860"
    volumes:
      - ./automatic1111/models:/stable-diffusion-webui/models
    command: ["/webui.sh", "--api", "--listen"]
    networks:
      - openwebui_net
```

### 2. Thêm biến môi trường vào .env:
```env
AUTOMATIC1111_BASE_URL=http://automatic1111:7860/
ENABLE_IMAGE_GENERATION=true
```

### 3. Khởi động lại stack:
```sh
docker compose up -d
```

### 4. Cấu hình trong Open WebUI:
- Vào **Admin Panel > Settings > Images**
- Chọn Image Generation Engine: Default (Automatic1111)
- API URL: `http://automatic1111:7860/` (nếu cùng network Docker)

### 5. Lưu ý:
- Nếu chạy Open WebUI ngoài Docker, dùng `http://host.docker.internal:7860/`
- Đảm bảo AUTOMATIC1111 chạy với flag `--api --listen`

---
## Hướng dẫn cài đặt Cloudflare Tunnel cho Open WebUI, Ollama, Grandpdr (mỗi service 1 domain)

### 1. Đăng ký Cloudflare và thêm domain
- Đăng ký tài khoản Cloudflare (https://dash.cloudflare.com/)
- Thêm domain bạn sở hữu vào Cloudflare và trỏ DNS về Cloudflare (nếu chưa có domain, mua domain trước)

### 2. Cài đặt Cloudflare Tunnel (Cloudflared)
#### a. Cài đặt cloudflared trên máy chủ (Linux/Windows)
- Tải về: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/
- Ví dụ (Linux):
```sh
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
```
- Ví dụ (Windows):
Tải file .exe về và thêm vào PATH.

#### b. Đăng nhập Cloudflare Tunnel
```sh
cloudflared tunnel login
```
- Làm theo hướng dẫn để xác thực tài khoản Cloudflare.

### 3. Tạo tunnel cho từng service
#### a. Tạo tunnel cho Open WebUI
```sh
cloudflared tunnel create openwebui-tunnel
```
#### b. Tạo tunnel cho Ollama
```sh
cloudflared tunnel create ollama-tunnel
```
#### c. Tạo tunnel cho Grandpdr
```sh
cloudflared tunnel create grandpdr-tunnel
```

### 4. Cấu hình tunnel cho từng service
#### a. Tạo file cấu hình cho từng tunnel (ví dụ: openwebui-tunnel.yml)
Ví dụ cho Open WebUI (port 8080):
```yaml
url: http://localhost:8080
ingress:
  - hostname: openwebui.yourdomain.com
    service: http://localhost:8080
  - service: http_status:404
```
Tương tự cho Ollama (port 11434):
```yaml
url: http://localhost:11434
ingress:
  - hostname: ollama.yourdomain.com
    service: http://localhost:11434
  - service: http_status:404
```
Tương tự cho Grandpdr (ví dụ port 9000):
```yaml
url: http://localhost:9000
ingress:
  - hostname: grandpdr.yourdomain.com
    service: http://localhost:9000
  - service: http_status:404
```

#### b. Liên kết tunnel với domain trên Cloudflare
- Vào Cloudflare Dashboard > Zero Trust > Access > Tunnels > Chọn tunnel vừa tạo > Public Hostname > Add a public hostname
- Nhập subdomain (openwebui.yourdomain.com, ollama.yourdomain.com, grandpdr.yourdomain.com) và port tương ứng.

### 5. Khởi động tunnel cho từng service
```sh
cloudflared tunnel --config openwebui-tunnel.yml run openwebui-tunnel
cloudflared tunnel --config ollama-tunnel.yml run ollama-tunnel
cloudflared tunnel --config grandpdr-tunnel.yml run grandpdr-tunnel
```

### 6. Kiểm tra truy cập
- Truy cập https://openwebui.yourdomain.com, https://ollama.yourdomain.com, https://grandpdr.yourdomain.com từ bất kỳ đâu trên internet.

### 7. Lưu ý bảo mật
- Có thể cấu hình thêm xác thực (Access Policy) trong Cloudflare Zero Trust để bảo vệ endpoint.
- Không public các port backend trực tiếp ra internet, chỉ truy cập qua Cloudflare Tunnel.

---
## Script tự động tạo và add public hostname Cloudflare Tunnel cho 3 subdomain (grafana, chat, openapi)

### 1. Script shell (Linux/macOS, cần cloudflared đã cài đặt và đăng nhập)
Tạo file `create_cf_tunnel.sh` với nội dung sau:
```sh
#!/bin/bash
read -p "Nhập domain chính (ví dụ: example.com): " DOMAIN

# Tạo tunnel cho từng service
cloudflared tunnel create grafana-tunnel
cloudflared tunnel create chat-tunnel
cloudflared tunnel create openapi-tunnel

# Lấy tunnel ID
GRAFANA_ID=$(cloudflared tunnel list | grep grafana-tunnel | awk '{print $1}')
CHAT_ID=$(cloudflared tunnel list | grep chat-tunnel | awk '{print $1}')
OPENAPI_ID=$(cloudflared tunnel list | grep openapi-tunnel | awk '{print $1}')

# Sinh file cấu hình cho từng tunnel
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

# Tự động add public hostname (DNS) cho từng tunnel
cloudflared tunnel route dns $GRAFANA_ID grafana.$DOMAIN
cloudflared tunnel route dns $CHAT_ID chat.$DOMAIN
cloudflared tunnel route dns $OPENAPI_ID openapi.$DOMAIN

# Hướng dẫn tiếp theo
echo "\nĐã tạo xong tunnel, file cấu hình và tự động add DNS cho 3 subdomain."
echo "Chạy các lệnh sau để khởi động tunnel:\ncloudflared tunnel --config grafana-tunnel.yml run grafana-tunnel"
echo "cloudflared tunnel --config chat-tunnel.yml run chat-tunnel"
echo "cloudflared tunnel --config openapi-tunnel.yml run openapi-tunnel"
```

### 2. Cách dùng
```sh
chmod +x create_cf_tunnel.sh
./create_cf_tunnel.sh
```

- Script sẽ hỏi domain chính, tự động tạo tunnel, file cấu hình và add DNS cho 3 subdomain:
  - grafana.<domain> → port 3000
  - chat.<domain>    → port 8080 (Open WebUI)
  - openapi.<domain> → port 11434 (Ollama)

---