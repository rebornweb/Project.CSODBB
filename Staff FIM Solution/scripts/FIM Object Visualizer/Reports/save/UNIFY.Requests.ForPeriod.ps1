Param(
    [string]$FIMService = "localhost", 
    [string]$FIMDbServer = "EDMGT053", 
    [string]$FIMDbServerInstance = "FIMSQL",
    [string]$fromPeriod = "PT03H",
    [string]$toPeriod = "PT01H",
# Debug variable enables Write-Host and Write-Progress commands
# *** NOTE: $debug must be $False in order to run this from Event Broker!!! ***
    [boolean]$debug = $False,
# Allow the writing of a hard-copy of the XML file (with inserted XSL reference) to be optional
    [boolean]$writeToArchiveFolder = $true,
    [string]$archiveFolder = "D:\Logs\FIMService\archive",
# specify local working file path for SQL stored procedure usage
    [string]$FIMDbServerLocalFolder = "D:\SQL",
    [string]$databaseName = "FIMDEEWRArchive",
    [string]$FIMDbServerShareName = "SQL"
)
#----------------------------------------------------------------------------------------------------------
#[string]$FIMService = "rubbish"
#[string]$FIMDbServer = "EDMGT053"
#[string]$FIMDbServerInstance = "FIMSQL"
#----------------------------------------------------------------------------------------------------------
 Function ExecuteArchiveSP
 {
    Param($svr,$db,$xmlFile,$dbg)
    End
    {
        $sql = "exec dbo.ArchiveRequestFile '$xmlFile'"
        $conn = "server=$svr;database=$db;Integrated Security=SSPI"
        $sqlConnection = new-object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = $conn
        if($dbg -eq $true) {Write-Host "Opening SQL Connection => $conn ..."}
        $sqlConnection.Open()
        $sqlCommand = new-object System.Data.SqlClient.SqlCommand
        $sqlCommand.CommandTimeout = 120
        $sqlCommand.Connection = $sqlConnection
        $sqlCommand.CommandText= $sql
        $text = $sqlCommand.CommandText
        if($true -eq $true) {Write-Progress -Activity "Executing SQL" -Status "Ejecuting SQL => $text..."}
        if($dbg -eq $true) {Write-Host "Executing SQL => "$text"..."}
        $result = $sqlCommand.ExecuteNonQuery()
        $sqlConnection.Close() 
        if($Err){throw $Err}
    }
 }
#----------------------------------------------------------------------------------------------------------
# When exporting request objects we wish to observe the following:
# 1. exclude FIM system object requests (ma-data, etc.)
# 2. exclude set-transition generated events (SystemEvent)
# 3. exclude children of set-transition generated events
 Function GetRequestsForArchive
 {
    Param($fimService,$from,$to,$debug)
    End
    {
       [String]$customConfig = "/Request[not(Target=/ma-data) `
         and not(Target=/mv-data) `
         and not(Target=/ExpectedRuleEntry) `
         and not(Target=/DetectedRuleEntry) `
         and not(Target=/ActivityInformationConfiguration) `
         and not(Operation = 'SystemEvent') `
         and not(ParentRequest = /Request[Operation = 'SystemEvent']) `
         and (CreatedTime > op:subtract-dayTimeDuration-from-dateTime(fn:current-dateTime(), xs:dayTimeDuration('$from'))) `
         and (CreatedTime < op:subtract-dayTimeDuration-from-dateTime(fn:current-dateTime(), xs:dayTimeDuration('$to')))]"
       $uri = "http://" + $fimService + ":5725/resourcemanagementservice"
       if($debug -eq $true) {Write-Host "*** Querying FIM service: " $uri " - " $now " ***"}
       if($debug -eq $true) {Write-Host "*** Executing FIM query: " $customConfig " - " $now " ***"}
       $exportObjects = export-fimconfig -uri $uri `
                                         -messagesize 300000 `
                                         –AllLocales `
                                         -customconfig ($customConfig,"/Person[DisplayName='Built-in Synchronization Account']","/Resource[DisplayName='Forefront Identity Manager Service Account']") `
                                         -ErrorVariable Err `
                                         -ErrorAction SilentlyContinue 
#                                         –onlyBaseResources `
       if($Err){throw $Err}
       return $exportObjects                                 
    }
 }
#----------------------------------------------------------------------------------------------------------
 "" | clip

# 1. Set up/derive additional variables and libraries
 $curFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
 $dataFolder = "$curFolder\Data"
 $fileNameNoPath = $myInvocation.mycommand.Name -replace ".ps1",".xml"
 $fileName = "$dataFolder\$fileNameNoPath"
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 $now = Get-Date

