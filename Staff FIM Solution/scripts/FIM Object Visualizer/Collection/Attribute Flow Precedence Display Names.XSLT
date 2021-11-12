<?xml version="1.0" encoding="utf-8" ?>
<?xml-stylesheet type="text/css" href="Style.css" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="iso-8859-1" indent="yes" method="html" version="4.0" />
	<xsl:template match="/">
		<table class="tmain" id="tdata">
			<tr>
				<td style="font-family: Tahoma; font-size:11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: rgb(234,242,255);border-bottom: 1px solid rgb(120,172,255);">
          <xsl:text>Attribute Flow Precedence</xsl:text>
        </td>
			</tr>
			<tr>
				<td>
					<ol style="font-family: Tahoma; font-size:11px; line-height: 30px;">
						<xsl:variable name="filter" select="Results/@Filter" />
						<xsl:for-each select="//import-flow-set">
							<xsl:sort select="@mv-object-type" />
	            <li>
								<xsl:choose>
									<xsl:when test="(position() mod 2 = 0)">
										<xsl:attribute name="class">lidsp2</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="class">lidsp1</xsl:attribute>	
									</xsl:otherwise>
								</xsl:choose>
                <a>
									<xsl:attribute name="href">
										<xsl:text>#</xsl:text>
									</xsl:attribute>
									<xsl:attribute name="onclick">
										<xsl:text>vbscript:ShowAttributeFlowPrecedenceFor &#39;</xsl:text>
										<xsl:value-of select="@mv-object-type" />
										<xsl:text>&#39;</xsl:text>
									</xsl:attribute>
									<xsl:value-of select="@mv-object-type" />
								</a>
							</li>
						</xsl:for-each>
					</ol>
				</td>
			</tr>
		</table>
	</xsl:template>
</xsl:stylesheet>