set -e

source config
if [ ! -f config ]; then
    echo "Error: config file not found!"
    echo "Use command 'cp config.example config' then proceed"
    exit 1
fi 
echo "Loaded configuration from config file."

echo "Running fetch-params.sh script..."
mkdir -p /home/${USER}/.zcash-params
./fetch-params.sh

echo "Generating .env file with MCL version and user details..."
echo "MCL_VERSION=${mcl_version}" > .env
echo "USER=${USER}" >> .env
echo "USER_ID=$(id -u)" >> .env
echo "GROUP_ID=$(id -g)" >> .env
#echo ".env file created."

echo "building mclbuilder for mc-${mcl_version}"
docker-compose -f docker-compose.mclbuild build

OUTPUT_FILE="docker-compose.yml"
SERVICE_TEMPLATE="templates/docker-service.template"

# Function to check for duplicate values in an array
check_duplicates() {
    echo "Checking for duplicate node names and SSH ports..."
    declare -A seen_names
    declare -A seen_ports
    for node_info in "${nodes[@]}"; do
        IFS=":" read -r node_name ssh_user ssh_pw ssh_port pubkey <<< "$node_info"
        # Check for duplicate node names
        if [[ -n "${seen_names[$node_name]}" ]]; then
            echo "Error: Duplicate node name '$node_name' found."
            exit 1
        fi
        seen_names[$node_name]=1  # Mark the node name as seen
        # Check for duplicate SSH ports
        if [[ -n "${seen_ports[$ssh_port]}" ]]; then
            echo "Error: Duplicate SSH port '$ssh_port' found."
            exit 1
        fi
        seen_ports[$ssh_port]=1  # Mark the SSH port as seen
    done
    echo "No duplicates found. Proceeding..."
}
check_duplicates

if [ -f "$OUTPUT_FILE" ]; then
    echo "Backing up existing docker-compose.yml to docker-compose.yml.bak"
    mv "$OUTPUT_FILE" "${OUTPUT_FILE}.bak"
fi

echo "Removing old CLI wrapper files..."
rm -f cli-wrappers/*-cli

echo "Starting to create docker compose file from template files ..."
echo "version: '3.7'" >> "$OUTPUT_FILE"
echo "services:" >> "$OUTPUT_FILE"

for node_info in "${nodes[@]}"; do
    cat "$SERVICE_TEMPLATE" >> "$OUTPUT_FILE"
    IFS=":" read -r node_name ssh_user ssh_pw ssh_port pubkey  <<< "$node_info"

    ssh_user_var=$node_name"_ssh_user"
    ssh_pw_var=$node_name"_ssh_pw"
    echo "$ssh_user_var=$ssh_user" >> .env
    echo "$ssh_pw_var=$ssh_pw" >> .env

    sed -i -e "s/{{ node.name }}/$node_name/g" \
           -e "s/{{ container.name }}/$node_name/g" \
           -e "s/{{ ssh_user }}/\${$ssh_user_var}/g" \
           -e "s/{{ ssh_pw }}/\${$ssh_pw_var}/g" \
           -e "s/{{ ssh_port }}/$ssh_port/g" \
           -e "s/{{ container.user }}/\${$ssh_user_var}/g" \
           -e "s/{{ volume.name }}/$node_name/g" \
           -e "s/{{ volume.user }}/\${$ssh_user_var}/g" \
           -e "s/{{ node.pubkey }}/$pubkey/g" "$OUTPUT_FILE"


    echo "Creating directory chainfiles/$node_name..."
    mkdir -p chainfiles/$node_name
    echo "Creating cli-wrappers/$node_name"-cli""
    echo "#!/bin/bash" > cli-wrappers/$node_name"-cli"
    echo "docker exec --user $ssh_user $node_name marmara-cli \"\$@\"" >> cli-wrappers/$node_name"-cli"
    chmod +x cli-wrappers/$node_name"-cli"
done

echo "Docker Compose file generation complete. All steps finished successfully."