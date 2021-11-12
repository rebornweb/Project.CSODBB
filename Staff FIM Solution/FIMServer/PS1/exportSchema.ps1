# ExportSchema.DEEWR.ps1
# Copyright � 2009 Microsoft Corporation

# The purpose of this script is to export the current schema configuration
# in the pilot environment.

# Adapted for DEEWR

# The script stores the configuration into file "schema.xml" in the current directory.
# Please note you will need to rename the file to pilot_schema.xml or production_schema.xml.
# See the documentation for more information.
#
# The DEEWR FIM development ("pilot") environment includes various schema objects which are not for migration.  In order to exclude these from 
# every deployment the convention is to prefix all such schema objects with 'AAA' so that the FIM query used to export this schema can filter these objects.
#
# Bob Bradley, Dec 2011

if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}

$schema_filename = "E:\Scripts\Output\schema.xml"
Write-Host "Exporting configuration objects from pilot."
# Please note that SynchronizationFilter Resources inform the FIM MA.
# $schema = Export-FIMConfig -customConfig "/AttributeTypeDescription[not(starts-with(DisplayName,'AAA'))]","/ObjectTypeDescription[not(starts-with(DisplayName,'AAA'))]","/BindingDescription[not(starts-with(DisplayName,'AAA'))]" -MessageSize 9999999 -AllLocales
$schema = Export-FIMConfig -customConfig "/AttributeTypeDescription[not(starts-with(DisplayName,'AAA'))]","/ObjectTypeDescription[not(starts-with(DisplayName,'AAA'))]","/BindingDescription[BoundAttributeType=/AttributeTypeDescription[not(starts-with(DisplayName,'AAA'))]]" -MessageSize 9999999 -AllLocales

if ($schema -eq $null)
{
    Write-Host "Export did not successfully retrieve configuration from FIM.  Please review any error messages and ensure that the arguments to Export-FIMConfig are correct."
}
else
{
    Write-Host "Exported " $schema.Count " objects from pilot."
    $schema | ConvertFrom-FIMResource -file $schema_filename
    Write-Host "Pilot file is saved as " $schema_filename "."
    if($schema.Count -gt 0)
    {
        Write-Host "Export complete.  The next step is to run ExportPolicy.DEEWR.ps1."
    }
    else
    {
        Write-Host "While export completed, there were no resources.  Please ensure that the arguments to Export-FIMConfig are correct." 
     }
}