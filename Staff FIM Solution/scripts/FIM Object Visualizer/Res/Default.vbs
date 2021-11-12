'-----------------------------------------------------------------------------------------------------------------------------------------
 Option Explicit
'-----------------------------------------------------------------------------------------------------------------------------------------
 Const FORM_WIDTH      = 800
 Const FORM_HEIGHT     = 800
 Const MSG_READY       = "<p>Ready</p>"
 Const MSG_BUSY        = "<p>Processing request. Please wait...</p>"
 Const SERVICE_NAME    = "FIMService"
 Const MSG_NO_FIM      = "The FIM Service is not installed on this computer"
 Const MSG_SUCC        = "Command completed successfully"
 Const MSG_NOPS        = "This script requires PowerShell to be installed"
'-----------------------------------------------------------------------------------------------------------------------------------------
'Global Variables:
'-----------------------------------------------------------------------------------------------------------------------------------------
 Dim gCollectionsFolder, gXsltDisplayNamePath, gReportsFolder, gOperationsFolder 
'-----------------------------------------------------------------------------------------------------------------------------------------
'Procedure to initialize controls and variables 
'-----------------------------------------------------------------------------------------------------------------------------------------
 Sub OnMouseOver(idCtrl)
    idCtrl.classname = "over"
 End Sub
 
 Sub OnMouseOut(idCtrl)
    idCtrl.classname = "button"
 End Sub
 
 Sub OnMouseDown(idCtrl)
    idCtrl.classname = "down"
 End Sub
 
 Sub OnMouseUp(idCtrl)
    idCtrl.classname = "over"
 End Sub 
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub ResizeControls()
    Dim oCtrl 
    Set oCtrl = document.getelementbyid("oData")
    oCtrl.style.height = document.body.clientHeight - 78
    oCtrl.style.width  = document.body.clientWidth - 132
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub PowerShellCheck()
    Dim oShell, retVal
    Set oShell  = CreateObject("WScript.Shell")
    On Error Resume Next
    retVal = oShell.RegRead("HKLM\SOFTWARE\Microsoft\PowerShell\1\Install") 
    On Error GoTo 0
    
    If(0 <> Err.number) Then
       MsgBox MSG_NOPS, vbExclamation, oHTA.applicationName
       Window.Close
    End If 
    
    On Error Resume Next
    retVal = oShell.RegRead("HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell\ExecutionPolicy")
    On Error GoTo 0
    
    Dim errMsg
    errMsg = "To run this script, you need to enable PowerShell to run script files, " & _
             "start PowerShell, and then type " & _
             "Set-ExecutionPolicy Unrestricted."

    If(0 <> Err.number) Then
       MsgBox errMsg, vbExclamation, oHTA.applicationName
       Window.Close
    End If 
    
    If(retVal = "Restricted" or retVal = "AllSigned") Then
       MsgBox errMsg, vbExclamation, oHTA.applicationName
       Window.Close
    End If 
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Function HtaCheck()
    HtaCheck = 0
    
    Dim oShell, retVal 
    Set oShell  = CreateObject("WScript.Shell")
 
    retVal = oShell.RegRead("HKLM\SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine\ApplicationBase") 
    If(0 < InStr(LCase(retVal), "syswow64")) Then
       MsgBox "You are running your HTA in 32bit mode!", vbExclamation, oHTA.applicationName
       HtaCheck = 1
    End If   
 End Function
