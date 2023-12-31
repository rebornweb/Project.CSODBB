        #$conn = "Server=$server;Database=$db;Trusted_connection=true"
        #$conn = "Data source=" + $server + ";Integrated Security=true;Initial Catalog=" + $db
 Function GetFIMObjects
 {
    param($server,$db,$sql)
    {
        $conn = "provider=sqloledb;server=EDMGT053;database=FIMDEEWRArchive;Integrated Security=SSPI"
        $sqlConnection = new-object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = $conn
        $sqlConnection.Open()
        $sqlCommand = new-object System.Data.SqlClient.SqlCommand
        $sqlCommand.CommandTimeout = 120
        $sqlCommand.Connection = $sqlConnection
        $sqlCommand.CommandText= $sql
        $text = $sql.Substring(0, 50)
        Write-Progress -Activity "Executing SQL" -Status "Ejecuting SQL => $text..."
        Write-Host "Ejecuting SQL => $text..."
        $result = $sqlCommand.ExecuteNonQuery()
        $sqlConnection.Close() 
    }
}

#$connectionString = "Data source=EDMGT053;Integrated Security=true;Initial Catalog=FIMDEEWRArchive;"
$connectionString = "provider=sqloledb;server=EDMGT053;database=FIMDEEWRArchive;Integrated Security=SSPI"
$xmlFile = "\\EDMGT051\D$\Scripts\FIM.ScriptBox\FIM Object Visualizer\Reports\Data\DEEWR.Requests.Today.xml"
$xsdFile = "D:\Scripts\FIM.ScriptBox\FIM Object Visualizer\Reports\DEEWR.Requests.Today.New.xsd"
$errorLog = "D:\Logs\FIMService\archive\Archive.Errors.log"
#$bulkCopy = new-object ("SQLXMLBulkLoad.SQLXMLBulkload.4.0") $connectionString
#$bulkCopy.SchemaGen = $true
#$bulkCopy.Bulkload = $true
#$bulkCopy.ErrorLogFile = $errorLog
#$output = $bulkCopy.Execute($xsdFile, $xmlFile)


$sqlxml = new-object -comobject "SQLXMLBulkLoad.SQLXMLBulkLoad"
$sqlxml.ConnectionString = $connectionString
$sqlxml.SchemaGen = $true
$sqlxml.Bulkload = $true
#$sqlxml.ErrorLogFile = $errorLog
###$sqlxml.Execute($xsdFile,$xmlFile)


#Exec dbo.ArchiveRequestFile 'D:\Scripts\DEEWR.Requests.Today.xml'

$sqlCommand = "exec dbo.ArchiveRequestFile '$xmlFile'"
#sqlcmd -S "EDMGT053" -E -Q $sqlCommand

execute-Sql ("EDMGT053","FIMDEEWRArchive",$sqlCommand)