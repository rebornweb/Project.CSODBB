#------------------------------------------------------ 
# Description:	This script will define a unique Account Name
#              
# Author:       Anthony SOQUIN, 12/8/2019
# Project:      CSODBB - Change Name Process
# Version:      v0.1
#
# Usage:        
#------------------------------------------------------ 
# History:      v0.1 Initial version (Anthony - adapted from NameChangeScript.ps1)
#               v0.2 Minor usability adjustments + removal of $ADCredential usage (Bob Bradley, 12/8/2019)
#------------------------------------------------------ 
param 
(
    [Parameter(Mandatory = $true)] $AccountName,
    # Bob>> Default to $null not "" to allow defaulting
    $FirstName = $null,
    $LastName = $null,
    $PreferredName = $null
    # Bob<<
)

$RootOU = "DC=dbb,DC=local"
$FQDomain = "dbb.local"
$ObjectToManage = "user"
# Bob>> AD attributes to return
$AttributesToInclude = @("SamAccountName","Name","GivenName","Surname","Mail","UserPrincipalName","mailNickname","cn","DistinguishedName","ProfilePath")
# Bob<<

# Parameter Validation - must be at least one of FirstName, LastName or PreferredName
if ((!$FirstName) -and (!$LastName) -and (!$PreferredName))
{
    Throw "Usage error: must supply at least one of FirstName, LastName or PreferredName parameters"
}


##
## Remove-Diacritics - Converts accented characters to a non-accented version
## 
## Input: String to convert
## Returns: Converted string
##
function RemoveDiacritics([string]$InputString) {
    $inputFormD = $InputString.Normalize([Text.NormalizationForm]::FormD)
    $outStringB = New-Object Text.StringBuilder
	
    $charIndex = 0
    while ($charIndex -lt $inputFormD.Length) {
        $inputChar = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($inputFormD[$charIndex])
        if ($inputChar -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
            $outStringB.Append($inputFormD[$charIndex]) | Out-Null
        }
        $charIndex++
    }
	
    $retString = $outStringB.ToString().Normalize([Text.NormalizationForm]::FormC)
    return $retString
}

function RemoveNonAsciiChars([string]$InputString) {
    $retString = (RemoveDiacritics $InputString).ToLower() -Replace "[^a-z0-9]", ""
    return $retString
}


Function UniqueInAD {
    PARAM ($ADAttribute, $SearchValue, $SearchBase, $ADObjClass, $AttributesToInclude, $FQDomain, $Log, $CustomFilter)
    $attrUnique = $false
	
    $ldapFilter = $null
    if (-not [string]::IsNullOrEmpty($CustomFilter)) {
        $ldapFilter = $CustomFilter
    }
    else {
        $ldapFilter = "(&(objectClass={0})({1}={2}))" -f $ADObjClass, $ADAttribute, $SearchValue
    }
	
    #Perform AD Search, and return 1st match.
    $ADObj = Get-ADObject -LDAPFilter $ldapFilter -ResultSetSize 1 -Server $FQDomain
	
    #If a value is returned, this attribute is not unique.
    if ($ADObj -ne $null) {
        $attrUnique = $false
        $objJson = $ADObj | ConvertTo-Json
    }
    else {
        $attrUnique = $true
    }	
    return $attrUnique      
}

function GenerateAcctName {
    PARAM($FirstName, $LastName, $NumFirstDigits, $NumLastDigits, $NumMaxDigits)
	
    $firstN = RemoveNonAsciiChars $FirstName
    $lastN = RemoveNonAsciiChars $LastName
	
    if ($firstN.Length -gt $NumFirstDigits) {
        $firstN = $firstN.SubString(0, $NumFirstDigits)
    }	
    if ($lastN.Length -gt $NumLastDigits) {
        $lastN = $lastN.SubString(0, $NumLastDigits)
    }
    
    
    $acctName = $firstN + "." + $lastN
	if ($acctName.length -gt 19)
	{
		$acctName = $acctName.SubString(0, $NumMaxDigits)
	}    
	
    return $acctName
}

