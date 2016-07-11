
<#
.SYNOPSIS
    This script creates a scheduled task which calls another powershell script to perform a basic robocopy at a user selected interval indefinitely.

.DESCRIPTION
    The scheduled task calls robocopy.ps1, which copies the contents of 1 directory to another with the /MIR switch

.PARAMETER TaskName
    The name of the task to be created.

.PARAMETER Source
    Source folder to be replicated by the script.

.PARAMETER Destination
    Destination folder for items to be copied to.

.PARAMETER Interval
    Time, in minutes, between runs.

.EXAMPLE
    New-RepeatingScheduledTask -TaskName test -Source c:\1 -Destination c:\2 -Interval 1
#>


function New-RepeatingScheduledTask
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
            Position=0,
            HelpMessage="The name of the task to be created.")]
        [string]$TaskName,
        [Parameter(Mandatory=$true,
            Position=1,
            HelpMessage="Source folder to be replicated by the script.")]
        [string]$source,
        [Parameter(Mandatory=$true,
            Position=2,
            HelpMessage="Destination folder for items to be copied to.")]
        [string]$destination,
        [Parameter(Mandatory=$true,
            Position=3,
            HelpMessage="Interval (in minutes)")]
        [string]$interval
    )
    
    Begin
    {
        $user = "NT AUTHORITY\SYSTEM"

        $TaskAction = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-command `"& c:\users\chris.lee\documents\robocopy.ps1 -source $source -destination $destination`""
       
        $Interval = New-TimeSpan -Minutes $interval

        $startTime = (get-date).AddMinutes(1).ToString("HH:mmtt")

        $TaskTrigger = New-ScheduledTaskTrigger -Once -At "$startTime" -RepetitionInterval $Interval -RepetitionDuration ([TimeSpan]::MaxValue)
    }
    
    Process
    {
        Register-ScheduledTask –TaskName “$TaskName” -Action $TaskAction –Trigger $TaskTrigger -User $user

        Start-ScheduledTask -TaskName "$TaskName"
    }
    
    End
    {
        Get-ChildItem $destination
    }

}

New-RepeatingScheduledTask
