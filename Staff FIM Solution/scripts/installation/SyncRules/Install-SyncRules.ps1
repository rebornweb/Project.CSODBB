PARAM([boolean]$UpdateExisting=$true,[boolean]$Uninstall=$false,[string]$fimSyncServer="occcp-as033")

### Written by Bob Bradley, UNIFY Solutions
###
### Installs the Schema and Policy objects for specified Sync Rules.
###

$ErrorActionPreference = "Stop"

. D:\Scripts\Shared\Set-LocalVariables.ps1
if ($IncludeScripts) {foreach ($IncludeScript in $IncludeScripts) {. $IncludeScript}}

#$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$scriptPath = "D:\Scripts\Installation\SyncRules"

###
### Check dependencies
###
if (-not (Test-Path ($WFScriptFolder + "\WFFunctions.ps1"))) {Throw ("Expected to find " + $WFScriptFolder + "\WFFunctions.ps1. If it is in a different location then change or set the $WFScriptFolder variable in the Set-LocalVariables.ps1 script.")}
if (-not (Test-Path $WFLogFolder)) {Throw ("Expected to find " + $WFLogFolder + ". If you want to use a different location for Workflow logging then change or set the $WFLogFolder variable in the Set-LocalVariables.ps1 script. Otherwise, create the folder in the specified location.")}

#$filter = "/ActivityInformationConfiguration[ActivityName='FimExtensions.FimActivityLibrary.PowerShellActivity']"
#$AICObj = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
#if (-not $AICObj) {Throw "The PowerShell activity must be installed."}

$filter = "/ActivityInformationConfiguration[ActivityName='UFIM.CustomActivities.UpdateResourceFromWorkflowData']"
$AICObj = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
if (-not $AICObj) {Throw "The 'UNIFY-Create update and delete FIM resource activity' must be installed."}

#$filter = "/AttributeTypeDescription[Name='PolicyGroup']"
#$obj = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
#if (-not $obj) {Throw "The PolicyGroup attribut must exist, must be bound to all Policy and UI object types, and the current account must have permission to update it. The script Setup-MPRs.ps1 may be used to create these prerequisites."}

#$filter = "/ma-data[DisplayName='Downstream AD']"
#$MAobj = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter

## XML and WMI functions
function getMAGuid (
    [string]$maName="Upstream AD"
) {
    $thisMA = get-wmiobject -class "MIIS_ManagementAgent where Name = '$maName'" -namespace "root\MicrosoftIdentityIntegrationServer" -computername $fimSyncServer
    $thisMA.Guid
}

function getMAName (
    [string]$maGuid="{405DD2A1-8B12-478C-A78B-7D398BE6DC7A}"
) {
    $thisMA = get-wmiobject -class "MIIS_ManagementAgent where Guid = '$maGuid'" -namespace "root\MicrosoftIdentityIntegrationServer" -computername $fimSyncServer
    $thisMA.Name
}

function Add-XmlFragment {
    Param(        
        [Parameter(Mandatory=$true)][System.Xml.XmlNode] $xmlElement,
        [Parameter(Mandatory=$true)][string] $text)        
    $xml = $xmlElement.OwnerDocument.ImportNode(([xml]$text).DocumentElement, $true)
    [void]$xmlElement.AppendChild($xml)
}

function ReadSRXml
{
    PARAM([string]$srName)
    END
    {
        $HashReturn = @{}

        $XmlFile = "$scriptPath\$srName.xml"
        if (Test-Path $XmlFile)
        {
            [xml]$sr = Get-Content $XmlFile
 
            $HashReturn.Add("ConnectedSystemScope",$sr.SynchronizationRule.ConnectedSystemScope.InnerXml)
            $HashReturn.Add("OutboundScope",$sr.SynchronizationRule.OutboundScope.InnerXml)
            $HashReturn.Add("RelationshipCriteria",$sr.SynchronizationRule.RelationshipCriteria.InnerXml)

            $PersistentFlow = @()
            foreach ($rule in $sr.SynchronizationRule.PersistentFlow."import-flow")
            {
                $PersistentFlow += $rule.OuterXml
            }
            foreach ($rule in $sr.SynchronizationRule.PersistentFlow."export-flow")
            {
                $PersistentFlow += $rule.OuterXml
            }
            $HashReturn.Add("PersistentFlow",$PersistentFlow)

            $InitialFlow = @()
            foreach ($rule in $sr.SynchronizationRule.InitialFlow."import-flow")
            {
                $InitialFlow += $rule.OuterXml
            }
            foreach ($rule in $sr.SynchronizationRule.InitialFlow."export-flow")
            {
                $InitialFlow += $rule.OuterXml
            }
            $HashReturn.Add("InitialFlow",$InitialFlow)

            return $HashReturn
        }
    }
}

