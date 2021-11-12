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
    PARAM ($ADAttribute, $SearchValue, $SearchBase, $ADObjClass, $AttributesToInclude, $FQDomain, $ADCreds, $Log, $CustomFilter)
    #$Log.DebugValue("ADAttribute", $ADAttribute)
    #$Log.DebugValue("SearchValue", $SearchValue)
    #$Log.DebugValue("SearchBase", $SearchBase)
    #$Log.DebugValue("ADObjClass", $ADObjClass)
    #$Log.DebugValue("FQDomain", $FQDomain)
    #$Log.DebugValue("CustomFilter", $CustomFilter)
	
    $attrUnique = $false
	
    $ldapFilter = $null
    if (-not [string]::IsNullOrEmpty($CustomFilter)) {
        $ldapFilter = $CustomFilter
    }
    else {
        $ldapFilter = "(&(objectClass={0})({1}={2}))" -f $ADObjClass, $ADAttribute, $SearchValue
    }
    #$Log.DebugValue("ldapFilter", $ldapFilter)
    #$Log.DebugArray("AttributesToInclude", $AttributesToInclude)
	
    #Perform AD Search, and return 1st match.
    $ADObj = Get-ADObject -LDAPFilter $ldapFilter -ResultSetSize 1 -Server $FQDomain -Credential $ADCreds #-Properties $AttributesToInclude #-SearchBase $SearchBase 
	
    #If a value is returned, this attribute is not unique.
    if ($ADObj -ne $null) {
        $attrUnique = $false
        $objJson = $ADObj | ConvertTo-Json
        #$Log.DebugValue("ADObj", $objJson)
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
        #$Log.DebugValue("FirstName", $FirstName)
        #$Log.DebugValue("LastName", $LastName)
        #$Log.DebugValue("MiddleName", $MiddleName)
		
        $LastNameLength = [System.Math]::Min((6 - $uniqueVal.toString().length), $LastName.toString().Length)
        $acctName = GenerateAcctName -FirstName $cleanFirstname -MiddleName $cleanMiddleName -LastName $cleanLastName -NumFirstDigits 1 -NumLastDigits $LastNameLength
        $acctName += $uniqueVal
        #$Log.DebugValue("acctName", $acctName)
				
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