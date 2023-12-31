#Copyright (c) 2012, Unify Solutions Pty Ltd
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
#IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
#OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Duplicate-Object.ps1
#   Written by Carol Wapshere
#
# Use to duplicate an object in the Portal. The new object will be called "Copy Of " followed by the name of the source object.
#
# USAGE: .\Duplicate-Object.ps1 -ObjectType <ObjectType> -DisplayName "<Source Object Display Name>"
#
# Notes:
#  - Uses the FIMPowerShell Function library from http://technet.microsoft.com/en-us/library/ff720152(v=ws.10).aspx
#  - If using FIM R1 powershell date attributes can't be copied so add them to the SkipAttribs array.


PARAM($ObjectType,$DisplayName)

. E:\scripts\FIMPowerShell.ps1

$SkipAttribs = @("ObjectType","ObjectID","CreatedTime","Creator")


[string]$filter = "/" + $ObjectType + "[DisplayName = '" + $DisplayName + "']"
$obj = export-fimconfig -customConfig $filter -OnlyBaseResources
$hashObj = ConvertResourceToHashtable $obj

$importObj = CreateImportObject -ObjectType $ObjectType
foreach ($attrib in $hashObj.Keys)
{
  if ($attrib -eq "DisplayName")
  {
    [string]$NewDisplayName = "Copy of " + $DisplayName
    SetSingleValue -ImportObject $importObj -AttributeName "DisplayName" -NewAttributeValue $NewDisplayName
  }
  elseif ($SkipAttribs -contains $attrib) {}
  elseif ($hashobj.$attrib.Count -gt 1)
  {
    foreach ($val in $hashobj.$attrib)
    {
      AddMultiValue -ImportObject $importObj -AttributeName $attrib -NewAttributeValue $val
    }
  }
  else
  {
    SetSingleValue -ImportObject $importObj -AttributeName $attrib -NewAttributeValue $hashobj.$attrib
  }
}

Import-FIMConfig -ImportObject $importObj

