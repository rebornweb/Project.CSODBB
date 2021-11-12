<#
Get-Variables.ps1,v2.4,  written by UNIFY Solutions 2016

This script is called by Run-HealthCheck.ps1, and allows an interactive user
to set custom parameters for the Health Check.

#>

$ScriptVersions.Add("Get-Variables.ps1","2.4")

#region Functions

Function Get-ParameterValue
{
<#
.SYNPOSIS
    Prompts for a Parameter value to be entered, displaying a default or existing value that can be accepted or over-ridden with a new value.
    The response is converted to an array or yes/no value if applicable.
.OUTPUT
    Returns the entered or accepted value.
.PARAMETERS
    ParamName: The Parameter to ask for
    Prompt: The prompt to display, updated to include the default or existing value
    ShowDefault: The default value to show in the prompt and set if the user just hits Enter.
    DataType: Whether to return a string, array, Yes|No, or prompt for and securely store a credential.
.DEPENDENCIES
    
.ChangeLog
    Unify Support, 07/08/2016
#>
    PARAM(
        [string]$ParamName,
        [string]$Prompt,
        [string]$ShowDefault,
        [string]$DataType
        )
    END
    {
        [string]$ValueEntered = ""
        
        ###
        ### If we got a Default value, add it to the end of the prompt.
        ###
        if ($ShowDefault -ne "")
        {
            if ($DataType -eq "yesno") {$Prompt = $Prompt + (" Y/N (Default: {0})" -f $ShowDefault)}
            else {$Prompt = $Prompt + (" (Default: {0})" -f $ShowDefault)}
            $ValueEntered = $ShowDefault
        }

        ###
        ### Prompt for input and get the response. "Enter" selects the Default value.
        ###
        [string]$Response = Read-Host $Prompt
        if ($Response -ne '') 
        {
            if ($DataType -eq "yesno") 
            {
                if ($Response.ToLower().StartsWith("y")) {$ValueEntered = "Yes"}
                else {$ValueEntered = "No"}
            }
            else {$ValueEntered = $Response}
        }
        
        ###
        ### If credential, add an extra prompt to get, and store, the password
        ###
        if ($DataType -eq "credential")
        {
            $EnterPW = $false
            if (Test-Path $ValueEntered)
            {
                $Response = Read-Host "Re-enter password? (Y/N)"
                if ($Response.ToLower().StartsWith("y")) {$EnterPW = $true}
            }
            else
            {            
                $Folder = Split-Path -Path $ValueEntered -Parent
                if (-not (Test-Path $Folder)) 
                {
                    Write-Log -ErrorLevel Information -Message "Creating folder $Folder"
                    New-Item -Path $Folder -ItemType Directory | Out-Null
                }
                $EnterPW = $true
            }
            if ($EnterPW)
            {
                Read-Host -Prompt "Enter Password" -AsSecureString | ConvertFrom-SecureString | Out-File $ValueEntered
            }
        }

        ###
        ### Return value. Comma-separated lists are converted to array.
        ###
        if ($DataType -eq "array")
        {
            $Value = $ValueEntered.split(',') | % {$_.trim()}         
        }
        else
        {
            $Value = $ValueEntered
        }

        Return $Value
    }
}


