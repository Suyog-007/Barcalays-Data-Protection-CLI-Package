#!/bin/sh

#Author : Suyog
#Script is as follows

# generate ASYM key at cloud
sudo ssh -t -t -i "cloud.pem" ubuntu@ec2-13-236-147-242.ap-southeast-2.compute.amazonaws.com << EOF
openssl genrsa -out private.key 4096 
head private.key
#openssl genpkey -algorithm RSA -out private.key
openssl rsa -in private.key -pubout -out public.key
head public.key
logout
EOF

# send public key to devraj
sudo scp -i "cloud.pem" ubuntu@ec2-13-236-147-242.ap-southeast-2.compute.amazonaws.com:/home/ubuntu/public.key public.key
#head public.key

# create SYM key and encrypt
openssl rand -out keyfile.bin 32
openssl enc -base64 -in keyfile.bin -out keyfile.txt
openssl enc -in input.txt -out encrypted.txt -pbkdf2 -e -aes256 -k keyfile.txt
echo "INPUT FILE"
hexdump -C input.txt

echo "ENC FILE"
hexdump -C encrypted.txt

# encrypt SYM key using public key 
openssl pkeyutl -encrypt -in keyfile.txt  -pubin -inkey public.key -out encrypted_key.txt 
rm public.key

# send encrypted sym key and data to cloud
sudo scp -i "cloud.pem" encrypted_key.txt ubuntu@ec2-13-236-147-242.ap-southeast-2.compute.amazonaws.com:/home/ubuntu/encrypted_key.txt
sudo scp -i "cloud.pem" encrypted.txt ubuntu@ec2-13-236-147-242.ap-southeast-2.compute.amazonaws.com:/home/ubuntu/encrypted.txt
echo "File uploaded to cloud"

# go to cloud
sudo ssh -t -t -i "cloud.pem" ubuntu@ec2-13-236-147-242.ap-southeast-2.compute.amazonaws.com << EOF

# decrypt key and then data
openssl pkeyutl -decrypt -inkey private.key -in encrypted_key.txt -out decrypted_key.txt
openssl enc -in encrypted.txt -out output.txt -pbkdf2 -d -aes256 -k decrypted_key.key
echo "DEC FILE"
hexdump -C output.txt

#move data to S3
aws s3 mv output.txt s3://inputdatafromec2 # --recursive
