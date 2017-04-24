$PreviousBackup="D:\ArtifactsBackup\NextGenGateWay\PreviousBackup"
$LatestBackup="D:\ArtifactsBackup\NextGenGateWay\LatestBackup"
$CurrentDeploymentLocation="D:\Artifacts\NextGenGateWay"

$ErrorActionPreference = "Stop"

function DeleteCreateDirectory([string]$folder) {

if (Test-Path $folder) {
Get-ChildItem -Path $folder -Include * | remove-Item -recurse 
} 

if (-not (Test-Path $folder )) {
New-Item -ItemType Directory -Force -Path $folder
}

}

function CopyContent([string]$sourcepath, [string]$destinationpath) {

if (Test-Path $sourcepath) {
#Copy-Item  $sourcepath\* $destinationpath
Get-ChildItem -Path $sourcepath | % { 
  Copy-Item $_.fullname "$destinationpath" -Recurse -Force
}
} 
}

#Delete content in previous Backup directory and if previous directory doesn't exist create the directory
DeleteCreateDirectory -folder $PreviousBackup

#Copy content from Latest backup directory to Previous Backup Directory
CopyContent -sourcepath $LatestBackup -destinationpath $PreviousBackup

#Delete content in Latest Backup directory and if previous directory doesn't exist create the directory
DeleteCreateDirectory -folder $LatestBackup

#Copy content from Latest backup directory to Previous Backup Directory
CopyContent -sourcepath $CurrentDeploymentLocation -destinationpath $LatestBackup

#Delete content in previous Backup directory and if previous directory doesn't exist create the directory
DeleteCreateDirectory -folder $CurrentDeploymentLocation
