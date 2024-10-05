source config.example 

mkdir -p /home/${USER}/.zcash-params
./fetch-params.sh

echo "MCL_VERSION=${mcl_version}" > .env
echo "USER_ID=$(id -u)" >> .env
echo "GROUP_ID=$(id -g)" >> .env

OUTPUT_FILE="docker-compose_t.yml"
VOLUME_TEMPLATE="templates/volume.template"
SERVICE_TEMPLATE="templates/docker-service.template"

# Function to check for duplicate values in an array
check_duplicates() {
    declare -A seen_names
    declare -A seen_ports
    for node_info in "${nodes[@]}"; do
        IFS=":" read -r node_name password ssh_port pubkey <<< "$node_info"
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
}
check_duplicates 

cp "$VOLUME_TEMPLATE" "$OUTPUT_FILE"
echo "sevices:" >> "$OUTPUT_FILE"

for node_info in "${nodes[@]}"; do
    cat "$SERVICE_TEMPLATE" >> "$OUTPUT_FILE"
    IFS=":" read -r node_name password ssh_port pubkey  <<< "$node_info"

    sed -i "s/{{ node.name }}/$node_name/g" "$OUTPUT_FILE"
    sed -i "s/{{ container.name }}/$node_name/g" "$OUTPUT_FILE"
    sed -i "s/{{ node.password }}/$password/g" "$OUTPUT_FILE"
    sed -i "s/{{ ssh_port }}/$ssh_port/g" "$OUTPUT_FILE"
    sed -i "s/{{ volume.name }}/$node_name/g" "$OUTPUT_FILE"
    sed -i "s/{{ node.pubkey }}/$pubkey/g" "$OUTPUT_FILE"

    mkdir -p chainfiles/$node_name
done
