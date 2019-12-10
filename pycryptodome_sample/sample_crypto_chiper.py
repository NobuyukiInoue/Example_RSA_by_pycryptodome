from Crypto.Cipher import Salsa20

key = b'0123456789012345'
cipher = Salsa20.new(key)
ciphertext =  cipher.encrypt(b'The secret I want to send.')
ciphertext += cipher.encrypt(b'The second part of the secret.')
print(cipher.nonce)  # A byte string you must send to the receiver too
