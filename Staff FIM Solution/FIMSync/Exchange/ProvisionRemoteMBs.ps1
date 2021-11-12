PARAM(  
        [string]$ExchangeCAS,
        [string]$SearchBase,
	    [string]$Path,
	    [string]$LogPath = "",
        [string]$AdminAccount = "",
        [string]$PWFileName = "Creds.txt",
        [string]$Filter = "(&(objectCategory=user)(objectClass=user)(!adminDescription=*)(!msExchHomeServerName=*)(!extensionAttribute6=*)(sAMAccountName=adrian.corston))",
        # Note: !adminDescription=*      excludes users who were manually migrated to O365 prior to this script
        # Note: !msExchHomeServerName=*  excludes users with on-prem mailboxes (they are to be migrated via some other procedure)
        # Note: !extensionAttribute6=*   excludes users who have been successfully provisioned with an O365 mailbox by this script previously
        [string]$Alias = "sAMAccountName",
        [string]$LogExtension = "log",
        [int]$Daysback = 21,
        [int]$BatchLimit = -1,
        [string]$ForwardingMailDomain = "",
        [Parameter(Mandatory)][ValidateSet('student','staff')][string]$UserType,
        [switch]$SkipMailboxOperations
)

# Description: Adds an Office365 mailbox to newly-created user accounts
# =====================================================================
#
# Usage:
# Mandatory Params:
#    [string]$ExchangeCAS = fqdn of Exchange 2010 Client Access Server (used to construct web url for remote Powershell end point)
#    [string]$SearchBase = OU root of the subtree search for user accounts missing mailboxes
#    [string]$Path = full path of folder containing this script and optional credentials file
#    [string]$UserType = type of user, either "staff" or "student"
# Optional Params:
#    [string]$ForwardingMailDomain = Add a forward to an address made from the same prefix as the primary mail address plus the specified domain (default blank for no forward)
#    [string]$LogPath = full path of folder for writing logs, default "" will cause a "\logs" subfolder of $Path to be created if it doesn't already exist
#    [string]$LogExtension = file extension for log files, default ".log"
#    [string]$AdminAccount = identity of mailbox administrator (domain\sAMAccountName format), default "" (i.e. identity of launching context)
#    [string]$PWFileName = file name of encrypted credentials to be located within specified path (used only if $AdminAccount supplied), default "Creds.txt"
#    [string]$Filter = filter for users with no mailbox, default "(&(objectCategory=user)(objectClass=user)(!adminDescription=*)(!msExchHomeServerName=*)(!extensionAttribute6=*))"
#    [int]$Alias = name of user property to use as email alias (mailNickname), default sAMAccountName (*** note: specifying mailNickname itself can be problematic with Exchange 2010 ***)
#    [int]$Daysback = number of days log files can age before they are deleted, default 21
#    [int]$BatchLimit = number of mailboxes allowed to be created in a single execution of this script, default -1 (no limit)
#    [switch]$SkipMailboxOperations = do everything except for exchange mailbox operations.  The user's extensionAttribute6 is still updated in AD, however
#
# Overview: 
#   Targets accounts created by FIM based on following rule:
#   - In a FIM-managed OU
#   - Exchange mail server not present
#
#   When $AdminAccount is specified, uses corresponding AD account, where password has been stored in an encrypted file ($PWFileName in $Path) using the following command:
#       read-host -assecurestring | convertfrom-securestring | out-file encrypted.txt
# 
# Modification History:
# 25/3/2013: CW/BB Initial version
# 27/03/2019 AC Converted from on-prem to O365 provisioning
#   
#
# Copyright (c) 2012, Unify Solutions Pty Ltd
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## ---------------------------------------------------------------- ##


#region Parameter checks - mandatory parameters and other validation

if (-not($ExchangeCAS)) {
    Throw "Script usage error: mandatory parameter ExchangeCAS not specified"
    break
}
if (-not($SearchBase)) {
    Throw "Script usage error: mandatory parameter SearchBase not specified"
    break
}
if (-not($Path)) {
    Throw "Script usage error: mandatory parameter Path not specified"
    break
}

# Check existence of path
if (-not(Test-Path $Path)) {
    Throw "Script context error: specified parameter Path does not exist"
    break
}

# Check if $Path has been specified, and if not use default, but first check existence of logs folder below specified path, and create it if required
if ($LogPath -eq "") {
    if (-not(Test-Path "$Path\logs")) {
        New-Item -Path "$Path\logs" -ItemType directory -force
        $LogPath = "$Path\logs"
    }
}

