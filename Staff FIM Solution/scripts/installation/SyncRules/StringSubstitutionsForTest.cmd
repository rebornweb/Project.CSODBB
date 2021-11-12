@echo off
@cls
set runpath="E:\Scripts\installation\SyncRules"
set target="E:\Scripts\installation\SyncRules\DBBCSO - Manage Current Students as AD Contacts.xml"
E:
CD %runpath% 

@echo Replacing strings in file: %target% in folder: %runpath% 
@echo
cscript replace.vbs %target% "UNIFYFIM&lt;" "DBB&lt;"
cscript replace.vbs %target% ">UNIFYFIM<" ">DBB<"
cscript replace.vbs %target% "F:\LOGS" "E:\LOGS"
cscript replace.vbs %target% "localhost:59990" "d-occcp-as001:59990"
cscript replace.vbs %target% "DC=unifyfim,DC=unifytest,DC=local" "DC=dbb,DC=local"

set target="E:\Scripts\installation\SyncRules\cso-People Student attributes are imported from ADLDS.xml"
@echo Replacing strings in file: %target% in folder: %runpath% 
@echo
cscript replace.vbs %target% "UNIFYFIM&lt;" "DBB&lt;"
cscript replace.vbs %target% ">UNIFYFIM<" ">DBB<"
cscript replace.vbs %target% "F:\LOGS" "E:\LOGS"
cscript replace.vbs %target% "localhost:59990" "d-occcp-as001:59990"
cscript replace.vbs %target% "DC=unifyfim,DC=unifytest,DC=local" "DC=dbb,DC=local"

set target="E:\Scripts\installation\SyncRules\DBBCSO - Manage students as SAS records.xml"
@echo Replacing strings in file: %target% in folder: %runpath% 
@echo
cscript replace.vbs %target% "UNIFYFIM&lt;" "DBB&lt;"
cscript replace.vbs %target% ">UNIFYFIM<" ">DBB<"
cscript replace.vbs %target% "F:\LOGS" "E:\LOGS"
cscript replace.vbs %target% "localhost:59990" "d-occcp-as001:59990"
cscript replace.vbs %target% "DC=unifyfim,DC=unifytest,DC=local" "DC=dbb,DC=local"

pause



