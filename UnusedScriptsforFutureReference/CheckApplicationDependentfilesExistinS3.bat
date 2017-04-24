echo off

set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%

echo on

set AWS_DEFAULT_REGION=%AWS_DEFAULT_REGION%

set DependencyFolder=%1

aws s3 ls s3://%S3MozartDependencies%/%DependencyFolder% > "%workspace%\s3dependencyfolderexist.txt"
set /p s3dependencyfolderexist=<"%workspace%\s3dependencyfolderexist.txt"
echo %s3dependencyfolderexist%
if "%s3dependencyfolderexist%" == "" (
echo s3://%S3MozartDependencies%/%DependencyFolder% folder does not exist in S3. Please check whether dependency s3 bucket folder is correct.
exit 1
)
