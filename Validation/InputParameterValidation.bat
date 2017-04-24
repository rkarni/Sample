@echo on

if "%Source_Revision_Number%" == "" (
echo "Source_Revision_Number cannot be empty"
exit 1
)

if "%Git_Revision%" == "" (
echo GIT Revision Number cannot be empty
exit 1
)
