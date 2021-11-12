<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="iso-8859-1" indent="yes" method="html" version="4.0" />
  <xsl:template match="/">
		<table style="font-family: Tahoma;font-size: 11px;border-top: #E6E6E6 1px solid;border-right: #E6E6E6 1px solid;border-left: #E6E6E6 1px solid;border-bottom: #E6E6E6 1px solid;" id="tdata">
      <tr>
        <td colspan="4" style="font-family: Tahoma;font-size: 11px;padding: 10px;font-weight: bold;background: rgb(234,242,255);border-bottom: 1px solid rgb(120,172,255);">
          Object Definition for 	<xsl:value-of select="//Attributes/@ObjectType" />
        </td>
      </tr>
      <tr>
        <td style="font-family: Tahoma;font-size: 11px;text-align: left;padding: 5px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">
          Name
        </td>
        <td style="font-family: Tahoma;font-size: 11px;text-align: center;padding: 5px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">
          Required
        </td>
        <td style="font-family: Tahoma;font-size: 11px;text-align: center;padding: 5px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">
          Type
        </td>
        <td style="font-family: Tahoma;font-size: 11px;text-align: left;padding: 5px;font-weight: normal;white-space: nowrap;background-color:#E6E6E6;">
          Description
        </td>
      </tr>
      <xsl:for-each select="//Attribute">
        <xsl:sort select="IsRequired" order="descending"/>
        <tr>
          <xsl:choose>
            <xsl:when test="(position() mod 2 = 0)">
              <xsl:attribute name="style">
                background-color:#F5F5DC;
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="style">
                background-color:white;
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <td valign="top" style="font-family: Tahoma;font-size: 11px;padding:5px;">
            <xsl:value-of select="AttributeName" />
          </td>
          <td valign="top" style="text-align: center;font-family: Tahoma;font-size: 11px;padding:5px;">
            <xsl:value-of select="IsRequired" />
          </td>
          <td valign="top" style="text-align: center;font-family: Tahoma;font-size: 11px;padding:5px;">
            <xsl:value-of select="AttributeType" />
          </td>
          <td valign="top" style="font-family: Tahoma;font-size: 11px;padding:5px;">
            <xsl:value-of select="AttributeDescription" />
          </td>
        </tr>
      </xsl:for-each>
		</table>
	</xsl:template>
</xsl:stylesheet>