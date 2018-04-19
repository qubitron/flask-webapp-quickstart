
## Prerequisites
To complete this tutorial:

- [Install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest)
- [Install Python 3](https://www.python.org/downloads/)
- [Install Docker Community Edition](https://www.docker.com/community-edition)

## Create app and run it locally

First create a virtual environment to capture the dependencies for your app, install flask, and save the list of dependencies to a requirements.txt file.

On Windows:
```
py -3 -m venv env
env\scripts\activate
pip install flask
pip freeze > requirements.txt
deactivate
```

On Linux/Unix/macOS:
```
python3 -m venv env
env/bin/activate
pip install flask
pip freeze > requirements.txt
deactivate
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
docker run --name flaskapp -p 5000:5000 flask-quickstart
```

Open a web browser, and navigate to the sample app at ```http://localhost:5000.```

You can see the Hello World message from the sample app displayed in the page.

![Flask app running locally](https://docs.microsoft.com/en-us/azure/app-service/media/app-service-web-get-started-python/localhost-hello-world-in-browser.png)

In your terminal window, press Ctrl+C to exit the web server and type the following to stop and remove the container:
```
docker rm -f flaskapp
```

If you make code changes you can run the build and run commands above to update the container.

## Deploy the container to Azure

Create the resource group:
```
az group create --name MyFlaskApp --location "West US"
```

Create a container registry:
```
az acr create --name <registry_name> --resource-group MyFlaskApp --location "West US" --sku Basic
az acr update --name <registry_name> --admin-enabled true
az acr credential show -n <registry_name>
```

You see two passwords. Make note of the user name and the first password.
```JSON
{
  "passwords": [
    {
      "name": "password",
      "value": "<registry_password>"
    },
    {
      "name": "password2",
      "value": "<registry_password2>"
    }
  ],
  "username": "<registry_name>"
}
```

Log in to your registry. When prompted, supply the password you retrieved.
```bash
docker login <registry_name>.azurecr.io -u <registry_name>
```

Push your container to the registry:
```
docker tag flask-quickstart <registry_name>.azurecr.io/flask-quickstart
docker push <registry_name>.azurecr.io/flask-quickstart
```

Create the app service plan:
```
az appservice plan create --name MyFlaskAppPlan --resource-group MyFlaskApp --sku B1 --is-linux
```

Create the web app:
```
az webapp create --name <app_name> --resource-group MyFlaskApp --plan MyFlaskAppPlan --deployment-container-image-name "<registry_name>.azurecr.io/flask-quickstart"
```

Browse to the web app:
```
http://<app_name>.azurewebsites.net 
```