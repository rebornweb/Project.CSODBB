<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="iso-8859-1" indent="yes" method="html" version="4.0" />
  <xsl:include href="./Common.Reports.xslt"/>
  <xsl:template name="WorkflowInclude">
    <xsl:param name="filter" />
    <xsl:variable name="curnode" select="//ResourceManagementObject[ObjectIdentifier = $filter]/ResourceManagementAttributes/ResourceManagementAttribute" />
		<xsl:call-template name="GeneralData" >
      <xsl:with-param name="curnode" select="$curnode" />
    </xsl:call-template>
		<xsl:call-template name="SyncRuleData" >
      <xsl:with-param name="curnode" select="$curnode" />
    </xsl:call-template>
	</xsl:template>
	<!--======================================================================================-->
	<!-- Template to display the general data                                                 -->
	<!--======================================================================================-->
	<xsl:template name="GeneralData">
    <xsl:param name="curnode"/>
    <!--
    <tr>
			<td style="font-family: Tahoma;font-size: 11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: rgb(234,242,255);border-bottom: 1px solid rgb(120,172,255);" colspan="10">Workflow Configuration</td>
		</tr>
    -->
		<tr>
      <td colspan="10">
        <table style="font-family: Tahoma;font-size: 11px;border-top: #E6E6E6 1px solid;border-right: #E6E6E6 1px solid;border-left: #E6E6E6 1px solid;border-bottom: #E6E6E6 1px solid;" id="tdata">
          <xsl:call-template name="DataItem">
						<xsl:with-param name="property">Name</xsl:with-param>
						<xsl:with-param name="value" select="$curnode[AttributeName='DisplayName']/Value" />
					</xsl:call-template>

					<xsl:call-template name="DataItem">
						<xsl:with-param name="property">Description</xsl:with-param>
						<xsl:with-param name="value" select="$curnode[AttributeName='Description']/Value" />
					</xsl:call-template>

					<xsl:call-template name="DataItem">
						<xsl:with-param name="property">Created Time</xsl:with-param>
						<xsl:with-param name="value" select="substring-before($curnode[AttributeName='CreatedTime']/Value, ' ')" />
					</xsl:call-template>

					<xsl:call-template name="DataItem">
						<xsl:with-param name="property">Workflow Type</xsl:with-param>
						<xsl:with-param name="value" select="$curnode[AttributeName='RequestPhase']/Value" />
					</xsl:call-template>

					<xsl:call-template name="DataItem">
						<xsl:with-param name="property">Run On Policy Update</xsl:with-param>
						<xsl:with-param name="value" select="$curnode[AttributeName='RunOnPolicyUpdate']/Value" />
					</xsl:call-template>
				</table>
			</td>
		</tr>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display the workflow data                                                                                                                       -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="SyncRuleData">
    <xsl:param name="curnode"/>
    <xsl:if test="count($curnode[AttributeName='XOML']/SynchronizationRuleActivity)&gt;0">
			<xsl:variable name="srnode" select="$curnode[AttributeName='XOML']/SynchronizationRuleActivity" />
			<tr>
				<td style="font-family: Tahoma;font-size: 11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: #e9ffcb;border-bottom: 1px solid green;" colspan="10">Synchronization Rule</td>
			</tr>
			<tr>
        <td colspan="10">
          <table style="font-family: Tahoma;font-size: 11px;border-top: #E6E6E6 1px solid;border-right: #E6E6E6 1px solid;border-left: #E6E6E6 1px solid;border-bottom: #E6E6E6 1px solid;" id="tdata">
            <xsl:variable name="srid" select="$srnode/SynchronizationRuleId" />
						<xsl:variable name="objectid" select="concat('urn:uuid:', $srid)" />
				
						<xsl:call-template name="DataItem">
							<xsl:with-param name="property">Name</xsl:with-param>
							<xsl:with-param name="value" select="//ResourceManagementObject[ObjectIdentifier=$objectid]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
						</xsl:call-template>

						<xsl:call-template name="DataItem">
							<xsl:with-param name="property">Action</xsl:with-param>
							<xsl:with-param name="value" select="$srnode/Action" />
						</xsl:call-template>


						<xsl:if test="substring($srnode/AttributeId, 1, 8) != '00000000'">
							<xsl:variable name="attrid" select="concat('urn:uuid:', $srnode/AttributeId)" />
							<xsl:call-template name="DataItem">
								<xsl:with-param name="property">Attribute</xsl:with-param>
								<xsl:with-param name="value" select="//ResourceManagementObject[ObjectIdentifier=$attrid]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
							</xsl:call-template>

							<xsl:call-template name="DataItem">
								<xsl:with-param name="property">Add Value</xsl:with-param>
								<xsl:with-param name="value" select="$srnode/AddValue" />
							</xsl:call-template>


							<xsl:call-template name="DataItem">
								<xsl:with-param name="property">Remove Value</xsl:with-param>
								<xsl:with-param name="value" select="$srnode/RemoveValue" />
							</xsl:call-template>
						</xsl:if>

					</table>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>