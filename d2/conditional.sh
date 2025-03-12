#!/bin/bash

#This function definition

function hero_check(){
echo "You entered a name $1"
if [[ $1 == "Tonystark" ]]; then
    echo "$1 is Iron man"
elif [[ $1 == "Shaktimaan" ]]; then
    echo "$1 is Shaktimaan"
else
    echo "$1 is nothing"
fi
}

#This is function calling
hero_check $1

