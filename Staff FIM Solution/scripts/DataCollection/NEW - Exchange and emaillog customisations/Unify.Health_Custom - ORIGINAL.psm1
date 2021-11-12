<#
Unify.Health-Custom.psm1

Add functions that gather and export data additional to that covered by the base Unify.Health functions.
It is also possible to override Unify.Health functions - if a function with the same name is added here it will be used instead.

The following functions MUST exist:
 * Get-HealthModuleCustomVersion - Specifies the version number for this script
 * Export-Custom - This is the only function called by Run-HealthCheck.ps1
#>

Function Get-HealthModuleCustomVersion
{
    $ScriptVersions.Add("Unify.Health_Custom.psm1","2.4")
}

Function Export-Custom
{
<#
.SYNPOSIS
    Called by Run-Health.ps1. All custom functions must be run by this function.
.OUTPUT

.PARAMETERS
    Parameters: The Parameters hashtable
    RunType: All or Diff
.DEPENDENCIES    

.ChangeLog

#>
    PARAM (
        [Parameter(Mandatory=$true)][hashtable]$Parameters, 
        [Parameter(Mandatory=$true)][string]$RunType
        )
    END
    {
        ## Custom content here
    }
}
