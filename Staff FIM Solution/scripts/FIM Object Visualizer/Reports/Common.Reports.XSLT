<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt" xmlns:dsml="http://www.dsml.org/DSML" xmlns:fn="http://www.w3.org/2005/xpath-functions">
  <!--<xsl:include href="./Common.xslt"/>-->
  <xsl:include href="./Common.Synchronization Rules.Include.xslt"/>
  <!--===================================================================================================================================-->
  <!-- Templates to display the TOC and detail sections                                                                                  -->
  <!--===================================================================================================================================-->
  <xsl:template match="ResourceManagementObject" mode="toc">
    <xsl:param name="ObjectTypes" />
    <xsl:variable name="ObjectType" select="ObjectType" />
    <xsl:variable name="ObjectIdentifier" select="ObjectIdentifier" />
    <xsl:variable name="PrevIndex" select="position()-1" />
    <xsl:variable name="PrevObjectType">
      <xsl:choose>
        <xsl:when test="position()=1"></xsl:when>
        <xsl:when test="$ObjectTypes">
          <xsl:value-of select="ms:node-set($ObjectTypes)/objectTypes/objectType[$PrevIndex]/text()" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="(ObjectType!=$PrevObjectType)">
      <tr>
        <td colspan="6">
          <xsl:call-template name="subheadstyle" />
          <xsl:text>Resource Type: </xsl:text>
          <xsl:value-of select="ObjectType/text()"/>
        </td>
      </tr>
      <tr>
        <td colspan="6">
          <ol>
            <!-- [ObjectIdentifier=$ObjectIdentifier] -->
            <xsl:apply-templates select="//ResourceManagementObject[ObjectType=$ObjectType]" mode="toc2">
              <xsl:sort select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value/text()"/>
              <xsl:with-param name="tocTitle" select="'DisplayName'" />
              <xsl:with-param name="ObjectType" select="$ObjectType"/>
            </xsl:apply-templates>
          </ol>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>
  <xsl:template match="ResourceManagementObject" mode="tocRH">
    <xsl:variable name="ObjectIdentifier" select="ObjectIdentifier" />
    <xsl:variable name="CreatedTime" select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='CreatedTime']/Value" />
    <!-- TOC -->
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="concat('#',substring-after(ObjectIdentifier,'urn:uuid:'))"/>
        </xsl:attribute>
        <xsl:value-of select="$CreatedTime"/>
        <xsl:text> : </xsl:text>
        <!--<xsl:value-of select="dsml:GetDateTimeExpr(string($CreatedTime))"/>
        <xsl:text> : </xsl:text>-->
        <xsl:value-of select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
      </a>
    </li>
  </xsl:template>  
  <xsl:template match="ResourceManagementObject" mode="detail">
    <xsl:param name="ObjectTypes" />
    <xsl:variable name="ObjectType" select="ObjectType" />
    <xsl:variable name="ObjectIdentifier" select="ObjectIdentifier" />
    <xsl:variable name="PrevIndex" select="position()-1" />
    <xsl:variable name="PrevObjectType">
      <xsl:choose>
        <xsl:when test="position()=1"></xsl:when>
        <xsl:when test="$ObjectTypes">
          <xsl:value-of select="ms:node-set($ObjectTypes)/objectTypes/objectType[$PrevIndex]/text()" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="ObjectType!=$PrevObjectType">
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Resource Type: </xsl:text>
          <xsl:value-of select="ObjectType/text()"/>
        </td>
      </tr>
      <tr>
        <td colspan="6">
          <!-- [ObjectIdentifier=$ObjectIdentifier] -->
          <xsl:apply-templates select="//ResourceManagementObject[ObjectType=$ObjectType]/ResourceManagementAttributes" mode="detail">
            <xsl:sort select="Value/text()"/>
            <xsl:with-param name="ObjectType" select="$ObjectType"/>
            <xsl:with-param name="ObjectId" select="substring-after(ObjectIdentifier,'urn:uuid:')"/>
          </xsl:apply-templates>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>
  <xsl:template match="ResourceManagementObject" mode="detailForOID">
    <xsl:param name="ObjectTypes" />
    <xsl:variable name="ObjectType" select="ObjectType" />
    <xsl:variable name="ObjectIdentifier" select="ObjectIdentifier" />
    <xsl:variable name="PrevIndex" select="position()-1" />
    <xsl:variable name="PrevObjectType">
      <xsl:choose>
        <xsl:when test="position()=1"></xsl:when>
        <xsl:when test="$ObjectTypes">
          <xsl:value-of select="ms:node-set($ObjectTypes)/objectTypes/objectType[$PrevIndex]/text()" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="ObjectType!=$PrevObjectType">
      <tr>
        <td colspan="6">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>Resource Type: </xsl:text>
          <xsl:value-of select="ObjectType/text()"/>
        </td>
      </tr>
      <tr>
        <td colspan="6">
          <!-- [ObjectIdentifier=$ObjectIdentifier] -->
          <xsl:apply-templates select="//ResourceManagementObject[ObjectType=$ObjectType][ObjectIdentifier=$ObjectIdentifier]/ResourceManagementAttributes" mode="detail">
            <xsl:sort select="Value/text()"/>
            <xsl:with-param name="ObjectType" select="$ObjectType"/>
            <xsl:with-param name="ObjectId" select="substring-after(ObjectIdentifier,'urn:uuid:')"/>
          </xsl:apply-templates>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>
  <xsl:template match="ResourceManagementObject" mode="toc2">
    <xsl:param name="tocTitle" />
    <xsl:param name="ObjectType" />
    <!-- TOC -->
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="concat('#',substring-after(ObjectIdentifier,'urn:uuid:'))"/>
        </xsl:attribute>
        <xsl:value-of select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName=$tocTitle]/Value"/>
      </a>
    </li>
  </xsl:template>
  <xsl:template match="ResourceManagementAttributes" mode="detail">
    <xsl:param name="ObjectType" />
    <xsl:param name="ObjectId" />
    <tr>
      <td colspan="5">
        <xsl:call-template name="subheadstyle" />
        <a>
          <xsl:attribute name="name">
            <xsl:value-of select="concat('#',substring-after(ResourceManagementAttribute[AttributeName='ObjectID']/Value,'urn:uuid:'))"/>
          </xsl:attribute>
        </a>
        <xsl:value-of select="position()"/>
        <xsl:text>. </xsl:text>
        <xsl:value-of select="ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
      </td>
      <td>
        <xsl:call-template name="subheadrightstyle" />
        <a href="#top">^Top</a>
      </td>
    </tr>
    <xsl:choose>
      <xsl:when test="$ObjectType='SynchronizationRule'">
        <xsl:call-template name="SynchronizationRuleInclude">
          <xsl:with-param name="filter" select="ResourceManagementAttribute[AttributeName='ObjectID']/Value"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="($ObjectType='AttributeTypeDescriptionX')">
        <!-- do nothing -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="ResourceManagementAttribute">
          <xsl:choose>
            <xsl:when test="(AttributeName='ObjectType') or (AttributeName='CreatedTime') or (AttributeName='ObjectID')">
              <!-- do nothing -->
            </xsl:when>
            <xsl:when test="(AttributeName='Creator' and not($ObjectType='Request'))">
            </xsl:when>
            <xsl:when test="AttributeName='SyncConfig-export-attribute-flow'
                      or AttributeName='SyncConfig-schema'
                      or AttributeName='SyncConfig-ma-run-data'
                      or AttributeName='SyncConfig-join'
                      or AttributeName='SyncConfig-projection'
                      or AttributeName='SyncConfig-attribute-inclusion'
                      or AttributeName='SyncConfig-controller-configuration'
                      or AttributeName='SyncConfig-ma-ui-settings'
                      or AttributeName='SyncConfig-password-sync'
                      or AttributeName='SyncConfig-private-configuration'
                      or AttributeName='SyncConfig-ma-partition-data'">
              <xsl:call-template name="DataItem">
                <xsl:with-param name="property" select="AttributeName" />
                <xsl:with-param name="value" select="'*** xml - see sync rules ***'" />
                <xsl:with-param name="valueSpan" select="5" />
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="AttributeName='DEEWR-selfServicePassword'">
              <xsl:call-template name="DataItem">
                <xsl:with-param name="property" select="AttributeName" />
                <xsl:with-param name="value" select="'*** binary string ***'" />
                <xsl:with-param name="valueSpan" select="5" />
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="AttributeName='ExplicitMember'">
              <xsl:call-template name="DataItem">
                <xsl:with-param name="property" select="AttributeName" />
                <xsl:with-param name="value" select="'*** various ***'" />
                <xsl:with-param name="valueSpan" select="5" />
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="AttributeName='RequestParameter'">
              <xsl:apply-templates select="RequestParameter">
                <xsl:with-param name="property" select="RequestParameter/type" />
                <xsl:with-param name="value" select="." />
                <xsl:with-param name="valueSpan" select="5" />
              </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="AttributeName='XOML'">
              <xsl:apply-templates select="Activity">
                <xsl:with-param name="property" select="'Workflow Activity'" />
                <xsl:with-param name="value" select="." />
                <xsl:with-param name="valueSpan" select="5" />
              </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="AttributeName='Filter'">
              <xsl:call-template name="QueryDataItem">
                <xsl:with-param name="property" select="AttributeName" />
                <xsl:with-param name="value" select="dsml:GetTextFromXmlText(string(Value))" />
                <xsl:with-param name="valueSpan" select="5" />
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="AttributeName='StringRegex'">
              <xsl:call-template name="QueryDataItem">
                <xsl:with-param name="property" select="AttributeName" />
                <xsl:with-param name="value" select="dsml:ReplaceString(string(Value),'|','| ')" />
                <xsl:with-param name="valueSpan" select="5" />
              </xsl:call-template>
            </xsl:when>
            <!--
            <xsl:when test="AttributeName='FilterXXX'">
              <xsl:call-template name="QueryDataItem">
                <xsl:with-param name="property" select="AttributeName" />
                <xsl:with-param name="value" select="substring-before(substring-after(Value,'&lt;Filter xmlns:xsi=&quot;http://www.w3.org/2001/XMLSchema-instance&quot; xmlns:xsd=&quot;http://www.w3.org/2001/XMLSchema&quot; Dialect=&quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&quot; xmlns=&quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&quot;>'),'&lt;/Filter>')" />
                <xsl:with-param name="valueSpan" select="5" />
              </xsl:call-template>
            </xsl:when>
            -->
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="Value">
                  <xsl:call-template name="DataItem">
                    <xsl:with-param name="property" select="AttributeName" />
                    <xsl:with-param name="value" select="Value" />
                    <xsl:with-param name="valueSpan" select="5" />
                  </xsl:call-template>
                </xsl:when>
                <xsl:when test="Values">
                  <xsl:call-template name="DataItemMV">
                    <xsl:with-param name="property" select="AttributeName" />
                    <xsl:with-param name="value" select="Values"/>
                    <xsl:with-param name="valueSpan" select="5" />
                  </xsl:call-template>
                  <!--
                  <xsl:for-each select="Values/string[text()]">
                    <xsl:if test="not(position()='1')">
                      <xsl:text>; </xsl:text>
                    </xsl:if>
                    <xsl:call-template name="DataItem">
                      <xsl:with-param name="property" select="../AttributeName" />
                      <xsl:with-param name="value" select="text()" />
                      <xsl:with-param name="valueSpan" select="5" />
                    </xsl:call-template>
                  </xsl:for-each>
                  <xsl:call-template name="DataItem">
                    <xsl:with-param name="property" select="AttributeName" />
                    <xsl:with-param name="value">
                      <xsl:apply-templates select="Values" mode="multiValue"/>
                    </xsl:with-param>
                    <xsl:with-param name="valueSpan" select="5" />
                  </xsl:call-template>
                  -->
                </xsl:when>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="Activity">
    <xsl:param name="property" />
    <xsl:param name="value" />
    <xsl:param name="colspanProperty" />
    <xsl:param name="colspanValue" />
    <tr valign="top">
      <th colspan="{$colspanProperty}">
        <!--style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;"-->
        <xsl:call-template name="headstyle"/>
        <!--<xsl:if test="$colspanProperty">
          <xsl:attribute name="colspan">
            <xsl:value-of select="$colspanProperty"/>
          </xsl:attribute>
        </xsl:if>-->
        <xsl:value-of select="$property"/>
        <xsl:text> #</xsl:text>
        <xsl:value-of select="position()"/>
      </th>
      <th colspan="{$colspanProperty}">
        <!--style="text-align:left;font-weight:normal;padding-left:10px;padding-right:10px;"-->
        <xsl:call-template name="leftcell"/>
        <table id="tdata" width="100%">
          <xsl:call-template name="tablestyle" />
          <tr>
            <td colspan="5">
              <xsl:call-template name="subheadstyle" />
              <xsl:value-of select="Type"/>
            </td>
          </tr>
          <tr>
            <xsl:for-each select="*[not(name(.)='Type')]">
              <xsl:variable name="key">
                <xsl:choose>
                  <xsl:when test="(name(.)='SynchronizationRuleId') or (name(.)='FilterScopeIdentifier') or (name(.)='EmailTemplate')">
                    <xsl:value-of select="concat('urn:uuid:',dsml:ToLowerCase(string(.)))"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="."/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:call-template name="DataItem">
                <xsl:with-param name="property" select="name(.)" />
                <xsl:with-param name="value" select="$key" />
                <xsl:with-param name="valueSpan" select="5" />
              </xsl:call-template>
            </xsl:for-each>
          </tr>
        </table>
      </th>
    </tr>
  </xsl:template>
  <xsl:template match="RequestParameter">
    <xsl:param name="property" />
    <xsl:param name="value" />
    <xsl:param name="colspanProperty" />
    <xsl:param name="colspanValue" />
    <tr valign="top">
      <th colspan="{$colspanProperty}">
        <!--style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;"-->
        <xsl:call-template name="headstyle"/>
        <xsl:value-of select="position()"/>
        <xsl:text>. </xsl:text>
        <xsl:value-of select="$property"/>
      </th>
      <th colspan="{$colspanProperty}">
        <!--style="text-align:left;font-weight:normal;padding-left:10px;padding-right:10px;"-->
        <xsl:call-template name="leftcell"/>
        <table id="tdata" width="100%">
          <xsl:call-template name="tablestyle" />
          <tr>
            <td colspan="5">
              <xsl:call-template name="subheadstyle" />
              <xsl:value-of select="PropertyName"/>
            </td>
          </tr>
          <tr>
            <xsl:for-each select="*[not(name(.)='type' or name(.)='Target' or name(.)='PropertyName')]">
              <xsl:call-template name="DataItem">
                <xsl:with-param name="property" select="name(.)" />
                <xsl:with-param name="value">
                  <xsl:text>uuid:</xsl:text>
                  <xsl:choose>
                    <xsl:when test="(../PropertyName='DEEWR-selfServicePassword') and (name(.)='Value')">
                      <xsl:value-of select="'*** binary string ***'" />
                    </xsl:when>
                    <xsl:when test="(../PropertyName='ExplicitMember') and (name(.)='Value')">
                      <xsl:value-of select="'*** various ***'" />
                    </xsl:when>
                    <xsl:when test="(../PropertyName='Filter') and (name(.)='Value')">
                      <xsl:value-of select="substring-before(substring-after(.,'&lt;Filter xmlns:xsi=&quot;http://www.w3.org/2001/XMLSchema-instance&quot; xmlns:xsd=&quot;http://www.w3.org/2001/XMLSchema&quot; Dialect=&quot;http://schemas.microsoft.com/2006/11/XPathFilterDialect&quot; xmlns=&quot;http://schemas.xmlsoap.org/ws/2004/09/enumeration&quot;>'),'&lt;/Filter>')" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="."/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="valueSpan" select="5" />
              </xsl:call-template>
            </xsl:for-each>
          </tr>
        </table>
      </th>
    </tr>
  </xsl:template>
  <xsl:template name="unreferenced">
    <xsl:param name="ObjectType"/>
    <xsl:param name="header"/>
    <tr>
      <td colspan="6">
        <xsl:call-template name="reportheadstyle" />
        <xsl:value-of select="$header"/>
      </td>
    </tr>
    <tr>
      <td colspan="6" style="background:yellow;">
        <xsl:apply-templates select="//ResourceManagementObject[ObjectType=$ObjectType][contains(ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value,'DEEWR')]" mode="unreferenced">
          <xsl:sort select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
        </xsl:apply-templates>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="ResourceManagementObject" mode="unreferenced">
    <xsl:variable name="filterId" select="ObjectIdentifier"/>
    <xsl:variable name="callingMPRId_Principal" select="//ResourceManagementObject[ObjectType='Set'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='PrincipalSet']/Values/string=$filterId]/ObjectIdentifier"/>
    <xsl:variable name="callingMPRId_ResourceCurrentSet" select="//ResourceManagementObject[ObjectType='Set'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='ResourceCurrentSet']/Values/string=$filterId]/ObjectIdentifier"/>
    <xsl:variable name="callingMPRId_ResourceFinalSet" select="//ResourceManagementObject[ObjectType='Set'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='ResourceFinalSet']/Values/string=$filterId]/ObjectIdentifier"/>
    <xsl:variable name="ActionWorkflowDefinition" select="//ResourceManagementObject[ObjectType='ManagementPolicyRule'][ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='ActionWorkflowDefinition']/Values/string=$filterId]/ObjectIdentifier"/>
    <xsl:choose>
      <xsl:when test="$callingMPRId_Principal or $callingMPRId_ResourceCurrentSet or $callingMPRId_ResourceFinalSet or $ActionWorkflowDefinition">
        <!--<xsl:value-of select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/> (OK)-->
      </xsl:when>
      <xsl:otherwise>
        <li>
          <a href="#{substring-after($filterId,'urn:uuid:')}">
            <xsl:value-of select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value"/>
          </a>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>