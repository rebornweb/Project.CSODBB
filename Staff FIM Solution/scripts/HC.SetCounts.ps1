D:
cd D:\scripts
import-module ./FIMPowerShellModules-2.2/FimPowerShellModule.psm1

### Get all the Sets
$sets = Export-FIMConfig -OnlyBaseResources -CustomConfig "/Set[starts-with(DisplayName,'all%')]" |
### Convert to PSObjects (easier to deal with than FIM Export Objects)
Convert-FimExportToPSObject |
### Sort by the count of members
Sort-Object {$_.ExplicitMember.Count} -Descending
### Output as a nice table
$sets | Format-Table DisplayName, @{Name='ExplicitMemberCount';Expression={$_.ExplicitMember.Count}}, @{Name='ComputedMemberCount';Expression={$_.ComputedMember.Count}} -AutoSize
