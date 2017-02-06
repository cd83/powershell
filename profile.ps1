# Powershell profile

# Set Aliases
New-Alias dp Load-DeadpoolMenu

$hosts = "C:\Windows\System32\drivers\etc\hosts"

# Simple find function
function find ($filter, $path) {
  if ($path -eq $null) {
    Get-Childitem -recurse -filter $filter
  } else {
    Get-Childitem -recurse -filter $filter -path $path
  }
}

Function Start-Countdown 
{
  Param
  (
    [Int32]$Seconds = 10,
    [string]$Message = "Pausing for 10 seconds..."
  )
    ForEach ($Count in (1..$Seconds))
  {
    Write-Progress -Id 1 -Activity $Message -Status "Waiting for $Seconds seconds, $($Seconds - $Count) left" -PercentComplete (($Count / $Seconds) * 100)
    Start-Sleep -Seconds 1
  }
  Write-Progress -Id 1 -Activity $Message -Status "Completed" -PercentComplete 100 -Completed
}

# Adds clock to window 
function Add-Clock {
 $code = { 
    $pattern = '\d{2}:\d{2}:\d{2}'
    do {
      $global:clock = Get-Date -format 'HH:mm:ss'

      $global:oldtitle = [system.console]::Title
      if ($oldtitle -match $pattern) {
        $newtitle = $oldtitle -replace $pattern, $clock
      } else {
        $newtitle = "$clock $oldtitle"
      }
      [System.Console]::Title = $newtitle
      Start-Sleep -Seconds 1
    } while ($true)
  }

 $ps = [PowerShell]::Create()
 $null = $ps.AddScript($code)
 $ps.BeginInvoke()
}

# Checks for latest version of posh
If(!($PSVersionTable.PSVersion.Major) -ge '5')
{
  Write-Host "Please update to the latest version of PowerShell"
  Write-Host "https://msdn.microsoft.com/en-us/powershell/wmf/install"
}
else
{
  Write-Verbose -Message "Checking for Azure Module"
  if(!(Get-Module -ListAvailable -Name 'AzureRM'))
  {
      Write-Host "AzureRM Module NOT installed.  Installing..." -BackgroundColor Black -ForegroundColor Green
      Install-Module -Name AzureRM
  }
  if(!(Get-Module -ListAvailable -Name 'AzureRM.profile'))
  {
      Write-Host "Installing the Azure PowerShell Modules... This could take several minmutes." -BackgroundColor Black -ForegroundColor Green
      Install-AzureRM
  }
}
  
