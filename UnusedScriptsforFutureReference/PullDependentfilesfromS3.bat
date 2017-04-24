echo off

set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%

echo on

set AWS_DEFAULT_REGION=%AWS_DEFAULT_REGION%

set folderpath=%1
set DependencyFolder=%2

if not exist "%workspace%\Artifacts\%Environment%\%Application_Name%\%folderpath%\%DependencyFolder%" mkdir "%workspace%\Artifacts\%Environment%\%Application_Name%\%folderpath%\%DependencyFolder%"
cd %workspace%\Artifacts\%Environment%\%Application_Name%\%folderpath%\%DependencyFolder%

aws s3 cp s3://%S3MozartDependencies%/%DependencyFolder% . --recursive