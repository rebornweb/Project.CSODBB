<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt">
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:template match="/">
    <table id="tdata"><xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="5">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Management Agent List</xsl:text>
        </td>
      </tr>

      <xsl:for-each select="//ManagementAgent">
        <xsl:sort select="Name"/>
        <xsl:call-template name="sectionbreak">
          <xsl:with-param name ="colspan" select="'2'" />
        </xsl:call-template>
        <tr>
          <td colspan="2">
            <xsl:call-template name="sectionstyle" />
            <xsl:value-of select="Name"/>
          </td>
        </tr>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Type'" />
          <xsl:with-param name="value" select="Type" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'ID'" />
          <xsl:with-param name="value" select="ID" />
        </xsl:call-template>

        <xsl:if test="count(SynchronizationRules/SynchronizationRule) != 0">
          <tr>
            <th colspan="2">
              <xsl:attribute name="style">
                text-align:left;
                background:#CCCCCC;
                padding-left:10px;
                padding-right:10px;
                padding-top:10px;
                padding-bottom:5px;
                border-top:1px RGB(212,208,200) solid;
              </xsl:attribute>
              Synchronization Rules
            </th>
          </tr>
          <tr>
            <td colspan="2">
              <xsl:attribute name="style">
                text-align:left;
                font-weight:normal;
                padding-left:10px;
                padding-right:10px;
                Padding-top:5px;
              </xsl:attribute>
              <ul>
              <xsl:for-each select="SynchronizationRules/SynchronizationRule">
          
                <li>
                  <xsl:attribute name="style">
                    padding-top:2px;
                    padding-bottom:2px;
                  </xsl:attribute>
                  <xsl:value-of select="."/>                  
                </li>
              </xsl:for-each>
              </ul>
            </td>
          </tr>
        </xsl:if>
      </xsl:for-each>
    </table>
  </xsl:template>
  <!--===================================================================================================================================-->
  <!-- Template to display a data iten                                                                                                   -->
  <!--===================================================================================================================================-->
  <xsl:template name="DataItem">
    <xsl:param name="property" />
    <xsl:param name="value" />
    <tr>
      <th>
        <xsl:attribute name="style">
          text-align:left;
          background:#CCCCCC;
          padding-left:10px;
          padding-right:10px;
          padding-top:2px;
          padding-bottom:2px;
        </xsl:attribute>
        <xsl:value-of select="$property"/>
      </th>
      <th>
        <xsl:attribute name="style">
          text-align:left;
          font-weight:normal;
          padding-left:10px;
          padding-right:10px;
          padding-top:2px;
          padding-bottom:2px;
        </xsl:attribute>
        <xsl:value-of select="$value"/>
      </th>
    </tr>
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
      border-collapse:collapse;
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
</xsl:stylesheet>