# Menu to switch between Microsoft Azure 'dev' and 'prod' subscriptions
function Load-DeadpoolMenu ()
{
    cls
    Write-Host ""
    Write-Host -foreground red "    _  _    ____  ____        ____  _____    _    ____  ____   ___   ___  _     "
    Write-Host -foreground red "  _| || |_ |  _ \|  _ \      |  _ \| ____|  / \  |  _ \|  _ \ / _ \ / _ \| |    "
    Write-Host -foreground red " |_  ..  _|| |_) | | | |_____| | | |  _|   / _ \ | | | | |_) | | | | | | | |    "
    Write-Host -foreground red " |_  ..  _||  __/| |_| |_____| |_| | |___ / ___ \| |_| |  __/| |_| | |_| | |___ "
    Write-Host -foreground red "   |_||_|  |_|   |____/      |____/|_____/_/   \_\____/|_|    \___/ \___/|_____|"
    Write-Host ""
    Write-Host -foreground cyan "                            _    _____   _ ___ ___            "
    Write-Host -foreground cyan "                           /_\  |_  / | | | _ \ __|           "
    Write-Host -foreground cyan "                     _ ___/ _ \__/ /| |_| |   / _|___ _ _     "
    Write-Host -foreground cyan "                   (___  /_/ \_\/___|\___/|_|_\___| _____)    "
    Write-Host -foreground cyan "                     (_______ _ _)         _ ______ _)_ _     "
    Write-Host -foreground cyan "                             (______________ _ )   (___ _ _)  "
    Write-Host ""
    Write-Host ""
    Write-Host "------------------------------------------------------------------------------------------"

	$Title = "Please select the subscription to load"
	$Message = "You can return to this menu anytime by typing Load-DeadpoolMenu"
	
	$E = New-Object System.Management.Automation.Host.ChoiceDescription "&Exit", `
	"Exits the menu to default PowerShell Host."
	
	$0 = New-Object System.Management.Automation.Host.ChoiceDescription "&d1", `
	"Logs you into the Develop Subscription"
	
	$1 = New-Object System.Management.Automation.Host.ChoiceDescription "&u1-pd", `
	"Logs you into the Production Subscription"

  $2 = New-Object System.Management.Automation.Host.ChoiceDescription "&List All Subs", `
	"Lists all available subscriptions"
	
	$MenuOptions = [System.Management.Automation.Host.ChoiceDescription[]] ($E, $0, $1, $2)
	
	$MenuResult = $host.ui.PromptForChoice($Title, $Message, $MenuOptions, 0)

	switch	($MenuResult)
	{
		0 #Exit
    {
			Write-Host "Exiting the menu"
			Write-Host ""
			Write-Host "You can return to this menu anytime by typing Load-DeadpoolMenu"
    }
		1 #Development
    {
			$Global:Env = 'd1'
			ConnectDevelop
    }
		2 #Production
    {
			$Global:Env = 'u1-pd'
			ConnectProduction
    }
    3 #List all subscriptions
    {
      Write-Host
      Write-Host "All subscriptions:"
      Write-Host "------------------"

      try
      {
        (Get-AzureRmSubscription).SubscriptionName
        Write-Host
        Write-Host "Use 'Select-Sub -SubName X' where 'X' equals of the above to select that subscription."
        Write-Host
      }
      catch
      {
        Write-Host
        Login-AzureRmAccount
        (Get-AzureRmSubscription).SubscriptionName
        Write-Host
        Write-Host "Use 'Select-Sub -SubName X' where 'X' equals one of the above to select that subscription."
        Write-Host
      }

    }
	}
}

function ConnectDevelop () 
{
  cls
  try
  {
      Write-Host "Attempting to login to Leankit Develop Subscription."
      Select-AzureRmSubscription -SubscriptionName 'LeanKit_Development' | Out-Null
  }
  catch
  {
      Write-Host "Could not login or switch subscriptions...Initiating login"
      Login-AzureRmAccount
      Select-AzureRmSubscription -SubscriptionName 'LeanKit_Development' | Out-Null
  }
}

function ConnectProduction ()
{
  cls
  try
  {
      Write-Host "Attempting to login to Leankit Production Subscription."
      Select-AzureRmSubscription -SubscriptionName 'LeanKit_Production' | Out-Null
  }
  catch
  {
      Write-Host "Could not login or switch subscriptions...Initiating login"
      Login-AzureRmAccount
      Select-AzureRmSubscription -SubscriptionName 'LeanKit_Production' | Out-Null
  }
}

function Select-Sub ($SubName)
{
  Select-AzureRmSubscription -SubscriptionName $SubName
  $Global:Env = $SubName
}

#Sets var to check for admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )  

Set-Location C:\

# This is the part that lods the prompt
# If $currentPrincipal is admin, load all the things, else change foreground to magenta
if ($currentPrincipal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )) {

  Add-Clock | Out-Null  
  Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

  Import-Module posh-git 

  function global:prompt {

    switch -wildcard ($Global:Env)
    {
      "u1-pd" {$promptColor = "Yellow"}
      "d1" {$promptColor = "Green"}
      "u4*" {$promptColor = "Magenta"}
      default {$promptColor = "White"}
    }

    $PromptString = "[$Global:Env]: " + $(Get-Location)
    Write-Host $PromptString -NoNewline -ForegroundColor $promptColor -BackgroundColor Black
    Write-VcsStatus
    return " > "

  }
  Pop-Location
  Start-SshAgent -Quiet	
  Load-DeadpoolMenu
}
else
{ 
  clear	
  Write-Host -foreground darkred -background magenta "Not running in Admin..."
  $Host.UI.RawUI.ForegroundColor = ?magenta?
}