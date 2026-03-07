import os
import base64
import numpy as np
import cv2
import face_recognition
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

def decode_base64_to_image(base64_str):
    try:
        if "," in base64_str:
            base64_str = base64_str.split(",")[1]
        img_data = base64.b64decode(base64_str)
        nparr = np.frombuffer(img_data, np.uint8)
        # face_recognition needs RGB, but OpenCV decodes to BGR
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        return cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    except Exception:
        return None

@app.route('/verify', methods=['POST'])
def verify():
    data = request.json
    input_rgb = decode_base64_to_image(data.get('imageBase64', ''))
    reference_list = data.get('referenceBase64List', [])

    if input_rgb is None or not reference_list:
        return jsonify({"error": "Invalid input"}), 400

    # Get encoding for the input image
    input_encodings = face_recognition.face_encodings(input_rgb)
    if not input_encodings:
        return jsonify({"match": False, "error": "No face detected in input"})
    
    input_enc = input_encodings[0]

    for ref_base64 in reference_list:
        ref_rgb = decode_base64_to_image(ref_base64)
        if ref_rgb is None: continue
        
        ref_encodings = face_recognition.face_encodings(ref_rgb)
        if not ref_encodings: continue
        
        # Compare (0.6 is the default tolerance, lower is stricter)
        match = face_recognition.compare_faces([ref_enc], input_enc, tolerance=0.6)
        
        if match[0]:
            distance = face_recognition.face_distance([ref_enc], input_enc)[0]
            return jsonify({
                "match": True, 
                "distance": float(distance),
                "referenceBase64": ref_base64,
                "threshold": 0.6,
                "model": "dlib-resnet",
                "similarity_metric": "euclidian"
            })

    return jsonify({"match": False})

@app.route("/health")
def health():
    return {"status": "ok"}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=7860)