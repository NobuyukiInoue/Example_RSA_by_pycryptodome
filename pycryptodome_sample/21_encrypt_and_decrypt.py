# -*- coding: utf-8 -*-

from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP


# pemロード
with open('private.pem', 'br') as f:
    private_pem = f.read()
    private_key = RSA.import_key(private_pem)
 
with open('public.pem', 'br') as f:
    public_pem = f.read()
    public_key = RSA.import_key(public_pem)


# メッセージを暗号化

message = "テストメッセージ"
print("original message = {0}".format(message))

public_cipher = PKCS1_OAEP.new(public_key)
ciphertext = public_cipher.encrypt(message.encode())

print("ciphertext = {0}".format(ciphertext))


# メッセージを復号

private_cipher = PKCS1_OAEP.new(private_key)
message2 = private_cipher.decrypt(ciphertext).decode("utf-8")

print("decrypt message = {0}".format(message2))
