#!/usr/bin/bash

vcard_directory=~/.config/mutt/contacts/people

if [[ ! $# -eq 3 ]]
then
    echo "Usage: add_vcard.sh <name> <surname> <email>"
    exit
fi

name=$1
surname=$2
email=$3
uid="$name-$surname-$(date +'%s')"

echo "Adding $name $surname $email $uid"


cd $vcard_directory

vcard_file="$uid.vcf"

echo -e "BEGIN:VCARD\n\
VERSION:3.0\n\
UID:$uid\n\
FN:$name $surname\n\
N:$surname;$name\n\
EMAIL:$email\n\
END:VCARD" >> $vcard_file 

# git add $vcard_file
