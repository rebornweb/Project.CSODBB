$scriptFolder = "E:\Scripts\Entitlements"
read-host -assecurestring "Enter CSODBB service account password" | convertfrom-securestring | out-file "$scriptFolder\authToken.txt"
