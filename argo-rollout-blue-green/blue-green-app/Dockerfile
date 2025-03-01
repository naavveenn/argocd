FROM python:3.8-slim-buster
WORKDIR /blue-green
ENV FLASK_APP script.py
COPY requirements.txt . 
RUN pip3 install -r requirements.txt
COPY script.py .
COPY templates ./templates
CMD ["flask", "run", "--host=0.0.0.0"]
