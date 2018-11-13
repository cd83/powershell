#========================================================================
# Version:      0.1
# Created with: Visual Studio Code
# Created on:   11/13/2018
# Created by:   Chris Lee
# Filename:     Get-AllAKSClusterPodsLogs.ps1
#========================================================================

<#
.SYNOPSIS
This script gets the logs for all pods in an AKS Cluster, zips them up, and shoots them over to a Blob Storage Account.

.NOTES
Log into your Cluster first with az aks get-credentials --resource-group <resource group name> --name <cluster name> --admin

ToDo:
- Create and echo a Shared Access Signature for the zip file in Blob Storage.

#>

param (
    [Parameter(
        Mandatory=$true,
        HelpMessage="The name of the Resource Group of the Cluster.")]
    [string]$RG,
    [Parameter(
        Mandatory=$true,
        HelpMessage="The name of the Cluster.")]
    [string]$clusterName,
    [Parameter(
        Mandatory=$true,
        HelpMessage="The name of the blob storage account.")]
    [string]$storageAccountName,
    [Parameter(
        Mandatory=$true,
        HelpMessage="The key for blob storage account.")]
    [string]$storageAccountKey,
    [Parameter(
        Mandatory=$true,
        HelpMessage="The name of the container in the blob storage account.")]
    [string]$blobContainerName
)

az aks get-credentials --resource-group $RG --name $clusterName --admin

$date = get-date -format yyyy-MM-dd-hh:mm

$dirname = "./$date-logs"

if (!(Test-Path -type Container -path ./$dirname)) { mkdir $dirname }

$pods = kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}} {{end}}'
# powershell had problems with the go template {{"\n"}} to separate these into new lines
# so instead of working on that I did it the way I know how, with the .split() method:
$podsarray = $pods.split(' ')

foreach ($pod in $podsarray)
{
    Write-Output "Getting log for $pod"
    $log = kubectl logs $pod | Out-String
    $filename = "$date-$pod-log.txt"
    $filename
    New-Item -Path .\$($dirname)\$logname -Name $filename -ItemType "file" -Value $log
    Write-Output ""
}

Compress-Archive -path ./$dirname -DestinationPath ./$dirname/$dirname

az storage blob upload `
-c "$blobContainerName" `
-f "./$dirname/$dirname.zip" `
-n "$dirname.zip" `
--account-key $storageAccountKey `
--account-name $storageAccountName 