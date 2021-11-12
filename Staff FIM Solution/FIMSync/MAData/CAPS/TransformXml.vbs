Option Explicit

Sub DoTransformation(xmlFile, xsltFile, paramName, paramValue, outputFile)

	Dim xmlDoc, xslDoc, oCache, xsltProc, objFSO, objTextStream

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

	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objTextStream = objFSO.CreateTextFile(outputFile, True)
	Call objTextStream.Write(xsltProc.output)
	Call objTextStream.Close
    
	Set xmlDoc = Nothing
	Set xslDoc = Nothing
	Set oCache = Nothing
	Set xsltProc = Nothing
	Set objFSO = Nothing

End Sub

DoTransformation "AVPInput.xml", "XmlToLDIF.CAPS.xslt", "", "", "capsData.ldif"
