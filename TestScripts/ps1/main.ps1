param($keyfile_public, $keyfile_private, $file_source, $file_encrypted, $file_decrypted, $file_signature)

Write-Host "args ="$MyInvocation.MyCommand.Name $keyfile_public $keyfile_private $file_source $file_encrypted $file_decrypted $file_signature

##--------------------------------------------------------##
## �����`�F�b�N
##--------------------------------------------------------##

if (-Not($keyfile_public) -Or -Not($keyfile_private) -Or -Not($file_source) -Or -Not($file_encrypted) -Or -Not($file_decrypted) -Or -Not($file_signature)) {
    Write-Host $keyfile_public $keyfile_private $file_source $file_encrypted $file_decrypted $file_signature
    Write-Host "Usage :"$MyInvocation.MyCommand.Name" public_key private_key org_file encrypted_file decrypted_file signature_file [mode]"
    exit
}


##--------------------------------------------------------##
## ���ؑΏۃv���O�����̎w��
##--------------------------------------------------------##

$cmd_rsa_main = "../../rsa_main.py"
$cmd_filehash = "../../print_FileHash.py"


##--------------------------------------------------------##
## �Ώۃt�@�C���̎��O�폜
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
## ���J���^�閧���t�@�C���̐���
##--------------------------------------------------------##

$keyfiles = $keyfile_public + "`n" + $keyfile_private + "`n"

Write-Host "Execute: python"$cmd_rsa_main" createkey"
$keyfiles | python $cmd_rsa_main createkey > $NULL


##--------------------------------------------------------##
## �Í�������
##--------------------------------------------------------##

## ���J���ňÍ���
Write-Host "Execute: python $cmd_rsa_main encrypt $file_source $file_encrypted $keyfile_public"
python $cmd_rsa_main encrypt $file_source $file_encrypted $keyfile_public


##--------------------------------------------------------##
## �d�q�����̐���
##--------------------------------------------------------##

## �d�q�����̐���
Write-Host "Execute: python $cmd_rsa_main signature $file_source $file_signature $keyfile_private"
python $cmd_rsa_main signature $file_source $file_signature $keyfile_private


##--------------------------------------------------------##
## ��������
##--------------------------------------------------------##

## �閧���ŕ���
Write-Host "Execute: python $cmd_rsa_main decrypt $file_encrypted $file_decrypted $keyfile_private"
python $cmd_rsa_main decrypt $file_encrypted $file_decrypted $keyfile_private


##--------------------------------------------------------##
## �d�q�����̏ƍ�
##--------------------------------------------------------##

## �d�q�����̏ƍ�
Write-Host "Execute: python $cmd_rsa_main verify $file_source $file_signature $keyfile_public"
python $cmd_rsa_main verify $file_source $file_signature $keyfile_public


##--------------------------------------------------------##
## ���t�@�C���̓��e��\��
##--------------------------------------------------------##

Write-Host $keyfile_public.PadRight(20)":" -ForegroundColor Yellow
Get-Content $keyfile_public

Write-Host $keyfile_private.PadRight(20)":" -ForegroundColor Yellow
Get-Content $keyfile_private


##--------------------------------------------------------##
## �Í����O�t�@�C���ƕ�����t�@�C���̃n�b�V���l���o�͂���
##--------------------------------------------------------##

$result1 = python $cmd_filehash $file_source
$result3 = python $cmd_filehash $file_decrypted
Write-Host $file_source.PadRight(25)$result1 -ForegroundColor Cyan
Write-Host $file_decrypted.PadRight(25)$result3 -ForegroundColor Cyan


##--------------------------------------------------------##
## ��v�^�s��v�̌��ʂ�\��
##--------------------------------------------------------##

if ($result1 -eq $result3) {
    Write-Host "<<Sucess>>" -ForegroundColor Green
}
else {
    Write-Host "<<Failed>>" -ForegroundColor Red
    
    ##--------------------------------##
    ## ���t�@�C�����o�b�N�A�b�v
    ##--------------------------------##
    $timestamp1=$(Get-ItemProperty $keyfile_public).LastWriteTime.ToString('yyyyMMdd_HHmmss')
    $timestamp2=$(Get-ItemProperty $keyfile_private).LastWriteTime.ToString('yyyyMMdd_HHmmss')
    $keyfile_backup1 = $keyfile_public + ".err_" + $timestamp1 + ".txt"
    $keyfile_backup2 = $keyfile_private + ".err_" + $timestamp2 + ".txt"
    Copy-Item $keyfile_public $keyfile_backup1
    Copy-Item $keyfile_private $keyfile_backup2
}
