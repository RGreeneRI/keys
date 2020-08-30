#!/bin/bash

###  This script will add the public key of the specified github user   ###
###  to the currently logged in linux/unix user's authorized_keys file. ###
###  Tested with Ubuntu and macOS.                                      ###

# Title
cat <<'EOF'
 _  __               ___           _        _ _
| |/ /___ _   _     |_ _|_ __  ___| |_ __ _| | |
| ' // _ \ | | |_____| || '_ \/ __| __/ _` | | |
| . \  __/ |_| |_____| || | | \__ \ || (_| | | |
|_|\_\___|\__, |    |___|_| |_|___/\__\__,_|_|_|
          |___/

EOF

## Prerequsite Check
DOWNLOADER="None"
echo "Looking for wget"
which wget
if [ "$?" == "0" ]; then
    DOWNLOADER="wget";
    echo "Found it!"
else
echo "Looking for curl"
which curl
    if [ "$?" == "0" ]; then
        DOWNLOADER="curl";
        echo "Found it!"
    fi
fi

if [ "$DOWNLOADER" == "None" ]; then
    echo "You do not have wget or curl.  You need one of these to use this script.";
    exit 1;
fi

if [ "" == "$1" ]
then
    echo ""
    echo "For future reference:"
    echo "You can specify the github username as an argument"
    echo "Example:  ./key-install.sh johnsmith"
    echo ""
    echo -e "Where \"johnsmith\" is a Github username..."
    echo ""
    echo ""
    echo "Please type the Github username, then press ENTER."
    read -p 'Github Username: ' GITHUB_USER
    echo ""
else
    echo ""
    echo "Working with Github user $1's public key."
    echo ""
    ## Establish Github Username
    GITHUB_USER="$1"
fi

## Get SSH Public Key
echo "Downloading Public Key for $GITHUB_USER."
if [ "$DOWNLOADER" == "wget" ]; then
KEY=`wget -qO - https://github.com/$GITHUB_USER.keys`
fi
if [ "$DOWNLOADER" == "curl" ]; then
KEY=$(curl https://github.com/$GITHUB_USER.keys)
fi

## Check key isnt empty
if [ "" == "$KEY" ]
then
    echo ""
    echo "It appears $GITHUB_USER does not have a public key on github."
    echo "NO KEY ADDED!"
    echo ""
    exit 1
else
    echo ""
    echo "Github user $GITHUB_USER's public key is:"
    echo "----------"
    echo "$KEY"
    echo "----------"
    echo ""
fi

## Check if ~/.ssh directory exists
cd ~
echo "Checking to see if your ~/.ssh directory exists."
if [ ! -d ".ssh" ]
then
    ## Create the ~/.ssh directory if it doesnt exist, and chmod it to 700
    echo "Your .ssh directory doesn't exist, creating and securing it."
    cd ~
    mkdir .ssh
    chmod 700 .ssh
    echo "Done."
    echo ""
else
    ## If the ~/.ssh directory does exist, chmod it to 700
    echo "Your .ssh directory already exists, making sure its secure."
    cd ~
    chmod 700 .ssh
    echo "Done."
    echo ""
fi

## Change to ~/.ssh directory
cd ~/.ssh

## chmod 600 the authorized_keys file
echo "Creating (if it doesn't exist) and securing the authorized_keys file."
touch authorized_keys
chmod 600 authorized_keys
echo "Done."
echo ""

## Append to authorized_keys file
echo "Checking to see if $GITHUB_USER's public key is already in authorized_keys file."
grep -q "$KEY" authorized_keys
if [ "$?" == "0" ]
then
    echo "$GITHUB_USER's public key is already in the authorized_keys file."
    echo "Exiting."
    exit 1
else
    echo "$GITHUB_USER's public key is not already in the authorized_keys file."
    echo "Adding $GITHUB_USER's public key to authorized_keys file."
    echo "$KEY" >> authorized_keys
    echo "Done."

    echo ""
    echo "SSH key from Github user $GITHUB_USER has been added"
    echo "to the authorized_keys file for Linux user $USER"
    echo ""
fi

exit 0
