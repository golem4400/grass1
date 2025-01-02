# Sử dụng Python chính thức làm base image
FROM python:3.11-slim

# Cài đặt các gói hệ thống cần thiết
RUN apt-get update && apt-get install -y \
    gcc \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Thiết lập thư mục làm việc
WORKDIR /app

# Sao chép mã nguồn vào container
COPY main.py /app/main.py

# Cài đặt các thư viện Python cần thiết
RUN pip install loguru websockets

# Thiết lập lệnh khởi chạy main.py
CMD ["python", "/app/main.py"]
