#Account Variables
$Server = "leepc"
$Name = "NEWONE"

$ProfileName = $Name

$ID = $Name

$AccountName = $Name
$Description = $Name+" Alert Email Account"
$EmailAddress = $Name+"@leankit.com"
$DisplayName = $Name
$ReplyToAddress = "noreply@leankit.com"
$MailServers = "smtp."+$Name+".leankit.com"
$smtpPort = 41234
$SSL = $FALSE

$ChkAccount = $null

$Changed = $false
New-EventLog -LogName Application -Source SQL-DBMail-Script | Out-Null

#Functions go here
function Create-AccPro ()
{
        #Create Mail Account
    $DBAccount = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Mail.MailAccount -argumentlist $DBMail,$AccountName -ErrorAction Stop
    
    Try {
        $DBAccount.Description = $Description
        $DBAccount.DisplayName = $AccountName
        $DBAccount.EmailAddress = $EmailAddress
        $DBAccount.ReplyToAddress = $ReplyToAddress
        $DBAccount.Create()
    } Catch {
        Write-EventLog -Source SQL-DBMail-Script -EventId 12655 -Message "ERROR [CREATE ACCOUNT]:"$_.Exception.Message -LogName Application -EntryType Error
        Exit;
    }
    
    Try {
        $DBAccount.MailServers.Item( $Server ).Rename( $MailServers )
        $DBAccount.MailServers.item(0).enablessl = $SSL
        $DBAccount.Alter()
    } Catch {
        Write-EventLog -Source SQL-DBMail-Script -EventId 12655 -Message "ERROR [ADD SMTP TO ACCOUNT]:"$_.Exception.Message -LogName Application -EntryType Error
        EXIT;
    }
    Write-EventLog -Source SQL-DBMail-Script -EventId 12654 -Message "Created account: $AccountName" -LogName Application -EntryType Information
    
    #Create Mail Profile
    $DBProfile = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Mail.MailProfile -argumentlist $DBMail,$ProfileName -ErrorAction Stop
    
    Try {
        $DBProfile.Description = $Description
        $DBProfile.Create()
    } Catch {
        Write-EventLog -Source SQL-DBMail-Script -EventId 12655 -Message "ERROR [CREATE PROFILE]:"$_.Exception.Message -LogName Application -EntryType Error
        EXIT;
    }
    
    Write-EventLog -Source SQL-DBMail-Script -EventId 12654 -Message "Created profile: $ProfileName" -LogName Application -EntryType Information
    
    Try {
        $DBProfile.AddAccount($AccountName,0)
        $DBProfile.AddPrincipal("Public",$false)
        $DBProfile.Alter()
    } Catch {
        Write-EventLog -Source SQL-DBMail-Script -EventId 12655 -Message "ERROR [ADD ACCOUNT TO PROFILE]:"$_.Exception.Message -LogName Application -EntryType Error
        EXIT;
    }
    Write-Host -ForegroundColor DarkGreen "DB Account [$AccountName] added to Profile [$ProfileName]"
}

