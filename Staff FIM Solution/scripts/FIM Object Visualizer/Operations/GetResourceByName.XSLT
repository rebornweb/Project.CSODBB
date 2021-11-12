<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt" xmlns:dsml="http://www.dsml.org/DSML" xmlns:ms-dsml="http://www.microsoft.com/MMS/DSML">
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:template match="/">
    <table id="tdata" style="border-collapse:collapse;border-top: #E6E6E6 1px solid;border-left: #E6E6E6 1px solid;border-right: #E6E6E6 1px solid;border-bottom: #E6E6E6 1px solid;">
      <tr>
        <td colspan="2" class="label" style="font-family: Tahoma;font-size: 11px;padding-top: 5px;padding-bottom: 5px;padding-left: 10px;padding-right: 10px;font-weight: bold;background: rgb(234,242,255);border-bottom: 1px solid rgb(120,172,255);">
          <xsl:text>Export Object - </xsl:text>
          <xsl:value-of select="//ObjectType" />
        </td>
      </tr>
      <xsl:for-each select="//ResourceManagementAttribute">
        <tr>
          <xsl:call-template name="headercell">
            <xsl:with-param name="value" select="AttributeName" />
          </xsl:call-template>
          <xsl:call-template name="datacell">
            <xsl:with-param name="value" select="." />
          </xsl:call-template>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>
  <!--===================================================================================================================================-->
  <!-- Template to display the header cell                                                                                               -->
  <!--===================================================================================================================================-->
  <xsl:template name="headercell">
    <xsl:param name="value" />
    <th style="text-align: left;font-family: Tahoma;font-size: 11px;padding-left: 5px;padding-right: 5px;padding-top: 5px;padding-bottom: 5px;background-color:#E6E6E6;">
      <xsl:value-of select="$value"/>
    </th>
  </xsl:template>
  <!--===================================================================================================================================-->
  <!-- Template to display a data iten                                                                                                   -->
  <!--===================================================================================================================================-->
  <xsl:template name="datacell">
    <xsl:param name="value" />
    <td style="text-align:left;font-family:Tahoma;font-size:11px;padding-left:5px;padding-right:5px;padding-top:5px;padding-bottom:5px">
      <xsl:choose>
        <xsl:when test="IsMultiValue = 'false'">
          <xsl:call-template name="displayvalue">
            <xsl:with-param name="value" select="Value" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="count(Values/string) &lt; 2">
              <xsl:call-template name="displayvalue">
                <xsl:with-param name="value" select="Values/string" />
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <ul style="list-style-type: square;padding: 8px;margin: 4px;">
                <xsl:for-each select="Values/string">
                  <li style="font-family: Tahoma;font-size: 11px;">
                    <xsl:call-template name="displayvalue">
                      <xsl:with-param name="value" select="." />
                    </xsl:call-template>
                  </li>
                </xsl:for-each>
              </ul>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </xsl:template>
  <!--===================================================================================================================================-->
  <!-- Template to display a data value                                                                                                  -->
  <!--===================================================================================================================================-->
  <xsl:template name="displayvalue">
    <xsl:param name="value" />
    <xsl:choose>
      <xsl:when test="starts-with($value, 'urn:uuid:')">
        <xsl:value-of select="substring-after($value, 'urn:uuid:')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
