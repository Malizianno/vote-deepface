---
title: Face Verification Service
emoji: 🛡️
colorFrom: blue
colorTo: indigo
sdk: docker
app_port: 7860

# vote-deepface

# test locally

On the first try please run all the steps in order, but for the second attempt, after the first was successful,
you can run only the steps which contain lines marked with "!".

1. install python3.9.13 with installer from https://www.python.org/downloads/release/python-3913/
2. make sure environment variable is set (PATH to /bin of python installation folder)
3. start environment:
	$! python -m venv faceenv
	$! .\faceenv\Scripts\activate
4. install deepface and other required packages:
	$ pip install tensorflow==2.11.0
	$ python.exe -m pip install --upgrade pip
	$ pip install deepface flask opencv-python
5. create service deepface_service.py
6. Fix: downgrade numpy to v1:
	$ pip uninstall numpy -y
	$ pip install numpy==1.24.4
7. run deepface:
	$! python deepface_service.py