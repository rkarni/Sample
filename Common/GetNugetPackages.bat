REM Nuget package Restore process
if "%Application_Name%" == "NextGenFramework" (
"C:\Program Files (x86)\NuGet\nuget.exe" restore "%workspace%\%GIT_FOLDER_NAME%\%Solution_Name%"
) else (
"C:\Program Files (x86)\NuGet\nuget.exe" restore "%workspace%\%GIT_FOLDER_NAME%\%Product_Version_Path%\%Solution_Name%"
)