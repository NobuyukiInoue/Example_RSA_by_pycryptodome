param($keyfile1, $keyfile2, $file1, $file2, $file3, $mode)

Write-Host "args ="$MyInvocation.MyCommand.Name $keyfile1 $keyfile2 $file1 $file2 $file3 $mode

##--------------------------------------------------------##
## 引数チェック
##--------------------------------------------------------##

if (-Not($keyfile1) -Or -Not($keyfile2) -Or -Not($file1) -Or -Not($file2) -Or -Not($file3)) {
    Write-Host $keyfile1 $keyfile2 $file1 $file2 $file3
    Write-Host "Usage :"$MyInvocation.MyCommand.Name" public_key private_key org_file encrypted_file decrypted_file [mode]"
    exit
}

if (-Not($mode)) {
    $mode = $TRUE
}
else {
    if ($mode -match "TRUE" -Or $mode -match "True" -Or $mode -match "true") {
        $mode = $TRUE
    }
    else {
        $mode = $FALSE
    }
}


##--------------------------------------------------------##
## 検証対象プログラムの指定
##--------------------------------------------------------##

$cmd_rsa_main = "../../rsa_main_by_pycryptodome.py"
$cmd_filehash = "../../print_FileHash.py"


##--------------------------------------------------------##
## 対象ファイルの事前削除
##--------------------------------------------------------##

if (Test-Path $keyfile1) {
    Remove-Item $keyfile1
}

if (Test-Path $keyfile2) {
    Remove-Item $keyfile2
}

if (Test-Path $file2) {
    Remove-Item $file2
}

if (Test-Path $file3) {
    Remove-Item $file3
}


##--------------------------------------------------------##
## 公開鍵／秘密鍵ファイルの生成
##--------------------------------------------------------##

$keyfiles = $keyfile1 + "`n" + $keyfile2 + "`n"

Write-Host "Execute: python"$cmd_rsa_main" create_key"
$keyfiles | python $cmd_rsa_main create_key > $NULL


##--------------------------------------------------------##
## 暗号化処理
##--------------------------------------------------------##

if ($mode) {
    ## 公開鍵で暗号化
    Write-Host "Execute: python $cmd_rsa_main encrypt $file1 $file2 $keyfile1"
    python $cmd_rsa_main encrypt $file1 $file2 $keyfile1
}
else {
    ## 秘密鍵で暗号化
    Write-Host "Execute: python $cmd_rsa_main encrypt $file1 $file2 $keyfile2"
    python $cmd_rsa_main encrypt $file1 $file2 $keyfile2
}


##--------------------------------------------------------##
## 復号処理
##--------------------------------------------------------##

if ($mode) {
    ## 秘密鍵で復号
    Write-Host "Execute: python $cmd_rsa_main decrypt $file2 $file3 $keyfile2"
    python $cmd_rsa_main decrypt $file2 $file3 $keyfile2
}
else {
    ## 公開鍵で復号
    Write-Host "Execute: python $cmd_rsa_main decrypt $file2 $file3 $keyfile1"
    python $cmd_rsa_main decrypt $file2 $file3 $keyfile1
}


##--------------------------------------------------------##
## 鍵ファイルの内容を表示
##--------------------------------------------------------##

Write-Host $keyfile1.PadRight(20)":" -ForegroundColor Yellow
Get-Content $keyfile1

Write-Host $keyfile2.PadRight(20)":" -ForegroundColor Yellow
Get-Content $keyfile2


##--------------------------------------------------------##
## 暗号化前ファイルと復号後ファイルのハッシュ値を出力する
##--------------------------------------------------------##

$result1 = python $cmd_filehash $file1
$result3 = python $cmd_filehash $file3
Write-Host $file1.PadRight(20)$result1 -ForegroundColor Cyan
Write-Host $file3.PadRight(20)$result3 -ForegroundColor Cyan


##--------------------------------------------------------##
## 一致／不一致の結果を表示
##--------------------------------------------------------##

if ($result1 -eq $result3) {
    Write-Host "<<Sucess>>" -ForegroundColor Green
}
else {
    Write-Host "<<Failed>>" -ForegroundColor Red
    
    ##--------------------------------##
    ## 鍵ファイルをバックアップ
    ##--------------------------------##
    $timestamp1=$(Get-ItemProperty $keyfile1).LastWriteTime.ToString('yyyyMMdd_HHmmss')
    $timestamp2=$(Get-ItemProperty $keyfile2).LastWriteTime.ToString('yyyyMMdd_HHmmss')
    $keyfile_backup1 = $keyfile1 + ".err_" + $timestamp1 + ".txt"
    $keyfile_backup2 = $keyfile2 + ".err_" + $timestamp2 + ".txt"
    Copy-Item $keyfile1 $keyfile_backup1
    Copy-Item $keyfile2 $keyfile_backup2
}
