This file contains instructions for deploying this web app using VS Code instead of the command line tools.

## Prerequisites
To complete this tutorial:

- [Install Python 3](https://www.python.org/downloads/)
- [Install Docker Community Edition](https://www.docker.com/community-edition)
- [Git Command Line](https://git-scm.com/downloads)
- [Visual Studio Code](https://code.visualstudio.com/)

To run commands in Visual Studio code, press `Ctrl-Shift-P` on Windows/Linux or `Command-Shift-P` on macOS.

## Clone the repo and install packages

Clone the repository:
```
git clone https://github.com/qubitron/flask-webapp-quickstart
cd flask-webapp-quickstart
```

Now create the virtual environment and install required packages.

On Windows:
```
py -3 -m venv env
```

On Linux/macOS:
```
python3 -m venv env
```

## Set up Visual Studio Code

From the extensions tab of VS Code, install the following extensions:
 - Python
 - Docker
 - Azure Account
 - Azure App Service

Reload Visual Studio Code once all extensions are installed, you can click the `Reload` button on one of the extensions, or use the `Reload Window` command.

After reloading run the `Azure: Sign In` command, and follow the instructions to sign into your Azure subscription.

Select **File > Open Folder**, and navigate to the `flask-webapp-quickstart` folder.

Use the `Python: Select Interpreter` command, and select the `.\env` virtual environment from the list.

## Install Packages and Run App

Use the `Python: Create Terminal` command, in the terminal run the following command to install required packages:
```
pip install -r requirements.txt
```

In the file explorer expand the `app` node and single-click on `main.py`. Now let's run this file by running the `Python: Run File in Terminal` command.

Browse to `localhost:5000` to see the app working locally.

## Create Azure Resource Group and Container Registry

From the Azure portal, click **Create a resource** in the upper left hand corner. Search for and click on "Container Registry", and then click Create.

Pick a name for the container registry and the resource group, set **Admin user** to **Enable**.

After the registry is created, navigate to it in the portal and then select  **Access keys** menu in the container registry menu. We will need the access key in the next section.

## Build and Push Docker Image

From the terminal in VS Code, type ```docker login <registry_name>.azurecr.io```. Press enter to use the default user name, and then copy the password from the Access keys page for the container registry and use `Ctrl-V` to paste the password in the terminal.

Run the `Docker: Build Image` command. Select the default Dockerfile, and name the image `<registry_name>.azurecr.io/flask-webapp-quickstart:latest`.

After the build completes, navigate to the Docker group in the Explorer. Expand the images node, right-click on the image you just built and select **Push**.

## Create Azure Webapp from Container

In the Docker group in the Explorer, expand the Registries node, expand your registry, expand the image, and then right-click on the image with the latest tag and select `Deploy Image to Azure App Service`.

From the set of menus that appear, enter:
 - Resource group: the resource group greated above
 - Plan name: create a new plan, and pick a name for it
 - Type: select a pricing tier, use `B1` for the cheapest option
 - Site name: pick a unique site name to use

After the site finishes creating, navigate to the **Azure App Service** group in the Explorer, expand your subscription and the site that just created. If your site is not shown, you might need to right-click on your subscription and select **Refresh**.

Right-click on the **Application Settings** group and select **Add New Setting...**. In the first prompt for the setting name enter `WEBSITES_PORT`, and for the second prompt set the value to `8000`.

Right-click on the web site and select **Refresh**, then right-click and select **Browse Web Site**.

Your browser should open and browse to the site, it may take a minute for the site to load the first time because the Docker container is being downloaded. Subsequent deploys to the same App Service plan will be faster because the base image is saved on the plan.