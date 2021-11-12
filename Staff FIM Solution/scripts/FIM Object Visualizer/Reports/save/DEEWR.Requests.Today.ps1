#----------------------------------------------------------------------------------------------------------
 Function execute-ArchiveSP
 {
    Param($svr,$db,$xmlFile,$interactive)
    End
    {
        $sql = "exec dbo.ArchiveRequestFile '"+$xmlFile+"'"

        $conn = "server="+$svr+";database="+$db+";Integrated Security=SSPI"
        $sqlConnection = new-object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = $conn
        $sqlConnection.Open()
        $sqlCommand = new-object System.Data.SqlClient.SqlCommand
        $sqlCommand.CommandTimeout = 120
        $sqlCommand.Connection = $sqlConnection
        $sqlCommand.CommandText= $sql
        $text = $sqlCommand.CommandText
        if($interactive -eq $true) {Write-Progress -Activity "Executing SQL" -Status "Ejecuting SQL => $text..."}
        if($interactive -eq $true) {Write-Host "Executing SQL => "$text"..."}
        $result = $sqlCommand.ExecuteNonQuery()
        $sqlConnection.Close() 
        if($Err){throw $Err}
    }
 }
#----------------------------------------------------------------------------------------------------------
 Function GetFIMObjects
 {
    Param($filter)
    End
    {
       $exportObjects = export-fimconfig -uri "http://localhost:5725/resourcemanagementservice" `
                                         -messagesize 300000 `
                                         –onlyBaseResources `
                                         -customconfig ("$filter") `
                                         -ErrorVariable Err `
                                         -ErrorAction SilentlyContinue 
       if($Err){throw $Err}
       return $exportObjects                                 
    }
 }
#----------------------------------------------------------------------------------------------------------
 "" | clip
 $interactive = $false
 $curFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileNameNoPath = $myInvocation.mycommand.Name -replace ".ps1",".xml"
 $fileName = "$dataFolder\" + $fileNameNoPath
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $now = Get-Date
 if($interactive -eq $true) {Write-Host "*** export-fimconfig starting: " $now " ***"}
 #$data = export-fimconfig -uri http://localhost:5725/resourcemanagementservice -customconfig ("/*[(ObjectID=/Request[(CreatedTime > op:subtract-dayTimeDuration-from-dateTime(fn:current-dateTime(), xs:dayTimeDuration('P2D'))) and (CreatedTime < op:subtract-dayTimeDuration-from-dateTime(fn:current-dateTime(), xs:dayTimeDuration('P1D')))]) and not(ObjectType='ma-data')]") -MessageSize 9999999 -AllLocales
 #$data = GetFIMObjects("/Request[(CreatedTime > op:subtract-dayTimeDuration-from-dateTime(fn:current-dateTime(), xs:dayTimeDuration('P2D'))) and (CreatedTime < op:subtract-dayTimeDuration-from-dateTime(fn:current-dateTime(), xs:dayTimeDuration('P1D')))]","/ma-data[not(ObjectID=/*)]")
 #$data = GetFIMObjects("/Request[(CreatedTime > op:subtract-dayTimeDuration-from-dateTime(fn:current-dateTime(), xs:dayTimeDuration('P2D'))) and (CreatedTime < op:subtract-dayTimeDuration-from-dateTime(fn:current-dateTime(), xs:dayTimeDuration('P1D')))]")
 
 $data = export-fimconfig -uri http://localhost:5725/resourcemanagementservice -customconfig (`
    # "/Request[(Target=/Person or Target=/DEEWR-vasco-DPToken or Target=/DEEWR-esg-invitation) `
    # and not(ParentRequest = /Request[Operation = 'SystemEvent']) `
    #"/Request[(Target=/Person or Target=/DEEWR-claim) `
    "/Request[not(Target=/ma-data or Target=/mv-data or Target=/ExpectedRuleEntry or Target=/DetectedRuleEntry or Target=/ActivityInformationConfiguration) `
     and not(Operation = 'SystemEvent') `
     and not(ParentRequest = /Request[Operation = 'SystemEvent']) `
     and (CreatedTime > op:subtract-dayTimeDuration-from-dateTime(fn:current-dateTime(), xs:dayTimeDuration('PT04H'))) `
     and (CreatedTime < op:subtract-dayTimeDuration-from-dateTime(fn:current-dateTime(), xs:dayTimeDuration('PT01H')))]") -MessageSize 300000 -AllLocales
    #,"/ManagementPolicyRule[ObjectID=/Request[not(Target=/ma-data or Target=/mv-data or Target=/ExpectedRuleEntry or Target=/DetectedRuleEntry or Target=/ActivityInformationConfiguration)`
    # and (CreatedTime > op:subtract-dayTimeDuration-from-dateTime(fn:current-dateTime(), xs:dayTimeDuration('P7D')))`
    # and (CreatedTime < op:subtract-dayTimeDuration-from-dateTime(fn:current-dateTime(), xs:dayTimeDuration('P0D')))]/ManagementPolicy]")`
    #  -MessageSize 300000 -AllLocales
 if($data -eq $null) {throw "The are no objects with this object type configured on your FIM server"} 
 $now = Get-Date
 if($interactive -eq $true) {Write-Host "*** export-fimconfig complete: " $data.Count " objects from FIM. Time: " $now " ***"}
 $now = Get-Date
 $data | convertfrom-fimresource -file $fileName
 $now = Get-Date
 if($interactive -eq $true) {Write-Host "*** convertfrom-fimresource complete. Time: "$now " ***"}
 [xml]$xmlDoc = get-content $fileName
 $now = Get-Date
 if($interactive -eq $true) {Write-Host "*** get-content complete. Time: " $now " ***"}

#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Affix XML data:
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 foreach($curNode In $xmlDoc.selectNodes("//ResourceManagementAttribute[AttributeName='RequestParameter']"))
 {
    foreach($stringNode In $curNode.Values.ChildNodes)
    {
        #[xml]$xmlxoml = [string]$curNode.Values.FirstChild.InnerText
        [xml]$xmlxoml = [string]$stringNode.InnerText
        #[xml]$xmlxoml = new-object System.Xml.DomDocument
        #$xmlxoml.async = false
        #$xmlxoml.LoadXml($curNode.Values.string[1])
        
        $xmlXoml.RequestParameter |
        foreach{
           [xml.xmlElement]$requestNode = $_
           $root = $xmlDoc.CreateElement("RequestParameter")
           $newElem = $xmlDoc.CreateElement("type")
           $newElem.set_InnerText($_.type) | out-null
           $root.AppendChild($newElem) | out-null
           switch($_.type)
           {
                "SystemEventRequestParameter"
                {
                   $szlist = "Target|Calculated|WorkflowDefinition.Value"
                }
                "DeleteRequestParameter"
                {
                   $szlist = "Target|Calculated|Operation"
                }
                "CreateRequestParameter"
                {
                   $szlist = "Target|Calculated|PropertyName|Value|Operation"
                }
                "UpdateRequestParameter"
                {
                   $szlist = "Target|Calculated|PropertyName|Value|Operation"
                }
                default
                {
                   $szlist = "TODO"
                }
           }
           foreach($item In $szlist.Split("|"))
           {
              $newElem = $xmlDoc.CreateElement($item)
              #$newElem.set_InnerText($requestNode.$item) | out-null
              $newElem.set_InnerText($requestNode.SelectSingleNode($item).InnerText) | out-null
              $root.AppendChild($newElem) | out-null
           }
           $curNode.AppendChild($root) | out-null
       }
    }
 }  
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 $xmlDoc.Results.SetAttribute("Filter", "WorkflowDefinition")
 $xmlDoc.Results.SetAttribute("Objects", "Workflows")
 $xmlDoc.save($fileName)

 if(1 -eq 2) {
#Append stylesheet reference and save archive xml
     $archiveFolder = "D:\Logs\FIMService\archive"
     [string]$datePart = Get-Date
     $archiveFileName = "$archiveFolder\RequestHistory.$datePart.xml"
     #[xml]$xmlArchive = [string]$stringNode.InnerText
     [xml]$xmlArchive = new-object Xml
     $xmlArchive.LoadXml($xmlDoc.OuterXml)
     $xmlpi = $xmlArchive.CreateProcessingInstruction("xml-stylesheet", "type=""text/xsl"" href=""./DEEWR.Requests.Today.xslt""")
     $newNode = $xmlArchive.AppendChild($xmlpi)
     # move the PI node to the top
     $docRoot = $xmlArchive.RemoveChild($xmlArchive.documentElement)
     $xmlArchive.AppendChild($docRoot)
     $xmlArchive.save($archiveFileName)
 }
 

copy-item $fileName -destination "\\EDMGT053\SQL"
$archive = execute-ArchiveSP -svr "EDMGT053" -db "FIMDEEWRArchive" -xmlFile "D:\SQL\DEEWR.Requests.Today.xml" -interactive $interactive
 
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 trap 
 { 
    $_.Exception.Message | clip
    Exit 1
 }
#---------------------------------------------------------------------------------------------------------------------------------------------------------
