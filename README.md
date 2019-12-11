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

## 1. 鍵ペア（秘密鍵／公開鍵ファイル）の生成（rsa_main.py）

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

* "rsa -in 鍵ファイル名 -text -noout"オプション

```
$ openssl rsa -in key_private.pem -text -noout
...
...
$ openssl rsa -in key_public.pem -pubin -text -noout
...
...
```

## 2.ファイルの暗号化と復号


### 2-1. 元ファイルから暗号化ファイルを生成する（rsa_main.py）

"rsa_main.py encrypt"に続けて、<br>
暗号化したい元ファイル名、 暗号化後のファイル名、 公開鍵ファイル<br>
を指定して rsa_main.py を実行します。

```
$ python rsa_main.py encrypt 暗号化したい元ファイル名 暗号化後のファイル名 公開鍵ファイル
```

<br>
<br>


### 2-2. 暗号化後のファイルから元のファイルを復号する（rsa_main.py）

"rsa_main.py decrypt"に続けて、<br>
暗号化後のファイル名、復号後のファイル名、秘密鍵ファイル<br>
を指定して rsa_main.py を実行します。

```
$ python rsa_main.py decrypt 暗号化後の出力結果ファイル 復号後のファイル名 秘密鍵ファイル
```

<br>
<br>


### 2-3. 暗号化と復号の実行例

* 暗号化処理例

```
$ python rsa_main.py encrypt image1.jpg testimage.bin key_public.pem
```

* 復号処理例

```
$ python rsa_main.py decrypt testimage.bin image2.jpg key_private.pem
```

<br>
<br>


## 3. 電子署名の生成と照合


### 3-1. 電子署名ファイルの生成

"rsa_main.py signature"に続けて、<br>
元ファイル名、電子署名ファイル名、秘密鍵ファイル<br>
を指定して rsa_main.py を実行します。

```
$ python rsa_main.py signature 元ファイル名 電子署名ファイル名 秘密鍵ファイル
```

<br>
<br>


### 3-2. 電子署名の照合

"rsa_main.py verify"に続けて、<br>
元ファイル名、電子署名ファイル名、公開鍵ファイル<br>
を指定して rsa_main.py を実行します。

```
$ python rsa_main.py verify 元ファイル名 電子署名ファイル名 公開鍵ファイル
```

<br>
<br>


### 3-3. 電子署名の生成と照合の実行例


* 電子署名ファイルの生成

```
$ python rsa_main.py signature image1.jpg image1.sig key_private.pem
```

* 電子署名ファイルの照合

```
$ python rsa_main.py verify image1.jpg image1.sig key_public.pem
```

<br>
<br>


## 4. 検証用スクリプト

下記のサブディレクトリに、鍵の生成、暗号化、復号処理と、元ファイルと復号後ファイルのハッシュ値比較を行うスクリプトを配置しています。それぞれ、

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


### 4-1. 検証用スクリプト実行例(bash版)

```
$ cd TestScripts/bash
```

```
$ ./repeated_main.sh
#### encrypt(public_key) --> decrypt(private_key) ###
args = ./main.sh ./keys/key_public.pem ./keys/key_private.pem ./sample/original.jpg ./sample/test.bin ./sample/test.jpg ./sample/test.sig
Execute: python ../../rsa_main.py createkey
Execute: python ../../rsa_main.py encrypt ./sample/original.jpg ./sample/test.bin ./keys/key_public.pem
Execute: python ../../rsa_main.py signature ./sample/original.jpg ./sample/test.sig ./keys/key_private.pem
./sample/original.jpg[SHA256] : 0aa50a87f0a5025ada74b16604c8448bdace0b945a974c50fb365e3bf66ef560
Execute: python ../../rsa_main.py decrypt ./sample/test.bin ./sample/test.jpg ./keys/key_private.pem
Execute: python ../../rsa_main.py verify ./sample/original.jpg ./sample/test.sig ./keys/key_public.pem
./sample/original.jpg[SHA256] : 0aa50a87f0a5025ada74b16604c8448bdace0b945a974c50fb365e3bf66ef560
Verify OK
./keys/key_public.pem:
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDTuNxc37GfLSLR4MTkxKweMLH3
3cWcu8xc6/2F6H9oLTHYWlaU4O0o0ez/Wi/CYDtjiQW9A22u2l0ZcDECmx6PjSZk
fVJ+9L179OmqE7hRFrUt5ZUGik8Sdl1CyAp5H2GS4bImY+vkQzufMcSdtgAdQ9JO
jCT6GlSbsVOrbkWPJwIDAQAB
-----END PUBLIC KEY-----
./keys/key_private.pem:
-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQDTuNxc37GfLSLR4MTkxKweMLH33cWcu8xc6/2F6H9oLTHYWlaU
4O0o0ez/Wi/CYDtjiQW9A22u2l0ZcDECmx6PjSZkfVJ+9L179OmqE7hRFrUt5ZUG
ik8Sdl1CyAp5H2GS4bImY+vkQzufMcSdtgAdQ9JOjCT6GlSbsVOrbkWPJwIDAQAB
AoGALLU5m0cFS/aNBsKu8RvyuIFR42RqSTmC4xBWPcOlu8rnXqdc5x1EFz2VDSrv
MN1/TPpvQsWJkMW9qRR+1O0Km6U9L4FlMIAaU1U9sLDBAetXiAxxXQVlC1MXWfCm
8Yr4WAumHr6jP8ZdAZwSddTzIw0tx1vfJZr8rsiZrrt5j6kCQQDk26FaeX1Y0Dfw
79YFKPFCYkK1gCZsxRYYbwBAtu4XlX5MGws2TpNQoIbaxdtpUY3v5ZBQaXkKxe7R
T71WRu8jAkEA7NT4B+tqBwR93kHTWIEB0FahMctV5kOyaFnwUksfaHjfxXrL18Nq
VbAEbx2nNdGA3+yVzVyBe9eGw1WJ/ufCLQJBANEScBp2SHO9bI2YnR2DpLvvhl/H
XdMaTbAun71/II29DW87eYe4Ss5qiCgOfv58+b0CLE+5u1GDN0RSo3bRQJ8CQG5Q
2WPe/Vlddz/TC54bIXwpDhbCrzV97Rl8Y1wB0BR60UkMZO0RAnP9dGNJvbxs5Qnp
CvJIl6vW/df4/Tl2PNUCQCJq9DFdwgJKm5apelgT++BuNQ8zxq050bg8HOW+m4QV
mYUo6QbIvR4u9xZjI8nJ+6DJtjf2yUYxO6vbo0Ngtvc=
-----END RSA PRIVATE KEY-----
./sample/original.jpg:SHA256 : 0aa50a87f0a5025ada74b16604c8448bdace0b945a974c50fb365e3bf66ef560
./sample/test.jpg   :SHA256 : 0aa50a87f0a5025ada74b16604c8448bdace0b945a974c50fb365e3bf66ef560
<<Success>>
   ...
   ...
```

