# Example_RSA

PyCryptodomeを使用して暗号化／復号および電子署名の生成／復号を行うプログラムです。

* 公開鍵で暗号化し、秘密鍵で復号する（暗号化データの送受信）

ことができます。

そのほか、元ファイルと復号後のファイルの内容のチェック用に、ファイルのハッシュ値を出力するプログラムとして、

* ファイルのハッシュ値出力ツール print_FileHash.py

を用意しています。
<br>
<br>

### 1. 鍵ペア（秘密鍵／公開鍵ファイル）の生成（rsa_main_by_pycryptodome.py）

公開鍵／秘密鍵を生成します。
生成された鍵は、デフォルトではそれぞれ"key_public.pem", "key_private.pem"というファイルに出力されます。

```
$ python rsa_main_by_pycryptodome.py create_key
Public key filename [key_public.pem]:
Private key filename [key_private.pem]:
Create Keys done.
```

<br>
<br>

### 2. 元ファイルから暗号化ファイルを生成する（rsa_main_by_pycryptodome.py）

"rsa_main_by_pycryptodome.py encrypt"に続けて、暗号化したい元ファイル名、暗号化後のファイル名、公開鍵ファイルを指定して
rsa_main_by_pycryptodome.pyを実行します。

```
$ python rsa_main_by_pycryptodome.py encrypt 暗号化したい元ファイル名 暗号化後のファイル名 公開鍵ファイル
```

<br>
<br>

### 3. 暗号化後のファイルから元のファイルを復号する（rsa_main_by_pycryptodome.py）

"rsa_main_by_pycryptodome.py decrypt"に続けて、暗号化後のファイル名、復号後のファイル名、秘密鍵ファイルを指定して
rsa_main_by_pycryptodome.pyを実行します。

```
$ python rsa_main_by_pycryptodome.py decrypt 暗号化後の出力結果ファイル 復号後のファイル名 秘密鍵ファイル
```

<br>
<br>

### 4. 暗号化と復号の実行例（rsa_main_by_pycryptodome.py）

暗号化処理例

```
$ python rsa_main_by_pycryptodome.py encrypt image1.jpg testimage.bin key_public.pem
```

復号処理例

```
$ python rsa_main_by_pycryptodome.py decrypt testimage.bin image2.jpg key_private.pem
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
* ./TestScripts_mode_bin/bash/repeated_main_mode_bin.sh ... 親側スクリプト
* ./TestScripts_mode_bin/bash/test_mode_bin.sh ... 鍵の生成、暗号化、復号を１回だけ実行
<br>

### PowerShell版
* ./TestScripts_mode_bin/ps1/repeated_main_mode_bin.ps1 ... 親側スクリプト
* ./TestScripts_mode_bin/ps1/test_mode_bin.ps1 ... 鍵の生成、暗号化、復号を１回だけ実行
<br>


### 3-1. 検証用スクリプト実行例(bash版)

```
$ cd TestScripts_mode_bin/bash
```

```
$ ./repeated_main_mode_bin.sh
#### encypt(public_key) --> decrypt(private_key) ###
args = ./repeated_test.sh key1.key key2.key ./original.jpg ./test.bin ./test.jpg
Execute: python ../../rsa_main_by_pycryptodome.py create_key
Execute: python ../../rsa_main_by_pycryptodome.py encrypt ./original.jpg ./test.bin key1.key
Execute: python ../../rsa_main_by_pycryptodome.py decrypt ./test.bin ./test.jpg key2.key
key1.key            :390703,4562471
key2.key            :7,4562471
./original.jpg      :MD5 : 351efe5e4d33d7ca16c86b3137c78011
./test.jpg          :MD5 : 351efe5e4d33d7ca16c86b3137c78011
<<Success>>
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
#### encypt(public_key) --> decrypt(private_key) ###
args = repeated_test.ps1 ./key1.key ./key2.key ./original.jpg ./test.bin ./test.jpg
Execute: python ../../rsa_main_by_pycryptodome.py create_key
Execute: python ../../rsa_main_by_pycryptodome.py encrypt ./original.jpg ./test.bin ./key1.key
Execute: python ../../rsa_main_by_pycryptodome.py decrypt ./test.bin ./test.jpg ./key2.key
./key1.key           : 5,6107737
./key2.key           : 813701,6107737
./original.jpg       MD5 : 351efe5e4d33d7ca16c86b3137c78011
./test.jpg           MD5 : 351efe5e4d33d7ca16c86b3137c78011
<<Sucess>>
    ....
    ....
```

<br>
<br>
