echo on

set Folder_Name=%1

robocopy %WORKSPACE%\%GIT_FOLDER_NAME%\Deployment\CodeDeploy\Appspec\%Folder_Name% %WORKSPACE%\Artifacts\%Environment%\%Application_Name%\%Folder_Name% /s

exit 0