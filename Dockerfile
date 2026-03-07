FROM python:3.10-slim

# Install build tools (Hugging Face has the RAM to handle this!)
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies
RUN pip install --no-cache-dir \
    flask \
    flask-cors \
    gunicorn \
    numpy \
    opencv-python-headless \
    face_recognition

COPY . .

# Hugging Face usually expects port 7860
EXPOSE 7860

CMD ["gunicorn", "--bind", "0.0.0.0:7860", "--workers", "1", "--timeout", "120", "app:app"]