Function Add-Parameter
{
<#
.SYNPOSIS
    Adds or updates a value in the $Parameters hashtable
.OUTPUT
    
.PARAMETERS
    ParamName: The Parameter to add or update. Corresponds to a key name in the ParametersDefinition table.
    ParamKey:  Where ParamName is a template, the actual key name to store in the Parameters table.
    OverrideDefault: Overrides the Default value set for this Parameter in the $ParameterDefinition hashtable. 
                -- Use when the Default value needs information to be generated that was not available when the $ParameterDefinition hashtable was defined.
                -- Data type not specied as may be string, array or hashtable.
    OverridePrompt: Overrides the Prompt value set for this Parameter in the $ParameterDefinition hashtable. Use when:
                -- the Prompt value needs information to be generated that was not available when the $ParameterDefinition hashtable was defined, or
                -- in the case of template parameters such as Infra_DBServer_[name], to specify a prompt which replaces a [variable] value.
                -- the value of "none" is a special value meaning "don't prompt this time". Needed because an empty string was interpreted the same as $null in some cases.
.DEPENDENCIES
    
.ChangeLog
    Carol Wapshere, 10/9/2016
#>
    PARAM (
        [Parameter(Mandatory=$true)][string]$ParamName,
        [string]$ParamKey,
        $OverrideDefault,
        [string]$OverridePrompt
        )
    END
    {
        if (-not $ParamKey) {$ParamKey = $ParamName}
        
        ###
        ### Work out the Default value for the Parameter
        ###
        if ($OverrideDefault) ## Option 1: Use OverrideDefault value if provided.
        {
            $Default = $OverrideDefault
        }
        elseif ($Parameters.($ParamKey)) ## Option 2: Existing value already set - show that as the Default value.
        {            
            $Default = $Parameters.($ParamKey)
        }
        else ## Option 3: No existing value and no Override Default value - generate default value based on $ParametersDefinition table.     
        { 
            if ($ParameterDefinition.($ParamName).ContainsKey("GenerateDefault") -and $ParameterDefinition.($ParamName).GenerateDefault -ne "")
            {
                $Default = Invoke-Expression -Command $ParameterDefinition.($ParamName).GenerateDefault
            }
            elseif ($ParameterDefinition.($ParamName).ContainsKey("Default") -and $ParameterDefinition.($ParamName).Default -ne "")
            {
                $Default = $ParameterDefinition.($ParamName).Default
            }
            else {$Default = ""}
        }
        
        ###
        ### Interactive Prompt value (if applicable)
        ###
        if ($OverridePrompt -and $OverridePrompt -ne "none") ## Option 1: Use OverridePrompt value if provided.
        {
            $Prompt = $OverridePrompt
        }
        else  ## Option 2: Generate from $ParametersDefinition table.  
        {                     
            if ($OverridePrompt -ne "none" -and $ParameterDefinition.($ParamName).Prompt) 
            {
                $Prompt = $ParameterDefinition.($ParamName).Prompt
            }
            else {$Prompt = ""}
        }

        ###
        ### If we're in interactive mode and $Prompt has a vaue then request for user input.
        ### Otherwise just use the Default value.
        ###
        if ($UpdateParametersMode -and $Prompt -ne "")
        {
            if ($Default.GetType().BaseType.Name -eq "Array") {$ShowDefault = $Default -join ","}
            else {$ShowDefault = $Default}
            $Value = Get-ParameterValue -ParameterName $ParamKey -Prompt $Prompt -ShowDefault $ShowDefault -DataType $ParameterDefinition.($ParamName).Type            
        }
        else
        {
            $Value = $Default
        }

        ###
        ### Add to or update the $Parameters table
        ###
        if ($Parameters.ContainsKey($ParamKey)) {$Parameters.($ParamKey) = $Value}
        else {$Parameters.Add($ParamKey,$Value)}
    }
}

#endregion Functions

#region Initialise

