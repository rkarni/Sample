param(
    [Parameter(Mandatory=$true)]
    [string]$Environment,

    [Parameter(Mandatory=$true)]
    [string]$TransformFile,

    [Parameter(Mandatory=$true)]
    [string]$ApplicationLocation,

    [Parameter(Mandatory=$true)]
    [string]$Passkey,
	[Parameter(Mandatory=$true)]
    [string]$Application
)

$ErrorActionPreference = "Stop"

$transformScriptFile = Join-Path $PSScriptRoot "Transform.ps1"
$input = Join-Path $ApplicationLocation "Web.config"

& $transformScriptFile -InputFile $input -OutputFile $input -Script $(Join-Path $PSScriptRoot "$Application\Values\$Environment\$TransformFile") -Passkey $Passkey
