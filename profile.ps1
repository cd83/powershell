# Powershell profile
$version = "2.0"

# Set Aliases
New-Alias lm Load-Menu

# .source the Write-Menu.ps1
$ProfilePath = $Profile | Split-Path -parent
. $ProfilePath\Write-Menu.ps1

$hosts = "C:\Windows\System32\drivers\etc\hosts"

$AzureRmProfilePath = [Environment]::GetFolderPath("MyDocuments") + "\AzureRmProfile.json"

#Sets var to check for admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )  

Set-Location C:\

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


function azureheader ($SubName) {
  Write-Host
  Write-Host -foreground cyan "              _    _____   _ ___ ___            "
  Write-Host -foreground cyan "             /_\  |_  / | | | _ \ __|           "
  Write-Host -foreground cyan "       _ ___/ _ \__/ /| |_| |   / _|___ _ _     "
  Write-Host -foreground cyan "     (___  /_/ \_\/___|\___/|_|_\___| _____)    "
  Write-Host -foreground cyan "       (_______ _ _)         _ ______ _)___     "
  Write-Host -foreground cyan "         (_t_h_e_r_e__i_s_) no (_c_l_o_u_d_)    "
  Write-Host ""
  Write-Host "Logged into: $SubName"
}

# Menu to switch between Microsoft Azure 'dev' and 'prod' subscriptions
function Load-Menu ()
{
  Clear-Host

	$Title = "Menu v$version. Do Azure things?"
	$Message = "You can return to this menu anytime by typing Load-Menu"
	
	$E = New-Object System.Management.Automation.Host.ChoiceDescription "&Exit", `
	"Exits the menu to default PowerShell Host."
	
	$0 = New-Object System.Management.Automation.Host.ChoiceDescription "&Azure", `
	"Do Azure Things"
	
	$MenuOptions = [System.Management.Automation.Host.ChoiceDescription[]] ($E, $0)
	
	$MenuResult = $host.ui.PromptForChoice($Title, $Message, $MenuOptions, 0)

	switch	($MenuResult)
	{
		0 #Exit
    {
			Write-Host "Exiting the menu"
			Write-Host ""
			Write-Host "You can load the subscription menu anytime by typing 'sub'."
      Write-Host ""
    }
		1 #AzureMenu
    {
      Test-AzureModules
      $AzureSubs = Get-AzureSubs
      Get-SubMenu
    }
	}
}

function Test-AzureModules {
  if(!(Get-Module -ListAvailable -Name 'AzureRM'))
  {
    Write-Host "AzureRM Module NOT installed.  Installing..." -BackgroundColor Black -ForegroundColor Green
    Install-Module -Name AzureRM
    Import-Modle -Name AzureRM
  }
  if(!(Get-Module -ListAvailable -Name 'AzureRM.profile'))
  {
    Write-Host "Installing the Azure PowerShell Modules... This could take several minmutes." -BackgroundColor Black -ForegroundColor Green
    Install-AzureRM
  }
}

function Update-AzureModules {
  # todo
}

function Get-SubMenu {
  $SubSelection = Write-Menu -Title "Select Azure Subscription" -Sort -Entries @(
    $AzureSubs
  )

  Select-Sub -SubName $SubSelection
  $Global:AzureSub = $SubSelection
  [System.Console]::CursorVisible = $true # The Write-Menu.ps1 that is used by this function has a bug somewhere that isn't resetting the ::CursorVisible to $true, so we're doing it here.
}

function sub {
  $AzureSubs = Get-AzureSubs
  Get-SubMenu
}

function Get-AzureSubs {
  if (!$AzureSubs) {
    try
    {
      $AzureSubs = (Get-AzureRmSubscription).Name |  Where-Object {$_ -notlike "*-*" }
      Write-Host "Logged into Azure, getting subscriptions..."
      return $AzureSubs
      #Write-Host $AzureSubs
    }
    catch
    {
      Test-AzureProfile
      $AzureSubs = (Get-AzureRmSubscription).Name | Where-Object {$_ -notlike "*-*" }
      return $AzureSubs
      #Write-Host $AzureSubs
    }
  }
}

function Test-AzureProfile () {
  if (test-path $AzureRmProfilePath) {
    Get-AzureRmContext
    Import-AzureRmContext -Path $AzureRmProfilePath | Out-Null
  }
  else {
    Write-Host "Log into Azure..."
    Login-AzureRmAccount -ErrorAction SilentlyContinue | Out-Null
    Save-AzureRmContext -path $AzureRmProfilePath
  }
}

function Select-Sub ($SubName)
{
  try
  {
    if (Get-AzureRmContext) {
      azureheader $SubName
      Write-Host "(Select a new subscription anytime by typing 'sub'.)"
      Write-Host ""
    }
    Select-AzureRmSubscription -SubscriptionName $SubName | Out-Null
  }
  catch
  {
    Write-Host "Could not login or switch subscriptions... Initiating login"
    Login-AzureRmAccount
    Select-AzureRmSubscription -SubscriptionName $SubName | Out-Null
  }
}

# This is the part that lods the prompt
# If $currentPrincipal is admin, load all the things, else change foreground to magenta
Add-Clock | Out-Null  
Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

if (Get-Module -ListAvailable -Name posh-git) {
  Write-Host "posh-git installed"
} else {
  Write-Host "Installing posh-git"
  install-Module posh-git
}
Import-Module posh-git -ErrorAction SilentlyContinue

function global:prompt 
{
  switch ($Global:AzureSub)
  {
    "LeanKit_Production" {$Global:AzureSub = "PD"}
    "LeanKit_Development" {$Global:AzureSub = "DEV"}
  }

  switch ($Global:AzureSub)
  {
    "PD" {$promptColor = "Yellow"}
    "DEV" {$promptColor = "Green"}
    "u3" {$promptColor = "Magenta"}
    "u4" {$promptColor = "cyan"}
    "e3" {$promptColor = "gray"}
    "e4" {$promptColor = "darkgreen"}
    default {$promptColor = "White"}
  }

  if ($Global:AzureSub) {
    $PromptString = "[$Global:AzureSub]: " + $(Get-Location)
    Write-Host $PromptString -NoNewline -ForegroundColor $promptColor -BackgroundColor Black
    if (get-module -name posh-git) {Write-VcsStatus}
    return " > "
  } else {
    $PromptString = $(Get-Location)
    Write-Host $PromptString -NoNewline -ForegroundColor $promptColor -BackgroundColor Black
    if (get-module -name posh-git) {Write-VcsStatus}
  return " > "
  }

}
Pop-Location
Load-Menu
