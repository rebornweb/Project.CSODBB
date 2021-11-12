<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt" xmlns:dsml="http://www.dsml.org/DSML">
  <xsl:include href="./Common.xslt"/>
  <xsl:include href="./Common.Script.xslt"/>
  <xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes" />
  <xsl:template match="/">
    <xsl:call-template name="IdentityBrokerAdapters" />
  </xsl:template>
  <!--======================================================================================-->
  <!-- Template to display the Identity Broker Adapters                                     -->
  <!--======================================================================================-->
  <xsl:template name="IdentityBrokerAdapters">
    <table id="tdata">
      <xsl:call-template name="tablestyle" />
      <tr>
        <td colspan="4">
          <xsl:call-template name="reportheadstyle" />
          <a name="top"/>
          <xsl:text>Identity Broker 3.0 - Adapter Definitions</xsl:text>
        </td>
      </tr>
      <tr>
        <td colspan="4">
          <xsl:call-template name="reportheadstyle" />
          <ul>
            <xsl:apply-templates select="//AdapterEngineConfigurations/AdapterConfiguration" mode="toc">
              <xsl:sort select="../../@AdapterName"/>
              <xsl:sort select="@AdapterName"/>
            </xsl:apply-templates>
          </ul>
        </td>
      </tr>
      <xsl:apply-templates select="//AdapterEngineConfigurations/AdapterConfiguration" mode="body">
        <xsl:sort select="../../@AdapterName"/>
        <xsl:sort select="@AdapterName"/>
      </xsl:apply-templates>
    </table>
  </xsl:template>
  <xsl:template match="AdapterConfiguration" mode="body">
    <tr>
      <td style="text-align:left;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px" colspan="3">
        <xsl:choose>
          <xsl:when test="../../@AdapterName">
            <xsl:apply-templates select="../../image" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="image" />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>  </xsl:text>
        <a>
          <xsl:attribute name="name">
            <xsl:text>#Adapter:</xsl:text>
            <xsl:if test="../../@AdapterName">
              <xsl:value-of select="../../@AdapterName"/>
              <xsl:text>:</xsl:text>
            </xsl:if>
            <xsl:value-of select="@AdapterName"/>
          </xsl:attribute>
        </a>
        <xsl:if test="../../@AdapterName">
          <xsl:value-of select="../../@AdapterName"/>
          <xsl:text>:</xsl:text>
        </xsl:if>
        <xsl:value-of select="@AdapterName"/>
      </td>
      <td style="text-align:right;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px">
        <a href="#top">^Top</a>
      </td>
      <xsl:call-template name="DataItem">
        <xsl:with-param name="property" select="'Type'"/>
        <xsl:with-param name="value">
          <xsl:choose>
            <xsl:when test="../../@AdapterName">
              <xsl:text>Composite</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>Single</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
		  <xsl:with-param name="colspanValue" select="3" />
      </xsl:call-template>
      <xsl:call-template name="DataItem">
        <xsl:with-param name="property" select="'Class'" />
        <xsl:with-param name="value" select="@class" />
		  <xsl:with-param name="colspanValue" select="3" />
      </xsl:call-template>
      <xsl:call-template name="DataItem">
        <xsl:with-param name="property" select="'Base Connector'" />
        <xsl:with-param name="value" select="dsml:GetConnectorName(string(@BaseConnectorId))" />
		  <xsl:with-param name="colspanValue" select="3" />
      </xsl:call-template>
      <xsl:call-template name="DataItem">
        <xsl:with-param name="property" select="'DN Template'" />
        <!--<xsl:with-param name="value" select="dn/@template" />-->
        <xsl:with-param name="value">
          <xsl:apply-templates select="dn/dnComponent" />
        </xsl:with-param>
		  <xsl:with-param name="colspanValue" select="3" />
      </xsl:call-template>
    </tr>
    <xsl:if test="adapterEntityTransformationFactory[@name='ChainList'][adapter]">
      <tr>
        <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
          <xsl:text>Section</xsl:text>
        </th>
        <td colspan="3">
          <xsl:call-template name="reportheadstyle" />
          <xsl:text>ChainList Adapters</xsl:text>
        </td>
      </tr>
      <xsl:apply-templates select="adapterEntityTransformationFactory/adapter" mode="ChainList">
        <xsl:sort select="@name"/>
      </xsl:apply-templates>
    </xsl:if>
    <xsl:if test="adapterEntityTransformationFactory[@name='Sequential'][adapter]">
      <tr>
		  <td style="text-align:left;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px">
          <!--<xsl:text>Section</xsl:text>-->
        </td>
		  <td style="text-align:left;border-bottom:green 1px solid;padding-bottom:5px;padding-left:10px;padding-right:10px;background:#e9ffcb;font-weight:bold;padding-top:5px" colspan="3">
          <!--<xsl:text>Attribute Extensions</xsl:text>-->
        </td>
      </tr>
      <xsl:apply-templates select="adapterEntityTransformationFactory/adapter" mode="ChainList">
        <xsl:sort select="@name"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  <xsl:template match="columnMappings">
    <tr>
		<td style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;" />
      <td>
        <xsl:value-of select="@SourceAttribute"/>
      </td>
      <td>
        <xsl:value-of select="@TargetAttribute"/>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="adapter" mode="ChainList">
    <xsl:choose>
      <xsl:when test="@name='Multivalue.GenerateDNs'">
        <tr>
          <th style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;">
            <xsl:text>DN Mapping</xsl:text>
          </th>
        </tr>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'InputKey'" />
          <xsl:with-param name="value" select="Extended/@InputKey" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Group Target'" />
          <xsl:with-param name="value" select="Extended/@GroupTarget" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'DN Template'" />
          <!--<xsl:with-param name="value" select="Extended/dn/@template" />-->
          <xsl:with-param name="value">
            <xsl:apply-templates select="Extended/dn/dnComponent" />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@name='ConstantValue'">
        <tr>
          <th style="text-align:right;background:#CCCCCC;padding-left:10px;padding-right:10px;">
            <xsl:value-of select="substring-after(@name,'Unify.Transformations.')"/>
            <xsl:text> ConstantValue</xsl:text>
          </th>
          <td colspan="3">
            <xsl:call-template name="reportheadstyle" />
			<xsl:value-of select="Extended/value/@TargetColumn"/>
          </td>
        </tr>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Value Type'" />
          <xsl:with-param name="value" select="Extended/value/@valueType" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Value'" />
          <xsl:with-param name="value" select="Extended/value/text()" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@name='TimeOffset'">
        <tr>
          <th style="text-align:right;background:#CCCCCC;padding-left:10px;padding-right:10px;">
            <xsl:value-of select="substring-after(@name,'Unify.Transformations.')"/>
            <xsl:text> TimeOffset</xsl:text>
          </th>
          <td colspan="3">
            <xsl:call-template name="reportheadstyle" />
			<xsl:value-of select="Extended/@destinationColumn"/>
          </td>
        </tr>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Source column'" />
          <xsl:with-param name="value" select="Extended/@sourceColumn" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Offset'" />
          <xsl:with-param name="value" select="Extended/@offset" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Adjust for local'" />
          <xsl:with-param name="value" select="Extended/@adjustForLocal" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@name='Move' or @name='Unify.Transformations.Join'">
        <xsl:if test="@name='Unify.Transformations.Join'">
          <tr>
            <th style="text-align:right;background:#CCCCCC;padding-left:10px;padding-right:10px;">
              <xsl:value-of select="substring-after(@name,'Unify.Transformations.')"/>
              <xsl:text> Relationships</xsl:text>
            </th>
            <th>
              <xsl:call-template name="headstyle" />Input Key
            </th>
            <th colspan="2">
              <xsl:call-template name="headstyle" />Relationship Key
            </th>
          </tr>
          <xsl:apply-templates select="Extended/Relationships" />
        </xsl:if>
        <tr>
          <th style="text-align:right;background:#CCCCCC;padding-left:10px;padding-right:10px;">
            <xsl:value-of select="substring-after(@name,'Unify.Transformations.')"/>
            <xsl:text> Column Mappings</xsl:text>
          </th>
          <th>
            <xsl:call-template name="headstyle" />Source
          </th>
          <th colspan="2">
            <xsl:call-template name="headstyle" />Target
          </th>
        </tr>
        <xsl:apply-templates select="Extended/columnMappings/columnMapping" />
      </xsl:when>
      <xsl:when test="@name='Unify.Transformations.Group'">
        <tr>
          <th style="text-align:right;background:#CCCCCC;padding-left:10px;padding-right:10px;">
            <xsl:text>Group</xsl:text>
          </th>
          <td colspan="3">
            <xsl:call-template name="reportheadstyle" />
            <xsl:value-of select="Extended/@GroupTarget"/>
          </td>
        </tr>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Name'" />
          <xsl:with-param name="value" select="@name" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'DN'" />
          <!--<xsl:with-param name="value" select="Extended/dn/@template" />-->
          <xsl:with-param name="value">
            <xsl:apply-templates select="Extended/dn/dnComponent" />
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Relationships'" />
          <xsl:with-param name="value" select="dsml:GetConnectorName(string(Extended/@RelationshipConnectorId))" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Relation key'" />
          <xsl:with-param name="value" select="Extended/Relationships/Relationship/@InputKey" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Relation reference'" />
          <xsl:with-param name="value" select="Extended/Relationships/Relationship/@RelationshipKey" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Filter'" />
          <xsl:with-param name="value" select="Extended/Filter/@filterType" />
          <xsl:with-param name="value">
            <xsl:choose>
              <xsl:when test="Extended/Filter/@filterType = 'Unify.EntityFilters.Passthrough'">
                <xsl:text>None</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="Extended/Filter/@filterType"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Window'" />
          <xsl:with-param name="value">
            <xsl:choose>
              <xsl:when test="Extended/Window/@windowType = 'Unify.Windows.Default'">
                <xsl:text>None</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="Extended/Window/@windowType"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@name='Relational'">
        <tr>
          <th style="text-align:right;background:#CCCCCC;padding-left:10px;padding-right:10px;">
            <xsl:text>Reference target</xsl:text>
          </th>
          <td colspan="3">
            <xsl:call-template name="reportheadstyle" />
			<xsl:choose>
				<xsl:when test="Extended/@target">
					<xsl:value-of select="Extended/@target"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Multiple mappings</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
          </td>
        </tr>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Name'" />
          <xsl:with-param name="value" select="@name" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Input key'" />
          <xsl:with-param name="value" select="Extended/@InputKey" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Relationship connector'" />
          <xsl:with-param name="value" select="dsml:GetConnectorName(string(Extended/@RelationshipConnectorId))" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
		<xsl:if test="Extended/columnMappings">
			<tr>
			  <td style="text-align:right;background:#CCCCCC;padding-left:10px;padding-right:10px;">
				<xsl:value-of select="substring-after(@name,'Unify.Transformations.')"/>
				<xsl:text> Column Mappings</xsl:text>
			  </td>
			  <th>
				<xsl:call-template name="headstyleL" />Source
			  </th>
			  <th colspan="2">
				<xsl:call-template name="headstyleL" />Target
			  </th>
			</tr>
			<xsl:apply-templates select="Extended/columnMappings/columnMapping" />
		</xsl:if>
      </xsl:when>
      <xsl:when test="@name='Relational.dn' or @name='Relational.Compare.String'">
        <tr>
          <th style="text-align:right;background:#CCCCCC;padding-left:10px;padding-right:10px;">
            <xsl:text>Reference target</xsl:text>
          </th>
          <td colspan="3">
            <xsl:call-template name="reportheadstyle" />
			<xsl:choose>
				<xsl:when test="Extended/dn/@target">
					<xsl:value-of select="Extended/dn/@target"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Multiple mappings</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
          </td>
        </tr>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Name'" />
          <xsl:with-param name="value" select="@name" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Input key'" />
          <xsl:with-param name="value" select="Extended/@InputKey" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Relationship connector'" />
          <xsl:with-param name="value" select="dsml:GetConnectorName(string(Extended/@RelationshipConnectorId))" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Relationship key'" />
          <xsl:with-param name="value" select="Extended/@RelationshipKey" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
		<xsl:if test="Extended/@PriorityKey">
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Priority key'" />
			  <xsl:with-param name="value" select="Extended/@PriorityKey" />
				<xsl:with-param name="colspanValue" select="3" />
			</xsl:call-template>
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Priority key values'" />
			  <xsl:with-param name="value">
				<xsl:apply-templates select="Extended/items/item" />
			  </xsl:with-param>
			<xsl:with-param name="colspanValue" select="3" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Extended/dn">
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property">
				<xsl:choose>
				  <xsl:when test="Extended/dn/@target">
					<xsl:text>DN - </xsl:text>
					<xsl:value-of select="Extended/dn/@target"/>
				  </xsl:when>
				  <xsl:when test="Extended/@GroupTarget">
					<xsl:text>DN - </xsl:text>
					<xsl:value-of select="Extended/@GroupTarget"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:text>DN</xsl:text>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:with-param>
			  <xsl:with-param name="value">
				<xsl:apply-templates select="Extended/dn/dnComponent" />
			  </xsl:with-param>
			  <xsl:with-param name="colspanValue" select="3" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Extended/columnMappings">
			<tr>
			  <td style="text-align:right;background:#CCCCCC;padding-left:10px;padding-right:10px;">
				<xsl:value-of select="substring-after(@name,'Unify.Transformations.')"/>
				<xsl:text> Column Mappings</xsl:text>
			  </td>
			  <th>
				<xsl:call-template name="headstyleL" />Source
			  </th>
			  <th colspan="2">
				<xsl:call-template name="headstyleL" />Target
			  </th>
			</tr>
			<xsl:apply-templates select="Extended/columnMappings/columnMapping" />
		</xsl:if>
      </xsl:when>
      <xsl:when test="@name='Relational.Composite'">
        <tr>
          <th style="text-align:right;background:#CCCCCC;padding-left:10px;padding-right:10px;">
            <xsl:text>Reference target</xsl:text>
          </th>
          <td colspan="3">
            <xsl:call-template name="reportheadstyle" />
			<xsl:choose>
				<xsl:when test="Extended/dn/@target">
					<xsl:value-of select="Extended/dn/@target"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Multiple mappings</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
          </td>
        </tr>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Name'" />
          <xsl:with-param name="value" select="@name" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Relationship connector'" />
          <xsl:with-param name="value" select="dsml:GetConnectorName(string(Extended/@RelationshipConnectorId))" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
		<xsl:if test="Extended/@PriorityKey">
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Priority key'" />
			  <xsl:with-param name="value" select="Extended/@PriorityKey" />
			<xsl:with-param name="colspanValue" select="3" />
			</xsl:call-template>
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Priority key values'" />
			  <xsl:with-param name="value">
				<xsl:apply-templates select="Extended/items/item" />
			  </xsl:with-param>
			<xsl:with-param name="colspanValue" select="3" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Extended/@RelationReference">
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Relationship key'" />
			  <xsl:with-param name="value" select="Extended/@RelationshipKey" />
			  <xsl:with-param name="colspanValue" select="3" />
			</xsl:call-template>
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Relation reference'" />
			  <xsl:with-param name="value" select="Extended/@RelationReference" />
			<xsl:with-param name="colspanValue" select="3" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Extended/Relationships">
          <tr>
            <td style="text-align:right;background:#CCCCCC;padding-left:10px;padding-right:10px;">
              <xsl:value-of select="substring-after(@name,'Unify.Transformations.')"/>
              <xsl:text> Relationships</xsl:text>
            </td>
            <th>
              <xsl:call-template name="headstyle" />Input Key
            </th>
            <th colspan="2">
              <xsl:call-template name="headstyle" />Relationship Key
            </th>
          </tr>
			<xsl:apply-templates select="Extended/Relationships" />
		</xsl:if>
		<xsl:if test="Extended/@InputKey">
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Input key'" />
			  <xsl:with-param name="value" select="Extended/@InputKey" />
			  <xsl:with-param name="colspanValue" select="3" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Extended/columnMappings">
			<tr>
			  <td style="text-align:right;background:#CCCCCC;padding-left:10px;padding-right:10px;">
				<xsl:value-of select="substring-after(@name,'Unify.Transformations.')"/>
				<xsl:text> Column Mappings</xsl:text>
			  </td>
			  <th>
				<xsl:call-template name="headstyleL" />Source
			  </th>
			  <th colspan="2">
				<xsl:call-template name="headstyleL" />Target
			  </th>
			</tr>
			<xsl:apply-templates select="Extended/columnMappings/columnMapping" />
		</xsl:if>
      </xsl:when>
      <xsl:when test="@name='Relation.Group.dn' or @name='Relation.Group' or @name='Relation.Group.Composite.Filter.String'">
        <tr>
          <th style="text-align:right;background:#CCCCCC;padding-left:10px;padding-right:10px;">
            <xsl:text>Reference group target</xsl:text>
          </th>
          <td colspan="3">
            <xsl:call-template name="reportheadstyle" />
            <xsl:value-of select="Extended/@GroupTarget"/>
          </td>
        </tr>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Name'" />
          <xsl:with-param name="value" select="@name" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property" select="'Relationship connector'" />
          <xsl:with-param name="value" select="dsml:GetConnectorName(string(Extended/@RelationshipConnectorId))" />
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
		<xsl:if test="Extended/@InputKey">
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Input key'" />
			  <xsl:with-param name="value" select="Extended/@InputKey" />
			<xsl:with-param name="colspanValue" select="3" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Extended/@RelationKey">
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Relation key'" />
			  <xsl:with-param name="value" select="Extended/@RelationKey" />
			<xsl:with-param name="colspanValue" select="3" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Extended/@RelationshipFilterKey">
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Relationship filter key'" />
			  <xsl:with-param name="value" select="Extended/@RelationshipFilterKey" />
			<xsl:with-param name="colspanValue" select="3" />
			</xsl:call-template>
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Relationship filter key values'" />
			  <xsl:with-param name="value">
				<xsl:apply-templates select="Extended/FilterValues/FilterValue" />
			  </xsl:with-param>
			<xsl:with-param name="colspanValue" select="3" />
			</xsl:call-template>
		</xsl:if>
        <xsl:call-template name="DataItem">
          <xsl:with-param name="property">
            <xsl:choose>
              <xsl:when test="Extended/dn/@target">
                <xsl:text>DN - </xsl:text>
                <xsl:value-of select="Extended/dn/@target"/>
              </xsl:when>
              <xsl:when test="Extended/@GroupTarget">
                <xsl:text>DN - </xsl:text>
                <xsl:value-of select="Extended/@GroupTarget"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>DN</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="value">
            <xsl:apply-templates select="Extended/dn/dnComponent" />
          </xsl:with-param>
		  <xsl:with-param name="colspanValue" select="3" />
        </xsl:call-template>
		<xsl:if test="Extended/@RelationReference">
			<xsl:call-template name="DataItem">
			  <xsl:with-param name="property" select="'Relation reference'" />
			  <xsl:with-param name="value" select="Extended/@RelationReference" />
			<xsl:with-param name="colspanValue" select="3" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Extended/Relationships">
          <tr>
            <td style="text-align:right;background:#CCCCCC;padding-left:10px;padding-right:10px;">
              <xsl:value-of select="substring-after(@name,'Unify.Transformations.')"/>
              <xsl:text> Relationships</xsl:text>
            </td>
            <th>
              <xsl:call-template name="headstyle" />Input Key
            </th>
            <th colspan="2">
              <xsl:call-template name="headstyle" />Relationship Key
            </th>
          </tr>
			<xsl:apply-templates select="Extended/Relationships" />
		</xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <tr>
          <th style="text-align:right;background:#CCCCCC;padding-left:10px;padding-right:10px;">
            <xsl:text>Unexpected Transformation</xsl:text>
          </th>
          <td colspan="3">
            <xsl:call-template name="reportheadstyle" />
            <xsl:value-of select="@name"/>
          </td>
        </tr>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="Relationships">
	<xsl:apply-templates select="Relationship"/>
  </xsl:template>
  <xsl:template match="FilterValue">
    <xsl:if test="position()>1">
      <xsl:text>,</xsl:text>
    </xsl:if>
	<xsl:value-of select="text()"/>
  </xsl:template>
  <xsl:template match="item">
    <xsl:if test="position()>1">
      <xsl:text>,</xsl:text>
    </xsl:if>
	<xsl:value-of select="text()"/>
  </xsl:template>
  <xsl:template match="columnMapping">
    <tr>
		<td style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;" />
      <td colspan="1">
        <xsl:value-of select="@SourceAttribute"/>
      </td>
      <td colspan="1">
        <xsl:value-of select="@TargetAttribute"/>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="Relationship">
    <tr>
		<td style="text-align:left;background:#CCCCCC;padding-left:10px;padding-right:10px;" />
      <td colspan="1">
        <xsl:value-of select="@InputKey"/>
      </td>
      <td colspan="1">
        <xsl:value-of select="@RelationshipKey"/>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="dnComponent">
    <xsl:if test="position()>1">
      <xsl:text>,</xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@name='Constant'">
        <xsl:value-of select="@attributeType"/>
        <xsl:text>=</xsl:text>
        <xsl:value-of select="@value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@attributeType"/>
        <xsl:text>={</xsl:text>
        <xsl:value-of select="@key"/>
        <xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="dnComponentX">
    <tr>
      <xsl:call-template name="multiline" />
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@name"/>
      </td>
      <xsl:choose>
        <xsl:when test="@name='Field'">
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@key"/>
          </td>
          <td/>
        </xsl:when>
        <xsl:when test="@name='Constant'">
          <td/>
          <td>
            <xsl:call-template name="centercell" />
            <xsl:value-of select="@value"/>
          </td>
        </xsl:when>
        <xsl:otherwise>
          <td colspan="2"/>
        </xsl:otherwise>
      </xsl:choose>
      <td>
        <xsl:call-template name="centercell" />
        <xsl:value-of select="@attributeType"/>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="AdapterConfiguration" mode="toc">
    <!-- TOC -->
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:text>#Adapter:</xsl:text>
          <xsl:if test="../../@AdapterName">
            <xsl:value-of select="../../@AdapterName"/>
            <xsl:text>:</xsl:text>
          </xsl:if>
          <xsl:value-of select="@AdapterName"/>
        </xsl:attribute>
        <xsl:if test="../../@AdapterName">
          <xsl:value-of select="../../@AdapterName"/>
          <xsl:text>:</xsl:text>
        </xsl:if>
        <xsl:value-of select="@AdapterName"/>
      </a>
    </li>
  </xsl:template>
  <xsl:template match="image">
    <img>
      <xsl:attribute name="alt">
        <xsl:value-of select="../@AdapterName"/>
      </xsl:attribute>
      <xsl:attribute name="src">
        <xsl:text>data:image/jpeg;base64,</xsl:text>
        <xsl:value-of select="node()"/>
      </xsl:attribute>
    </img>
  </xsl:template>
</xsl:stylesheet>