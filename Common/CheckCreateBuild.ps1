param(
    [Parameter ()]
    [String]$CREATE_BUILD = "false"
    
)

$CREATE_BUILD = [Boolean]::Parse($CREATE_BUILD)
$CREATE_BUILD ='CREATE_BUILD = ' + $CREATE_BUILD

$ErrorActionPreference = "Stop"

$CREATE_BUILD | Add-Content $env:workspace\$env:Deployment_Details_File.Properties