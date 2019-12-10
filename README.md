# Example_RSA_by_pycryptodome 

PyCryptodomeを使用してファイルの暗号化／復号を行うPytho3用プログラムです。<br>
<br>

なお、サポートが終了した Crypto や pycrypto のモジュールがインストールされている場合は、<br>
事前にアンインストールしておいてください。<br>
<br>
```
pip uninstall Crypto
pip uninstall pycrypto
```
<br>

続いて、pycryptodome をインストールします。<br>

```
pip install pycryptodome
```

公開鍵で暗号化し、秘密鍵で復号する（暗号化データの送受信）ことができます。<br>
そのほか、元ファイルと復号後のファイルの内容のチェック用に、<br>
ファイルのハッシュ値を出力するプログラムとして、<br>
ファイルのハッシュ値出力ツール **print_FileHash.py**<br>
を用意しています。<br>
<br>

### 1. 鍵ペア（秘密鍵／公開鍵ファイル）の生成（rsa_main.py）

最初に公開鍵／秘密鍵を生成します。<br>
"rsa_main.py"に続けて、"createkey"を指定します。<br>
<br>
生成された鍵は、デフォルトではそれぞれ"key_public.pem", "key_private.pem"というファイルに出力されます。

```
$ python rsa_main.py createkey
Public key filename [key_public.pem]:
Private key filename [key_private.pem]:
Create Keys done.
```

<br>
<br>

ちなみに、鍵の中身は、OpenSSLコマンドで確認することができます。<br>
<br>
* ASN1形式

```
$ openssl asn1parse -in key_private.pem
...
...
$ openssl asn1parse -in key_public.pem
...
...
```
$ openssl rsa -in key_private.pem -text -noout
...
...
$ openssl rsa -in key_public.pem -pubin -text -noout
...
...
```


### 2. 元ファイルから暗号化ファイルを生成する（rsa_main.py）

"rsa_main.py encrypt"に続けて、<br>
暗号化したい元ファイル名、 暗号化後のファイル名、 公開鍵ファイル<br>
を指定して rsa_main.py を実行します。

```
$ python rsa_main.py encrypt 暗号化したい元ファイル名 暗号化後のファイル名 公開鍵ファイル
```

<br>
<br>

### 3. 暗号化後のファイルから元のファイルを復号する（rsa_main.py）

"rsa_main.py decrypt"に続けて、<br>
暗号化後のファイル名、復号後のファイル名、秘密鍵ファイル<br>
を指定して rsa_main.py を実行します。

```
$ python rsa_main.py decrypt 暗号化後の出力結果ファイル 復号後のファイル名 秘密鍵ファイル
```

<br>
<br>

### 4. 暗号化と復号の実行例（rsa_main.py）

暗号化処理例

```
$ python rsa_main.py encrypt image1.jpg testimage.bin key_public.pem
```

復号処理例

```
$ python rsa_main.py decrypt testimage.bin image2.jpg key_private.pem
```

<br>
<br>

## 3. 検証用スクリプト

下記のサブディレクトリに、鍵の生成、暗号化、復号処理と、元ファイルと復号後ファイルのハッシュ値比較を行うスクリプトを配置しています。
それぞれ、

* 鍵ペアの生成および公開鍵による暗号化および秘密鍵による復号
* 鍵ペアの生成および秘密鍵による暗号化および公開鍵による復号

を10回づつ実行します。
<br>

### bash版
* ./TestScripts/bash/repeated_main.sh ... 親側スクリプト
* ./TestScripts/bash/main.sh ... 鍵の生成、暗号化、復号を１回だけ実行
<br>

### PowerShell版
* ./TestScripts/ps1/repeated_main.ps1 ... 親側スクリプト
* ./TestScripts/ps1/main.ps1 ... 鍵の生成、暗号化、復号を１回だけ実行
<br>


### 3-1. 検証用スクリプト実行例(bash版)

```
$ cd TestScripts/bash
```

```
$ ./repeated_main.sh
#### encypt(public_key) --> decrypt(private_key) ###
args = main.ps1 ./key_public.pem ./key_private.pem ./original.jpg ./test.bin ./test.jpg
Execute: python ../../rsa_main.py createkey
Execute: python ../../rsa_main.py encrypt ./original.jpg ./test.bin ./key_public.pem
Execute: python ../../rsa_main.py decrypt ./test.bin ./test.jpg ./key_private.pem
./key_public.pem     :
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCS+es6BayR6pa8jTgwaolxVNjx
gcVJMEIdu/x5WAtMSOcXzGJRylcUhMz/ahOkXRrHF1WowkZY+HkW5gj+oweq5DvK
7NURPp6pv1nhDQTctfUJXn6haEMxphW5k+iABmvBK7tnwVR8f5ZN8B0VQwlnIymt
aBbNFFjIzoSwKz2QYQIDAQAB
-----END PUBLIC KEY-----
./key_private.pem    :
-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQCS+es6BayR6pa8jTgwaolxVNjxgcVJMEIdu/x5WAtMSOcXzGJR
ylcUhMz/ahOkXRrHF1WowkZY+HkW5gj+oweq5DvK7NURPp6pv1nhDQTctfUJXn6h
aEMxphW5k+iABmvBK7tnwVR8f5ZN8B0VQwlnIymtaBbNFFjIzoSwKz2QYQIDAQAB
AoGAAd2FoHwjc0uio5x4NtcXTPaqdTA0MIhaAnYZD3IwXIS9WBY6NjcG8WX5ExHF
04tx9E5lwilLCsSGhuWe/hpUFdB4PLP5mDSKRoobkdNWJnUJs5Y8pobdLOaxUbCq
i3TugcylU6LfKOgQSKamCpQdEj9gVNJAWsaNluX91HjdllUCQQC8ar+MUCOdZYnD
Z1Bo+IVzn/aCeRBaY5aDm8IqMfD3cYJ/VymrhK+uujxv6F3E2ovy8+3aUXkVAm1V
2V1c3vutAkEAx7Hnr4dCE0NpRdv2n5fBAJJI0VSCWl9ostYvIGNXlmn5/Yfvifx/
QySjuCnf14xjeeZuz9A/BP72G7mR14H+BQJAE7DQPdiuMCfJYutsItw+Dhxchbwj
Ml8P/scLXp+DgEiTi71PNIaUWZ1K7aMKEaWJVKWbaOJ01fY/+OXTdP40rQJBALg7
8wNm51f8VnBkKlk82Ywcad/udsDHy0FLB3l7DYCwzznPoviMIiEg+Ybb4y7qz4/U
P6Gsf6etTgNwJhRMUr0CQQCH+tkwLPTwzDPo6cQX5gc1h3jkjMXvGXZBv5bCqxJQ
b643I6x0A0piUV+co6PNwEqzoGS4GDThbNOLDrOpooC/
-----END RSA PRIVATE KEY-----
./original.jpg       MD5 : 351efe5e4d33d7ca16c86b3137c78011
./test.jpg           MD5 : 351efe5e4d33d7ca16c86b3137c78011
<<Sucess>>
   ...
   ...
