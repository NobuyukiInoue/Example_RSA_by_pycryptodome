$cmd = "./main.ps1"
$keyfile1 = "./key_public.pem"
$keyfile2 = "./key_private.pem"
$file1 = "./original.jpg"
$file2 = "./test.bin"
$file3 = "./test.jpg"

$loopCount = 10

Write-Host "#### encypt(public_key) --> decrypt(private_key) ###" -ForegroundColor Magenta

for ($i = 0; $i -lt $loopCount; $i++) {
    &$cmd $keyfile1 $keyfile2 $file1 $file2 $file3
}
