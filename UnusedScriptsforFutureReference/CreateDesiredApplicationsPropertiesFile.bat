

if "%Mozart_Web%" == "true" (echo. 2>"%workspace%\%Mozart_Web_Folder_Name%.properties")
if "%Mozart_API%" == "true" (echo. 2>"%workspace%\%Mozart_API_Folder_Name%.properties")
if "%Word_Package%" == "true" (echo. 2>"%workspace%\%Mozart_Word_Package_Folder_Name%.properties")
if "%Identity_Server%" == "true" (echo. 2>"%workspace%\%Mozart_Identity_Server_Folder_Name%.properties")
if "%DB_Deployment%" == "true" (echo. 2>"%workspace%\%Mozart_DB_Deployment_Folder_Name%.properties")

exit 0