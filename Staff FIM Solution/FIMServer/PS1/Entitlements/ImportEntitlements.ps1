PARAM(
    [string]$RoleName = "BO Vocations", 
    [string]$StartDate, 
    [string]$EndDate = "01/01/2100", 
    [string]$AccountFileName = "BO_Vocations.txt")

# CSODBB-249: Batch import of objects into FIM
# The following script creates entitlements for the specified $RoleName, $StartDate (default todays date) and $AccountFileName.
# *** IMPORTANT: $AccountFileName and FIMPowerShell.ps1 (download from http://technet.microsoft.com/en-us/library/ff720152(v=ws.10).aspx) MUST exist in the same folder as this script!!! ***
# Start and End date values are determined (defaulted) within FIM workflow - since datetime params are not supported in FIM R1.
# Bob Bradley, UNIFY Solutions, 17 June 2013 (initial version)
# *** NOTE: the easiest way to generate a list of account names is using the FIM metaverse search utility with accountName as the only display column.

# Default $StartDate to todays date if not supplied
if (!($StartDate)) {
    $StartDate = (Get-Date).ToString()
}

# Calculate full file paths
$curFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
$accountFile = "$curFolder\" + $AccountFileName
$saveFileName = "$curFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"

# Load FIMPowerShell library
. "$curFolder\FIMPowerShell.ps1"

# Note: in the following function the setting of $StartDate and $EndDate is commented out due to a FIM R1 bug with datetime parameters
function CreateEntitlement
{
    PARAM($RoleName,$AccountName,$idmStartDate,$idmEndDate,$UserID,$csoRoles, $Uri = $DefaultUri)
    END
    {
        $DisplayName = [System.String]::Format("{0} - {1}", $AccountName, $RoleName)
        $Description = [System.String]::Format("{1} entitlements for user {0}", $AccountName, $RoleName)
        [DateTime]$StartDate = Get-Date($idmStartDate)
        [DateTime]$EndDate = Get-Date($idmEndDate)
        $StartDateString = $StartDate.ToString("G")
        $EndDateString = $EndDate.ToString("G")
        
        $NewObj = CreateImportObject -ObjectType "csoEntitlement"
        SetSingleValue -ImportObject $NewObj -AttributeName "DisplayName" -NewAttributeValue $DisplayName
        SetSingleValue -ImportObject $NewObj -AttributeName "Description" -NewAttributeValue $Description
        SetSingleValue -ImportObject $NewObj -AttributeName "csoRecalculate" -NewAttributeValue $False
        #SetSingleValue $NewObj "idmStartDate" $StartDateString
        #SetSingleValue $NewObj "idmEndDate" $EndDateString
        SetSingleValue -ImportObject $NewObj -AttributeName "UserID" -NewAttributeValue $UserID -FullyResolved 0
        $NewRolesArray = @($csoRoles)
        AddMultiValue -ImportObject $NewObj -AttributeName "csoRoles" -NewAttributeValue $NewRolesArray -FullyResolved 0
        
        #$NewObj | Import-FIMConfig -Uri $Uri
        $NewObj
    }
}

# Get role IDs for specified Role Name
$AllRoles = ResolveObject -ObjectType "csoRole" -AttributeName "DisplayName" -AttributeValue $RoleName
#$AllRoles | Import-FIMConfig -Uri $DefaultUri

# Read list of account names from a file (one per line)
$Accounts = Get-Content $accountFile
[string]$AccountName = ""

if ($AllRoles)
{
    $ImportObjects = (,$AllRoles)
    # Create an entitlement record for each valid account in the file
    foreach($AccountName in $Accounts) {
        $AccountName
        # Get UserID for specified Account Name
        $UserID = ResolveObject -ObjectType "Person" -AttributeName "AccountName" -AttributeValue $AccountName
        #$UserID | Import-FIMConfig -Uri $DefaultUri
        if($UserID -ne $NULL)
        {
            $ImportObjects += $UserID
        }
        if ($UserID) {
            $ImportObject = CreateEntitlement `
                -RoleName $RoleName `
                -AccountName $AccountName `
                -UserID $UserID.SourceObjectIdentifier `
                -csoRoles $AllRoles.SourceObjectIdentifier `
                -idmStartDate $StartDate `
                -idmEndDate $EndDate
            if($ImportObject -ne $NULL)
            {
                $ImportObjects += $ImportObject
            }
        }
    }
}

if($ImportObjects)
{
    $ImportObjects | convertfrom-fimresource -file $saveFileName
    $ImportObjects | Import-FIMConfig -Uri $DefaultUri
}


