#!/bin/sh
for iteration in 1 10 100 1000 10000 100000 1000000; do
	for max in 10 100 1000; do
		echo "Running $iteration with $max consumer"
		mix benchmark --config ./stress_test/config.json $1 --max $max $iteration 1
	done
done