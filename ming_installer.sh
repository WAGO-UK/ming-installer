#!/bin/bash
#
# Title:   WAGO M.I.N.G stack installation script
# Version: V1.0
# Author:  Marcin Regulski
# Date:    23.07.2024
# 
# variables declaration
decision=""
declare -a options
DIR="$(pwd)"
daemonPath="/etc/docker/daemon.json"
#
function greetAndAsk() {
echo "Hello to M.I.N.G stack installer!"
sleep 1
#
echo "Before running this installer, make sure SD card is present and formatted."
read -p "Do you want to continue? [y/n]" decision
echo "$decision"
decision=$( echo "$decision" | tr '[:upper:]' '[:lower:]' )
case $decision in
"y"|"yes")
                ;;
"n"|"no")
                echo "Installation cancelled."
                exit ;;
*)
                echo "Invalid input; try again.";;
esac
}
#
function checkDockerDaemon() {
    echo "-> Checking path: $path for Docker Daemon..."
    [ -f "$daemonPath" ] && echo "Docker Daemon found!" || echo "Docker Daemon could not be found."
}
#
function moveDockerDirectory() {
    echo "-> moving Docker directory..."
    /etc/init.d/dockerd stop && echo "Done!" || { echo "Error occured. Try again."; exit; }
    cp -r /home/docker /media/sd/ && echo "Done!" || { echo "Error occured. Try again."; exit; }
}
#
function modifyDaemonFile() {
    echo "-> Overwriting Docker root directory..."
    echo "{
    \"data-root\":\"/media/sd/docker\",
    \"log-driver\":\"json-file\"
}
" > "$daemonPath" && echo "Done!" || { echo "Error occured. Try again."; exit; }
}
#
function startDockerDaemon() {
    echo '-> Starting Docker Daemon with new directory...'
    /etc/init.d/dockerd start || { echo "Error occured. Try again."; exit; }
    echo 'Done!'
}
#
function createDockerNetwork() {
    echo '-> Setting up docker network for M.I.N.G. containers...'
    docker network create \
    --driver=bridge \
    --subnet=10.10.0.0/16 \
    --ip-range=10.10.1.0/24 \
    --gateway=10.10.1.254 \
    -o "com.docker.network.bridge.host_binding_ipv4"="0.0.0.0" \
    -o "com.docker.network.bridge.name"="cc100stack" \
    -o "com.docker.network.bridge.mtu"="1500" \
    -o "com.docker.network.bridge.enable_ip_masquerade"="true" \
    -o "com.docker.network.bridge.icc"="true" \
    cc100-stack || { echo "Error occured. Try again."; exit; }
    echo 'Done!'
}
#
function chooseDockerContainers() {
    echo '-> Installing docker containers. Please select any of the following by typing a combination of starting letters, separated by comma.'
    echo '   InfluxDB - i/I'
    echo '   Node-RED - n/N'
    echo '   Grafana  - g/G'
    read -p "To be installed: " decision
    IFS=', ' read -r -a options <<< "$decision"
    for element in "${options[@]}"
    do
        element=$( echo "$element" | tr '[:upper:]' '[:lower:]' )
    done
}
#
function installInflux() {
    echo "-> Installing InfluxDB..."
    docker run -d \
    -p 8086:8086 \
    --network cc100-stack \
    --ip 10.10.1.3 \
    --restart=unless-stopped \
    -e INFLUXDB_ADMIN_USER=admin \
    -e INFLUXDB_ADMIN_PASSWORD=wago \
    --name influxdb \
    -v myInfluxVolume:/influxdb \
    arm32v7/influxdb || { echo "Error occured. Try again."; exit; }
    echo "Done!"
}
#
function installNodeRed() {
    echo "->Installing Node-RED..."
    docker run -d \
    -p 1880:1880 \
    --network cc100-stack \
    --ip 10.10.1.1 \
    --no-healthcheck \
    --privileged=true \
    -u root \
    --restart=unless-stopped \
    --name node-red \
    -v node_red_user_data:/data \
    nodered/node-red || { echo "Error occured. Try again."; exit; }
    echo "Done!"
}
#
function installGrafana() {
    echo "-> Installing Grafana..."
    docker run -d \
    --name grafana \
    -p 3000:3000 \
    --network cc100-stack \
    --ip 10.10.1.2 \
    --restart=unless-stopped \
    --name grafana \
    --privileged=true \
    --user=root \
    -v grafana-storage:/var/lib/grafana \
    grafana/grafana || { echo "Error occured. Try again."; exit; }
    echo "Done!"
}
###
### Main ###
###
greetAndAsk
checkDockerDaemon
moveDockerDirectory
modifyDaemonFile
startDockerDaemon
createDockerNetwork
chooseDockerContainers
for element in "${options[@]}"
    do
        case $element in
        "i")
                installInflux
                ;;
        "n")
                installNodeRed
                ;;
        "g")
                installGrafana
                ;;
        *)
                echo "Entry $element not recognised.";;
        esac
    done
echo "-> Process completed; enter 'docker ps' to see currently running containers"
exit