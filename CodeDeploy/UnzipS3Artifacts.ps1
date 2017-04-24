$ErrorActionPreference = "Stop"

$files = Get-ChildItem -Path "$env:workspace\Artifacts\$env:Environment\$env:Application_Name" -Filter "*.zip" -Recurse;

Add-Type -AssemblyName System.IO.Compression.FileSystem;

ForEach ($fn in $files) {
	[System.IO.Compression.ZipFile]::ExtractToDirectory($fn.FullName, $fn.DirectoryName);
	Remove-Item -Path $fn.FullName;
}
