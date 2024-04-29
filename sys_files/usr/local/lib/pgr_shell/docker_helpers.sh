#!/bin/bash
. /usr/local/lib/pgr_shell/script_interface.sh 2>/dev/null

DOCKER_REQUIRED_DISK_SPACE=2000000

function dkr_get_docker_dir() {
    docker info | grep "Docker Root Dir" | awk '{print $NF;}'
}

function dkr_check_docker_disk_space() {
    # $1 - required space in KB (optional) defauilt: DOCKER_REQUIRED_DISK_SPACE
    # $2 - [docker directory] (optional) default: $(dkr_get_docker_dir)
    local required_space=${1:-DOCKER_REQUIRED_DISK_SPACE}
    local docker_dir=${2:-$(dkr_get_docker_dir)}
    local available=$(df $docker_dir --output=avail | tail -n 1)
    if [ $available -lt $required_space ]; then
        shout "Not enough disk space for '${docker_dir}'. Required: $required_space, available: $available"
        return 1
    fi
}

function dkr_check_tag_exists() {
    # $1 - base tag (path to image without tag)
    # $2 - tag (number of tag to check)
    local base_tag=$1
    local tag=$2
    local is_existing=$(gcloud artifacts docker tags list ${base_tag} 2>/dev/null | awk '{print $1;}' | grep -E "^${tag}\$" | wc -l)
    if [ $is_existing -ne 0 ]; then
        shout "WARNING: TAG ${tag} already exists in repository."
        return 1
    fi
}

function dkr_install_docker_ce() {
    read -p "Do you want to install Docker CE? [y/n]: " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        shout Action cancelled.
        return 1
    fi
    trap "shout 'Failed to install Docker.'; return 1' ERR"
    for package in docker docker-engine docker.io containerd runc; do
        apt -y remove $package
    done
    apt -y install apt-transport-https ca-certificates curl gnupg lsb-release git
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

    apt update
    apt -y install docker-ce docker-ce-cli containerd.io google-cloud-sdk docker-compose

    systemctl enable docker.service
    systemctl enable containerd.service
    trap - ERR
}

function dkr_move_docker_directory(){
    # $1 - destination directory
    service docker stop
    old_docker_dir=$(dkr_get_docker_dir)
    trap "shout 'Failed to move Docker directory.'; service docker start; return 1" ERR
    if [ -z "$1" ]; then
        shout "Destination directory not specified."
        false
    fi
    if [ -e $1 ]; then
        shout "Directory $1 already exists."
        false
    fi
    mkdir -p $1
    # cp -r --sparse=always "${old_docker_dir}"/* $1
    mv "${old_docker_dir}"/* $1
    if [ -f  /etc/docker/daemon.json ]; then
        sed -i "s|${old_docker_dir}|$1|g" /etc/docker/daemon.json
    else
        echo "{\"data-root\": \"$1\"}" > /etc/docker/daemon.json
    fi
    service docker start
    trap - ERR
}