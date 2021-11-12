<!--
    Copyright(c)2003 Microsoft Corporation. All rights reserved.
    Modified: Bob Bradley, UNIFY Solutions, 31/8/2008 - implemented alternative version to GetMAName to support independant use of this stylesheet from MVConfigurationViewer.exe
-->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns="http://www.w3.org/1999/xhtml" xmlns:ms-dsml="http://www.microsoft.com/MMS/DSML" xmlns:ms-dsml2="http://www.microsoft.com/MMS/DSML" xmlns:dsml="http://www.dsml.org/DSML" xmlns:msxsl="urn:schemas-microsoft-com:xslt">  

<msxsl:script language='JScript' implements-prefix="ms-dsml">
<![CDATA[

var FinalSrcAttrs = "";
function RemovePoundSign(Node)
{
	if( Node != null )
 		return Node.substr(1);
	else
		return Node;
}

function IsRanked( precType )
{
	if( precType == "ranked" )
		return true;
	else
		return false;

}

function ConstValue( value )
{
    var constMapping = "Constant-";
    return constMapping.concat(value);
}

function DNValue( part )
{
    var dnMapping = "DN Component-";
    return dnMapping.concat(part);
}

function ScriptContext( context )
{
    var scriptMapping = "Rules Extension-";
    return scriptMapping.concat(context);
}

function IsNotScripted( type )
{
    if( type == "declared")
        return true;
    else
        return false;

}

function IsScripted( type )
{
    if( type == "scripted")
        return true;
    else
        return false;

}


function SrcAttrs( attr )
{
	if( FinalSrcAttrs == "" )
	{
		FinalSrcAttrs = FinalSrcAttrs.concat(attr);
	}
	else
	{
		FinalSrcAttrs = FinalSrcAttrs.concat(",");
		FinalSrcAttrs = FinalSrcAttrs.concat(attr);
	}

}

function FinalListOfAttrs()
{
	var list = FinalSrcAttrs;
	FinalSrcAttrs = "";
	return list;
}

function ObjTypePlusMVAttr(objtype,attr)
{
    var finalStr;
    var colon=" : ";
    finalStr = objtype.concat(colon);
    finalStr = finalStr.concat(attr);
    return finalStr;    
}

function GetMAName(maGuid)
{
	var Service = GetObject("winmgmts:root\\MicrosoftIdentityIntegrationServer");
	var ManagementAgents = Service.ExecQuery("Select * from MIIS_ManagementAgent Where GUID = '" + maGuid + "'");
	var enum = new Enumerator(ManagementAgents);
	for (;!enum.atEnd();enum.moveNext()) 
	{ 
		var objItem = enum.item();
		maGuid = objItem.Name;
		break;
	}
	return maGuid;
}

function GetMANameOrig(maGuid)
{  
   var shell = new ActiveXObject("WScript.Shell")
   var env = shell.Environment("process")
   var tempPath = env("TEMP")    

   
 
   var postFix = ".txt";
   var fileName = tempPath.concat("\\");
   var fileName = fileName.concat(maGuid);
   fileName = fileName.concat(postFix);   

    
   var fso,ts;
   var ForReading = 1;
   fso = new ActiveXObject("Scripting.FileSystemObject");
 
   if (fso.FileExists(fileName))
    {
        ts = fso.OpenTextFile(fileName, ForReading);
        var maName = ts.ReadLine();    
        ts.Close();
        return maName;    
    }
    else    
        return maGuid;
 	
}

function TrueOrFalse(Node)
{
	if( Node == "" || Node == null)
 		return "false";
	else
		return Node;
}

function IsEnabled(value)
{
	if( value == "1" )
	    return true;
	else
	    return false;
}

function InProc(value)
{
	if( value == "high" )
	    return "Yes";
	else
	    return "No";
}

function Syntax(Node)
{
	if( Node == "1.3.6.1.4.1.1466.115.121.1.27" )
		return "Integer";
	else if( Node == "1.3.6.1.4.1.1466.115.121.1.5" )
		return "Binary";
	else if( Node == "1.3.6.1.4.1.1466.115.121.1.15" )
		return "String";
	else if( Node == "1.3.6.1.4.1.1466.115.121.1.7" )
		return "Boolean";
	else if( Node == "1.3.6.1.4.1.1466.115.121.1.12" )
		return "Reference";
	else
		return Node;	
}


]]>
</msxsl:script>


