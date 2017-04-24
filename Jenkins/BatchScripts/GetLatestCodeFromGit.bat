echo on


set GIT_Folder_Name=%1
set Git_Branch=%2
set GIT_Revision=%3
set WORKSPACE=%4

cd %WORKSPACE%


git clone https://rkarni:Intel1985..@github.com/AllianceGlobalServices/%GIT_Folder_Name%.git --branch %Git_Branch%
cd %GIT_Folder_Name%
git checkout %Git_Branch%
git checkout .
git pull
git checkout %GIT_Revision%

REM ********* To assign GIT Head Revision, Date and Time  to a Variable *******************
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --short HEAD`) DO SET GITHEADREVISION=%%F