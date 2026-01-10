# Hướng dẫn Cài đặt & Sử dụng ComfyUI trên DGX/Spark

## Tổng quan
ComfyUI là giao diện web mạnh mẽ cho việc tạo ảnh AI, hỗ trợ GPU NVIDIA. Hướng dẫn này giúp bạn cài đặt, chạy và kiểm tra ComfyUI trên máy DGX hoặc Spark.

---

## Bước 1: Kiểm tra điều kiện hệ thống

Chạy các lệnh sau để xác nhận hệ thống đáp ứng yêu cầu:

```bash
python3 --version
pip3 --version
nvcc --version
nvidia-smi
```
- Python >= 3.8, pip đã cài, CUDA toolkit, và GPU NVIDIA phải được phát hiện.

---

## Bước 2: Tạo môi trường ảo Python

```bash
python3 -m venv comfyui-env
source comfyui-env/bin/activate
```
- Đảm bảo prompt hiển thị `(comfyui-env)`.

---

## Bước 3: Cài PyTorch hỗ trợ CUDA

```bash
pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu130
```
- Dành cho CUDA 13.0 (Blackwell GPU).

---

## Bước 4: Clone mã nguồn ComfyUI

```bash
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI/
```

---

## Bước 5: Cài đặt các phụ thuộc

```bash
pip install -r requirements.txt
```

---

## Bước 6: Tải checkpoint Stable Diffusion

```bash
cd models/checkpoints/
wget https://huggingface.co/Comfy-Org/stable-diffusion-v1-5-archive/resolve/main/v1-5-pruned-emaonly-fp16.safetensors
cd ../../
```
- File ~2GB, cần thời gian tải.

---

## Bước 7: Khởi động ComfyUI server

```bash
python main.py --listen 0.0.0.0
```
- Server sẽ chạy trên port 8188, truy cập được từ các thiết bị khác.

---

## Bước 8: Kiểm tra hoạt động

```bash
curl -I http://localhost:8188
```
- Kết quả trả về HTTP 200 là thành công.
- Truy cập trình duyệt: `http://<SPARK_IP>:8188`

---

## Bước 9: (Tùy chọn) Xóa cài đặt

```bash
deactivate
rm -rf comfyui-env/
rm -rf ComfyUI/
```
- **Cảnh báo:** Xóa toàn bộ môi trường và model đã tải.

---

## Bước 10: (Tùy chọn) Thử tạo ảnh

- Truy cập web UI: `http://<SPARK_IP>:8188`
- Load workflow mặc định, nhấn "Run" để tạo ảnh đầu tiên.
- Theo dõi GPU với `nvidia-smi` nếu muốn.

---

## Troubleshooting

- Nếu gặp lỗi về CUDA, kiểm tra lại driver và phiên bản PyTorch.
- Nếu port 8188 bị chiếm, đổi port khi chạy server: `python main.py --listen 0.0.0.0 --port <PORT_MỚI>`

---

## Tham khảo

- [ComfyUI GitHub](https://github.com/comfyanonymous/ComfyUI)
- [Stable Diffusion v1.5 Checkpoint](https://huggingface.co/Comfy-Org/stable-diffusion-v1-5-archive)

---

Chúc bạn thành công với ComfyUI!
