<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ms="urn:schemas-microsoft-com:xslt"
                xmlns:dsml="http://www.dsml.org/DSML"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:my="http://schemas.microsoft.com/2006/11/ResourceManagement"
                xmlns:xd="http://schemas.microsoft.com/office/infopath/2003">
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:include href="./Common.Script.Short.xslt"/>
  <xsl:include href="./Common.Reports.xslt"/>
  <!--<xsl:include href="./Workflows.Include.xslt"/>-->
  <xsl:template match="/">
    <xsl:call-template name="RequestHistory" />
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to display the Portal Configuration                                         -->
  <!--======================================================================================-->
  <xsl:template name="RequestHistory">
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <a name="top"/>
          <xsl:text>FIM Request History</xsl:text>
        </td>
      </tr>
      <tr>
        <td colspan="6">
          <ol>
            <xsl:apply-templates select="//ResourceManagementObject[ObjectType='Request']" mode="tocRH">
              <xsl:sort select="dsml:GetDateTimeExpr(string(ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='CreatedTime']/Value))" data-type="text" order="descending" />
            </xsl:apply-templates>
          </ol>
        </td>
      </tr>
      <xsl:apply-templates select="//ResourceManagementObject[ObjectType='Request']" mode="detailForOID">
        <xsl:sort select="dsml:GetDateTimeExpr(string(ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='CreatedTime']/Value))" data-type="text" order="descending" />
      </xsl:apply-templates>
      <xsl:apply-templates select="//ResourceManagementObject[(ObjectType!='Request') and not(starts-with(ObjectType,'DEEWR-')) and (ObjectType!='WorkflowDefinition') and (ObjectType!='ManagementPolicyRule') and (ObjectType!='Set') and (ObjectType!='SynchronizationRule')]" mode="detailForOID">
        <xsl:sort select="ObjectType"/>
        <xsl:sort select="dsml:GetDateTimeExpr(string(ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='CreatedTime']/Value))" data-type="text" order="descending" />
      </xsl:apply-templates>
    </table>
  </xsl:template>
</xsl:stylesheet>