```

<br>
<br>

### 3-2. 検証用スクリプト実行例(PowerShell版)

```
PS D:\work\Example_RSA> cd .\TestScripts\ps1
```

```
PS D:\work\Example_RSA\TestScripts\ps1>.\repeated_main.ps1
args = ./main.sh key_public.pem key_private.pem ./original.jpg ./test.bin ./test.jpg
Execute: python ../../rsa_main.py createkey
Execute: python ../../rsa_main.py encrypt ./original.jpg ./test.bin key_public.pem
Execute: python ../../rsa_main.py decrypt ./test.bin ./test.jpg key_private.pem
key_public.pem      :
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCqxvLwdt6FTTdR2NL+QF2dfGfj
Qu9301SIf7vzQB8TZWecFtasjaN4OVlAKBUUj3USa1WXjFvIs1rbvJi9UaX76O0B
goJJcv63YHFttrQdZi30U7xrJ2PWiKxaRwcvbEWsYsDVyOeJ60aLIRg100QZ/9ka
IEw+mDyTq2owU6rf8QIDAQAB
-----END PUBLIC KEY-----
key_private.pem     :
-----BEGIN RSA PRIVATE KEY-----
MIICWwIBAAKBgQCqxvLwdt6FTTdR2NL+QF2dfGfjQu9301SIf7vzQB8TZWecFtas
jaN4OVlAKBUUj3USa1WXjFvIs1rbvJi9UaX76O0BgoJJcv63YHFttrQdZi30U7xr
J2PWiKxaRwcvbEWsYsDVyOeJ60aLIRg100QZ/9kaIEw+mDyTq2owU6rf8QIDAQAB
AoGAAKU36OVWGyD9glvLFRJzHttH9lT4mMjsGpxSi/JvNOS6wGQP3M/XAgjzBtup
LvGx5gCXtVVDvDeoxp/kAdOtuxim5s4gK3G2ivuUgMEe+PSm5CW3lLJpJSM+HUof
W5a0qLtlsPKrEPm1ZnamNzXkqvWFaW7uunL79APdlXLliC0CQQDKfpN+v23ujD0A
/kcQgd1UqWuyJtuPOUKrCURRIapLH6kj2DfGU88Ap3sbealutv+YaLDQIlRsPaba
kCTgbfytAkEA1+bnyqNowZEpgBCR13sVKqjujJ8TKNxktPhCSLvcg6wDfJkGTp2e
Zd/Fq/+AN3giaOfGS+4dHelbB7/djja01QJAbRcyCQfChtCAkQdsa6U7A0Be59Rt
VsTHePN+HaNgZiaBbfEvYyaFj9mqxguOTzpBiu9jyk2kY8f3Gyqq40n95QJAOX43
w3J4dvNdBcljzOnt3QpXXAMQaxUljDuACzZbpoSr+QYW8+BtSdupHABR+HN5Vk5C
M/4Yqtp1bz7clP5kcQJAHhUG7rAJk6mmU3sBKlXiqac/hzARBlcne/UP23kc0RqI
3i32dKJDQKdbj+5YWS0pjGo7iOqbppe/JBp7cMfQmQ==
-----END RSA PRIVATE KEY-----
./original.jpg      :MD5 : 351efe5e4d33d7ca16c86b3137c78011
./test.jpg          :MD5 : 351efe5e4d33d7ca16c86b3137c78011
<<Success>>
    ....
    ....
```

<br>
<br>
