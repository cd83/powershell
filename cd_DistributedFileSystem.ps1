#========================================================================
# Created with: PowerShell ISE v3.0
# Created on:   4/1/2016
# Created by:   Chris Lee
# Filename:     cd_DistributedFileSystem.ps1  
#========================================================================

<#
.SYNOPSIS
This script duplicates a source folder into a list of Azure File Shares.

.NOTES
Run this script as a Windows Service
http://software.dell.com/products/powergui-freeware/

Authors:
Chris Lee (chrisdlee@gmail.com)

ToDo:
- Set up script to get input from a config file

#>

# Set the source folder
$SourceFolder = "C:\junk"

# Enter all of the Azure Storage Account names in a hash table, along with their Storage Account Key
# Get your Storage Account Key by going into Azure Portal > Storage Accounts > Select Account > Key Icon
$Shares = @{
    'AzureStorageAccount1'='AzureStorageAccount1Key';
    'AzureSTorageAccount2'='AzureSTorageAccount2Key'
}

# Set the Azure File Share name
$FileShare = "FileShareName"

# Get the Service status
$Service = (Get-Service cd_DistributedFileSystem).status

# While the service is running, do things lots
While ($Service -eq "Running")
{
	# This loop creates the network share for each of the Azure Storage Accounts
	foreach ($Share in $Shares.Keys)
	{
	    net use * \\$Share.file.core.windows.net\$FileShare /u:$Share $Shares.$Share
	}

	# Get the Network Shares
	$Drives = Get-PSDrive -PSProvider FileSystem | Where-Object { [char[]]"ACD" -notcontains $_.Name }

	# Create an empty array to add the Drives to
	$DestinationFolders = @("")

	# Adds each drive to the array
	foreach ( $Drive in $Drives )
	{
	    $DriveName = $Drive.Name + ":\"
	    $DestinationFolders += $DriveName
	}

	# Performs Robocopy to each of the shares
	# /MIR will remove existing files in the destination folders if removed from the source
	foreach ($Destination in $DestinationFolders)
	{
	    Robocopy.exe $SourceFolder $Destination /MIR
	}

	# Cleans up all the network shares
	net use * /d /y
	
	# Sleep to give the CPU a break
	Start-Sleep -Seconds 900 # Runs every 15min
	
}
