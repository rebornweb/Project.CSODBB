<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt" xmlns:dsml="http://www.dsml.org/DSML" xmlns:ms-dsml="http://www.microsoft.com/MMS/DSML">
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:template match="/">
    <table id="tdata"><xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Metaverse Active Schema and FIMMA EAF Configuration</xsl:text>
        </td>
      </tr>
      <xsl:for-each select="//import-flow-set">
        <xsl:sort select="@mv-object-type" />
        <xsl:call-template name="sectionbreak">
          <xsl:with-param name ="colspan" select="'6'" />
        </xsl:call-template>
        <tr>
          <td colspan="6">
            <xsl:call-template name="sectionstyle" />
            <xsl:text>Metaverse object type: </xsl:text>
            <xsl:value-of select="@mv-object-type" />
          </td>
        </tr>
        <tr>
          <th><xsl:call-template name="headstyle" />Metaverse Attribute</th>
          <th><xsl:call-template name="headstyle" />Type</th>
          <th><xsl:call-template name="headstyle" />Multi-valued</th>
          <th><xsl:call-template name="headstyle" />Indexed</th>
          <th><xsl:call-template name="headstyle" />Import-Flows</th>
          <th><xsl:call-template name="headstyle" />Replicated</th>
        </tr>
        <xsl:for-each select="import-flows">
          <xsl:variable name="mvtype" select="../@mv-object-type"/>
          <tr>
            <xsl:call-template name="multiline" />
            <xsl:variable name="mv-attribute" select="@mv-attribute" />
            <td style="padding-left:10px;padding-right:10px;white-space:nowrap;text-align:center;font-weight:normal;">
              <xsl:value-of select="$mv-attribute" />
            </td>

            <td>
              <xsl:call-template name="centercell" />
              <xsl:variable name ="oid"  select="//dsml:attribute-type[@id=$mv-attribute]/dsml:syntax" />
              <xsl:choose>
                <xsl:when test="$oid='1.3.6.1.4.1.1466.115.121.1.27'" >
                  <xsl:text>Number</xsl:text>
                </xsl:when>
                <xsl:when test="$oid='1.3.6.1.4.1.1466.115.121.1.12'" >
                  <xsl:text>Reference (DN)</xsl:text>
                </xsl:when>
                <xsl:when test="$oid='1.3.6.1.4.1.1466.115.121.1.7'" >
                  <xsl:text>Boolean</xsl:text>
                </xsl:when>
                <xsl:when test="$oid='1.3.6.1.4.1.1466.115.121.1.5'" >
                  Binary
                  <xsl:call-template name="isindexable" />
                </xsl:when>
                <xsl:when test="$oid='1.3.6.1.4.1.1466.115.121.1.15'" >
                  String
                  <xsl:call-template name="isindexable" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$oid" />
                </xsl:otherwise>
              </xsl:choose>
            </td>
            <td>
              <xsl:call-template name="centercell" />
              <xsl:choose>
                <xsl:when test="//dsml:attribute-type[@id=$mv-attribute]/@single-value">
                  <xsl:choose>
                    <xsl:when test="//dsml:attribute-type[@id=$mv-attribute]/@single-value='true'">
                      no
                    </xsl:when>
                    <xsl:otherwise>yes</xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>yes</xsl:otherwise>
              </xsl:choose>
            </td>
            <td>
              <xsl:call-template name="centercell" />
              <xsl:choose>
                <xsl:when test="//dsml:attribute-type[@id=$mv-attribute]/@ms-dsml:indexed">
                  <xsl:choose>
                    <xsl:when test="//dsml:attribute-type[@id=$mv-attribute]/@ms-dsml:indexed='true'">
                      yes
                    </xsl:when>
                    <xsl:otherwise>no</xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>no</xsl:otherwise>
              </xsl:choose>
            </td>
            <td>
              <xsl:call-template name="centercell" />
              <xsl:value-of select="count(import-flow)"/>
            </td>
            <xsl:variable name ="flowcount" select="count(//export-flow-set[@mv-object-type=$mvtype]/export-flow/direct-mapping[src-attribute=$mv-attribute])" />
            <td>
              <xsl:call-template name="centercell" />
              <xsl:choose>
                <xsl:when test="$flowcount = 0">
                  <xsl:text>no</xsl:text>
                </xsl:when>
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
  <!--===================================================================================================================================-->
  <!-- Template to determine whether a value is indexable                                                                                -->
  <!--===================================================================================================================================-->
  <xsl:template name="isindexable">
    <xsl:param name="value" />
    <xsl:choose>
      <xsl:when test="//dsml:attribute-type[@id=$value]/@ms-dsml:indexable='true'" >
        <xsl:text> (indexable)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> (non-indexable)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
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
  <!-- Template to add a multi line                                                         -->
  <!--======================================================================================-->
  <xsl:template name="multiline">
    <xsl:if test="(position() mod 2 = 0)">
      <xsl:attribute name="bgcolor">#F5F5DC</xsl:attribute>
    </xsl:if>
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to add a head style                                                        -->
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
