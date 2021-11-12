cls
$bustedData = get-content "E:\install\Scripts\Data Collection Script\IdBLogs\CSODBB-PROD_IdentityBroker_Logs2.json" #| ConvertFrom-Json
$bustedData | ConvertFrom-Json -Verbose
$bustedData2 = get-content "E:\install\Scripts\Data Collection Script\IdBLogs\CSODBB-PROD_FIMSync_Runs.json" #| ConvertFrom-Json
$bustedData2 | ConvertFrom-Json -Verbose
$bustedData1 = '{    "Type":  "Information",    "Object":  "Change detection engine",    "Impact":  "Normal",    "Time":  "06:47:55",    "Date":  "20170809",    "System":  "UNIFY
 5Identity Broker",    "HCRecordType":  "IdentityBroker_Log",    "_time":  "2017-08-09T06:55:22",    "Detail":  "Change detection engine import changes started.\r\nChange detection engine import changes for connector PeopleSoft Employee Connector started."}'

$bustedData1 | ConvertFrom-Json



read-host -assecurestring | convertfrom-securestring | out-file "E:\install\Scripts\Data Collection Script\Creds\AzureKey.txt"
"quEPUo5RDntyzVwq2Aq2qPGyGMxHL2njnBc+u7GDLGBOmEOaDyBUEe6JfFwy51lT8daaeA9LpDILZOqeLH8OPg==" | convertfrom-securestring | out-file "E:\install\Scripts\Data Collection Script\Creds\AzureKey.txt"
"?sv=2015-07-08&sr=s&si=gen21062017&sig=lzS4vatFpDOzAj019aAFcz%2FSMSy8mNuvSs62zmN11Ys%3D"


.\Run-HealthCheck.ps1 -FIMSync -FIMService -IdentityBroker -EventBroker -Infrastructure -WindowsEventLogs -RunType Delta
