<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
	<xsl:param name="filter" />
	<xsl:template match="/">
		<table id="tdata">
			<xsl:call-template name="TableStyle" />
			<tr>
				<td colspan="4">
					<xsl:call-template name="SectionStyle" />
					<xsl:text>Metaverse Attribute Flow Configuration for  </xsl:text>
					<xsl:value-of select="$filter" />
				</td>
			</tr>
			<xsl:for-each select="//import-flow-set[@mv-object-type=$filter]/import-flows">
				<xsl:sort select="@mv-attribute" />
        <xsl:if test="position()!=1">
          <tr>
            <td colspan="6" heigth="5px" style="color:#F7FBFA;background-color:#F7FBFA;border-top:1px RGB(212,208,200) solid;">
              <xsl:text>-</xsl:text>
            </td>
          </tr>
        </xsl:if>      
				<tr>
					<td colspan="4">
						<xsl:call-template name="MetaverseAttributeStyle" />
						<xsl:value-of select="@mv-attribute" />
						<xsl:text>, </xsl:text>
						<xsl:value-of select="@type" />
					</td>
				</tr>
				<xsl:call-template name="ImportFlow" />
			</xsl:for-each>
		</table>
	</xsl:template>
	<!--======================================================================================-->
	<!-- Template to display import flows                                                     -->
	<!--======================================================================================-->
	<xsl:template name="ImportFlow" match="import-flow">
		<tr>
			<td><xsl:call-template name="HeadLeftStyle" />Management Agent</td>
			<td><xsl:call-template name="HeadCenterStyle" />Object Type</td>

			<td><xsl:call-template name="HeadCenterStyle" />Type</td>
			<td><xsl:call-template name="HeadCenterStyle" />Source Attributes</td>
		</tr>
		<xsl:for-each select="import-flow">
			<tr>
        <xsl:if test="(position() mod 2 = 0)">
          <xsl:attribute name="bgcolor">#F5F5DC</xsl:attribute>
        </xsl:if>
				<td>
					<xsl:call-template name="LeftData" />
					<xsl:variable name="guid" select="@src-ma" />
					<xsl:value-of select="//ma-data/ma[@Guid=$guid]/@Name" />
				</td>
				<td>
					<xsl:call-template name="CenterData" />
					<xsl:value-of select="@cd-object-type" />
				</td>
				<td style="text-align:left;">
					<xsl:call-template name="CenterData" />
					<xsl:choose>
						<xsl:when test="count(direct-mapping)&gt;0">
							<xsl:text>d</xsl:text>
						</xsl:when>
						<xsl:when test="count(scripted-mapping)&gt;0">
							<xsl:text>s</xsl:text>
						</xsl:when>
						<xsl:when test="count(sync-rule-mapping)&gt;0">
							<xsl:text>sr</xsl:text>
						</xsl:when>
					</xsl:choose>
				</td>
				<td>
					<xsl:call-template name="LeftData" />
					<xsl:choose>
						<xsl:when test="count(direct-mapping)&gt;0">
							<xsl:value-of select="direct-mapping/src-attribute" />
						</xsl:when>
						<xsl:when test="count(scripted-mapping)&gt;0">
							<xsl:for-each select="scripted-mapping/src-attribute">
								<xsl:value-of select="." />
								<xsl:if test="not(position()=last())">
									<xsl:text>, </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:when test="count(sync-rule-mapping)&gt;0">
              <xsl:choose>
                <xsl:when test="count(sync-rule-mapping[@mapping-type='expression']) &gt; 0">
                  <xsl:for-each select="sync-rule-mapping/sync-rule-value/import-flow">
                    <xsl:call-template name="DisplayFunction" />
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="count(sync-rule-mapping[@mapping-type='direct']) &gt; 0">
                  <xsl:value-of select="sync-rule-mapping/src-attribute" />
                </xsl:when>
                <xsl:otherwise>
                  <strong>
                  <xsl:text>Constant: </xsl:text>
                  </strong>
                  <xsl:value-of select="sync-rule-mapping/sync-rule-value" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
					</xsl:choose>
				</td>
			</tr>
		</xsl:for-each>
	</xsl:template>
	<!--======================================================================================-->
	<!-- Template to add a table style                                                        -->
	<!--======================================================================================-->
	<xsl:template name="TableStyle">
		<xsl:attribute name="style">
			font-family: Tahoma;
			font-size:11px;
			border-top:1px RGB(212,208,200) solid;
			border-left:1px RGB(212,208,200) solid;
			border-right:1px RGB(212,208,200) solid;
			border-bottom:1px RGB(212,208,200) solid;
			padding:0px;
		</xsl:attribute>
	</xsl:template>
	<!--======================================================================================-->
	<!-- Template to add a head style                                                         -->
	<!--======================================================================================-->
	<xsl:template name="SectionStyle">
		<xsl:attribute name="style">
			padding-top:10px;
			padding-bottom:10px;
			padding-left:10px;
			padding-right:10px;
			font-weight:bold;
			background:rgb(234,242,255);
			border-bottom:1px solid rgb(120,172,255);
		</xsl:attribute>
	</xsl:template>
	<!--======================================================================================-->
	<!-- Template to add a head style                                                        -->
	<!--======================================================================================-->
	<xsl:template name="MetaverseAttributeStyle">
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
	<!-- Template to add a head style                                                        -->
	<!--======================================================================================-->
	<xsl:template name="HeadLeftStyle">
		<xsl:attribute name="style">
			text-align:left;
			<xsl:call-template name="HeadStyle" />
		</xsl:attribute>
	</xsl:template>
	<!--======================================================================================-->
	<!-- Template to add a head style                                                        -->
	<!--======================================================================================-->
	<xsl:template name="HeadCenterStyle">
		<xsl:attribute name="style">
			text-align:center;
			<xsl:call-template name="HeadStyle" />
		</xsl:attribute>
	</xsl:template>
	<!--======================================================================================-->
	<!-- Template to add a head style                                                        -->
	<!--======================================================================================-->
	<xsl:template name="HeadStyle">
    background:#CCCCCC;
    border-right:#666666 1px solid;
    border-bottom:#666666 1px solid;
    padding-left:10px;
    padding-right:10px;
    font-weight:normal;
    white-space:nowrap;
  </xsl:template>
	<!--======================================================================================-->
	<!-- Template to add a left data style                                                    -->
	<!--======================================================================================-->
	<xsl:template name="LeftData">
		<xsl:attribute name="style">
			padding-left:10px;
			padding-right:10px;
			font-weight:normal;"
		</xsl:attribute>
	</xsl:template>
	<!--======================================================================================-->
	<!-- Template to add a centered data style                                                -->
	<!--======================================================================================-->
	<xsl:template name="CenterData">
		<xsl:attribute name="style">
			padding-left:10px;
			padding-right:10px;
			white-space:nowrap;
			text-align:center;
			font-weight:normal;
		</xsl:attribute>
	</xsl:template>
  <!--=============================================================================================================================================================-->
  <!-- Template to display functions                                                                                                                               -->
  <!--=============================================================================================================================================================-->
  <xsl:template name="DisplayFunction">
    <xsl:param name="value" />

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