#!/bin/bash

num=$1

while [[ $((num % 2)) == 0 && $num -le $2 ]]; do
    echo "$num Iteration"
    num=$((num + 1))
done

