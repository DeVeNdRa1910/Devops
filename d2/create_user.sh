#!/bin/bash

read -p "Enter username " username

echo "You entered username: $username"

sudo useradd -m $username

echo "New user added"