'------------------------------------------------------------------------------------------------------------------------------------------------
 Function FimCheck()
    FimCheck = 0
    
    Dim oWMIService, colItems 
    Set oWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}\\.\root\cimv2")
    Set colItems = oWMIService.ExecQuery("Select * from Win32_Service Where Name = '" & SERVICE_NAME & "'")
    
    If(0 = colItems.Count) Then
       MsgBox MSG_NO_FIM, vbExclamation, oHTA.applicationName
       FimCheck = 1
    End If
 End Function
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub ShowHelp()
    MsgBox "Version: " & oHTA.version, vbInformation, oHTA.applicationName
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub CopyData()
    Dim oTable
    Set oTable = document.getelementbyid("tdata")
    
    If(oTable Is Nothing) then 
       MsgBox "There is no data displayed", vbExclamation, oHTA.applicationName
       Exit Sub
    End If
 
    Dim ctRange
    Set ctRange = document.body.createControlRange
    ctRange.addElement(oTable)
    ctRange.execCommand("Copy")
    
    MsgBox "Data copied to clipboard successfully", vbInformation, oHTA.applicationName
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub CopyHTML()
    Dim oTable
    Set oTable = document.getelementbyid("tdata")
    
    If(oTable Is Nothing) then 
       MsgBox "There is no data displayed", vbExclamation, oHTA.applicationName
       Exit Sub
    End If

    window.clipboardData.SetData "text", oTable.outerHtml
  
    MsgBox "HMTL data copied to clipboard successfully", vbInformation, oHTA.applicationName

 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub Initialize()
   '---------------------------------------------------------------------------------- 
    Dim wLeft, wTop
    wLeft = CInt((parent.window.screen.availWidth - FORM_WIDTH) / 2)
    wTop  = CInt((parent.window.screen.availHeight - FORM_HEIGHT) / 2)
    parent.window.moveTo wLeft, wTop
    parent.window.resizeTo FORM_WIDTH, FORM_HEIGHT
    ResizeControls()
    PowerShellCheck()
   '----------------------------------------------------------------------------------
    Dim oShell
    Set oShell  = CreateObject("WScript.Shell")
    gOperationsFolder    = oShell.CurrentDirectory & "\Operations"
    gCollectionsFolder   = oShell.CurrentDirectory & "\Collection"
    gReportsFolder       = oShell.CurrentDirectory & "\Reports\"
    gXsltDisplayNamePath = oShell.CurrentDirectory & "\Collection\Display Names.xslt"
   '---------------------------------------------------------------------------------- 
    GetListControlData lbCollection,       gCollectionsFolder,           ".ps1"
    GetListControlData lbCollectionNames,  gCollectionsFolder & "\Data", ".xml"
    GetListControlData lbReports,          gReportsFolder,               ".ps1"
    GetListControlData lbReportNames,      gReportsFolder & "\Data",     ".xml"
   '---------------------------------------------------------------------------------- 
    oStatus.innerHtml = MSG_READY
   '---------------------------------------------------------------------------------- 
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub Destructor()
 End Sub  
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub ShowObject(filterVal, filterMode)
 
    If(filterMode = "ObjectDefinitions") Then
       GetObjectDefinition filterVal 
       Exit Sub
    End If
    
	Dim oShell, xmlFile, xslFile
    Set oShell  = CreateObject("WScript.Shell")
    xmlFile = oShell.CurrentDirectory & "\Collection\Data\" & filterMode & ".xml"
    xslFile = oShell.CurrentDirectory & "\Collection\" & filterMode & ".xslt"
    DoTransformation xmlFile, xslFile, "filter", filterVal
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub GetDisplayNames()
    If(0 > lbCollectionNames.selectedIndex) Then
       MsgBox "No list item selected", vbInformation, oHTA.ApplicationName
       Exit Sub
    End If
    
    Dim xsltFileName
    Select Case lbCollectionNames.options(lbCollectionNames.selectedIndex).text
       Case "Replication Configuration"
          xsltFileName = gCollectionsFolder + "\Replication Configuration Display Names.xslt"
       Case "Provisioning Policies"
          xsltFileName = gCollectionsFolder + "\Provisioning Policies Display Names.xslt"
       Case "Attribute Flow Precedence"
          xsltFileName = gCollectionsFolder + "\Attribute Flow Precedence Display Names.xslt"
       Case "Active Metaverse Schema"
          xsltFileName = gCollectionsFolder + "\Active Metaverse Schema Display Names.xslt"
       Case "FIMMA Schema"
          xsltFileName = gCollectionsFolder + "\FIMMA Schema Display Names.xslt"
       Case "Management Agent Attributes"
          xsltFileName = gCollectionsFolder + "\Management Agent Attributes Display Names.xslt"
       Case Else
          xsltFileName = gXsltDisplayNamePath
    End Select

    DoTransformation lbCollectionNames.options(lbCollectionNames.selectedIndex).value, _
                     xsltFileName, _
                     "", _
                     ""
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub ShowAttributesForMa(maName)
    DoTransformation gCollectionsFolder & "\Data\Management Agent Attributes.xml", _
                     gCollectionsFolder & "\Management Agent Attributes.xslt", _
                     "maname", _
                     maName
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub ShowFIMMASchemaFor(objectType)
    DoTransformation gCollectionsFolder & "\Data\FIMMA Schema.xml", _
                     gCollectionsFolder & "\FIMMA Schema.xslt", _
                     "filter", _
                     objectType
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub ShowMetaverseSchemaFor(objectType)
    DoTransformation gCollectionsFolder & "\Data\Active Metaverse Schema.xml", _
                     gCollectionsFolder & "\Active Metaverse Schema.xslt", _
                     "filter", _
                     objectType
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub ShowAttributeFlowPrecedenceFor(objectType)
    DoTransformation gCollectionsFolder & "\Data\Attribute Flow Precedence.xml", _
                     gCollectionsFolder & "\Attribute Flow Precedence.xslt", _
                     "filter", _
                     objectType
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub ShowProvisioningPolicyFor(srName)
    DoTransformation gCollectionsFolder & "\Data\Provisioning Policies.xml", _
                     gCollectionsFolder & "\Provisioning Policies.xslt", _
                     "filter", _
                     srName
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub ShowReplicationSchemaFor(objectType)
    DoTransformation gCollectionsFolder & "\Data\Replication Configuration.xml", _
                     gCollectionsFolder & "\Replication Configuration.xslt", _
                     "filter", _
                     objectType
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub GetObjectDefinition (filterVal)
    Dim filterParts, appCmd
    filterParts = Split(filterVal, ":")
    appCmd = "powershell.exe &'" & gOperationsFolder & "\GetObjectDefinitions.ps1" & "' '" & filterParts(2) & "'"
    RenderData appCmd, true
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub RenderData (appCmd, showPs)
    Dim oShell, retVal, retData, showShell
    
    If Not(showPs) Then
       showShell = 0
    Else
       showShell = 4
    End If
          
    Set oShell  = CreateObject("WScript.Shell")
    
    oStatus.innerHtml = MSG_BUSY
    window.document.body.style.cursor = "wait"

    retData = window.clipboarddata.setdata("Text", "")
    retVal  = oShell.Run(appCmd, showShell, true)
    retData = ""
    retData = window.clipboarddata.getdata("Text")

    If(retVal <> 0) Then
       MsgBox "Error: " & retData, vbExclamation, oHTA.ApplicationName 
    Else
       oData.innerHtml = retData    
       MSgBox MSG_SUCC, vbInformation, oHTA.ApplicationName 
    End If
  
    oStatus.innerHtml = MSG_READY
    window.document.body.style.cursor = "default"
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub DoTransformation(xmlFile, xsltFile, paramName, paramValue)
    Dim xmlDoc, xslDoc, oCache, xsltProc
    Set xmlDoc = CreateObject("MSXML2.DOMDocument")
    xmlDoc.async = false
    xmlDoc.load(xmlFile)
    
    Set xslDoc = CreateObject("MSXML2.FreeThreadedDOMDocument.3.0")
    xslDoc.async = false
    xslDoc.Load xsltFile
 
    Set oCache = CreateObject("Msxml2.XSLTemplate.3.0")
    oCache.stylesheet = xslDoc
    
    Set xsltProc = oCache.createProcessor()
    xsltProc.input = xmlDoc
    If(0 < Len(paramName)) Then
       xsltProc.addParameter paramName, paramValue
    End If
   
   xsltProc.transform()
   oData.innerHtml = xsltProc.output
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub GetReportData()
    GetItemData lbReports, lbReportNames, gReportsFolder
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub GetCollectionData()
    GetItemData lbCollection, lbCollectionNames, gCollectionsFolder
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub GetItemData(controlId1, controlId2, folderName)
    Dim oListBox1, appCmd, iRet
    Set oListBox1 = document.getElementById(controlId1)
    
    If(0 > controlId1.selectedIndex) Then
       MsgBox "There is no item selected", vbInformation, oHTA.ApplicationName  
       Exit Sub 
    End If
    
    appCmd = "powershell.exe &'" & _
             folderName & _
             "\" &_
             controlId1.options(controlId1.selectedIndex).text & _
             ".ps1'" 

    oStatus.innerHtml = MSG_BUSY
    window.document.body.style.cursor = "wait"
  
    iRet = GetFimData(appCmd)
    oStatus.innerHtml = MSG_READY
    window.document.body.style.cursor = "default"
     
    GetListControlData controlId2, folderName & "\Data", ".xml"
    
    If(0 = iRet) Then
       MSgBox MSG_SUCC, vbInformation, oHTA.ApplicationName 
    End If   
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub GetAllReports()
     GetAllItemData lbReports, lbReportNames, gReportsFolder
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub GetAllCollectionData()
    GetAllItemData lbCollection, lbCollectionNames, gCollectionsFolder
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub GetAllItemData(lbListSource, lbListTarget, sourceFolder)
    Dim curOption, iRet, appCmd
    
    oStatus.innerHtml = MSG_BUSY
    window.document.body.style.cursor = "wait"

    For Each curOption In lbListSource.Options
       appCmd = "powershell.exe &'" & _
                sourceFolder & _
                "\" & _
                curOption.text & _
                ".ps1'"
    
       iRet = GetFimData(appCmd)
       If(0 <> iRet) Then
          Exit For
       End If 
    Next
        
    oStatus.innerHtml = MSG_READY
    window.document.body.style.cursor = "default"
     
    GetListControlData lbListTarget, sourceFolder & "\Data", ".xml"
    
    If(0 = iRet) Then
       MSgBox MSG_SUCC, vbInformation, oHTA.ApplicationName
    End If    
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Function GetFimData(appCmd)
    Dim retData, oShell

    GetFimData = FimCheck()
    If(GetFimData <> 0) Then
       Exit Function
    End If
    
    GetFimData = HtaCheck()
    If(GetFimData <> 0) Then
       Exit Function
    End If

    Set oShell  = CreateObject("WScript.Shell")
    GetFimData  = oShell.Run(appCmd, 4, true)
    retData = window.clipboarddata.getdata("Text")

    If(GetFimData <> 0) Then
       MsgBox "Error: " & retData, vbExclamation, oHTA.ApplicationName 
    End If
 End Function
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub GetListControlData(oControl, folderPath, fileSuffix)
    Dim oOption, curItem
    For Each oOption In oControl.options
       oControl.options.Remove(0)
    Next    
    
    Dim oFso, oFolder, oFile
    Set oFso    = CreateObject("Scripting.FileSystemObject")
    Set oFolder = oFso.GetFolder(folderPath)
    
    For Each oFile In oFolder.Files
       If(0 = StrComp(Right(LCase(oFile.Name), 4), fileSuffix)) Then
          Set oOption = document.createElement("OPTION")
          oControl.options.add(oOption)
          oOption.innerText = Left(oFile.Name, Len(oFile.Name) - 4)
          oOption.value     = oFile.Path
       End If   
    Next

    If(0 < oControl.length) Then
      oControl.selectedIndex = 0   
    End If 
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub ShowReport
    If(0 > lbReportNames.selectedIndex) Then
       MsgBox "No list item selected", vbInformation, oHTA.ApplicationName
       Exit Sub
    End If
  
    DoTransformation lbReportNames.options(lbReportNames.selectedIndex).value, _
                     gReportsFolder & lbReportNames.options(lbReportNames.selectedIndex).text & ".xslt", _
                     "", _
                     ""

 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub GetResourceData()
    Dim nameType
    If(group1(0).checked) Then
       nameType = 0 
    Else
       nameType = 1 
    End If
 
    Dim resourceName
    resourceName = InputBox ("Resource Name", "Get Resource By Name")
    If(0 = Len(resourceName)) Then   
       Exit Sub
    End If

    Dim oShell, scriptName, appCmd, retVal, retData
    Set oShell = CreateObject("WScript.Shell")
 
    oStatus.innerHtml = MSG_BUSY 
    window.document.body.style.cursor = "wait"

    scriptName = gOperationsFolder & "\GetResourceByName.ps1"
    appCmd     = "powershell &'" & scriptName & "' '" & resourceName & "' '" & nameType & "'"
    retVal     = oShell.Run(appCmd, 4, true)
    retData    = window.clipboarddata.getdata("Text")
    
    If(retVal <> 0) Then
       MsgBox "Error: " & retData, vbExclamation, oHTA.ApplicationName 
    Else
       ShowData()
    End If
    window.document.body.style.cursor = "default"
    oStatus.innerHtml = MSG_READY
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
 Sub ShowData()
    DoTransformation gOperationsFolder & "\GetResourceByName.xml", gOperationsFolder & "\GetResourceByName.xslt", "", ""
 End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------
