#!/bin/bash

###  This script will add the public key of the specified github user  ###
###  to the currently logged in linux user's authorized_keys file.     ###

if [ "" == "$1" ]
then
    echo ""
    echo "You must specify the github username as an argument"
    echo "Example:  ./key-install.sh johnsmith"
    echo ""
    exit 1
else
    echo ""
    echo "Working with Github user $1's public key."
    echo ""
fi

## Establish Github Username
GITHUB_USER="$1"

## Check if ~/.ssh directory exists
cd ~
if [ ! -d ".ssh" ]
then
    ## Create the ~/.ssh directory if it doesnt exist, and chmod it to 700
    echo "Your .ssh directory doesn't exist, creating and securing it."
    cd ~
    mkdir .ssh
    chmod 700 .ssh
    echo "Done."
else
    ## If the ~/.ssh directory does exist, chmod it to 700
    echo "Your .ssh directory already exists, making sure its secure."
    cd ~
    chmod 700 .ssh
    echo "Done."
fi

## Change to ~/.ssh directory
cd ~/.ssh

## Get SSH Public Key
echo "Downloading Public Key."
KEY=`wget -qO - https://github.com/$GITHUB_USER.keys`
echo "Done."

## chmod 600 the authorized_keys file
echo "Securing the authorized_keys file."
touch authorized_keys
chmod 600 authorized_keys
echo "Done."

## Append to authorized_keys file
echo "Adding key to authorized_keys file."
echo "$KEY" >> authorized_keys
echo "Done."

echo ""
echo "SSH key from Github user $GITHUB_USER has been added"
echo "to the authorized_keys file for Linux user $USER"
echo ""