function GenerateCN {
    PARAM($FirstName, $LastName)
	
    $firstN = RemoveNonAsciiChars $FirstName
    $lastN = RemoveNonAsciiChars $LastName
    $firstN = (Get-Culture).TextInfo.ToTitleCase($firstN)
    $lastN = (Get-Culture).TextInfo.ToTitleCase($lastN)
    $newCN = $lastN + ", " + $firstN
    return $newCN
}

function CheckAttributes($Attribs) {
    $CheckOk = $true
    foreach ($attrib in $Attribs) {
        if ([string]::IsNullOrEmpty($attrib)) {
            $CheckOk = $false
        }
    }
    return $CheckOk
}

function ConvertCN($ADCN) {
    return $ADCN.ToString().Replace(",", "\,")
}

function GenerateUniqueAccountName {
    PARAM($FirstName, $LastName, $MiddleName, $AssignedAccounts, $Log)
	
    $uniqueName = $false
    $acctName = ""
    $uniqueVal = 2
    while (-not $uniqueName) { #Increment and Appent a number until a unique name is found.

        $LastNameLength = [System.Math]::Min((6 - $uniqueVal.toString().length), $LastName.toString().Length)
        $acctName = GenerateAcctName -FirstName $cleanFirstname -MiddleName $cleanMiddleName -LastName $cleanLastName -NumFirstDigits 1 -NumLastDigits $LastNameLength
        $acctName += $uniqueVal
				
        $acctName = $acctName.ToLower()
        $found = $false
        foreach ($acc in $AssignedAccounts) {
            if ($acctName -eq $acc) {
                $found = $true
                break;
            }
        }
		
        if (-not $found ) {
            $uniqueName = $true
        }
        else {
            $uniqueVal++
            while ($uniqueVal.ToString().Contains("0") -or $uniqueVal.ToString().Contains("1")) {
                $uniqueVal++
            }   
        }
		
		
    }
    return $acctName
}

<#if ($PreferredName)
{
    $FirstName = $PreferredName
}#>


#Active Directory Section
Write-Output ""
Write-Output "##############################################################"
Write-Output "User information in Active Directory"
Write-Output "##############################################################"

try 
{
# Bob>> set up $AttributesToInclude
    $ADUser = Get-ADUser -Identity $AccountName -Properties $AttributesToInclude
# Bob<<
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

$OldEmailAddress =  $ADUser.Mail

# Bob>> default values if not supplied, overriding with PreferredName if supplied
if (!$LastName)
{
    $LastName = $ADUser.Surname
}
if (!$FirstName)
{
    if (!$PreferredName)
    {
        $FirstName = $ADUser.GivenName
    }
}
if ($PreferredName)
{
    $FirstName = $PreferredName
}
# Bob<<

$UserNameCandidate = GenerateAcctName -FirstName $FirstName -LastName $LastName -NumFirstDigits 18 -NumLastDigits 18 -NumMaxDigits 20
$UserNameUnique = $False
$Digit = 0
While (!$UserNameUnique)
{ 
    $UserNameUnique = UniqueInAD -ADAttribute "SamAccountName" -SearchValue $UserNameCandidate  $SearchBase $RootOU  -ADObjClass $ObjectToManage -Log $Log -CustomFilter $null -FQDomain $FQDomain -AttributesToInclude $null

	if ($UserNameUnique)
    {
        $EmailCandidate = $UserNameCandidate + "@" + $EmailSuffix
        $EmailUnique = UniqueInAD -ADAttribute "Mail" -SearchValue $EmailCandidate  $SearchBase $RootOU  -ADObjClass $ObjectToManage -Log $Log -CustomFilter $null -FQDomain $FQDomain -AttributesToInclude $null
        if ($EmailUnique)
        {
            $UPNCandidate = $UserNameCandidate + "@" + $UPNSuffix
            $UPNUnique = UniqueInAD -ADAttribute "UserPrincipalName" -SearchValue $UPNCandidate  $SearchBase $RootOU  -ADObjClass $ObjectToManage -Log $Log -CustomFilter $null -FQDomain $FQDomain -AttributesToInclude $null
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

Write-Output ""
Write-Output ""
Write-Output "## Please find below the Account Name: "
Write-Output "New Account Name: $ValidAccountName"
Write-Output ""

Exit 0
