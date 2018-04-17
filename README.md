
## Prerequisites
To complete this tutorial:

- Install Git
- Install Python

## Create app and run it locally

First create a virtual environment to capture the dependencies for your app, install flask, and save the list of dependencies to a requirements.txt file.

On windows:
```
py -3 -m venv env
env\scripts\activate
pip install flask
pip freeze > requirements.txt
```

On Linux/Unix/macOS:
```
python3 -m venv env
env/bin/activate
pip install flask
pip freeze > requirements.txt
```

Now let's write our app paste the following code into app.py:

```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
  return 'Hello, World!'

if __name__ == '__main__':
  app.run()
```

Now let's create a dockerfile for the app, we'll use an alpine linux container with an nginx web server.

```Dockerfile
FROM nginx:alpine

COPY requirements.txt /

RUN apk add --update python3 \
  && python3 -m pip install -r requirements.txt \
  && rm -rf /var/cache/apk/*

COPY app/ /app/
WORKDIR /app

ENV FLASK_APP=app.py
CMD flask run -h 0.0.0.0 -p 5000
```

Now build and run the docker container:
```
docker build -t flask-quickstart .
docker run -p 5000:5000 flask-quickstart
```

Open a web browser, and navigate to the sample app at ```http://localhost:5000.```

You can see the Hello World message from the sample app displayed in the page.



In your terminal window, press Ctrl+C to exit the web server.