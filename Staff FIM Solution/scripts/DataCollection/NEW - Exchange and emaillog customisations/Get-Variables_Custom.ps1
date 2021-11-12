$ParameterDefinition_Custom = [ordered]@{
    "Custom_ExchangeProvisioningLogFolder"=@{"Type"="string";"Prompt"="Enter the folder for the Exchange Provisioning log files (i.e. ProvisionMBs*.log and UpdateContacts*.log)";"Default"="D:\Logs\Exchange"}
	"Custom_EmailLogPath"=@{"Type"="string";"Prompt"="Enter the full path to the IdentityBroker emaillog.txt log file";"Default"="C:\Program Files\UNIFY Solutions\Identity Broker\Services\Logs-emaillog.txt"}
}