FROM python:3.10-slim

# 1. Install pre-compiled dlib and system dependencies
# This avoids the 8GB RAM 'Build' crash entirely
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-dlib \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Link the system-installed dlib to your python environment
# Debian installs it to /usr/lib/python3/dist-packages
ENV PYTHONPATH="${PYTHONPATH}:/usr/lib/python3/dist-packages"

# 3. Install the remaining lightweight packages
# NOTE: Removed 'dlib' and 'face_recognition' from here to prevent re-compilation
RUN pip install --no-cache-dir \
    flask \
    flask-cors \
    gunicorn \
    opencv-python-headless \
    numpy==1.24.3

# 4. Install face_recognition (it's a light wrapper, won't trigger dlib build now)
RUN pip install --no-cache-dir face_recognition --no-dependencies

COPY . .

EXPOSE 5001

CMD ["gunicorn", "--bind", "0.0.0.0:5001", "--workers", "1", "--timeout", "120", "app:app"]