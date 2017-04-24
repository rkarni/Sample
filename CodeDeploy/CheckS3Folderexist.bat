echo off

set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%

echo on

set AWS_DEFAULT_REGION=%AWS_DEFAULT_REGION%

aws s3 ls s3://%S3Bucket%/%Application_Name%/%Source_Environment%/%Source_Revision_Number% > "%workspace%\s3folderexist.txt"
set /p S3folderexist=<"%workspace%\s3folderexist.txt"
echo %S3folderexist%
if "%S3folderexist%" == "" (
echo s3://%S3Bucket%/%Application_Name%/%Source_Environment%/%Source_Revision_Number% folder does not exist in S3. Please check whether Source Revision Number is correct.
exit 1
)
