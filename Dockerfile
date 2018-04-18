FROM nginx:alpine

COPY requirements.txt /

RUN apk add --update python3 \
  && python3 -m pip install --no-cache-dir -r requirements.txt \
  && rm -rf /var/cache/apk/* 

COPY app/ /app/
WORKDIR /app

ENV FLASK_APP=app.py
CMD flask run -h 0.0.0.0 -p 5000
