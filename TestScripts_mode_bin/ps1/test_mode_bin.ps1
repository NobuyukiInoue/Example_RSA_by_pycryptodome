param($keyfile1, $keyfile2, $file1, $file2, $file3, $mode)

Write-Host "args ="$MyInvocation.MyCommand.Name $keyfile1 $keyfile2 $file1 $file2 $file3 $mode

##--------------------------------------------------------##
## �����`�F�b�N
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
## ���ؑΏۃv���O�����̎w��
##--------------------------------------------------------##

$cmd_rsa_main = "../../rsa_main_by_pycryptodome.py"
$cmd_filehash = "../../print_FileHash.py"


##--------------------------------------------------------##
## �Ώۃt�@�C���̎��O�폜
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
## ���J���^�閧���t�@�C���̐���
##--------------------------------------------------------##

$keyfiles = $keyfile1 + "`n" + $keyfile2 + "`n"

Write-Host "Execute: python"$cmd_rsa_main" create_key"
$keyfiles | python $cmd_rsa_main create_key > $NULL


##--------------------------------------------------------##
## �Í�������
##--------------------------------------------------------##

if ($mode) {
    ## ���J���ňÍ���
    Write-Host "Execute: python $cmd_rsa_main encrypt $file1 $file2 $keyfile1"
    python $cmd_rsa_main encrypt $file1 $file2 $keyfile1
}
else {
    ## �閧���ňÍ���
    Write-Host "Execute: python $cmd_rsa_main encrypt $file1 $file2 $keyfile2"
    python $cmd_rsa_main encrypt $file1 $file2 $keyfile2
}


##--------------------------------------------------------##
## ��������
##--------------------------------------------------------##

if ($mode) {
    ## �閧���ŕ���
    Write-Host "Execute: python $cmd_rsa_main decrypt $file2 $file3 $keyfile2"
    python $cmd_rsa_main decrypt $file2 $file3 $keyfile2
}
else {
    ## ���J���ŕ���
    Write-Host "Execute: python $cmd_rsa_main decrypt $file2 $file3 $keyfile1"
    python $cmd_rsa_main decrypt $file2 $file3 $keyfile1
}


##--------------------------------------------------------##
## ���t�@�C���̓��e��\��
##--------------------------------------------------------##

Write-Host $keyfile1.PadRight(20)":" -ForegroundColor Yellow
Get-Content $keyfile1

Write-Host $keyfile2.PadRight(20)":" -ForegroundColor Yellow
Get-Content $keyfile2


##--------------------------------------------------------##
## �Í����O�t�@�C���ƕ�����t�@�C���̃n�b�V���l���o�͂���
##--------------------------------------------------------##

$result1 = python $cmd_filehash $file1
$result3 = python $cmd_filehash $file3
Write-Host $file1.PadRight(20)$result1 -ForegroundColor Cyan
Write-Host $file3.PadRight(20)$result3 -ForegroundColor Cyan


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
    $timestamp1=$(Get-ItemProperty $keyfile1).LastWriteTime.ToString('yyyyMMdd_HHmmss')
    $timestamp2=$(Get-ItemProperty $keyfile2).LastWriteTime.ToString('yyyyMMdd_HHmmss')
    $keyfile_backup1 = $keyfile1 + ".err_" + $timestamp1 + ".txt"
    $keyfile_backup2 = $keyfile2 + ".err_" + $timestamp2 + ".txt"
    Copy-Item $keyfile1 $keyfile_backup1
    Copy-Item $keyfile2 $keyfile_backup2
}
