<!--
**********************************************************************************************************************************
    Microsoft Identity Integration Server 'Management Agent Configuration Viewer' Utility v1.0
    Copyright(c)2003 Microsoft Corporation. All rights reserved.

    Date : 10/Sep/03
    Time : 19:37

    This XSLT Displays An Management Agent's Configuration data(Using the MAConfigurationViewer utility). The MA Types Supported are :
    1.  AD                - Active Directory 
    2.  ADAM              - Active Directory Application Mode
    3.  AD GAL            - Active Directory Global Address List
    4.  iPlanet           - Sun and Netscape directory servers
    5.  Exchange          - Exchange Server 5.5
    6.  Exchange GAL      - Exchange Server 5.5 (bridgehead server)
    7.  eDirectory        - Novell eDirectory
    8.  Fixed             - Fixed-width text file
    9.  Delimited         - Delimited text file
    10. AVP               - Attribute-value pair text file
    11. LDIF              - LDAP Data Interchange Format (LDIF)
    12. DSML              - Directory Services Markup Language (DSML) 2.0
    13. MSSQL             - SQL Server 7.0 or 2000
    14. Oracle            - Oracle Database 8i or 9i
    15. NT                - Windows NT 4.0
    16. Notes             - Lotus Notes
    17. IBM DB2           - IBM DB2
    18. Extensible        - Extensible Connectivity
    19. IBM DS            - IBM DS
============================================================================================================
    In brief this XSL is divided into 22 sections in which some have sub section(s) .
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    1. General Properties of an MA. 
      [The General section of the XSL renders the Properties information of an MA, the general properties are 
          a. MA Type
          b. Description
          c. Creation Time
          d. Last Modification Time
          e. Run in Separate Process
      ]

        MA's Covered: {All the MA's}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    2. Private Configuration of an MA. 
     [Displays the Private Configuration of all MA individually, that is for each MA its relevant configuration is shown.]

        MA's Covered: { All the MA's}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    3. Selected Attributes of an MA.
     [Displays the Selected Attributes of AD, AD GAL, ADAM, Exchange, Exchange 
      GAL, iPlanet, Novell eDirectory , Windows NT MAs
     ]

        MA's Covered: {File Based MA's (AVP, Delimited, Fixed, DSML, LDIF, Extensible)}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    4. Map Object Types for File Based MAs.
     [Displays the Map Object Types AVP, Delimited, Fixed,DSML, LDIF, Extensible MA's]

      MA's Covered: { File Based MA's (AVP, Delimited, Fixed, DSML and LDIF)}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    5. Define Object Types for File Based MAs.
     [Displays the Define Object Types AVP, Delimited, Fixed, DSML, LDIF, Extensible MA's]

      MA's Covered: { File Based MA's (AVP, Delimited, Fixed, DSML, LDIF, Extensible)}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    6. Partition Information of an MA.
     [Displays the partition information of AVP, Delimited, Fixed,
          DSML, LDIF, AD, AD GAL, ADAM, Exchange, Exchange GAL, Extensible MA's
     ]

      MA's Covered: {File Based (AVP, Delimited, Fixed, DSML, LDIF, Extensible), AD, AD GAL, ADAM,Exchange, Exchange GAL}


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    7. Naming Context of iPlanet MA.
     [Displays the Naming Context of iPlanet MA]

      MA's Covered: {iPlanet}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    8. Selected Containers of Novell eDirectory MA.
     [Displays Selected Containers of Novell eDirectory MA only]

      MA's Covered: {Novell eDirectory}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    9. Organizational Units of Lotus Notes MA.
     [Displays the Organizational Units of Lotus Notes MA]

      MA's Covered: {Lotus Notes}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    10. GAL Configuration of AD GAL MA.
     [Displays the GAL Configuration information of AD GAL MA only]

      MA's Covered: {AD GAL}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    11. Selected Objects of MA.
     [Displays the Selected Objects of AD, AD GAL, Sun iPlanet, Novell eDirectory,
      Exchange, Exchange GAL, Lotus Notes, Windows NT4
     ]

      MA's Covered:{AD, AD GAL, Sun iPlanet, Novell eDirectory, Exchange, Exchange GAL, Lotus Notes, Windows NT4}


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    12. Column Data for MSSQL and Oracle types of MA.
     [Column Data for MSSQL and Oracle MA Types]

      MA's Covered: {MSSQL, Oracle}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    13. Selected Attributes of MA.
     [Displays the Attributes of AVP, Delimited, Fixed, DSML and LDIF, Extensible MA's]

      MA's Covered: {AD, AD GAL, ADAM, Exchange, Exchange GAL, iPlanet, Novell eDirectory, Windows NT}


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    14. Selected Attributes of Lotus Notes MA.
     [Displays the Connector Filter Configuration of Lotus Notes MA]

      MA's Covered: {Lotus Notes}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    15. Selected Anchor Attributes of iPlanet MA.
     [Displays the Selected Anchor Attributes of iPlanet MA if present]

      MA's Covered: {iPlanet}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    16. Connector Filter Configuration of MA.
     [Displays the Connector Filter Configuration of MA]

      MA's Covered: {All the MA's}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    17. Join Rules of MA.
     [Displays the Join Rules of MA ]

      MA's Covered: {All the MA's}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    18. Projection Rules of MA.
     [Displays the Projection Rules of MA]

      MA's Covered: {All the MA's}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    19. Attribute Flow Rules of MA.
     [Displays the Import and Export Attribute flow of an MA]

      MA's Covered: {All the MA's}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    20. Deprovisioning Information of MA.
     [ This section displays the de provisioning of the MA, the subsections include
      a. Deprovision option 
      b. Do not recall attributes when MA is disconnected
     ]

      MA's Covered: {All the MA's}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    21. Extension DLL information of MA.
     [This section displays the Extension DLL information of the MA, the subsections include like DLL]

      MA's Covered: {All the MA's}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    22.Run Profiles of MA.
     [This section displays different Run Profile steps configured for this MA]

      MA's Covered:{All the MA's}

============================================================================================================
**********************************************************************************************************************************
-->
<!--
**********************************************************************************************************************************
    This section handles the header of the XSL.
**********************************************************************************************************************************
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:user="http://www.myserver.com/user"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                version="1.0">


<xsl:output method="html"/>
<msxsl:script language="JScript" implements-prefix="user">
<![CDATA[
// stores the @cd-object-type.
  var iSend1=0;

// stores the @mv-object-type.
  var iSend2=0;

//function to initialize the cd-object-type.
  function xml1(send) 
  {
    iSend1 = send;
    return 0;
  }

//function to retrieve the cd-object-type.
  function xml2() 
  {
    return iSend1;
  }

//function to initialize the mv-object-type.
  function xml3(send) 
  {
    iSend2 = send;
    return 0;
  }
//function to retrieve the mv-object-type.
  function xml4() 
  {
    return iSend2;
  }
]]>
</msxsl:script>

<xsl:key name="import-attribute-flow" match="import-flow" use="@src-ma"/>

<xsl:template match="/">
<!--
**************************************************************
  Variables defined to be used for processing some sections.