if ($myInvocation.MyCommand.Path -ne $null) {$ScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Path)}
else {$ScriptDir = (Get-Item -Path ".\" -Verbose).FullName}
$ParametersDir = $ScriptDir + '\ScriptInfo'

if ((Get-Module).Name -notcontains "Unify.Health") {Import-Module -Name $ScriptDir\Unify.Health.psm1 -ErrorAction stop}

## Import script parameters from json file
$ParametersFile = 'Health-Vars-Constants.json'
$ParametersOldFile = 'Health-Vars-Constants-Old.json'
$ParametersFilePath = "$ParametersDir\$ParametersFile"
$ParametersOldFilePath = "$ParametersDir\$ParametersOldFile"  

## Check Parameters file and folder exists, and load existing parameters.
if (Test-Path $ParametersFilePath) 
{        
	Write-Log -ErrorLevel Information -Console -Message "Parameters file found, loading existing values"
    $jsonVars = Get-Content -Raw -Path $ParametersFilePath | ConvertFrom-Json
}
else
{
	Write-Log -ErrorLevel Warning -Console -Message  "$ParametersDir not found, Creating folder ..."
    $UpdateParametersMode = $true
    $jsonVars = @{}

    if (!(Test-Path $ParametersDir))
    {   
        New-Item -Path $ParametersDir -ItemType Directory
        Write-Log -ErrorLevel Information -Console -Message "Folder $ParametersDir created"       
    }   
}

#endregion Initialise

<#
The ParameterDefinition hashtable defines all Parameters to be saved.
Define as follows:

  - Parameter Name: The Key of the hashtable entry. Names are set with a defined prefix that is used in a script 
                    block further down. Do not define a new prefix without also creating the matching script block.

  - Type: specific names used in the Get-ParameterValue function. Can be:
               array: values stored as an array of strings
               yesno: will add "Y/N" to the prompt and store Yes|No
               string: value stored as a string

  - Prompt: If specified will prompt for user input. If not specified, either Default or GenerateDefault must 
            be specified to produce the stored value.

  - Default: A default value to offer or set. This should be a simple string value. If using a variable it must
             aready have beed defined before this point.

  - GenerateDefault: A command that can be run using Invoke-Expression at the point when the parameter is being set,
                     to generate the value. If the command is complex create a function that returns the value.
#>
$ParameterDefinition = [ordered]@{
    "Feature_FIMSync"=@{"Type"="string";"Prompt"="Collect MIM Sync Service Data?";"Default"="No"}
    "Feature_FIMService"=@{"Type"="string";"Prompt"="Collect MIM Service Data?";"Default"="No"}
    "Feature_EventBroker"=@{"Type"="string";"Prompt"="Collect Event Broker Logs?";"Default"="No"}
    "Feature_IdentityBroker"=@{"Type"="string";"Prompt"="Collect Identity Broker Logs?";"Default"="No"}
    "Feature_WindowsEventLog"=@{"Type"="string";"Prompt"="Collect Windows Event Logs?";"Default"="No"}
    "Feature_Infrastructure"=@{"Type"="string";"Prompt"="Collect Infrastructure Health Data?";"Default"="No"}
    "Feature_SplunkUpload"=@{"Type"="string";"Prompt"="Upload to Splunk automatically?";"Default"="No"}

    "AlwaysUpdate_ScriptDir"=@{"Type"="string";"Prompt"="";"Default"=$ScriptDir}
    "AlwaysUpdate_ParametersFile"=@{"Type"="string";"Prompt"="";"Default"=$ParametersFilePath}
    "AlwaysUpdate_LastRunTime"=@{"Type"="datetime";"Prompt"="";"GenerateDefault"="(Get-Date).ToUniversalTime().ToString('s')"}

    "General_ClientPrefix"=@{"Type"="string";"Prompt"="Enter the client abbreviated prefix, such as 'CORP' or 'CORP-DEV'";"Default"=""}
    "General_DataFile_Version"=@{"Type"="string";"Prompt"="";"GenerateDefault"='($Parameters.General_ClientPrefix) + "_HealthScript_Version.json"'}
    "General_DataFolder"=@{"Type"="string";"Prompt"="Specify data collection folder location";"Default"="$ScriptDir\Data"}
    "General_DataUpload"=@{"Type"="string";"Prompt"="";"GenerateDefault"='$Parameters.General_DataFolder + "\UPLOAD"'}
    "General_DataRetention" = @{"Type"="string";"Prompt"="Specify retention period in days for collected Data files";"Default"="30"}

    "FIMSync_DataFile_ObjectCounts"=@{"Type"="string";"Prompt"="";"GenerateDefault"='($Parameters.General_ClientPrefix) + "_FIMSync_ObjectCounts.json"'}
    "FIMSync_DataFile_Runs"=@{"Type"="string";"Prompt"="";"GenerateDefault"='($Parameters.General_ClientPrefix) + "_FIMSync_Runs.json"'}
    "FIMSync_DataFile_Version"=@{"Type"="string";"Prompt"="";"GenerateDefault"='($Parameters.General_ClientPrefix) + "_FIMSync_Version.json"'}
    "FIMSync_DataFile_MAs"=@{"Type"="string";"Prompt"="";"GenerateDefault"='($Parameters.General_ClientPrefix) + "_FIMSync_MAs.json"'}
    "FIMSync_Server"=@{"Type"="string";"Prompt"="Enter the name of the FIMSynchronizationService server";"GenerateDefault"="hostname"}
    "FIMSync_ProgramFolder"=@{"Type"="string";"Prompt"="Enter the folder location of the FIMSynchronizationService Program";"Default"="C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service"}
    "FIMSync_DB"=@{"Type"="string";"Prompt"="Enter the name of the FIMSynchronizationService database";"Default"="FIMSynchronizationService"}
    "FIMSync_DBServer"=@{"Type"="string";"Prompt"="Enter the name of the SQL Server";"Default"=""}
    "FIMSync_DBInstance"=@{"Type"="string";"Prompt"="Enter the name of the SQL Instance";"Default"="DEFAULT"}

    "FIMSvc_DataFile_ObjectCounts"=@{"Type"="string";"Prompt"="";"GenerateDefault"='($Parameters.General_ClientPrefix) + "_FIMSvc_ObjectCounts.json"'}
    "FIMSvc_DataFile_Requests"=@{"Type"="string";"Prompt"="";"GenerateDefault"='($Parameters.General_ClientPrefix) + "_FIMSvc_Requests.json"'}
    "FIMSvc_DataFile_Version"=@{"Type"="string";"Prompt"="";"GenerateDefault"='($Parameters.General_ClientPrefix) + "_FIMSvc_Version.json"'}
    "FIMSvc_Servers"=@{"Type"="array";"Prompt"="Enter the servers hosting the MIM Service, comma-separated";"GenerateDefault"="hostname"}
    "FIMSvc_DB"=@{"Type"="string";"Prompt"="Enter the name of the FIMService database";"Default"="FIMService"}
    "FIMSvc_DBServer"=@{"Type"="string";"Prompt"="Enter the name of the SQL Server";"Default"=""}
    "FIMSvc_DBInstance"=@{"Type"="string";"Prompt"="Enter the name of the SQL Instance";"Default"="DEFAULT"}
    
    "EB_DataFile_Logs"=@{"Type"="string";"Prompt"="";"GenerateDefault"='($Parameters.General_ClientPrefix) + "_EventBroker_Logs.json"'}
    "EB_DataFile_Version"=@{"Type"="string";"Prompt"="";"GenerateDefault"='($Parameters.General_ClientPrefix) + "_EventBroker_Version.json"'}
    "EB_Server"=@{"Type"="string";"Prompt"="Enter the name of the Event Broker server";"GenerateDefault"="hostname"}
    "EB_ProgramFolder"=@{"Type"="string";"Prompt"="Enter the folder location of the Event Broker Program";"Default"="C:\Program Files\UNIFY Solutions\Event Broker"}
    "EB_LogFolder"=@{"Type"="string";"Prompt"="Enter the folder location of the Event Broker log files";"GenerateDefault"='($Parameters.EB_ProgramFolder) + "\Services\Logs"'}

    "IDB_DataFile_Logs"=@{"Type"="string";"Prompt"="";"GenerateDefault"='($Parameters.General_ClientPrefix) + "_IdentityBroker_Logs.json"'}
    "IDB_DataFile_Version"=@{"Type"="string";"Prompt"="";"GenerateDefault"='($Parameters.General_ClientPrefix) + "_IdentityBroker_Version.json"'}
    "IDB_Server"=@{"Type"="string";"Prompt"="Enter the name of the Identity Broker server";"GenerateDefault"="hostname"}
    "IDB_ProgramFolder"=@{"Type"="string";"Prompt"="Enter the folder location of the Identity Broker Program folder";"Default"="C:\Program Files\UNIFY Solutions\Identity Broker"}
    "IDB_LogFolder"=@{"Type"="string";"Prompt"="Enter the folder location of the Identity Broker log files";"GenerateDefault"='($Parameters.IDB_ProgramFolder) + "\Services\Logs"'}
    "IDB_DB"=@{"Type"="string";"Prompt"="Enter the name of the Identity Broker database";"Default"="Unify.IdentityBroker"}
    "IDB_DBServer"=@{"Type"="string";"Prompt"="Enter the name of the SQL Server";"Default"=""}
    "IDB_DBInstance"=@{"Type"="string";"Prompt"="Enter the name of the SQL Instance";"Default"="DEFAULT"}

    "EventLog_DataFile_Events"=@{"Type"="string";"Prompt"="";"GenerateDefault"='($Parameters.General_ClientPrefix) + "_WindowsEventLog_[Server]_[EventLog].json"'}
    "EventLog_Servers"=@{"Type"="array";"Prompt"="Enter the servers to export Event Logs from, NetBIOS names, comma-separated";"GenerateDefault"="hostname"}
    "EventLog_Names"=@{"Type"="array";"Prompt"="Enter Event Log names, comma-separated";"Default"=@("Application","System","Forefront Identity Manager")}
    "EventLog_EntryTypes"=@{"Type"="array";"Prompt"="Enter Event Log entry types, comma-separated";"Default"=@("Error","Warning")}
    "EventLog_MaxEvents"=@{"Type"="string";"Prompt"="Enter the maximum number of Event Log entries to get";"Default"="All"}

    "Infra_DataFile_Server"=@{"Type"="string";"Prompt"="";"GenerateDefault"='($Parameters.General_ClientPrefix) + "_ServerState_[Server].json"'}
    "Infra_DataFile_DB"=@{"Type"="string";"Prompt"="";"GenerateDefault"='($Parameters.General_ClientPrefix) + "_DBState_[DB].json"'}
    "Infra_Servers"=@{"Type"="array";"Prompt"="List all servers to be checked for general operation and performance";"GenerateDefault"='$Parameters.EventLog_Servers + $Parameters.FIMSync_Server + $Parameters.IDB_Server | select -Unique'}
    "Infra_DB_All"=@{"Type"="array";"Prompt"="List all SQL Databases for the Infrastructure checks, separated by commas";"Default"=@("FIMService","FIMSynchronizationService","Unify.IdentityBroker")}
    "Infra_DBServer_[name]"=@{"Type"="string";"Prompt"="Enter the [DB] SQL Server name";"Default"=""}
    "Infra_DBInstance_[name]"=@{"Type"="string";"Prompt"="Enter the [DB] SQL Instance name";"Default"="DEFAULT"}

	"Splunk_AzureStorageURL"=@{"Type"="string";"Prompt"="Enter Azure client storage URL";"GenerateDefault"='"https://unifyhealthcheck.file.core.windows.net/clients/{0}-healthcheck-1-internal" -f $Parameters.General_ClientPrefix.ToLower()'}
    "Splunk_CredFile"=@{"Type"="credential";"Prompt"="Enter the full path to the file where the ecrypted Azure SAS key will be stored";"Default"="$ScriptDir\Creds\AzureKey.txt"}

    "_LastRunTime"=@{"Type"="datetime";"Prompt"="";"GenerateDefault"='$Parameters.AlwaysUpdate_LastRunTime'}
}

## Add custom Parameter Definitions
if (Test-Path "$ScriptDir\Get-Variables_Custom.ps1")
{
    . "$ScriptDir\Get-Variables_Custom.ps1"
    foreach ($key in $ParameterDefinition_Custom.Keys)
    {
        if ($key.StartsWith("Custom_")) {$ParameterDefinition.Add($Key,$ParameterDefinition_Custom.($Key))}
    }
}


#region GetParameters

###
### Start by copying all existing Parameter values
###
[hashtable] $Global:Parameters = [ordered]@{}
foreach ($match in $ParameterDefinition.Keys | Select-String "\[" -NotMatch)
{
    $item = $match.ToString()
    if ($jsonVars.($item)) {$Parameters.Add($item,$jsonVars.($item))}
}
foreach ($match in $ParameterDefinition.Keys | Select-String "\[")
{
    $item = $match.ToString()
    foreach ($matchvar in ($jsonVars | Get-Member).Name | Select-String ($item.Split("[")[0]))
    {
        $itemvar = $matchvar.ToString()
        $Parameters.Add($itemvar,$jsonVars.($itemvar))
    }
}


###
### Parameter values that are updated every time the script runs
###
foreach ($match in ($ParameterDefinition.Keys) | Select-String "AlwaysUpdate_")
{
    $Parameters.Remove($match.ToString())
    Add-Parameter -ParamName $match.ToString()
}


###
### Script Features to configure - pops up a UI checkbox for this part
###

if ($UpdateParametersMode)
{
    $FeatureOptions = @{}

    ## Define a Question and Answer for each feature using the $Features hashtable
    function AddQuestion
    {
        PARAM ([string]$ParameterName, [string]$Prompt)
        END
        {
            [boolean]$Default = $false
            if ($jsonVars.($ParameterName) -and $jsonVars.($ParameterName) -eq "Yes") {$Default = $true}
            $FeatureOptions.Add($ParameterName, @{"question" = $Prompt; "default" = $Default})
        }
    }

    foreach ($match in (@($ParameterDefinition.Keys) | Select-String "Feature_"))
    {
        AddQuestion -ParameterName $match.ToString() -Prompt $ParameterDefinition.($match.ToString()).Prompt
    }


    #Begin building UI
    ###########
    #Import required libs
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

    #Generate initial form 
    $questionsForm = New-Object System.Windows.Forms.Form
    $questionsForm.Text = "Data Collection Questions"
    $questionsForm.Size = New-Object System.Drawing.Size(300, 400)
    $questionsForm.StartPosition = "CenterScreen"
    $questionsForm.ControlBox = $false

    #Set the current vertical size variable so we can stack the check boxes (in pixels)
    $currentVerticalLocation = 20
    
    #Loop through the hashtable to output required check boxes
    foreach ($option in $FeatureOptions.GetEnumerator()) {
        #Create the option
        $optionBox = New-Object System.Windows.Forms.Checkbox
        $optionBox.Location = New-Object System.Drawing.Size(10, $currentVerticalLocation)
        $optionBox.Name = $option.Key
        $optionBox.Size = New-Object System.Drawing.Size(500,20)
        $optionBox.Text = $option.Value.question
        $optionBox.Checked = $option.Value.default
        $questionsForm.Controls.Add($optionBox)
        #Bump up the vertical location
        $currentVerticalLocation += 20
    }

    # Add the OK Button
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size(120, $currentVerticalLocation)
    $OKButton.Size = New-Object System.Drawing.Size(75, 23)
    $OKButton.Text = "OK"
    $OKButton.Add_Click({
        foreach($option in $FeatureOptions.GetEnumerator()) {
            [System.Windows.Forms.Checkbox]$checkBox = $questionsForm.Controls.Item($option.Key)

            if ($checkBox.Checked) {$Value = "Yes"}
            else {$Value = "No"}

            if ($Parameters.ContainsKey($option.Key)) {$Parameters.($option.Key) = $Value}
            else {$Parameters.Add($option.Key,$Value)}

        } #end foreach
        $questionsForm.Close()
    }) #end add_click
    $questionsForm.Controls.Add($OKButton)
    [void]$questionsForm.ShowDialog()
}


###
### General Parameters
###
if ($UpdateParametersMode)
{
    write-host "`nGeneral Settings:" -ForegroundColor Yellow

    foreach ($match in ($ParameterDefinition.Keys) | Select-String "General_")
    {
        Add-Parameter -ParamName $match.ToString()
    }
}

###
### Feature: MIM Sync Service
###
if ($Parameters.Feature_FIMSync -eq 'Yes' -and $UpdateParametersMode)
{
    write-host "`nMIM Sync Settings:" -ForegroundColor Yellow

    foreach ($match in ($ParameterDefinition.Keys) | Select-String "FIMSync_")
    {
        Add-Parameter -ParamName $match.ToString()
    }

    ## Also add values to the Infra_DB_[DBName] parameters so they don't have to be entered again
    Add-Parameter -ParamName "Infra_DBServer_[name]" -ParamKey ("Infra_DBServer_" + $Parameters.FIMSync_DB) -OverrideDefault $Parameters.FIMSync_DBServer -OverridePrompt "none"
    Add-Parameter -ParamName "Infra_DBInstance_[name]" -ParamKey ("Infra_DBInstance_" + $Parameters.FIMSync_DB) -OverrideDefault $Parameters.FIMSync_DBInstance -OverridePrompt "none"
}

###
### Feature: MIM Service
###
if ($Parameters.Feature_FIMService -eq 'Yes' -and $UpdateParametersMode)
{
    write-host "`nMIM Service Settings:" -ForegroundColor Yellow

    foreach ($match in ($ParameterDefinition.Keys) | Select-String "FIMSvc_")
    {
        Add-Parameter -ParamName $match.ToString()
    }

    ## Also add values to the Infra_DB_[DBName] parameters so they don't have to be entered again
    Add-Parameter -ParamName "Infra_DBServer_[name]" -ParamKey ("Infra_DBServer_" + $Parameters.FIMSvc_DB) -OverrideDefault $Parameters.FIMSvc_DBServer -OverridePrompt "none"
    Add-Parameter -ParamName "Infra_DBInstance_[name]" -ParamKey ("Infra_DBInstance_" + $Parameters.FIMSvc_DB) -OverrideDefault $Parameters.FIMSvc_DBInstance -OverridePrompt "none"
 }

###
### Feature: Event Broker
###
if ($Parameters.Feature_EventBroker -eq 'Yes' -and $UpdateParametersMode)
{
    write-host "`nEvent Broker Settings:" -ForegroundColor Yellow

    foreach ($match in ($ParameterDefinition.Keys) | Select-String "EB_")
    {
        Add-Parameter -ParamName $match.ToString()
    }
}


###
### Feature: Identity Broker
###
if ($Parameters.Feature_IdentityBroker -eq 'Yes' -and $UpdateParametersMode)
{
    write-host "`nIdentity Broker Settings:" -ForegroundColor Yellow

    foreach ($match in ($ParameterDefinition.Keys) | Select-String "IDB_")
    {
        Add-Parameter -ParamName $match.ToString()
    }

    ## Also add values to the Infra_DB_[DBName] parameters so they don't have to be entered again
    Add-Parameter -ParamName "Infra_DBServer_[name]" -ParamKey ("Infra_DBServer_" + $Parameters.IDB_DB) -OverrideDefault $Parameters.IDB_DBServer -OverridePrompt "none"
    Add-Parameter -ParamName "Infra_DBInstance_[name]" -ParamKey ("Infra_DBInstance_" + $Parameters.IDB_DB) -OverrideDefault $Parameters.IDB_DBInstance -OverridePrompt "none"
}


###
### Feature: Windows Event Logs
###
if ($Parameters.Feature_WindowsEventLog -eq 'Yes' -and $UpdateParametersMode)
{
    write-host "`nWindows Event Log Settings:" -ForegroundColor Yellow

    $ServersAdded = @($Parameters.FIMSync_Server) + @($Parameters.FIMSvc_Servers) + @($Parameters.IDB_Server) | select-object -Unique
    Add-Parameter -ParamName "EventLog_Servers" -OverrideDefault ($ServersAdded -join ",")

    foreach ($match in ($ParameterDefinition.Keys) | Select-String "EventLog_" | Select-String "EventLog_Servers" -NotMatch)
    {
        Add-Parameter -ParamName $match.ToString()
    }
}


###
### Feature: Infrastructure
###
if ($Parameters.Feature_Infrastructure -eq 'Yes' -and $UpdateParametersMode)
{
    write-host "`nInfrastructure Settings:" -ForegroundColor Yellow

    foreach ($match in ($ParameterDefinition.Keys) | Select-String "Infra_" | Select-String "Infra_DB|Infra_Cred" -NotMatch)
    {
        Add-Parameter -ParamName $match.ToString()
    }

    ## Database setting
    ## Add any DBs already defined
    if ($Parameters.Infra_DB_All -or $Parameters.FIMSync_DB -or $Parameters.FIMSvc_DB -or $Parameters.IDB_DB) 
    {
        $DBsAdded = @($Parameters.Infra_DB_All) + @($Parameters.FIMSync_DB) + @($Parameters.FIMSvc_DB) + @($Parameters.IDB_DB) | select-object -Unique
        Add-Parameter -ParamName "Infra_DB_All" -OverrideDefault $DBsAdded
    }

    if ($Parameters."Infra_DB_All")
    {
        foreach ($DB in $Parameters."Infra_DB_All")
        {
            $Prompt = $ParameterDefinition."Infra_DBServer_[name]".Prompt.Replace("[DB]",$DB)
            Add-Parameter -ParamName "Infra_DBServer_[name]" -ParamKey "Infra_DBServer_$DB" -OverridePrompt $Prompt

            $Prompt = $ParameterDefinition."Infra_DBInstance_[name]".Prompt.Replace("[DB]",$DB)
            Add-Parameter -ParamName "Infra_DBInstance_[name]" -ParamKey "Infra_DBInstance_$DB" -OverridePrompt $Prompt
        }
    }
}


###
### Feature: Ping Federate
###
if ($Parameters.Feature_Ping -eq 'Yes' -and $UpdateParametersMode)
{
    write-host "`nPing Federate Settings:" -ForegroundColor Yellow

    foreach ($match in ($ParameterDefinition.Keys) | Select-String "Ping_")
    {
        Add-Parameter -ParamName $match.ToString()
    }
}


###
### Splunk Upload
###
if ($Parameters.Feature_SplunkUpload -eq 'Yes' -and $UpdateParametersMode)
{
    write-host "`nSplunk Upload Settings:" -ForegroundColor Yellow

    foreach ($match in ($ParameterDefinition.Keys) | Select-String "Splunk_" | Select-String "Splunk_Cred" -NotMatch)
    {
        Add-Parameter -ParamName $match.ToString()
    }

    Add-Parameter -ParamName "Splunk_CredFile"
}

###
### Feature: Custom Parameters
###
if ($UpdateParametersMode -and (($ParameterDefinition.Keys) | Select-String "Custom_"))
{
    write-host "`nCustom Settings:" -ForegroundColor Yellow

    foreach ($match in ($ParameterDefinition.Keys) | Select-String "Custom_")
    {
        Add-Parameter -ParamName $match.ToString()
    }
}


###
### Create new Parameters file
###
$ParametersJSON = $Parameters | ConvertTo-Json
if ($ParametersJSON -and (Test-Path $ParametersFilePath)){

    Write-Log -ErrorLevel Information -Console -Message  "Existing Parameters file found...." "Yellow"
	if (Test-Path $ParametersOldFilePath){

        Write-Log -ErrorLevel Information -Console -Message  "Existing Parameters Backup file found...." "Yellow"
		Remove-Item $ParametersOldFilePath
		Write-Log -ErrorLevel Information -Console -Message  "Removed Existing Parameters Backup file" "Yellow"
		Rename-Item $ParametersFilePath $ParametersOldFile
        Write-Log -ErrorLevel Information -Console -Message  "Existing Parameters file renamed for fallback..." 
	}
	else
    {
		Rename-Item $ParametersFilePath $ParametersOldFile
        Write-Log -ErrorLevel Information -Console -Message  "Existing Parameters file renamed for fallback...."
	}
}

$ParametersJSON | Out-File -FilePath $ParametersFilePath -Force
Write-Log -ErrorLevel Information -Console -Message  "Parameters file created/updated"

#endregion GetParameters