<xsl:template match="/">
    <html>	
     <basefont face="Verdana" size="2"/>
      <head>      
      </head>
     <STYLE type="text/css">
       @page FullPage{margin-left:1.0in;margin-right:0.5in}

        h1,h3{margin: 0px; padding: 0px;}
        #S1 {width: 300px;}
        h1 {color: #AAAAAA; font-size: 500%;}
        h3 {color: #AAAAAA; font-size: 200%;}
               
        
        .thAttributeFlow{background-color:#bbbbbb;  FONT-SIZE: 70%;}
        .thAttributeFlow1{background-color:#dddddd; FONT-SIZE: 70%;}
        .thAttributeFlow2{background-color:#dddddd; FONT-SIZE: 70%; width:50px}

        .tableMenu{FONT-SIZE: 300%; FONT-FAMILY: Verdana;  width:575px}
        .tdMenu{border-right: 1px solid #999999;text-align:center;}
        .trMenu{background-color:#ffffff;}
        .tdValue{FONT-SIZE: 60%; FONT-FAMILY: Verdana;word-wrap: break-word;}
        .tdHeader{FONT-SIZE: 60%; FONT-FAMILY: Verdana;word-wrap: break-word;}

        .tableClass2{cellspacing:'0' cellpadding:'0'; border='1'; width:100% FONT-SIZE: 80%; FONT-FAMILY: Verdana;  border-color: #eeeeee; border-style:solid; PADDING: .25em;}
        .tableClass3{width:50px;}
        .tableClass4{width:575px;vertical-align:left}
        .tableClass5{vertical-align:middle; width:375px}
        .tdLeftSection{background-color:#eeeeee; FONT-SIZE: 70%; text-align:center;}
        

        A{color:#0000FF; text-decoration: none;}
        a:active {text-decoration: underline;}
        a:hover {text-decoration: underline;}
        img {border: none; }
        .imgbanner {border: none; width:10px;}
        .my .ct p {padding: 0px 0px 3px 0px;}
        #btnsearch {border: none; margin-left: 95px; margin-top: -25px;}
        body,div,span,p,ul,td,th,input,select,textarea,button {font-family: Arial, sans-serif; font-size: 70%;}
        td{font-size: 70%;word-wrap:break-word;}


        .tdClass1{font-size: 70%; width:400px; word-wrap:break-word;}
        .tdClass2{font-size: 70%; width:350px; word-wrap:break-word;}
        .tdClass3{font-size: 70%; width:175px; word-wrap:break-word;}
        .tdClass4{font-size: 70%; width:20px; word-wrap:break-word;}
        .tdClass5{font-size: 70%; width:350px; word-wrap:break-word;}
        .tdClass6{font-family: Symbol;font-size: 70%; color:blue; text-align:center; width:8%;}
        .tdClass7{font-size: 70%; word-wrap:break-word; width:350px;}

        body {page:FullPage;}
        br.clear, .clrbth {clear: both;}
        hr {height: 1px; padding: 0px; border:1px solid; color:#BBBBBB; }
        ol {list-style-position: outside; margin: -2px 0px 0px 23px;}
        li {list-style-position: outside; margin: -2px 0px 0px 12px; padding: 0; margin-left: 20px;}      
       </STYLE>	
      <body>
      <xsl:choose>
      <xsl:when test="//saved-mv-configuration">
      <table width="80%">
      <tr>
        <h3 align="center">Metaverse Configuration</h3>   
      </tr>
      <tr>
      <td class="tdMenu" width="16%">
        <A href="#provisioning"><font face="verdana" size="2"><b>Provisioning</b></font></A>   
       </td>
       <td class="tdMenu" width="16%">
        <A href="#mvdelrules"><font face="verdana" size="2"><b>Metaverse Deletion Rules</b></font></A>   
       </td>  
       <td class="tdMenu" width="16%">
        <A href="#mvextension"><font face="verdana" size="2"><b>Metaverse Extension</b></font></A>   
       </td>    
       <td class="tdMenu" width="16%">
        <A href="#iafrules"><font face="verdana" size="2"><b>Import Attribute Flow Rules</b></font></A>   
       </td>      
       <td class="tdMenu" width="16%">
        <A href="#mvobjtypes"><font face="verdana" size="2"><b>Metaverse Object Types</b></font></A>   
       </td>    
       <td class="tdMenu" width="16%">
        <A href="#mvattrs"><font face="verdana" size="2"><b>Metaverse Attributes</b></font></A>   
       </td>  
       <td class="tdMenu" width="16%">
        <A href="#pwdchghist"><font face="verdana" size="2"><b>WMI Password Change History</b></font></A>           
       </td>        	        
       <td class="tdMenu" width="16%">
        <A href="#pwdsync"><font face="verdana" size="2"><b>Password Sync</b></font></A>   
       </td>  
       </tr>      
      </table>  
      <br/>
      <br/>
    <table cellspacing="4" cellpadding="0" bordercolordark="#ffffff" border="1" width="80%">
    <tr>
    <td class="tdLeftSection" width="10%"><b>Provisioning</b></td>
    <td>
    <a NAME="#provisioning"></a>
    <xsl:for-each select="//provisioning">   
    <table cellspacing='0' cellpadding='0' bordercolordark='#ffffff' border='1' width="100%">        
		<tr>
		<td class="tdValue" width="25%"><b>Type</b></td>
		<td class="tdValue" width="25%"><xsl:value-of select="./@type"/></td>
		</tr>		
	</table>	
	</xsl:for-each>
    </td>
    </tr>   
    <tr>
    <a NAME="#mvdelrules"></a>
    <td class="tdLeftSection"><b>MV-Deletion-Rules</b></td>
    <xsl:choose>
    <xsl:when test="//mv-deletion/mv-deletion-rule">           
    <td>    
    <xsl:for-each select="//mv-deletion/mv-deletion-rule">    
    <table cellspacing='0' cellpadding='1' bordercolordark='#ffffff' border='1' width="100%">        
        <tr>
        <td class="tdValue" width="25%" bgcolor="#bbbbbb"><b>MV Object Type</b></td>
        <td class="tdValue" width="25%" bgcolor="#bbbbbb"><b>Type of Rule</b></td>
        <td class="tdValue"  width="25%" bgcolor="#bbbbbb"><b>Source MA</b></td>
        </tr>
		<tr>				
		<td class="tdValue"><xsl:value-of select="./@mv-object-type"/></td>				
		<xsl:choose>
        <xsl:when test="ms-dsml:IsScripted(string(./@type))">
		    <td class="tdValue" >Rules Extension</td>				
		</xsl:when>
		<xsl:otherwise>
		    <td class="tdValue" >Declared</td>				
		</xsl:otherwise>	
		</xsl:choose>			
		<xsl:choose>
        <xsl:when test="ms-dsml:IsNotScripted(string(./@type))">
		    <td class="tdValue" ><xsl:value-of select="ms-dsml:GetMAName(string(./src-ma))"/></td>				
		</xsl:when>
		<xsl:otherwise>
		    <td class="tdValue" >-</td>				
		</xsl:otherwise>	
		</xsl:choose>	
		</tr>		
	</table>	
	<br/>	
	</xsl:for-each>	
    </td> 
    </xsl:when>       
    <xsl:otherwise>
        <td class="tdValue"><b>None</b></td>
    </xsl:otherwise> 
    </xsl:choose>              
    </tr>
    <tr>
    <a NAME="#mvextension"></a>
    <td class="tdLeftSection"><b>MV Extension</b></td>
    <xsl:for-each select="//extension">
    <xsl:choose>
    <xsl:when test="./assembly-name">
    <td>
    <table cellspacing='0' cellpadding='1' bordercolordark='#ffffff' border='1' width="100%">        
		<tr>
		<td class="tdValue"  width="25%" bgcolor="#bbbbbb"><b>Assembly Name</b></td>
		<td class="tdValue"  width="25%"><xsl:value-of select="./assembly-name"/></td>
		</tr>
		<tr>
		<td class="tdValue"  width="25%" bgcolor="#bbbbbb"><b>Run In Separate Process</b></td>
		<td class="tdValue"  width="25%"><xsl:value-of select="ms-dsml:InProc(string(./application-protection))"/></td>
		</tr>
	</table>	
	</td>
	</xsl:when>
	<xsl:otherwise><td class="tdValue" ><b>None</b></td></xsl:otherwise>
	</xsl:choose>
	</xsl:for-each>    
    </tr>    
    <tr>
    <a NAME="#iafrules"></a>    
    <td class="tdLeftSection"><b>Import Attribute Flow</b></td>            
    <xsl:choose>
    <xsl:when test="//import-attribute-flow/import-flow-set">       
    <td>   
    <xsl:for-each select="//import-attribute-flow/import-flow-set">                        
    <xsl:variable name="mvobjtype" select="./@mv-object-type"/>    
            <xsl:for-each select="./import-flows">
            <xsl:variable name="precedencetype" select="./@type"/>
            <table cellspacing='0' cellpadding='0' bordercolordark='#ffffff' border='1' width="100%">
		    <tr>		  		              
		        <td class="tdValue"  colspan="2" bgcolor="#bbbbbb"><b>Destination Attribute</b></td>		        
		        <td class="tdValue"  align="center" colspan="3" bgcolor="#bbbbbb"><b><xsl:value-of select="ms-dsml:ObjTypePlusMVAttr(string($mvobjtype),string(./@mv-attribute))"/></b></td>		        		        		        
		    </tr>			    		    	
		    <tr>
		        <td class="tdValue" width="5%" bgcolor="#EBEBEB"><b>Precedence</b></td>		        		        		        
		        <td class="tdValue" width="15%" bgcolor="#EBEBEB"><b>Management Agent</b></td>		        
		        <td class="tdValue" width="10%" bgcolor="#EBEBEB"><b>CD-Object Type</b></td>		
		        <td class="tdValue" width="35%" bgcolor="#EBEBEB"><b>CD-Attribute(s)</b></td>				        
		        <td class="tdValue" width="35%" bgcolor="#EBEBEB"><b>Mapping Type</b></td>		        		        
		    </tr>  		    
		    <xsl:for-each select="./import-flow">		    
		    <tr>
				<xsl:choose>
				<xsl:when test="ms-dsml:IsRanked(string($precedencetype))">
					<td width="5%" class="tdValue"><xsl:value-of select="position()"/></td>		        		        
		        </xsl:when>
		        <xsl:otherwise>
					<td width="5%" class="tdValue">manual</td>		        
		        </xsl:otherwise>
		        </xsl:choose>
		        <td width="15%" class="tdValue"><xsl:value-of select="ms-dsml:GetMAName(string(./@src-ma))"/></td>
		        <td width="10%" class="tdValue"><xsl:value-of select="./@cd-object-type"/></td>		        
		        <xsl:if test="./sync-rule-mapping">
		            <td width="35%" class="tdValue" ><xsl:value-of select="./sync-rule-mapping/src-attribute"/></td>	
		            <td width="35%" class="tdValue">Direct (SR)</td>		            
		        </xsl:if>	        		        		        
		        <xsl:if test="./direct-mapping">
		            <td width="35%" class="tdValue" ><xsl:value-of select="./direct-mapping/src-attribute"/></td>	
		            <td width="35%" class="tdValue">DirectXXX</td>		            
		        </xsl:if>	        		        		        
		        <xsl:if test="./scripted-mapping">			        
					<xsl:for-each select="./scripted-mapping/src-attribute">		    
						<xsl:value-of select="ms-dsml:SrcAttrs(string(.))"/>
					</xsl:for-each>
					<td width="35%" class="tdValue"><xsl:value-of select="ms-dsml:FinalListOfAttrs()"/></td>
		            <td width="35%" class="tdValue"><xsl:value-of select="ms-dsml:ScriptContext(string(./scripted-mapping/script-context))"/></td>
		        </xsl:if>
		        <xsl:if test="./constant-mapping">
		            <td width="35%" class="tdValue">-</td>
		            <td width="35%" class="tdValue"><xsl:value-of select="ms-dsml:ConstValue(string(./constant-mapping/constant-value))"/></td>
		        </xsl:if>
		        <xsl:if test="./dn-part-mapping">
					<td width="35%" class="tdValue">-</td>
		            <td width="35%" class="tdValue"><xsl:value-of select="ms-dsml:DNValue(string(./dn-part-mapping/dn-part))"/></td>
		        </xsl:if>		        		        
		    </tr>		   		    	    
		    </xsl:for-each>
		    </table>	
		    <br/>			
		    </xsl:for-each>		    
		    <br/>
     </xsl:for-each>    
     </td>		
     </xsl:when>
     <xsl:otherwise>
     <td class="tdValue"><b>None</b></td>
     </xsl:otherwise>
     </xsl:choose>
	</tr>  
    <tr>
    <a NAME="#mvobjtypes"></a>
    <td class="tdLeftSection"><b>Metaverse Object Types</b></td>		
    <td>
	<xsl:for-each select="//dsml:class">	
	<xsl:sort select="./dsml:name"/>	
	<table cellspacing='0' cellpadding='1' bordercolordark='#ffffff' border='1' width="100%">
		<tr>
			<td width="50%" bgcolor="#bbbbbb"><font face="verdana" size="2"><b>Object-Type</b></font></td>
			<td width="50%" bgcolor="#bbbbbb"><font face="verdana" size="2"><b><xsl:value-of select="./dsml:name"/></b></font></td>			
		</tr>
		<tr>
			<td class="tdValue"  width="50%" bgcolor="#EBEBEB"><b>Attribute Name</b></td>
			<td class="tdValue"  width="50%" bgcolor="#EBEBEB"><b>Required</b></td>
		</tr>
		<xsl:for-each select="./dsml:attribute">
		<tr>
			<td class="tdValue"  width="50%"><xsl:value-of select="ms-dsml:RemovePoundSign(string(./@ref))"/></td>
			<td class="tdValue"  width="50%"><xsl:value-of select="./@required"/></td>
		</tr>
		</xsl:for-each>
	</table>			
	<br/>	
	</xsl:for-each>    
	</td>
    </tr>
    <tr>
    <a NAME="#mvattrs"></a>
    <td class="tdLeftSection"><b>Metaverse Attributes</b></td>		
    <td>
	<xsl:for-each select="//dsml:attribute-type">	
	<xsl:sort select="./dsml:name"/>	
	<table cellspacing='0' cellpadding='1' bordercolordark='#ffffff' border='1' width="100%">
		<tr>
			<td class="tdValue"  width="50%" bgcolor="#bbbbbb"><b>Attribute Name</b></td>
			<td class="tdValue"  width="50%" bgcolor="#bbbbbb"><b><xsl:value-of select="./dsml:name"/></b></td>			
		</tr>
		<tr>
			<td class="tdValue"  width="50%">Single-Valued</td>
			<td class="tdValue"  width="50%"><xsl:value-of select="ms-dsml:TrueOrFalse(string(./@single-value))"/></td>
		</tr>
		<tr>
			<td class="tdValue"  width="50%">Indexable</td>
			<td class="tdValue"  width="50%"><xsl:value-of select="ms-dsml:TrueOrFalse(string(./@ms-dsml:indexable))"/></td>
		</tr>
		<tr>
			<td class="tdValue"  width="50%">Indexed</td>
			<td class="tdValue"  width="50%"><xsl:value-of select="ms-dsml:TrueOrFalse(string(./@ms-dsml:indexed))"/></td>
		</tr>
		<tr>
			<td class="tdValue"  width="50%">Syntax</td>
			<td class="tdValue"  width="50%"><xsl:value-of select="ms-dsml:Syntax(string(./dsml:syntax))"/></td>
		</tr>		
	</table>			
	<br/>
	</xsl:for-each>    
	</td>
    </tr>   
    <tr>
    <a NAME="#pwdchghist"></a>
    <td class="tdLeftSection"><b>WMI Password Change History Size</b></td>		
    <td class="tdValue"  width="50%"><xsl:value-of select="//password-change-history-size"/></td>    
    </tr>
    <tr>
    <a NAME="#pwdsync"></a>
    <td class="tdLeftSection"><b>Password Sync</b></td>		    
    <xsl:choose>    
    <xsl:when test="//password-sync/password-sync-enabled">
    <td class="tdValue">        
        <xsl:choose>
        <xsl:when test="ms-dsml:IsEnabled(string(//password-sync/password-sync-enabled))">
            Enabled
        </xsl:when>
        <xsl:otherwise>
            Not Enabled
        </xsl:otherwise>                
        </xsl:choose>        
    </td>
    </xsl:when>    
    <xsl:otherwise><td class="tdValue" >None</td></xsl:otherwise>
    </xsl:choose>    
    </tr>    
    </table>    
	</xsl:when>	
	<xsl:when test="//export-mv-schema">
	<table width="80%">
      <tr>
        <h3 align="center">Metaverse Schema</h3>   
      </tr>
      <tr>      
       <td class="tdMenu" width="50%">
        <A href="#mvobjtypes"><font face="verdana" size="2"><b>Metaverse Object Types</b></font></A>   
       </td>    
       <td class="tdMenu" width="50%">
        <A href="#mvattrs"><font face="verdana" size="2"><b>Metaverse Attributes</b></font></A>   
       </td>         
       </tr>      
      </table>  
      <br/>
      <br/>
      <table cellspacing="0" cellpadding="0" bordercolordark="#ffffff" border="1" width="80%">
	<tr>
    <a NAME="#mvobjtypes"></a>
    <td class="tdLeftSection"><b>Metaverse Object Types</b></td>		
    <td>
	<xsl:for-each select="//dsml:class">
	<xsl:sort select="./dsml:name"/>
	<table cellspacing='0' cellpadding='1' bordercolordark='#ffffff' border='1' width="100%">
		<tr>
			<td width="50%" bgcolor="#bbbbbb"><font face="verdana" size="2"><b>Object-Type</b></font></td>
			<td width="50%" bgcolor="#bbbbbb"><font face="verdana" size="2"><b><xsl:value-of select="./dsml:name"/></b></font></td>			
		</tr>
		<tr>
			<td class="tdValue"  width="50%" bgcolor="#EBEBEB"><b>Attribute Name</b></td>
			<td class="tdValue"  width="50%" bgcolor="#EBEBEB"><b>Required</b></td>
		</tr>
		<xsl:for-each select="./dsml:attribute">
		<tr>
			<td class="tdValue"  width="50%"><xsl:value-of select="ms-dsml:RemovePoundSign(string(./@ref))"/></td>
			<td class="tdValue"  width="50%"><xsl:value-of select="./@required"/></td>
		</tr>
		</xsl:for-each>
	</table>			
	<br/>	
	</xsl:for-each>    
	</td>
    </tr>
    <tr>
    <a NAME="#mvattrs"></a>
    <td class="tdLeftSection"><b>Metaverse Attributes</b></td>		
    <td>
	<xsl:for-each select="//dsml:attribute-type">	
	<xsl:sort select="./dsml:name"/>	
	<table cellspacing='0' cellpadding='1' bordercolordark='#ffffff' border='1' width="100%">
		<tr>
			<td class="tdValue"  width="50%" bgcolor="#bbbbbb"><b>Attribute Name</b></td>
			<td class="tdValue"  width="50%" bgcolor="#bbbbbb"><b><xsl:value-of select="./dsml:name"/></b></td>			
		</tr>
		<tr>
			<td class="tdValue"  width="50%">Single-Valued</td>
			<td class="tdValue"  width="50%"><xsl:value-of select="ms-dsml:TrueOrFalse(string(./@single-value))"/></td>
		</tr>
		<tr>
			<td class="tdValue"  width="50%">Indexable</td>
			<td class="tdValue"  width="50%"><xsl:value-of select="ms-dsml:TrueOrFalse(string(./@ms-dsml:indexable))"/></td>
		</tr>
		<tr>
			<td class="tdValue"  width="50%">Indexed</td>
			<td class="tdValue"  width="50%"><xsl:value-of select="ms-dsml:TrueOrFalse(string(./@ms-dsml:indexed))"/></td>
		</tr>
		<tr>
			<td class="tdValue"  width="50%">Syntax</td>
			<td class="tdValue"  width="50%"><xsl:value-of select="ms-dsml:Syntax(string(./dsml:syntax))"/></td>
		</tr>		
	</table>			
	<br/>
	</xsl:for-each>    
	</td>
    </tr>       
    </table>
    </xsl:when>
    <xsl:otherwise>
       <h3>Not a Valid Exported MV configuration File</h3>      
    </xsl:otherwise>
    </xsl:choose>
	</body>
    </html>
</xsl:template>
</xsl:stylesheet>