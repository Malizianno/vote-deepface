import os
# Force TensorFlow to use only CPU and be quiet
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3' 
os.environ['OMP_NUM_THREADS'] = '1'
os.environ['TF_NUM_INTRAOP_THREADS'] = '1'
os.environ['TF_NUM_INTEROP_THREADS'] = '1'

import tensorflow as tf
# Limit TensorFlow to 1 CPU thread to save RAM
tf.config.threading.set_inter_op_parallelism_threads(1)
tf.config.threading.set_intra_op_parallelism_threads(1)

from flask import Flask, request, jsonify
from flask_cors import CORS
from deepface import DeepFace
import base64
import cv2
import numpy as np
import logging

app = Flask(__name__)
CORS(app) # Enable CORS for all routes
logging.basicConfig(level=logging.INFO)

# Configuration
# OLD_MODEL_NAME = "ArcFace"
# OLD_DETECTOR_BACKEND = "retinaface"

MODEL_NAME = "OpenFace"
DETECTOR_BACKEND = "opencv"

thresholds = {
    "ArcFace": 0.4,
    "Facenet": 0.7,
    "VGG-Face": 0.4,
    "Dlib": 0.6,
    "OpenFace": 0.1
}

def decode_base64_image(base64_str):
    try:
        img_data = base64.b64decode(base64_str)
        np_arr = np.frombuffer(img_data, np.uint8)
        return cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    except Exception as e:
        logging.warning(f"Failed to decode image: {e}")
        return None

@app.route('/verify', methods=['POST'])
def verify():
    data = request.json
    input_img = decode_base64_image(data.get('imageBase64'))
    reference_list = data.get('referenceBase64List', [])

    if input_img is None or not reference_list:
        return jsonify({ "error": "Invalid input image or reference list" }), 400

    best_match = None
    lowest_distance = float('inf')

    for ref_base64 in reference_list:
        ref_img = decode_base64_image(ref_base64)
        if ref_img is None:
            continue

        try:
            result = DeepFace.verify(
                img1_path=input_img,
                img2_path=ref_img,
                model_name=MODEL_NAME,
                detector_backend=DETECTOR_BACKEND,
                enforce_detection=False,
                align=False
            )
            logging.info(f"Verification result: {result}")

            if result["verified"] and result["distance"] < lowest_distance:
                best_match = {
                    "distance": result["distance"],
                    "model": result["model"],
                    "similarity_metric": result["similarity_metric"],
                    "threshold": thresholds.get(result["model"], None),
                    "referenceBase64": ref_base64
                }
                lowest_distance = result["distance"]
        except Exception as e:
            logging.warning(f"Verification failed: {e}")
            continue

    if best_match:
        return jsonify({ "match": True, **best_match })
    else:
        return jsonify({ "match": False })

@app.route("/health")
def health():
    return {"status": "ok"}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)