<#function DumpSR ([string]$SRName)
{
    $thisSR = Export-FIMConfig -OnlyBaseResources -CustomConfig "/SynchronizationRule[DisplayName='$SRName']" #"/SynchronizationRule"
    #$thisSR = $allSRs.ResourceManagementObject | where {$_.ResourceManagementAttributes.AttributeName -eq "DisplayName" -and $_.ResourceManagementAttributes.Value -eq $SRName }
    $CompareSR = $thisSR.ResourceManagementObject.ResourceManagementAttributes | where {$_.AttributeName -notin @(
        "msidmOutboundScopingFilters","InitialFlow","PersistentFlow","RelationshipCriteria","ConnectedSystemScope","ManagementAgentID","ObjectType","Creator","CreatedTime","ObjectID"
    )} | % {"$($_.AttributeName):$($_.Value)" } #ConvertTo-Json
    $CompareSR
}#>


#$filter = "/SynchronizationRule"
#$allSRs = Export-FIMConfig -OnlyBaseResources -CustomConfig $filter
#$allSRs[0].ResourceManagementObject.ResourceManagementAttributes
#if (-not $allSRs) {Throw "The Sync Rules collection cannot be located."}

#foreach ($thisSR in ($allSRs.ResourceManagementObject | Where-Object { $_.ResourceManagementAttributes.AttributeName -eq "DisplayName" -and $_.ResourceManagementAttributes.Value -eq "Downstream Inbound Groups" }))
#foreach ($thisSR in ($allSRs.ResourceManagementObject | Where-Object { $_.ResourceManagementAttributes.AttributeName -eq "DisplayName" -and $_.ResourceManagementAttributes.Value -eq "Downstream Inbound Users" }))
#ConnectedSystems: ($allSRs.ResourceManagementObject.ResourceManagementAttributes | Where-Object { $_.AttributeName -eq "ConnectedSystem" }).Value
#ManagementAgentIDs: ($allSRs.ResourceManagementObject.ResourceManagementAttributes | Where-Object { $_.AttributeName -eq "ManagementAgentID" }).Value

## Objects to create are stored in hashtables.
## - The Object Type is the top level of the hashtable
## - The Display Name of the object is the next level
## - Under that we must have Add and Update - where "Add" includes attributes that may only be set at object creation
## - If an attribute is multivalued the values must be stored as an array, even if there is only one value to add.

#cls
$Objects = @{}

###
### Sync Rules
###


$Objects.Add("SynchronizationRules", @{})

$SRName = "cso-PHRIS: people are imported to FIM"
$SRObj = ReadSRXml -srName $SRName.Replace(":","")
$Objects.SynchronizationRules.Add($SRName,
@{
    "Add" = @{
        #"msidmOutboundIsFilterBased"="False"
        "ConnectedObjectType"="person"
        "ConnectedSystem"=(getMAGuid -maName "PHRIS")
        "ILMObjectType"="person"
        "FlowType"="0"
        "DisconnectConnectedSystemObject"="False"
        "CreateILMObject"="True"
        "CreateConnectedSystemObject"="False"
        "Precedence"="3"
    }
    "Update" = @{
        "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
        "ConnectedSystem"=(getMAGuid -maName "PHRIS")
        "RelationshipCriteria"=$SRObj.RelationshipCriteria
        #"msidmOutboundScopingFilters"=$SRObj.OutboundScope
        "InitialFlow"=$SRObj.InitialFlow
        "PersistentFlow" = $SRObj.PersistentFlow
        "Description"="PHRIS people are imported to FIM"
    }
    "Uninstall" = "DeleteObject"
})


$SRName = "cso-PHRIS: depts are imported to FIM"
$SRObj = ReadSRXml -srName $SRName.Replace(":","")
$Objects.SynchronizationRules.Add($SRName,
@{
    "Add" = @{
        #"msidmOutboundIsFilterBased"="False"
        "ConnectedObjectType"="dept"
        "ConnectedSystem"=(getMAGuid -maName "PHRIS")
        "ILMObjectType"="csoDepartment"
        "FlowType"="0"
        "DisconnectConnectedSystemObject"="False"
        "CreateILMObject"="True"
        "CreateConnectedSystemObject"="False"
        "Precedence"="5"
    }
    "Update" = @{
        "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
        "ConnectedSystem"=(getMAGuid -maName "PHRIS")
        "RelationshipCriteria"=$SRObj.RelationshipCriteria
        #"msidmOutboundScopingFilters"=$SRObj.OutboundScope
        "InitialFlow"=$SRObj.InitialFlow
        "PersistentFlow" = $SRObj.PersistentFlow
        "Description"="PHRIS depts are imported to FIM"
    }
    "Uninstall" = "DeleteObject"
})



