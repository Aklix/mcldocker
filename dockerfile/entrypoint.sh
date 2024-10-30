#!/bin/bash

# Ensure all required environment variables are provided
if [ -z "$USER_ID" ] || [ -z "$GROUP_ID" ] || [ -z "$sshUSER" ] || [ -z "$PW" ]; then
    echo "Error: USER_ID, GROUP_ID, sshUSER, and PW environment variables must be provided."
    exit 1
fi

# Create a new group with the specified GROUP_ID if it doesn't exist
if ! getent group "$GROUP_ID" >/dev/null; then
    groupadd -g "$GROUP_ID" usergroup
    echo "Created group 'usergroup' with GID: $GROUP_ID"
fi

# Create the user with specified USER_ID and GROUP_ID if they don't already exist
if ! id -u "$sshUSER" >/dev/null 2>&1; then
    echo "Creating user ${sshUSER} with UID: ${USER_ID}, GID: ${GROUP_ID}"
    useradd -u "$USER_ID" -g "$GROUP_ID" -m -s /bin/bash ${sshUSER}
else
    echo "User ${sshUSER} already exist. Skipping creation"
fi

if [ -n "${PW}" ]; then
    echo "${sshUSER}:${PW}" | chpasswd
    echo "Pasword for user ${sshUSER} updated."
fi

# Create symbolic links to Marmara binaries in the user's home directory if they don't exist
if [ ! -L "/home/$sshUSER/marmarad" ]; then
    ln -s /usr/local/bin/marmarad /home/$sshUSER/marmarad
    echo "Created symbolic link for marmarad in /home/$sshUSER/"
fi

if [ ! -L "/home/$sshUSER/marmara-cli" ]; then
    ln -s /usr/local/bin/marmara-cli /home/$sshUSER/marmara-cli
    echo "Created symbolic link for marmara-cli in /home/$sshUSER/"
fi

# Set ownership for the user's home directory
chown -R ${USER_ID}:${GROUP_ID} /home/${sshUSER}

# Generate SSH host keys if they don't exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    echo "Generating new SSH host keys..."
    ssh-keygen -A
fi

# Disable root login and allow only the specified user
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "AllowUsers ${sshUSER}" >> /etc/ssh/sshd_config

# Start SSH daemon in the background
echo "Starting SSH daemon..."
/usr/sbin/sshd -D &

# Switch to the specified user to execute the command
echo "Switching to ${sshUSER} to execute the command"
exec gosu ${sshUSER} "$@"
