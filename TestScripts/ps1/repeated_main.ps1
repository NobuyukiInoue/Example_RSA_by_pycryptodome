$cmd = "./main.ps1"
$keyfile1 = "./keys/key_public.pem"
$keyfile2 = "./keys/key_private.pem"
$file1 = "./sample/original.jpg"
$file2 = "./sample/test.bin"
$file3 = "./sample/test.jpg"
$file4 = "./sample/test.sig"

$loopCount = 10

Write-Host "#### encypt(public_key) --> decrypt(private_key) ###" -ForegroundColor Magenta

for ($i = 0; $i -lt $loopCount; $i++) {
    &$cmd $keyfile1 $keyfile2 $file1 $file2 $file3 $file4
}
