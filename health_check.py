import json
import os
import subprocess
import signal
import requests
import time
import logging
from logging.handlers import RotatingFileHandler

LOG_FILE = 'health_check.log'
# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[
        RotatingFileHandler(LOG_FILE, maxBytes=5*1024*1024, backupCount=2),  # 5 MB per file, keep 2 backups
        logging.StreamHandler()  # Also outputs to console
    ]
)

CLI_WRAPPERS_DIR = 'cli-wrappers'

def get_cli_wrappers():
    cli_files = []
    for file in os.listdir(CLI_WRAPPERS_DIR):
        if file.endswith('-cli') and os.path.isfile(os.path.join(CLI_WRAPPERS_DIR, file)):
            cli_files.append(os.path.join(CLI_WRAPPERS_DIR, file))
    return cli_files

def node_rpc(cli, args, timeout=180):
    cmd = [cli] + args  # Combine the cli and the list of arguments
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True, timeout=timeout)
        return 1, result.stdout  # Return 1 and the result on success
    except subprocess.CalledProcessError as e:
        error_output = e.stderr
        return -1, error_output  # Return -1 and the error message on failure
    except Exception as e:
        return -1, str(e)  # Return -1 on general error with exception message

exp_api_urls = ["https://explorer.marmara.io/insight-api-komodo/",
                "https://explorer2.marmara.io/insight-api-komodo/",
                "https://explorer3.marmara.io/insight-api-komodo/"]

def api_response(url, timeout):
    try:
        response = requests.get(url, timeout=timeout)
        if response.status_code == 200:
            return response.json()
        else:
            return False
    except Exception as e:
       return e

def exp_api_forkcheck(api_url_args, timeout=30):
    exp_sync_count = 0
    reach_count = len(exp_api_urls)
    for api in exp_api_urls:
        api_url = api + api_url_args
        api_result = api_response(api_url, timeout)
        if isinstance(api_result, dict):
            if api_result.get('isMainChain'):
                exp_sync_count += 1
        else:
            reach_count -= 1
    if reach_count == 0:
        logging.warning(f"could not reach any of explorer api")
        return -1
    else:
        return exp_sync_count

def check_fork(cli, blocks, conneciton):
    status, block_hash = node_rpc(cli, ["getblockhash", str(blocks-1)])
    if status == 1:
        exp_sync_status = exp_api_forkcheck(f'block/{block_hash.strip()}')
        return exp_sync_status
    else:
        return -1
     
def check_staking(cli, is_forked, synced):
    staking_status, result = node_rpc(cli, ["getgenerate"])
    if staking_status == 1:
        staking = json.loads(result).get('staking')
        if not synced and staking:
            logging.warning("closing staking node is not synced..")
            node_rpc(cli, ["setgenerate", "false"])
        elif is_forked == 0:
            logging.warning("possible fork take action to fix. Taking necessary actions...")
            if staking:
                logging.warning("Disabling staking due to potential fork..")
                node_rpc(cli, ["setgenerate", "false"])
            else:
                logging.warning(f"Stopping {cli} due to potential fork..")
                node_rpc(cli, ["stop"])
        elif is_forked > 0:
            if not staking and synced:
                logging.info("Staking is currently disabled. Enabling staking...")
                node_rpc(cli, ["setgenerate", "true", "0"])
            logging.info("Health check completed: everything is OK.")
        elif is_forked == -1:
           logging.warning("is_forked is -1, cannot determine fork status.")
    else:
        logging.error("cannot determine staking status. {result}")
   

def monitor_nodes():
    clies = get_cli_wrappers()
    if not clies:
        logging.error("No clie found. Exiting.")
        handle_signal(None,None)
        return
    for cli in clies:
        status, result = node_rpc(cli, ["getinfo"])
        if status == 1:
            info = json.loads(result)
            blocks = info.get('blocks')
            connection = info.get('connections')
            synced = info.get('synced')
            errors = info.get('errors')
            
            is_forked = check_fork(cli, blocks, connection)
            check_staking(cli, is_forked, synced)                           
            if errors:
                logging.error(f"{cli} has errors: {errors}")
        else:
            if "Error response from daemon" in result:
                logging.error(f"Docker container is not running for {cli}.")
            else:
                logging.error(f"{cli} has {result}")

def read_config():
    interval_minutes = 35  # Default value
    try:
        with open('config', 'r') as config:
            for line in config:
                if 'healt_check_interval' in line:
                    interval_minutes = int(line.split('=')[1].strip())
    except FileNotFoundError:
        logging.warning("Config file not found, using default interval of 35 minutes.")
    return interval_minutes

keep_running = True
def handle_signal(sig, frame):
    global keep_running
    logging.info("Received termination signal. Exiting gracefully...")
    keep_running = False
    os._exit(0)

if __name__ == "__main__":
    signal.signal(signal.SIGINT, handle_signal)
    signal.signal(signal.SIGTERM, handle_signal)
    last_interval = read_config()  # Store the last known interva
    while keep_running:
        monitor_nodes()

        interval_minutes = read_config()
        if interval_minutes != last_interval:
            logging.info(f"Monitoring interval changed to {interval_minutes} minutes.")
            last_interval = interval_minutes  # Update last known interval

        time.sleep(interval_minutes * 60)
