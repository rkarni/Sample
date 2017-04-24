param(
    [Parameter(Mandatory=$true)]
    [string]$Environment,

    [Parameter(Mandatory=$true)]
    [string]$PackageLocation,

    [Parameter(Mandatory=$true)]
    [string]$Passkey
)

$ErrorActionPreference = "Stop"

$transformFile = Join-Path $PSScriptRoot "Transform.ps1"

function Update-Configuration([string]$TransformFileName, [string]$PropertiesFileName) {
    Write-Verbose "Processing configuration file `"$TransformFileName`""
    $input = Get-ChildItem -Path $PackageLocation -Recurse -File -Filter $TransformFileName | Select-Object -First 1
    & $transformFile -InputFile $($input.FullName) -OutputFile $($input.FullName) -Script $(Join-Path $PSScriptRoot "Values\$Environment\$PropertiesFileName") -Passkey $Passkey
}

Update-Configuration -TransformFileName "Verisk.Mozart.WordAddInExpress.Common.dll.config.deploy" "Verisk.Mozart.WordAddInExpress.Common.transform.xml"
Update-Configuration -TransformFileName "Verisk.Mozart.WordAddInExpress.dll.config.deploy" "Verisk.Mozart.WordAddInExpress.transform.xml"
Update-Configuration -TransformFileName "Verisk.Mozart.WordAddInLauncher.exe.config.deploy" "Verisk.Mozart.WordAddInLauncher.transform.xml"
