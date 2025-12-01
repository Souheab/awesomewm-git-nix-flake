#!/usr/bin/env bash

echo "Building awesome-git..."
nix build .#default

SCREEN_SIZE="1280x720"
DISPLAY_NUM=":1"

echo "Starting Xephyr on $DISPLAY_NUM..."

nix shell nixpkgs#xorg.xorgserver -c \
    Xephyr $DISPLAY_NUM -ac -br -noreset -screen $SCREEN_SIZE &
XEPHYR_PID=$!

sleep 1

echo "Starting AwesomeWM..."

CONFIG_FLAG=""
if [ -f "./rc.lua" ]; then
    CONFIG_FLAG="--config ./rc.lua"
else
    echo "No local rc.lua found, using default from build..."
fi

DISPLAY=$DISPLAY_NUM ./result/bin/awesome $CONFIG_FLAG \
    --search ./result/share/awesome/lib \
    --search ./result/share/awesome/themes

kill $XEPHYR_PID
