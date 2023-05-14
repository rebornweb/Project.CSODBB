With schools transitioning to Compass/Ancestry from SAS planned now in Feb 2023, a simple mechanism has been created to facilitate this.
Details of the mechanism are as follows
* new SQL table [SAS2IDM_SAS2IDM_LIVE].[dbo].[SAS2IDMSchoolEx]: there is a row for each school with a boolean flag [IsPromoted]
* updated SQL role [SAS2IDM_Write]: any DBB AD user [OCCCP-DB222] login who is a member of this existing SQL role will have permission to update this table
... specifically the [IsPromoted] flag on this table (e.g. from false to true)
* a new HTA [MaintainSites.hta]: a simple Windows Form UI which can be run from anywhere on the CSBB network with SQL access to the host [OCCCP-DB222] SAS host
* an updated SQL view [SAS2IDM_SAS2IDM_LIVE].[dbo].[AllSAS2IDMStudents]: this drives the data loaded to the [SAS2IDM] MIM MA via a UNIFYBroker v4 connector/adapter configuration
... specifically every student will be filtered from the view where the [SAS2IDMSchoolEx].[IsPromoted] value is TRUE matching [SAS2IDMSchoolEx].[SchoolID]
* all schools will be initialised with IsPromoted=FALSE, and eventually these will change to TRUE as each school is promoted

Bob Bradley, UNIFY Solutions, 27/9/2022