# 2. Query FIM for requests created in the hour leading up to the last hour (this mitigates against the potential loss of requests being created at the time of the report)
 if($debug -eq $true) {Write-Host "*** export-fimconfig starting: " $now " ***"}
 $data = GetRequestsForArchive -fimService $FIMService -from $fromPeriod -to $toPeriod -debug $debug
 if($debug -eq $true) {Write-Host "*** export-fimconfig completed: " $now " ***"}
 if($data -eq $null) {
    if($debug -eq $true) {Write-Host "The are no objects with this object type configured on your FIM server " $FIMDbServer}
 }
 else
 {
     $now = Get-Date
     if($debug -eq $true) {Write-Host "*** export-fimconfig complete: " $data.count.ToString() " objects from FIM. Time: " $now " ***"}
     $now = Get-Date

# 3. Save XML to file
     if($debug -eq $true) {Write-Host "*** exporting to xml file: " $fileName " - " $now " ***"}
     $data | ConvertFrom-FIMResource -file $fileName
     if($debug -eq $true) {Write-Host "*** exported to xml file: " $fileName " - " $now " ***"}
# 4. Copy XML file to archive database server
     copy-item $fileName -destination "\\$FIMDbServer\$FIMDbServerShareName"
     if($debug -eq $true) {Write-Host "*** xml file colied to \\$FIMDbServer\$FIMDbServerShareName"}
# 5. Import XML file to archive database server
     if($debug -eq $true) {Write-Host "*** archiving xml file from $FIMDbServerLocalFolder\$fileNameNoPath on sql server $FIMDbServerInstance"}
     $archive = ExecuteArchiveSP -svr $FIMDbServerInstance -db $databaseName -xmlFile "$FIMDbServerLocalFolder\$fileNameNoPath" -dbg $debug
     if($debug -eq $true) {Write-Host "*** xml archived"}
     $now = Get-Date
     if($debug -eq $true) {Write-Host "*** convertfrom-fimresource complete. Time: "$now " ***"}
# 6. (Optional) Save XML file to archive folder with extracted XML and referenced XSLT
     if($writeToArchiveFolder) {
         # Re-load XML from file (only do this for the current data)
         [xml]$xmlDoc = get-content $fileName
         if($debug -eq $true) {Write-Host "*** xml reloaded"}
         $now = Get-Date
         if($debug -eq $true) {Write-Host "*** get-content complete. Time: " $now " ***"}

#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Affix XML data:
#---------------------------------------------------------------------------------------------------------------------------------------------------------
         foreach($curNode In $xmlDoc.selectNodes("//ResourceManagementAttribute[AttributeName='RequestParameter']"))
         {
            foreach($stringNode In $curNode.Values.ChildNodes)
            {
                [xml]$xmlxoml = [string]$stringNode.InnerText
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
                      $newElem.set_InnerText($requestNode.SelectSingleNode($item).InnerText) | out-null
                      $root.AppendChild($newElem) | out-null
                   }
                   $curNode.AppendChild($root) | out-null
               }
            }
         }  
#---------------------------------------------------------------------------------------------------------------------------------------------------------
         if($debug -eq $true) {Write-Host "*** XML appended: " $now " ***"}
         $xmlDoc.Results.SetAttribute("Filter", "WorkflowDefinition")
         $xmlDoc.Results.SetAttribute("Objects", "Workflows")
         $xmlDoc.save($fileName)
         if($debug -eq $true) {Write-Host "*** XML saved: " $now " ***"}
         # Append stylesheet reference and save archive xml
         [string]$datePart = Get-Date -format "yyyyMMddTHHmmss"
         $archiveFileName = "$archiveFolder\RequestHistory.$datePart.xml"
         [xml]$xmlArchive = new-object Xml
         $xmlArchive.LoadXml($xmlDoc.OuterXml)
         if($debug -eq $true) {Write-Host "*** XML history $archiveFileName reloaded: " $now " ***"}
         $xmlpi = $xmlArchive.CreateProcessingInstruction("xml-stylesheet", "type=""text/xsl"" href=""./DEEWR.Requests.Today.xslt""")
         $newNode = $xmlArchive.AppendChild($xmlpi)
         # move the PI node to the top
         $docRoot = $xmlArchive.RemoveChild($xmlArchive.documentElement)
         $newerNode = $xmlArchive.AppendChild($docRoot)
         $xmlArchive.save($archiveFileName)
         if($debug -eq $true) {Write-Host "*** XML history $archiveFileName saved with PI: " $now " ***"}
     }
 }
 
#---------------------------------------------------------------------------------------------------------------------------------------------------------
 trap 
 { 
    $_.Exception.Message | clip
    Exit 1
 }
#---------------------------------------------------------------------------------------------------------------------------------------------------------
