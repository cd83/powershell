<#

.AUTHOR
Chris Lee chris.lee@breakfreesolutions.com

.SYNOPSIS
This script is meant to coincide with the SetupScript.ps1 for the bi-tools repository.

.DESCRIPTION
This script checks each individual folder in the bi-tools repository for a module and installs or updates it on the local machine.

Folder Structure requirement:

Each Module (psm1) must have an accompanying data file (psd1) and be in a folder with the same name.

tree /F
│   Check-Modules.ps1
│
└───ZZZGet--MyModuleTest
        ZZZGet-MyModuleTest.psd1
        ZZZGet-MyModuleTest.psm1

#>

Function verCompare($ver1, $ver2) {
   # Helper function which returns whether ver1 is Less, Greater, or Equal to ver2
   return [System.Version]$ver1 -gt [System.Version]$ver2
}

Function CheckInstalledVersion($ModuleToCheck,$File) {
    # Helper function to check currently installed version
    Import-LocalizedData -BaseDirectory $InstalledModulePath -FileName $File.split('\')[-1] -BindingVariable InstalledModule
    # This needs to be converted to type string to use verCompare helper function.
    $InstalledModuleVersion = $InstalledModule.ModuleVersion -as [string]
    return $InstalledModuleVersion
}

$psdFiles = (dir .\* -include ('*.psd1') -recurse).FullName # Only check files with accompanying psd1's (skip the SetupScript.ps1, etc)

# Instantiate blank array to list modules added at end of script run
$modules = @()

# Check each psd1 in the repo with what is currently installed.
# If not installed, install.
# If installed version needs update, update.
foreach ($File in $psdFiles) {

    # First, we get the version in the repo
    Write-Output "Checking $($File.split('\')[-1]): "
    $BaseDirectory = $File.Substring(0, $File.lastIndexOf('\'))
    Import-LocalizedData -BaseDirectory $BaseDirectory -FileName $File.split('\')[-1] -BindingVariable MostRecentModule
    # This needs to be converted to type string to use verCompare helper function.
    $MostRecentModuleVersion = $MostRecentModule.ModuleVersion -as [string] 
    Write-Output "Version in repo: $MostRecentModuleVersion"

    # Then, we check to see if the module is installed.
    $InstalledModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\" + (Get-Item $File).name.split('.')[0]
    if (Get-Childitem ($InstalledModulePath + "\" + $File.split('\')[-1]) -ErrorAction SilentlyContinue) {
        $InstalledModuleVersion = CheckInstalledVersion $InstalledModulePath $File
        Write-Output "Installed version: $InstalledModuleVersion"
        # Compare the versions. 
        if (verCompare $MostRecentModuleVersion $InstalledModuleVersion) {
            # If version in repo is greater, update installed version.
            Write-Output "Error: Needs update. Updating..."
            Copy-Item -Path "$($BaseDirectory)\*" -Destination $InstalledModulePath -recurse -Force -Verbose
            Remove-Module (Get-Item $File).name.split('.')[0] -ErrorAction SilentlyContinue
            $InstalledModuleVersion = CheckInstalledVersion $InstalledModulePath $File
            Write-Output "Installed version: $InstalledModuleVersion"
        }
    } else { # If the module is not installed, install module.
        Write-Output "Error: Not installed. Installing..."
        mkdir $InstalledModulePath -ErrorAction SilentlyContinue -Verbose
        Copy-Item -Path "$($BaseDirectory)\*" -Destination $InstalledModulePath -recurse -Force -Verbose
        $InstalledModuleVersion = CheckInstalledVersion $InstalledModulePath $File
        Write-Output "Installed version: $InstalledModuleVersion"
    }
    $modules += (Get-Item $File).name.split('.')[0]
    Import-Module (Get-Item $File).name.split('.')[0]
    ""
}

# Write out modules that were added
Write-Output "Modules added:"
$modules | foreach {$_}
""