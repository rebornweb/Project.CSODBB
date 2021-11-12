@echo off
cls
@echo Step #1:
@echo Generating AVPInput.xml from import.txt ...
ExtractCAPSEntitlements.exe "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData\CAPS\import.txt" "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData\CAPS\AVPInput.xml"
@echo AVPInput.xml generated OK!
@echo Now you need to transform this to capsData.ldif (step #2)
pause