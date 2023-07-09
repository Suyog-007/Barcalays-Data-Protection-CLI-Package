#!/bin/sh

#Author : Suyog
#Script is as follows

# Group into Tar
tar -zvcf new.tar test_folder/

# Encrypt the data using key
# openssl enc -in input.txt -out encrypted.enc -pbkdf2 -e -aes256 -k keyfile.key
openssl enc -a -in new.tar -out dir.aes256 -pbkdf2 -e -aes256 -k keyfile.key
#openssl aes-256-cbc -a -salt -pbkdf2 -in new.tar -out dir.aes256

# Send file over SSH
sudo scp -i "cloud.pem" dir.aes256 ubuntu@ec2-13-236-147-242.ap-southeast-2.compute.amazonaws.com:/home/ubuntu/dir.aes256
echo "File uploaded to cloud"

# Entering AWS Server
sudo ssh -t -t -i "cloud.pem" ubuntu@ec2-13-236-147-242.ap-southeast-2.compute.amazonaws.com << EOF
echo "File Decrypted"
openssl enc -a -in encrypted.txt -out decrypted.csv -pbkdf2 -d -aes256 -k sym.key
#head decrypted.csv
tar --one-top-level -xvf decrypted.tar
aws s3 mv decrypted/test_folder s3://inputdatafromec2 --recursive
echo "File Uploaded to S3"