function Check-AccPro ()
{

    #Checking and updating Account properties
    if ( $ActiveAccount.Description -ne $Description ) {
        Try {
            $ActiveAccount.Description = $Description
            $Changed = $true
            Write-EventLog -Source SQL-DBMail-Script -EventId 12654 -Message "Updated Account Description to: $Description" -LogName Application -EntryType Information
        } Catch {
            Write-EventLog -Source SQL-DBMail-Script -EventId 12655 -Message "ERROR [UPDATE ACCOUNT DESCRIPTION]:"$_.Exception.Message -LogName Application -EntryType Error
            Exit;
        }
    }
    if ( $ActiveAccount.DisplayName -ne $ProfileName ) {
        Try {
            $ActiveAccount.DisplayName = $ProfileName
            $Changed = $true
            Write-EventLog -Source SQL-DBMail-Script -EventId 12654 -Message "Updated Profile Name to: $ProfileName" -LogName Application -EntryType Information
        } Catch {
            Write-EventLog -Source SQL-DBMail-Script -EventId 12655 -Message "ERROR [UPDATE ACCOUNT DISPLAYNAME]:"$_.Exception.Message -LogName Application -EntryType Error
            Exit;
        }
    }
    if ( $ActiveAccount.EmailAddress -ne $EmailAddress ) {
        Try {
            $ActiveAccount.EmailAddress = $EmailAddress
            $Changed = $true
            Write-EventLog -Source SQL-DBMail-Script -EventId 12654 -Message "Updated Email Address to: $EmailAddress" -LogName Application -EntryType Information
        } Catch {
            Write-EventLog -Source SQL-DBMail-Script -EventId 12655 -Message "ERROR [UPDATE ACCOUNT DISPLAYNAME]:"$_.Exception.Message -LogName Application -EntryType Error
            Exit;
        }        
    }
    if ( $ActiveAccount.ReplyToAddress -ne $ReplyToAddress ) {
        Try {
            $ActiveAccount.ReplyToAddress = $ReplyToAddress
            $Changed = $true
            Write-EventLog -Source SQL-DBMail-Script -EventId 12654 -Message "Updated Reply-To Address to: $ReplyToAddress" -LogName Application -EntryType Information
        } Catch {
            Write-EventLog -Source SQL-DBMail-Script -EventId 12655 -Message "ERROR [UPDATE ACCOUNT REPLYTOADDRESS]:"$_.Exception.Message -LogName Application -EntryType Error
            Exit;
        }         
    }
    if ( $ActiveAccount.MailServers.Item(0).name -ne $MailServers ) {
        Try {
            $ActiveAccount.MailServers.Item(0).Rename($MailServers)
            $Changed = $true
            Write-EventLog -Source SQL-DBMail-Script -EventId 12654 -Message "Updated Server URL to: $MailServers" -LogName Application -EntryType Information
        } Catch {
            Write-EventLog -Source SQL-DBMail-Script -EventId 12655 -Message "ERROR [UPDATE MAILSERVERS]:"$_.Exception.Message -LogName Application -EntryType Error
            Exit;
        }
    }
    if ( $ActiveAccount.MailServers.item(0).Port -ne $smtpPort ) {
        Try {
            $ActiveAccount.MailServers.item(0).Port = $smtpPort
            $Changed = $true
            Write-EventLog -Source SQL-DBMail-Script -EventId 12654 -Message "Updated SMTP Port to: $smtpPort" -LogName Application -EntryType Information
        } Catch {
            Write-EventLog -Source SQL-DBMail-Script -EventId 12655 -Message "ERROR [UPDATE MAILSERVER PORT]:"$_.Exception.Message -LogName Application -EntryType Error
            Exit;
        }
    }
    if ( $ActiveSSL -ne $SSL ) {
        Try {        
            $ActiveAccount.MailServers.item(0).enablessl = $SSL
            $Changed = $true
            Write-EventLog -Source SQL-DBMail-Script -EventId 12654 -Message "Updated Require SSL state to: $SSL" -LogName Application -EntryType Information
        } Catch {
            Write-EventLog -Source SQL-DBMail-Script -EventId 12655 -Message "ERROR [UPDATE SSL STATE]:"$_.Exception.Message -LogName Application -EntryType Error
        }
    }
    if ($Changed -eq $true ) {
        $ActiveAccount.Alter()
    }

    #Checking and updating Profile properties
    if ( $ActiveProfile.Description -ne $Description ) {
		Try {
			$ActiveProfile.Description = $Description
            $ActiveProfile.Alter()
            Write-EventLog -Source SQL-DBMail-Script -EventId 12654 -Message "Updated Profile Description to: $Description" -LogName Application -EntryType Information
		} Catch {
            Write-EventLog -Source SQL-DBMail-Script -EventId 12655 -Message "ERROR [UPDATE PROFILE DESCRIPTION]:"$_.Exception.Message -LogName Application -EntryType Error
			Exit;
		}
	}
}
 
#Connect to the local, default instance of SQL Server.
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null

#Get a server object which corresponds to the default instance
$srv = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Server -ArgumentList $Server -ErrorAction Stop

$DBMail = $srv.Mail
$ChkProfile = $DBMail.Profiles | where {$_.name -eq $ProfileName}
$ChkAccount = $DBMail.Accounts | where {$_.name -eq $AccountName}
#$ActiveAccountName = $DBMail.accounts | where { $_.name -eq $AccountName }
$ActiveAccount = $DBMail.Accounts | where { $_.name -eq $AccountName }
#$ActiveProfileName = $DBMail.profiles.name
$ActiveProfile = $DBMail.Profiles | where { $_.name -eq $ProfileName }
$ActiveSSL = $ActiveAccount.MailServers.item(0).enablessl

#If DatabaseMail is enabled, check to ensure Account is up to date
#If anything on the server doesn't match specified parameters above, update it   
if($srv.Configuration.DatabaseMailEnabled.ConfigValue -eq 1) {
    if ( $ActiveAccount.name -eq $AccountName ) {
        Check-AccPro    
    }
    elseif ( ( $ActiveAccount -eq $null ) -or ( $ActiveAccount -ne $AccountName ) )
    {
        Create-AccPro
    }
    Write-Host "done"
}
Else #Enable DatabaseMail and Create Mail Account and Profile
{
    Try {
        $srv.Configuration.DatabaseMailEnabled.ConfigValue = 1
        $srv.Configuration.Alter()
        Write-EventLog -Source SQL-DBMail-Script -EventId 12654 -Message "Database Mail Enabled" -LogName Application -EntryType Information
    } Catch {
        Write-EventLog -Source SQL-DBMail-Script -EventId 12655 -Message "ERROR [DATABASE MAIL ENABLE]:"$_.Exception.Message -LogName Application -EntryType Error
		Exit;
    }
     
    Create-AccPro
}