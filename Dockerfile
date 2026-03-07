# Use a pre-built image that already has face_recognition and dlib
FROM animcogn/face_recognition:latest

# Install only the web-related dependencies
RUN pip install --no-cache-dir \
    flask \
    flask-cors \
    gunicorn \
    numpy

WORKDIR /app
COPY . .

# Hugging Face port
EXPOSE 7860

CMD ["gunicorn", "--bind", "0.0.0.0:7860", "--workers", "1", "--timeout", "120", "app:app"]