#!/bin/bash

date_var=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(basename "$0")
LOGFILE="/tmp/${SCRIPT_NAME}-${date_var}.log"

# Define color codes for output
R="\e[31m"  # Red (Failure)
G="\e[32m"  # Green (Success)
Y="\e[33m"  # Yellow (Info)
N="\e[0m"   # Reset color

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${R}Error: Please run this script with sudo or as root.${N}"
    exit 1
fi

# Validation function
VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 ..... ${R}Failed${N}" | tee -a "$LOGFILE"
        exit 1
    else
        echo -e "$2 ..... ${G}Successful${N}" | tee -a "$LOGFILE"
    fi
}

echo "Starting Docker installation at $(date)" | tee -a "$LOGFILE"

# 1. Update existing packages
yum update -y &>> "$LOGFILE"
VALIDATE $? "Updating packages"

# 2. Install required packages
yum install -y yum-utils device-mapper-persistent-data lvm2 &>> "$LOGFILE"
VALIDATE $? "Installing required packages"

# 3. Add Docker repository
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &>> "$LOGFILE"
VALIDATE $? "Adding Docker repo"

# 4. Install Docker Engine
yum install -y docker-ce docker-ce-cli containerd.io &>> "$LOGFILE"
VALIDATE $? "Installing Docker"

# 5. Start Docker service
systemctl start docker &>> "$LOGFILE"
VALIDATE $? "Starting Docker"

# 6. Enable Docker to start on boot
systemctl enable docker &>> "$LOGFILE"
VALIDATE $? "Enabling Docker"

# 7. Verify Docker is installed and running
echo "Verifying Docker version..." | tee -a "$LOGFILE"
docker --version

# 8. Run hello-world test container
docker run hello-world &>> "$LOGFILE"
VALIDATE $? "Running hello-world container"

# 9. Add user to docker group
usermod -aG docker $USER &>> "$LOGFILE"
VALIDATE $? "Adding user to docker group"

echo -e "${G}Docker installation completed successfully at $(date)${N}" | tee -a "$LOGFILE"