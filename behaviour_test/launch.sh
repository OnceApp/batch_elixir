#!/bin/bash

if [ -z "$KEY_REST_API" ]; then
	echo "Rest API key:"
	read KEY_REST_API
fi

export KEY_REST_API
docker-compose stop || true
docker-compose rm -f || true
docker-compose build
docker-compose run test
RETURN_CODE=$?
docker-compose stop || true
docker-compose rm -f || true
exit $RETURN_CODE
