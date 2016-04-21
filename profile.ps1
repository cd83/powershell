# Powershell profile

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
function Load-Menu ()
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
    Write-Host "----------------------------------------------------------"
    Write-Host "Select an Option Below"
    Write-Host ""
    Write-Host "(E) Exit"
    Write-Host "(D) Connect to Azure Develop Subscription"
    Write-Host "(P) Connect to Azure Production Subscription"
    Write-Host "(U) Update AzureRM Modules"
    Write-Host "----------------------------------------------------------"
	
	$Title = "Please select the subscription to load"
	$Message = "You can return to this menu anytime by typing Load-Menu"
	
	$E = New-Object System.Management.Automation.Host.ChoiceDescription "&Exit", `
	"Exits the menu to default PowerShell Host."
	
	$0 = New-Object System.Management.Automation.Host.ChoiceDescription "&Develop", `
	"Logs you into the Develop Subscription"
	
	$1 = New-Object System.Management.Automation.Host.ChoiceDescription "&Production", `
	"Logs you into the Production Subscription"
  
  $2 = New-Object System.Management.Automation.Host.ChoiceDescription "&Update AzureRM", `
  "Updates the Azure Powershell Modules"
	
	$MenuOptions = [System.Management.Automation.Host.ChoiceDescription[]] ($E, $0, $1, $2)
	
	$MenuResult = $host.ui.PromptForChoice($Title, $Message, $MenuOptions, 0)
    Set-Location C:\
    $Global:Env = ''
	
	switch	($MenuResult)
	{
		0 #Exit
    {
			Write-Host "Exiting the menu"
			Write-Host ""
			Write-Host "You can return to this menu anytime by typing Load-Menu"
    }
		1 #Development
    {
			$Global:Env = 'Dev'
			ConnectDevelop
    }
		2 #Production
    {
			$Global:Env = 'Prod'
			ConnectProduction
    }
    3 #Update Azure
    {
      try
      {
        Update-AzureRM
        Load-Menu
      }
      Catch
      {
        Write-Host "Ooops Something went wrong updating the modules"
        Load-Menu
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

#Sets var to check for admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )  

# This is the part that lods the prompt
# If $currentPrincipal is admin, load all the things, else change foreground to magenta
if ($currentPrincipal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )) {

  Add-Clock | Out-Null  
  Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

  Import-Module posh-git 
  function global:prompt {
    if($Global:Env -cmatch "Dev")
      {
        $PromptString = "[Dev]: " + $(Get-Location)
        Write-Host $PromptString -NoNewline -ForegroundColor Green -BackgroundColor Black
        Write-VcsStatus
        return " > "
      }
    elseif($Global:Env -cmatch "Prod")
      {
        $PromptString = '[Prod]: ' + $(Get-Location)
        Write-Host $PromptString -NoNewline -ForegroundColor Yellow -BackgroundColor Black
        Write-VcsStatus
        return " > "
      }
    else
      {
        $PromptString = $(Get-Location)
        Write-Host $PromptString -NoNewline -ForegroundColor White -BackgroundColor Black
        Write-VcsStatus
        return " > "
      }
  }
  Pop-Location
  Start-SshAgent -Quiet	
  Load-Menu
}
else
{ 
  clear	
  Write-Host -foreground darkred -background magenta "Not running in Admin..."
  $Host.UI.RawUI.ForegroundColor = “magenta”
}
