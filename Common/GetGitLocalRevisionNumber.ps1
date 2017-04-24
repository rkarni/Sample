
$gitlogfile = Get-Content -Path $env:workspace\$env:GIT_FOLDER_NAME\.git\refs\heads\$env:GIT_BRANCH | Select-Object -First 1
$localrevision = $gitlogfile.Substring(0,7)
$localrevisionnumber ='localrevisionnumber = ' + $localrevision
$Environment ='Environment = ' + $env:Environment
$GIT_BRANCH ='GIT_BRANCH = ' + $env:GIT_BRANCH

$ErrorActionPreference = "Stop"

$localrevisionnumber | Set-Content $env:workspace\$env:Deployment_Details_File.Properties
$Environment | Add-Content $env:workspace\$env:Deployment_Details_File.Properties
$GIT_BRANCH | Add-Content $env:workspace\$env:Deployment_Details_File.Properties