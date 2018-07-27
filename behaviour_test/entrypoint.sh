#!/bin/sh

if [ -z "$KEY_REST_API" ]; then
    echo "Missing KEY_REST_API variable"
    exit 1
fi

confd -onetime -backend env

java -jar /usr/local/bin/selenium.jar &
mix test