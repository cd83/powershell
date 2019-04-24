# Change these things and run it in the same dir as your kickass psm1
$path = ".\MyCustomModule.psd1"
$guid = [guid]::NewGuid().guid
$paramHash = @{
 Path = $path
 RootModule = "MyCustomModule.psm1"
 Author = "Chris Lee"
 CompanyName = "@_cd83"
 ModuleVersion = "1.0"
 Guid = $guid
 PowerShellVersion = "5.1"
 Description = "My Custom Module"
 FunctionsToExport = "Get-MyCustomModule"
 AliasesToExport = "*"
 VariablesToExport = "*"
 CmdletsToExport = "*"
}
New-ModuleManifest @paramHash