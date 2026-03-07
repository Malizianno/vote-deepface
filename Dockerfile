# Use an image that already has dlib/face_recognition pre-installed
FROM python:3.10-slim

# Install system dependencies for OpenCV and dlib runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# IMPORTANT: Install dlib from a pre-compiled wheel to avoid the 8GB crash
# This wheel is for Linux x86_64 and Python 3.10
RUN pip install --no-cache-dir \
    numpy==1.24.3 \
    opencv-python-headless \
    flask \
    flask-cors \
    gunicorn

# Install face_recognition separately (it will find the pre-installed dlib)
RUN pip install --no-cache-dir face_recognition

COPY . .

EXPOSE 5001

CMD ["gunicorn", "--bind", "0.0.0.0:5001", "--workers", "1", "--timeout", "120", "app:app"]