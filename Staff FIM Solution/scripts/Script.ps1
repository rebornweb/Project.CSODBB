Function GetServiceData(
    [string]$opName="FimGetEmployeeNidsByDttm",
    [string]$sTime="",
    [string]$rootURI="https://prod.phris.org.au/PSIGW/PeopleSoftServiceListeningConnector", #/HRPRD #https://int.phris.org.au/PSIGW/PeopleSoftServiceListeningConnector
    [string]$sFilterColumn="",
    [string]$sFilterValue="",
    [string]$username = "CEOFIMSVC",
    [string]$password = "CEOPhris1!" #"Shastri98!" #"CEOPhris1!" #???? "VGgo263i+tt+m7YVY1duaQ=="
)
{

    cd "D:\Install\PowerShell"
    cls
    $usFilename = "usAll.xml";
    if ($opName.EndsWith("ByDttm")) {
        $usFilename = "us.xml";
    }
    $usTemplate = Get-Content $usFilename;
    #$usTemplate
    $usMessage = [string]::Format($usTemplate, $username, $password, $sTime);

    $uri2 = "$rootURI/FimService.1.wsdl"
    [xml]$wsdl = Invoke-WebRequest -Uri $uri2 -Method Post -ContentType "text/xml"

    $operation = $wsdl.definitions.portType.operation | Where-Object {$_.name -eq $opName}
    $opCollection = $operation.output.name.Split(".")[0]

    $uri3 = "$rootURI/$($operation.output.name).xsd"
    $wsdl = Invoke-WebRequest -Uri $uri3 -Method Post -ContentType "text/xml"
    $opCollectionItem = $wsdl.schema.include.schemaLocation.Split(".")[0]

    $uri4 = "$rootURI/$($wsdl.schema.include.schemaLocation)"
    $wsdl = Invoke-WebRequest -Uri $uri4 -Method Post -ContentType "text/xml"
    $opTableName = $wsdl.schema.complexType[0].sequence.element.name

    $uri = "$($rootURI)?MessageName=$opName.v1"
    $themResponse = Invoke-WebRequest -Uri $uri -Method Post -ContentType "text/xml" -Body $usMessage
    [xml]$xmlResponse = $themResponse.Content
    if ($xmlResponse.Envelope.Body.$opCollection.childNodes.Count -gt 0) {
        "Rows found: $($xmlResponse.Envelope.Body.$opCollection.childNodes.Count)"
        if ($sFilterColumn -eq "") {
            $xmlResponse.Envelope.Body.$opCollection.$opCollectionItem.$opTableName | Out-GridView
        } else {
            $xmlResponse.Envelope.Body.$opCollection.$opCollectionItem.$opTableName | Where-Object {$_.$sFilterColumn -eq $sFilterValue} | Out-GridView
        #$xmlResponse.Envelope.Body.$opCollection.$opCollectionItem.$opTableName | Where-Object {$_."EMPLID" -eq "24211100"} | Out-GridView
        }
    } else {
        "No data: $($xmlResponse.Envelope.Body.InnerXml)"
    }
}


$Time = [DateTime]::UtcNow.ToLocalTime()
#$sTime = $Time.AddYears(-3).ToString("yyyy-MM-ddTHH:mm:ss.ffffffK");
$sTime = $Time.ToString("yyyy-MM-ddTHH:mm:ss.ffffffK");
$sTime = "2014-09-03T09:53:03.000000+10:00"
$sTime = "2015-10-20T14:06:11.000000+10:00"
$sTime = "2015-10-20T14:06:11.000000+10:00"
$sTime = "2016-01-11T08:00:00.000000+10:00"
$sTime = "2016-01-21T08:00:00.000000+10:00"

#EMPLID: 32081100, EMAILTYPE: BUS, EMAILID: Timothy.Kitchen@dbb.org.au, CLASS: R

GetServiceData -sTime $sTime -opName "FimGetEmails" -sFilterColumn EMPLID -sFilterValue 32081100
GetServiceData -sTime $sTime -opName "FimGetEmails" -sFilterColumn EMAILID -sFilterValue Timothy.Kitchen@dbb.org.au
GetServiceData -sTime $sTime -opName "FimGetEmployees" -sFilterColumn EMPLID -sFilterValue 75832100
GetServiceData -sTime $sTime -opName "FimGetEmployeesByDttm"
GetServiceData -sTime $sTime -opName "FimGetGrades"
GetServiceData -sTime $sTime -opName "FimGetJobs"
GetServiceData -sTime $sTime -opName "FimGetJobsByDttm" -sFilterColumn EMPLID -sFilterValue 24211100
GetServiceData -sTime $sTime -opName "FimGetDepts"
GetServiceData -sTime $sTime -opName "FimGetEmployeeNids"
GetServiceData -sTime $sTime -opName "FimGetEmployeeNidsByDttm"

