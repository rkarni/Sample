echo on

if exist "%workspace%\Artifacts\%Environment%" (
echo Deleting content in %workspace%\Artifacts\%Environment%
del /s /q "%workspace%\Artifacts\%Environment%"
) else (
echo %workspace%\Artifacts\%Environment% folder does not exist to delete content in it.
)

if not exist "%workspace%\Artifacts\%Environment%" mkdir "%workspace%\Artifacts\%Environment%"

