<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ms="urn:schemas-microsoft-com:xslt"
                xmlns:dsml="http://www.dsml.org/DSML"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:my="http://schemas.microsoft.com/2006/11/ResourceManagement"
                xmlns:xd="http://schemas.microsoft.com/office/infopath/2003">
  <!--===================================================================================================================================-->
  <!-- Library Functions                                                                                                   -->
  <!--===================================================================================================================================-->
  <ms:script language="JScript" implements-prefix="dsml">
    <![CDATA[

function ToLowerCase(origVal){
  return origVal.toLowerCase();
}

function ReplaceString(origVal, fromVal, toVal){
  var result = "";
  var str = "";
  for (str in origVal.split(fromVal)){
    if (result.length > 0){
      result+=toVal;
    }
    result += origVal.split(fromVal)[str];
  }
  return result.toString();
}

function GetDateTimeExpr(dateTimeString){

  var result = "";
  if(dateTimeString != null){
    var d = new Date(dateTimeString);
    //result = d.toString();
    var year = d.getFullYear().toString();
    var month = d.getMonth().toString();
    var day = d.getDay().toString();
    var hours = d.getHours().toString();
    var minutes = d.getMinutes().toString();
    var seconds = d.getSeconds().toString();
    result = year;
    result += ("0" + month).slice(2-month.length);
    result += ("0" + day).slice(2-day.length);
    result += "T";
    result += ("0" + hours).slice(2-hours.length);
    result += ("0" + minutes).slice(2-minutes.length);
    result += ("0" + seconds).slice(2-seconds.length);
  }
  return result.toString();
}

function GetTextFromXmlText(escapedXml){
  var result = ""; //"Unable to load xml: " + escapedXml;
  if (escapedXml != null)
  {
    var xmlDoc = new ActiveXObject("MSXML2.DOMDocument.6.0"); //.6.0
    var xmlDocInner = new ActiveXObject("MSXML2.DOMDocument.6.0"); //.6.0
    xmlDoc.async = false;
    var xmlNod = xmlDoc.appendChild(xmlDoc.createElement("xml"));
    xmlNod.text = escapedXml;
    xmlDocInner.loadXML(xmlDoc.documentElement.text);
    result = xmlDocInner.documentElement.text;
  }
  return result;
}

function GetXmlFromXmlText(escapedXml, ns){
  var result = ""; //"Unable to load xml: " + escapedXml;
  if (escapedXml != null)
  {
    var xmlDoc = new ActiveXObject("MSXML2.DOMDocument.6.0"); //.6.0
    var xmlDocInner = new ActiveXObject("MSXML2.DOMDocument.6.0"); //.6.0
    xmlDoc.async = false;
    if (ns != null){
      xmlDoc.setProperty("SelectionNamespaces", ns);
    }
    var xmlNod = xmlDoc.appendChild(xmlDoc.createElement("xml"));
    xmlNod.text = escapedXml;
    xmlDocInner.loadXML(xmlDoc.documentElement.text);
    result = xmlDocInner.documentElement.text;
  }
  return result;
}

function GetNodeListFromText(escapedXml, xpath, ns){

	var xmlNodChild;
  var result = "Unable to load xml: " + escapedXml;
	var xmlDocOut = new ActiveXObject("MSXML2.DOMDocument.6.0");
	xmlDocOut.async = false;
  xmlDocOut.loadXML("<xml><root/></xml>");
	var xmlDoc = new ActiveXObject("MSXML2.DOMDocument.6.0");
	xmlDoc.async = false;
	var stylePI = xmlDoc.createProcessingInstruction("xml", "version='1.0' encoding='UTF-8'");
	xmlDoc.appendChild(stylePI);
  var xmlNod = xmlDoc.appendChild(xmlDoc.createElement("xml"));
  xmlDoc.loadXML(escapedXml);
  if (ns != null){
    xmlDoc.setProperty("SelectionNamespaces", ns);
  }
  result = "Unable to perform query: " + xpath;
  var nodesToAppend = xmlDoc.selectNodes(xpath);
  if (nodesToAppend != null){
    for (xmlNodChild in nodesToAppend){
      xmlNod = xmlDocOut.documentElement.appendChild(xmlDocOut.createElement(xmlNodChild.nodeName));
      xmlNod.text = xmlNodChild.text;
    }
    result = xmlDoc.documentElement.xml;
  }
  return result;
}

]]>
  </ms:script>
</xsl:stylesheet>