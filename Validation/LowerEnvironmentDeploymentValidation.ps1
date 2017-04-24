

param(
    [Parameter(Mandatory=$true)]
    [string]$FileName,

    [Parameter(Mandatory=$true)]
    [string]$Value


)

$ErrorActionPreference = "Stop"

function Validate-LowerDeployment([string]$FileName, [string]$Value) {


    $folder = Join-Path $env:workspace "Artifacts\$env:Environment\$env:Application_Name"
    $deployedfolders=get-childitem $folder -dir

    if (-not $FileName) {
        throw "The file name cannot be empty"
    }

     $val = [Boolean]::Parse($Value)
     $check=0
	 if ($val) {
	 
     foreach ($foldername in $deployedfolders) {

          if (($FileName -eq $foldername) -and ($val)) {
            $check=1
            break
        }
        

     }
     if ($check -eq 0) {
        Write-Output "$FileName is not deployed in lower environment. Please check it."
        exit 1
     }
	 }


 }
 
Validate-LowerDeployment -FileName $FileName -Value $Value