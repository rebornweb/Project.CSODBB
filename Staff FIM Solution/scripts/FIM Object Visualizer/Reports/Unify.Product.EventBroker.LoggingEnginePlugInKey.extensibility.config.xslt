<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt">
  <xsl:include href="./Common.xslt"/>
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:template match="/">
    <xsl:call-template name="EventBrokerLogging" />
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to display the Event Broker Logging                                         -->
  <!--======================================================================================-->
  <xsl:template name="EventBrokerLogging">
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="5">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Event Broker 3.0 - Logging</xsl:text>
        </td>
      </tr>
      <xsl:for-each select="//LoggingEngine">
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'File prefix'" />
          <xsl:with-param name="value" select="@filePrefix" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Log days to keep'" />
          <xsl:with-param name="value" select="@logDaysKeep" />
        </xsl:call-template>
      </xsl:for-each>
      <tr>
        <td colspan="2" style="color:#F7FBFA;">
          <xsl:text>-</xsl:text>
        </td>
      </tr>
      <xsl:for-each select="//LoggingEngine/LogWriter">
        <xsl:sort select="@name"/>
        <tr>
          <td style="text-align:left;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px" colspan="5">
            <xsl:value-of select="@name"/>
          </td>
        </tr>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Name'" />
          <xsl:with-param name="value" select="LogWriter/@name" />
        </xsl:call-template>
        <xsl:if test="position() != last()">
          <tr>
            <td colspan="2" style="color:#F7FBFA;">
              <xsl:text>-</xsl:text>
            </td>
          </tr>
        </xsl:if>
      </xsl:for-each>
    </table>
  </xsl:template>
</xsl:stylesheet>