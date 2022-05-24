#!/usr/bin/env bash

ENV_FILE=".env"
NETWORKS=(
    "core"
    "plex"
)
SERVICES=(
    "plex"
    "promtail"
    "traefik"
    "wireguard"
)

if [ -z "$1" ]; then
    echo "Usage: $0 up|down|ps"
    exit 1
fi

command=""
if [ "$1" == "up" ]; then
    echo "Starting services..."
    command="up -d"
    for NETWORK in ${NETWORKS[@]}; do
        echo "Running: docker network create $NETWORK"
        docker network create $NETWORK
    done
elif [ "$1" == "down" ]; then
    echo "Stopping services..."
    command="down"
elif [ "$1" == "ps" ]; then
    echo "Check services..."
    command="ps"
fi

if [ -n "$command" ]; then
    for SERVICE in ${SERVICES[@]}; do
        echo "Running: docker compose --env-file ${ENV_FILE} -f ${SERVICE}/docker-compose.yml $command"
        docker compose --env-file ${ENV_FILE} -f ${SERVICE}/docker-compose.yml $command
    done
fi
