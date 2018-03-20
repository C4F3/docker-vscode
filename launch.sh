#!/bin/bash

root=$(dirname ${BASH_SOURCE[0]})
if [[ $root == . ]]; then
	root=$PWD
fi
app=$(basename $root)

xhost +local:docker
docker build \
	--build-arg PKG=https://vscode-update.azurewebsites.net/1.20.1/linux-deb-x64/stable \
	--build-arg USERNAME=$(whoami) \
	--build-arg UID=$(id -u) \
	--build-arg GID=$(id -g) \
	-t $app $root
docker run --rm \
	-e DISPLAY=$DISPLAY \
	--device /dev/dri \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v /etc/localtime:/etc/localtime:ro \
	-v $HOME/.gitconfig:$HOME/.gitconfig \
	-v $HOME/.git-credentials:$HOME/.git-credentials \
	-v $HOME/.config/Code:$HOME/.config/Code \
	-v $HOME/.vscode:$HOME/.vscode \
	-v $HOME/Público:$HOME/Público \
	-v /tmp:/tmp \
	$app $@
