@echo off
@cls
set runpath="D:\scripts\installation\SyncRules"
set target="D:\scripts\installation\SyncRules\DBBCSO - Manage Current Students as AD Contacts.xml"
E:
CD %runpath% 

@echo Replacing strings in file: %target% in folder: %runpath% 
@echo
cscript replace.vbs %target% "UNIFYFIM&lt;" "DBB&lt;"
cscript replace.vbs %target% ">UNIFYFIM<" ">DBB<"
cscript replace.vbs %target% "F:\LOGS" "D:\LOGS"
cscript replace.vbs %target% "localhost:59990" "occcp-as034:59990"
cscript replace.vbs %target% "DC=unifyfim,DC=unifytest,DC=local" "DC=dbb,DC=local"

set target="D:\Scripts\installation\SyncRules\cso-People Student attributes are imported from ADLDS.xml"
@echo Replacing strings in file: %target% in folder: %runpath% 
@echo
cscript replace.vbs %target% "UNIFYFIM&lt;" "DBB&lt;"
cscript replace.vbs %target% ">UNIFYFIM<" ">DBB<"
cscript replace.vbs %target% "F:\LOGS" "D:\LOGS"
cscript replace.vbs %target% "localhost:59990" "occcp-as034:59990"
cscript replace.vbs %target% "DC=unifyfim,DC=unifytest,DC=local" "DC=dbb,DC=local"

set target="D:\Scripts\installation\SyncRules\DBBCSO - Manage students as SAS records.xml"
@echo Replacing strings in file: %target% in folder: %runpath% 
@echo
cscript replace.vbs %target% "UNIFYFIM&lt;" "DBB&lt;"
cscript replace.vbs %target% ">UNIFYFIM<" ">DBB<"
cscript replace.vbs %target% "F:\LOGS" "D:\LOGS"
cscript replace.vbs %target% "localhost:59990" "occcp-as034:59990"
cscript replace.vbs %target% "DC=unifyfim,DC=unifytest,DC=local" "DC=dbb,DC=local"

pause



