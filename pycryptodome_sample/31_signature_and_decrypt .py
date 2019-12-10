# -*- coding: utf-8 -*-

from Crypto.PublicKey import RSA
from Crypto.Hash import SHA256
from Crypto.Signature import pkcs1_15


# pemロード
with open('private.pem', 'br') as f:
    private_pem = f.read()
    private_key = RSA.import_key(private_pem)
 
with open('public.pem', 'br') as f:
    public_pem = f.read()
    public_key = RSA.import_key(public_pem)


# メッセージと秘密鍵から署名を生成
message = 'テストメッセージ'
print("original message = {0}".format(message))

h1 = SHA256.new(message.encode())

signature = pkcs1_15.new(private_key).sign(h1)
print("signature = {0}".format(signature))


# 公開鍵から妥当性を検証
h2 = SHA256.new(message.encode())
try:
    pkcs1_15.new(public_key).verify(h2, signature)
    verified = True
except ValueError:
    verified = False

print(verified)
