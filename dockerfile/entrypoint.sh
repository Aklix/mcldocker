#!/bin/bash

# Check if all required environment variables are provided
if [ -z "$USER_ID" ] || [ -z "$GROUP_ID" ] || [ -z "$sshUSER" ] || [ -z "$PW" ]; then
    echo "Error: USER_ID, GROUP_ID, sshUSER, and PW environment variables must be provided."
    exit 1
fi

# Create a new group if it doesn't exist
if ! getent group usergroup >/dev/null; then
    groupadd -g "$GROUP_ID" usergroup
    echo "Created group 'usergroup' with GID: $GROUP_ID"
fi

# Create the user and set password if necessary
if [ -n "${PW}" ] && [ -n "${sshUSER}" ]; then
    echo "Creating user ${sshUSER} with password ${PW}"
    useradd -m -s /bin/bash ${sshUSER} 
    echo "Password for user ${sshUSER} updated."
fi

echo "${sshUSER}:${PW}" | chpasswd

# Create symbolic links to the Marmara binaries in the user's home directory
if [ ! -L "/home/$sshUSER/marmarad" ]; then
    ln -s /usr/local/bin/marmarad /home/$sshUSER/marmarad
    echo "Created symbolic link for marmarad in /home/$sshUSER/"
fi

if [ ! -L "/home/$sshUSER/marmara-cli" ]; then
    ln -s /usr/local/bin/marmara-cli /home/$sshUSER/marmara-cli
    echo "Created symbolic link for marmara-cli in /home/$sshUSER/"
fi

# Set ownership for the user's home directory
chown -R ${sshUSER}:${sshUSER} /home/${sshUSER}

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

echo Switching to ${sshUSER} for execute the command
exec gosu ${sshUSER} "$@"
