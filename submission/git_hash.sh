#!/usr/bin/bash
# Generates a 16-digit random number hash

Hash=""

for (( i=0; i < 16; i++ ));
do
	x="$(echo "($RANDOM*10)/32767" | bc)"
	Hash=$Hash"$x"
done

echo $Hash
