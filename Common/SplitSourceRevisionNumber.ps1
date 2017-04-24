$ErrorActionPreference = "Stop"

$SourceRevisionNumber = $env:Source_Revision_Number

$VersionNumber,$shacode = $SourceRevisionNumber.split('_')
$VersionNumber
$shacode

$DLLVersionNumber = 'DLLVersionNumber = ' + $VersionNumber
$DLLVersionNumber | Add-Content $env:workspace\$env:Deployment_Details_File.Properties

