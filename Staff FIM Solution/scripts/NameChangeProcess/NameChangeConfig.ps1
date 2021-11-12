$RunningDir = "C:\Users\anthony.soquin.tst\Desktop\Script\"

# Log Setup
$LogFolder = "C:\Users\anthony.soquin.tst\Desktop\Script\Logs"
$LogFileTemplate = "NameChangeScript-{0}.log"
$Debug = $true

#Encryption 
$Key = (1..16)

#Exchang eParameters
$ExchangeServerAddress = "D-OCCCP-EX002.dbb.local"
$ExchangeUsername ="anthony.soquin.tst"
$ExchangePassword = get-content "" | convertto-securestring -key $Key #SecureString type


# AD Parameters
$ADUsername = "anthony.soquin.tst" 
$ADPassword = get-content "" | convertto-securestring -key $Key #SecureString type
$RootOU = "DC=dbb,DC=local"
#$DC = "10.19.229.12" # value list managed with comma
$DC = "D-OCCCP-DC201"
$FQDomain = "dbb.local"
$ObjectToManage = "user"


# AD Creation Account Parameters
$UPNSuffix = "dbb.local"
$EmailSuffix = "dbb.org.au"

#User Computer Parameters - Admin Account allowed to connect to the User's computer
$ComputerUsername = ""
$ComputerPassword = get-content "" | convertto-securestring -key $Key #SecureString type
$DefaultUserDirectory = "C:\Users\"