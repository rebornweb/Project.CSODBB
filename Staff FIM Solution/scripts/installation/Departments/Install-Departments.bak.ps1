PARAM([boolean]$UpdateExisting=$true,[boolean]$Uninstall=$false,[string]$fimSyncServer="occcp-as033")

### Written by Bob Bradley, UNIFY Solutions
###
### Installs the Schema and Policy objects for specified Sync Rules.
###

cls
$ErrorActionPreference = "Stop"

. D:\Scripts\Shared\Set-LocalVariables.ps1
if ($IncludeScripts) {foreach ($IncludeScript in $IncludeScripts) {. $IncludeScript}}

#$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$scriptPath = "D:\Scripts\Installation\Departments"

###
### Check dependencies
###
if (-not (Test-Path ($WFScriptFolder + "\WFFunctions.ps1"))) {Throw ("Expected to find " + $WFScriptFolder + "\WFFunctions.ps1. If it is in a different location then change or set the $WFScriptFolder variable in the Set-LocalVariables.ps1 script.")}
if (-not (Test-Path $WFLogFolder)) {Throw ("Expected to find " + $WFLogFolder + ". If you want to use a different location for Workflow logging then change or set the $WFLogFolder variable in the Set-LocalVariables.ps1 script. Otherwise, create the folder in the specified location.")}

#$filter = "/ActivityInformationConfiguration[ActivityName='FimExtensions.FimActivityLibrary.PowerShellActivity']"
#$Departments = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
#if (-not $Departments) {Throw "The PowerShell activity must be installed."}

$filter = "/csoDepartment"
$Departments = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
if (-not $Departments) {Throw "The 'UNIFY-Create update and delete FIM resource activity' must be installed."}

## Objects to create are stored in hashtables.
## - The Object Type is the top level of the hashtable
## - The Display Name of the object is the next level
## - Under that we must have Add and Update - where "Add" includes attributes that may only be set at object creation
## - If an attribute is multivalued the values must be stored as an array, even if there is only one value to add.


###
### Departments
###

$Objects = @{}

$DepartmentsCSV = get-content -Path $("$scriptPath\StaffDeptUPNSuffix.csv") | ConvertFrom-Csv


$Objects.Add("Departments", @{})

foreach ($dept in $Departments) {
    #$dept = $Departments[0]
    $DeptID = ($dept.ResourceManagementObject.ResourceManagementAttributes | where {$_.AttributeName -eq "csoDeptID"}).Value
    if ($DeptID) {
        $DeptUpnSuffix = ($DepartmentsCSV | where {$_.DEPTID -eq $DeptID})."UPN SUFFIX"
        if ($DeptUpnSuffix) {
            $Objects.Departments.Add($DeptID,
            @{
                #"Add" = @{}
                "Update" = @{
                    "csoUpnSuffix"=$DeptUpnSuffix
                }
                #"Uninstall" = "DeleteObject"
            })
        }
    }
}

ProcessObjects -ObjectType "csoDepartment" -HashObjects $Objects.Departments

#$Objects.Departments."01460".Update
#$Objects.Departments."10000".Update
