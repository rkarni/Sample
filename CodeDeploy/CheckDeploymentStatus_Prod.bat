echo off

set AWS_ACCESS_KEY_ID=%HIGHER_ENV_AWS_ACCESS_KEY_ID%
set AWS_SECRET_ACCESS_KEY=%HIGHER_ENV_AWS_SECRET_ACCESS_KEY%
set AWS_DEFAULT_REGION=%AWS_DEFAULT_REGION%

echo on

set /p deploymentid=<"%workspace%\deploymentid.txt"

echo Deployment-ID=%deploymentid%

:result
rem timeout 20
aws deploy get-deployment --deployment-id %deploymentid% --query "deploymentInfo.status" --output text > "%workspace%\result.txt"

set /p result=<"%workspace%\result.txt"

echo DeploymentResultStatus=%result%

if "%result%" == "Failed" ( exit 1 )

if "%result%" NEQ "Succeeded" (goto :result)
