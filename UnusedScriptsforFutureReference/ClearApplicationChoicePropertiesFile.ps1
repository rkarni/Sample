$Deployment_Options = @("$env:Mozart_Web_Folder_Name", "$env:Mozart_API_Folder_Name", "$env:Mozart_Word_Package_Folder_Name", "$env:Mozart_Identity_Server_Folder_Name", "$env:Mozart_DB_Deployment_Folder_Name", "$env:Deployment_Details_File")


foreach ($element in $Deployment_Options)
{

if (Test-Path "$env:workspace\$element.properties")
{
  Remove-Item "$env:workspace\$element.properties"
}
($env:element)


}