<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="iso-8859-1" indent="yes" method="html" version="4.0" />
  <xsl:include href="./Common.xslt"/>
  <xsl:template name="SynchronizationRuleInclude">
    <xsl:param name="filter" />
    <xsl:variable name="curnode" select="//ResourceManagementObject[ObjectIdentifier = $filter]/ResourceManagementAttributes/ResourceManagementAttribute" />
      <xsl:call-template name="GeneralData" >
        <xsl:with-param name="curnode" select="$curnode" />
      </xsl:call-template>
			<xsl:call-template name="ScopeData" >
        <xsl:with-param name="curnode" select="$curnode" />
      </xsl:call-template>
			<xsl:call-template name="RelationshipData" >
        <xsl:with-param name="curnode" select="$curnode" />
      </xsl:call-template>
			<xsl:call-template name="ConnectedObjectScopeData" >
        <xsl:with-param name="curnode" select="$curnode" />
      </xsl:call-template>
			<xsl:call-template name="RelationshipCriteriaData" >
        <xsl:with-param name="curnode" select="$curnode" />
      </xsl:call-template>
			<xsl:call-template name="ParametersData" >
        <xsl:with-param name="curnode" select="$curnode" />
      </xsl:call-template>
			<xsl:call-template name="InboundAttributeFlows" >
        <xsl:with-param name="curnode" select="$curnode" />
      </xsl:call-template>
			<xsl:call-template name="InitialOutboundAttributeFlows" >
        <xsl:with-param name="curnode" select="$curnode" />
      </xsl:call-template>
			<xsl:call-template name="ExistenceTests" >
        <xsl:with-param name="curnode" select="$curnode" />
      </xsl:call-template>
			<xsl:call-template name="PersistentOutboundAttributeFlows" >
        <xsl:with-param name="curnode" select="$curnode" />
      </xsl:call-template>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display general data                                                                                                                            -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="GeneralData">
    <xsl:param name="curnode"/>
		<tr>
			<td style="font-family: Tahoma;font-size: 11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: rgb(234,242,255);border-bottom: 1px solid rgb(120,172,255);" colspan="10">Synchronization Rule Configuration</td>
		</tr>
		<tr>
      <td colspan="10">
        <table style="font-family: Tahoma;font-size: 11px;border-top: #E6E6E6 1px solid;border-right: #E6E6E6 1px solid;border-left: #E6E6E6 1px solid;border-bottom: #E6E6E6 1px solid;" id="tdata">
          <!--<table style="border: 0px;border-collapse:collapse;">-->
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
						<xsl:with-param name="property">Precedence</xsl:with-param>
						<xsl:with-param name="value" select="$curnode[AttributeName='Precedence']/Value" />
					</xsl:call-template>

					<xsl:variable name="curval">
						<xsl:choose>
							<xsl:when test="$curnode[AttributeName='FlowType']/Value='1'">Outbound</xsl:when>
							<xsl:when test="$curnode[AttributeName='FlowType']/Value='0'">Inbound</xsl:when>
							<xsl:otherwise>
								<xsl:text>Inbound and Outbound</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:call-template name="DataItem">
						<xsl:with-param name="property">Data Flow Direction</xsl:with-param>
						<xsl:with-param name="value" select="$curval" />
					</xsl:call-template>


					<xsl:variable name="idval" select="$curnode[AttributeName='Dependency']/Value" />
					<xsl:variable name="dpstring" select="//ResourceManagementObject[ObjectIdentifier=$idval]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />

					<xsl:call-template name="DataItem">
						<xsl:with-param name="property">Dependency</xsl:with-param>
						<xsl:with-param name="value" select="$dpstring" />
					</xsl:call-template>

				</table>
			</td>
		</tr>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display scope data                                                                                                                              -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="ScopeData">
    <xsl:param name="curnode"/>
    <tr>
			<td style="font-family: Tahoma;font-size: 11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: rgb(234,242,255);border-bottom: 1px solid rgb(120,172,255);" colspan="10">Scope</td>
		</tr>
		<tr>
      <td colspan="10">
        <table style="font-family: Tahoma;font-size: 11px;border-top: #E6E6E6 1px solid;border-right: #E6E6E6 1px solid;border-left: #E6E6E6 1px solid;border-bottom: #E6E6E6 1px solid;" id="tdata">
          <!--<table style="border: 0px;border-collapse:collapse;">-->
          <xsl:call-template name="DataItem">
						<xsl:with-param name="property">Metaverse Resource Type</xsl:with-param>
						<xsl:with-param name="value" select="$curnode[AttributeName='ILMObjectType']/Value" />
					</xsl:call-template>


					<xsl:variable name="idval" select="$curnode[AttributeName='ManagementAgentID']/Value" />
					<xsl:variable name="dsstring" select="//ResourceManagementObject[ObjectIdentifier=$idval]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />

					<xsl:variable name="dsname">
						<xsl:choose>
							<xsl:when test="string-length($dsstring)= 0">
								<xsl:value-of select="substring($idval, 10)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$dsstring" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:call-template name="DataItem">
						<xsl:with-param name="property">External System</xsl:with-param>
						<xsl:with-param name="value" select="$dsname" />
					</xsl:call-template>

					<xsl:call-template name="DataItem">
						<xsl:with-param name="property">External System Resource Type</xsl:with-param>
						<xsl:with-param name="value" select="$curnode[AttributeName='ConnectedObjectType']/Value" />
					</xsl:call-template>
				</table>
			</td>
		</tr>
	</xsl:template>

	<!--=============================================================================================================================================================-->
	<!-- Template to display relationship data                                                                                                                       -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="RelationshipData">
    <xsl:param name="curnode"/>
    <tr>
			<td style="font-family: Tahoma;font-size: 11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: rgb(234,242,255);border-bottom: 1px solid rgb(120,172,255);" colspan="10">Relationship</td>
		</tr>
		<tr>
      <td colspan="10">
        <table style="font-family: Tahoma;font-size: 11px;border-top: #E6E6E6 1px solid;border-right: #E6E6E6 1px solid;border-left: #E6E6E6 1px solid;border-bottom: #E6E6E6 1px solid;" id="tdata">
          <!--<table style="border: 0px;border-collapse:collapse;">-->
          <xsl:if test="$curnode[AttributeName='FlowType']/Value != '1'">
            <xsl:call-template name="DataItem">
              <xsl:with-param name="property">Create Resource In FIM</xsl:with-param>
              <xsl:with-param name="value" select="$curnode[AttributeName='CreateILMObject']/Value" />
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$curnode[AttributeName='FlowType']/Value != '0'">
            <xsl:call-template name="DataItem">
						<xsl:with-param name="property">Create Resource In External System</xsl:with-param>
						<xsl:with-param name="value" select="$curnode[AttributeName='CreateConnectedSystemObject']/Value" />
            </xsl:call-template>
            <xsl:call-template name="DataItem">
						<xsl:with-param name="property">Enable Deprovisioning</xsl:with-param>
						<xsl:with-param name="value" select="$curnode[AttributeName='DisconnectConnectedSystemObject']/Value" />
            </xsl:call-template>
          </xsl:if>
        </table>
			</td>
		</tr>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display the connected object scope                                                                                                             -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="ConnectedObjectScopeData">
    <xsl:param name="curnode"/>
    <xsl:if test="count($curnode[AttributeName='ConnectedSystemScope'])&gt;0">
			<tr>
				<td style="padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: rgb(234,242,255);border-bottom: 1px solid rgb(120,172,255);" colspan="10">Connected Object Scope</td>
			</tr>
			<tr>
        <td colspan="10">
          <table style="font-family: Tahoma;font-size: 11px;border-top: #E6E6E6 1px solid;border-right: #E6E6E6 1px solid;border-left: #E6E6E6 1px solid;border-bottom: #E6E6E6 1px solid;" id="tdata">
            <!--<table style="border: 0px;border-collapse:collapse;">-->
            <tr>
							<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">Source Attribute</td>
							<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">Operation</td>
							<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">Value</td>
						</tr>
						<xsl:for-each select="$curnode[AttributeName='ConnectedSystemScope']/scoping/scope">
							<tr>
								<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">
									<xsl:value-of select="csAttribute" />
								</td>
								<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">
									<xsl:value-of select="csOperator" />
								</td>

								<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">
									<xsl:value-of select="csValue" />
								</td>
							</tr>
						</xsl:for-each>
					</table>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display relationships                                                                                                                           -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="RelationshipCriteriaData">
    <xsl:param name="curnode"/>
    <tr>
			<td style="font-family: Tahoma;font-size: 11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: rgb(234,242,255);border-bottom: 1px solid rgb(120,172,255);" colspan="10">Relationship Criteria</td>
		</tr>
		<tr>
      <td colspan="10">
        <table style="font-family: Tahoma;font-size: 11px;border-top: #E6E6E6 1px solid;border-right: #E6E6E6 1px solid;border-left: #E6E6E6 1px solid;border-bottom: #E6E6E6 1px solid;" id="tdata">
          <!--<table style="border: 0px;border-collapse:collapse;">-->
          <tr>
						<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">ILM Attribute</td>
						<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">Data Source Attribute</td>
					</tr>
					<xsl:for-each select="$curnode[AttributeName='RelationshipCriteria']/conditions/condition">
						<tr>
							<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">
								<xsl:value-of select="ilmAttribute" />
							</td>
							<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">
								<xsl:value-of select="csAttribute" />
							</td>
						</tr>
					</xsl:for-each>
				</table>
			</td>
		</tr>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display parameter                                                                                                                               -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="ParametersData">
    <xsl:param name="curnode"/>
    <xsl:if test="count($curnode[AttributeName='SynchronizationRuleParameters']/Values)&gt;0">
			<tr>
				<td style="font-family: Tahoma;font-size: 11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: rgb(234,242,255);border-bottom: 1px solid rgb(120,172,255);" colspan="10">Parameters</td>
			</tr>
			<tr>
        <td colspan="10">
          <table style="font-family: Tahoma;font-size: 11px;border-top: #E6E6E6 1px solid;border-right: #E6E6E6 1px solid;border-left: #E6E6E6 1px solid;border-bottom: #E6E6E6 1px solid;" id="tdata">
            <!--<table style="border: 0px;border-collapse:collapse;">-->
            <tr>
							<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">ILM Attribute</td>
							<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">Data Source Attribute</td>
						</tr>
						<xsl:for-each select="$curnode[AttributeName='SynchronizationRuleParameters']/Values/sync-parameter">
							<tr>
								<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">
									<xsl:value-of select="name" />
								</td>
								<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">
									<xsl:value-of select="type" />
								</td>
							</tr>
						</xsl:for-each>
					</table>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display inbound attribute flows                                                                                                                 -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="InboundAttributeFlows">
    <xsl:param name="curnode"/>
    <xsl:if test="count($curnode[AttributeName='PersistentFlow']/Values/import-flow)&gt;0">
			<tr>
				<td style="text-align: left;font-family: Tahoma;font-size: 11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: #e9ffcb;border-bottom: 1px solid green;" colspan="10">Inbound Attribute Flows</td>
			</tr>
			<xsl:call-template name="DisplayFlowData">
				<xsl:with-param name="type" select="$curnode[AttributeName='PersistentFlow']/Values/import-flow" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display persistent outbound flows                                                                                                               -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="PersistentOutboundAttributeFlows">
    <xsl:param name="curnode"/>
    <xsl:if test="count($curnode[AttributeName='PersistentFlow']/Values/export-flow)&gt;0">
			<tr>
				<td style="text-align: left;font-family: Tahoma;font-size: 11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: #e9ffcb;border-bottom: 1px solid green;" colspan="10">Persistent Outbound Attribute Flows</td>
			</tr>
			<xsl:call-template name="DisplayFlowData">
				<xsl:with-param name="type" select="$curnode[AttributeName='PersistentFlow']/Values/export-flow" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display initial outbound attribute flows                                                                                                        -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="InitialOutboundAttributeFlows">
    <xsl:param name="curnode"/>
    <xsl:if test="count($curnode[AttributeName='InitialFlow']/Values/export-flow)&gt;0">
			<tr>
				<td style="text-align: left;font-family: Tahoma;font-size: 11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: #e9ffcb;border-bottom: 1px solid green;" colspan="10">Initial Outbound Attribute Flows</td>
			</tr>
			<xsl:call-template name="DisplayFlowData">
				<xsl:with-param name="type" select="$curnode[AttributeName='InitialFlow']/Values/export-flow" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display existence tests                                                                                                                         -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="ExistenceTests">
    <xsl:param name="curnode"/>
    <xsl:if test="count($curnode[AttributeName='ExistenceTest']/Values/export-flow)&gt;0">
			<tr>
				<td style="font-family: Tahoma;font-size: 11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: #e9ffcb;border-bottom: 1px solid green;" colspan="10">Existence Tests</td>
			</tr>
			<xsl:call-template name="DisplayFlowData">
				<xsl:with-param name="type" select="$curnode[AttributeName='ExistenceTest']/Values/export-flow" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>	
	<!--=============================================================================================================================================================-->
	<!-- Template to display flow data                                                                                                                               -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="DisplayFlowData">
    <xsl:param name="type" />
		<tr>
      <td colspan="10">
        <table style="font-family: Tahoma;font-size: 11px;border-top: #E6E6E6 1px solid;border-right: #E6E6E6 1px solid;border-left: #E6E6E6 1px solid;border-bottom: #E6E6E6 1px solid;" id="tdata">
          <!--<table style="border: 0px;border-collapse:collapse;">-->
          <tr>
						<xsl:if test="$type/@allows-null">
							<td style="text-align: left;font-family: Tahoma;font-size: 11px;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">Allow Nulls</td>
						</xsl:if>

						<td style="font-family: Tahoma;font-size: 11px;text-align: left;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">Destination</td>
						<td style="font-family: Tahoma;font-size: 11px;text-align: left;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">Source</td>
					</tr>
					<xsl:for-each select="$type">
						<tr>
							<xsl:if test="(position() mod 2 = 0)">
								<xsl:attribute name="bgcolor">#EEEEFF</xsl:attribute>
							</xsl:if>

							<xsl:if test="@allows-null">
								<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">
									<xsl:value-of select="@allows-null" />
								</td>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="self::node()[0 = count(fn)]">
									<xsl:call-template name="DirectFlow" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="CalculatedFlow" />
								</xsl:otherwise>
							</xsl:choose>
						</tr>
					</xsl:for-each>
				</table>
			</td>
		</tr>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display a direct flows                                                                                                                          -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="DirectFlow">
		<td style="font-family: Tahoma;font-size: 11px;text-align: left;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">
			<xsl:value-of select="dest" />
		</td>
		<td style="font-family: Tahoma;font-size: 11px;text-align: left;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;">
      <xsl:choose>
        <xsl:when test="count(src/attr) != 0">
          <xsl:value-of select="src/attr" />
        </xsl:when>
        <xsl:otherwise>
          <strong>
            <xsl:text>Constant: </xsl:text>
          </strong>
          <xsl:value-of select="src" />
        </xsl:otherwise>
      </xsl:choose>
		</td>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display a calculated flows                                                                                                                      -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="CalculatedFlow">
		<td style="font-family: Tahoma;font-size: 11px;text-align: left;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">
			<xsl:value-of select="dest" />
		</td>
		<td style="font-family: Tahoma;font-size: 11px;text-align: left;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal">
			<xsl:call-template name="DisplayFunction" />
		</td>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display functions                                                                                                                               -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="DisplayFunction">
		<xsl:if test="fn/@isCustomExpression='true'">
			<strong>
				<xsl:text>CustomExpression(</xsl:text>
			</strong>
		</xsl:if>

		<strong>
			<xsl:value-of select="fn/@id" />
			<xsl:text>(</xsl:text>
		</strong>
		<xsl:for-each select="fn/arg">
			<xsl:call-template name="DisplayArgument" />
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>

		<strong>
			<xsl:text>)</xsl:text>
		</strong>

		<xsl:if test="fn/@isCustomExpression='true'">
			<strong>
				<xsl:text>)</xsl:text>
			</strong>
		</xsl:if>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display arguments                                                                                                                               -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="DisplayArgument">
		<xsl:choose>
			<xsl:when test="./fn">
				<xsl:for-each select=".">
					<xsl:call-template name="DisplayFunction" />
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
<!--==================================================================================================================================================================-->
