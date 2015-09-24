# Stupid little script to unfux Shrew VPN services
# Because Uninstall-Shrew is not an option -- yet

function Test-Admin { 
    # returns true if running as admin
    
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() ) 
    
    if ($currentPrincipal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )) { 
        return $true 
    } else { 
        return $false 
    } 
}  

function Restart-ScriptAsAdmin {
    # Restarts powershell if not running as admin
	$Invocation=((Get-Variable MyInvocation).value).ScriptName 
	
	if ($Invocation -ne $null) 
	{ 
	    $arg="-command `"& '"+$Invocation+"'`"" 
	    if (!(Test-Admin)) { # ----- F
            Start-Process "$psHome\powershell.exe" -Verb Runas -ArgumentList $arg 
		    break 
		} Else {
			Write-Host "Already running as Admin no need to restart..."
		}
	} 
	else 
	{ 
	    return "Error - Script is not saved" 
	    break 
	} 
}

function unfuxClose($Process1,$Process2){
    # function unfuxClose Closes any open Shrew windwos
    Write-Host ""
    Write-Host "Shutting down any open Shrew windows..."
    Write-Host ""

    $Process1Active = Get-Process $Process1 -ErrorAction SilentlyContinue
 
    if ($Process1Active -ne $null){
        Get-Process $Process1 | stop-process –force
        Write-Host "... Success."
        Write-Host ""
    }
}

function UnfuxStop($Service1,$Service2){
    # function UnfuxStop stops the iked and ipsecd Shrew Services
    $ServiceStat1 = Get-Service $Service1
 
    if ($ServiceStat1.Status -eq "Running"){
    Write-Host "... Initializing unfux sequence: Checking Shrew services status..."
    Get-Service iked,ipsecd
    Write-Host ""
    Write-Host "... Unfux sequence: ACTIVATED (Stopping Shrew services...)"
    Write-Host ""
    Start-Sleep 2
    Stop-Service $Service1
    }
    Get-Service iked,ipsecd
    Write-Host ""
}

function UnfuxStart($Service1,$Service2){
    # function UnfuxStart starts up the iked and ipsecd Shrew services
    $ServiceStat1 = Get-Service $Service1
     
    if ($ServiceStat1.Status -ne "Running"){
        Write-Host "... Initializing unfux sequence: Starting Shrew services..."
        Write-Host ""
        Start-Sleep 2
        Start-Service $Service1
    }
    Get-Service iked,ipsecd
    Write-Host ""
}

Test-Admin
Restart-ScriptAsAdmin

unfuxClose("ipseca","ipsecc")
UnfuxStop("iked","ipsecd")
UnfuxStart("iked","ipsecd")