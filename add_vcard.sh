#!/usr/bin/bash

vcard_file=~/.config/mutt/contacts.vcf

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

echo -e "\nBEGIN:VCARD\n\
VERSION:3.0\n\
UID:$uid\n\
FN:$name $surname\n\
N:$surname;$name\n\
EMAIL:$email\n\
END:VCARD" >> $vcard_file 
