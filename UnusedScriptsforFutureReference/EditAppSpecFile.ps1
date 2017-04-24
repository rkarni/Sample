param(

    [Parameter(Mandatory=$true)]
    [string]$Environment,

	[Parameter(Mandatory=$true)]
    [string]$AppSpecFile
)

$ErrorActionPreference = "Stop"

if (Test-Path $AppSpecFile) {

$doc = (Get-Content $AppSpecFile)


(Get-Content $AppSpecFile) | Foreach-Object {
    if ($Environment -ne "PROD")
    {
    $_ -replace '_Environment', "_$Environment" `
    }
    if ($Environment -eq "PROD")
    {
        $_ -replace '_Environment', "" `
    }
    } | Set-Content $AppSpecFile


}
