#!/bin/bash
sudo apt-get update -y
sudo snap install docker

sudo mkdir /home/ubuntu/proj/
sudo mkdir /home/ubuntu/proj/app/

echo "from flask import Flask
app = Flask(__name__)
@app.route('/')
def hello_world():
    return \"Hello, World!\"
app.run(host='0.0.0.0', port=5000)" > /home/ubuntu/proj/app/index.py

echo "FROM python:3.8.0-alpine
WORKDIR /application
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY /app .
CMD [\"python\", \"index.py\"]" > /home/ubuntu/proj/Dockerfile

echo "Flask==1.1.1" > /home/ubuntu/proj/requirements.txt

echo "#!/bin/bash
sudo docker build /home/ubuntu/proj/ -t test
sudo docker run -p 80:5000 -d test:latest" > /home/ubuntu/scr.sh

sudo sleep 2m
chmod +x /home/ubuntu/scr.sh
sudo /home/ubuntu/scr.sh