**************************************************************
-->
<xsl:variable name='id' select="//ma-data/id"/>
<xsl:variable name='category' select="//ma-data/category"/>
<HTML>
<HEAD>
    <TITLE>MAConfigurationViewer 1.0 - <xsl:value-of select="//summary/heading"/> </TITLE>
       <STYLE type="text/css">
       @page FullPage{margin-left:1.0in;margin-right:0.5in}

        h1,h3{margin: 0px; padding: 0px;}
        #S1 {width: 300px;}
        h1 {color: #AAAAAA; font-size: 500%;}
        h3 {color: #AAAAAA; font-size: 500%;}
        
        table{page:FullPage;width:575px;}
        .tableClass1{page:FullPage; width:300px; border: medium ;}
        .trtableClass1{width:375px;}
        .tdtableClass1{width:165px;}

        .tableMain{page:FullPage; width:540px;  FONT-FAMILY:Verdana; FONT-SIZE: 70%;}

        .thTitle{background-color:#666666; color: #FFFFFF; FONT-SIZE: 70%;}
        .thAttributeFlow{background-color:#bbbbbb;  FONT-SIZE: 70%;}
        .thAttributeFlow1{background-color:#dddddd; FONT-SIZE: 70%;}
        .thAttributeFlow2{background-color:#dddddd; FONT-SIZE: 70%; width:50px}

        .tableMenu{FONT-SIZE: 300%; FONT-FAMILY: Verdana;  width:575px}
        .tdMenu{border-right: 1px solid #999999;text-align:center;}
        .trMenu{background-color:#ffffff;}

        .tableClass2{cellspacing:'0' cellpadding:'0'; border='1'; width:100% FONT-SIZE: 80%; FONT-FAMILY: Verdana;  border-color: #eeeeee; border-style:solid; PADDING: .25em;}
        .tableClass3{width:50px;}
        .tableClass4{width:575px;vertical-align:left}
        .tableClass5{vertical-align:middle; width:375px}
        .tdLeftSection{background-color:#eeeeee; FONT-SIZE: 70%;}
        

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
</HEAD>

<BODY>
<script>
//scrolling TOP Link to navigate...
var displayed="<nobr><b>[Top]</b></nobr>"
var logolink='javascript:window.scrollTo(0,0)'
var ie4 =document.all

if (ie4)
document.write('<span id="logo" style="position:absolute;top:-300;z-index:100">'+displayed+'</span>')

function staticit()
{
crosslogo.style.left=document.body.scrollLeft+document.body.clientWidth-crosslogo.offsetWidth-10
crosslogo.style.top=document.body.scrollTop+document.body.clientHeight-crosslogo.offsetHeight-10
}

function inserttext()
{ 
    if (ie4)
    crosslogo=document.all.logo
    if (ie4)
    window.onscroll=staticit

    crosslogo.innerHTML='<a href="'+logolink+'">'+displayed+'</a>'
    crosslogo.style.left=document.body.clientWidth-crosslogo.offsetWidth-10
    crosslogo.style.top=document.body.clientHeight-crosslogo.offsetHeight-10

}

if(ie4)
{
    window.onload=inserttext
    window.onresize=new Function("window.location.reload()")
}

</script>
<TABLE cellpadding='0' cellspacing='0' class="tableMain">

<!--
**********************************************************************************************************************************
    This section handles the Management Agent's name, description and displays as the heading.
**********************************************************************************************************************************
-->
<TR>
    <TD>
        <H1>MAConfigurationViewer 1.0 </H1>
    </TD>
</TR>
<!-- Start of XSL menu. -->
<TR>
    <TD>
        <TABLE class="tableMenu">
        <Tr class="trMenu">
        <Td class="tdMenu"><b><A  href='#properties' > Properties </A></b> </Td>

        <xsl:if test="$category='AVP' or $category='Delimited' or $category='DSML' or $category='Fixed' or $category='LDIF'">
        <Td class="tdMenu"> <b><A   href='#Attri' > Selected Attributes </A></b></Td>
        </xsl:if>

        <xsl:if test="$category='AVP' or $category='Delimited' or $category='DSML' or $category='Fixed' or $category='LDIF'">
        <Td class="tdMenu"> <b><A  href='#Map' > Map Object Types </A></b></Td>
        </xsl:if>

        <xsl:if test="$category='AVP' or $category='Delimited' or $category='DSML' or $category='Fixed' or $category='LDIF'">
        <Td class="tdMenu"> <b><A  href='#DefineObjectTypes' > Define Object Types </A></b></Td>
        </xsl:if>


        <xsl:if test="$category='AD' or $category='AD GAL'">
        <Td class="tdMenu"> <b><A  href='#AdForest' > AD Forest Connection Information </A></b></Td>
        </xsl:if>

        <xsl:if test="$category='MSSQL' or $category='Oracle' or $category='DB2'">
        <Td class="tdMenu"> <b><A  href='#DBConf' > Database Configuration </A></b></Td>
        <Td class="tdMenu"> <b><A  href='#ColsConf' > Columns Configured </A></b></Td>
        </xsl:if>

        <xsl:if test = "$category = 'AD' or $category = 'AD GAL'">
        <Td class="tdMenu"> <b><A  href='#Part1' > Partition Information </A></b></Td>
        </xsl:if>


        <xsl:if test = "$category = 'AD GAL'">
        <Td class="tdMenu"> <b><A  href='#ADGAL1' > GAL Configuration </A></b></Td>
        </xsl:if>

        <xsl:if test="$category='Extensible'">
        <Td class="tdMenu"> <b><A href='#ExtensibleInformation'>Extensible Information</A></b></Td>
        </xsl:if>

        <xsl:if test="$category='AVP' or $category='Fixed' or $category='Delimited' or $category='LDIF' or $category='DSML'">
        <Td class="tdMenu"> <b><A  href='#Partition' > Partitions Configured </A></b></Td>
        </xsl:if>

        <xsl:if test="$category='ADAM'">
        <Td class="tdMenu"> <b><A  href='#ADAM1' > ADAM Server Connection Information </A></b></Td>
        <Td class="tdMenu"> <b><A  href='#ADAM2' > Directory Partitions Configured </A></b></Td>
        </xsl:if>

        <xsl:if test="$category='iPlanet'">
        <Td class="tdMenu"> <b><A  href='#iPlanet1' > Logon Information  </A></b></Td>
        <Td class="tdMenu"> <b><A  href='#iPlanet2' > Naming Context Configuration </A></b></Td>
        </xsl:if>

        <xsl:if test="$category='IBM DS'">
        <Td class="tdMenu"> <b><A  href='#IBMDS1' > Logon Information  </A></b></Td>
        <Td class="tdMenu"> <b><A  href='#IBMDS2' > Naming Context Configuration </A></b></Td>
        </xsl:if>

        <xsl:if test="$category='Exchange' or $category='Exchange GAL'">
        <Td class="tdMenu"> <b><A  href='#Exchange1' > Organization Connection Information </A></b></Td>
        <Td class="tdMenu"> <b><A  href='#Exchange2' > Sites Configuration  </A></b></Td>
        </xsl:if>

        <xsl:if test="$category='eDirectory'">
        <Td class="tdMenu"> <b><A  href='#eDirectory1' > Server Connection Information </A></b></Td>
        <Td class="tdMenu"> <b><A  href='#eDirectory2' > Selected Containers </A></b></Td>
        </xsl:if>

        <xsl:if test="$category='NT'">
        <Td  class="tdMenu" > <b><A  href='#NT1' > Domain Connection Information </A></b></Td>
        </xsl:if>


        <xsl:if test="$category='AD' or $category='AD GAL'">
        <Td  class="tdMenu" > <b><A  href='#SelObjects' > Selected Object Types </A></b></Td>
        <Td  class="tdMenu" > <b><A  href='#Attri1' > Selected Attributes </A></b></Td>
        </xsl:if>

        <xsl:if test="$category='ADAM' or $category='iPlanet' or $category='IBM DS' or $category='Exchange' or $category='Exchange GAL' or $category='eDirectory' or $category='NT' ">
        <Td  class="tdMenu" > <b><A  href='#SelObjects' > Selected Object Types </A></b></Td>
        </xsl:if>

        <xsl:if test="$category='Exchange' or $category='Exchange GAL' or $category='NT' or $category='iPlanet' or $category='IBM DS' or $category='eDirectory'">
        <Td  class="tdMenu" > <b><A  href='#Attri1' > Selected Attributes </A></b></Td>
        </xsl:if>

        <xsl:if test="$category='Notes'">
        <Td  class="tdMenu" > <b><A  href='#Notes1' > Server Connection Information  </A></b></Td>
        <Td  class="tdMenu" > <b><A  href='#Notes2' > Organizational Units Configured </A></b></Td>
        <Td  class="tdMenu" > <b><A  href='#SelObjects' > Selected Object Types </A></b></Td>
        <Td  class="tdMenu" > <b><A  href='#Notes3' > Selected Attributes </A></b></Td>
        </xsl:if>

        <xsl:if test="$category='ADAM'">
        <Td  class="tdMenu" > <b><A  href='#Attri1' > Selected Attributes </A></b></Td>
        </xsl:if>

        <xsl:if test="$category='iPlanet' or $category='IBM DS'">
        <xsl:if test="//ma-data/private-configuration/ipma-configuration/anchor-attributes/anchor-attribute/.">
        <Td  class="tdMenu" > <b><A  href='#SelectedAnchorAttributes' > Selected Anchor Attributes </A></b></Td>
        </xsl:if>
        </xsl:if>
        
        <Td  class="tdMenu" > <b><A  href='#connectorfilters' > Connector Filters </A></b></Td>
        <Td  class="tdMenu" > <b><A  href='#Joinandprojection' > Join and Projection Rules </A></b></Td>
        <Td  class="tdMenu" > <b><A  href='#AttributeFlow' > Attribute Flow </A></b></Td>
        <Td  class="tdMenu" > <b><A  href='#Deprovisioning' > Deprovisioning </A></b></Td>
        <Td  class="tdMenu" > <b><A  href='#MAExDLL' > MA Extensions </A></b></Td>
        <Td  class="tdMenu" > <b><A  href='#RSofMA' > Run Profiles</A></b></Td>
        </Tr>
        </TABLE>
    </TD>
</TR>
<!-- End of XSL menu. -->
<TR>
    <TD>
        <h3><xsl:value-of select="//ma-data/name"/> Management Agent </h3>
        <hr></hr>
    </TD>
</TR>
<!-- Start of checking for Not supported Management Agent. -->
<TR>
	<TD Align='center'>
		<xsl:if test="$category !='AVP' and $category !='Delimited' and $category !='DSML' and $category !='Fixed'
		and $category !='LDIF' and $category !='AD GAL' and $category !='MSSQL' and $category !='Oracle'
		and $category !='AD' and $category !='ADAM' and $category !='iPlanet' and $category !='IBM DS' and $category !='Exchange GAL'
		and $category !='eDirectory' and $category !='NT' and $category !='Exchange' 
		and $category !='Notes' and $category !='DB2' and $category != 'Extensible'">
        
			<FONT SIZE="6" COLOR="#FF0000">
                       		WARNING!! 
            </FONT>

			<FONT SIZE="5" COLOR="#FF0000">
                The tool currently doesn't support the MA type '<xsl:value-of select="$category"/>'.
				Some MA properties or information may not appear or may display incorrectly.
            </FONT>
			<hr></hr>
       		</xsl:if>

	</TD>
</TR>
<!--End of checking for Not supported management Agent. -->
<!--
**********************************************************************************************************************************
     Displays the table title of the utility.
**********************************************************************************************************************************
-->

<TR>
    <TD>
        <TABLE cellspacing='0' cellpadding='0' border='1'  bordercolordark="#ffffff" class="tableClass2">
            <TR>
                <TH class='thTitle' colspan='2'>
                        Management Agent's Properties
                </TH>
            </TR>


<!--
#################################################################################################################################
    MA general properties section.
    This Section handles the Properties of respective Management Agents, and each specific Management Agent is handled independently 
    to display its expanded name. The general properties include MAType, Version, Creation Time, Modification Time, Description,
    Process of an MA.
#################################################################################################################################
-->

<!--
**********************************************************************************************************************************
    This is sub-section of Properties which handles the MAType of the Management Agent. That is replacing the short-form of the MA Type to
    expanded format.
**********************************************************************************************************************************
-->
            <TR>
                <TD class='tdLeftSection'><b>Properties</b></TD>
                <TD align='left'> <a NAME="#properties"></a>
                    <xsl:choose>
                        <xsl:when test="$category!=''">
                            <table cellspacing='0' cellpadding='0' bordercolordark='#ffffff' border='1' align='left' class="tableClass4">
                                <tr>
                                    <xsl:if test="$category">
                                        <td><b>MA Type: </b></td>

                                        <xsl:choose>
                                            <xsl:when test="$category='AD'">
                                                <td> Active Directory </td>
                                            </xsl:when>

                                            <xsl:when test="$category='ADAM'">
                                                <td> Active Directory Application Mode </td>
                                            </xsl:when>

                                            <xsl:when test="$category='AD GAL'">
                                                <td> Active Directory Global Address List </td>
                                            </xsl:when>

                                            <xsl:when test="$category='AVP'">
                                                <td> Attribute-value pair text file</td>
                                            </xsl:when>

                                            <xsl:when test="$category='Delimited'">
                                                <td> Delimited text file </td>
                                            </xsl:when>

                                            <xsl:when test="$category='DSML'">
                                                <td> Directory Services Markup Language (DSML) 2.0 </td>
                                            </xsl:when>

                                            <xsl:when test="$category='eDirectory'">
                                                <td> Novell eDirectory </td>
                                            </xsl:when>

                                            <xsl:when test="$category='Exchange'">
                                                <td> Exchange Server 5.5 </td>
                                            </xsl:when>

                                            <xsl:when test="$category='Exchange GAL'">
                                                <td> Exchange Server 5.5 (bridgehead server) </td>
                                            </xsl:when>

                                            <xsl:when test="$category='Fixed'">
                                                <td> Fixed-width text file </td>
                                            </xsl:when>

                                            <xsl:when test="$category='LDIF'">
                                                <td> LDAP Data Interchange Format (LDIF) </td>
                                            </xsl:when>

                                            <xsl:when test="$category='iPlanet'">
                                                <td> Sun and Netscape directory servers </td>
                                            </xsl:when>

                                            <xsl:when test="$category='MSSQL'">
                                                <td> SQL Server 7.0 or 2000 </td>
                                            </xsl:when>

                                            <xsl:when test="$category='Notes'">
                                                <td> Lotus Notes </td>
                                            </xsl:when>

                                            <xsl:when test="$category='NT'">
                                                <td> Windows NT 4.0 </td>
                                            </xsl:when>

                                            <xsl:when test="$category='Oracle'">
                                                <td> Oracle Database 8i or 9i </td>
                                            </xsl:when>

                                            <xsl:when test="$category='DB2'">
                                                <td> IBM DB2 </td>
                                            </xsl:when>
                      
                                            <xsl:when test="$category='Extensible'">
                                                <td> Extensible Connectivity </td>
                                            </xsl:when>
 
                                            <xsl:when test="$category='IBM DS'">
                                                <td> IBM DS </td>
                                            </xsl:when>

                                            <xsl:otherwise>
                                                <td><xsl:value-of select="$category"/></td>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:if>
                                </tr>

<!--
**********************************************************************************************************************************
    This is sub-section of Properties which handles the Description of the Management Agent. If Nothing is specified then a - is displayed.
**********************************************************************************************************************************
-->
                                <tr>
                                    <td><b>Description: </b></td>
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/description!=''">
                                            <td class="tdClass3"><xsl:value-of disable-output-escaping="yes" select="//ma-data/description"/></td>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <td><xsl:text> - </xsl:text> </td>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </tr>

<!--
    **********************************************************************************************************************************
    This is sub-section of Properties, handles the Subtype of the Management Agent. If nothing is specified then nothing is displayed.
    **********************************************************************************************************************************
-->

                                <xsl:if test="//ma-data/subtype != ''">
				    <tr>
                                        <td><b>Subtype: </b></td>
                                        <td class='tdClass3'>
                                            <xsl:value-of disable-output-escaping="yes" select="//ma-data/subtype"/>
                                        </td>
                                    </tr>
                                </xsl:if>


<!--
    **********************************************************************************************************************************
    This is sub-section of Properties, handles the listname of the Management Agent. If nothing is specified then nothing is displayed.
    **********************************************************************************************************************************
-->

                                <xsl:if test="//ma-data/ma-listname != ''">
				    <tr>
                                        <td><b>List Name: </b></td>
                                        <td class='tdClass3'>
                                            <xsl:value-of disable-output-escaping="yes" select="//ma-data/ma-listname"/>
                                        </td>
                                    </tr>
                                </xsl:if>


<!--
    **********************************************************************************************************************************
    This is sub-section of Properties, handles the companyname of the Management Agent. If nothing is specified then nothing is displayed.
    **********************************************************************************************************************************
-->

                                <xsl:if test="//ma-data/ma-companyname != ''">
				    <tr>
                                        <td><b>Company: </b></td>
                                        <td class='tdClass3'>
                                            <xsl:value-of disable-output-escaping="yes" select="//ma-data/ma-companyname"/>
                                        </td>
                                    </tr>
                                </xsl:if>

<!--
**********************************************************************************************************************************
    This is sub-section of Properties which handles the Creation Time of the Management Agent.
**********************************************************************************************************************************
-->
                                <tr>
                                    <td><b>Creation Time: </b></td>
                                    <td><xsl:value-of select="//ma-data/creation-time"/></td>
                                </tr>
<!--
**********************************************************************************************************************************
This is sub-section of Properties which handles the Last Modification Time of the Management Agent.
**********************************************************************************************************************************
-->
                                <tr>
                                    <td><b>Last Modification Time: </b></td>
                                    <td><xsl:value-of select="//ma-data/last-modification-time"/></td>
                                </tr>

<!--
**********************************************************************************************************************************
This is sub-section of Properties which handles the Process of the Management Agent.
**********************************************************************************************************************************
-->
                                <tr>
                                    <td>
                                        <b> Run in Separate Process:</b>
                                    </td>

                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="//ma-data/controller-configuration/application-protection='low'">
                                                <xsl:text> No </xsl:text>
                                            </xsl:when >

                                            <xsl:otherwise >
                                                <xsl:text> Yes </xsl:text>
                                            </xsl:otherwise >
                                        </xsl:choose>
                                    </td>
                                </tr>
                            </table>
                        </xsl:when>

                        <xsl:otherwise>
                            <xsl:text> None </xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </TD>
            </TR>

<!--
#################################################################################################################################
    This section handles the Private configuration information of each individual MA, 
    The Following sub-sections handle different MA's as 
    1.  AD
    2.  ADAM
    3.  AD GAL
    4.  iPlanet
    5.  Exchange & Exchange GAL
    6.  eDirectory
    7.  Notes
    8.  NT
    9.  MSSQL & Oracle
    10. Fixed, Delimited, AVP, LDIF, DSML
    11. Extensible
    12. IBM DS
#################################################################################################################################
-->

<!--
**********************************************************************************************************************************
    This is sub-section of Private Configuration which handles the Private Configuration data of an MA of Type Active Directory and AD GAL.
**********************************************************************************************************************************
-->
            <xsl:if test="$category='AD' or $category = 'AD GAL'">
                <TR>
                    <TD class="tdLeftSection"><b>AD Forest Connection Information </b></TD>
                    <TD align='left'><a NAME='#AdForest'></a>
                        <table cellspacing='0' cellpadding='0' bordercolordark='#ffffff' border='1' align='left' class="tableClass4">
                            <tr >
                                <th colspan='2' class="thAtrributeFlow1"><b>Forest Connection Information</b></th>
                            </tr>

                            <tr >
                                <td >Forest name:</td>
                                <xsl:choose >
                                    <xsl:when test="//ma-data/private-configuration/adma-configuration/forest-name!=''">
                                        <td ><xsl:value-of select="//ma-data/private-configuration/adma-configuration/forest-name"/></td>
                                    </xsl:when>

                                    <xsl:otherwise><td><xsl:text> None </xsl:text></td></xsl:otherwise>
                                </xsl:choose >
                            </tr>

                            <tr >
                                <td >User name:</td>
                                <xsl:choose >
                                    <xsl:when test="//ma-data/private-configuration/adma-configuration/forest-login-user!=''">
                                        <td ><xsl:value-of select="//ma-data/private-configuration/adma-configuration/forest-login-user"/></td>
                                    </xsl:when>

                                    <xsl:otherwise><td><xsl:text> None </xsl:text></td></xsl:otherwise>
                                </xsl:choose >
                            </tr> 

                            <tr > 
                                <td >Domain:</td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/adma-configuration/forest-login-domain!=''">
                                            <xsl:value-of select="//ma-data/private-configuration/adma-configuration/forest-login-domain"/>
                                        </xsl:when>

                                        <xsl:otherwise><xsl:text> None </xsl:text></xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </table>
                    </TD>
                </TR>
            </xsl:if>

<!--
**********************************************************************************************************************************
    This is sub-section of Private Configuration which handles the Private Configuration data of an MA of Type Extensible
**********************************************************************************************************************************
-->
            <xsl:if test="$category='Extensible'">
                <TR>
                    <TD class="tdLeftSection"><b>Extensible Information </b></TD>
                    <TD align='left'><a NAME='#ExtensibleInformation'></a>
                        <Table><tr><td>
                        <table cellspacing='0' cellpadding='0' bordercolordark='#ffffff' border='1' align='left' class="tableClass4">
                            <tr>
                               <th colspan='2' class="thAttributeFlow"><b>Connection Information</b></th>
                            </tr>
                            
                            <tr>
                               <td>Step Types supported:</td>
                               <xsl:choose>
                                   <xsl:when test="//ma-data/private-configuration/MAConfig/extension-config/import-enabled='1' and //ma-data/private-configuration/MAConfig/extension-config/export-enabled='1'">
                                       <td>
                                           <xsl:text>Import and Export</xsl:text>
                                       </td>
                                   </xsl:when>
                                   <xsl:when test="//ma-data/private-configuration/MAConfig/extension-config/import-enabled='1' and //ma-data/private-configuration/MAConfig/extension-config/export-enabled='0'">
                                       <td>
                                           <xsl:text>Import Only</xsl:text>
                                       </td>
                                   </xsl:when>
                                   <xsl:when test="//ma-data/private-configuration/MAConfig/extension-config/import-enabled='0' and //ma-data/private-configuration/MAConfig/extension-config/export-enabled='1'">
                                       <td>
                                           <xsl:text>Export Only</xsl:text>
                                       </td>
                                   </xsl:when>
                                   <xsl:otherwise><td><xsl:text>Unknown</xsl:text></td></xsl:otherwise>
                               </xsl:choose>
                            </tr>

                            <tr>
                               <td>Export mode supported:</td>
                               <xsl:choose>
                                   <xsl:when test="//ma-data/private-configuration/MAConfig/extension-config/export-mode!=''">
                                       <td><xsl:value-of select="//ma-data/private-configuration/MAConfig/extension-config/export-mode"/></td>
                                   </xsl:when>
                                   <xsl:otherwise><td><xsl:text>None</xsl:text></td></xsl:otherwise>
                               </xsl:choose>
                            </tr>
 
                            <tr>
                               <td>Connected data source extension name:</td>
                               <xsl:choose>
                                   <xsl:when test="//ma-data/private-configuration/MAConfig/extension-config/filename!=''">
                                       <td><xsl:value-of select="//ma-data/private-configuration/MAConfig/extension-config/filename"/></td>
                                   </xsl:when>
                                   <xsl:otherwise><td><xsl:text>None</xsl:text></td></xsl:otherwise>
                               </xsl:choose>
                            </tr>                          

                            <tr>
                               <td>Connect To:</td>
                               <xsl:choose>
                                   <xsl:when test="//ma-data/private-configuration/MAConfig/extension-config/connection-info/connect-to!=''">
                                       <td><xsl:value-of select="//ma-data/private-configuration/MAConfig/extension-config/connection-info/connect-to"/></td>
                                   </xsl:when>
                                   <xsl:otherwise><td><xsl:text>None</xsl:text></td></xsl:otherwise>
                               </xsl:choose>
                           </tr>
                            <tr>
                               <td>User:</td>
                               <xsl:choose>
                                   <xsl:when test="//ma-data/private-configuration/MAConfig/extension-config/connection-info/user!=''">
                                       <td><xsl:value-of select="//ma-data/private-configuration/MAConfig/extension-config/connection-info/user"/></td>
                                   </xsl:when>
                                   <xsl:otherwise><td><xsl:text>None</xsl:text></td></xsl:otherwise>
                               </xsl:choose>
                           </tr>
                       </table>
                       </td></tr>
                       <tr><td>
                        <table cellspacing='0' cellpadding='0' bordercolordark='#ffffff' border='1' align='left' class="tableClass4">
                           <tr>
                               <th colspan='3' class="thAttributeFlow"><b>Additional Parameters</b></th>
                           </tr>
                           <tr>
                               <th class="thAttributeFlow1">Name</th>
                               <th class="thAttributeFlow1">Value</th>
                               <th class="thAttributeFlow1">Encrypted</th>
                           </tr>
                           <xsl:for-each select="//ma-data/private-configuration/MAConfig/extension-config/attributes/attribute">
                               <tr>
                                   <td>
                                      <xsl:value-of select="./@name"/>
                                   </td>
                                   <td>
                                      <xsl:choose>
                                          <xsl:when test=".!=''">
                                              <xsl:value-of select="."/>
                                          </xsl:when>
                                          <xsl:otherwise><xsl:text>********</xsl:text></xsl:otherwise>
                                      </xsl:choose>
                                   </td>
                                   <td>
                                      <xsl:choose>
                                          <xsl:when test="@encrypted='1'">
                                              <xsl:text>Yes</xsl:text>
                                          </xsl:when>
                                          <xsl:otherwise><xsl:text>No</xsl:text></xsl:otherwise>
                                      </xsl:choose>
                                   </td>
                               </tr>
                           </xsl:for-each>
                           <tr>
                           </tr>
                       </table>
                       </td></tr></Table>
                   </TD>
                </TR>
            </xsl:if>

<!--
**********************************************************************************************************************************
    This is sub-section of Private Configuration which handles the Private Configuration data of an MA of Type Active Directory Application Mode.
**********************************************************************************************************************************
-->
            <xsl:if test="$category='ADAM'">
                <TR>
                    <TD class="tdLeftSection"><b>ADAM<br></br>Connection Information</b></TD>
                    <TD align='left'><a NAME='#ADAM1'></a>

                        <table cellspacing='0' cellpadding='0' bordercolordark='#ffffff' border='1' align='left' class="tableClass4">
                            <tr>
                                <th colspan='2' class="thAttributeFlow"><b>Forest configuration</b></th>
                            </tr>
                            <tr>
                                <td >Server name:</td>
                                <xsl:choose >
                                    <xsl:when test="//ma-data/private-configuration/adma-configuration/forest-name != ''">
                                        <td ><xsl:value-of select="//ma-data/private-configuration/adma-configuration/forest-name"/></td>
                                    </xsl:when>

                                    <xsl:otherwise><td><xsl:text> None </xsl:text></td></xsl:otherwise>
                                </xsl:choose >
                            </tr>
                            <tr>
                                <td >Port:</td>
                                <xsl:choose >
                                    <xsl:when test="//ma-data/private-configuration/adma-configuration/forest-port!= ''">
                                        <td ><xsl:value-of select="//ma-data/private-configuration/adma-configuration/forest-port"/></td>
                                    </xsl:when>

                                    <xsl:otherwise><td><xsl:text> None </xsl:text></td></xsl:otherwise>
                                </xsl:choose >
                            </tr>
                            <tr>
                                <td >User name:</td>
                                <xsl:choose >
                                    <xsl:when test="//ma-data/private-configuration/adma-configuration/forest-login-user!=''">
                                        <td ><xsl:value-of select="//ma-data/private-configuration/adma-configuration/forest-login-user"/></td>
                                    </xsl:when>

                                    <xsl:otherwise><td><xsl:text> None </xsl:text></td></xsl:otherwise>
                                </xsl:choose >
                            </tr>
                            <tr>
                                <td >Domain:</td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/adma-configuration/forest-login-domain!=''">
                                            <xsl:value-of select="//ma-data/private-configuration/adma-configuration/forest-login-domain"/>
                                        </xsl:when>

                                        <xsl:otherwise><xsl:text> None </xsl:text></xsl:otherwise>
                                        </xsl:choose>
                                </td>
                            </tr>
                            <tr>
                                <td >Enable Secure Sockets Layer (SSL) for communications:</td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/adma-configuration/ssl-bind='0'">
                                            <xsl:text> No </xsl:text>
                                        </xsl:when>

                                        <xsl:otherwise><xsl:text> Yes </xsl:text></xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                            <tr>
                                <td >Sign and encrypt LDAP traffic:</td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/adma-configuration/sign-and-seal='0'">
                                            <xsl:text> No </xsl:text>
                                        </xsl:when>

                                        <xsl:otherwise><xsl:text> Yes </xsl:text></xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </table>

                    </TD>
                </TR>
            </xsl:if>

<!--
**********************************************************************************************************************************
    This is sub-section of Private Configuration which handles the Private Configuration data of an MA of Type iPlanet 4.6 and 5.0.
**********************************************************************************************************************************
-->
            <xsl:if test="$category='iPlanet'">
                <TR>
                    <TD class="tdLeftSection"><b>Logon Information </b></TD>
                    <TD align='left'><a NAME='#iPlanet1'></a>

                        <table cellspacing='0' cellpadding='0' bordercolordark='#ffffff' border='1' align='left' class="tableClass4" >
                            <tr>
                                <th colspan='2' class="thAttributeFlow1"><b>Logon Information</b></th>
                            </tr>
                            <tr>
                                <td >Server name:</td>
                                <xsl:choose>
                                    <xsl:when test="//ma-data/private-configuration/ipma-configuration/default-server!=''">
                                        <td ><xsl:value-of select="//ma-data/private-configuration/ipma-configuration/default-server"/></td>
                                    </xsl:when>

                                    <xsl:otherwise><td><xsl:text> None </xsl:text></td></xsl:otherwise>
                                </xsl:choose >
                            </tr>
                            <tr>
                                <td >Port:</td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/ipma-configuration/default-port!=''">
                                            <xsl:value-of select="//ma-data/private-configuration/ipma-configuration/default-port"/>
                                        </xsl:when>

                                        <xsl:otherwise><xsl:text> None </xsl:text></xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                            <tr>
                                <td >User name:</td>
                                <xsl:choose >
                                    <xsl:when test="//ma-data/private-configuration/ipma-configuration/default-login-user!=''">
                                        <td ><xsl:value-of select="//ma-data/private-configuration/ipma-configuration/default-login-user"/></td>
                                    </xsl:when>

                                    <xsl:otherwise><td><xsl:text> None </xsl:text></td></xsl:otherwise>
                                </xsl:choose >
                            </tr>
                            <tr>
                                <td >Enable Secure Sockets Layer (SSL) for communications:</td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/ipma-configuration/default-ssl-bind='0'">
                                            <xsl:text> No </xsl:text>
                                        </xsl:when>
                                        <xsl:when test="//ma-data/private-configuration/ipma-configuration/default-ssl-bind='1'">
                                            <xsl:text> Yes </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text> - </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                            <tr>
                                <td >Enable Simple Authentication Security Layer (SASL) for communications:</td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/ipma-configuration/default-sasl-mechanism='1'">
                                            <xsl:text> Yes </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                        <xsl:text> No </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </table>

                    </TD>
                </TR>
            </xsl:if>

<!--
**********************************************************************************************************************************
    This is sub-section of Private Configuration which handles the Private Configuration data of an MA of Type IBM DS.
**********************************************************************************************************************************
-->
            <xsl:if test="$category='IBM DS'">
                <TR>
                    <TD class="tdLeftSection"><b>Logon Information </b></TD>
                    <TD align='left'><a NAME='#IBMDS'></a>

                        <table cellspacing='0' cellpadding='0' bordercolordark='#ffffff' border='1' align='left' class="tableClass4" >
                            <tr>
                                <th colspan='2' class="thAttributeFlow1"><b>Logon Information</b></th>
                            </tr>
                            <tr>
                                <td >Server name:</td>
                                <xsl:choose>
                                    <xsl:when test="//ma-data/private-configuration/dsma-configuration/default-server!=''">
                                        <td ><xsl:value-of select="//ma-data/private-configuration/dsma-configuration/default-server"/></td>
                                    </xsl:when>

                                    <xsl:otherwise><td><xsl:text> None </xsl:text></td></xsl:otherwise>
                                </xsl:choose >
                            </tr>
                            <tr>
                                <td >Port:</td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/dsma-configuration/default-port!=''">
                                            <xsl:value-of select="//ma-data/private-configuration/dsma-configuration/default-port"/>
                                        </xsl:when>

                                        <xsl:otherwise><xsl:text> None </xsl:text></xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                            <tr>
                                <td >User name:</td>
                                <xsl:choose >
                                    <xsl:when test="//ma-data/private-configuration/dsma-configuration/default-login-user!=''">
                                        <td ><xsl:value-of select="//ma-data/private-configuration/dsma-configuration/default-login-user"/></td>
                                    </xsl:when>

                                    <xsl:otherwise><td><xsl:text> None </xsl:text></td></xsl:otherwise>
                                </xsl:choose >
                            </tr>
                            <tr>
                                <td >Enable Secure Sockets Layer (SSL) for communications:</td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/dsma-configuration/default-ssl-bind='0'">
                                            <xsl:text> No </xsl:text>
                                        </xsl:when>
                                        <xsl:when test="//ma-data/private-configuration/dsma-configuration/default-ssl-bind='1'">
                                            <xsl:text> Yes </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text> - </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                            <tr>
                                <td >Enable Simple Authentication Security Layer (SASL) for communications:</td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/dsma-configuration/default-sasl-mechanism='1'">
                                            <xsl:text> Yes </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                        <xsl:text> No </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </table>

                    </TD>
                </TR>
            </xsl:if>

<!--
**********************************************************************************************************************************
    This is sub-section of Private Configuration which handles the Private Configuration data of an MA of Type Exchange 5.5 and
    Exchange 5.5 bridgehead.
**********************************************************************************************************************************
-->
            <xsl:if test="$category='Exchange' or $category='Exchange GAL'">
                <TR>
                    <TD class="tdLeftSection"><b>Organization Connection Information </b></TD>
                    <TD align='left'><a NAME='#Exchange1'></a>
                        <table cellspacing='0' cellpadding='0' bordercolordark='#ffffff' border='1' align='left' class="tableClass4" >
                            <xsl:variable name="serverinfo" select="//ma-data/private-configuration/exma-configuration/default-server"/>
                            <tr>
                                <th colspan='2' class="thAttributeFlow"><b>Organization Connection Information </b></th>
                            </tr>

                            <tr>
                                <td > Server name:</td>
                                <xsl:choose >
                                    <xsl:when test="//ma-data/private-configuration/exma-configuration/default-server!=''">
                                        <td ><xsl:value-of select="substring-before($serverinfo,':')"/></td>
                                    </xsl:when>
                                    <xsl:otherwise><td><xsl:text> None </xsl:text></td></xsl:otherwise>
                                </xsl:choose >
                            </tr>
                            <tr>
                                <td > Port:</td>
                                <xsl:choose >
                                    <xsl:when test="//ma-data/private-configuration/exma-configuration/default-server!=''">
                                        <xsl:if test="substring-after($serverinfo,':') != ''">
                                            <td ><xsl:value-of select="substring-after($serverinfo,':')"/></td>
                                        </xsl:if>

                                        <xsl:if test="substring-after($serverinfo,':') = ''">
                                            <td><xsl:text> 389 </xsl:text></td>
                                        </xsl:if>
                                    </xsl:when>

                                    <xsl:otherwise><td><xsl:text> None </xsl:text></td></xsl:otherwise>
                                </xsl:choose >
                            </tr>
                            <tr>
                                <td > User name:</td>
                                <xsl:choose >
                                    <xsl:when test="//ma-data/private-configuration/exma-configuration/default-login-user!=''">
                                        <td ><xsl:value-of select="//ma-data/private-configuration/exma-configuration/default-login-user"/></td>
                                    </xsl:when>
                                    <xsl:otherwise><td><xsl:text> None </xsl:text></td></xsl:otherwise>
                                </xsl:choose >
                            </tr>
                            <tr>
                                <td > Domain:</td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/exma-configuration/default-login-domain!=''">
                                            <xsl:value-of select="//ma-data/private-configuration/exma-configuration/default-login-domain"/>
                                        </xsl:when>
                                        <xsl:otherwise><xsl:text> None </xsl:text></xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                            <tr>
                                <td >Enable Secure Sockets Layer (SSL) for communications:</td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/exma-configuration/default-ssl-bind='0'">
                                            No
                                        </xsl:when>
                                        <xsl:otherwise><xsl:text> Yes </xsl:text></xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </table>
                    </TD>
                </TR>
            </xsl:if>

<!--
**********************************************************************************************************************************
    This is sub-section of Private Configuration which handles the Private Configuration data of an MA of Type Novell eDirectory.
**********************************************************************************************************************************
-->
            <xsl:if test="$category='eDirectory'">
                <TR>
                    <TD class="tdLeftSection"><b>Server Connection Information </b></TD>
                    <TD align='left'><a NAME='#eDirectory1'></a>
                        <table align='left' class="tableClass4" cellspacing='0' cellpadding='0' bordercolordark='#ffffff' border='1' >
                            <tr>
                                <th colspan='2' class="thAttributeFlow1"><b>Server Connection Information</b></th>
                            </tr>
                            <tr>
                                <td >Server name:</td>
                                <xsl:choose >
                                    <xsl:when test="//ma-data/private-configuration/edma-configuration/default-server!=''">
                                     <td ><xsl:value-of select="//ma-data/private-configuration/edma-configuration/default-server"/></td>
                                    </xsl:when>
                                    <xsl:otherwise><xsl:text> None </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose >
                            </tr>
                            <tr>
                                <td >Port:</td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/edma-configuration/default-port!=''">
                                            <xsl:value-of select="//ma-data/private-configuration/edma-configuration/default-port"/>
                                        </xsl:when>
                                        <xsl:otherwise><xsl:text> None </xsl:text></xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                            <tr>
                                <td >User name:</td>
                                <xsl:choose >
                                    <xsl:when test="//ma-data/private-configuration/edma-configuration/default-login-user!=''">
                                        <td ><xsl:value-of select="//ma-data/private-configuration/edma-configuration/default-login-user"/></td>
                                    </xsl:when>
                                    <xsl:otherwise><td><xsl:text> None </xsl:text></td></xsl:otherwise>
                                </xsl:choose >
                            </tr>
                            <tr>
                                <td >Enable Secure Sockets Layer (SSL)for communications:</td>
                                    <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/edma-configuration/default-ssl-bind='0'">
                                            No
                                        </xsl:when>
                                        <xsl:otherwise><xsl:text> Yes </xsl:text></xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                            <tr>
                                <td >Enable Simple Authentication Security Layer (SASL) for communications:</td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/edma-configuration/default-sasl-mechanism='1'">
                                            Yes
                                        </xsl:when>
                                        <xsl:otherwise><xsl:text> No </xsl:text></xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </table>
                    </TD>
                </TR>
            </xsl:if>

<!--
**********************************************************************************************************************************
    This is sub-section of Private Configuration which handles the Private Configuration data of an MA of Type Lotus Notes Server.
**********************************************************************************************************************************
-->
            <xsl:if test="$category='Notes'">
                <TR>
                    <TD class="tdLeftSection"><b> Server Connection Information </b></TD>
                    <TD align='left'><a NAME='#NOTES1'></a>
                        <table cellspacing='0' cellpadding='0' bordercolordark='#ffffff' border='1' align='left' class="tableClass4">
                            <tr>
                                <th colspan='2' class="thAttributeFlow1"><b> Connect to Notes server Information </b></th>
                            </tr>

                            <tr>
                                <td ><b> Hierarchical Server name:</b></td>
                                <td ><xsl:value-of select="//ma-data/private-configuration/lnma-configuration/server"/></td>
                            </tr>

                            <tr>
                                <td ><b> User ID file:</b></td>
                                <td class="tdClass3">
                                    <xsl:value-of select="//ma-data/private-configuration/lnma-configuration/userid"/>
                                </td>
                            </tr>

                            <tr>
                                <td  colspan='2'>
                                <table>
                                    <tr><td><b>Address Books:</b></td></tr>                                                                        
                                    <xsl:for-each select="//ma-data/private-configuration/lnma-configuration/ou-list/item/nab"> 
									<xsl:if test="selected > 0">
										<li><xsl:value-of select="."/></li>
									</xsl:if>
									</xsl:for-each> 
                                    
                                    <xsl:for-each select="//ma-data/ma-partition-data/partition"> 
                                    <xsl:if test="selected > 0">
                                    <tr>
                                        <td >
                                           <li> <xsl:value-of select="name"/> </li>                                                                                      
                                        </td>
                                    </tr>
                                    </xsl:if>
                                    </xsl:for-each> 
                                </table>
                                </td>
                            </tr>                            
                        </table>
                    </TD>
                </TR>

            </xsl:if>

<!--
**********************************************************************************************************************************
    This is sub-section of Private Configuration which handles the Private Configuration data of an MA of Type Windows NT Server.
**********************************************************************************************************************************
-->
            <xsl:if test="$category='NT'">
                <TR>
                    <TD class="tdLeftSection"><b>Domain Connection Information </b></TD>
                    <TD align='left'><a NAME='#NT1'></a>
                        <table cellspacing='0' cellpadding='0' bordercolordark='#ffffff' border='1' >
                            <tr>
                                <th colspan='2' class="thAttributeFlow1"><b>Connect to domain </b></th>
                            </tr>
                            <tr>
                                <td >Domain to discover:</td>
                                <xsl:choose >
                                    <xsl:when test="//ma-data/private-configuration/ntma-configuration/domain!=''">
                                        <td ><xsl:value-of select="//ma-data/private-configuration/ntma-configuration/domain"/></td>
                                    </xsl:when>

                                    <xsl:otherwise><td><xsl:text> None </xsl:text></td></xsl:otherwise>
                                </xsl:choose >
                            </tr>
                            <tr>
                                <td >User name:</td>
                                    <xsl:choose >
                                        <xsl:when test="//ma-data/private-configuration/ntma-configuration/login-user!=''">
                                            <td ><xsl:value-of select="//ma-data/private-configuration/ntma-configuration/login-user"/></td>
                                        </xsl:when>

                                        <xsl:otherwise><td><xsl:text> None </xsl:text></td></xsl:otherwise>
                                </xsl:choose >
                            </tr>
                            <tr>
                                <td >Domain:</td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/ntma-configuration/login-domain!=''">
                                            <xsl:value-of select="//ma-data/private-configuration/ntma-configuration/login-domain"/>
                                        </xsl:when>
                                        <xsl:otherwise><xsl:text> - </xsl:text></xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </table>
                    </TD>
                </TR>
            </xsl:if>

<!--
**********************************************************************************************************************************
    This is sub-section of Private Configuration which handles the Private Configuration data of an MA of Type SQL Server & Oracle.
**********************************************************************************************************************************
-->
            <xsl:if test="$category='Oracle' or $category='MSSQL' or $category='DB2'">
                <TR>
                    <TD class="tdLeftSection"><b>Database Configuration </b></TD>
                    <TD align='left'><a NAME='#DBConf'></a>
                        <table border='1' cellpadding='0' cellspacing='0' bordercolordark='#ffffff'>
                            <tr>
                                <th colspan='2' class="thAttributeFlow1">
                                    <xsl:choose>
                                        <xsl:when test="$category='MSSQL'">
                                            <b>SQL Server connection Information</b>
                                        </xsl:when>

                                        <xsl:when test="$category='Oracle'">
                                            <b>Oracle Database Connection Information</b>
                                        </xsl:when>

                                        <xsl:when test="$category='DB2'">
                                            <b>DB2 Database Connection Information</b>
                                        </xsl:when>

                                        <xsl:otherwise>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </th>
                            </tr>

                            <xsl:if test="//ma-data/private-configuration/oledbma-configuration/connection-info/server">
                                <tr>
                                    <td ><b>Server Name:</b></td>
                                    <td ><xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/connection-info/server"/></td>
                                </tr>
                            </xsl:if>

                            <tr>
                                <xsl:choose>
                                    <xsl:when test="//ma-data/private-configuration/oledbma-configuration/connection-info/databasename">
                                        <td ><b>Database:</b></td>
                                        <td ><xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/connection-info/databasename"/></td>
                                    </xsl:when>

                                    <xsl:when test="//ma-data/private-configuration/oledbma-configuration/connection-info/datasource">
                                        <td ><b>Data source:</b></td>
                                        <td ><xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/connection-info/datasource"/></td>
                                    </xsl:when>

                                    <xsl:otherwise>
                                        <td ><b>Database:</b></td>
                                        <td > None </td>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </tr>

                            <tr>
                                <td ><b>Table/View:</b></td>
                                <td >
                                    <xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/connection-info/tablename"/>
                                </td>
                            </tr>

                            <tr>
                                <td ><b>Delta table/view:</b></td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/oledbma-configuration/connection-info/delta-tablename!=''">
                                            <xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/connection-info/delta-tablename"/>
                                        </xsl:when>
                                        <xsl:otherwise> - </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                            <tr>
                                <td ><b>Multivalued table:</b></td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/oledbma-configuration/connection-info/multivalued-tablename!=''">
                                            <xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/connection-info/multivalued-tablename"/>
                                        </xsl:when>
                                        <xsl:otherwise> - </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                                
                            <xsl:if test="$category!='DB2'">
                            <tr>
                                <td ><b>Authentication:</b></td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/oledbma-configuration/connection-info/authentication = 'integrated'">
                                            <xsl:text> Windows integrated authentication </xsl:text>
                                        </xsl:when>

                                        <xsl:when test="//ma-data/private-configuration/oledbma-configuration/connection-info/authentication = 'database'">
                                            <xsl:choose>
                                                <xsl:when test="$category='Oracle'">
                                                    <xsl:text> Database authentication </xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$category='MSSQL'">
                                                    <xsl:text> SQL authentication </xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <p> </p>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>

                                        <xsl:otherwise>
                                            <xsl:text> None </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                            </xsl:if>

                            <tr>
                                <td ><b>User name:</b></td>
                                <td >
                                    <xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/connection-info/user"/>
                                </td>
                            </tr>
                            
                            <!-- Start of of Domain-->
                            <xsl:if test="$category!='DB2'">
                            <tr>
                                <td ><b>Domain:</b></td>
                                <td >
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/oledbma-configuration/connection-info/domain!=''">
                                            <xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/connection-info/domain"/>
                                        </xsl:when>

                                        <xsl:otherwise> - </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                            </xsl:if>
                            <!-- End of of Domain-->
                        </table>
                    </TD>
                </TR>
            </xsl:if>

<!--
    #################################################################################################################################
    This section handles the Selected Attributes of the MA. 
    The following sections render the information for different MA's
    AVP, Delimited, Fixed, DSML, LDIF and Extensible (which is based off these).
    #################################################################################################################################
-->
            <xsl:if test="$category='AVP' or $category='Delimited' or $category='DSML' or $category='Fixed' or $category='LDIF' or $category='Extensible'">
                <TR>
                    <TD class="tdLeftSection"><b>Selected Attributes </b></TD>
                    <TD align='left'><a NAME='#Attri'></a>
                        <TABLE align='left'>
                        <TR>
                        <TD>
                        <table border='1' cellpadding='0' cellspacing='0' bordercolordark='#ffffff' align='left' class="tableClass4">
                            <tr>
                                <td class="thAttributeFlow1"> <b>Attribute Name </b></td>
                                <td class="thAttributeFlow1"> <b>Type </b></td>
                                <td class="thAttributeFlow1"> <b>MultiValued </b></td>
								<td class="thAttributeFlow1"> <b>Min Length</b></td>
								<td class="thAttributeFlow1"> <b>Max Length</b></td>
                            </tr>

                            <!-- Iterate each attribute in attributes.-->
                            <xsl:for-each select="//ma-data/private-configuration/MAConfig/ui-data/xmlwizard/attributes/attribute">
                                <tr>
                                    <td><xsl:value-of select="@ cd_name"/></td>

                                    <xsl:choose>
                                        <xsl:when test="@ type='DN'">
                                            <td><xsl:text> Reference (DN) </xsl:text></td>
                                        </xsl:when>

                                        <xsl:when test="@ type='Bool'">
                                            <td><xsl:text> Boolean </xsl:text></td>
                                        </xsl:when>

                                        <xsl:otherwise>
                                            <td><xsl:value-of select="@ type"/></td>
                                        </xsl:otherwise>
                                    </xsl:choose>

                                    <xsl:choose>
                                        <xsl:when test="@ multi_valued='-1'">
                                            <td><xsl:text> Yes </xsl:text></td>
                                        </xsl:when>

                                        <xsl:otherwise>
                                            <td><xsl:text> No </xsl:text></td>
                                        </xsl:otherwise>
                                    </xsl:choose>

                                    <xsl:choose>
                                        <xsl:when test="@ lower_bound=''">
                                            <td><xsl:text> - </xsl:text></td>
                                        </xsl:when>

                                        <xsl:otherwise>
                                            <td><xsl:value-of select="@ lower_bound"/></td>
                                        </xsl:otherwise>
                                    </xsl:choose>

                                    <xsl:choose>
                                        <xsl:when test="@ upper_bound=''">
                                            <td><xsl:text> - </xsl:text></td>
                                        </xsl:when>

                                        <xsl:otherwise>
                                            <td><xsl:value-of select="@ upper_bound"/></td>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                            </xsl:for-each>
                            <!-- End of attribute for-each.-->
                            </table>
                            </TD>
                            </TR>
                            <TR>
                            <TD>
                            <table  border='1' cellpadding='0' cellspacing='0' bordercolordark='#ffffff' align='left' class="tableClass4">
                            <tr>
                                <td> <b>Anchor Attribute(s): </b></td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/MAConfig/importing/anchor/dn">
                                        <xsl:text> dn </xsl:text>
                                        </xsl:when>
                                        <xsl:when test="//ma-data/private-configuration/MAConfig/importing/anchor/attribute">
                                            <xsl:for-each select="//ma-data/private-configuration/MAConfig/importing/anchor/attribute">
                                                <xsl:if test="position() &gt; 1">
                                                    <xsl:text> + </xsl:text>
                                                </xsl:if>
                                                <xsl:value-of select="."/>
                                            </xsl:for-each>
                                        </xsl:when>

                                        <xsl:otherwise>
                                            <xsl:text> None </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>

                            <xsl:if test="$category!='LDIF' and $category!='DSML'">
                            <tr>
                                <td><b>Input file contains LDAP distinguished name: </b></td> 
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/MAConfig/ldap-dn='1'">
                                            Yes
                                        </xsl:when>

                                        <xsl:otherwise> 
                                            No
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>

                            <xsl:if test="//ma-data/private-configuration/MAConfig/ldap-dn='1'">
                            <tr>
                                <td> <b> Distinguished name attribute: </b></td>
                            <xsl:choose>
                            <xsl:when test="$category='DSML'">
                            <td> - </td>
                            </xsl:when>
                            <xsl:otherwise>
                                <td><xsl:value-of select="//ma-data/private-configuration/MAConfig/importing/dn/attribute"/></td>
                            </xsl:otherwise>
                            </xsl:choose>
                            </tr>
                            </xsl:if>

                            <xsl:if test="//ma-data/private-configuration/MAConfig/change_type_attribute!=''">
                            <tr>
                                <td><b>Change type attribute: </b></td> 
                                <td> <xsl:value-of select="//ma-data/private-configuration/MAConfig/change_type_attribute"/> </td>
                            </tr>
                            <tr>
                                <td><b>Modify: </b></td> 
                                <td> <xsl:value-of select="//ma-data/private-configuration/MAConfig/modify_change_type_value"/> </td>
                            </tr>
                            <tr>
                                <td><b>Add: </b></td> 
                                <td> <xsl:value-of select="//ma-data/private-configuration/MAConfig/add_change_type_value"/> </td>
                            </tr>
                            <tr>
                                <td><b>Delete: </b></td> 
                                <td> <xsl:value-of select="//ma-data/private-configuration/MAConfig/delete_change_type_value"/> </td>
                            </tr>
                            </xsl:if>

                            </xsl:if>
                            <!-- End of test="$category!='LDIF'" if.-->



                            <xsl:if test="//ma-data/private-configuration/MAConfig/attribute_value_pair_format/code_page/.">
                            <tr>
                                <td> <b>Code Page: </b></td>
                                <xsl:choose>
                                 <xsl:when test="//ma-data/private-configuration/MAConfig/attribute_value_pair_format/code_page!=''">
                                <td> <xsl:value-of select="//ma-data/private-configuration/MAConfig/attribute_value_pair_format/code_page"/> 
                                        <xsl:if test="//ma-data/private-configuration/MAConfig/ui-data/xmlwizard/properties/code_page_description/.">
                                                                        - <xsl:value-of select="//ma-data/private-configuration/MAConfig/ui-data/xmlwizard/properties/code_page_description"/>
                                        </xsl:if>
                                </td>
                                 </xsl:when>
                                <xsl:otherwise>
                                    <td><xsl:text> None </xsl:text></td>
                                </xsl:otherwise>
                                </xsl:choose>
                            </tr>
                            </xsl:if>

                            <xsl:if test="//ma-data/private-configuration/MAConfig/ldif_format/code_page/.">
                            <tr>
                                <td> <b>Code Page: </b></td>
                                <xsl:choose>
                                 <xsl:when test="//ma-data/private-configuration/MAConfig/ldif_format/code_page!=''">
                                <td> <xsl:value-of select="//ma-data/private-configuration/MAConfig/ldif_format/code_page"/> 
                                        <xsl:if test="//ma-data/private-configuration/MAConfig/ui-data/xmlwizard/properties/code_page_description/.">
                                                                        - <xsl:value-of select="//ma-data/private-configuration/MAConfig/ui-data/xmlwizard/properties/code_page_description"/>
                                        </xsl:if>
                                </td>
                                 </xsl:when>
                                <xsl:otherwise>
                                    <td><xsl:text> None </xsl:text></td>
                                </xsl:otherwise>
                                </xsl:choose>
                            </tr>
                            </xsl:if>

                            <xsl:if test="//ma-data/private-configuration/MAConfig/fixed_width_format/code_page/.">
                            <tr>
                                <td> <b>Code Page: </b></td>
                                <xsl:choose>
                                 <xsl:when test="//ma-data/private-configuration/MAConfig/fixed_width_format/code_page!=''">
                                <td> <xsl:value-of select="//ma-data/private-configuration/MAConfig/fixed_width_format/code_page"/> 
                                        <xsl:if test="//ma-data/private-configuration/MAConfig/ui-data/xmlwizard/properties/code_page_description/.">
                                                                        - <xsl:value-of select="//ma-data/private-configuration/MAConfig/ui-data/xmlwizard/properties/code_page_description"/>
                                        </xsl:if>
                                </td>
                                 </xsl:when>
                                <xsl:otherwise>
                                    <td><xsl:text> None </xsl:text></td>
                                </xsl:otherwise>
                                </xsl:choose>
                            </tr>
                            </xsl:if>

                            <xsl:if test="//ma-data/private-configuration/MAConfig/delimited_format/code_page/.">
                            <tr>
                                <td> <b>Code Page: </b></td>
                                <xsl:choose>
                                 <xsl:when test="//ma-data/private-configuration/MAConfig/delimited_format/code_page!=''">
                                <td> <xsl:value-of select="//ma-data/private-configuration/MAConfig/delimited_format/code_page"/> 
                                        <xsl:if test="//ma-data/private-configuration/MAConfig/ui-data/xmlwizard/properties/code_page_description/.">
                                                                        - <xsl:value-of select="//ma-data/private-configuration/MAConfig/ui-data/xmlwizard/properties/code_page_description"/>
                                        </xsl:if>
                                </td>
                                 </xsl:when>
                                <xsl:otherwise>
                                    <td><xsl:text> None </xsl:text></td>
                                </xsl:otherwise>
                                </xsl:choose>
                            </tr>
                            </xsl:if>
                            <xsl:if test="//ma-data/private-configuration/MAConfig/delimited_format/delimiter/.">
                            <tr>
                                <td> <b>Delimiter: </b></td>
                                <xsl:choose>
                                 <xsl:when test="//ma-data/private-configuration/MAConfig/delimited_format/delimiter!=''">
                                <td>
                                <xsl:variable name='Delimiter_Value' select='//ma-data/private-configuration/MAConfig/delimited_format/delimiter'> </xsl:variable>
                                <xsl:text disable-output-escaping="yes">&amp;#</xsl:text>
                                <xsl:value-of select="$Delimiter_Value" />
                                <xsl:text>;</xsl:text>
                                </td>
                                 </xsl:when>
                                <xsl:otherwise>
                                    <td><xsl:text> None </xsl:text></td>
                                </xsl:otherwise>
                                </xsl:choose>
                            </tr>
                            </xsl:if>

                            <xsl:if test="//ma-data/private-configuration/MAConfig/dsml_format/code_page/.">
                            <tr>
                                <td> <b>Code Page: </b></td>
                                <xsl:choose>
                                 <xsl:when test="//ma-data/private-configuration/MAConfig/dsml_format/code_page!=''">
                                <td> <xsl:value-of select="//ma-data/private-configuration/MAConfig/dsml_format/code_page"/> 
                                        <xsl:if test="//ma-data/private-configuration/MAConfig/ui-data/xmlwizard/properties/code_page_description/.">
                                                                        - <xsl:value-of select="//ma-data/private-configuration/MAConfig/ui-data/xmlwizard/properties/code_page_description"/>
                                        </xsl:if>
                                </td>
                                 </xsl:when>
                                <xsl:otherwise>
                                    <td><xsl:text> None </xsl:text></td>
                                </xsl:otherwise>
                                </xsl:choose>
                            </tr>
                            </xsl:if>

                            <xsl:if test="//ma-data/private-configuration/MAConfig/importing/object_class_attribute/.!='' or //ma-data/private-configuration/MAConfig/importing/default_object_class/.!=''">
                            <tr>
                                <td colspan='2'><b> Define Object Class:</b></td>
                            </tr>
                            <xsl:if test="//ma-data/private-configuration/MAConfig/importing/object_class_attribute/.">
                            <tr>
                                <td><b>Object Class Attribute: </b></td>
                                <td><xsl:value-of select="//ma-data/private-configuration/MAConfig/importing/object_class_attribute"/></td>
                            </tr>
                            </xsl:if>
                            <xsl:if test="//ma-data/private-configuration/MAConfig/importing/default_object_class/.">
                            <tr>
                                <td><b>Fixed Object Type Value: </b></td>
                                <td><xsl:value-of select="//ma-data/private-configuration/MAConfig/importing/default_object_class"/></td>
                            </tr>
                            </xsl:if>
                            </xsl:if>
    
                        </table>
                    </TD>
                    </TR>
                </TABLE>
                </TD>
                </TR>
            </xsl:if>



<!--
    #################################################################################################################################
    This section handles the Map Object Types for following types of MA's
    AVP, Delimited, Fixed, DSML, LDIF, Extensible.
    #################################################################################################################################
-->
<xsl:if test="$category='Fixed' or $category='DSML' or $category='AVP' or $category='Delimited' or $category='LDIF'or $category='Extensible' ">
<TR>
<TD class="tdLeftSection"><b>Map Object Types </b></TD>
<TD align='left'><a NAME='#Map'></a>
    <table border='1' bordercolordark='#ffffff' cellpadding='0' cellspacing='0' align='left' class="tableClass4">
    <tr >
        <td class="thAttributeFlow1"><b> Object Class </b></td>
        <td class="thAttributeFlow1"><b> Object Type </b></td>
    </tr>
    <xsl:for-each select="//ma-data/private-configuration/MAConfig/ui-data/xmlwizard/primary_class_mappings/mapping">
    <tr>
        <td><xsl:value-of select="@object_class"/> </td>
        <td><xsl:value-of select="@primary_class"/> </td>
    </tr>
    </xsl:for-each>
    </table>
</TD>
</TR>
</xsl:if>

<!--
    #################################################################################################################################
    This section handles the Define object types for following types of MA's
    AVP, Delimited, Fixed, DSML, LDIF, Extensible.
    #################################################################################################################################
-->
<xsl:if test="$category='Fixed' or $category='DSML' or $category='AVP' or $category='Delimited' or $category='LDIF' or $category='Extensible' ">
<TR>
<TD class="tdLeftSection"><b> Define Object Types </b></TD>
<TD align='left'><a NAME='#DefineObjectTypes'></a>
    <table align='left' class="tableClass4">
    <xsl:for-each select="//ma-data/private-configuration/MAConfig/ui-data/xmlwizard/object_classes/object_class">
    <xsl:if test="@selected!=0"> 
    <xsl:variable name="anchor" select="@anchor"/>
    <tr><td><b> Object Type: </b></td><td><xsl:value-of select="@cd_name"/></td> </tr>
    <tr><td><b>Use distinguished name as anchor attribute: </b></td>
        <td>
        <xsl:choose>
        <xsl:when test="@dn_as_anchor='-1'">
        <xsl:text> Yes </xsl:text>
        </xsl:when>
        <xsl:otherwise>
        <xsl:text> No </xsl:text>
        </xsl:otherwise>
        </xsl:choose>
        </td>
    </tr>

    <tr>
        <td colspan="2"> 
        <table border='1' cellspacing='0' cellpadding='0' bordercolordark='#ffffff' class="tableClass4">
            <tr>
                <td class="thAttributeFlow1"><b> Attribute Name </b></td>
                <td class="thAttributeFlow1"><b> Must Have </b></td>
            </tr>

            <xsl:for-each select="attribute">
            <tr>
                <td> <xsl:value-of select="."/></td>
                <td>
                    <xsl:choose>
                        <xsl:when test="@ mandatory='0'">
                            <xsl:text> No </xsl:text>
                        </xsl:when>

                        <xsl:when test="@ mandatory='-1'">
                            <xsl:choose>
                                <xsl:when test="$anchor=.">
                                    <xsl:text>
                                        Anchor
                                    </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>
                                        Yes
                                    </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>

                    </xsl:choose>
                </td>
            </tr>
            </xsl:for-each>

        </table>
        </td>
    </tr>
    </xsl:if> 
    </xsl:for-each>
    </table>
</TD>
</TR>
</xsl:if>

<!--
#################################################################################################################################
    This section handles the Partition Information of MA.
    is divided into following subsections.
    1. File Based (AVP, Fixed, LDIF, DSML, Delimited, Extensible)
    2. AD, AD GAL
    3. ADAM
    4. Exchange, Exchange GAL
#################################################################################################################################
-->
<!--
**********************************************************************************************************************************
    This section handles the Partition Information of the MA for File based MAs.
**********************************************************************************************************************************
-->

            <xsl:if test="$category='AVP' or $category='Fixed' or $category='Delimited' or $category='LDIF' or $category='DSML' or $category='Extensible'">
                <TR>
                    <TD class="tdLeftSection"><b>Partitions Configured </b></TD>
                    <TD align='left'><a NAME='#Partition'></a>
                        <xsl:choose>

                            <xsl:when test="//ma-data/ma-partition-data!=''">
                                <table border='1' cellspacing='0' cellpadding='0' bordercolordark='#ffffff' align='left' class="tableClass4" >
                                    <tr>
                                        <td align='center' class="thAttributeFlow1">
                                            <b> Object Type </b>
                                        </td>
                                        <td align='center' class="thAttributeFlow1">
                                            <b> Partition Name </b>
                                        </td>
                                    </tr>
                                    
                                    <xsl:for-each select="//ma-data/ma-partition-data/partition">
                                        <xsl:if test="selected>0">
                                            <xsl:variable name='partition_name' select="name"/>
                                            <xsl:for-each select="filter/object-classes/object-class">
                                                <tr>
                                                    <td>
                                                        <xsl:value-of select="."/>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="$partition_name"/>
                                                    </td>
                                                </tr>
                                            </xsl:for-each>
                                        </xsl:if>
                                    </xsl:for-each>

                                </table>
                            </xsl:when>
                            
                            <xsl:otherwise> Not Configured </xsl:otherwise>
                        </xsl:choose>
                    </TD>
                </TR>
            </xsl:if>
<!--
**********************************************************************************************************************************
    This section handles the Partition Information of the MA 
    AD, AD GAL only.
**********************************************************************************************************************************
-->
            <xsl:if test = "$category = 'AD' or $category = 'AD GAL'">
                <TR>
                    <TD class="tdLeftSection"><b>Partition Information </b></TD>
                    <TD align='left'><a NAME='#Part1'></a>
                        <table  border='1' cellspacing='0' cellpadding='0' bordercolordark='#ffffff' align='left'  class="tableClass4">
                            <xsl:choose>
                                <xsl:when test="//ma-data/ma-partition-data!=''">
                                    <xsl:for-each select="//ma-data/ma-partition-data/partition">
                                        <xsl:if test="selected > 0">
                                            <tr>
                                                <td><b>Partition Name: </b> <xsl:value-of select="name"/></td>
                                            </tr>
                                            <!-- Start of Display name-->
                                            <xsl:if test="display-name">
                                            <tr>
                                                <td><b>Display Name: </b> <xsl:value-of select="display-name"/></td>
                                            </tr>
                                            </xsl:if>
                                            <!-- End of display name-->
                                            <xsl:if test="//ma-data/ma-partition-data/partition/custom-data">
                                                <tr>
                                                    <td>
                                                        <table class="tableClass4" id='1' border='1' cellspacing='0' bordercolordark='#ffffff'>
                                                            <tr>
                                                                <td><b>Preferred Domain Controllers: </b></td>
                                                                <xsl:choose>
                                                                    <xsl:when test="custom-data/adma-partition-data/preferred-dcs/preferred-dc!=''">
                                                                        <td>
                                                                            <xsl:for-each select="custom-data/adma-partition-data/preferred-dcs/preferred-dc">
                                                                                    <li><xsl:value-of select="."/></li>
                                                                            </xsl:for-each>
                                                                        </td>
                                                                    </xsl:when>

                                                                    <xsl:otherwise><td> None </td></xsl:otherwise>
                                                                </xsl:choose>
                                                            </tr>

                                                            <tr>
                                                                <td><b>Last domain controller used: </b></td>
                                                                <xsl:choose>
                                                                    <xsl:when test="custom-data/adma-partition-data/last-dc">
                                                                        <td><xsl:value-of select="custom-data/adma-partition-data/last-dc"/></td>
                                                                    </xsl:when>

                                                                    <xsl:otherwise><td> None </td></xsl:otherwise>
                                                                </xsl:choose>
                                                            </tr>

                                                            <tr>
                                                                <td><b>Only use preferred domain controller: </b></td>
                                                                <xsl:choose>
                                                                    <xsl:when test="custom-data/adma-partition-data/dc-failover='1'">
                                                                        <td><xsl:text> No </xsl:text></td>
                                                                    </xsl:when>

                                                                    <xsl:when test="custom-data/adma-partition-data/dc-failover='0'">
                                                                        <td><xsl:text> Yes </xsl:text></td>
                                                                    </xsl:when>

                                                                    <xsl:otherwise><td> None </td></xsl:otherwise>
                                                                </xsl:choose>
                                                            </tr>

                                                            <tr>
                                                                <td><b>Sign and encrypt LDAP traffic:</b></td>
                                                                <xsl:choose>
                                                                    <xsl:when test="custom-data/adma-partition-data/sign-and-seal">
                                                                        <td>
                                                                            <xsl:choose>
                                                                                <xsl:when test="custom-data/adma-partition-data/sign-and-seal">
                                                                                    <xsl:text> Yes </xsl:text>
                                                                                </xsl:when>

                                                                                <xsl:otherwise>
                                                                                    <xsl:text> No </xsl:text>
                                                                                </xsl:otherwise>
                                                                            </xsl:choose>
                                                                        </td>
                                                                    </xsl:when>

                                                                    <xsl:otherwise><td> None </td>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </tr>

                                                            <xsl:choose>
                                                                <xsl:when test="custom-data/adma-partition-data/login-domain!='' or custom-data/adma-partition-data/login-user!=''">
                                                                    <tr>
                                                                        <td colspan='2'><b> Alternate Credentials </b></td>
                                                                    </tr>

                                                                    <tr>
                                                                        <td><b>User: </b></td>
                                                                        <xsl:choose>
                                                                            <xsl:when test="custom-data/adma-partition-data/login-user">
                                                                                <td><xsl:value-of select="custom-data/adma-partition-data/login-user"/></td>
                                                                            </xsl:when>

                                                                            <xsl:otherwise><td> None </td></xsl:otherwise>
                                                                        </xsl:choose>
                                                                    </tr>

                                                                    <tr>
                                                                        <td><b>Domain: </b></td>
                                                                        <td>
                                                                        <xsl:choose>
                                                                            <xsl:when test="custom-data/adma-partition-data/login-domain">

                                                                                <xsl:choose>
                                                                                    <xsl:when test="custom-data/adma-partition-data/login-domain!=''">
                                                                                        <xsl:value-of select="custom-data/adma-partition-data/login-domain"/>
                                                                                    </xsl:when>

                                                                                    <xsl:otherwise>
                                                                                        <xsl:text> None </xsl:text>
                                                                                    </xsl:otherwise>
                                                                                </xsl:choose>

                                                                            </xsl:when>

                                                                            <xsl:otherwise>
                                                                                 <xsl:text> None </xsl:text>
                                                                            </xsl:otherwise>
                                                                        </xsl:choose>
                                                                        </td>
                                                                    </tr>

                                                                </xsl:when>

                                                                <xsl:otherwise>
                                                                    <tr>
                                                                        <td><b> Use default credentials </b></td>
                                                                        <td> Yes </td>
                                                                    </tr>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </table>
                                                    </td>
                                                </tr>

                                                <xsl:if test="//ma-data/ma-partition-data/partition/filter/containers/exclusions/exclusion!='' or //ma-data/ma-partition-data/partition/filter/containers/inclusions/inclusion!=' '">
                                                    <tr>
                                                        <td>
                                                            <table cellspacing='0' cellpadding='0' border='1' width='100%' bordercolordark='#ffffff'>
                                                                <tr>
                                                                    <td colspan='2'><b> Selected Containers to Synchronize </b></td>
                                                                </tr>

                                                                <tr>
                                                                    <td><b> Include </b></td>
                                                                    <td><b> Container </b></td>
                                                                </tr>

                                                                <xsl:for-each select="filter/containers/exclusions/exclusion">
                                                                    <tr>
                                                                        <td> Exclude </td>
                                                                        <td><xsl:value-of select="."/></td>
                                                                    </tr>
                                                                </xsl:for-each>

                                                                <xsl:for-each select="filter/containers/inclusions/inclusion">
                                                                    <tr>
                                                                        <td> Include </td>
                                                                        <td><xsl:value-of select="."/></td>
                                                                    </tr>
                                                                </xsl:for-each>
                                                            </table>

                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                       
                                                <tr>
                                                    <td>
                                                        <table class="tableClass4" id='1' border='1' cellspacing='0' bordercolordark='#ffffff'>
                                                            <tr>
                                                                <th colspan='2'>Password Synchronization</th>
                                                            </tr>
                                                            <tr>                                                  
                                                                <td>Enable partition as a password synchronization source:</td>
                                                                <td>
                                                                    <xsl:choose>
                                                                        <xsl:when test="password-sync/password-source-enabled='1'">
                                                                            <xsl:text>Yes</xsl:text>
                                                                        </xsl:when>
                                                                        <xsl:otherwise><xsl:text>No</xsl:text></xsl:otherwise>
                                                                    </xsl:choose>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Maximum number of password changes for a 24 hour period</td>
                                                                <td>
                                                                    <xsl:choose>
                                                                        <xsl:when test="password-sync/max-changes-allowed=''">
                                                                            <xsl:text>Disabled</xsl:text>
                                                                        </xsl:when>
                                                                        <xsl:otherwise><xsl:value-of select="password-sync/max-changes-allowed"/></xsl:otherwise>
                                                                    </xsl:choose>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>

                                            </xsl:if>
                                            <!-- End of test="//ma-data/ma-partition-data/partition/custom-data" if.-->

                                        </xsl:if>
                                        <!-- End of test="selected > 0" if.-->
                                    </xsl:for-each>
                                    <!-- End of select="//ma-data/ma-partition-data/partition" for-each.-->

                                </xsl:when>
                                <!-- End of test="//ma-data/ma-partition-data!=''" when.-->

                                <xsl:otherwise>
                                <tr>
                                    <td>
                                        <xsl:text> None </xsl:text>
                                    </td>
                                </tr>
                                </xsl:otherwise>
                            </xsl:choose>
                        </table>
                    </TD>
                </TR>
            </xsl:if>


<!--
**********************************************************************************************************************************
    This section handles the Partition Information of the MA ADAM.
**********************************************************************************************************************************
-->
            <xsl:if test = "$category = 'ADAM'">
                <TR>
                    <TD class="tdLeftSection"><b>Directory Partitions Configured</b></TD>
                    <TD align='left'><a NAME='#ADAM2'></a>
                        <table align='left' class="tableClass4">
                            <xsl:choose>
                                <xsl:when test="//ma-data/ma-partition-data!=''">

                                <!-- Iterate each partition.-->

                                <xsl:for-each select="//ma-data/ma-partition-data/partition">
                                        <xsl:if test="selected > 0">
                                            <tr>
                                                <td><b>Partition Name: </b> <xsl:value-of select="name"/></td>
                                            </tr>
                                            <xsl:if test="custom-data">

                                                <xsl:if test="filter/containers/exclusions/exclusion!='' or filter/containers/inclusions/inclusion!=' '">
                                                    <tr>
                                                        <td>
                                                            <table cellspacing='0' cellpadding='0' border='1' bordercolordark='#ffffff' width='100%'>
                                                                <tr>
                                                                    <td colspan='2'><b> Containers to synchronize </b></td>
                                                                </tr>

                                                                <tr>
                                                                    <td><b> Include </b></td>
                                                                    <td><b> Container </b></td>
                                                                </tr>

                                                                <xsl:for-each select="filter/containers/exclusions/exclusion">
                                                                    <tr>
                                                                        <td> Exclude </td>
                                                                        <td><xsl:value-of select="."/></td>
                                                                    </tr>
                                                                </xsl:for-each>

                                                                <xsl:for-each select="filter/containers/inclusions/inclusion">
                                                                    <tr>
                                                                        <td> Include </td>
                                                                        <td><xsl:value-of select="."/></td>
                                                                    </tr>
                                                                </xsl:for-each>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <!-- End of if after custom-data if.-->

                                            </xsl:if>
                                            <!-- End of test="custom-data" if.-->

                                        </xsl:if>
                                        <!-- End of test="selected > 0" if.-->

                                        <!--Start of Password sync enabled for source If-->
                                        <xsl:if test="password-sync/password-sync-source-enabled/.">
                                        <tr>
                                        <td>
                                            <table cellspacing='0' cellpadding='0' border='1' bordercolordark='#ffffff' width='100%'>
                                            <tr>
                                                <td colspan='2'><b> Password Synchronization: </b></td>
                                            </tr>
                                            <tr>
                                                <td>Configure as source domain: </td>
                                                <td>
                                                    <xsl:if test="password-sync/password-sync-source-enabled=1">
                                                        <xsl:text> True </xsl:text>
                                                    </xsl:if>
                                                    <xsl:if test="password-sync/password-sync-source-enabled=0">
                                                        <xsl:text> False</xsl:text>
                                                    </xsl:if>
                                                </td>
                                            </tr>
                                            </table>
                                        </td>
                                        </tr>
                                        </xsl:if>
                                        <!--End of Password sync enabled for source If-->

                                        </xsl:for-each>
                                        <!-- End of select="//ma-data/ma-partition-data/partition" for-each.-->

                                </xsl:when>
                                <!-- End of test="//ma-data/ma-partition-data!=''" when.-->

                                <xsl:otherwise>
                                <tr>
                                    <td>
                                        <xsl:text> None </xsl:text>
                                    </td>
                                </tr>
                                </xsl:otherwise>
                            </xsl:choose>
                        </table>
                    </TD>
                </TR>
            </xsl:if>


<!--
**********************************************************************************************************************************
    This section handles the Partition data of Exchange and Exchange GAL MA only.
**********************************************************************************************************************************
-->
            <xsl:if test = "$category = 'Exchange' or $category = 'Exchange GAL'">
                <TR>
                    <TD class="tdLeftSection"><b>Sites Configuration </b></TD>
                    <TD align='left'><a NAME='#Exchange2'></a>
                        <table border='1' cellspacing='0' cellpadding='0' bordercolordark='#ffffff' align='left'  class="tableClass4">
                            <xsl:choose>

                                <!-- Proceed when //ma-data/ma-partition-data is not null.-->

                                <xsl:when test="//ma-data/ma-partition-data!=''">

                                    <!-- Iterate each partition.-->
                                    <xsl:for-each select="//ma-data/ma-partition-data/partition">
                                        <xsl:if test="selected > 0">
                                            <tr>
                                                <td><b>Site Name: </b> <xsl:value-of select="name"/></td>
                                            </tr>

                                            <tr>
                                                <td>
                                                <table>
                                                <tr>
                                                <td>
                                                    <table border='1' cellspacing='0' cellpadding='0' bordercolordark='#ffffff' align='left' class="tableClass4">
                                                        <tr>
                                                            <td><b> Preferred Servers: </b></td>
                                                            <xsl:choose>
                                                                <xsl:when test="custom-data/exma-partition-data/preferred-servers/server">
                                                                    <xsl:for-each select="custom-data/exma-partition-data/preferred-servers/server">
                                                                            <td><li><xsl:value-of select="."/></li></td>
                                                                    </xsl:for-each>
                                                                </xsl:when>

                                                                <xsl:otherwise><td> None </td></xsl:otherwise>
                                                            </xsl:choose>
                                                        </tr>

                                                        <tr>
                                                            <td><b> Last server used :</b></td>
                                                            <td>
                                                                <xsl:value-of select="custom-data/exma-partition-data/last-server"/>                                                                
                                                            </td>
                                                        </tr>

                                                        <tr>
                                                            <td><b>Only use preferred servers</b></td>

                                                            <xsl:choose>
                                                                <xsl:when test="custom-data/exma-partition-data/server-failover='1'">
                                                                    <td><xsl:text> No </xsl:text></td>
                                                                </xsl:when>
        
                                                                <xsl:when test="custom-data/exma-partition-data/server-failover='0'">
                                                                    <td><xsl:text> Yes </xsl:text></td>
                                                                </xsl:when>

                                                                <xsl:otherwise><td> None </td></xsl:otherwise>
                                                            </xsl:choose>
                                                        </tr>

                                                        <tr>
                                                            <td><b>Use SSL</b></td>
                                                            <xsl:choose>
                                                                <xsl:when test="custom-data/exma-partition-data/use-ssl='1'">
                                                                    <td><xsl:text> Yes </xsl:text></td>
                                                                </xsl:when>

                                                                <xsl:otherwise>
                                                                    <td><xsl:text> No </xsl:text></td>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </tr>
                                                </table>
                                                </td>
                                                </tr>
                                                <tr>
                                                <td>
                                                <table>
                                                        <!-- Proceed if inclusion of inclusions is not null.-->
                                                        <xsl:if test="//ma-data/ma-partition-data/partition/filter/containers/exclusions/exclusion!='' or //ma-data/ma-partition-data/partition/filter/containers/inclusions/inclusion!=' '">
                                                            <tr>
                                                                <td>
                                                                    <table cellspacing='0' cellpadding='0' border='1' bordercolordark='#ffffff' width='100%'>
                                                                        <tr>
                                                                            <td colspan='2'><b> Containers to synchronize </b></td>
                                                                        </tr>
                                                                                
                                                                        <tr>
                                                                            <td><b> Include </b></td>
                                                                            <td><b> Container </b></td>
                                                                        </tr>

                                                                        <xsl:for-each select="filter/containers/exclusions/exclusion">
                                                                            <tr>
                                                                                <td> Exclude </td>
                                                                                <td><xsl:value-of select="."/></td>
                                                                            </tr>
                                                                        </xsl:for-each>

                                                                        <xsl:for-each select="filter/containers/inclusions/inclusion">
                                                                            <tr>
                                                                                <td> Include </td>
                                                                                <td><xsl:value-of select="."/></td>
                                                                            </tr>
                                                                        </xsl:for-each>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </xsl:if>
                                                        <!-- End of //ma-data/ma-partition-data/partition/filter/containers/exclusions/exclusion!='' or //ma-data/ma-partition-data/partition/filter/containers/inclusions/inclusion if.-->

                                                    </table>
                                                    </td>
                                                    </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </xsl:if>
                                        <!-- End of "selected > 0 if.-->

                                    </xsl:for-each>
                                    <!-- End of //ma-data/ma-partition-data/partition for-each.-->

                                </xsl:when>
                                <!-- End of //ma-data/ma-partition-data when.-->

                                <xsl:otherwise>
                                <tr>
                                    <td>
                                        <xsl:text> None </xsl:text>
                                    </td>
                                </tr>
                                </xsl:otherwise>
                            </xsl:choose>
                        </table>
                    </TD>
                </TR>
            </xsl:if>

<!--
#################################################################################################################################
        This section handles the Naming Context of Type iPlanet MA only.
#################################################################################################################################
-->
            <xsl:if test="$category='iPlanet'">
                <TR>
                    <TD class="tdLeftSection"><b> Naming Context Configuration </b></TD>
                    <TD align='left'><a NAME='#iPlanet2'></a>

                        <table align='left'>
                            <xsl:for-each select="//ma-data/ma-partition-data/partition">
                            <xsl:if test="selected > 0">
                            <tr> 
                                <td><b> Naming Context </b> <xsl:value-of select="name"/> </td> 
                            </tr>

                            <tr> 
                                <td><b> Containers to synchronize </b></td>
                            </tr>
                            <tr>
                                <td>
                                    <table cellpadding='0' cellspacing='0' border='1' bordercolordark='#ffffff' >
                                        <tr> 
                                            <td> <b>Include </b></td>
                                            <td><b> Container </b></td>
                                        </tr>

                                        <xsl:for-each select="filter/containers/inclusions/inclusion/.">
                                            <tr> 
                                                <td> Include</td>
                                                <td> <xsl:value-of select="."/> </td>
                                            </tr>
                                        </xsl:for-each>

                                        <xsl:for-each select="filter/containers/exclusions/exclusion/.">
                                            <tr> 
                                                <td> Exclude</td>
                                                <td> <xsl:value-of select="."/> </td>
                                            </tr>
                                        </xsl:for-each>
                                    </table>
                                </td>
                            </tr>
                           </xsl:if>
                           </xsl:for-each>
                           <!-- End of select="//ma-data/ma-partition-data/partition" for-each.-->

                            <xsl:choose>
                                <xsl:when test="//ma-data/private-configuration/ipma-configuration/anti-trawling/trawling-filter!=''">
                                    <tr>
                                        <td><b> Search Ranges: </b></td>
                                    </tr>

                                    <xsl:for-each select="//ma-data/private-configuration/ipma-configuration/anti-trawling/trawling-filter">
                                        <tr>
                                            <td><u> For Attribute '<xsl:value-of select="@attribute"/>' values are </u></td>
                                        </tr>

                                        <tr>
                                            <td>
                                                <table>
                                                <tr>
                                                    <td>
                                                    <ol>
                                                        <xsl:for-each select="value-cut-point">
                                                        <li><xsl:value-of select="."/></li>
                                                        </xsl:for-each>
                                                    </ol>
                                                    </td>
                                                </tr>
                                                </table>
                                            </td>
                                        </tr>

                                    </xsl:for-each>
                                </xsl:when>

                                <xsl:otherwise>
                                    <tr>
                                        <td><b> Search Ranges: </b> None </td>
                                    </tr>
                                </xsl:otherwise>
                            </xsl:choose>


                            <tr> 
                                <td><b> Server Type:</b>
                                <xsl:choose>
                                <xsl:when test="//ma-data/private-configuration/ipma-configuration/ui-data/server-type!=''">
                                    <xsl:value-of select="//ma-data/private-configuration/ipma-configuration/ui-data/server-type"/>
                                </xsl:when>
                                <xsl:otherwise> None </xsl:otherwise>
                                </xsl:choose>
                                </td>
                            </tr>

                            <tr> 
                                <td><b> Change Log enabled: </b>
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/ipma-configuration/ui-data/supportchangelog='1'">
                                            <xsl:text> Yes </xsl:text>
                                        </xsl:when>

                                        <xsl:when test="//ma-data/private-configuration/ipma-configuration/ui-data/supportchangelog='0'">
                                            <xsl:text> No </xsl:text>
                                        </xsl:when>

                                        <xsl:otherwise><xsl:text> None </xsl:text></xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </table>
                    </TD>
                </TR>
            </xsl:if>

<!--
#################################################################################################################################
        This section handles the Naming Context of Type IBM DS MA only.
#################################################################################################################################
-->
            <xsl:if test="$category='IBM DS'">
                <TR>
                    <TD class="tdLeftSection"><b> Naming Context Configuration </b></TD>
                    <TD align='left'><a NAME='#IBMDS2'></a>

                        <table align='left'>
                            <xsl:for-each select="//ma-data/ma-partition-data/partition">
                            <xsl:if test="selected > 0">
                            <tr> 
                                <td><b> Naming Context </b> <xsl:value-of select="name"/> </td> 
                            </tr>

                            <tr> 
                                <td><b> Containers to synchronize </b></td>
                            </tr>
                            <tr>
                                <td>
                                    <table cellpadding='0' cellspacing='0' border='1' bordercolordark='#ffffff' >
                                        <tr> 
                                            <td> <b>Include </b></td>
                                            <td><b> Container </b></td>
                                        </tr>

                                        <xsl:for-each select="filter/containers/inclusions/inclusion/.">
                                            <tr> 
                                                <td> Include</td>
                                                <td> <xsl:value-of select="."/> </td>
                                            </tr>
                                        </xsl:for-each>

                                        <xsl:for-each select="filter/containers/exclusions/exclusion/.">
                                            <tr> 
                                                <td> Exclude</td>
                                                <td> <xsl:value-of select="."/> </td>
                                            </tr>
                                        </xsl:for-each>
                                    </table>
                                </td>
                            </tr>
                           </xsl:if>
                           </xsl:for-each>
                           <!-- End of select="//ma-data/ma-partition-data/partition" for-each.-->
                        </table>
                    </TD>
                </TR>
            </xsl:if>


<!--
#################################################################################################################################
        This section handles the Selected Containers of Novell eDirectory MA only.
#################################################################################################################################
-->
            <xsl:if test="$category='eDirectory'">
                <TR>
                    <td class="tdLeftSection"><b>Selected Containers </b></td>
                    <td align='left'><a NAME='#eDirectory2'></a>
                        <table cellpadding='0' cellspacing='0' border='1' bordercolordark='#ffffff' align='left' class="tableClass4">
                            <tr class="tdLeftSection"> 
                                <td><b>Containers to synchronize</b></td>
                            </tr>

                            <tr> 
                                <td>

                                    <table border='1' bordercolordark='#ffffff' cellspacing='0' cellpadding='0'>
                                        <tr >
                                            <td><b>Include </b></td>
                                            <td><b>Container </b></td>
                                        </tr>

                                        <xsl:for-each select="//ma-data/ma-partition-data/partition/filter/containers/exclusions/exclusion">
                                            <tr > 
                                                <td> Exclude </td>
                                                <td><xsl:value-of select="."/> </td>
                                            </tr>
                                        </xsl:for-each>

                                        <xsl:for-each select="//ma-data/ma-partition-data/partition/filter/containers/inclusions/inclusion">
                                            <tr> 
                                                <td> Include </td>
                                                <td><xsl:value-of select="."/></td>
                                            </tr>
                                        </xsl:for-each>
                                    </table>

                                </td>
                            </tr>
                        </table>
                    </td>
                </TR>
            </xsl:if>

<!--
    #################################################################################################################################
        This section handles the Organizational Units of Lotus Notes MA only.
    #################################################################################################################################
-->
            <xsl:if test="$category='Notes'">
                <TR>
                    <td class="tdLeftSection"><b>Organizational Units Configured</b></td>
                    <td align='left'><a NAME='#NOTES2'></a>
                        <table >
                            <tr>
                                <td>
                                    <table cellpadding='0' cellspacing='0' border='1' bordercolordark='#ffffff' >
                                        <tr> 
                                            <td class="thAttributeFlow1"> <b> Address Book </b></td>
                                            <td class="thAttributeFlow1"><b> Organizational Unit </b></td>
                                            <td class="thAttributeFlow1"><b> Certifier Path </b></td>
                                        </tr>

                                        <xsl:for-each select="//ma-data/private-configuration/lnma-configuration/ou-list/item">
                                            <tr>
                                                <td><xsl:value-of select="nab"/></td>
                                                <td><xsl:value-of select="ou"/></td>
                                                <td><xsl:value-of select="certifier-path"/></td>
                                            </tr>
                                        </xsl:for-each>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </TR>
            </xsl:if>

<!--
    #################################################################################################################################
    This section handles the GAL Configuration of the AD GAL MA only.
    #################################################################################################################################
-->
            <xsl:if test="//ma-data/private-configuration/adma-configuration/ui-data/galma/.">
                <TR>
                    <TD class="tdLeftSection"><b> GAL Configuration </b></TD>
                    <TD align='left'><a NAME='#ADGAL1'></a>
                        <table cellpadding='0' cellspacing='0' border='1' bordercolordark="#ffffff" align='left' class="tableClass4">
                            <tr>
                                <td colspan='2'><b>GAL Container Configuration </b></td>
                            </tr>

                            <tr>
                                <td><b>Destination container for contacts synchronized with this forest:</b></td>
                                <td><xsl:value-of select="//ma-data/private-configuration/adma-configuration/ui-data/galma/target-ou"/></td>
                            </tr>

                            <tr>
                                <td><b>Source containers with authoritative contacts in the forest:</b></td>
                                <td>
                                    <table class="tableClass5">
                                        <td>
                                        <xsl:for-each select="//ma-data/private-configuration/adma-configuration/ui-data/galma/source-contact-ous/ou">
                                                <li><xsl:value-of select='.'/></li>
                                        </xsl:for-each>
                                        </td>
                                    </table>
                                </td>
                            </tr>

                            <tr><td colspan='2'><b>Exchange Configuration</b></td></tr>
                            <tr>
                                <td><b>SMTP mail suffix(s)for mailbox and mail objects in this forest:</b></td>
                                <td>
                                    <table class="tableClass5" >
                                        <xsl:for-each select="//ma-data/private-configuration/adma-configuration/ui-data/galma/smtp-mail-domains/domain">
                                            <xsl:if test="position()=1">
                                                <tr>
                                                    <td><b>For Users and Groups:</b></td>
                                                    <td><xsl:value-of select="."/></td>
                                                </tr>
                                            </xsl:if>

                                            <xsl:if test="position()&gt;1">
                                                <tr>
                                                    <td>
                                                        <xsl:if test="position()&lt;3">
                                                            <b>For Contacts:</b>
                                                        </xsl:if>
                                                    </td>
                                                     <td>
                                                         <li><xsl:value-of select="."/></li>
                                                     </td>
                                                </tr>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </table>
                                </td>
                            </tr>

                            <tr>
                                <td><b>Route mail</b></td>
                                <xsl:choose>
                                    <xsl:when test="//ma-data/private-configuration/adma-configuration/ui-data/galma/mail-routing!='false'">
                                        <td><xsl:text> Yes </xsl:text></td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <td><xsl:text> No </xsl:text></td>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </tr>

                            <tr>
                                <td ><b>Contact object type associated with this forest</b></td>
                                <td>
                                    <xsl:value-of select="//ma-data/private-configuration/adma-configuration/ui-data/galma/contact-type"/> 
                                </td>
                            </tr>

                            <tr>
                                <td><b>Administrator Group for Exchange interoperability with Exchange 5.5 and Active Directory Connector environments</b></td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="//ma-data/private-configuration/adma-configuration/ui-data/galma/admin-group!=''">
                                            <xsl:value-of select="//ma-data/private-configuration/adma-configuration/ui-data/galma/admin-group"/>
                                        </xsl:when>

                                        <xsl:otherwise>
                                            <xsl:text> None </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </table>
                    </TD>
                </TR>
            </xsl:if>

<!--
    #################################################################################################################################
        This section handles the Selected Objects of an MA.
        For AD, AD GAL, Sun iPlanet, Novell eDirectory, Exchange, Exchange GAL, Lotus Notes and Windows NT4 only.
    #################################################################################################################################
-->
            <xsl:if test="$category='AD' or $category='AD GAL' or $category='ADAM' or $category='Notes' or $category='iPlanet' or $category='IBM DS' or $category='Exchange' or $category='Exchange GAL' or $category='eDirectory' or $category='NT' ">
                <TR>
                    <td class="tdLeftSection"><b>Selected Object Types  </b></td>
                    <td align='left' class="tdClass5"><a NAME='#SelObjects'></a>
                        <xsl:if test="//ma-data/ma-partition-data/partition">
                            <xsl:for-each select="//ma-data/ma-partition-data/partition">
                                <xsl:if test='position()=1'>

                                    <!-- Iterate each object-class in the object-classes.-->

                                    <xsl:for-each select="filter/object-classes/object-class">
                                        <li><xsl:value-of select="."/></li>
                                    </xsl:for-each>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                    </td>
                </TR>
            </xsl:if>



<!--
    #################################################################################################################################
        This section handles the Column data of SQL Server and Oracle MA only.
    #################################################################################################################################
-->
            <xsl:if test="//ma-data/private-configuration/oledbma-configuration/mms-info">
                <TR>
                    <TD class="tdLeftSection"><b>Columns Configured </b></TD>
                    <TD align='left'><a NAME='#ColsConf'></a>
                    <table>
                    <tr>
                    <td>
                        <table cellpadding='0' cellspacing='0' border='1' bordercolordark="#ffffff" align='left' class="tableClass4">
                            <tr>
                                <th class="thAttributeFlow1"><b>Name</b></th>
                                <th class="thAttributeFlow1"><b>Database type</b></th>
                                <th class="thAttributeFlow1"><b>Length</b></th>
                                <th class="thAttributeFlow1"><b>Nullable</b></th>
                                <th class="thAttributeFlow1"><b>Type</b></th>
                            </tr>

                            <!-- Iterate each column of column info.-->

                        <xsl:for-each select="//ma-data/private-configuration/oledbma-configuration/mms-info/column-info/column">
                            <tr>
                                <td ><xsl:value-of select="name"/></td>
                                <td ><xsl:value-of select="data-type"/></td>
                                <td align='right'><xsl:value-of select="length"/></td>
                                <td align='center'>
                                    <xsl:choose>
                                        <xsl:when test="isnullable=1">
                                            <xsl:text> Yes </xsl:text>
                                        </xsl:when>

                                        <xsl:otherwise>
                                            <xsl:text> No </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>

                                <td>
                                    <xsl:choose>
                                        <xsl:when test="mms-type/@dn='1'">
                                            <xsl:text> Reference DN </xsl:text>
                                        </xsl:when>

                                        <xsl:otherwise>
                                            <xsl:value-of select="mms-type"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </xsl:for-each>
                            <!-- End of select="//ma-data/private-configuration/oledbma-configuration/mms-info/column-info/column for-each.-->

                        </table>
                        </td>
                        </tr>
                        <tr>
                        <td>
                        <table  cellpadding='0' cellspacing='0' border='1' bordercolordark="#ffffff" align='left' class="tableClass4">
                            <tr>
                                <td colspan='2'><u><b>Special Attributes</b></u></td>
                            </tr>

                            <tr>
                                <td><b> Anchor: </b></td>
                                <td>
                                    <!-- Iterate each anchor attribute.-->
                                    <xsl:for-each select="//ma-data/private-configuration/oledbma-configuration/mms-info/anchor/attribute">
                                        <xsl:if test="position() &gt; 1">
                                                <xsl:text> + </xsl:text>
                                        </xsl:if>
                                        <xsl:value-of select="."/>
                                    </xsl:for-each>
                                </td>
                            </tr>
                            <tr>
                                <td><b>Object Type:</b></td>
                                <td><xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/mms-info/object-type"/></td>
                            </tr>
                            <!-- Proceed if the delta-info is not null.-->
                            <xsl:if test="//ma-data/private-configuration/oledbma-configuration/mms-info/delta-info!=''">
                            <tr>
                                <td colspan='2'><b><u>Delta Configuration</u></b></td>
                            </tr>
                            <tr>
                                <td colspan='2'>
                                    <table cellpadding='0' cellspacing='0' border='1' bordercolordark="#ffffff" align='center' class="tableClass4">
                                        <tr>
                                            <td><b> Change type attribute: </b></td>
                                            <td>
                                                <xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/mms-info/delta-info/change-column"/>
                                            </td>
                                        </tr>

                                        <tr>
                                            <td><b> Modify:</b></td>
                                            <td><xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/mms-info/delta-info/update"/></td>
                                        </tr>

                                        <tr>
                                            <td><b> Add:</b></td>
                                            <td><xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/mms-info/delta-info/add"/></td>
                                        </tr>

                                        <tr>
                                            <td><b> Delete:</b></td>
                                            <td><xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/mms-info/delta-info/delete"/></td>
                                        </tr>

                                        <tr>
                                            <td><b> Attribute modify:</b></td>
                                            <td><xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/mms-info/delta-info/update-attribute"/></td>
                                        </tr>
                                        <tr>
                                            <td><b> Attribute Level Synchronization Column:</b></td>
                                            <td><xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/mms-info/delta-info/attribute-column"/></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            </xsl:if>
                            <!-- End of //ma-data/private-configuration/oledbma-configuration/mms-info/delta-info if.-->

                            <!-- Proceed if the multivalued-info is not null.-->
                            <xsl:if test="//ma-data/private-configuration/oledbma-configuration/mms-info/multivalued-info!=''">
                            <tr>
                                <td colspan='2'><b><u>Multivalued Configuration</u></b></td>
                            </tr>
                            <tr>
                                <td colspan='2'>
                                    <table cellpadding='0' cellspacing='0' border='1' bordercolordark="#ffffff" align='center' class="tableClass4">
                                        <tr>
                                            <td><b> Attribute name column:</b></td>
                                            <td><xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/mms-info/multivalued-info/attribute-column"/></td>
                                        </tr>
                                        <tr>
                                            <td><b> String attribute column: </b></td>
                                            <td>
                                                <xsl:choose>
                                                    <xsl:when test="//ma-data/private-configuration/oledbma-configuration/mms-info/multivalued-info/string-column!=''">
                                                        <xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/mms-info/multivalued-info/string-column"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>-</xsl:otherwise>
                                                </xsl:choose>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td><b> Large String attribute column: </b></td>
                                            <td>
                                                <xsl:choose>
                                                    <xsl:when test="//ma-data/private-configuration/oledbma-configuration/mms-info/multivalued-info/long-string-column!=''">
                                                        <xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/mms-info/multivalued-info/long-string-column"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>-</xsl:otherwise>
                                                </xsl:choose>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td><b> Binary attribute column: </b></td>
                                            <td>
                                                <xsl:choose>
                                                    <xsl:when test="//ma-data/private-configuration/oledbma-configuration/mms-info/multivalued-info/binary-column!=''">
                                                        <xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/mms-info/multivalued-info/binary-column"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>-</xsl:otherwise>
                                                </xsl:choose>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td><b> Large Binary attribute column: </b></td>
                                            <td>
                                                <xsl:choose>
                                                    <xsl:when test="//ma-data/private-configuration/oledbma-configuration/mms-info/multivalued-info/long-binary-column!=''">
                                                        <xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/mms-info/multivalued-info/long-binary-column"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>-</xsl:otherwise>
                                                </xsl:choose>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td><b> Numeric attribute column: </b></td>
                                            <td>
                                                <xsl:choose>
                                                    <xsl:when test="//ma-data/private-configuration/oledbma-configuration/mms-info/multivalued-info/numeric-column!=''">
                                                        <xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/mms-info/multivalued-info/numeric-column"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>-</xsl:otherwise>
                                                </xsl:choose>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan='2'>
                                                <table cellpadding='0' cellspacing='0' border='1' bordercolordark="#ffffff" align='left' class="tableClass4">
                                                    <tr>
                                                        <th class="thAttributeFlow1"><b>Attribute name</b></th>
                                                        <th class="thAttributeFlow1"><b>Attribute type</b></th>
                                                    </tr>
                                        <xsl:for-each select="//ma-data/private-configuration/oledbma-configuration/mms-info/multivalued-info/multivalued-columns/column">
                                            <tr>
                                                <td><xsl:value-of select="name"/></td>
                                                <td><xsl:value-of select="mms-type"/></td>
                                            </tr>
                                        </xsl:for-each>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            </xsl:if>
                            <!-- End of //ma-data/private-configuration/oledbma-configuration/mms-info/multivalued-info if.-->

                            <!-- Proceed if the object-type is not null.-->
                            <tr>
                                <td colspan='2'><b><u>Object Type Configuration</u></b></td>
                            </tr>
                            <tr>
                                <xsl:choose>
                                    <xsl:when test="//ma-data/private-configuration/oledbma-configuration/mms-info/object-type-info/object-type-column!=''">
                                        <td>Column:</td>
                                        <td><xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/mms-info/object-type-info/object-type-column"/></td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <td>Fixed</td>
                                        <td><xsl:value-of select="//ma-data/private-configuration/oledbma-configuration/mms-info/object-type"/></td>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </tr>
                        </table>
                        </td>
                        </tr>
                        </table>
                    </TD>
                </TR>
            </xsl:if>

<!--
    #################################################################################################################################
    This section handles the Selected Attributes information 
    for AD, AD GAL, ADAM, Exchange, Exchange GAL, iPlanet, eDirectory and Windows NT only.
    #################################################################################################################################
-->
            <xsl:if test="$category='AD' or $category='AD GAL' or $category='ADAM'or $category='Exchange' or $category='Exchange GAL' or $category='NT' or $category='iPlanet' or $category='IBM DS' or $category='eDirectory'">
               <TR> 
                    <TD align='left' class="tdLeftSection"><b>Selected Attributes </b></TD>

                        <xsl:choose>

                            <!-- Proceed when attribute-inclusion is not null.-->

                            <xsl:when test="//ma-data/attribute-inclusion!=''">

                                <td class="tdClass2"> <a NAME='#Attri1'></a>
                                        <b> Attribute(s) </b> <br></br> <br></br>
                                    <!-- Iterate each attribute in attribute-inclusion.-->
                                    <xsl:for-each select="//ma-data/attribute-inclusion/attribute">
                                        <li><xsl:value-of select="."/></li>
                                    </xsl:for-each>
                                </td>
                            </xsl:when>

                            <xsl:otherwise><td><xsl:text>No attributes selected</xsl:text></td></xsl:otherwise>
                        </xsl:choose>
                </TR>
            </xsl:if>

<!--
    #################################################################################################################################
    This section handles the Selected Attributes Information 
    for Lotus Notes.
    #################################################################################################################################
-->
            <!--Display this section for Lotus notes.-->
            <xsl:if test="$category='Notes'">
                <TR>
                    <TD class="tdLeftSection"><b>Selected Attributes </b></TD>
                    <TD align='left'><a NAME='#Notes3'></a>
                    <table cellpadding='0' cellspacing='0' border='1' bordercolordark="#ffffff" width='100%' align='left' class="tableClass4">
                            <tr>
                                <td><b> Attribute </b></td>
                                <td><b> User Defined </b></td>
                            </tr>
                            <xsl:for-each select="//ma-data/attribute-inclusion/attribute">
                            <xsl:variable name='m_attribute' select="."/>
                            <tr>
                                    <td>
                                            <xsl:value-of select="$m_attribute"/>
                                    </td>
                                    <td>
                                        <xsl:variable name='m_attribute.available' select="//ma-data/private-configuration/lnma-configuration/ui-data/extended-attributes[attribute/@ name=$m_attribute]"/>
                                            <xsl:choose>
                                                <xsl:when test="$m_attribute.available!=''">
                                                    Extended
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    Default
                                                </xsl:otherwise>
                                            </xsl:choose>
                                    </td>
                            </tr>
                            </xsl:for-each>
                        </table>
                    </TD>
                </TR>
            </xsl:if>

<!-- 
    #################################################################################################################################
    This section handles the Selected Anchor Attributes of iPlanet MA only.
    #################################################################################################################################
-->
<!--Display this section for iPlanet.-->
<xsl:if test="$category='iPlanet' or $category='IBM DS'">
<xsl:if test="//ma-data/private-configuration/ipma-configuration/anchor-attributes/anchor-attribute/.">
<TR>
    <TD class="tdLeftSection"><b> Selected Anchor Attributes </b></TD>
    <TD align='left'><a NAME='#SelectedAnchorAttributes'></a>
    <Table cellpadding='0' cellspacing='0' border='1' bordercolordark="#ffffff" width='100%' align='left' class="tableClass4">
        <th class="thAttributeFlow1"> Object Type </th>
        <th class="thAttributeFlow1"> Anchor Attribute </th>
        <xsl:for-each select="//ma-data/private-configuration/ipma-configuration/anchor-attributes/anchor-attribute">
        <tr>
            <td><xsl:value-of select="object-type"/></td>
            <td><xsl:value-of select="name"/></td>
        </tr>
        </xsl:for-each>
    </Table>
    </TD>
</TR>
</xsl:if>
</xsl:if>
<!-- 
    #################################################################################################################################
    This section handles the Connector Filter Configuration of MA.
    #################################################################################################################################
-->

<TR>
    <TD class="tdLeftSection"><b> Connector Filters </b></TD>
        <TD align='left'><a NAME='#connectorfilters'></a>
        <xsl:choose>

        <!-- Proceed when //ma-data/stay-disconnector/filter-set/. is not null.-->

        <xsl:when test="//ma-data/stay-disconnector/filter-set/.!=' '">
            <table cellpadding='0' cellspacing='0' border='1' bordercolordark="#ffffff" width='100%' align='left' class="tableClass4">
                <tr>
                    <th class="thAttributeFlow1">Data Source Object Type</th>
                    <th class="thAttributeFlow1">Filter Type</th>
                    <th class="thAttributeFlow1">Filter </th>
                </tr>

                <!-- Iterate each select="//ma-data/stay-disconnector/filter-set/.".-->

                <xsl:for-each select="//ma-data/stay-disconnector/filter-set/.">
                    <tr>
                        <td class="tdClass3">
                            <xsl:value-of select="@cd-object-type"/>
                        </td>

                        <td class="tdClass3">
                            <xsl:value-of select="@type"/>
                        </td>

                        <td>
                            <xsl:choose>

                            <!-- Proceed when  filter-alternative is present.-->

                                <xsl:when test="filter-alternative">

                                    <!-- Iterate each select="filter-alternative".-->

                                    <xsl:for-each select="filter-alternative">
                                        <table align='center' cellpadding='0' cellspacing='0' border='1' bordercolordark="#ffffff" class="tableClass5" >
                                            <tr>
                                                <th class="thAttributeFlow1">Attribute</th>
                                                <th class="thAttributeFlow1">Operator</th>
                                                <th class="thAttributeFlow1">Value</th>
                                            </tr>

                                            <!-- Iterate each condition.-->

                                            <xsl:for-each select="condition">
                                                <tr>
                                                    <td class="tdClass3">
                                                        <xsl:choose>
                                                            <xsl:when test="@cd-attribute">
                                                                <xsl:value-of select="@cd-attribute"/>
                                                            </xsl:when>

                                                            <xsl:otherwise>
                                                                <xsl:text> Not Applicable.</xsl:text>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </td>

                                                    <td class="tdClass3">
                                                        <xsl:choose>
                                                            <xsl:when test="@operator">
                                                                <xsl:value-of select="@operator"/>
                                                            </xsl:when>

                                                            <xsl:otherwise>
                                                                <xsl:text> Not Applicable.</xsl:text>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </td>

                                                    <td class="tdClass3">
                                                        <xsl:choose>
                                                            <xsl:when test="value=''">
                                                                -
                                                            </xsl:when>

                                                            <xsl:when test="value">
                                                                <xsl:value-of select="value"/>
                                                            </xsl:when>

                                                            <xsl:otherwise>
                                                                <xsl:text> Not Applicable.</xsl:text>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </td>
                                                </tr>
                                            </xsl:for-each>
                                            <!-- End of select="condition" for-each.-->

                                        </table>
                                    </xsl:for-each>
                                    <!-- End of select="filter-alternative" for-each.-->

                                </xsl:when>
                                <!-- End of test="filter-alternative" when.-->

                                <xsl:otherwise>
                                    <xsl:text> Rules Extension </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:for-each>
                <!--end of select="//ma-data/stay-disconnector/filter-set/." for-each.-->

            </table>
        </xsl:when>
        
        <xsl:otherwise>
            <xsl:text> None </xsl:text>
        </xsl:otherwise>
        </xsl:choose>
    </TD>
</TR>

<!-- 
    #################################################################################################################################
    This section handles the Join Rules of the MA.
    #################################################################################################################################
-->

<TR>
    <TD class="tdLeftSection"><b>Join and Projection Rules </b></TD>
    <TD align='left'><a NAME='#Joinandprojection'></a>
        <br></br>
            <TABLE align='left' class="tableClass4">
            <TR>
            <TD>
            <table cellpadding='0' cellspacing='0' width='100%' align='left' class="tableClass4">
                <tr>
                    <td colspan='3'><b>Join Rules: </b></td>
                </tr>
                <tr>
                    <td>
                        <xsl:choose>

                        <!-- Proceed when the //ma-data/join/join-profile is not null.-->

                        <xsl:when test="//ma-data/join/join-profile!=''">
                        <table cellpadding='0' cellspacing='0' border='1' bordercolordark="#ffffff" width='100%' align='center'>

                        <tr>
                            <th class="thAttributeFlow1" align='center' >Data Source Object</th>
                            <th class="thAttributeFlow1" align='center' >Mapping</th>
                            <th class="thAttributeFlow1" align='center' >Metaverse Object</th>
                            <th class="thAttributeFlow1" align='center' >Join Resolution Extension</th>
                        </tr>

                                <!-- Iterate each join-profile.-->

                                <xsl:for-each select="//ma-data/join/join-profile">

                                    <!-- Instantiate a variable cdobjecttype with value of @ cd-object-type for later use.-->

                                    <xsl:variable name='cdobjecttype' select='@ cd-object-type'/>

                                    <!-- Iterate each join criterion.-->

                                    <xsl:for-each select="join-criterion">

                                    <!-- Instantiate a variable res with value of resolution/script-context for later use.-->

                                    <xsl:variable name='res' select="resolution/script-context" />
                                    <tr>
                                        <td class="tdClass3">
                                            <b><xsl:value-of select="$cdobjecttype"/></b>
                                        </td>
                                        <td align='center' class="tdClass2"> - </td>
                                        <td>
                                            <b>
                                                <xsl:choose>
                                                <xsl:when test="search/@ mv-object-type!=''">
                                                <xsl:value-of select="search/@ mv-object-type"/>
                                                </xsl:when>
                                                <xsl:when test="not(@mv-object-type)">
                                                    <b>
                                                        <xsl:text>  ANY </xsl:text>
                                                    </b>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                <b></b>
                                                </xsl:otherwise>
                                                </xsl:choose>
                                            </b>
                                        </td>
                                        <td align='center' class="tdClass3"> - </td>
                                    </tr>

                                    <xsl:for-each select="search/attribute-mapping">
                                    <tr>
                                        <xsl:if test="direct-mapping">
                                        <td class="tdClass3"><xsl:value-of select="direct-mapping/src-attribute"/></td>
                                        <td class="tdClass3">Direct</td>
                                        <td class="tdClass3"><xsl:value-of select="@mv-attribute"/></td>
                                        </xsl:if>

                                        <xsl:if test="scripted-mapping">
                                        <td class="tdClass3">
                                            <xsl:for-each select="scripted-mapping/src-attribute">
                                                    <xsl:if test="position() &gt;1">                                                        
                                                        <br />
                                                    </xsl:if>
                                                    <xsl:value-of select="."/>
                                            </xsl:for-each>
                                        </td>
                                        <td class="tdClass3">Rules Extension - <xsl:value-of select="scripted-mapping/script-context"/></td>
                                        <td class="tdClass3"><xsl:value-of select="@mv-attribute"/></td>
                                        </xsl:if>

                                        <td class="tdClass3">
                                            <xsl:choose>
                                                <xsl:when test="$res!=''">
                                                <xsl:value-of select="$res"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:text> None </xsl:text>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </td>
                                    </tr>
                                    </xsl:for-each>
                                    <!-- End of select="search/attribute-mapping" for-each.-->

                                    </xsl:for-each>
                                    <!--end of join-criterion for-each.-->

                                </xsl:for-each>
                                <!-- End of //ma-data/join/join-profile for-each.-->

                            </table>
                            </xsl:when>
                            <!-- End of test="//ma-data/join/join-profile!='' when.-->

                            <xsl:otherwise>
                                    <xsl:text> None </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>

                   </td>
                </tr>
            </table>

            <br></br>
</TD>           
</TR>
<TR>
<TD>
<!--
    #################################################################################################################################
    This section handles the Projection Rules information of MA.
    #################################################################################################################################
-->
            <table width='100%'  cellspacing='0' cellpadding='0' bordercolordark='#ffffff' align='left' class='tableClass4'>
            <tr>
                <td><b>Projection Rules:</b></td>
            </tr>

            <tr>
                <TD>
                    <xsl:choose>

                        <!-- Proceed only if the any sub nodes are present in the class-mapping.-->

                        <xsl:when test="//ma-data/projection/class-mapping">
                            <table cellpadding='0' cellspacing='0' border='1' bordercolordark="#ffffff" width='100%'>

                                <!-- Display the header of the projection.-->

                                <xsl:if test="//ma-data/projection/class-mapping">
                                <tr>
                                <th class="thAttributeFlow1">Data Source Object</th>
                                <th class="thAttributeFlow1">Mapping</th>
                                <th class="thAttributeFlow1">Metaverse Object</th>
                                </tr>
                                </xsl:if>

                                <!-- Iterate each class-mapping in the projection.-->

                                <xsl:for-each select="//ma-data/projection/class-mapping">
                                <tr>
                                    <td class="tdClass3"><xsl:value-of select="@ cd-object-type"/></td>
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="@type='scripted'">
                                            <xsl:text> Rules Extension </xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                            <xsl:text> Declared </xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>

                                    <!-- Proceed if the type of class-mapping is scripted.-->
                                    <xsl:if test="@type='scripted'">
                                     <td align='center'> ANY </td>
                                    </xsl:if>

                                    <!-- Proceed if the type of class-mapping is declared.-->

                                    <xsl:if test="@type='declared'">
                                     <td class="tdClass3"><xsl:value-of select="mv-object-type"/> </td>
                                    </xsl:if>

                                </tr>
                                </xsl:for-each>
                                <!-- End of //ma-data/projection/class-mapping for-each.-->

                            </table>

                        </xsl:when>
                        <!-- End of test="//ma-data/projection/class-mapping" when.-->

                        <!-- If the any sub nodes are not present in the projection then display none.-->

                        <xsl:otherwise>
                            <xsl:text> None </xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </TD>
            </tr>
            </table>
</TD>
</TR>
</TABLE>
    </TD>
</TR>


<!-- 
    #################################################################################################################################
    This section handles the Attribute Flow rules of the MA.
    #################################################################################################################################
-->

<TR>
    <TD class="tdLeftSection"><b>Attribute Flow</b></TD>
    <TD align='left'><a NAME='#AttributeFlow'></a>

<!-- 
    *********************************************************************************************************************************
    This section handles the Export Attribute Flow rules of the MA.
    *********************************************************************************************************************************
-->

<br></br>
<TABLE align='left' class="tableClass4">
<TR>
<TD>
    <TABLE cellspacing='0' cellpadding='0' border='1' bordercolorlight='#ffffff' bordercolordark='#ffffff' width='100%' align='left' class="tableClass4">
    <TR>
       <TH class="thAttributeFlow" colspan='4'><b>Export Attribute Flow </b></TH>
    </TR>
    <TR>
        <TD>
            <xsl:choose>
                <xsl:when test="//ma-data/export-attribute-flow/export-flow-set">
                    <table cellspacing='0' cellpadding='0' border='1' bordercolordark='#ffffff' width='100%' align='left' class="tableClass4">

                        <!-- Display the header of the export attribute flow table.-->

                        <tr>
                            <th class="thAttributeFlow1">Data Source Attribute</th>
                            <th class="thAttributeFlow1">To </th>
                            <th class="thAttributeFlow1">Metaverse Attribute</th>
                            <th class="thAttributeFlow1">Mapping Type</th>
                            <th class="thAttributeFlow1">Allow Nulls</th>
                            <th class="thAttributeFlow1">Initial Flow Only</th>
                        </tr>

                       <!-- Iterate each export-flow-set to print the header of the export-flow-set.-->

                       <xsl:for-each select="//ma-data/export-attribute-flow/export-flow-set">
                         <tr>
                             <td class="tdClass3"><b><xsl:value-of select="@ cd-object-type"/></b></td>
                             <td > <xsl:text> - </xsl:text> </td>
                             <td class="tdClass3"><b><xsl:value-of select="@ mv-object-type"/></b></td>
                             <td > <xsl:text> - </xsl:text> </td>
                             <td > <xsl:text> - </xsl:text> </td>
                             <td > <xsl:text> - </xsl:text> </td>
                         </tr>

                        <!-- Iterate each export-flow and process the mapping of the cd-attribute and the src-attribute.-->

                         <xsl:for-each select="export-flow">
                         <tr>

                            <!-- process the following sub section if the mapping type is SR mapping.-->

                            <xsl:if test="sync-rule-mapping">
                                   <td class="tdClass3"><xsl:value-of select="@ cd-attribute"/></td>
                                    <td class="tdClass6">
                                    <b>
                                        <xsl:text>&lt;-- </xsl:text>
                                    </b>
                                    </td>
                                   <td class="tdClass3"> 
										<xsl:choose>
											<xsl:when test="sync-rule-mapping/@mapping-type='direct'">
												<xsl:value-of select="sync-rule-mapping/src-attribute"/>
											</xsl:when>
											<xsl:when test="sync-rule-mapping/@mapping-type='expression'">
												<xsl:for-each select="sync-rule-mapping/src-attribute">
													<xsl:value-of select="."/>,
												</xsl:for-each>
												<xsl:for-each select="sync-rule-mapping/sync-rule-value/export-flow">
													[<xsl:call-template name="DisplayFunction" />]
												</xsl:for-each>
											</xsl:when>
											<xsl:when test="sync-rule-mapping/@mapping-type='constant'">
												[<xsl:value-of select="sync-rule-mapping/sync-rule-value"/>]
											</xsl:when>
										</xsl:choose>
                                    </td>
                                   <td class="tdClass3">
										<xsl:choose>
											<xsl:when test="sync-rule-mapping/@mapping-type='direct'">
												SR Direct 
											</xsl:when>
											<xsl:when test="sync-rule-mapping/@mapping-type='expression'">
												SR Expression 
											</xsl:when>
											<xsl:when test="sync-rule-mapping/@mapping-type='constant'">
												SR Constant 
											</xsl:when>
										</xsl:choose>
									</td>
                                   <td class="tdClass3"> 
                                    <xsl:choose>
                                    <xsl:when test="@suppress-deletions!='true'">
                                      <xsl:text>Allow</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise> -  </xsl:otherwise>
                                    </xsl:choose>
									</td>
                                   <td class="tdClass3">
										<xsl:choose>
											<xsl:when test="sync-rule-mapping"> 
												<xsl:value-of select="sync-rule-mapping/@initial-flow-only"/>
											</xsl:when>
											<xsl:otherwise> false  </xsl:otherwise>
										</xsl:choose>
                                   </td>
                            </xsl:if>

                            <!-- process the following sub section if the mapping type is direct mapping.-->

                            <xsl:if test="direct-mapping">
                                   <td class="tdClass3">  <xsl:value-of select="@ cd-attribute"/></td>
                                    <td class="tdClass6">
                                    <b>
                                        <xsl:text>&lt;-- </xsl:text>
                                    </b>
                                    </td>
                                   <td class="tdClass3"> 
                                      <xsl:value-of select="direct-mapping/src-attribute"/>
                                    </td>
                                   <td class="tdClass3"> Direct </td>
                                   <td class="tdClass3"> 
                                    <xsl:choose>
                                    <xsl:when test="@suppress-deletions!='true'">
                                      <xsl:text>Allow</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise> -  </xsl:otherwise>
                                    </xsl:choose>
                                   </td>
                            </xsl:if>

                            <!-- process the following sub section if the mapping type is scripted mapping.-->

                             <xsl:if test="scripted-mapping">
                                   <td class="tdClass3">  <xsl:value-of select="@ cd-attribute"/></td>
                                   <td class="tdClass6">
                                   <b>
                                       <xsl:text>&lt;--</xsl:text>
                                   </b>
                                   </td>                                   
                                   <td class="tdClass3"><xsl:for-each select="scripted-mapping/src-attribute">
										<xsl:if test="position()!=1">										
												<br />
											</xsl:if>
											<xsl:value-of select="."/>
										</xsl:for-each>
								   </td>
                                   
                                   <td class="tdClass3">Rules Extension - <xsl:value-of select="scripted-mapping/script-context"/></td>
                                   <td> 
                                    <xsl:choose>
                                    <xsl:when test="@suppress-deletions!='true'">
                                      <xsl:text>Allow</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise> -  </xsl:otherwise>
                                    </xsl:choose>
                                   </td>
                            </xsl:if>

                            <!-- process the following sub section if the mapping type is constant mapping.-->

                             <xsl:if test="constant-mapping">
                                   <td class="tdClass3">  <xsl:value-of select="@ cd-attribute"/>
                                    <td class="tdClass6">
                                    <b>
                                        <xsl:text>&lt;--</xsl:text>
                                    </b>
                                    </td>
                                    <td class="tdClass3"><xsl:text> - </xsl:text> </td>
                                   </td>
                                   <td class="tdClass3"> Constant -  <xsl:value-of select="constant-mapping/constant-value"/></td>
                                   <td> 
                                    <xsl:choose>
                                    <xsl:when test="@suppress-deletions!='true'">
                                      <xsl:text>Allow</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise> -  </xsl:otherwise>
                                    </xsl:choose>
                                   </td>
                            </xsl:if>

                       </tr>
                       </xsl:for-each>
                        <!-- End of select="export-flow" for-each.-->

                       </xsl:for-each>
                       <!-- End of //ma-data/export-attribute-flow/export-flow-set for-each.-->

                    </table>
                </xsl:when>
                <!-- End of test="//ma-data/export-attribute-flow/export-flow-set when.-->

                <xsl:otherwise>
                    <xsl:text> None </xsl:text>
                </xsl:otherwise>

            </xsl:choose>
        </TD>
    </TR>
    </TABLE>

<!--
    *********************************************************************************************************************************
    This section handles the Import Attribute Flow Rules of the MA.
    *********************************************************************************************************************************
-->
</TD>
</TR>
<TR>
<TD>
<br></br>     
    <TABLE cellspacing='0' border='1' cellpadding='0' bordercolorlight='#ffffff' bordercolordark='#ffffff' width='100%' align='left' class="tableClass4">
    <TR>         
       <TH class="thAttributeFlow" colspan='4'><b>Import Attribute Flow </b></TH>
    </TR>
     <TR>
        <TD>
        <xsl:choose>
        <xsl:when test="//mv-data/import-attribute-flow/import-flow-set/.">
            <table cellspacing='0' cellpadding='0' bordercolordark='#ffffff' border='1' class="tableClass4">                
                <tr>
                    <th class="thAttributeFlow1">Data Source Attribute</th>
                    <th class="thAttributeFlow1">To </th>
                    <th class="thAttributeFlow1">Metaverse Attribute</th>
                    <th class="thAttributeFlow1">Mapping Type</th>
                    <th class="thAttributeFlow1">Precedence Order</th>
                </tr>
                               
				<xsl:for-each select="//mv-data/import-attribute-flow/import-flow-set">				                
					<xsl:for-each select="import-flows">						
						<xsl:for-each select="import-flow">													
					    	<xsl:if test="@src-ma =$id ">
								<xsl:variable name='test2' select="user:xml2()"/>
								<xsl:variable name='test4' select="user:xml4()"/>
								<xsl:if test='$test2!=@ cd-object-type or $test4!=../../@ mv-object-type'>
											<tr>
											<td class="tdClass3"><b><xsl:value-of select="@cd-object-type"/> </b></td>
											<td> - </td>
											<td class="tdClass3"><b> <xsl:value-of select="../../@ mv-object-type"/></b></td>
											<td> - </td>
											<td> - </td>
											</tr>
								</xsl:if> 
								
								<xsl:variable name='test1' select="user:xml1(@ cd-object-type)"/>
								<xsl:variable name='test3' select="user:xml3(../../@ mv-object-type)"/>							
								
								<tr>
								<xsl:if test='sync-rule-mapping'>		                        
									<td class="tdClass3">
										<xsl:choose>
											<xsl:when test="sync-rule-mapping/@mapping-type='direct'">
												<xsl:value-of select="sync-rule-mapping/src-attribute"/>
											</xsl:when>
											<xsl:when test="sync-rule-mapping/@mapping-type='expression'">
												<xsl:for-each select="sync-rule-mapping/src-attribute">
													<xsl:value-of select="."/>,
												</xsl:for-each>
												<xsl:for-each select="sync-rule-mapping/sync-rule-value/export-flow">
													[<xsl:call-template name="DisplayFunction" />]
												</xsl:for-each>
												<!--[<xsl:value-of select="sync-rule-mapping/sync-rule-value"/>]-->
											</xsl:when>
											<xsl:when test="sync-rule-mapping/@mapping-type='constant'">
												[<xsl:value-of select="sync-rule-mapping/sync-rule-value"/>]
											</xsl:when>
										</xsl:choose>
									</td>
									<td class="tdClass6">
									<b>
										<xsl:text>--&gt;</xsl:text>
									</b>
									</td>
									<td class="tdClass3"><xsl:value-of select="../@ mv-attribute"/></td>
									<td class="tdClass3">
										<xsl:choose>
											<xsl:when test="sync-rule-mapping/@mapping-type='direct'">
												SR Direct 
											</xsl:when>
											<xsl:when test="sync-rule-mapping/@mapping-type='expression'">
												SR Expression 
											</xsl:when>
											<xsl:when test="sync-rule-mapping/@mapping-type='constant'">
												SR Constant 
											</xsl:when>
										</xsl:choose>
									</td>
								</xsl:if> 

								<xsl:if test='direct-mapping'>		                        
										<td class="tdClass3"> <xsl:value-of select="direct-mapping/src-attribute"/></td>
										<td class="tdClass6">
										<b>
											<xsl:text>--&gt;</xsl:text>
										</b>
										</td>                                    
										<td class="tdClass3"><xsl:value-of select="../@ mv-attribute"/></td>
										<td class="tdClass3">Direct </td>                                    		                        
								</xsl:if> 

								<!-- if the mapping type is scripted mapping then go to the following section.-->
								<xsl:if test='scripted-mapping'>		                        
										<td class="tdClass3"> 
										<xsl:for-each select="scripted-mapping/src-attribute">
											<xsl:if test="position()!=1">
												<xsl:text>,</xsl:text> 
											</xsl:if>
											<xsl:value-of select="."/>
										</xsl:for-each>
										</td>
										<td class="tdClass6">
										<b>
											<xsl:text>--&gt;</xsl:text>
										</b>
										</td>
										<td class="tdClass3"><xsl:value-of select="../@ mv-attribute"/></td>
										<td class="tdClass3">Rules Extension - <xsl:value-of select="scripted-mapping/script-context"/></td>											                        
								</xsl:if>

								<!-- if the mapping type is constant mapping then go to the following section.-->
								<xsl:if test='constant-mapping'>		                                                            
										<td class="tdClass3"><xsl:text> - </xsl:text> </td>
										<td class="tdClass6">
										<b>
											<xsl:text>--&gt;</xsl:text>
										</b>
										</td>                                     

										<td class="tdClass3"><xsl:value-of select="../@ mv-attribute"/></td>
										<td class="tdClass3">Constant - <xsl:value-of select="constant-mapping/constant-value"/></td>		                        
								</xsl:if>

								<!-- if the mapping type is dn part mapping then go to the following section.-->
								<xsl:if test="dn-part-mapping">		                        
										<td class="tdClass3"><xsl:text> - </xsl:text> </td>
										<td class="tdClass6">
										<b>
											<xsl:text>--&gt;</xsl:text>
										</b>
										</td> 
										<td class="tdClass3"><xsl:value-of select="../@ mv-attribute"/></td>
										<td class="tdClass3"> DN Component -  <xsl:value-of select="dn-part-mapping/dn-part"/></td>		                        
								</xsl:if>                                                                							
								<td class="tdClass3"><xsl:number format="1 "></xsl:number></td>                            																							
								</tr>
							</xsl:if>							                                                             
						</xsl:for-each>    
					</xsl:for-each>          
				</xsl:for-each> 
            </table>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text> None </xsl:text>
        </xsl:otherwise>
        </xsl:choose>
        </TD>
     </TR>
    </TABLE>


</TD>
</TR>
</TABLE>
    </TD>
</TR>


<!-- 
    #################################################################################################################################
    This section handles the Deprovisioning information of MA.
    #################################################################################################################################
-->


<TR>
    <TD class="tdLeftSection"><b> Deprovisioning </b></TD>
    <TD align='left'><a NAME='#Deprovisioning'></a>
    <table cellpadding='0' cellspacing='0' bordercolordark='#ffffff' align='left' border='1' class="tableClass4">
    <tr>
    <td ><b> Deprovision option: </b></td>
    <td >
        <xsl:choose>

<!-- When the provisioning-cleanup type is declared then display this type information.-->

        <xsl:when test="//ma-data/provisioning-cleanup/@ type = 'declared'">
        <xsl:choose>
                <xsl:when test="//ma-data/provisioning-cleanup/action = 'make-normal-disconnector'">
                        <xsl:text> Make them disconnectors </xsl:text>
                </xsl:when>
                <xsl:when test="//ma-data/provisioning-cleanup/action = 'make-explicit-disconnector'">
                        <xsl:text> Make them explicit disconnectors </xsl:text>
                </xsl:when>
                <xsl:when test="//ma-data/provisioning-cleanup/action = 'delete-object'">
                        <xsl:text> Stage a delete on the object for the next export run </xsl:text>
                </xsl:when>
        </xsl:choose>
        </xsl:when>

<!-- When the provisioning-cleanup type is scripted then display this type information as determined using extension.-->

        <xsl:when test="//ma-data/provisioning-cleanup/@ type = 'scripted'">
                 <xsl:text> Determine with a rules extension </xsl:text>
        </xsl:when>

        <xsl:otherwise>
                 <xsl:text> None </xsl:text>
        </xsl:otherwise>
        </xsl:choose>
    </td>
    </tr>

    <tr>
        <td ><b> Do not recall attributes contributed by an object from this MA when it is disconnected:</b></td>

    <xsl:choose>
    <xsl:when test="//mv-data/import-attribute-flow/per-ma-options">
    <!-- For each 'ma-options' in 'per-ma-options' iterate to get the valid 'ma-id'.-->

<xsl:variable name='m_isidavailable' select="//mv-data/import-attribute-flow/per-ma-options[ma-options/@ ma-id=$id]"/>
    <xsl:for-each select="//mv-data/import-attribute-flow/per-ma-options/ma-options">

        <!-- If the context-node's @ma-id is equal to the id of the MA then only display the sub-section.-->


                    <xsl:choose>
                    <!-- Display Yes when the 'enable-recall' is false.-->
                        <xsl:when test="@ma-id=$id">
                          <td>
                            <xsl:if test="enable-recall = 'false'">
                                <xsl:text> Yes </xsl:text>	
                            </xsl:if>
                            <xsl:if test="enable-recall = 'true'">
                                <xsl:text> No </xsl:text>	
                            </xsl:if>
                          </td>
                        </xsl:when>
                    <!-- Display No when the 'enable-recall' is true.-->
                    </xsl:choose>

    </xsl:for-each> 
    <!-- End of //mv-data/import-attribute-flow/per-ma-options/ma-options for-each.-->
    </xsl:when>

    <xsl:otherwise>
        <td><xsl:text>No</xsl:text> </td>
    </xsl:otherwise>

    </xsl:choose>
    </tr>
    </table>
    </TD>
</TR>


<!-- 
    #################################################################################################################################
    This section handles the Extension DLL information of MA.
    #################################################################################################################################
-->


<TR>
    <TD class="tdLeftSection"> <b>MA Extensions  </b></TD>
    <TD align='left'><a NAME='#MAExDLL'></a>
    <table cellpadding='0' cellspacing='0' bordercolordark='#ffffff' border='1' align='left' class="tableClass4">

<!-- Display the 'DLL' data.-->

    <tr>
        <td width="50%"><b>DLL:</b></td>
        <td width="50%">
            <xsl:choose>

            <!-- Display only if the 'assembly-name' of the 'extension' is not null.-->

                <xsl:when test="//ma-data/extension/assembly-name!=''">
                     <xsl:value-of select="//ma-data/extension/assembly-name"/>
                </xsl:when>

            <!-- Display None if the 'assembly-name' of the 'extension' is null.-->

                <xsl:otherwise>
                    <xsl:text> None </xsl:text>
                </xsl:otherwise>

            </xsl:choose>
        </td >
    </tr>

<!-- If the 'assembly-name' of the MA is not null then display the 'Run in separate process' data.-->

    <xsl:if test="//ma-data/extension/assembly-name!=''">
    <tr>
        <td width="50%"><b>Run in Separate Process: </b></td>
        <td width="50%">
        <xsl:choose>
            <xsl:when test="//ma-data/extension/application-protection='low'">
                <xsl:text> No </xsl:text>
            </xsl:when >
            <xsl:otherwise >
                <xsl:text> Yes </xsl:text>
            </xsl:otherwise >
        </xsl:choose>
        </td>
    </tr>
    </xsl:if>

    <tr>
        <td width="50%"><b> Enable Password Management:</b></td>
        <td width="50%">
        <xsl:choose>
        <xsl:when test="//ma-data/password-sync-allowed='0'">
        <xsl:text> No </xsl:text>
        </xsl:when >
        <xsl:otherwise >
        <xsl:text> Yes </xsl:text>
        </xsl:otherwise >
        </xsl:choose>
        </td>
    </tr>
    
    <!-- Start Password Target Settings -->
    <xsl:if test="//ma-data/password-sync-allowed='1'">
        <tr>
            <td colspan='2'>
                <table cellpadding='0' cellspacing='0' bordercolordark='#ffffff' border='1' align='left' class="tableClass4">
                    <tr>
                        <th colspan='2' class="thAttributeFlow">Password Target Settings</th>
                    </tr>

                    <!-- Start Password Extension Settings -->
                    <xsl:if test="//ma-data/private-configuration/*/password-extension-config/password-extension-enabled!=''">
                        <tr>
                            <td>
                                <b>Password Extention:</b>
                            </td>
                            <td>
                                <xsl:value-of select="//ma-data/private-configuration/*/password-extension-config/dll"/>
                            </td>
                        </tr>

                        <tr>
                            <td>
                                <b>Supported Operations:</b>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="//ma-data/private-configuration/*/password-extension-config/password-set-enabled='1' and //ma-data/private-configuration/*/password-extension-config/password-change-enabled='1'">
                                        Set and Change
                                    </xsl:when>
                                    <xsl:when test="//ma-data/private-configuration/*/password-extension-config/password-set-enabled='0' and //ma-data/private-configuration/*/password-extension-config/password-change-enabled='1'">
                                        Change Only
                                    </xsl:when>
                                    <xsl:when test="//ma-data/private-configuration/*/password-extension-config/password-set-enabled='1' and //ma-data/private-configuration/*/password-extension-config/password-change-enabled='0'">
                                        Set Only
                                    </xsl:when>
                                    <xsl:otherwise>
                                        Unknown
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>                            
                        </tr>

                        <tr>
                            <td>
                                <b>Server:</b>
                            </td>
                            <td>
                                <xsl:value-of select="//ma-data/private-configuration/*/password-extension-config/connection-info/connect-to"/>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <b>Username:</b>
                            </td>
                            <td>
                                <xsl:value-of select="//ma-data/private-configuration/*/password-extension-config/connection-info/user"/>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <b>Time out:</b>
                            </td>
                            <td>
                                <xsl:value-of select="//ma-data/private-configuration/*/password-extension-config/timeout"/>
                            </td>
                        </tr>
                            
                    </xsl:if>
                    <!-- End Password Extension Settings -->

                    <tr>
                        <td>
                            <b>Maximum retry count:</b>
                        </td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="//ma-data/password-sync/maximum-retry-count!=''">                
                                    <xsl:value-of select="//ma-data/password-sync/maximum-retry-count"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>Unknown</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <b>Retry interval (seconds):</b>
                        </td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="//ma-data/password-sync/retry-interval!=''">                
                                    <xsl:value-of select="//ma-data/password-sync/retry-interval"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>Unknown</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <b>Require secure connect:</b>
                        </td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="//ma-data/password-sync/allow-low-security!='1'">                
                                    <xsl:text>Yes</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>No</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </xsl:if>
    <!-- End Password Target Settings -->
    
    <xsl:if test="//ma-data/ma-partition-data/partition/.">
    <tr><th class="thAttributeFlow" colspan='2'>Partitions</th></tr>
    <tr>
		<th class="thAttributeFlow1"> <b>Partition Name </b></th> <th class="thAttributeFlow1"><b>Display Name</b> </th>
    </tr>
    <xsl:for-each select="//ma-data/ma-partition-data/partition">
        <xsl:if test="selected > 0">
        <tr>
            <td ><xsl:value-of select="name"/></td>
			<!-- Start of Display name-->
			<xsl:choose>
			<xsl:when test="display-name">
	            <td><xsl:value-of select="display-name"/></td>

		    </xsl:when>
			<xsl:otherwise>
				<td>None</td>
			</xsl:otherwise>
			</xsl:choose>
        </tr>
        </xsl:if>
    </xsl:for-each>
    </xsl:if>
   
   </table>
   </TD>
</TR>

<!--
    #################################################################################################################################
     This section handles the Run Profiles of MA.
    #################################################################################################################################
-->

<TR>
    <TD class="tdLeftSection"><b>Run Profiles</b></TD>
        <xsl:choose>

           <!-- If 'ma-run-data' is not null then execute the following 'for-each'.-->

            <xsl:when test="//ma-data/ma-run-data!=''">
                        <td class="tdClass2" align='left'><a NAME='#RSofMA'></a>

                        <!-- Display the name of the Runprofile based on each 'run-configuration' of 'ma-run-data'.-->

                            <xsl:for-each select="//ma-data/ma-run-data/run-configuration">
                            <table cellspacing='0' cellpadding='0' border='1' width='100%' bordercolordark='#ffffff'>
                                <tr><th class="thAttributeFlow" colspan='2' align='left' ><xsl:value-of select="name"/></th></tr>
                                <xsl:for-each select="configuration/step">
                                <tr>
                                    <td colspan='2'>
                                    <b>step <xsl:value-of select="position()" />   </b>

                                        <xsl:if test="step-type/@type='delta-import'" >
                                        <xsl:choose>
                                             <xsl:when test="step-type/import-subtype[last()]">
                                             <xsl:choose>                                           
                                                 <xsl:when test="step-type/import-subtype='to-cs'">                                         
                                                    <xsl:text>  Delta Import (Stage Only)</xsl:text>
                                                 </xsl:when>
                                                 <xsl:otherwise>
                                                    <xsl:text>  Delta Import and Delta Synchronization</xsl:text>
                                                 </xsl:otherwise>
                                             </xsl:choose>
                                             </xsl:when>
                                             <xsl:otherwise>
                                                    <xsl:text>  Delta Import and Delta Synchronization</xsl:text>
                                             </xsl:otherwise>
                                        </xsl:choose>
                                        </xsl:if>

                                        <xsl:if test="step-type/@type='full-import'" >
                                         <xsl:choose>
                                             <xsl:when test="step-type/import-subtype[last()]">
                                             <xsl:choose>
                                                 <xsl:when test="step-type/import-subtype='to-cs'">
                                                    <xsl:text>  Full Import (Stage Only)</xsl:text>
                                                 </xsl:when>
                                                 <xsl:otherwise>
                                                    <xsl:text>  Full Import and Delta Synchronization </xsl:text>
                                                 </xsl:otherwise>
                                             </xsl:choose>
                                              </xsl:when>
                                             <xsl:otherwise>
                                                  <xsl:text>  Full Import and Delta Synchronization </xsl:text>
                                             </xsl:otherwise>
                                        </xsl:choose>
                                        </xsl:if>

                                        <xsl:if test="step-type/@type='export'" >
                                            <xsl:text>  Export </xsl:text>
                                        </xsl:if>

                                        <xsl:if test="step-type/@type='full-import-reevaluate-rules'" >
                                            <xsl:text>  Full Import and Full Synchronization </xsl:text>
                                        </xsl:if>

                                        <xsl:if test="step-type/@type='apply-rules'" >
                                            <xsl:if test="step-type/apply-rules-subtype='apply-pending'">
                                            <xsl:text>  Delta Synchronization </xsl:text>
                                            </xsl:if>
                                            <xsl:if test="step-type/apply-rules-subtype='reevaluate-flow-connectors'">
                                            <xsl:text>  Full Synchronization </xsl:text>
                                            </xsl:if>
                                        </xsl:if>
                                    </td>
                                </tr>

                                <!--Start of log file name.-->
                                <tr>
                                    <td>Log filename</td>
                                    <xsl:choose>
                                        <xsl:when test="dropfile-name!=''">
                                            <td><xsl:value-of select="dropfile-name" /></td>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <td><xsl:text> None </xsl:text></td>
                                        </xsl:otherwise>
                                     </xsl:choose>
                                </tr>
                                <!-- End of Log file name.-->

                                <!-- Start of Partition.-->
                                <tr>
                                    <td>Partition Name</td>
                                    <td>
                                    <xsl:variable name='partition' select="partition"/>
                                    <xsl:for-each select="//ma-data/ma-partition-data/partition">
                                       <xsl:if test='id=$partition'>
                                            <xsl:value-of select='name'/>
                                        </xsl:if>
                                     </xsl:for-each>
                                    </td>
                                </tr>
                                <!-- End of Partition.-->

                                <!-- Start of number of objects.-->
                                <xsl:if test="threshold!=''">
                                <tr>
                                    <td class="tdClass2">Number of objects </td>
                                    <td><xsl:value-of select="threshold/object" /></td>
                                </tr>
                                </xsl:if>
                                <!-- End of number of objects.-->

 <!-- Start of Custom Data -->

                            <xsl:if test="$category='AVP' or $category='Fixed' or $category='Delimited' or $category='LDIF' or $category='DSML' or $category='MSSQL' or $category='Oracle' or $category='Extensible'">
                            <!-- start of input-file -->
                                <xsl:if test="custom-data/run-config/input-file/.">
                                <tr>
                                    <td class="tdClass2">Input File Name: </td>
                                    <xsl:choose>
                                    <xsl:when test="custom-data/run-config/input-file!=''">
                                    <td><xsl:value-of select="custom-data/run-config/input-file" /></td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    <td>None</td>
                                    </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                                </xsl:if>
                            <!--end of input-file-->

                                <!--start of output-file-->
                                <xsl:if test="custom-data/run-config/output-file">
                                <tr>
                                    <td class="tdClass2">Output File Name: </td>
                                    <xsl:choose>
                                    <xsl:when test="custom-data/run-config/output-file!=''">
                                    <td><xsl:value-of select="custom-data/run-config/output-file" /></td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    <td>None</td>
                                    </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                                </xsl:if>
                            </xsl:if>
                            <!--end of output-file-->
                            <!--start of Timeout,pagesize etc..-->
                            <xsl:if test="$category='AD' or $category='AD GAL' or $category='ADAM'">
                                <!-- AD, ADGAL, ADAM -->
                                <xsl:if test="custom-data/adma-step-data/.">
                                <tr>
                                    <td class="tdClass2">Batch-size (Objects): </td>
                                    <xsl:choose>
                                    <xsl:when test="custom-data/adma-step-data/batch-size!=''">
                                    <td><xsl:value-of select="custom-data/adma-step-data/batch-size" /></td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    <td>None</td>
                                    </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                                <tr>
                                    <td class="tdClass2">Page-size (Objects): </td>
                                    <xsl:choose>
                                    <xsl:when test="custom-data/adma-step-data/page-size!=''">
                                    <td><xsl:value-of select="custom-data/adma-step-data/page-size" /></td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    <td>None</td>
                                    </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                                <tr>
                                    <td class="tdClass2">TimeOut (in sec's): </td>
                                    <xsl:choose>
                                    <xsl:when test="custom-data/adma-step-data/time-limit!=''">
                                    <td><xsl:value-of select="custom-data/adma-step-data/time-limit" /></td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    <td>None</td>
                                    </xsl:otherwise>
                                    </xsl:choose>
                                </tr>

                                </xsl:if>
                            </xsl:if>
                            <!-- eDirectory -->
                            <xsl:if test="$category='eDirectory'">
                                <!-- Novell-eDir -->
                                <xsl:if test="custom-data/edma-step-data/.">
                                <tr>
                                    <td class="tdClass2">Batch-size (Objects): </td>
                                    <xsl:choose>
                                    <xsl:when test="custom-data/edma-step-data/batch-size!=''">
                                    <td><xsl:value-of select="custom-data/edma-step-data/batch-size" /></td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    <td>None</td>
                                    </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                                <tr>
                                    <td class="tdClass2">Page-size (Objects): </td>
                                    <xsl:choose>
                                    <xsl:when test="custom-data/edma-step-data/page-size!=''">
                                    <td><xsl:value-of select="custom-data/edma-step-data/page-size" /></td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    <td>None</td>
                                    </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                                <tr>
                                    <td class="tdClass2">TimeOut (in sec's): </td>
                                    <xsl:choose>
                                    <xsl:when test="custom-data/edma-step-data/time-limit!=''">
                                    <td><xsl:value-of select="custom-data/edma-step-data/time-limit" /></td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    <td>None</td>
                                    </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                                </xsl:if>
                                <!-- Novell-eDir -->
                            </xsl:if>
                            <xsl:if test="$category='iPlanet' or $category='IBM DS'">
                                <!-- iPlanet -->
                                <xsl:if test="custom-data/ipma-step-data/.">
                                <tr>
                                    <td class="tdClass2">Batch-size (Objects): </td>
                                    <xsl:choose>
                                    <xsl:when test="custom-data/ipma-step-data/batch-size!=''">
                                    <td><xsl:value-of select="custom-data/ipma-step-data/batch-size" /></td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    <td>None</td>
                                    </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                                <tr>
                                    <td class="tdClass2">Page-size (Objects): </td>
                                    <xsl:choose>
                                    <xsl:when test="custom-data/ipma-step-data/page-size!=''">
                                    <td><xsl:value-of select="custom-data/ipma-step-data/page-size" /></td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    <td>None</td>
                                    </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                                <tr>
                                    <td class="tdClass2">TimeOut (in sec's): </td>
                                    <xsl:choose>
                                    <xsl:when test="custom-data/ipma-step-data/time-limit!=''">
                                    <td><xsl:value-of select="custom-data/ipma-step-data/time-limit" /></td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    <td>None</td>
                                    </xsl:otherwise>
                                    </xsl:choose>

                                </tr>

                                </xsl:if>
                            </xsl:if>
                            <!-- iPlanet -->
                            <!--End of Timeout,pagesize etc..-->
                            <!--End of Custom Data-->


                                </xsl:for-each>
                            </table>
                            </xsl:for-each>

                        </td>
            </xsl:when>
            <!-- If the 'ma-run-data' is null then display 'None'.-->

            <xsl:otherwise>
                <td align='left'><xsl:text> None </xsl:text></td>
            </xsl:otherwise>
        </xsl:choose>
</TR>
</TABLE>
</TD>
</TR>
</TABLE>
</BODY>
</HTML>
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
s="tdClass3">
                            <xsl:value-of select="@type"/>
                        </td>

                        <td>
                            <xsl:choose>

                            <!-- Proceed when  filter-alternative is present.-->

                                <xsl:when test="filter-alternative">

                                    <!-- Iterate each select="filter-alternative".-->

                                    <xsl:for-each select="filter-alternative">
                                        <table align='center' cellpadding='0' cellspacing='0' border='1' bordercolordark="#ffffff" class="tableClass5" >
                                            <tr>
                                                <th class="thAttributeFlow1">Attribute</th>
                                                <th class="thAttributeFlow1">Operator</th>
                                                <th class="thAttributeFlow1">Value</th>
                                            </tr>

                                            <!-- Iterate each condition.-->

                                            <xsl:for-each select="condition">
                                                <tr>
                                                    <td class="tdClass3">
                                                        <xsl:choose>
                                                            <xsl:when test="@cd-attribute">
                                                                <xsl:value-of select="@cd-attribute"/>
                                                            </xsl:when>

                                                            <xsl:otherwise>
                                                                <xsl:text> Not Applicable.</xsl:text>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </td>

                                                    <td class="tdClass3">
                                                        <xsl:choose>
                                                            <xsl:when test="@operator">
                                                                <xsl:value-of select="@operator"/>
                                                            </xsl:when>

                                                            <xsl:otherwise>
                                                                <xsl:text> Not Applicable.</xsl:text>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </td>

                                                    <td class="tdClass3">
                                                        <xsl:choose>
                                                            <xsl:when test="value=''">
                                                                -
                                                            </xsl:when>

                                                            <xsl:when test="value">
                                                                <xsl:value-of select="value"/>
                                                            </xsl:when>

                                                            <xsl:otherwise>
                                                                <xsl:text> Not Applicable.</xsl:text>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </td>
                                                </tr>
                                            </xsl:for-each>
                                            <!-- End of select="condition" for-each.-->

                                        </table>
                                    </xsl:for-each>
                                    <!-- End of select="filter-alternative" for-each.-->

                                </xsl:when>
                                <!-- End of test="filter-alternative" when.-->

                                <xsl:otherwise>
                                    <xsl:text> Rules Extension </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:for-each>
                <!--end of select="//ma-data/stay-disconnector/filter-set/." for-each.-->

            </table>
        </xsl:when>
        
        <xsl:otherwise>
            <xsl:text> None </xsl:text>
        </xsl:otherwise>
        </xsl:choose>
    </TD>
</TR>

<!-- 
    #################################################################################################################################
    This section handles the Join Rules of the MA.
    #################################################################################################################################
-->

<TR>
    <TD class="tdLeftSection"><b>Join and Projection Rules </b></TD>
    <TD align='left'><a NAME='#Joinandprojection'></a>
        <br></br>
            <TABLE align='left' class="tableClass4">
            <TR>
            <TD>
            <table cellpadding='0' cellspacing='0' width='100%' align='left' class="tableClass4">
                <tr>
                    <td colspan='3'><b>Join Rules: </b></td>
                </tr>
                <tr>
                    <td>
                        <xsl:choose>

                        <!-- Proceed when the //ma-data/join/join-profile is not null.-->

                        <xsl:when test="//ma-data/join/join-profile!=''">
                        <table cellpadding='0' cellspacing='0' border='1' bordercolordark="#ffffff" width='100%' align='center'>

                        <tr>
                            <th class="thAttributeFlow1" align='center' 