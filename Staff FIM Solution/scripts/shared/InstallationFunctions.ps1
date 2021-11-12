$LookupObjects = @{}
$LookupUsers = @{}

Function LookupObject
{
    PARAM($ObjectType,$Name,$NoPrefix=$false)
    END
    {
        $Key = $ObjectType + "::" + $Name
        if ($LookupObjects.ContainsKey($Key)) {[string]$ObjectID = $LookupObjects.($Key)}
        else
        {
            if ($ObjectType -eq "AttributeTypeDescription" -or $ObjectType -eq "ObjectTypeDescription"){$filter = "/{0}[Name = '{1}']" -f $ObjectType,$Name}
            else {$filter = "/{0}[DisplayName = '{1}']" -f $ObjectType,$Name}
            $obj = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
            if ($obj)
            {
                if ($obj.Count -gt 1) {Throw "More than one object found matching $filter"}
                [string]$ObjectID = $obj.ResourceManagementObject.ObjectIdentifier
                $LookupObjects.Add($Key,$ObjectID)
            }
            else
            {
                if (-not $Uninstall) {Throw "Failed to find an object matching $filter"}
                $ObjectID = "none"
            }
        }
        if ($NoPrefix) {Return $ObjectID.Replace("urn:uuid:","")}
        else {Return $ObjectID}
    }
}

Function LookupUser
{
    PARAM($Attribute,$Value,$NoPrefix=$false)
    END
    {
      $Key = $Attribute + "::" + $Value
      if ($LookupUsers.ContainsKey($Key)) {[string]$ObjectID = $LookupUsers.($Key)}
      else 
      {
        $filter = "/Person[{0} = '{1}']" -f $Attribute,$Value
        $obj = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
        if ($obj)
        {
            if ($obj.Count -gt 1) {Throw "More than one object found matching $filter"}
            [string]$ObjectID = $obj.ResourceManagementObject.ObjectIdentifier
	    $LookupUsers.Add($Key,$ObjectID)
        }
        else
        {
            if (-not $Uninstall) {Throw "Failed to find an object matching $filter"}
            $ObjectID = "none"
        }
     }
     if ($NoPrefix) {Return $ObjectID.Replace("urn:uuid:","")}
     else {Return $ObjectID}
    }
}


Function AddObject
{
    PARAM($ObjectType,$Name,$HashAddValues,$HashUpdateValues)
    END
    {
        write-host "Adding $ObjectType $Name..."
        $ImportObject = CreateImportObject -ObjectType $ObjectType
        SetSingleValue $ImportObject "DisplayName" $Name
        foreach ($attr in $HashAddValues.Keys)
        {
            if ($HashAddValues.($attr) -is [system.array])
            {
                foreach ($value in $HashAddValues.($attr))
                {
                    AddMultiValue $ImportObject $attr $value
                }
            }
            else
            {
                SetSingleValue $ImportObject $attr $HashAddValues.($attr)
            }
        }
        foreach ($attr in $HashUpdateValues.Keys)
        {
            if ($HashUpdateValues.($attr) -is [system.array])
            {
                foreach ($value in $HashUpdateValues.($attr))
                {
                    AddMultiValue $ImportObject $attr $value
                }
            }
            else
            {
                SetSingleValue $ImportObject $attr $HashUpdateValues.($attr)
            }
        }
        $ImportObject.Changes
        $ImportObject | Import-FIMConfig
    }
}

Function UpdateObject
{
    PARAM($ObjectType,$Name,$HashUpdateValues,$FIMObject)
    END
    {
        write-host "Updating $ObjectType $Name..."
        $ImportObject = ModifyImportObject -ObjectType $ObjectType -TargetIdentifier $FIMObject.ResourceManagementObject.ObjectIdentifier
        foreach ($attr in $HashUpdateValues.Keys)
        {
            if ($HashUpdateValues.($attr) -is [system.array])
            {
                $NewValues = $HashUpdateValues.($attr)
                $CurrValues = ($FIMObject.ResourceManagementObject.ResourceManagementAttributes | where {$_.AttributeName -eq $attr}).Values

                if ($CurrValues) 
                {
                    foreach ($value in $CurrValues)
                    {
                        if ($NewValues -notcontains $value) {RemoveMultiValue $ImportObject $attr $value}
                    }
                }
                foreach ($value in $NewValues)
                {
                    if ($CurrValues -notcontains $value) {AddMultiValue $ImportObject $attr $value}
                }
            }
            else
            {
		        $CurrValue = ($FIMObject.ResourceManagementObject.ResourceManagementAttributes | where {$_.AttributeName -eq $attr}).Value
		        $newVal = $HashUpdateValues.($attr)
		        #if (($attr -eq "XOML") -or ($attr -eq "ConfigurationData") -or ($attr -eq "EmailBody") -or ($attr -eq "StringResources"))
                if ($newVal -like "*`r`n*" -and $newVal -like "*</*")
		        {
			        $newVal = $newVal.Replace("`r`n","`n")
		        }
                if ($CurrValue -ne $newVal) {SetSingleValue $ImportObject $attr $HashUpdateValues.($attr)}
            }
        }
        if ($ImportObject.Changes)
        {
            $ImportObject.Changes
            $ImportObject | Import-FIMConfig
        }
        else {write-host "--No changes"}
    }
}


