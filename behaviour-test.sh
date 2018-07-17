#!/bin/bash

if [ -z "$KEY_REST_API" ]; then
	echo "Rest API key:"
	read KEY_REST_API
fi
if [ -z "$KEY_API" ]; then
	echo "SDK API key:"
	read KEY_API
fi

echo "Webpage for notification: https://localhost:3000"
echo "Post for notification: http://localhost:8080"
sleep 5
docker-compose -f behaviour_test/docker-compose.yml up

