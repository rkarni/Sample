echo off

set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%

echo on

set AWS_DEFAULT_REGION=%AWS_DEFAULT_REGION%

if not exist "%workspace%\Artifacts\%Environment%\%Application_Name%" mkdir "%workspace%\Artifacts\%Environment%\%Application_Name%"
cd %workspace%\Artifacts\%Environment%\%Application_Name%

aws s3 cp s3://%S3Bucket%/%Application_Name%/%Source_Environment%/%Source_Revision_Number% . --recursive
