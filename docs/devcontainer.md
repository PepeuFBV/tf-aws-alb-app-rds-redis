# Devcontainer Usage

The project has a devcontainer configuration that allows you to set up a consistent development environment using Visual Studio Code and Docker. It'll handle all the dependencies and configurations needed to work on the project without having to install them directly on your local machine.

Start the project in a devcontainer by following these steps:

1. **Install Prerequisites**: Make sure you have [Docker](https://www.docker.com/get-started) and [Visual Studio Code](https://code.visualstudio.com/) installed on your machine. Additionally, install the [Remote - Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) for Visual Studio Code.

2. **Open the Project in VS Code**: Open the project folder in Visual Studio Code.

3. **Reopen in Container**: Click on the green bottom-left corner of VS Code and select "Reopen in Container". This will build the Docker container based on the configuration defined in the `.devcontainer` folder.

## Troubleshooting

If you encounter any issues while setting up the devcontainer, here are some common troubleshooting steps:

- Check Docker Status: Ensure that Docker is running on your machine. You can check this by running `docker info` in your terminal.

- Rebuild the Container: If you make changes to the devcontainer configuration, you may need to rebuild the container (or restart it). You can do this by clicking on the green bottom-left corner of VS Code and selecting "Rebuild Container".