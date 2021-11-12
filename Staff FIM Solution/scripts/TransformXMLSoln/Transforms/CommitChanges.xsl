<?xml version="1.0" encoding="UTF-8" ?>
<!--

Copyright (c) 2010  Bob Bradley. All Rights Reserved.

The SyncPolicy.ps1 FIM script generates a consolidated XML file of the portal changes that will be applied on
when the CommitChanges.ps1 script is applied.  This stylesheet transforms this XML
to visually present these changes, rendering the XML in a neat formatted HTML file via IE.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns="http://www.w3.org/1999/xhtml"
	xmlns:ms-dsml="http://www.microsoft.com/MMS/DSML" xmlns:dsml="http://www.dsml.org/DSML" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" indent="yes" omit-xml-declaration="no" />
	<xsl:template match="/">
		<html>
			<basefont face="tahoma" size="1" />
			<head>
				<xsl:call-template name="installScript" />
			</head>
			<xsl:call-template name="applyStyles" />
			<body>
				<xsl:variable name="changesCount" select="count(Results/ImportObject[SourceObjectIdentifier])" />
				<DIV class="c1">
					<xsl:choose>
						<xsl:when test="$changesCount='0'">
							<h4>No changes found for this file</h4>
						</xsl:when>
						<xsl:otherwise>
							<h4>Pending FIM Portal Changes</h4>
							<table border="0" class="tableClass2">
								<thead>
									<tr class="thImportObject">
										<th>Change#</th>
										<th>Name</th>
										<th>Join On</th>
										<!--<th>Object Type</th>-->
										<th>State</th>
										<th>Changes</th>
									</tr>
								</thead>
								<tbody>
									<xsl:apply-templates select="Results/ImportObject[SourceObjectIdentifier]" mode="summary">
										<!--<xsl:sort select="Changes/ImportChange[AttributeName='DisplayName']/AttributeValue" order="ascending" data-type="text" />-->
										<xsl:sort select="ObjectType" order="ascending" data-type="text" />
										<xsl:sort select="AnchorPairs/JoinPair/AttributeValue" order="ascending" data-type="text" />
										<xsl:sort select="State" order="ascending" data-type="text" />
									</xsl:apply-templates>
								</tbody>
							</table>
						</xsl:otherwise>
					</xsl:choose>
				</DIV>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="ImportObject" mode="summary">
		<tr>
			<th class="tdLeftSection" colspan="4">
				<xsl:value-of select="ObjectType" />
			</th>
		</tr>
		<tr>
			<td class="tdLeftSection">
				<xsl:value-of select="position()" />
			</td>
			<td class="tdHeader">
				<xsl:choose>
					<xsl:when test="Changes/ImportChange">
						<a>
							<xsl:attribute name="href">
							<xsl:text>javascript: toggleDiv('tr_</xsl:text>
							<xsl:value-of select="position()" />
							<xsl:text>');</xsl:text>
							</xsl:attribute>
							<xsl:value-of select="AnchorPairs/JoinPair/AttributeValue" />
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="AnchorPairs/JoinPair/AttributeValue" />
					</xsl:otherwise>
				</xsl:choose>
				<!--<xsl:value-of select="Changes/ImportChange[AttributeName='DisplayName']/AttributeValue" />-->
			</td>
			<td class="tdValue">
				<xsl:value-of select="AnchorPairs/JoinPair/AttributeName" />
			</td>
			<td class="tdValue">
				<xsl:value-of select="State" />
			</td>
			<td class="tdValue">
				<xsl:choose>
					<xsl:when test="Changes/ImportChange">
								<table border="0" class="tableClass2">
									<thead>
										<tr class="thImportObject">
											<th>Attribute Name</th>
											<th>Operation</th>
											<th>Attribute Value</th>
											<th>Fully Resolved</th>
										</tr>
									</thead>
									<tbody>
										<xsl:apply-templates select="Changes/ImportChange" mode="summary">
											<xsl:with-param name="id" select="position()" /><!-- AnchorPairs/JoinPair/AttributeName" -->
											<xsl:sort select="AttributeName" order="ascending" data-type="text" />
										</xsl:apply-templates>
									</tbody>
								</table>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text disable-output-escaping="yes">No Changes</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<!--
			<td class="tdValue">
				<a>
					<xsl:attribute name="href">
						<xsl:text>javascript: toggleDiv('tr_</xsl:text>
						<xsl:value-of select="../ma-id" />
						<xsl:text>_</xsl:text>
						<xsl:value-of select="@step-id" />
						<xsl:text>');</xsl:text>
					</xsl:attribute>
					<xsl:value-of select="step-result/text()" />
				</a>
			</td>
			<xsl:choose>
				<xsl:when test="step-result/text()='completed-transient-objects'">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="ma-id" select="../ma-id" />
						<xsl:with-param name="step-id" select="@step-id" />
						<xsl:with-param name="errorText">
							<xsl:apply-templates select="ma-connection" mode="transient" />
						</xsl:with-param>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="synchronization-errors/import-error">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="ma-id" select="../ma-id" />
						<xsl:with-param name="step-id" select="@step-id" />
						<xsl:with-param name="errorText">
							<xsl:if test="ma-connection/connection-result[text()!='success']">
								<xsl:apply-templates select="ma-connection/connection-log/incident" />
								<xsl:text>;
								</xsl:text>
							</xsl:if>
							<xsl:for-each select="synchronization-errors/import-error">
								<xsl:call-template name="importExportError">
									<xsl:with-param name="dn" select="@dn" />
									<xsl:with-param name="error-type" select="error-type" />
									<xsl:with-param name="date-occurred" select="date-occurred" />
									<xsl:with-param name="retry-count" select="retry-count" />
								</xsl:call-template>
							</xsl:for-each>
						</xsl:with-param>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="synchronization-errors/export-error">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="ma-id" select="../ma-id" />
						<xsl:with-param name="step-id" select="@step-id" />
						<xsl:with-param name="errorText">
							<xsl:if test="ma-connection/connection-result[text()!='success']">
								<xsl:apply-templates select="ma-connection/connection-log/incident" />
								<xsl:text>;
								</xsl:text>
							</xsl:if>
							<xsl:for-each select="synchronization-errors/import-error">
								<xsl:call-template name="importExportError">
									<xsl:with-param name="dn" select="@dn" />
									<xsl:with-param name="error-type" select="error-type" />
									<xsl:with-param name="date-occurred" select="date-occurred" />
									<xsl:with-param name="retry-count" select="retry-count" />
								</xsl:call-template>
							</xsl:for-each>
						</xsl:with-param>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="ma-connection/connection-result[text()!='success']">
					<xsl:apply-templates select="." mode="error">
						<xsl:with-param name="ma-id" select="../ma-id" />
						<xsl:with-param name="step-id" select="@step-id" />
						<xsl:with-param name="errorText">
							<xsl:apply-templates select="ma-connection/connection-log/incident" />
						</xsl:with-param>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
			-->
		</tr>
	</xsl:template>
	<xsl:template match="ImportChange" mode="summary">
		<xsl:param name="id" />
		<tr class="trImportChange" id="tr_{$id}">
			<xsl:attribute name="style">
				<xsl:text>display: none; visibility: hidden</xsl:text>
			</xsl:attribute>
			<td class="tdLeftSection">
				<xsl:value-of select="AttributeName" />
			</td>
			<td class="tdValue">
				<xsl:value-of select="Operation" />
			</td>
			<td class="tdValue">
				<xsl:value-of select="AttributeValue" />
			</td>
			<td class="tdValue">
				<xsl:value-of select="FullyResolved" />
			</td>
		</tr>
	</xsl:template>
	<!--
	<xsl:template match="ma-connection" mode="transient">
		<xsl:text>Connection Result:</xsl:text>
		<xsl:value-of select="connection-result" />
		<xsl:text>; Date:</xsl:text>
		<xsl:value-of select="connection-log/incident/date" />
		<xsl:text>; Server:</xsl:text>
		<xsl:value-of select="server" />
		<xsl:text>; Step:</xsl:text>
		<xsl:value-of select="../step-description/step-type/@type" />
	</xsl:template>
	<xsl:template name="importExportError">
		<xsl:param name="dn" />
		<xsl:param name="error-type" />
		<xsl:param name="date-occurred" />
		<xsl:param name="retry-count" />
		<xsl:text>DN:</xsl:text>
		<xsl:value-of select="$dn" />
		<xsl:text>; Type:</xsl:text>
		<xsl:value-of select="$error-type" />
		<xsl:text>; Date:</xsl:text>
		<xsl:value-of select="$date-occurred" />
		<xsl:text>; Retries:</xsl:text>
		<xsl:value-of select="$retry-count" />
	</xsl:template>
	-->
	<xsl:template name="installScript">
		<script type="text/javascript" language="JavaScript"><![CDATA[
			//<!--
//Works the same way as VB
function trim(vstrString)
{
	return vstrString.replace(/(^\s*)|(\s*$)/g, "");
}

//The following two functions are for use with selectable table rows
function TR_WhenMouseOver(robjRow)
{
	robjRow.style.cursor = "hand";
	robjRow.className="CellSelected";
	window.status='Click to select the Row...';
	return true;
}

function TR_WhenMouseOut(robjRow)
{
	robjRow.style.cursor = "";
	robjRow.className="Cell";
	window.status='';
	return true;
}

function toggleDiv2(vobjId)
{
	alert(vobjId);
}

function toggleDiv(vobjId)
{
	var key;
	var i = 0;
	var varrTr = document.all(vobjId);
	if ( varrTr != null )
	{
		if ( typeof(varrTr.length) == 'undefined' ) {
				if (varrTr.style.display == 'none')
				{
					varrTr.style.display = 'block';
					varrTr.style.visibility = 'visible';
				}
				else
				{
					varrTr.style.display = 'block';
					varrTr.style.display = 'none';
					varrTr.style.visibility = 'hidden';
				}
		}
		else
		{
			while (i != varrTr.length) {
				//alert(varrTr[i].style.display);
				if (varrTr[i].style.display == 'none')
				{
					varrTr[i].style.display = 'block';
					varrTr[i].style.visibility = 'visible';
				}
				else
				{
					varrTr[i].style.display = 'block';
					varrTr[i].style.display = 'none';
					varrTr[i].style.visibility = 'hidden';
				}
				i += 1;
			}
		}
	}
}
			//-->
			]]>
			</script>
	</xsl:template>
	<xsl:template name="applyStyles">
		<STYLE type="text/css">
       @page FullPage{margin-left:1.0in;margin-right:0.5in}

        h1,h3{margin: 0px; padding: 0px;}
        #S1 {width: 300px;}
        h1 {color: #AAAAAA; font-size: 500%;}
        h3 {color: #AAAAAA; font-size: 200%;}
               
        
        .thImportObject{background-color:#bbbbbb;  FONT-SIZE: 90%;}
        .thImportObject1{background-color:#dddddd; FONT-SIZE: 70%;}
        .thImportObject2{background-color:#dddddd; FONT-SIZE: 70%; width:50px}

        .tableMenu{FONT-SIZE: 300%; FONT-FAMILY: Verdana;  width:575px}
        .tdMenu{border-right: 1px solid #999999;text-align:center;}
        .trMenu{background-color:#ffffff;}
        .trImportChange{background-color:#eeeeee;}
        .tdValue{FONT-SIZE: 60%; FONT-FAMILY: Verdana;word-wrap: break-word;}
        .tdHeader{FONT-SIZE: 60%; FONT-FAMILY: Verdana;word-wrap: break-word;}

        .tableClass2{cellspacing:'0' cellpadding:'0'; border='1'; width:100% FONT-SIZE: 80%; FONT-FAMILY: Verdana;  border-color: #eeeeee; border-style:solid; PADDING: .25em;}
        .tableClass3{width:50px;}
        .tableClass4{width:575px;vertical-align:left}
        .tableClass5{vertical-align:middle; width:375px}
        .tdLeftSection{background-color:#eeeeee; FONT-SIZE: 70%; text-align:center;}
        

        A{color:#0000FF; text-decoration: none;}
        a:active {text-decoration: underline;}
        a:hover {text-decoration: underline;}
        img {border: none; }
        .imgbanner {border: none; width:10px;}
        .my .ct p {padding: 0px 0px 3px 0px;}
        #btnsearch {border: none; margin-left: 95px; margin-top: -25px;}
        body,div,span,p,ul,td,th,input,select,textarea,button {font-family: Arial, sans-serif; font-size: 70%;}
        td{font-size: 70%;word-wrap:break-word;}


        .tdClass1{font-size: 70%; width:400px; word-wrap:break-word;}
        .tdClass2{font-size: 70%; width:350px; word-wrap:break-word;}
        .tdClass3{font-size: 70%; width:175px; word-wrap:break-word;}
        .tdClass4{font-size: 70%; width:20px; word-wrap:break-word;}
        .tdClass5{font-size: 70%; width:350px; word-wrap:break-word;}
        .tdClass6{font-family: Symbol;font-size: 70%; color:blue; text-align:center; width:8%;}
        .tdClass7{font-size: 70%; word-wrap:break-word; width:350px;}

        body {page:FullPage;}
        br.clear, .clrbth {clear: both;}
        hr {height: 1px; padding: 0px; border:1px solid; color:#BBBBBB; }
        ol {list-style-position: outside; margin: -2px 0px 0px 23px;}
        li {list-style-position: outside; margin: -2px 0px 0px 12px; padding: 0; margin-left: 20px;}      
       </STYLE>
	</xsl:template>
</xsl:stylesheet>