#endregion
#region Preliminary setup

[string]$logFile = "$LogPath\ProvisionMBs {0}.$LogExtension" -f (get-date -Format "yyyy-MM-dd")

# Append log header for current execution
"" | out-file -FilePath $logFile -Encoding 'Default' -Append
"Begin execution, " + [string](get-date) | Add-Content -Path $logFile

# Check if $AdminAccount has been specified, and if so use to construct mailbox administrator credentials using specified $PWFileName
if ($AdminAccount -ne "") {
    [string]$pwFile = "$Path\$PWFileName"
    $password = get-content $pwFile | convertto-securestring
    $userCredential =  New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $AdminAccount,$password
}

# Create new exchange session
"Connecting to $ExchangeCAS" | Add-Content -Path $logFile
if ($AdminAccount -ne "") {
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ExchangeCAS/PowerShell/ -Authentication Kerberos -Credential $userCredential
} else {
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ExchangeCAS/PowerShell/
}
Import-PSSession $session -ErrorAction SilentlyContinue -AllowClobber

# Import standard AD PowerShell library
Import-Module ActiveDirectory

#endregion
#region Main section: set up an O365 mailbox for any user who needs one

# Lookup AD users using supplied parameters
$users = get-aduser -LDAPFilter $Filter -searchbase $SearchBase -searchscope "Subtree" -Properties extensionAttribute14
if ($users -ne $null) {

    # Loop through collection of returned user accounts, creating a mailbox for each one until either collection is fully processed or specified limit is reached
    [int]$batchCount = 0
    foreach ($user in $users) {

        $Error.clear() 
        "Remote Mail-enabling $user (" + $user.sAMAccountName + ")" | Add-Content -Path $logFile 

        # Create the remote mailbox object in on-prem exchange (AADConnect will then sync it up to O365)
        try {
            if ($SkipMailboxOperations) {
                Write-Host "Skipping remote mailbox enable for $($user.$Alias)"
            }
            else {
                Enable-RemoteMailbox $user.sAMAccountName -Alias $user.$Alias | Add-Content -Path $logFile
            }
            $batchCount = $batchCount + 1
        } 
        catch {} 
        
        # Enable-RemoteMailbox failed
        if ($Error.Count -gt 0) { 
            if ($Error[0].Exception -ilike '*RemoteException*') {
                "Error enabling remote mailbox: " + $Error[0].Exception | Add-Content -Path $logFile
            }
            else {
                "Error: " + $Error[0].Exception | Add-Content -Path $logFile
                Throw $Error
            }

        # Enable-RemoteMailbox was successful
        } else {

            # Set EA6 to flag this user as O365 provisioned
            try {
                $user | Set-ADUser -Replace @{ "extensionAttribute6" = "O365-$UserType" } | Add-Content -Path $logFile
            }
            catch {}

            if ($Error.Count -gt 0) {
                $Error[0].Exception | Add-Content -Path $logFile
                Throw $Error
            }

            # If the user is either a student, or staff with extensionAttribute14="edu" then we set a gmail forwarder
            if ($ForwardingMailDomain -and ($UserType -eq "student" -or ($UserType -eq "staff" -and $user.extensionAttribute14 -eq "edu"))) {
                try {
                    $mailPrefix = $user.$Alias
                    if ($SkipMailboxOperations) {
                        Write-Host "Skipping ForwardingSMTPAddress setup for $mailPrefix@$ForwardingMailDomain"
                    }
                    else {
                        Set-Mailbox -Identity $user.sAMAccountName -DeliverToMailboxAndForward $true -ForwardingSMTPAddress "$mailPrefix@$ForwardingMailDomain"
                    }
                } 
                catch {} 

                if ($Error.Count -gt 0) { 
                    if ($Error[0].Exception -ilike 'WARNING*') {
                        $Error[0].Exception | Add-Content -Path $logFile
                    }
                    else {
                        "Error: " + $Error[0].Exception | Add-Content -Path $logFile
                        Throw $Error
                    }
                } 
            }
        }
        if (($BatchLimit -ne -1) -and ($batchCount -gt $BatchLimit)) {
            break
        }
    }
}

#endregion
#region Finish up

# Append log footer for current execution
"End execution, " + [string](get-date) | Add-Content -Path $logFile

# Delete all log Files in target folder older than $Daysback day(s)
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays(-$Daysback)
Get-ChildItem $LogPath -Include "*.$LogExtension" -Recurse | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item

# Destroy current session
Remove-PSSession -session $session

#endregion