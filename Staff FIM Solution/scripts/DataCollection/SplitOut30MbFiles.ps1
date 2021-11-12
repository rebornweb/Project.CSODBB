# Script to deal with failure of OMS upload to handle files larger than 30 Mb
# Refer: https://blogs.technet.microsoft.com/germanageability/2016/10/12/testing-log-analytics-http-data-collector-api-limits-with-powershell/

cls
[long]$fileLimit = 15000000 # This is exactly half of the 30Mb limit ... not sure why but seems to work well (possibly because uncompressed)
$workingDir = "D:\Scripts\DataCollection\Data\22-01-2018-17-21"
$filesToSplitOut = Get-ChildItem $workingDir -Filter "*.json" | Where-Object {$_.Length -gt $fileLimit}
$filesToSplitOut
foreach($jasonFile in $filesToSplitOut) {
    #$jasonFile = $filesToSplitOut[0]
    $jsonData = Get-Content ([System.IO.Path]::Combine($workingDir, $jasonFile)) | ConvertFrom-Json
    # calculate the number of parts to break down the data until it is within the max file size limit
    [int]$divisor = [int]([long]::Parse($jasonFile.Length) / $fileLimit) + 1
    [long]$chunkSize = $jsonData.Length / $divisor
    [long]$ix = 0
    [long]$ixAll = 0
    [long]$ixChunks = 0
    [System.Collections.ArrayList]$al = [System.Collections.ArrayList]::new()
    foreach($jsonRecord in $jsonData) {
        #$jsonRecord = $jsonData[0]
        $al.Add($jsonRecord) | Out-Null
        $ix ++;
        $ixAll ++;
        if($ix -ge $chunkSize -or $ixAll -eq ($jsonData.Length)) {
            $ixChunks ++
            $ix = 0
            [string]$filePathToWrite = ([System.IO.Path]::Combine($workingDir, "$jasonFile.$($ixChunks.ToString("0000"))"))
            #Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType
            #$al.Length
            Add-ContentToFile -FilePath $filePathToWrite -ContentToAdd ($al | ConvertTo-Json)
            $al = [System.Collections.ArrayList]::new()
        }
    }
}

