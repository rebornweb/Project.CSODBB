#----------------------------------------------------------------------------------------------------------
 function execute-ArchiveSP
 {
    Param($svr,$db,$xmlFile)
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
        Write-Progress -Activity "Executing SQL" -Status "Ejecuting SQL => $text..."
        Write-Host "Executing SQL => "$text"..."
        $result = $sqlCommand.ExecuteNonQuery()
        $sqlConnection.Close() 
        if($Err){throw $Err}
    }
 }
#----------------------------------------------------------------------------------------------------------
 "" | clip
 #copy-item "D:\Logs\FIMService\archive\RequestHistory.2011Sep16.103419.xml" -destination "\\EDMGT053\SQL"
 #execute-ArchiveSP -svr "EDMGT053" -db "FIMDEEWRArchive" -xmlFile "D:\Scripts\DEEWR.Requests.Today.xml"
 execute-ArchiveSP -svr "EDMGT053" -db "FIMDEEWRArchive" -xmlFile "D:\SQL\RequestHistory.2011Sep16.103419.xml"