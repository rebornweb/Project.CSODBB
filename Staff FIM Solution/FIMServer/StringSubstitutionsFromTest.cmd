@echo off
@cls
set runpath="E:\Scripts\Output"
set target="E:\Scripts\Output\pilot_policy.xml"
E:
CD %runpath% 

@echo Replacing strings in file: %target% in folder: %runpath% 
@echo
cscript replace.vbs %target% "DBB&lt;" "UNIFYFIM&lt;"
cscript replace.vbs %target% ">DBB<" ">UNIFYFIM<"
cscript replace.vbs %target% "E:\LOGS" "F:\LOGS"
cscript replace.vbs %target% "d-occcp-as001:59990" "localhost:59990"
cscript replace.vbs %target% "DC=dbb,DC=local" "DC=unifyfim,DC=unifytest,DC=local"
pause
