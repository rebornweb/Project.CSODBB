#------------------------------------------------------ 
# Description:	This script update names and emails on AD, Exchange,etc...
#              
# Author:       Anthony SOQUIN, 14/03/2019
# Project:      CSODBB - Change Name Process
# Version:      v0.1
#
# Usage:        .\NameChangeScript.ps1 -ConfigFile NameChangeConfig.ps1
#------------------------------------------------------ 
# History:      v0.1 Initial version
#              
#------------------------------------------------------ 
param 
(
    $ConfigFile = "C:\Users\anthony.soquin.tst\Desktop\Script\NameChangeConfig.ps1",
    [Parameter(Mandatory = $true)] $AccountName,
    [Parameter(Mandatory = $false)] $ComputerName,
    $FirstName = "",
    $LastName = "",
    $PreferredName = ""    
)
. $ConfigFile

#Load Logger
$runDir = $RunningDir
if($RunningDir[$RunningDir.length - 1] -ne "\")
{
    $runDir = $runDir + "\"
}
Set-Location $runDir

#$logModule = $runDir + "Logging.ps1"
#. $logModule
try {
    $methodsModule = $runDir + "ADMethods.ps1"
    . $methodsModule
}
catch [System.Exception] {
    $log.Append("An error occurred while loading extra modules.")
    $log.LogFatalError($_.Exception)
	Exit 2
}

if ($PreferredName)
{
    $FirstName = $PreferredName
}
$AdminUserName = whoami

$log.Append("")
$log.Append("##############################################################")
$log.Append("Starting Name Change Process")
$log.Append("Operator: $AdminUserName")
$log.Append("##############################################################")
#Active Directory Section
Write-Output ""
Write-Output "##############################################################"
Write-Output "Update User information in Active Directory"
$log.Append( "Update User information in Active Directory")
Write-Output "##############################################################"

$ADCredential  = New-Object -typename System.Management.Automation.PSCredential -argumentlist $ADUsername, $ADPassword
try 
{
    $ADUser = Get-ADUser -Identity $AccountName -Server $DC -Credential $ADCredential -Properties * #-SearchBase $RootOU
    
}
catch 
{
    Write-Error "User not found in Active Directory. Please vefiry the Account Name value."
	Exit 2
}

Write-Output "Account Name: $($ADUser.SamAccountName)"
Write-Output "Display Name: $($ADUser.Name)"
Write-Output "First Name: $($ADUser.GivenName)"
Write-Output "Last Name: $($ADUser.Surname)"
Write-Output "Email: $($ADUser.Mail)"
Write-Output "User Principal Name: $($ADUser.UserPrincipalName)"
Write-Output "Mail Nickname: $($ADUser.mailNickname)"
Write-Output "CN: $($ADUser.cn)"
Write-Output "DN: $($ADUser.DistinguishedName)"
Write-Output "ProfilePath: $($ADUser.ProfilePath)"

$log.Append("Account Name: $($ADUser.SamAccountName)")
$log.Append("Display Name: $($ADUser.Name)")
$log.Append("First Name: $($ADUser.GivenName)")
$log.Append("Last Name: $($ADUser.Surname)")
$log.Append("Email: $($ADUser.Mail)")
$log.Append("User Principal Name: $($ADUser.UserPrincipalName)")
$log.Append("Mail Nickname: $($ADUser.mailNickname)")
$log.Append("CN: $($ADUser.cn)")
$log.Append("DN: $($ADUser.DistinguishedName)")
$log.Append("ProfilePath: $($ADUser.ProfilePath)")

$OldEmailAddress =  $ADUser.Mail

$UserNameCandidate = GenerateAcctName -FirstName $FirstName -LastName $LastName -NumFirstDigits 18 -NumLastDigits 18 -NumMaxDigits 20
$UserNameUnique = $False
$Digit = 0
While (!$UserNameUnique)
{ 
    $UserNameUnique = UniqueInAD -ADAttribute "SamAccountName" -SearchValue $UserNameCandidate  $SearchBase $RootOU  -ADObjClass $ObjectToManage -ADCreds $ADCredential -Log $Log -CustomFilter $null -FQDomain $FQDomain -AttributesToInclude $null

	if ($UserNameUnique)
    {
        $EmailCandidate = $UserNameCandidate + "@" + $EmailSuffix
        $EmailUnique = UniqueInAD -ADAttribute "Mail" -SearchValue $EmailCandidate  $SearchBase $RootOU  -ADObjClass $ObjectToManage -ADCreds $ADCredential -Log $Log -CustomFilter $null -FQDomain $FQDomain -AttributesToInclude $null
        if ($EmailUnique)
        {
            $UPNCandidate = $UserNameCandidate + "@" + $UPNSuffix
            $UPNUnique = UniqueInAD -ADAttribute "UserPrincipalName" -SearchValue $UPNCandidate  $SearchBase $RootOU  -ADObjClass $ObjectToManage -ADCreds $ADCredential -Log $Log -CustomFilter $null -FQDomain $FQDomain -AttributesToInclude $null
            if ($UPNUnique)
            {
                $UserNameUnique = $true
            }
            else
            {
                $UserNameUnique = $false
            }
        }
        else 
        {
            $UserNameUnique = $false
        }
    }
    else 
    {
        $UserNameUnique = $false
    }

    if (!$UserNameUnique)
    {
        $Digit++  
    
		if ($Digit -gt 9)
		{
			$UserNameCandidate = GenerateAcctName -FirstName $FirstName -LastName $LastName -NumFirstDigits 18 -NumLastDigits 18 -NumMaxDigits 18
		}
		else 
		{
			$UserNameCandidate = GenerateAcctName -FirstName $FirstName -LastName $LastName -NumFirstDigits 18 -NumLastDigits 18 -NumMaxDigits 19
		}
		$UserNameCandidate =  $UserNameCandidate + $Digit
	}
}

$ValidAccountName = $UserNameCandidate
$NewEmail = $ValidAccountName + "@" + $EmailSuffix
$NewUPN = $ValidAccountName + "@" + $UPNSuffix
$NewDisplayName = $FirstName + " " + $LastName
$NewCN = $FirstName + " " + $LastName

if ($ADUser.DistinguishedName -Match "Students")
{
    $NewDisplayName = $FirstName + ", " + $LastName + "(" + $ADUser.extensionAttribute13 + ")"
    if ($Digit -gt 0)
    {
        $NewCN = $FirstName + " " + $LastName + $Digit
    }
    else 
    {
        $NewCN = $FirstName + " " + $LastName
    }

}


$NewProfilePath = "\\dbb.local\local\users\" + $ValidAccountName

Write-Output ""
Write-Output ""
Write-Output "!! Please verify the following details: "
Write-Output "New Account Name: $ValidAccountName"
Write-Output "New Display Name: $NewDisplayName"
Write-Output "New Email: $NewEmail"
Write-Output "New User Principal Name: $NewUPN"
Write-Output "New CN: $NewCN"
Write-Output "New  ProfilePath: $NewProfilePath"
Write-Output ""

while (!$CorrectAnswer)
{
    $Answer = Read-Host -Prompt "Do you want to update user details with these new values? Please type 'Yes' or 'No'"

    if ($Answer.ToLower() -contains "yes")
    {   
        $CorrectAnswer = $true
		Rename-ADObject $ADUser.DistinguishedName -NewName $NewCN
		Set-ADUser -Identity $AccountName -GivenName $FirstName -Surname $LastName -EmailAddress $NewEmail -UserPrincipalName $NewUPN -SamAccountName $ValidAccountName -DisplayName $NewDisplayName -ProfilePath $NewProfilePath
    }
    elseif ($Answer.ToLower() -contains "no") 
    {
        Exit 0
    }
}

Write-Output "##############################################################"
Write-Output "User information Updated in Active Directory with Success"
Write-Output "##############################################################"


$ADUser = Get-ADUser -Identity $ValidAccountName -Server $DC -Credential $ADCredential  -Properties * # -SearchBase $RootOU
Write-Output "Account Name: $($ADUser.SamAccountName)"
Write-Output "Display Name: $($ADUser.Name)"
Write-Output "First Name: $($ADUser.GivenName)"
Write-Output "Last Name: $($ADUser.Surname)"
Write-Output "Email: $($ADUser.Mail)"
Write-Output "User Principal Name: $($ADUser.UserPrincipalName)"
Write-Output "Mail Nickname: $($ADUser.mailNickname)"
Write-Output "CN: $($ADUser.cn)"
Write-Output "DN: $($ADUser.DistinguishedName)"
Write-Output "ProfilePath: $($ADUser.ProfilePath)"
Write-Output ""

$log.Append("")
$log.Append("User information Updated in Active Directory with Success")
$log.Append("Account Name: $($ADUser.SamAccountName)")
$log.Append("Display Name: $($ADUser.Name)")
$log.Append("First Name: $($ADUser.GivenName)")
$log.Append("Last Name: $($ADUser.Surname)")
$log.Append("Email: $($ADUser.Mail)")
$log.Append("User Principal Name: $($ADUser.UserPrincipalName)")
$log.Append("Mail Nickname: $($ADUser.mailNickname)")
$log.Append("CN: $($ADUser.cn)")
$log.Append("DN: $($ADUser.DistinguishedName)")
$log.Append("ProfilePath: $($ADUser.ProfilePath)")
$log.Append("")

#Exchange Section
Write-Output "##############################################################"
Write-Output "Update User information in Exchange"
Write-Output "##############################################################"

$ExchangeCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist $ExchangeUsername, $ExchangePassword
$ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$ExchangeServerAddress/PowerShell/" -Authentication Kerberos -Credential $ExchangeCredential 
Import-PSSession $ExchangeSession -DisableNameChecking -AllowClobber

$ExchangeMailBox = Get-Mailbox -Identity $AccountName  | select *

Write-Output "Account Name: $($ExchangeMailBox.SamAccountName)"
Write-Output "Display Name: $($ExchangeMailBox.DisplayName)"
Write-Output " Name: $($ExchangeMailBox.Name)"
Write-Output "Alias: $($ExchangeMailBox.Alias)"
Write-Output "Primary Email: $($ExchangeMailBox.PrimarySmtpAddress)"
Write-Output "User Principal Name: $($ExchangeMailBox.UserPrincipalName)"

$log.Append("Update User information in Exchange")
$log.Append("Account Name: $($ExchangeMailBox.SamAccountName)")
$log.Append("Display Name: $($ExchangeMailBox.DisplayName)")
$log.Append(" Name: $($ExchangeMailBox.Name)")
$log.Append("Alias: $($ExchangeMailBox.Alias)")
$log.Append("Primary Email: $($ExchangeMailBox.PrimarySmtpAddress)")
$log.Append("User Principal Name: $($ExchangeMailBox.UserPrincipalName)")

Set-MailBox -Identity  $AccountName -Alias $ValidAccountName  -DisplayName  $NewDisplayName -Name $ValidAccountName -PrimarySmtpAddress $NewEmail -UserPrincipalName $NewUPN -EmailAddressPolicyEnabled $false

Write-Output "##############################################################"
Write-Output "User information Updated in Exchange with Success"
Write-Output "##############################################################"


$ExchangeMailBox = Get-Mailbox -Identity $NewEmail  | select * 

Write-Output "Account Name: $($ExchangeMailBox.SamAccountName)"
Write-Output "Display Name: $($ExchangeMailBox.DisplayName)"
Write-Output " Name: $($ExchangeMailBox.Name)"
Write-Output "Alias: $($ExchangeMailBox.Alias)"
Write-Output "Primary Email: $($ExchangeMailBox.PrimarySmtpAddress)"
Write-Output "User Principal Name: $($ExchangeMailBox.UserPrincipalName)"
Write-Output ""

$log.Append("User information Updated in Exchange with Success")
$log.Append("Account Name: $($ExchangeMailBox.SamAccountName)")
$log.Append("Display Name: $($ExchangeMailBox.DisplayName)")
$log.Append(" Name: $($ExchangeMailBox.Name)")
$log.Append("Alias: $($ExchangeMailBox.Alias)")
$log.Append("Primary Email: $($ExchangeMailBox.PrimarySmtpAddress)")
$log.Append("User Principal Name: $($ExchangeMailBox.UserPrincipalName)")
$log.Append("")

Remove-PSSession $ExchangeSession

if ($ComputerName)
{
	#User Profile Section
	Write-Output "##############################################################"
	Write-Output "Update User Profile"
	Write-Output "##############################################################"

	$UserComputerCredentail = new-object -typename System.Management.Automation.PSCredential -argumentlist $ComputerUsername, $ComputerPassword
	$UserComputerSession = New-PsSession -ComputerName $ComputerName -Credential $UserComputerCredentail

	Import-PSSession $UserComputerSession 
	$OldDirectory = $DefaultUserDirectory  + $AccountName
	$NewDirectory = $DefaultUserDirectory  + $ValidAccountName
	#New-Item -ItemType "directory" -Path $NewDirectory
	#Copy-Item "$OldDirectory\*" -Destination $NewDirectory -Recurse

	Write-Output "##############################################################"
	Write-Output "User Profile Updated Successfully"
	Write-Output "##############################################################"
	Write-Output ""
	#Outlook Profile Section
	Write-Output "##############################################################"
	Write-Output "Update Outlook Profile"
	Write-Output "##############################################################"
	$NewOutlookProfileDirectory = $NewDirectory + "\AppData\Local\Microsoft\Outlook"
	Set-Location -Path $NewOutlookProfileDirectory

	#Rename-Item -Path "$OldEmailAddress.ost" -NewName "$NewEmail.ost"
	#Rename-Item -Path "$OldEmailAddress.nst" -NewName "$NewEmail.nst"

	Remove-PSSession $UserComputerSession

	Write-Output "##############################################################"
	Write-Output "Outlook Profile Updated Successfully"
	Write-Output "##############################################################"
}
