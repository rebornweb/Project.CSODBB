PARAM(  
        [string]$ExchangeCAS,
        [string]$SearchBase,
	    [string]$Path,
	    [string]$LogPath = "",
        [string]$AdminAccount = "",
        [string]$PWFileName = "Creds.txt",
        [string]$LegacyVersion = "0.0 (6.5.6500.0)",
        [string]$LogExtension = "log"
)

# Description: Adds a mailbox to newly-created user accounts
# ==========================================================
#
# Usage:
# Mandatory Params:
#    [string]$ExchangeCAS = fqdn of Exchange 2010 Client Access Server (used to construct web url for remote Powershell end point)
#    [string]$SearchBase = OU root of the subtree search for user accounts missing mailboxes, in canonical form, e.g. "dbb.local/Contacts/MyMail"
#    [string]$Path = full path of folder containing this script and optional credentials file
# Optional Params:
#    [string]$LogPath = full path of folder for writing logs, default "" will cause a "\logs" subfolder of $Path to be created if it doesn't already exist
#    [string]$LogExtension = file extension for log files, default ".log"
#    [string]$AdminAccount = identity of mailbox administrator (domain\sAMAccountName format), default "" (i.e. identity of launching context)
#    [string]$PWFileName = file name of encrypted credentials to be located within specified path (used only if $AdminAccount supplied), default "Creds.txt"
#    [string]$LegacyVersion = used to construct filter for users with legacy mailbox version
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

# Check for mandatory parameters
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
[string]$logFile = "$LogPath\UpdateContacts {0}.$LogExtension" -f (get-date -Format "yyyy-MM-dd")

# Append log header for current execution
"" | out-file -FilePath $logFile -Encoding 'Default' -Append
"Begin execution, " + [string](get-date) | Add-Content -Path $logFile
"Connecting to $ExchangeCAS" | Add-Content -Path $logFile

# Check if $AdminAccount has been specified, and if so use to construct mailbox administrator credentials using specified $PWFileName
if ($AdminAccount -ne "") {
    [string]$pwFile = "$Path\$PWFileName"
    $password = get-content $pwFile | convertto-securestring
    $userCredential =  New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $AdminAccount,$password
}

# Create new exchange session
if ($AdminAccount -ne "") {
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ExchangeCAS/PowerShell/ -Authentication Kerberos -Credential $userCredential
} else {
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ExchangeCAS/PowerShell/
}
Import-PSSession $session -ErrorAction SilentlyContinue -AllowClobber | Out-Null

# locate contacts which need upgrading
$contacts = Get-MailContact -OrganizationalUnit $SearchBase -ResultSize Unlimited -Filter {ExchangeVersion -eq $null -or ExchangeVersion -eq $LegacyVersion} # -and PoliciesIncluded -eq $null}
if ($contacts.Count -gt 0) {
    # upgrade each contact returned from query
    $contacts | Set-MailContact -UseMapiRichTextFormat "Always" -ForceUpgrade -Confirm:$False -ErrorAction SilentlyContinue
}

# Append log footer for current execution
"End execution, " + [string](get-date) | Add-Content -Path $logFile

# Destroy current session
Remove-PSSession -session $session
