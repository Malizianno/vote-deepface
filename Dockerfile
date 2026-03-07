# Step 1: Build stage
FROM python:3.11-slim as builder
RUN apt-get update && apt-get install -y \
    build-essential cmake libopenblas-dev liblapack-dev libx11-dev \
    && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Step 2: Final stage
FROM python:3.11-slim
RUN apt-get update && apt-get install -y libgl1 libglib2.0-0 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
EXPOSE 5001
CMD ["gunicorn", "--bind", "0.0.0.0:5001", "--workers", "1", "--timeout", "60", "app:app"]