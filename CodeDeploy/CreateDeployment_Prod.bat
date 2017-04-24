echo off

set AWS_ACCESS_KEY_ID=%HIGHER_ENV_AWS_ACCESS_KEY_ID%
set AWS_SECRET_ACCESS_KEY=%HIGHER_ENV_AWS_SECRET_ACCESS_KEY%

echo on

set AWS_DEFAULT_REGION=%AWS_DEFAULT_REGION%



set Folder_Name=%1
set AWSCodeDeployApplicationName=%Application_Name%_%Environment%
aws deploy create-deployment --application-name %AWSCodeDeployApplicationName% --deployment-config-name %AWSCodeDeployDeploymentConfig% --deployment-group-name %Folder_Name% --description "%DLLVersionNumber%_%localrevisionnumber%_%Environment%" --s3-location bucket=%S3Bucket_Prod%,bundleType=zip,key=%Application_Name%/%Environment%/%DLLVersionNumber%_%localrevisionnumber%/%Folder_Name%/%Folder_Name%.zip --output text > "%workspace%\deploymentid.txt"
