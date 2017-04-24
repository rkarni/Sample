echo off

set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%

echo on

set AWS_DEFAULT_REGION=%AWS_DEFAULT_REGION%

set Folder_Name=%1
set AWSCodeDeployApplicationName=%Application_Name%_%Environment%
aws deploy push --application-name %AWSCodeDeployApplicationName% --description "%DLLVersionNumber%_%localrevisionnumber%_%Environment%" --s3-location s3://%S3Bucket%/%Application_Name%/%Environment%/%DLLVersionNumber%_%localrevisionnumber%/%Folder_Name%/%Folder_Name%.zip --source %workspace%\Artifacts\%Environment%\%Application_Name%\%Folder_Name%
