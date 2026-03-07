FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    # This tells DeepFace where to store models so they don't vanish
    DEEPFACE_HOME=/app/.deepface 

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create the weights directory and give permissions
RUN mkdir -p /app/.deepface/weights

COPY requirements.txt .

# Add gunicorn to your requirements.txt if it's not there!
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5001

# PRODUCTION COMMAND:
# --workers 1: Keep it at 1 for Render Free Tier to avoid RAM crashes
# --timeout 120: AI takes time; don't let the server kill the connection
CMD ["gunicorn", "--bind", "0.0.0.0:5001", "--workers", "1", "--timeout", "120", "deepface_service:app"]