<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:param name="filter" />
  <xsl:template match="/">
 			<xsl:call-template name="FIMMASchema" />
	</xsl:template>
	<!--======================================================================================-->
	<!-- Template to display the ILM MA data                                                  -->
	<!--======================================================================================-->
	<xsl:template name="FIMMASchema">
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="4">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>FIM MA Schema</xsl:text>
        </td>
			</tr>

			<xsl:for-each select="fimma-configuration/mms-info/column-info[@name=$filter]">
        <xsl:call-template name="sectionbreak">
          <xsl:with-param name ="colspan" select="'6'" />
        </xsl:call-template>
				<tr>
          <td colspan="5">
            <xsl:call-template name="sectionstyle" />
            <xsl:text>Object type: </xsl:text>
						<xsl:value-of select="@name"/>
					</td>
				</tr>
				<tr>
          <th><xsl:call-template name="headstyle" />Attribute Name</th>
          <th><xsl:call-template name="headstyle" />Data Type</th>
          <th><xsl:call-template name="headstyle" />Required</th>
          <th><xsl:call-template name="headstyle" />Multi-Valued</th>
				</tr>
				<xsl:for-each select="column">
          <xsl:sort select="name"/>
					<tr>
            <xsl:call-template name="multiline" />
            <td>
              <xsl:call-template name="centercell" />
              <xsl:value-of select="name"/>
            </td>
            <td>
              <xsl:call-template name="centercell" />
              <xsl:value-of select="data-type"/>
            </td>
            <td style="padding-left:10px;padding-right:10px;white-space:nowrap;text-align:center;font-weight:normal;">
              <xsl:choose>
                <xsl:when test="isrequired='0'">no</xsl:when>
                <xsl:otherwise>
                  <xsl:text>yes</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </td>
            <td>
              <xsl:call-template name="centercell" />
              <xsl:choose>
                <xsl:when test="ismultivalued='0'">no</xsl:when>
                <xsl:otherwise>
                  <xsl:text>yes</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </td>
					</tr>
				</xsl:for-each>
			</xsl:for-each>
		</table>
	</xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a table style                                                        -->
  <!--======================================================================================-->
  <xsl:template name="tablestyle">
    <xsl:attribute name="style">
      font-family:Tahoma;
      font-size:11px;
      border-top:1px RGB(212,208,200) solid;
      border-left:1px RGB(212,208,200) solid;
      border-right: 1px RGB(212,208,200) solid;
      border-bottom:1px RGB(212,208,200) solid;
      padding:0px;"
    </xsl:attribute>
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a report head style                                                  -->
  <!--======================================================================================-->
  <xsl:template name="reportheadstyle">
    <xsl:attribute name="style">
      padding-top:10px;
      padding-bottom:10px;
      padding-left:10px;
      padding-right:10px;
      font-weight:bold;
      background:rgb(234,242,255);
      border-bottom:1px solid rgb(120,172,255)
    </xsl:attribute>
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a section style                                                        -->
  <!--======================================================================================-->
  <xsl:template name="sectionstyle">
    <xsl:attribute name="style">
      text-align:left;
      border-bottom:green 1px solid;
      padding-bottom:5px;
      padding-left:10px;
      padding-right:10px;
      background:#e9ffcb;
      font-weight:bold;
      padding-top:5px
    </xsl:attribute>
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a multi line format                                                  -->
  <!--======================================================================================-->
  <xsl:template name="multiline">
    <xsl:if test="(position() mod 2 = 0)">
      <xsl:attribute name="bgcolor">#F5F5DC</xsl:attribute>
    </xsl:if>
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a section break                                                      -->
  <!--======================================================================================-->
  <xsl:template name="sectionbreak">
    <xsl:param name="colspan" />
    <xsl:if test="position()!=1">
      <tr>
        <td style="color:#FFFFFF;background-color:#FFFFFF; border-top:1px RGB(212,208,200) solid;" >
          <xsl:attribute name="colspan">
            <xsl:value-of select="$colspan"/>
          </xsl:attribute>
          &#160;
        </td>
      </tr>
    </xsl:if>
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a head style                                                         -->
  <!--======================================================================================-->
  <xsl:template name="headstyle">
    <xsl:attribute name="style">
      background:#CCCCCC;
      border-right:#666666 1px solid;
      border-bottom:#666666 1px solid;
      padding-left:10px;
      padding-right:10px;
      font-weight:normal;
      white-space:nowrap;
    </xsl:attribute>
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a center cell                                                        -->
  <!--======================================================================================-->
  <xsl:template name="centercell">
    <xsl:attribute name="style">
      padding-left:10px;
      padding-right:10px;
      white-space:nowrap;
      text-align:center;
      font-weight:normal;"
    </xsl:attribute>
  </xsl:template>  
  </xsl:stylesheet>