$SRName = "cso-People: All active staff and students are provisioned to ADLDS"
$SRObj = ReadSRXml -srName $SRName.Replace(":","")
$Objects.SynchronizationRules.Add($SRName,
@{
    "Add" = @{
        #"msidmOutboundIsFilterBased"="False"
        "ConnectedObjectType"="user"
        "ConnectedSystem"=(getMAGuid -maName "CSODBB LDS")
        "ILMObjectType"="person"
        "FlowType"="1"
        "DisconnectConnectedSystemObject"="False"
        "CreateILMObject"="False"
        "CreateConnectedSystemObject"="True"
        "Precedence"="1"
    }
    "Update" = @{
        "ConnectedObjectType"="user"
        "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
        "RelationshipCriteria"=$SRObj.RelationshipCriteria
        #"msidmOutboundScopingFilters"=$SRObj.OutboundScope
        "InitialFlow"=$SRObj.InitialFlow
        "PersistentFlow" = $SRObj.PersistentFlow
        "Description"="All active staff and students are provisioned to ADLDS with an extended attribute set not available in AD"
    }
    "Uninstall" = "DeleteObject"
})

if ($false) {
    $SRName = "Downstream Outbound Groups"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="group"
            "ConnectedSystem"=(getMAGuid -maName "Downstream AD")
            "ILMObjectType"="group"
            "FlowType"="2"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="False"
            "CreateConnectedSystemObject"="True"
            "Precedence"="2"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Outbound flow rules for groups to Downstream CMO AD forest"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "Downstream Outbound Users"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="user"
            "ConnectedSystem"=(getMAGuid -maName "Downstream AD")
            "ILMObjectType"="person"
            "FlowType"="1"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="False"
            "CreateConnectedSystemObject"="True"
            "Precedence"="3"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Outbound flow rules for users to Downstream CMO AD forest"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "Upstream Inbound Users"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="False"
            "ConnectedObjectType"="user"
            "ConnectedSystem"=(getMAGuid -maName "Upstream AD")
            "ILMObjectType"="person"
            "FlowType"="0"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="False"
            "CreateConnectedSystemObject"="False"
            "Precedence"="2"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Inbound flow rules for users from Upstream CMO AD forest"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "Upstream Outbound Groups"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="group"
            "ConnectedSystem"=(getMAGuid -maName "Upstream AD")
            "ILMObjectType"="group"
            "FlowType"="2"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="False"
            "CreateConnectedSystemObject"="True"
            "Precedence"="1"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Outbound flow rules for groups to Upstream CMO AD forest"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "Upstream Outbound Users"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="user"
            "ConnectedSystem"=(getMAGuid -maName "Upstream AD")
            "ILMObjectType"="person"
            "FlowType"="1"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="False"
            "CreateConnectedSystemObject"="True"
            "Precedence"="3"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Outbound flow rules for users to Upstream CMO AD forest"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "HPSM Inbound Contacts"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="False"
            "ConnectedObjectType"="Contact"
            "ConnectedSystem"=(getMAGuid -maName "HPSM")
            "ILMObjectType"="person"
            "FlowType"="0"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="False"
            "CreateConnectedSystemObject"="False"
            "Precedence"="1"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="The presence of a join on the HPSM connector indicates that the service desk have completed initial on-boarding activities"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "SuccessFactors Inbound Users"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="User"
            "ConnectedSystem"=(getMAGuid -maName "Success Factors")
            "ILMObjectType"="person"
            "FlowType"="0"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="True"
            "CreateConnectedSystemObject"="False"
            "Precedence"="1"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Inbound flow rules for users from Success Factors (HR)"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "SuccessFactors Inbound CostCentres"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="CostCentre"
            "ConnectedSystem"=(getMAGuid -maName "Success Factors")
            "ILMObjectType"="costCentre"
            "FlowType"="0"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="True"
            "CreateConnectedSystemObject"="False"
            "Precedence"="6"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Inbound flow rules for cost centres from Success Factors (HR)"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "SuccessFactors Inbound Departments"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="Department"
            "ConnectedSystem"=(getMAGuid -maName "Success Factors")
            "ILMObjectType"="department"
            "FlowType"="0"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="True"
            "CreateConnectedSystemObject"="False"
            "Precedence"="3"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Inbound flow rules for departments from Success Factors (HR)"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "SuccessFactors Inbound JobClasses"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="JobClass"
            "ConnectedSystem"=(getMAGuid -maName "Success Factors")
            "ILMObjectType"="jobClass"
            "FlowType"="0"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="True"
            "CreateConnectedSystemObject"="False"
            "Precedence"="4"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Inbound flow rules for job classes from Success Factors (HR)"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "SuccessFactors Inbound Locations"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="Location"
            "ConnectedSystem"=(getMAGuid -maName "Success Factors")
            "ILMObjectType"="location"
            "FlowType"="0"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="True"
            "CreateConnectedSystemObject"="False"
            "Precedence"="5"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Inbound flow rules for locations from Success Factors (HR)"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "SuccessFactors Inbound Positions"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="Position"
            "ConnectedSystem"=(getMAGuid -maName "Success Factors")
            "ILMObjectType"="position"
            "FlowType"="0"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="True"
            "CreateConnectedSystemObject"="False"
            "Precedence"="7"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Inbound flow rules for positions from Success Factors (HR)"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "SuccessFactors Outbound Users Email"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="userEmail"
            "ConnectedSystem"=(getMAGuid -maName "Success Factors")
            "ILMObjectType"="person"
            "FlowType"="2"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="False"
            "CreateConnectedSystemObject"="True"
            "Precedence"="2"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Outbound flow rules for users email to Success Factors (HR)"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "SuccessFactors Outbound Users Email US"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="userEmail"
            "ConnectedSystem"=(getMAGuid -maName "Success Factors")
            "ILMObjectType"="person"
            "FlowType"="2"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="False"
            "CreateConnectedSystemObject"="True"
            #"Precedence"="1"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Outbound flow rules for users email (on premise US mailbox) to Success Factors (HR)"
        }
        "Uninstall" = "DeleteObject"
    })


    $SRName = "SuccessFactors Outbound Users Network Account"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="userEmployment"
            "ConnectedSystem"=(getMAGuid -maName "Success Factors")
            "ILMObjectType"="person"
            "FlowType"="2"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="False"
            "CreateConnectedSystemObject"="False"
            "Precedence"="8"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Outbound flow rules for users network account to Success Factors (HR)"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "SARa Outbound and Inbound"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="user"
            "ConnectedSystem"=(getMAGuid -maName "SARa")
            "ILMObjectType"="person"
            "FlowType"="2"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="False"
            "CreateConnectedSystemObject"="True"
            "Precedence"="1"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Outbound flow rules for users to SARa (SharePoint List) and confirming import of SARa ID"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "Provision AD Users"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="user"
            "ConnectedSystem"=(getMAGuid -maName "Provision AD Users")
            "ILMObjectType"="person"
            "FlowType"="2"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="False"
            "CreateConnectedSystemObject"="True"
            "Precedence"="1"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Provisions to Identity Broker which in turn provisions the shell AD account with unique sAMAccountName and mailNickname."
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "WAAD Inbound Users"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="False"
            "ConnectedObjectType"="user"
            "ConnectedSystem"=(getMAGuid -maName "WAAD")
            "ILMObjectType"="person"
            "FlowType"="0"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="False"
            "CreateConnectedSystemObject"="False"
            "Precedence"="1"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Inbound flow rules for users from Windows Azure Active Directory (license assignment and mailbox creation)"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "WAAD Inbound Groups"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="False"
            "ConnectedObjectType"="group"
            "ConnectedSystem"=(getMAGuid -maName "WAAD")
            "ILMObjectType"="aadObject"
            "FlowType"="0"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="True"
            "CreateConnectedSystemObject"="False"
            "Precedence"="2"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Inbound flow rules for WAAD groups (to reduce disconnectors)"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "Office365 Outbound Users"
    $SRObj = ReadSRXml -srName $SRName
    #cls
    #DumpSR -SRName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="True"
            "ConnectedObjectType"="userEmail"
            "ConnectedSystem"=(getMAGuid -maName "Office365")
            "ILMObjectType"="person"
            "FlowType"="2"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="False"
            "CreateConnectedSystemObject"="True"
            "Precedence"="1"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Outbound (and inbound) flow rules for users to Office365 (license assignment and mailbox creation)"
        }
        "Uninstall" = "DeleteObject"
    })

    $SRName = "Upstream Inbound User Mailboxes"
    $SRObj = ReadSRXml -srName $SRName
    $Objects.SynchronizationRules.Add($SRName,
    @{
        "Add" = @{
            "msidmOutboundIsFilterBased"="False"
            "ConnectedObjectType"="user"
            "ConnectedSystem"=(getMAGuid -maName "Upstream AD")
            "ILMObjectType"="person"
            "FlowType"="0"
            "DisconnectConnectedSystemObject"="False"
            "CreateILMObject"="False"
            "CreateConnectedSystemObject"="False"
            "Precedence"="4"
        }
        "Update" = @{
            "ConnectedSystemScope"=$SRObj.ConnectedSystemScope
            "RelationshipCriteria"=$SRObj.RelationshipCriteria
            "msidmOutboundScopingFilters"=$SRObj.OutboundScope
            "InitialFlow"=$SRObj.InitialFlow
            "PersistentFlow" = $SRObj.PersistentFlow
            "Description"="Inbound flow rules for mailbox users from Upstream CMO AD forest"
        }
        "Uninstall" = "DeleteObject"
    })
}

ProcessObjects -ObjectType "SynchronizationRule" -HashObjects $Objects.SynchronizationRules
