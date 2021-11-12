<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt" xmlns:dsml="http://www.dsml.org/DSML" xmlns:fn="http://www.w3.org/2005/xpath-functions">
  <!--===================================================================================================================================-->
  <!-- Library Functions                                                                                                   -->
  <!--===================================================================================================================================-->
  <ms:script language='VBScript' implements-prefix="dsml">
    <![CDATA[
    
'Option Explicit

Function GetDateTimeExpr(ByVal dateTimeString)

  Dim d
  On Error Resume Next
  GetDateTimeExpr = ""
  If Len(dateTimeString) > 0 Then
    d = CDate(dateTimeString)
    GetDateTimeExpr = Right("0000" & Year(d),4) & Right("00" & Month(d),2) & Right("00" & Day(d),2)
    GetDateTimeExpr = GetDateTimeExpr & "T" & Right("00" & Hour(d),2) & Right("00" & Minute(d),2) & Right("00" & Second(d),2)
  End If
  If Len(Err.Description) > 0 Then
    GetDateTimeExpr = Err.Description
    Err.Clear
  End If

End Function

Function GetGroupName(ByVal groupGuid)

  GetGroupName = groupGuid
  
	Const conRootXPath = "//GroupConfigurations/Group[translate(@id, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='" ' As String
	Const conXPathTrailer = "']" ' As String
  Const DATA_PATH = ".\Data\Unify.Product.EventBroker.GroupEnginePlugInKey.extensibility.config.xml"
  
  GetGroupName = GetNodeName(DATA_PATH, conRootXPath & LCase(groupGuid) & conXPathTrailer, "@name")

End Function

Function GetConnectorName(ByVal groupGuid)

  GetConnectorName = groupGuid
  
	Const conRootXPath = "//connector[translate(@id, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='" ' As String
	Const conXPathTrailer = "']" ' As String
  Const DATA_PATH = ".\Data\Unify.Product.IdentityBroker.ConnectorEnginePlugInKey.extensibility.config.xml"
  
  GetConnectorName = GetNodeName(DATA_PATH, conRootXPath & LCase(groupGuid) & conXPathTrailer, "@name")

End Function

Function GetAgentName(ByVal groupGuid)

  GetAgentName = groupGuid
  
	Const conRootXPath = "//Agent[translate(@id, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='" ' As String
	Const conXPathTrailer = "']" ' As String
  Const DATA_PATH = ".\Data\Unify.Product.EventBroker.AgentEnginePlugInKey.extensibility.config.xml"
  
  GetAgentName = GetNodeName(DATA_PATH, conRootXPath & LCase(groupGuid) & conXPathTrailer, "@name")

End Function

Function GetIdBAgentName(ByVal groupGuid)

  GetIdBAgentName = groupGuid
  
	Const conRootXPath = "//Agent[translate(@id, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='" ' As String
	Const conXPathTrailer = "']" ' As String
  Const DATA_PATH = ".\Data\Unify.Product.IdentityBroker.AgentEnginePlugInKey.extensibility.config.xml"
  
  GetIdBAgentName = GetNodeName(DATA_PATH, conRootXPath & LCase(groupGuid) & conXPathTrailer, "@name")

End Function

Function GetAdapterName(ByVal groupGuid)

  GetAdapterName = groupGuid
  
	Const conRootXPath = "//*[translate(@AdapterId, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='" ' As String
	Const conXPathTrailer = "']" ' As String
  Const DATA_PATH = ".\Data\Unify.Product.IdentityBroker.AdapterEnginePlugInKey.extensibility.config.xml"
  
  GetAdapterName = GetNodeName(DATA_PATH, conRootXPath & LCase(groupGuid) & conXPathTrailer, "@AdapterName")

End Function

Function GetNodeName(ByVal xmlPath, ByVal xPathQuery, ByVal eltName)

	Dim xmlDoc 'As MSXML2.DOMDocument30
	Dim xmlNod 'As MSXML2.IXMLDOMNode

  GetNodeName = "Unable to load file: " & xmlPath
	Set xmlDoc = CreateObject("MSXML2.DOMDocument")
	xmlDoc.async = False
  If xmlDoc.Load(xmlPath) Then
    GetNodeName = "Unable to read element: " & xPathQuery
		Set xmlNod = xmlDoc.documentElement.selectSingleNode(xPathQuery)
		If Not xmlNod Is Nothing Then
		    GetNodeName = xmlNod.selectSingleNode(eltName).Text
		End If
  End If
  Set xmlNod = Nothing
  Set xmlDoc = Nothing

End Function

Function TimeFromDuration(ByVal duration)
  TimeFromDuration = ""
  ' e.g. PT30S = 30 seconds, PR5H2M30S = 5 hours 2 minutes 30 seconds

  Dim durationTime, durationHours, durationMinutes, durationSeconds, resultText

  duration = "PT30S"
  resultText = ""
  durationHours = 0
  durationMinutes = 0
  durationSeconds = 0
  durationTime = Replace(duration,"PT","")
  If InStr(durationTime,"H") > 0 Then
    durationHours = Split(durationTime,"H")(0)
'    resultText = CStr(durationHours) & " hrs"
    durationTime = Split(durationTime,"H")(1)
  End If
  resultText = Right("00" & CStr(durationHours),2)
  If InStr(durationTime,"M") > 0 Then
    durationMinutes = Split(durationTime,"M")(0)
'    If Len(resultText) > 0 Then
'      resultText = resultText & ", " & CStr(durationMinutes) & " mins"
'    Else
'      resultText = CStr(durationMinutes) & " mins"
'    End If
    durationTime = Split(durationTime,"M")(1)
  End If
  resultText = resultText & ":" & Right("00" & CStr(durationMinutes),2)
  If InStr(durationTime,"S") > 0 Then
    durationSeconds = Split(durationTime,"S")(0)
'    If Len(resultText) > 0 Then
'      resultText = resultText & ", " & CStr(durationSeconds) & " secs"
'    Else
'      resultText = CStr(durationSeconds) & " secs"
'    End If
    durationTime = Split(durationTime,"S")(1)
  End If
  resultText = resultText & ":" & Right("00" & CStr(durationSeconds),2)
  TimeFromDuration = resultText
  
End Function

Function ReplaceString(ByVal origVal, ByVal fromVal, ByVal toVal)

	ReplaceString = Replace(origVal, fromVal, toVal)

End Function

Function GetTextFromXmlText(ByVal escapedXml)

	Dim xmlDoc 'As MSXML2.DOMDocument30
	Dim xmlNod 'As MSXML2.IXMLDOMNode

  GetTextFromXmlText = "" '"Unable to load xml: " & escapedXml
	xmlDoc = CreateObject("MSXML2.DOMDocument.6.0")
	xmlDocInner = CreateObject("MSXML2.DOMDocument.6.0")
	xmlDoc.async = False
  xmlNod = xmlDoc.appendChild(xmlDoc.createElement("xml"))
  xmlNod.text = escapedXml
  'xmlDocInner.loadXML(xmlDoc.documentElement.text)
  'GetTextFromXmlText = xmlDocInner.documentElement.text
  GetTextFromXmlText = xmlNod.firstChild.text

  xmlNod = Nothing
  xmlDoc = Nothing
  xmlDocInner = Nothing

End Function

Function GetXMLFromText(ByVal escapedXml)

	Dim xmlDoc 'As MSXML2.DOMDocument30
	Dim xmlNod 'As MSXML2.IXMLDOMNode

  GetXMLFromText = "Unable to load xml: " & escapedXml
	Set xmlDoc = CreateObject("MSXML2.DOMDocument")
	xmlDoc.async = False
  Set xmlNod = xmlDoc.appendChild(xmlDoc.createElement("xml"))
  xmlNod.text = escapedXml
  GetXMLFromText = xmlNod.firstChild.xml

  Set xmlNod = Nothing
  Set xmlDoc = Nothing

End Function

Function GetNodeListFromText(ByVal escapedXml, ByVal xpath, ByVal ns)

	Dim xmlDoc 'As MSXML2.DOMDocument30
	Dim xmlDocOut 'As MSXML2.DOMDocument30
	Dim xmlNod 'As MSXML2.IXMLDOMNode
	Dim xmlNodChild 'As MSXML2.IXMLDOMNode
  Dim stylePI 'processing instruction

  GetNodeListFromText = "Unable to load xml: " & escapedXml
	Set xmlDocOut = CreateObject("MSXML2.DOMDocument")
	xmlDocOut.async = False
  xmlDocOut.loadXml("<xml><root/></xml>")
  
	Set xmlDoc = CreateObject("MSXML2.DOMDocument")
	xmlDoc.async = False
	Set stylePI = xmlDoc.createProcessingInstruction("xml", "version=""1.0""  encoding=""UTF-8""")
	xmlDoc.appendChild(stylePI)
  Set xmlNod = xmlDoc.appendChild(xmlDoc.createElement("xml"))
  xmlDoc.loadXml(escapedXml)
  'xmlNod.text = escapedXml
  If Not Len(ns) = 0 Then
    Call xmlDoc.setProperty("SelectionNamespaces", ns)
  End If
  GetNodeListFromText = "Unable to perform query: " & xpath
  If Not xmlDoc.selectNodes(xpath) Is Nothing Then
    For Each xmlNodChild in xmlDoc.selectNodes(xpath)
      Set xmlNod = xmlDocOut.documentElement.appendChild(xmlDocOut.createElement(xmlNodChild.nodeName))
      xmlNod.text = xmlNodChild.text
    Next
    GetNodeListFromText = xmlDoc.documentElement.xml
  End If

  Set xmlNod = Nothing
  Set xmlNod = Nothing
  Set xmlNodChild = Nothing
  Set stylePI = Nothing
  Set xmlDocOut = Nothing

End Function

]]>
  </ms:script>
</xsl:stylesheet>