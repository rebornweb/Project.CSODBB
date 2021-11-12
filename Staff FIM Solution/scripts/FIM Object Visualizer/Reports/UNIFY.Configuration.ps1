#----------------------------------------------------------------------------------------------------------
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $curFolder  = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileName = "$dataFolder\" + $myInvocation.mycommand.Name -replace ".ps1",".xml"
#----------------------------------------------------------------------------------------------------------
$xmlPolicy = Export-FIMConfig -customConfig "/ForestConfiguration","/DomainConfiguration","/ActivityInformationConfiguration[not(starts-with(DisplayName,'AAA')) and not(starts-with(DisplayName,'DEEWR')) and not(starts-with(DisplayName,'clink'))]"`
    ,"/HomepageConfiguration[not(starts-with(DisplayName,'AAA')) and not(starts-with(DisplayName,'DEEWR')) and not(starts-with(DisplayName,'clink'))]","/SystemResourceRetentionConfiguration[not(starts-with(DisplayName,'AAA')) and not(starts-with(DisplayName,'DEEWR')) and not(starts-with(DisplayName,'clink'))]"`
    ,"/NavigationBarConfiguration[not(starts-with(DisplayName,'AAA')) and not(starts-with(DisplayName,'DEEWR')) and not(starts-with(DisplayName,'clink'))]","/PortalUIConfiguration[not(starts-with(DisplayName,'AAA')) and not(starts-with(DisplayName,'DEEWR')) and not(starts-with(DisplayName,'clink'))]","/ObjectVisualizationConfiguration" -MessageSize 9999999 -AllLocales|
 where-object {$_.ResourceManagementObject.ResourceManagementAttributes}
 
if ($xmlPolicy -eq $null)
{
    Write-Host "Export did not successfully retrieve configuration from FIM.  Please review any error messages and ensure that the arguments to GetFIMObjects are correct."
}
else
{
    # Write-Host "Exported " $xmlPolicy.Count " objects from FIM."
    $xmlPolicy | ConvertFrom-FIMResource -file $fileName
    # Write-Host "Pilot file is saved as " $fileName "."
    if($xmlPolicy.Count -gt 0)
    {
        Write-Host "Export complete."
    }
    else
    {
        Write-Host "While export completed, there were no resources.  Please ensure that the arguments to Export-FIMConfig are correct." 
     }
}
#----------------------------------------------------------------------------------------------------------
 trap 
 { 
    Write-Host "`nError: $($_.Exception.Message)`n" -foregroundcolor white -backgroundcolor darkred
    Exit 1
 }
#----------------------------------------------------------------------------------------------------------
