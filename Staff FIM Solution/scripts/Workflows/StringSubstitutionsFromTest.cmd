@echo off
@cls
set runpath="E:\Scripts\Workflows"
E:
CD %runpath% 

@echo Replacing strings in file: %target% in folder: %runpath% 
@echo

set target="cso-Recalculate user roles from current entitlement context.txt"
cscript replace.vbs %target% "E:\LOGS" "F:\LOGS"

set target="cso-Recalculate user roles from deleted entitlement context.txt"
cscript replace.vbs %target% "E:\LOGS" "F:\LOGS"

set target="cso-Recalculate user roles from user context.txt"
cscript replace.vbs %target% "E:\LOGS" "F:\LOGS"

set target="cso-Set Role Housekeeping explicit collection 2.txt"
cscript replace.vbs %target% "E:\LOGS" "F:\LOGS"

set target="cso-Set Site Admin Housekeeping explicit collection.txt"
cscript replace.vbs %target% "E:\LOGS" "F:\LOGS"

pause



