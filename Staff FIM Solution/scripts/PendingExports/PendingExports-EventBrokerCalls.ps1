#& "D:\Scripts\PendingExports\RunCSExport.ps1" -SourceMA PHRIS
#& "D:\Scripts\PendingExports\RunCSExport.ps1" -SourceMA Staff

& "D:\Scripts\PendingExports\PendingExports-GenerateData.ps1" -SourceMA "Staff" -DropFile "Staff.Export.xml"

& "D:\Scripts\PendingExports\PendingExports-GenerateData.ps1" -SourceMA "PHRIS" -DropFile "PHRIS.Export.xml"

