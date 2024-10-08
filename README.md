# MCLDocker Build from Source

This repository provides scripts and Docker setup to build Marmara (MCL) from source. This setup includes Dockerfiles for both Linux and Windows environments. The `buildmcl` branch automates building Marmara from source using Docker, simplifying the process of creating Marmara binaries for your system.

## Prerequisites

Before using this setup, ensure you have the following installed:

- [Docker](https://docs.docker.com/engine/install/ubuntu/) / [Docker Convenience Script](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script)
- [Docker Compose](https://docs.docker.com/compose/install/)

Additionally, you may need to install Docker Compose with:

```bash
sudo apt install docker-compose
```

## Build Setup

### 1. Clone the Repository

Clone the repository to your local machine:

```bash
git clone https://github.com/Aklix/mcldocker
cd mcldocker
git checkout buildmcl
```

### 2. Build Marmara from Source

#### Linux Build

For building Marmara on a **Linux** environment, run the following:

```bash
./build.sh
```

This will trigger Docker Compose to build Marmara from source inside a Linux container. The build process will pull the Marmara repository from GitHub and compile the necessary binaries.

Once the build is successful, it will copy the `marmarad` and `marmara-cli` binaries into the `volumes` directory for easy access.

#### Windows Build

For building Marmara on a **Windows** environment, run:

```bash
./build-win.sh
```

This triggers Docker Compose to build Marmara from source inside a Windows container. The resulting binaries (`marmarad.exe` and `marmara-cli.exe`) will be copied into the `volumes` directory.

### 3. Docker Compose Configuration

The Docker Compose configuration (`docker-compose.yml`) defines two services:

- **build-mcl-linux**: A Linux-based container that builds Marmara using the provided `Dockerfile.mcl-build`.
- **build-mcl-win**: A Windows-based container that builds Marmara using the `Dockerfile.mcl-build-win`.

Each service pulls the Marmara source code from the GitHub repository, checks out the `development` branch, and builds the necessary binaries using the respective build script (`build.sh` for Linux and `build-win.sh` for Windows).

### 4. Accessing Built Binaries

After a successful build, the Marmara binaries (`marmarad` and `marmara-cli`) will be copied into the `volumes` directory:

- **For Linux**: `volumes/mcl-linux/marmara/src/marmarad` and `marmara-cli`.
- **For Windows**: `volumes/mcl-win/marmara/src/marmarad.exe` and `marmara-cli.exe`.

These binaries can be used as needed for deploying MCL nodes.

### 5. Cleaning Up

If you wish to clean up your build environment, you can remove the Docker containers and images:

```bash
docker-compose down --volumes --rmi all
```

### 6. Troubleshooting

- **Build errors**: Ensure the environment variables (like `repourl` and `branch`) in the Docker Compose file are correct. Also, verify Docker has sufficient resources.
- **Container permissions**: Make sure Docker has the necessary permissions to write to the `volumes` directory.
