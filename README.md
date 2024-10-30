# MCLDocker

This repository provides an automated Docker setup for managing multiple MCL (Marmara Chain Layer) nodes using Docker Compose. It includes all the necessary configurations, wrapper scripts, and setup steps to quickly get your MCL nodes up and running. Additionally, the setup supports SSH connections for accessing the nodes.

## Prerequisites

Before using this setup, ensure that you have the following installed on your machine:

- [Docker](https://docs.docker.com/engine/install/ubuntu/) / [manage as a nonroot user](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user): Ensure Docker is installed and set up to allow management without root privileges (non-root user).
- [Docker Compose](https://docs.docker.com/compose/install/linux/#install-using-the-repository): Install Docker Compose for managing multi-container applications.

For users preferring the legacy Docker Compose version, you can install it with:
```bash
sudo apt install docker-compose
```

## Setup Instructions

### 1. Clone the Repository

Clone the repository to your local machine:

```bash
git clone https://github.com/Aklix/mcldocker
cd mcldocker
```

### 2. Configure the Environment

Copy the example configuration file and make the necessary changes:

```bash
cp config.example config
```

Open the `config` file in a text editor and customize the following values according to your environment:

- **Node names**
- **SSH User**
- **Password**
- **Ports**
- **Volumes**

Make sure to adjust the settings as per your setup requirements.

### 3. Run Setup Script

Once the configuration is done, run the `setup.sh` script to build the Docker images and prepare the necessary containers:

```bash
./setup.sh
```

- Every time you make changes to the `config` file, rerun the `setup.sh` script to apply the updates.

### 4. Launch the Containers

Once the setup is complete, you can launch your MCL nodes using Docker Compose:

```bash
docker compose up -d
```

This will start all the containers defined in your `docker-compose.yml` file in detached mode.

### 5. Accessing the Containers

To access any container, you can use the `cli-wrappers` that are automatically created for each service. These are simple wrapper scripts that make it easy to execute commands inside the containers.

For example, to access `mcl_node1`, run:

```bash
./cli-wrappers/mcl_node1-cli getinfo
```

This will run the `getinfo` command in the `mcl_node1` container as the defined SSH user.

Each service has its own wrapper, so you can interact with different containers using their respective `cli-wrapper` scripts. 

### 6. Accessing the Containers with SSH

Once the MCL nodes are running, you can connect to each container via SSH using the following command format:

```bash
ssh <ssh_user>@<container_ip> -p <ssh_port>
```

- **ssh_user**: The SSH user defined in the configuration.
- **container_ip**: The IP address of the container (can be obtained via `docker inspect <container_name>`).
- **ssh_port**: The port exposed in the Docker Compose file (for example, `2201` for `mcl_node1`).


### 7. Making Changes to Configuration

Whenever you make changes to the `config` file, you need to rerun the `setup.sh` script and then restart your containers using:

```bash
docker compose down
docker compose up -d
```

## Repository Structure

- `config.example`: Example configuration file for setting up your nodes.
- `config`: Your own custom configuration file, copied from `config.example`.
- `setup.sh`: Script to build Docker images and prepare the environment.
- `docker-compose.yml`: Docker Compose configuration to manage containers.
- `docker-compose.mclbuild`: Build configuration for creating the Docker images.
- `cli-wrappers/`: Directory containing wrapper scripts for interacting with the containers.

## Healt check scripts
The health check script is a Python program that monitors container status. It verifies block synchronization and enables staking when blocks are synced. It also checks block validity through the explorer API, disabling staking if the chain forks and waiting for synchronization. If syncing fails, it will restart the chain.

- **Start the health check**: Run `./start_health_check`, which runs in the background.
- **Stop the health check**: Run `./stop_health_check` to terminate the health check process.
- **Output log**: The health check log can be found in `health_check.log`.

## Troubleshooting

- If you face any issues with building the Docker images, make sure the configuration in the `config` file is correct and all environment variables are properly set.
- To inspect logs of a specific container, you can use:

```bash
docker logs <container_name>
```

For example, to view logs for `mcl_node1`:

```bash
docker logs mcl_node1
```

The prerequisites section is clear, but a couple of minor adjustments could make it even more user-friendly. Here's a suggested revision:

---

**Prerequisites**

Before using this setup, make sure your system meets the following requirements:

- **Docker**: Ensure Docker is installed and set up to allow management without root privileges (non-root user).
- **Docker Compose**: Install Docker Compose for managing multi-container applications. 

For users preferring the legacy Docker Compose version, you can install it with:
```bash
sudo apt install docker-compose
```

---

This clarifies the setup process slightly and specifies what "non-root user" means in the context of Docker. You can find more suggestions by reviewing the full README for flow and clarity. 