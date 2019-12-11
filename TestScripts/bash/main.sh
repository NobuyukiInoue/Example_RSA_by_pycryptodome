#!/bin/bash

##--------------------------------------------------------##
## 引数チェック
##--------------------------------------------------------##

printf "args = ${0} ${1} ${2} ${3} ${4} ${5} ${6}\n"

if [ $# -lt 6 ]; then
    printf "Usage) ${0} keyfile_public keyfile_private org_file encrypted_file decrypted_file file_signature\n"
    exit
fi

keyfile_public=${1}
keyfile_private=${2}
file_source=${3}
file_encrypted=${4}
file_decrypted=${5}
file_signature=${6}


##--------------------------------------------------------##
## 検証対象プログラムの指定
##--------------------------------------------------------##

cmd_rsa_main="../../rsa_main.py"
cmd_filehash="../../print_FileHash.py"


##--------------------------------------------------------##
## 対象ファイルの事前削除
##--------------------------------------------------------##

if [ -f $keyfile_public ]; then
    rm $keyfile_public
fi

if [ -f $keyfile_private ]; then
    rm $keyfile_private
fi

if [ -f $file_encrypted ]; then
    rm $file_encrypted
fi

if [ -f $file_decrypted ]; then
    rm $file_decrypted
fi

if [ -f $file_signature ]; then
    rm $file_signature
fi


##--------------------------------------------------------##
## 公開鍵／秘密鍵ファイルの生成
##--------------------------------------------------------##

printf "Execute: python $cmd_rsa_main createkey\n"

python $cmd_rsa_main createkey 1> /dev/null << EOS
$keyfile_public
$keyfile_private
EOS


##--------------------------------------------------------##
## 暗号化処理
##--------------------------------------------------------##

## 公開鍵で暗号化
printf "Execute: python $cmd_rsa_main encrypt $file_source $file_encrypted $keyfile_public\n"
python $cmd_rsa_main encrypt $file_source $file_encrypted $keyfile_public


##--------------------------------------------------------##
## 電子署名の生成
##--------------------------------------------------------##

## 公開鍵で暗号化
printf "Execute: python $cmd_rsa_main signature $file_source $file_signature $keyfile_private\n"
python $cmd_rsa_main signature $file_source $file_signature $keyfile_private


##--------------------------------------------------------##
## 復号処理
##--------------------------------------------------------##

## 秘密鍵で復号
printf "Execute: python $cmd_rsa_main decrypt $file_encrypted $file_decrypted $keyfile_private\n"
python $cmd_rsa_main decrypt $file_encrypted $file_decrypted $keyfile_private


##--------------------------------------------------------##
## 電子署名の照合
##--------------------------------------------------------##

## 秘密鍵で暗号化
printf "Execute: python $cmd_rsa_main verify $file_source $file_signature $keyfile_public\n"
python $cmd_rsa_main verify $file_source $file_signature $keyfile_public


##--------------------------------------------------------##
## 鍵ファイルの内容を表示
##--------------------------------------------------------##

printf "\033[0;33m"
printf "%-20s:\n" $keyfile_public
cat $keyfile_public

printf "\n"
printf "%-20s:\n" $keyfile_private
cat $keyfile_private

printf "\033[0;39m"
printf "\n"


##--------------------------------------------------------##
## 暗号化前ファイルと復号後ファイルのハッシュ値を出力する
##--------------------------------------------------------##

result1=`python $cmd_filehash $file_source`
result3=`python $cmd_filehash $file_decrypted`

printf "\033[0;36m"
printf "%-20s:" $file_source
printf "$result1\n"
printf "%-20s:" $file_decrypted
printf "$result3\n"
printf "\033[0;39m"


##--------------------------------------------------------##
## 一致／不一致の結果を表示
##--------------------------------------------------------##

if [ "$result1" = "$result3" ]; then
    printf "\033[0;32m<<Success>>\033[0;39m\n"
else
    printf "\033[0;31m<<Failed>>\033[0;39m\n"

    ## 鍵ファイルをバックアップ
    timestamp1=`date +%Y%m%d%H%M%S -r $keyfile_public`
    timestamp2=`date +%Y%m%d%H%M%S -r $keyfile_private`
    cp -p $keyfile_public $keyfile_public.err_$timestamp1".txt"
    cp -p $keyfile_private $keyfile_private.err_$timestamp2".txt"
fi
