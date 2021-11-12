<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="iso-8859-1" indent="yes" method="html" version="4.0" />
	<xsl:param name="filter" />
  <xsl:variable name="curnode" select="Results/ExportObject/ResourceManagementObject[ObjectIdentifier = $filter]/ResourceManagementAttributes/ResourceManagementAttribute" />
  <xsl:template match="/">
		<table style="font-family: Tahoma;font-size: 11px;border-top: #E6E6E6 1px solid;border-right: #E6E6E6 1px solid;border-left: #E6E6E6 1px solid;border-bottom: #E6E6E6 1px solid;" id="tdata">
			<xsl:call-template name="GeneralData" />
			<xsl:call-template name="SyncRuleData" />
		</table>
	</xsl:template>
	<!--======================================================================================-->
	<!-- Template to display the general data                                                 -->
	<!--======================================================================================-->
	<xsl:template name="GeneralData">
		<tr>
			<td style="font-family: Tahoma;font-size: 11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: rgb(234,242,255);border-bottom: 1px solid rgb(120,172,255);">Workflow Configuration</td>
		</tr>
		<tr>
			<td>
				<table style="border: 0px;border-collapse:collapse;">
					<xsl:call-template name="DataItem">
						<xsl:with-param name="type">Name</xsl:with-param>
						<xsl:with-param name="value" select="$curnode[AttributeName='DisplayName']/Value" />
					</xsl:call-template>

					<xsl:call-template name="DataItem">
						<xsl:with-param name="type">Description</xsl:with-param>
						<xsl:with-param name="value" select="$curnode[AttributeName='Description']/Value" />
					</xsl:call-template>

					<xsl:call-template name="DataItem">
						<xsl:with-param name="type">Created Time</xsl:with-param>
						<xsl:with-param name="value" select="substring-before($curnode[AttributeName='CreatedTime']/Value, ' ')" />
					</xsl:call-template>

					<xsl:call-template name="DataItem">
						<xsl:with-param name="type">Workflow Type</xsl:with-param>
						<xsl:with-param name="value" select="$curnode[AttributeName='RequestPhase']/Value" />
					</xsl:call-template>

					<xsl:call-template name="DataItem">
						<xsl:with-param name="type">Run On Policy Update</xsl:with-param>
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
		<xsl:if test="count($curnode[AttributeName='XOML']/SynchronizationRuleActivity)&gt;0">
			<xsl:variable name="srnode" select="$curnode[AttributeName='XOML']/SynchronizationRuleActivity" />
			<tr>
				<td style="font-family: Tahoma;font-size: 11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: #e9ffcb;border-bottom: 1px solid green;">Synchronization Rule</td>
			</tr>
			<tr>
				<td>
					<table style="border: 0px;border-collapse:collapse;">

						<xsl:variable name="srid" select="$srnode/SynchronizationRuleId" />
						<xsl:variable name="objectid" select="concat('urn:uuid:', $srid)" />
				
						<xsl:call-template name="DataItem">
							<xsl:with-param name="type">Name</xsl:with-param>
							<xsl:with-param name="value" select="//ResourceManagementObject[ObjectIdentifier=$objectid]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
						</xsl:call-template>

						<xsl:call-template name="DataItem">
							<xsl:with-param name="type">Action</xsl:with-param>
							<xsl:with-param name="value" select="$srnode/Action" />
						</xsl:call-template>


						<xsl:if test="substring($srnode/AttributeId, 1, 8) != '00000000'">
							<xsl:variable name="attrid" select="concat('urn:uuid:', $srnode/AttributeId)" />
							<xsl:call-template name="DataItem">
								<xsl:with-param name="type">Attribute</xsl:with-param>
								<xsl:with-param name="value" select="//ResourceManagementObject[ObjectIdentifier=$attrid]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
							</xsl:call-template>

							<xsl:call-template name="DataItem">
								<xsl:with-param name="type">Add Value</xsl:with-param>
								<xsl:with-param name="value" select="$srnode/AddValue" />
							</xsl:call-template>


							<xsl:call-template name="DataItem">
								<xsl:with-param name="type">Remove Value</xsl:with-param>
								<xsl:with-param name="value" select="$srnode/RemoveValue" />
							</xsl:call-template>
						</xsl:if>

					</table>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display a data item                                                                                                                             -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="DataItem">
		<xsl:param name="type" />
		<xsl:param name="value" />
		<tr>
			<td style="font-family: Tahoma;font-size: 11px;width:105px;text-align: left;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">
				<xsl:value-of select="$type" />
			</td>
			<td style="font-family: Tahoma;font-size: 11px;padding-left:5px;">
				<xsl:value-of select="$value" />
			</td>
		</tr>
	</xsl:template>	
</xsl:stylesheet>