#!/bin/bash

echo "You want to add user $1 in userlist"

sudo useradd -m $1

echo "$1 added succesfully"


