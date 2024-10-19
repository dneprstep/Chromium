#!/bin/bash

# Prompt user to continue or abort the installation
read -p "Chromium Docker will be installed. Y/N " CONFIRM

# Convert user input to uppercase and check if it's Y or N
CONFIRM=$(echo "$CONFIRM" | tr '[:lower:]' '[:upper:]')

if [[ "$CONFIRM" != "Y" ]]; then
  echo "Installation aborted."
  exit 0  # Exit the script
fi

# Define the folder path
FOLDER_PATH=~/chromium

# Check if the directory already exists
if [ -d "$FOLDER_PATH" ]; then
  echo "The folder '$FOLDER_PATH' already exists. Exiting script."
  exit 1  # Exit the script
fi

# Create the folder if it doesn't exist
mkdir -p "$FOLDER_PATH"
cd "$FOLDER_PATH"
echo "Folder '$FOLDER_PATH' created"

# Path to your docker-compose.yaml file
FILE_PATH="docker-compose.yaml"

# Prompt user for username, password, and ports
read -p "Enter chromium username: " CUSTOM_USER
read -sp "Enter password: " PASSWORD
echo  # Adds a new line after password input

# Prompt user for ports with default values if no input is provided
read -p "Enter http port (default 3010): " PORT1
PORT1=${PORT1:-3010}  # Default to 3010 if empty

read -p "Enter https port (default 3011): " PORT2
PORT2=${PORT2:-3011}  # Default to 3011 if empty

# Get the TZ value from the environment or use a default value if not set
TZ=${TZ:-"UTC"}  # Default to UTC if TZ is not set

# Write the content into the file
cat > $FILE_PATH <<EOF
---
services:
  chromium:
    image: lscr.io/linuxserver/chromium:latest
    container_name: chromium
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - CUSTOM_USER=${CUSTOM_USER}
      - PASSWORD=${PASSWORD}
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
      - CHROME_CLI=https://github.com/dneprstep #optional
    volumes:
      - /root/chromium/config:/config
    ports:
      - ${PORT1}:3000
      - ${PORT2}:3001
    shm_size: "1gb"
    restart: unless-stopped
EOF

# Prompt user to continue or abort the installation
read -p "Run Chromium docker? Y/N " RUN

# Convert user input to uppercase and check if it's Y or N
RUN=$(echo "$RUN" | tr '[:lower:]' '[:upper:]')

if [[ "$RUN" == "Y" ]]; then
  echo Running docker...""
  docker compose up -d
fi

# Get the system's IP address (grabbing the first one if multiple are present)
IP_ADDRESS=$(hostname -I | awk '{print $1}')

echo "'$FOLDER_PATH'/docker-compose.yaml has been written with TZ=$TZ, ports $PORT1:3000 and $PORT2:3001."
echo "To run docker manually go to '$FOLDER_PATH' and run docker compose up -d"
echo "Go to ${IP_ADDRESS}:${PORT1} to access Chromium."
