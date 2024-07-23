# ming-installer

Simple script used to install M.I.N.G. stack on your WAGO device.<br>
M - MQTT<br>
I - InfluxDB<br>
N - Node-RED<br>
G - Grafana<br>

> For more information please navigate to this repository's [WIKI Page](https://github.com/WAGO-UK/ming-installer/wiki)

# Prerequisites
- WAGO 750-821x / 750-8302 / 751-9301 / 751-9401 with FW24 or higher
- SD card (microSD for CC100, SD for PFC200/Edge) with max 32GB capacity
- USB-C cable and/or ethernet cable
- controller with internet access


# How to run script

1. SSH to your controller 
    > You will have to know it's IP address; see Wiki page for step by step configuration

2. log in with root credentials (default password: wago)

3. run the below command to copy script from this repository:<br>
    `curl -s  https://raw.githubusercontent.com/WAGO-UK/ming-installer/main/ming_installer.sh >ming_installer.sh`

4. run the below command to start the script:<br>
    `sh ming_installer.sh`

6. Follow instructions in your terminal

Enjoy!
