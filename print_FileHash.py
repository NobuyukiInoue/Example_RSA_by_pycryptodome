import hashlib
import os
import sys


def main():
    argv = sys.argv
    argc = len(argv)

    if argc < 1:
        exit_msg(argv[0])

    if not os.path.exists(argv[1]):
        print("%s not found." %argv[1])
        exit(0)

    f = open(argv[1],'rb')
    BinaryData = f.read()
    f.close()

    if argc >= 3:
        algorithm = argv[2].upper()
    else:
        algorithm = "MD5"

    if algorithm == "MD5":
        result = hashlib.md5(BinaryData).hexdigest()
        print('MD5 :', result)
    elif algorithm == "SHA1":
        result = hashlib.sha1(BinaryData).hexdigest()
        print('SHA1 :', result)
    elif algorithm == "SHA224":
        result = hashlib.sha224(BinaryData).hexdigest()
        print('SHA224 :', result)
    elif algorithm == "SHA256":
        result = hashlib.sha256(BinaryData).hexdigest()
        print('SHA256 :', result)
    elif algorithm == "SHA384":
        result = hashlib.sha384(BinaryData).hexdigest()
        print('SHA384 :', result)
    elif algorithm == "SHA512":
        result = hashlib.sha512(BinaryData).hexdigest()
        print('SHA512 :', result)
    else:
        print("%s is not defined." %argv[2])

def exit_msg(argv0):
    print("Usage: python %s [target_file] [MD5 | SHA1 | SHA224 | SHA256 | SHA384 | SHA512]" %argv0)
    exit(0)


if __name__ == "__main__":
    main()
