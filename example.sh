#!/bin/sh


#Script is as follows

# Group into Tar
##tar -zvcf new.tar testfolder/

# Encrypt the data using key
# openssl enc -in input.txt -out encrypted.enc -pbkdf2 -e -aes256 -k keyfile.key
openssl enc -a -in bankdataset.csv -out encrypted.txt -pbkdf2 -e -aes256 -k sym.key
#openssl aes-256-cbc -a -salt -pbkdf2 -in new.tar -out dir.aes256

# Send file over SSH
sudo scp encrypted.txt sym.key devraj@192.168.128.227:/home/devraj
echo "File sent"

# Entering AWS Server
# sudo ssh -t -t -i "ec2key.pem" ubuntu@ec2-13-50-250-17.eu-north-1.compute.amazonaws.com << EOF
# openssl enc -a -in dir.aes256 -out decrypted.tar -pbkdf2 -d -aes256 -k keyfile.key
# tar --one-top-level -xvf decrypted.tar
# aws s3 mv decrypted/testfolder s3://suyogs3bucket1 --recursive
