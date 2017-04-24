$folder="$env:workspace\Artifacts\$env:Environment\$env:Application_Name"

$ErrorActionPreference = "Stop"

if (Test-Path $folder) {

 #Remove-Item $folder -Recurse

Get-ChildItem -Path $folder -Include * | remove-Item -recurse 
} 
else
{

New-Item -ItemType Directory -Force -Path $folder
}

#If(!(test-path $folder))
#{
#New-Item -ItemType Directory -Force -Path $folder
#}
