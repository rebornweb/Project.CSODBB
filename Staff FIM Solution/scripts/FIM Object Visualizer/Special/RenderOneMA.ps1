#----------------------------------------------------------------------------------------------------------
 $xmlFileName = $myInvocation.mycommand.Path -replace ".ps1",".xml"
 if($args.count -ne 1) {throw "Missing MA name parameter"}
 $maName = $args[0]
 
 $xmlFileName = $myInvocation.mycommand.Path -replace ".ps1",".xml"
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $exportData = export-fimconfig -uri "http://localhost:5725/resourcemanagementservice" `
                                -customconfig ("ma-data[DisplayName='$maName']")

#
#                                –onlyBaseResources `
#                                -customconfig ("ma-data[DisplayName='$maName']") `
#                                -ErrorVariable Err `
#                                -ErrorAction SilentlyContinue 
 if($Err){throw $Err}
 if($exportData -eq $null) {throw "Object not found"}
 
 $attrList = $exportData.ResourceManagementObject.ResourceManagementAttributes | 
             Where-Object {$_.AttributeName -eq "SyncConfig-attribute-inclusion"}
 
 [xml]$xmlAttrs = "<attributes>" + $attrList.Value + "</attributes>"
#----------------------------------------------------------------------------------------------------------
 clear-host
 write-host "Selected Attributes"
 write-host "==================="
 
 if($attrList -eq $null) {"There are no attributes selected"}
# else {$xmlAttrs.root.attribute | foreach{write-host "- $_"}}
 else {$xmlAttrs.documentelement.attribute | foreach{write-host "- $_"}}
 write-host "`nCommand completed successfully`n"
#----------------------------------------------------------------------------------------------------------
 trap 
 { 
    write-host "`nError: $($_.Exception.Message)`n" -foregroundcolor white -backgroundcolor darkred
    Exit
 }
#----------------------------------------------------------------------------------------------------------
