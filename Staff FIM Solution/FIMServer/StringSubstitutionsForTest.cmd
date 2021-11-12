@echo off
@cls
set runpath="E:\Scripts\Output"
set target="E:\Scripts\Output\pilot_policy.xml"
E:
CD %runpath% 

@echo Replacing strings in file: %target% in folder: %runpath% 
@echo
cscript replace.vbs %target% "UNIFYFIM&lt;" "DBB&lt;"
cscript replace.vbs %target% ">UNIFYFIM<" ">DBB<"
cscript replace.vbs %target% "F:\LOGS" "E:\LOGS"
cscript replace.vbs %target% "localhost:59990" "d-occcp-as001:59990"
cscript replace.vbs %target% "DC=unifyfim,DC=unifytest,DC=local" "DC=dbb,DC=local"
pause



