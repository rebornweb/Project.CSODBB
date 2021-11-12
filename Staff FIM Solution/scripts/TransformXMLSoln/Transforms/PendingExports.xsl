<?xml version="1.0" encoding="utf-8" ?>
<!--

Copyright (c) 2010  Bob Bradley. All Rights Reserved.

An optional by-product of a FIM/ILM run profile is an "audit drop file".  This stylesheet transforms this XML
to visually present these changes, rendering the XML in a neat formatted HTML file via IE.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:a="http://www.microsoft.com/mms/mmsml/v2"
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
				<xsl:variable name="changesCount" select="count(a:mmsml/a:directory-entries/a:delta)" />
				<DIV class="c1">
					<xsl:choose>
						<xsl:when test="$changesCount='0'">
							<h4>No changes found for this file</h4>
						</xsl:when>
						<xsl:otherwise>
							<h4>Pending Exports</h4>
							<table border="0" class="tableClass2">
								<thead>
									<tr class="thImportObject">
                    <th>Group</th>
                    <th>Change#</th>
                    <th>AttrName</th>
                    <th>DeltaOp</th>
                    <th>DNAOp</th>
                    <th>DNVOp</th>
                    <th>ObjectDN</th>
                    <th>dn</th>
                    <th>AttrType</th>
                    <th>AttrMV</th>
                    <th>AttrValDel</th>
                    <th>AttrValAdd</th>
                    <th>AttrValNew</th>
									</tr>
								</thead>
								<tbody>
									<xsl:apply-templates select="a:mmsml/a:directory-entries/a:delta/a:dn-attr/a:dn-value/a:dn" mode="reference">
										<xsl:sort select="../../../@dn" order="ascending" data-type="text" />
									</xsl:apply-templates>
                  <xsl:apply-templates select="a:mmsml/a:directory-entries/a:delta[not(a:attr)][a:anchor][@operation='delete']" mode="deletes">
                    <xsl:sort select="@dn" order="ascending" data-type="text" />
                  </xsl:apply-templates>
                  <xsl:apply-templates select="a:mmsml/a:directory-entries/a:delta/a:dn-attr[not(a:dn-value)][@operation='delete']" mode="deletes">
                    <xsl:sort select="../@dn" order="ascending" data-type="text" />
                  </xsl:apply-templates>
                  <xsl:apply-templates select="a:mmsml/a:directory-entries/a:delta/a:attr[@operation='delete']" mode="deletes">
                    <xsl:sort select="../@dn" order="ascending" data-type="text" />
                  </xsl:apply-templates>
                  <xsl:apply-templates select="a:mmsml/a:directory-entries/a:delta/a:attr/a:value" mode="changes">
                    <xsl:sort select="../../@dn" order="ascending" data-type="text" />
                  </xsl:apply-templates>
                </tbody>
							</table>
						</xsl:otherwise>
					</xsl:choose>
				</DIV>
			</body>
		</html>
  </xsl:template>
  <xsl:template match="a:value" mode="changes">
    <tr>
      <!-- Group -->
      <td class="tdLeftSection">
        non-reference attribute changes
      </td>
      <!-- Change# -->
      <td class="tdLeftSection">
        <xsl:value-of select="position()" />
      </td>
      <!-- AttrName -->
      <td class="tdValue">
        <xsl:value-of select="../@name" />
      </td>
      <!-- DeltaOp -->
      <td class="tdValue">
        <xsl:value-of select="../../@operation" />
      </td>
      <!-- DNAOp -->
      <td class="tdValue">
        <xsl:value-of select="../@operation" />
      </td>
      <!-- DNVOp -->
      <td class="tdValue">
      </td>
      <!-- ObjectDN -->
      <td class="tdValue">
        <xsl:value-of select="../../@dn" />
      </td>
      <!-- dn -->
      <td class="tdValue">
      </td>
      <!-- AttrType -->
      <td class="tdValue">
        <xsl:value-of select="../@type" />
      </td>
      <!-- AttrMV -->
      <td class="tdValue">
        <xsl:value-of select="../@multivalued" />
      </td>
      <!-- AttrValDel -->
      <td class="tdValue">
        <xsl:value-of select="text()[@operation='delete']" />
      </td>
      <!-- AttrValAdd -->
      <td class="tdValue">
        <xsl:value-of select="text()[@operation='add']" />
      </td>
      <!-- AttrValNew -->
      <td class="tdValue">
        <xsl:value-of select="text()[not(@operation)]" />
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="a:attr" mode="deletes">
    <tr>
      <!-- Group -->
      <td class="tdLeftSection">
        non-reference attribute delete
      </td>
      <!-- Change# -->
      <td class="tdLeftSection">
        <xsl:value-of select="position()" />
      </td>
      <!-- AttrName -->
      <td class="tdValue">
        <xsl:value-of select="@name" />
      </td>
      <!-- DeltaOp -->
      <td class="tdValue">
        delete
      </td>
      <!-- DNAOp -->
      <td class="tdValue">
        <xsl:value-of select="@operation" />
      </td>
      <!-- DNVOp -->
      <td class="tdValue">
      </td>
      <!-- ObjectDN -->
      <td class="tdValue">
        <xsl:value-of select="../@dn" />
      </td>
      <!-- dn -->
      <td class="tdValue">
      </td>
      <!-- AttrType -->
      <td class="tdValue">
        <xsl:value-of select="@type" />
      </td>
      <!-- AttrMV -->
      <td class="tdValue">
        <xsl:value-of select="@multivalued" />
      </td>
      <!-- AttrValDel -->
      <td class="tdValue">
      </td>
      <!-- AttrValAdd -->
      <td class="tdValue">
      </td>
      <!-- AttrValNew -->
      <td class="tdValue">
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="a:dn-attr" mode="deletes">
    <tr>
      <!-- Group -->
      <td class="tdLeftSection">
        multivalue attribute collection delete
      </td>
      <!-- Change# -->
      <td class="tdLeftSection">
        <xsl:value-of select="position()" />
      </td>
      <!-- AttrName -->
      <td class="tdValue">
        <xsl:value-of select="@name" />
      </td>
      <!-- DeltaOp -->
      <td class="tdValue">
        delete
      </td>
      <!-- DNAOp -->
      <td class="tdValue">
        <xsl:value-of select="@operation" />
      </td>
      <!-- DNVOp -->
      <td class="tdValue">
      </td>
      <!-- ObjectDN -->
      <td class="tdValue">
        <xsl:value-of select="../@dn" />
      </td>
      <!-- dn -->
      <td class="tdValue">
      </td>
      <!-- AttrType -->
      <td class="tdValue">
        <xsl:value-of select="@type" />
      </td>
      <!-- AttrMV -->
      <td class="tdValue">
        <xsl:value-of select="@multivalued" />
      </td>
      <!-- AttrValDel -->
      <td class="tdValue">
      </td>
      <!-- AttrValAdd -->
      <td class="tdValue">
      </td>
      <!-- AttrValNew -->
      <td class="tdValue">
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="a:dn" mode="reference">
    <tr>
      <!-- Group -->
      <td class="tdLeftSection">
        reference attribute change
      </td>
      <!-- Change# -->
      <td class="tdLeftSection">
				<xsl:value-of select="position()" />
			</td>
      <!-- AttrName -->
      <td class="tdValue">
        <xsl:value-of select="../../@name" />
      </td>
      <!-- DeltaOp -->
      <td class="tdValue">
        <xsl:value-of select="../../../@operation" />
      </td>
      <!-- DNAOp -->
      <td class="tdValue">
        <xsl:value-of select="../../@operation" />
      </td>
      <!-- DNVOp -->
      <td class="tdValue">
        <xsl:value-of select="../@operation" />
      </td>
      <!-- ObjectDN -->
      <td class="tdValue">
        <xsl:value-of select="../../../@dn" />
      </td>
      <!-- dn -->
      <td class="tdValue">
        <xsl:value-of select="." />
      </td>
      <!-- AttrType -->
      <td class="tdValue">
      </td>
      <!-- AttrMV -->
      <td class="tdValue">
      </td>
      <!-- AttrValDel -->
      <td class="tdValue">
      </td>
      <!-- AttrValAdd -->
      <td class="tdValue">
      </td>
      <!-- AttrValNew -->
      <td class="tdValue">
      </td>
    </tr>
	</xsl:template>
	<xsl:template match="a:delta" mode="deletes">
    <tr>
      <!-- Group -->
      <td class="tdLeftSection">
        object deletion
      </td>
      <!-- Change# -->
      <td class="tdLeftSection">
        <xsl:value-of select="position()" />
      </td>
      <!-- AttrName -->
      <td class="tdValue">
      </td>
      <!-- DeltaOp -->
      <td class="tdValue">
        delete
      </td>
      <!-- DNAOp -->
      <td class="tdValue">
      </td>
      <!-- DNVOp -->
      <td class="tdValue">
      </td>
      <!-- ObjectDN -->
      <td class="tdValue">
        <xsl:value-of select="@dn" />
      </td>
      <!-- dn -->
      <td class="tdValue">
      </td>
      <!-- AttrType -->
      <td class="tdValue">
      </td>
      <!-- AttrMV -->
      <td class="tdValue">
      </td>
      <!-- AttrValDel -->
      <td class="tdValue">
      </td>
      <!-- AttrValAdd -->
      <td class="tdValue">
      </td>
      <!-- AttrValNew -->
      <td class="tdValue">
      </td>
    </tr>
  </xsl:template>
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
