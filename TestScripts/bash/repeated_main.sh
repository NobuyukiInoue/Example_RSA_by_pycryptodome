#!/bin/bash

cmd="./main.sh"
keyfile1="key_public.pem"
keyfile2="key_private.pem"
file1="./original.jpg"
file2="./test.bin"
file3="./test.jpg"

loopCount=10

echo -e "\033[0;35m#### encrypt(public_key) --> decrypt(private_key) ###\033[0;39m"

for ((i=0; i < $loopCount; i++)); do
    $cmd $keyfile1 $keyfile2 $file1 $file2 $file3
done
