# -*- coding: utf-8 -*-

import base64
import hashlib
import os
import struct
import sys

from Crypto.Cipher import PKCS1_OAEP
from Crypto.Hash import SHA256
from Crypto.PublicKey import RSA
from Crypto.Signature import pkcs1_15
from my_modules.getch import getch


def main():
    argv = sys.argv
    argc = len(argv)

    if argc < 2:
        exit_msg(argv[0])

    if argv[1] == "createkey" or argv[1] == "key":
        createkey(1024)
        exit(0)

    if argc < 5:           
        exit_msg(argv[0])

    r_file = argv[2]
    if not os.path.exists(r_file):
        print("%s not found." %r_file)
        exit(0)

    w_file = argv[3]

    if argv[1] != "verify" and argv[1] != "vrf":
        check_exists(w_file)

    keyfile = argv[4]
    if not os.path.exists(keyfile):
        print("%s not found." %keyfile)
        exit(0)

    if argv[1] == "encrypt" or argv[1] == "enc":
        encrypt_binary(keyfile, r_file, w_file)
    elif argv[1] == "decrypt" or argv[1] == "dec":
        decrypt_binary(keyfile, r_file, w_file)
    elif argv[1] == "signature" or argv[1] == "sig":
        create_signature(keyfile, r_file, w_file)
    elif argv[1] == "verify" or argv[1] == "vrf":
        verify_signature(keyfile, r_file, w_file)
    else:
        exit_msg(argv[0])


def exit_msg(argv0):
    print("Usage: python %s [encrypt | decrypt | createkey | signature | verify] [変換前ファイル] [変換後ファイル] [公開鍵ファイル | 秘密鍵ファイル]" %argv0)
    print("example1) -- createkey\n"
            "python rsa_main_mode_bin.py createkey\n\n"
            "example2) -- encrypt"
            "python rsa_main_mode_bin.py encrypt source_file encryped_file key_public.pem\n\n"
            "example3) -- decrypt"
            "python rsa_main_mode_bin.py decrypt encrypted_file decrypted_file key_private.pem\n\n"
            "example4) -- signature"
            "python rsa_main_mode_bin.py signature source_file signature_file key_private.pem\n\n"
            "example5) -- verify"
            "python rsa_main_mode_bin.py verify source_file signature_file key_public.pem\n\n")
    exit(0)


def createkey(n):
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

    """暗号化"""
    public_cipher = PKCS1_OAEP.new(public_key)
    encrypted_bytes = []
    for block in plain_bytes:
        encrypted_bytes.append(public_cipher.encrypt(block))

    """結果の出力"""
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

    """復号化"""
    private_cipher = PKCS1_OAEP.new(private_key)
    decrypted_bytes = []
    for block in encrypted_bytes:
        decrypted_bytes.append(private_cipher.decrypt(block))

    """結果の出力"""
    with open(write_file, 'wb') as f:
        for d in decrypted_bytes:
            f.write(d)

def create_signature(private_keyfile, source_file, signature_file):
    """鍵ファイルから秘密鍵を読み込む"""
    private_key = read_key(private_keyfile)

    """ファイルの内容を読み込む"""
    f = open(source_file, "rb")
    plain_bytes = f.read()
    f.close

    """ファイルハッシュを求める"""
    h1 = SHA256.new(plain_bytes)
    print("{0}[SHA256] : {1}".format(source_file, hashlib.sha256(plain_bytes).hexdigest()))
#   print("{0}[SHA256] : {1}".format(source_file, vars(h1)))

    """署名を生成"""
    signature = pkcs1_15.new(private_key).sign(h1)

    """結果の出力"""
    with open(signature_file, 'wb') as f:
        f.write(signature)

def verify_signature(public_keyfile, source_file, signature_file):
    """鍵ファイルから秘密鍵を読み込む"""
    public_key = read_key(public_keyfile)

    """ファイルの内容を読み込む"""
    f = open(source_file, "rb")
    plain_bytes = f.read()
    f.close

    """ファイルハッシュを求める"""
    h1 = SHA256.new(plain_bytes)
    print("{0}[SHA256] : {1}".format(source_file, hashlib.sha256(plain_bytes).hexdigest()))
#   print("{0}[SHA256] : {1}".format(source_file, vars(h1)))

    """署名を読み込む"""
    f = open(signature_file, "rb")
    signature = f.read()
    f.close

    # 公開鍵から妥当性を検証
    try:
        pkcs1_15.new(public_key).verify(h1, signature)
        verified = True
    except ValueError:
        verified = False

    if verified:
        print("Verify OK")
    else:
        print("Verify NG.")


if __name__ == "__main__":
    main()
