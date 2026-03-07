# Use an image that already has dlib pre-compiled
FROM kunalgaba/python3.10-dlib:latest

# Install only the light system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install lightweight python packages
# We do NOT include dlib here because it's already in the base image
RUN pip install --no-cache-dir \
    flask \
    flask-cors \
    gunicorn \
    opencv-python-headless \
    numpy==1.24.3 \
    face_recognition

COPY . .

EXPOSE 5001

# Increase timeout because AI takes time to initialize on cold starts
CMD ["gunicorn", "--bind", "0.0.0.0:5001", "--workers", "1", "--timeout", "120", "app:app"]