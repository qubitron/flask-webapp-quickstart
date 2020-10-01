Important links to understand few basic concepts:
https://azure.microsoft.com/en-in/overview/what-is-azure/
https://opensource.com/resources/what-docker
https://flask.palletsprojects.com/en/1.1.x/



This tutorial shows you how to create and deploy a Flask web app in an Alpine Linux + NGINX Docker container to Azure Web Apps for Containers using the Azure CLI.

See [VSCODE.md](VSCODE.md) for using Visual Studio Code and the Azure Portal instead.

## Prerequisites
To complete this tutorial:

- [Install Python 3](https://www.python.org/downloads/)
- [Install Docker Community Edition](https://www.docker.com/community-edition)
- (Optional) [Install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Create app and run it locally

First create a root folder, name it e.g. ```flask-quickstart``` and create a single ```app``` folder inside the root folder. Now let's write our app, copy and paste the following code into ```app/main.py```:

```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
  return 'Hello, World!'

if __name__ == '__main__':
  app.run()
```

Now let's create a dockerfile for the app, we'll use an Alpine Linux container with an NGINX web server. Put the following in a file named `Dockerfile` inside of the ```flask-quickstart``` folder:

```Dockerfile
FROM tiangolo/uwsgi-nginx-flask:python3.6-alpine3.7

ENV LISTEN_PORT=8000
EXPOSE 8000

COPY /app /app
```

Now build and run the docker container:
```
docker build --rm -t flask-quickstart .
docker run --rm -it -p 8000:8000 flask-quickstart
```

Open a web browser, and navigate to the sample app at ```http://localhost:8000```.

You can see the Hello World message from the sample app displayed in the page.

![Flask app running locally](https://docs.microsoft.com/en-us/azure/app-service/media/app-service-web-get-started-python/localhost-hello-world-in-browser.png)

In your terminal window, press Ctrl+C to exit the web server and stop the container.

If you make code changes you can re-run the docker build and run commands above to update the container.

## Deploy the container to Azure

For this portion of the tutorial you will need the Azure CLI. Either install it locally, or you can run commands in the browser by navigating to the [Azure Cloud Shell](https://shell.azure.com/bash). As you are running the commands below, you can view the resources being created in the Azure portal by navigating to [portal.azure.com](https://portal.azure.com).

Create a resource group:
```
az group create --name FlaskApp --location "West US"
```

Create a container registry and retrieve the password, note that `<registry_name>` needs to be a unique name: 
```
az acr create --name <registry_name> --resource-group FlaskApp --location "West US" --sku Basic --admin-enabled true
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

Log in to your registry. When prompted, supply the username and password shown above.
```bash
docker login <registry_name>.azurecr.io -u <registry_name>
```

Tag your container and push it to the registry:
```
docker tag flask-quickstart <registry_name>.azurecr.io/flask-quickstart
docker push <registry_name>.azurecr.io/flask-quickstart
```

Create the app service plan:
```
az appservice plan create --name FlaskAppPlan --resource-group FlaskApp --sku B1 --is-linux
```

Create the web app:
```
az webapp create --name <app_name> --resource-group FlaskApp --plan FlaskAppPlan --deployment-container-image-name "<registry_name>.azurecr.io/flask-quickstart"
```

Configure it to pull from the registry:
```
az webapp config container set --name <app_name> --resource-group FlaskApp --docker-custom-image-name <registry_name>.azurecr.io/flask-quickstart --docker-registry-server-url https://<registry_name>.azurecr.io --docker-registry-server-user <registry_name> --docker-registry-server-password <registry_password>
```

Run the following command to set the port number on the site and restart it:
```
az webapp config appsettings set --name <app name> --resource-group FlaskApp --settings  WEBSITES_PORT=8000
az webapp restart --name <app name> --resource-group FlaskApp
```

Browse to the web app at ```http://<app_name>.azurewebsites.net```

## Install additional libraries

To install additional libraries, first create a virtual environment locally, install packages and then generate a requirements.txt file.

On Windows:
```
py -3 -m venv env
env\scripts\activate
pip install flask <list of other libraries>
pip freeze > requirements.txt
deactivate
```

On Linux/Unix/macOS:
```
python3 -m venv env
env/bin/activate
pip install flask <list of other libraries>
pip freeze > requirements.txt
deactivate
```

Add the following code to the dockerfile so that the additional requirements are installed:
```
# Install additional requirements from a requirements.txt file
COPY requirements.txt /
RUN pip install --no-cache-dir -U pip
RUN pip install --no-cache-dir -r /requirements.txt
```

## Clean up

To clean up your Azure resources, delete the resource group
```az group delete --name FlaskApp```