<br>
<br>

### 4-2. 検証用スクリプト実行例(PowerShell版)

```
PS D:\work\Example_RSA_by_pycryptodome> cd .\TestScripts\ps1
```

```
PS D:\work\Example_RSA_by_pycryptodome\TestScripts\ps1>.\repeated_main.ps1
#### encypt(public_key) --> decrypt(private_key) ###
args = main.ps1 ./keys/key_public.pem ./keys/key_private.pem ./sample/original.jpg ./sample/test.bin ./sample/test.jpg ./sample/test.sig
Execute: python ../../rsa_main.py createkey
Execute: python ../../rsa_main.py encrypt ./sample/original.jpg ./sample/test.bin ./keys/key_public.pem
Execute: python ../../rsa_main.py signature ./sample/original.jpg ./sample/test.sig ./keys/key_private.pem
./sample/original.jpg[SHA256] : 0aa50a87f0a5025ada74b16604c8448bdace0b945a974c50fb365e3bf66ef560
Execute: python ../../rsa_main.py decrypt ./sample/test.bin ./sample/test.jpg ./keys/key_private.pem
Execute: python ../../rsa_main.py verify ./sample/original.jpg ./sample/test.sig ./keys/key_public.pem
./sample/original.jpg[SHA256] : 0aa50a87f0a5025ada74b16604c8448bdace0b945a974c50fb365e3bf66ef560
Verify OK
./keys/key_public.pem :
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDXfaJwEPLscYCmVhI6RpBQsDVk
54vZZtnkrs0kU3rDUdkEqREWdVwPinmXp2VCxq3Bd6WWeD6IFz1dvGzlqdpFK+TO
AiGs5hYpIrlKEPcuxHog2fl3OjL820itn7XschM6zsrKrYUsxPrwgMAzFFIeGBAM
sEFP+lYvkJrVNXhEFQIDAQAB
-----END PUBLIC KEY-----
./keys/key_private.pem :
-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQDXfaJwEPLscYCmVhI6RpBQsDVk54vZZtnkrs0kU3rDUdkEqREW
dVwPinmXp2VCxq3Bd6WWeD6IFz1dvGzlqdpFK+TOAiGs5hYpIrlKEPcuxHog2fl3
OjL820itn7XschM6zsrKrYUsxPrwgMAzFFIeGBAMsEFP+lYvkJrVNXhEFQIDAQAB
AoGAPtux/3iiM+BkA6FFzeP5gt/zo0x7md4Ln05yHq+PNtxwLpDWoDN5uDrPfzJg
MltcIfwxvDO1IeONjgNBzLiAJ3Y/vZArBmJaQwFn1PcZ6EvILNvJ0H9fSUeqxJC7
ngLjoq2+l6a2SWcndAFtwLqdH+IgjsGpk1ZCJWc0CTk9NB0CQQDpPixVMMNwcAZ/
PrraWFWGbSTjJJT3QWXkROQUFNymYDYvVyfPSk80IWOi+bq9GtD8wAmnVeEIYB5a
NFJCkx8HAkEA7IQO1CEZfSOvxexTh5J4RG6ZAOf509pfvXjZqWil3UX3Of8FJ9Q0
83b2Qb51w8D7q9n7sYmY3KY4S/swRIkhAwJAZYMMsmsNtGLdQQYhNqRZXK8l7cHf
H5mT6fxds6u8uKCJFKN/DQXPYOXjQmwj7Oe96zL9QJns3cNPknzRDG6RgwJBAKWO
zx54SPJK77h49AN7aMpmLJ3ww/Ui8E+d76bhRPF+D0++jqpRpfsis8BThPXQ+ZpT
DRc6fRE/HTs6io/++WcCQGJe32FwRjbtwK9Uuyy008lRnGolbB2FqwvNGcE/xGHq
jQQgXWDCwQdyQTB5ao3zR9IeNzuZqSaOw0n/Q78dNvo=
-----END RSA PRIVATE KEY-----
./sample/original.jpg SHA256 : 0aa50a87f0a5025ada74b16604c8448bdace0b945a974c50fb365e3bf66ef560
./sample/test.jpg    SHA256 : 0aa50a87f0a5025ada74b16604c8448bdace0b945a974c50fb365e3bf66ef560
<<Sucess>>
    ....
    ....
```

<br>
<br>
