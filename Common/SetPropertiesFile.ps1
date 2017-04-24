# The following prepares the .properties file that used as an evidence that particular downstream job must be built.

param(
    [Parameter(Mandatory=$true)]
    [string]$FileName,

    [Parameter(Mandatory=$true)]
    [string]$Value


)

$ErrorActionPreference = "Stop"

function Update-PropertyFile([string]$FileName, [string]$Value) {
    if (-not $FileName) {
        throw "The file name cannot be empty"
    }

    $fn = Join-Path $env:workspace "$FileName.properties"
    $val = [Boolean]::Parse($Value)

    if ((Test-Path $fn) -and (-not $val)) {
        Remove-Item $fn
    }
    elseif (-not (Test-Path $fn) -and $val) {
        $null > $fn
    }
}

Update-PropertyFile -FileName $FileName -Value $Value