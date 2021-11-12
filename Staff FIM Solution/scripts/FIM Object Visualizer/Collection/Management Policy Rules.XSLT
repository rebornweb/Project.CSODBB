<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt" version="1.0">
	<xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
	<xsl:param name="filter" />
  <xsl:variable name="curnode" select="Results/ExportObject/ResourceManagementObject[ObjectIdentifier = $filter]/ResourceManagementAttributes/ResourceManagementAttribute" />
  <xsl:template match="/">
    <table style="font-family: Tahoma;font-size: 11px;border-top: #E6E6E6 1px solid;border-right: #E6E6E6 1px solid;border-left: #E6E6E6 1px solid;border-bottom: #E6E6E6 1px solid;" id="tdata">
		  <xsl:call-template name="GeneralData" />
      <xsl:choose>
        <xsl:when test="$curnode[AttributeName='ManagementPolicyRuleType']/Value='SetTransition'">
          <xsl:call-template name="TransitionDefinition" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="RequestorsAndOperators" />
          <xsl:call-template name="TargetResources" />
        </xsl:otherwise>        
      </xsl:choose>
		  <xsl:call-template name="PolicyWorkflows" />
	  </table>
	</xsl:template>
	<!--======================================================================================-->
	<!-- Template to display the general data                                                 -->
	<!--======================================================================================-->
	<xsl:template name="GeneralData">
		<tr>
			<td style="padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: rgb(234,242,255);border-bottom: 1px solid rgb(120,172,255);">Management Policy Rule Configuration</td>
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
          <xsl:variable name="MprType">
            <xsl:choose>
              <xsl:when test="$curnode[AttributeName='ManagementPolicyRuleType']/Value='SetTransition'">
                <xsl:text>Set Transition</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Request</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:call-template name="DataItem">
            <xsl:with-param name="type">Type</xsl:with-param>
            <xsl:with-param name="value" select="$MprType" />
          </xsl:call-template>
          <xsl:call-template name="DataItem">
						<xsl:with-param name="type">Grants Permissions</xsl:with-param>
						<xsl:with-param name="value" select="$curnode[AttributeName='GrantRight']/Value" />
					</xsl:call-template>
      		<xsl:call-template name="DataItem">
						<xsl:with-param name="type">Disabled</xsl:with-param>
						<xsl:with-param name="value" select="$curnode[AttributeName='Disabled']/Value" />
					</xsl:call-template>
				</table>
			</td>
		</tr>				
  	</xsl:template>
  <!--=============================================================================================================================================================-->
  <!-- Template to display the transition definition                                                                                                                -->
  <!--=============================================================================================================================================================-->
  <xsl:template name="TransitionDefinition">
    <xsl:variable name="idval1">
        <xsl:choose>
        <xsl:when test="$curnode[AttributeName='ActionType']/Values/string='TransitionIn'">
            <xsl:value-of select="$curnode[AttributeName='ResourceFinalSet']/Value" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$curnode[AttributeName='ResourceCurrentSet']/Value" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable> 
    
    <xsl:variable name="TransitionType">
      <xsl:choose>
        <xsl:when test="$curnode[AttributeName='ActionType']/Values/string='TransitionIn'">
          <xsl:text>Transition In</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Transition Out</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="TransitionSet" select="//ResourceManagementObject[ObjectIdentifier=$idval1]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
 
    <tr>
      <td style="padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: rgb(234,242,255);border-bottom: 1px solid rgb(120,172,255);">Transition Definition</td>
    </tr>
    <tr>
      <td>
        <table style="border: 0px;border-collapse:collapse;">
          <xsl:call-template name="DataItem">
            <xsl:with-param name="type">Transition Type</xsl:with-param>
            <xsl:with-param name="value" select="$TransitionType" />
          </xsl:call-template>
          <xsl:call-template name="DataItem">
            <xsl:with-param name="type">Transition Set</xsl:with-param>
            <xsl:with-param name="value" select="$TransitionSet" />
          </xsl:call-template>
        </table>
      </td>
    </tr>
  </xsl:template>
  <!--=============================================================================================================================================================-->
	<!-- Template to display requestors and operators                                                                                                                -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="RequestorsAndOperators">
		<tr>
			<td style="padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: rgb(234,242,255);border-bottom: 1px solid rgb(120,172,255);">Requestors and Operators</td>
		</tr>
		<tr>
			<td>
				<table style="border: 0px;border-collapse:collapse;">
					<xsl:variable name="requestor">
						<xsl:choose>
							<xsl:when test="count($curnode[AttributeName='PrincipalRelativeToResource']/Value)&gt;0">
								<xsl:value-of select="$curnode[AttributeName='PrincipalRelativeToResource']/Value" />
								<xsl:text> (Attribute)</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="idval" select="$curnode[AttributeName='PrincipalSet']/Value" />
								<xsl:value-of select="//ResourceManagementObject[ObjectIdentifier=$idval]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:call-template name="DataItem">
						<xsl:with-param name="type">Requestor</xsl:with-param>
						<xsl:with-param name="value" select="$requestor" />
					</xsl:call-template>


					<xsl:variable name="operation">
						<xsl:for-each select="$curnode[AttributeName='ActionType']/Values/string">
							<xsl:value-of select="." />
							<xsl:if test="not (position()=last())">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>

					<xsl:call-template name="DataItem">
						<xsl:with-param name="type">Operation</xsl:with-param>
						<xsl:with-param name="value" select="$operation" />
					</xsl:call-template>
				</table>
			</td>
		</tr>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display target resoueces                                                                                                                        -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="TargetResources">
		<tr>
			<td style="padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: rgb(234,242,255);border-bottom: 1px solid rgb(120,172,255);">Target Resources</td>
		</tr>
		<tr>
			<td>
				<table style="border: 0px;border-collapse:collapse;">
					<xsl:variable name="brequest">
						<xsl:choose>
							<xsl:when test="count($curnode[AttributeName='ResourceCurrentSet']/Value)&gt;0">
								<xsl:variable name="idval1" select="$curnode[AttributeName='ResourceCurrentSet']/Value" />
								<xsl:value-of select="//ResourceManagementObject[ObjectIdentifier=$idval1]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$curnode[AttributeName='ResourceCurrentRelativeToPrincipal']/Value" />
								<xsl:text> (Attribute)</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>


					<xsl:call-template name="DataItem">
						<xsl:with-param name="type">Before Request</xsl:with-param>
						<xsl:with-param name="value" select="$brequest" />
					</xsl:call-template>


					<xsl:variable name="arequest">
						<xsl:choose>
							<xsl:when test="count($curnode[AttributeName='ResourceFinalSet']/Value)&gt;0">
								<xsl:variable name="idval1" select="$curnode[AttributeName='ResourceFinalSet']/Value" />
								<xsl:value-of select="//ResourceManagementObject[ObjectIdentifier=$idval1]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$curnode[AttributeName='ResourceFinalRelativeToPrincipal']/Value" />
								<xsl:text> (Attribute)</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:call-template name="DataItem">
						<xsl:with-param name="type">After Request</xsl:with-param>
						<xsl:with-param name="value" select="$arequest" />
					</xsl:call-template>

					<xsl:variable name="aattributes">
						<xsl:choose>
							<xsl:when test="$curnode[AttributeName='ActionParameter']/Values/string = '*'">
								<xsl:text>All Attributes</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="$curnode[AttributeName='ActionParameter']/Values/string">
									<xsl:value-of select="." />
									<xsl:if test="not (position()=last())">
										<xsl:text>, </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:call-template name="DataItem">
						<xsl:with-param name="type">Resources Attributes</xsl:with-param>
						<xsl:with-param name="value" select="$aattributes" />
					</xsl:call-template>
				</table>
			</td>
		</tr>
	</xsl:template>
	<!--=============================================================================================================================================================-->
	<!-- Template to display policy workflows                                                                                                                        -->
	<!--=============================================================================================================================================================-->
	<xsl:template name="PolicyWorkflows">
		<xsl:variable name="count" select="count($curnode[AttributeName='AuthenticationWorkflowDefinition']/Values/string) + count($curnode[AttributeName='AuthorizationWorkflowDefinition']/Values/string) + count($curnode[AttributeName='ActionWorkflowDefinition']/Values/string)" />
		<xsl:if test="$count != 0">
			<tr>
				<td style="font-family: Tahoma;font-size: 11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: #e9ffcb;border-bottom: 1px solid green;">Policy Workflows</td>
			</tr>
			<tr>
				<td>
					<table style="border: 0px;border-collapse:collapse;">
						<tr>
							<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">Type</td>
							<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">Display Name</td>
						</tr>
						<xsl:for-each select="$curnode[AttributeName='AuthenticationWorkflowDefinition']/Values/string">
							<tr>
								<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">Authentication</td>
								<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">
									<xsl:variable name="idval1" select="." />
									<xsl:value-of select="//ResourceManagementObject[ObjectIdentifier=$idval1]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
								</td>
							</tr>
						</xsl:for-each>
						<xsl:for-each select="$curnode[AttributeName='AuthorizationWorkflowDefinition']/Values/string">
							<tr>
								<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">Authorization</td>
								<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">
									<xsl:variable name="idval1" select="." />
									<xsl:value-of select="//ResourceManagementObject[ObjectIdentifier=$idval1]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
								</td>
							</tr>
						</xsl:for-each>
						<xsl:for-each select="$curnode[AttributeName='ActionWorkflowDefinition']/Values/string">
							<tr>
								<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">Action</td>
								<td style="font-family: Tahoma;font-size: 11px;text-align: center;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;">
									<xsl:variable name="idval1" select="." />
									<xsl:value-of select="//ResourceManagementObject[ObjectIdentifier=$idval1]/ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
								</td>
							</tr>
						</xsl:for-each>
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
			<td style="font-family: Tahoma;font-size: 11px;white-space: nowrap;width:120px;text-align: left;padding-left: 10px;padding-right: 10px;padding-top: 2px;padding-bottom: 2px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">
				<xsl:value-of select="$type" />
			</td>
			<td style="font-family: Tahoma;font-size: 11px;padding-left:5px;">
				<xsl:value-of select="$value" />
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>