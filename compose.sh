#!/usr/bin/env bash

ENV_FILE=".env"
SERVICES=(
    "traefik"
    "authelia"
    "grafana"
    "promtail"
    "wireguard"
    "backup"
    #"code-server"
)

if [ -z "$1" ]; then
    echo "Usage: $0 up|down|ps"
    exit 1
fi

command=""
if [ "$1" == "up" ]; then
    echo "Starting services..."
    command="up -d"
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
