#!/bin/sh

if [ -z "$KEY_REST_API" ] || [ -z "$KEY_API" ]; then
    echo "Missing KEY_REST_API or KEY_API variable"
    exit 1
fi

confd -onetime -backend env

mix run --no-halt