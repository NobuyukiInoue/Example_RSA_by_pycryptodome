param($keyfile_public, $keyfile_private, $file_source, $file_encrypted, $file_decrypted, $file_signature)

Write-Host "args ="$MyInvocation.MyCommand.Name $keyfile_public $keyfile_private $file_source $file_encrypted $file_decrypted $file_signature

##--------------------------------------------------------##
## 引数チェック
##--------------------------------------------------------##

if (-Not($keyfile_public) -Or -Not($keyfile_private) -Or -Not($file_source) -Or -Not($file_encrypted) -Or -Not($file_decrypted) -Or -Not($file_signature)) {
    Write-Host $keyfile_public $keyfile_private $file_source $file_encrypted $file_decrypted $file_signature
    Write-Host "Usage :"$MyInvocation.MyCommand.Name" public_key private_key org_file encrypted_file decrypted_file signature_file [mode]"
    exit
}


##--------------------------------------------------------##
## 検証対象プログラムの指定
##--------------------------------------------------------##

$cmd_rsa_main = "../../rsa_main.py"
$cmd_filehash = "../../print_FileHash.py"


##--------------------------------------------------------##
## 対象ファイルの事前削除
##--------------------------------------------------------##

if (Test-Path $keyfile_public) {
    Remove-Item $keyfile_public
}

if (Test-Path $keyfile_private) {
    Remove-Item $keyfile_private
}

if (Test-Path $file_encrypted) {
    Remove-Item $file_encrypted
}

if (Test-Path $file_decrypted) {
    Remove-Item $file_decrypted
}

if (Test-Path $file_signature) {
    Remove-Item $file_signature
}


##--------------------------------------------------------##
## 公開鍵／秘密鍵ファイルの生成
##--------------------------------------------------------##

$keyfiles = $keyfile_public + "`n" + $keyfile_private + "`n"

Write-Host "Execute: python"$cmd_rsa_main" createkey"
$keyfiles | python $cmd_rsa_main createkey > $NULL


##--------------------------------------------------------##
## 暗号化処理
##--------------------------------------------------------##

## 公開鍵で暗号化
Write-Host "Execute: python $cmd_rsa_main encrypt $file_source $file_encrypted $keyfile_public"
python $cmd_rsa_main encrypt $file_source $file_encrypted $keyfile_public


##--------------------------------------------------------##
## 電子署名の生成
##--------------------------------------------------------##

## 電子署名の生成
Write-Host "Execute: python $cmd_rsa_main signature $file_source $file_signature $keyfile_private"
python $cmd_rsa_main signature $file_source $file_signature $keyfile_private


##--------------------------------------------------------##
## 復号処理
##--------------------------------------------------------##

## 秘密鍵で復号
Write-Host "Execute: python $cmd_rsa_main decrypt $file_encrypted $file_decrypted $keyfile_private"
python $cmd_rsa_main decrypt $file_encrypted $file_decrypted $keyfile_private


##--------------------------------------------------------##
## 電子署名の照合
##--------------------------------------------------------##

## 電子署名の照合
Write-Host "Execute: python $cmd_rsa_main verify $file_source $file_signature $keyfile_public"
python $cmd_rsa_main verify $file_source $file_signature $keyfile_public


##--------------------------------------------------------##
## 鍵ファイルの内容を表示
##--------------------------------------------------------##

Write-Host $keyfile_public.PadRight(20)":" -ForegroundColor Yellow
Get-Content $keyfile_public

Write-Host $keyfile_private.PadRight(20)":" -ForegroundColor Yellow
Get-Content $keyfile_private


##--------------------------------------------------------##
## 暗号化前ファイルと復号後ファイルのハッシュ値を出力する
##--------------------------------------------------------##

$result1 = python $cmd_filehash $file_source
$result3 = python $cmd_filehash $file_decrypted
Write-Host $file_source.PadRight(25)$result1 -ForegroundColor Cyan
Write-Host $file_decrypted.PadRight(25)$result3 -ForegroundColor Cyan


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
    $timestamp1=$(Get-ItemProperty $keyfile_public).LastWriteTime.ToString('yyyyMMdd_HHmmss')
    $timestamp2=$(Get-ItemProperty $keyfile_private).LastWriteTime.ToString('yyyyMMdd_HHmmss')
    $keyfile_backup1 = $keyfile_public + ".err_" + $timestamp1 + ".txt"
    $keyfile_backup2 = $keyfile_private + ".err_" + $timestamp2 + ".txt"
    Copy-Item $keyfile_public $keyfile_backup1
    Copy-Item $keyfile_private $keyfile_backup2
}
