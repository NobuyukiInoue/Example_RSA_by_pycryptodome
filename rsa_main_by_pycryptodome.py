# -*- coding: utf-8 -*-

import os
import struct
import sys

from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
from my_modules.getch import getch


def main():
    argv = sys.argv
    argc = len(argv)

    if argc < 2:
        exit_msg(argv[0])

    if argv[1] == "create_key" or argv[1] == "key":
        create_key(1024)
    else:
        if argc < 5:           
            exit_msg(argv[0])

        r_file = argv[2]
        if not os.path.exists(r_file):
            print("%s not found." %r_file)
            exit(0)

        w_file = argv[3]
        check_exists(w_file)

        keyfile = argv[4]
        if not os.path.exists(keyfile):
            print("%s not found." %keyfile)
            exit(0)

        if argv[1] == "encrypt" or argv[1] == "enc":
            encrypt_binary(keyfile, r_file, w_file)
        elif argv[1] == "decrypt" or argv[1] == "dec":
            decrypt_binary(keyfile, r_file, w_file)
        else:
            exit_msg(argv[0])


def exit_msg(argv0):
    print("Usage: python %s [encrypt | decrypt | create_key] [変換前ファイル] [変換後ファイル] [公開鍵ファイル | 秘密鍵ファイル]" %argv0)
    print("example1) -- create_key\n"
            "python rsa_main_mode_bin.py create_key\n\n"
            "example2) -- encrypt"
            "python rsa_main_mode_bin.py encrypt file1 file2 key_public.pem\n\n"
            "example3) -- decrypt"
            "python rsa_main_mode_bin.py decrypt file2 file1 key_private.pem\n\n")
    exit(0)


def create_key(n):
    print("Public key filename [key_public.pem]:", end = '')
    public_key_filename = input()
    if public_key_filename == "":
        public_key_filename = "key_public.pem"

    check_exists(public_key_filename)

    print("Private key filename [key_private.pem]:", end = '')
    private_key_filename = input()
    if private_key_filename == "":
        private_key_filename = "key_private.pem"

    check_exists(private_key_filename)

    """公開鍵と秘密鍵を生成"""
    # 秘密鍵の生成
    private_key = RSA.generate(n)
    with open(private_key_filename, "w") as f:
        f.write(private_key.export_key().decode('utf-8'))

    # 公開鍵の生成
    public_key = private_key.publickey()
    with open(public_key_filename, "w") as f:
        f.write(public_key.export_key().decode('utf-8'))

    print("Create Keys done.")


def check_exists(filename):
    if os.path.exists(filename):
        firstKey = ''
        while (firstKey != 'Y' and firstKey != 'N'):
            print("\n%s is exists. overwrite? (Y/N):" %filename, end = "")
            keyRet = ord(getch())
            firstKey = chr(keyRet).upper()

        print()
        if (firstKey == 'N'):
            print("quit....")
            exit(0)


def read_key(keyfilename):
    """鍵ファイルの読み込み"""
    with open(keyfilename, "br") as f:
        pem_data = f.read()
        key = RSA.import_key(pem_data)

    return key


def encrypt_binary(keyfile, read_file, write_file):
    """鍵ファイルから公開鍵を読み込む"""
    public_key = read_key(keyfile)

    """平文ファイルを読み込む"""
    f = open(read_file, "rb")
    plain_bytes = []
    while True:
        d = f.read(16)
        if len(d) == 0:
            break
        plain_bytes.append(d)
    f.close

    """暗号化および結果の出力"""

    # 2019/12/09 デバッグ中
    # https://www.pycryptodome.org/en/latest/src/examples.html

    public_cipher = PKCS1_OAEP.new(public_key)
    encrypted_bytes = []
    for block in plain_bytes:
        encrypted_bytes.append(public_cipher.encrypt(block))

    with open(write_file, 'wb') as f:
        for d in encrypted_bytes:
            f.write(d)


def decrypt_binary(keyfile, read_file, write_file):
    """鍵ファイルから秘密鍵を読み込む"""
    private_key = read_key(keyfile)

    """暗号文ファイルを読み込む"""
    f = open(read_file, "rb")
    encrypted_bytes = []
    while True:
        d = f.read(128)
        if len(d) == 0:
            break
        encrypted_bytes.append(d)
    f.close

    """復号化および結果の出力"""
    private_cipher = PKCS1_OAEP.new(private_key)
    decrypted_bytes = []
    for block in encrypted_bytes:
        decrypted_bytes.append(private_cipher.decrypt(block))

    with open(write_file, 'wb') as f:
        for d in decrypted_bytes:
            f.write(d)


if __name__ == "__main__":
    main()
