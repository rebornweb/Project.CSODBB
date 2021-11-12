<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt">
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:param name="maname"/>
  <xsl:template match="/">
  <table id="tdata">
    <xsl:call-template name="tablestyle" />
    <tr>
      <td>
        <xsl:call-template name="reportheadstyle" />
        <xsl:text>Management Attribute Selection</xsl:text>
      </td>
    </tr>
    <xsl:for-each select="//ManagementAgent[MaName=$maname]">
      <xsl:sort select="MaName" />

      <xsl:call-template name="sectionbreak">
        <xsl:with-param name ="colspan" select="'0'" />
      </xsl:call-template>
      <tr>
        <td>
          <xsl:call-template name="sectionstyle" />
          <xsl:value-of select="MaName" />
        </td>
      </tr>
      <tr>
        <td>
          <ul>
            <xsl:for-each select="MaAttributes/MaAttribute">
              <li>
                <xsl:value-of select="."/>
              </li>
            </xsl:for-each>
          </ul>    
        </td>
      </tr>
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
      padding:0px;
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
  <!-- Template to add a section style                                                      -->
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
  <!-- Template to add a multi line format                                                  -->
  <!--======================================================================================-->
  <xsl:template name="multiline">
    <xsl:if test="(position() mod 2 = 0)">
      <xsl:attribute name="bgcolor">#F5F5DC</xsl:attribute>
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
