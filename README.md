# MCLDocker

This repository provides an automated Docker setup for managing multiple MCL (Marmara Chain Layer) nodes using Docker Compose. The setup includes all necessary configurations, wrapper scripts, and setup steps to quickly get your MCL nodes running. Additionally, it supports SSH connections for direct node access.

## Prerequisites

Before using this setup, ensure the following are installed on your machine:

- **Docker** ([installation guide](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository))  
  - Be sure to configure Docker to run without requiring root privileges by following [these instructions](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user).

> **Note**: Running the setup as the root user may cause permission issues. Instead, create a new user with sudo privileges:

```bash
sudo adduser <username>  # Create a new user
sudo passwd <username>   # Set a password for the new user
sudo usermod -aG sudo <username>  # Add the user to the sudo group
su - <username>  # Switch to the new user
```

### Configuring Docker with UFW Firewall

By default, Docker modifies iptables rules, which can bypass UFW. To ensure Docker respects UFW, follow these steps:

1. Open Docker’s configuration file:
   ```bash
   sudo nano /etc/default/docker
   ```

2. Add the following line to disable Docker's iptables changes, then save and exit:
   ```bash
   DOCKER_OPTS="--iptables=false"
   ```
3. Restart Docker to apply the change:
   ```bash
   sudo systemctl restart docker
   ```

### Install UFW (if not already installed) and Configure Ports

Install UFW, allowing SSH access before enabling the firewall:

```bash
sudo apt install ufw
sudo ufw allow OpenSSH comment 'SSH access'
sudo ufw allow 33824 comment 'MCL p2p'
sudo ufw enable
```

## Setup Instructions

### 1. Clone the Repository

Clone the repository to your local machine:

```bash
git clone https://github.com/Aklix/mcldocker
cd mcldocker
```

### 2. Configure the Environment

Copy the example configuration file and customize the values according to your setup:

```bash
cp config.example config
```

Open the `config` file in a text editor and customize the following values according to your setup:

- **Node names**: These names uniquely identify each MCL node container.
- **SSH User**: The SSH username used to access the container.
- **Password**: The password for the specified SSH user to access the container securely.
- **Ports**: Define the ports for each node to manage network connections.
- **Pubkey**: The public key for the chain, which is set automatically when the container starts
### 3. Run the Setup Script

After configuring `config`, run `setup.sh` to build Docker images and set up the containers:

```bash
./setup.sh
```

> **Note**: Anytime you make changes to `config`, rerun `setup.sh` to apply the updates.

### 4. Launch the Containers

Once setup is complete, start the MCL nodes with:

```bash
docker compose up -d
```

This command starts all containers defined in `docker-compose.yml` in detached mode.

### 5. Access the Containers

To interact with a container, use the `cli-wrappers` provided for each node. For example, to check the status of `mcl_node1`, run:

```bash
./cli-wrappers/mcl_node1-cli getinfo
```

Each node has its own CLI wrapper for convenient access.

### 6. SSH Access to Containers

Once the nodes are running, you can SSH into any container using:

```bash
ssh <ssh_user>@<container_ip> -p <ssh_port>
```

- **ssh_user**: SSH user from the configuration.
- **container_ip**: The IP address of the host machine (use 127.0.0.1 if connecting from within the host).
- **ssh_port**: The SSH port mapped to the container (e.g., 2201, 2202, etc., as defined in the configuration).

#### Ports Configuration for UFW

To allow remote SSH and node communication, the necessary ports need to be added to your firewall (UFW) configuration. Run the following command for each port:

```bash
sudo ufw allow <port_number> comment 'ssh for node_name'
```

Replace `<port_number>` with the specific ports defined in your configuration, such as the SSH ports (`2201`, `2202`, etc.)

### 7. Updating Node Configurations

Whenever you modify the `config` file, run `setup.sh` and restart the containers with:

```bash
docker compose down
docker compose up -d
```

To update specific nodes or all nodes based on configuration changes, use the `update_nodes` script:

- **To update all nodes**:
  ```bash
  ./update_nodes all
  ```

- **To update a specific node by ticker**:
  ```bash
  ./update_nodes <ticker>
  ```
  Example:
  ```bash
  ./update_nodes mcl_node1
  ```

## Repository Structure

- `config.example`: Example configuration file.
- `config`: Your customized configuration file.
- `setup.sh`: Script to build Docker images and set up the environment.
- `docker-compose.yml`: Docker Compose configuration for managing containers.
- `docker-compose.mclbuild`: Docker Compose configuration for building images.
- `cli-wrappers/`: Directory containing CLI wrapper scripts for container commands.

## Health Check Scripts

A health check Python script monitors container status, ensuring block synchronization and activating staking when blocks are synced. It also verifies block validity through the explorer API, disables staking if the chain forks, and restarts the chain if necessary.

- **Start the health check**: Run `./start_health_check`, which will operate in the background.
- **Stop the health check**: Run `./stop_health_check`.
- **View the log**: Check `health_check.log` for health check output.

## Troubleshooting

- **Configuration Issues**: Ensure the `config` file is correctly set up and that all required environment variables are in place.
- **Viewing Logs**: To view logs for a specific container, use:
  ```bash
  docker logs <container_name>
  ```
  Example:
  ```bash
  docker logs mcl_node1
  ```
