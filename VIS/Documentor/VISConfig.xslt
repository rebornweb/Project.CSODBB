<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt">
  <xsl:include href="./Common.xslt"/>
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:variable name="hrefsOn" select="1" />
  <xsl:template match="/">
    <xsl:call-template name="VISConfiguration" />
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to display the Main VIS Configuration Sections                              -->
  <!--======================================================================================-->
  <xsl:template name="VISConfiguration">
	<xsl:if test="$hrefsOn=1">
    <table>
      <tr valign="top">
        <td>
          <a href="http://optimalidm.com/our-products/virtual-identity-server-vis/">
            <img alt="OptimalIdM" src="data:image/jpeg;base64,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" />
          </a>
        </td>
        <td>
          <a href="http://education.qld.gov.au/">
            <img alt="Education Queensland" src="data:image/jpeg;base64,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" />
          </a>
        </td>
      </tr>
    </table>
	</xsl:if>
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="100">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>VIS Configuration - TOC</xsl:text>
        </td>
      </tr>
      <xsl:apply-templates select="configuration/configurationSection" mode="toc"/>
      <tr/>
    </table>
    <hr/>
    <xsl:apply-templates select="configuration/configurationSection" mode="main"/>
  </xsl:template>

  <xsl:template match="configurationSection" mode="toc">
	<xsl:param name="prevPos"/>
    <!-- TOC -->
    <tr valign="top">
      <td>
        <xsl:choose>
          <xsl:when test="configurationSection">
            <xsl:attribute name="colspan">2</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="colspan">98</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="subheadstyle" />
		<!--<xsl:value-of select="$prevPos"/><xsl:text>: </xsl:text>-->
		<xsl:value-of select="@type"/><xsl:text>: </xsl:text>
		<xsl:if test="@type='JOIN_TO_ATTRIBUTE'">
			<br/>
		</xsl:if>
		  <xsl:choose>
		  <xsl:when test="$hrefsOn=1">
			  <a>
				<xsl:attribute name="href">
				  <xsl:text>#Section:</xsl:text>
				  <xsl:value-of select="configurationItem[@name='id']/text()"/>
				</xsl:attribute>
				<xsl:value-of select="configurationItem[@name='name']/text()"/>
			  </a>
		  </xsl:when>
		  <xsl:otherwise>
				<xsl:value-of select="configurationItem[@name='name']/text()"/>
		  </xsl:otherwise>
		  </xsl:choose>
      </td>
      <xsl:if test="configurationSection">
        <td colspan="1">
          <xsl:call-template name="headstyle" />
          <table id="tdata">
            <xsl:call-template name="tablestyle" />
            <tr valign="top">
              <td colspan="1">
                <!--<xsl:call-template name="headstyle"/>-->
                <xsl:apply-templates select="configurationSection" mode="toc">
					<xsl:with-param name="prevPos" select="position()" />
					<xsl:sort select="@type"/>
				</xsl:apply-templates>
              </td>
            </tr>
          </table>
        </td>
      </xsl:if>
    </tr>
  </xsl:template>

  <xsl:template match="configurationSection" mode="main">
    <!-- Main Configuration Section -->
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="99">
          <xsl:call-template name="reportheadstyle" />
          <a>
            <xsl:attribute name="name">
              <xsl:text>#Section:</xsl:text>
              <xsl:value-of select="configurationItem[@name='id']/text()"/>
            </xsl:attribute>
          </a>
          <xsl:value-of select="@type"/> Main Section - 
          <xsl:value-of select="configurationItem[@name='name']/text()"/>
        </td>
        <td colspan="1" align="right">
          <xsl:call-template name="reportheadstyle" />
		  <xsl:choose>
		  <xsl:when test="$hrefsOn=1">
			<a href="#top">^Top</a>
		  </xsl:when>
		  <xsl:otherwise>
		  </xsl:otherwise>
		  </xsl:choose>
        </td>
      </tr>
      <tr valign="top">
        <td border="1" colspan="100">
          <xsl:call-template name="centercell" />
          <table width="100%" id="tdata">
            <xsl:call-template name="tablestyle" />
            <xsl:apply-templates select="configurationItem"/>
          </table>
        </td>
      </tr>
    </table>
    <xsl:if test="configurationSection">
      <!-- Sub Configuration Sections -->
      <table id="tdata">
        <xsl:call-template name="tablestyle" />
        <tr valign="top">
          <td border="1" colspan="100">
            <xsl:call-template name="centercell" />
            <table width="100%" id="tdata">
              <xsl:call-template name="tablestyle" />
              <xsl:apply-templates select="configurationSection" mode="sub">
					<xsl:sort select="@type"/>
				</xsl:apply-templates>
            </table>
          </td>
        </tr>
      </table>
    </xsl:if>
    <hr/>
  </xsl:template>

  <xsl:template match="configurationSection" mode="sub">
    <!-- Sub Configuration Section -->
    <tr valign="top">
      <!--<td style="text-align:left;border-bottom:black 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#a5ffcb;font-weight:bold;padding-top:5px">-->
	  <td colspan="99">
          <xsl:call-template name="reportheadstyle" />
        <a>
          <xsl:attribute name="name">
            <xsl:text>#Section:</xsl:text>
            <xsl:value-of select="configurationItem[@name='id']/text()"/>
          </xsl:attribute>
        </a>
        <xsl:value-of select="@type"/> Sub Section - 
        <xsl:value-of select="configurationItem[@name='name']/text()"/>
      </td>
      <!--<td style="text-align:right;border-bottom:black 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#a5ffcb;font-weight:bold;padding-top:5px">-->
	  <td colspan="1" align="right">
          <xsl:call-template name="reportheadstyle" />
		  <xsl:choose>
		  <xsl:when test="$hrefsOn=1">
			<a href="#top">^Top</a>
		  </xsl:when>
		  <xsl:otherwise>
		  </xsl:otherwise>
		  </xsl:choose>
      </td>
    </tr>
    <tr valign="top">
      <td border="1" colspan="100">
        <xsl:call-template name="centercell" />
        <table width="100%" id="tdata">
          <xsl:call-template name="tablestyle" />
          <xsl:apply-templates select="configurationItem"/>
        </table>
      </td>
    </tr>
    <tr valign="top">
      <td border="1" colspan="100">
        <xsl:call-template name="centercell" />
        <table width="100%" id="tdata">
          <xsl:call-template name="tablestyle" />
          <!--<xsl:if test="configurationSection/configurationItem/@name">
            <tr valign="top">
              <td colspan="2" style="text-align:left;border-bottom:black 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px">
                <xsl:text>SUBSECTION: </xsl:text>
				<xsl:value-of select="configurationSection/configurationItem[@name='name']/text()"/>
              </td>
            </tr>
          </xsl:if>-->
          <xsl:apply-templates select="configurationSection" mode="sub">
				<xsl:sort select="@type"/>
			</xsl:apply-templates>
        </table>
      </td>
    </tr>
    <xsl:if test="position() != last()">
      <tr>
        <td colspan="100" style="color:#F7FBFA;">
          <xsl:text>-</xsl:text>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template match="configurationItem">
    <!-- Configuration Item -->
    <xsl:if test="@name != 'id'">
      <xsl:call-template name="DataItem">
        <xsl:with-param name="property" select="@name" />
        <xsl:with-param name="value">
          <xsl:call-template name="HandleSplit">
            <xsl:with-param name="value" select="text()"/>
            <xsl:with-param name="delim" select="','"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="HandleSplit">
    <!-- Template to ensure delimited strings with no spaces are padded out to allow HTML wrap -->
    <xsl:param name="value"/>
    <xsl:param name="delim"/>
    <xsl:choose>
      <xsl:when test="substring-before($value,$delim)">
        <xsl:value-of select="substring-before($value,$delim)"/>
        <xsl:value-of select="$delim"/>
        <xsl:if test="substring-after($value,$delim)">
          <xsl:text xml:space="preserve"> </xsl:text>
          <xsl:call-template name="HandleSplit">
            <xsl:with-param name="value" select="substring-after($value,$delim)"/>
            <xsl:with-param name="delim" select="$delim"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>