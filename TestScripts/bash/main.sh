#!/bin/bash

##--------------------------------------------------------##
## 引数チェック
##--------------------------------------------------------##

printf "args = ${0} ${1} ${2} ${3} ${4} ${5} ${6}\n"

if [ $# -lt 5 ]; then
    printf "Usage) ${0} keyfile1 keyfile2 org_file encrypted_file decrypted_file [mode]\n"
    exit
fi

keyfile1=${1}
keyfile2=${2}
file1=${3}
file2=${4}
file3=${5}

if [ $# -ge 6 ]; then
    mode=${6}
else
    mode=1
fi


##--------------------------------------------------------##
## 検証対象プログラムの指定
##--------------------------------------------------------##

cmd_rsa_main="../../rsa_main.py"
cmd_filehash="../../print_FileHash.py"


##--------------------------------------------------------##
## 対象ファイルの事前削除
##--------------------------------------------------------##

if [ -f $keyfile1 ]; then
    rm $keyfile1
fi

if [ -f $keyfile2 ]; then
    rm $keyfile2
fi

if [ -f $file2 ]; then
    rm $file2
fi

if [ -f $file3 ]; then
    rm $file3
fi


##--------------------------------------------------------##
## 公開鍵／秘密鍵ファイルの生成
##--------------------------------------------------------##

printf "Execute: python $cmd_rsa_main create_key\n"

python $cmd_rsa_main create_key 1> /dev/null << EOS
$keyfile1
$keyfile2
EOS


##--------------------------------------------------------##
## 暗号化処理
##--------------------------------------------------------##

if [ $mode -eq 1 ]; then
    ## 公開鍵で暗号化
    printf "Execute: python $cmd_rsa_main encrypt $file1 $file2 $keyfile1\n"
    python $cmd_rsa_main encrypt $file1 $file2 $keyfile1
else
    ## 秘密鍵で暗号化
    printf "Execute: python $cmd_rsa_main encrypt $file1 $file2 $keyfile2\n"
    python $cmd_rsa_main encrypt $file1 $file2 $keyfile2
fi


##--------------------------------------------------------##
## 復号処理
##--------------------------------------------------------##

if [ $mode -eq 1 ]; then
    ## 秘密鍵で復号
    printf "Execute: python $cmd_rsa_main decrypt $file2 $file3 $keyfile2\n"
    python $cmd_rsa_main decrypt $file2 $file3 $keyfile2
else
    ## 公開鍵で復号
    printf "Execute: python $cmd_rsa_main decrypt $file2 $file3 $keyfile1\n"
    python $cmd_rsa_main decrypt $file2 $file3 $keyfile1
fi


##--------------------------------------------------------##
## 鍵ファイルの内容を表示
##--------------------------------------------------------##

printf "\033[0;33m"
printf "%-20s:\n" $keyfile1
cat $keyfile1

printf "\n"
printf "%-20s:\n" $keyfile2
cat $keyfile2

printf "\033[0;39m"
printf "\n"


##--------------------------------------------------------##
## 暗号化前ファイルと復号後ファイルのハッシュ値を出力する
##--------------------------------------------------------##

result1=`python $cmd_filehash $file1`
result3=`python $cmd_filehash $file3`

printf "\033[0;36m"
printf "%-20s:" $file1
printf "$result1\n"
printf "%-20s:" $file3
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
    timestamp1=`date +%Y%m%d%H%M%S -r $keyfile1`
    timestamp2=`date +%Y%m%d%H%M%S -r $keyfile2`
    cp -p $keyfile1 $keyfile1.err_$timestamp1".txt"
    cp -p $keyfile2 $keyfile2.err_$timestamp2".txt"
fi