Function ProcessObjects
{
    PARAM ($ObjectType,$HashObjects,$DeleteSchema=$false)
    END
    {
        foreach ($Name in $HashObjects.Keys)
        {
            if ($ObjectType -eq "BindingDescription") 
            {
                $AttrID = $HashObjects.($Name).Add.BoundAttributeType.Replace("urn:uuid:","")
                $ObjID = $HashObjects.($Name).Add.BoundObjectType.Replace("urn:uuid:","")
                $filter = "/{0}[BoundAttributeType='{1}' and BoundObjectType='{2}']" -f $ObjectType,$AttrID,$ObjID
            }
            elseif ($ObjectType -eq "AttributeTypeDescription") 
            {
                $filter = "/{0}[Name='{1}']" -f $ObjectType,$Name
            }
            elseif ($ObjectType -eq "csoDepartment") 
            {
                $filter = "/{0}[csoDeptID='{1}']" -f $ObjectType,$Name
            }
            else
            {
                $filter = "/{0}[DisplayName='{1}']" -f $ObjectType,$Name
            }
            $obj = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter

            if ($Uninstall)
            {
                if (($ObjectType -eq "ObjectTypeDescription" -or $ObjectType -eq "AttributeTypeDescription" -or $ObjectType -eq "BindingDescription") -and $DeleteSchema `
                    -or ($ObjectType -ne "ObjectTypeDescription" -and $ObjectType -ne "AttributeTypeDescription" -and $ObjectType -ne "BindingDescription"))
                {
                    if ($HashObjects.($Name).Uninstall)
                    {
                        if ($obj -and $HashObjects.($Name).Uninstall -eq "DeleteObject")
                        {
                            write-host "Deleting $ObjectType $Name..."
                            $ImportObject = DeleteObject -ObjectType $ObjectType -TargetIdentifier $obj.ResourceManagementObject.ObjectIdentifier
                            $ImportObject | Import-FIMConfig
                        }
                        elseif ($obj)
                        {
                            write-host "Updating $ObjectType $Name..."
                            UpdateObject -ObjectType $ObjectType -Name $Name -HashUpdateValues $HashObjects.($Name).Uninstall -FIMObject $obj
                        }
                        else
                        {
                             write-host "No uninstallation of $ObjectType $Name..."
                        }
                    }
                }
            }
            else
            {
                if (-not $obj)
                {
                    AddObject -ObjectType $ObjectType -Name $Name -HashAddValues $HashObjects.($Name).Add -HashUpdateValues $HashObjects.($Name).Update
                }
                elseif ($UpdateExisting)
                {
                    UpdateObject -ObjectType $ObjectType -Name $Name -HashUpdateValues $HashObjects.($Name).Update -FIMObject $obj
                }
                else {write-host "$ObjectType $Name already exists"}
            }
        }
    }
}

Function UninstallSchema
{
    PARAM ($HashObjects)
    END
    {
        $ErrorActionPreference = "Continue"

        foreach ($BoundObjectType in $HashObjects.BindingDescription.Keys)
        {
            ProcessObjects -ObjectType "BindingDescription" -HashObjects $Objects.BindingDescription.($BoundObjectType) -DeleteSchema $true
        }

        ProcessObjects -ObjectType "AttributeTypeDescription" -HashObjects $Objects.AttributeTypeDescription -DeleteSchema $true
        ProcessObjects -ObjectType "ObjectTypeDescription" -HashObjects $Objects.ObjectTypeDescription -DeleteSchema $true

        $ErrorActionPreference = "Stop"
    }
}
