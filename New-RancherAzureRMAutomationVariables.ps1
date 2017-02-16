#========================================================================
# Organization: LeanKit, Inc.
# Created on:   2/13/2017
# Created by:   Chris Lee
# Filename:     New-RancherAzureRMAutomationVariables.ps1  
#========================================================================

<#
.SYNOPSIS
Quick script to grab a bunch of rancher keys and secrets from a CSV file and store them as encrypted Azure automation variables.

.DESCRIPTION
This script reads rancher keys and secrets from a CSV file and stores them as encrypted Azure automation variables.

.PARAMETER csv
Path to the CSV file you wish to read from.

.NOTES
Authors:	Chris Lee (chris.lee@leankit.com)

#>

[CmdletBinding()]
    Param (
    [Parameter(Mandatory=$true, helpmessage="Source Subscription Name")]
    [string] $csvPath
)

$csv = Import-Csv $csvPath

foreach ($row in $csv) {
    Write-Host $row
    
    $keyname = "lku3-" + $row.inst + "RancherKey"
    New-AzureRmAutomationVariable -ResourceGroupName automation -AutomationAccountName lk-automation -Encrypted $true -Name $keyname -Value $row.key
    
    $secretname = "lku3-" + $row.inst + "RancherSecret"
    New-AzureRmAutomationVariable -ResourceGroupName automation -AutomationAccountName lk-automation -Encrypted $true -Name $secretname -Value $row.secret #howbadat
}