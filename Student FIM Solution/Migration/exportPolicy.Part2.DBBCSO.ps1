# ExportPolicy.ps1
# Copyright © 2009 Microsoft Corporation

# The purpose of this script is to export the current policy and synchronization configuration in the pilot environment.

# The script stores the configuration into file "policy.xml" in the current directory.
# Please note you will need to rename the file to Pilot_policy.xml or production_policy.xml.
# See the documentation for more information.
#
# The DBBCSO FIM development ("pilot") environment includes various policy objects which are not for migration.  In order to exclude these from 
# every deployment the convention is to prefix all such policy objects with 'AAA' so that the FIM query used to export this policy can filter these objects.
#
# Also, this script is a further variation to the standard in order for the DBBCSO FIM design to accommodate the dependencies on custom FIM schema synchronized 
# to the FIM metaverse. This is achieved through splitting the standard "exportPolicy.ps1" script into 2 parts to ensure that ma-data and mv-data dependencies 
# can be successfully negotiated.
#
# In part 2 we are now interested in all remaining policy that was excluded in part 1 (i.e. all dependencies on the ma-data and mv-data objects in the portal, 
# but at the same time grants the FIM Synchronization Service account the rights it needs to refresh the FIM Synchronization Server schema).
# 
# Bob Bradley, Dec 2011

if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}

$policy_filename = "C:\Unify Solutions\FIM Scripts\policy_part2.xml"
Write-Host "Exporting configuration objects from pilot."
# In many production environments, some Set resources are larger than the default message size of 10 MB.
$policy = Export-FIMConfig -customConfig "/Function","/SynchronizationFilter","/SynchronizationRule[not(starts-with(DisplayName,'AAA'))]",`
    "/SearchScopeConfiguration[not(starts-with(DisplayName,'AAA'))]","/HomepageConfiguration","/ObjectVisualizationConfiguration","/NavigationBarConfiguration[not(starts-with(DisplayName,'AAA'))]",`
    "/PortalUIConfiguration","/ConstantSpecifier","/EmailTemplate","/FilterScope",`
    "/ActivityInformationConfiguration[not(starts-with(DisplayName,'Event Broker'))and not(starts-with(DisplayName,'DBBCSO - Generate Unique Account Name'))]",`
    "/Set[not(starts-with(DisplayName,'AAA')) and not(DisplayName='Lockout gate registration resources') and not(DisplayName='Administrators')]",`
     "/WorkflowDefinition[(not(starts-with(DisplayName,'AAA')) and((starts-with(DisplayName,'DBBCSO - Event Broker')) or starts-with(DisplayName,'DBBCSO - Manage Unique AccountName')))]",`
    "/ManagementPolicyRule[not(starts-with(DisplayName,'AAA'))]"     -MessageSize 9999999 -AllLocales
if ($policy -eq $null)
{
    Write-Host "Export did not successfully retrieve configuration from FIM.  Please review any error messages and ensure that the arguments to Export-FIMConfig are correct."
}
else
{
    Write-Host "Exported " $policy.Count " objects from pilot."
    $policy | ConvertFrom-FIMResource -file $policy_filename
    Write-Host "Pilot file is saved as " $policy_filename "."
    if($policy.Count -gt 0)
    {
        Write-Host "Export complete.  The next step is run SyncPolicy.ps1."
    }
    else
    {
        Write-Host "While export completed, there were no resources.  Please ensure that the arguments to Export-FIMConfig are correct."
    }
}