#& "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData\NASS MA\GetNASSXml.ps1" -svr "localhost" -db "BOPS2DB" -xmlFile "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData\NASS MA\nassData.xml"

PARAM([string]$svr = "occcp-db003",
    [string]$db = "BOPS2DB",
    [string]$xmlFile = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData\NASS\nassData.xml",
    [bool]$dbg = $False)

$sql = "exec dbo.spNASSData"
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
[System.Xml.XmlReader]$result = $sqlCommand.ExecuteXmlReader()
$result.MoveToContent()
[xml]$xml = $result.ReadOuterXml()
$sqlConnection.Close() 
if($Err){throw $Err}
$xml.Save($xmlFile)

