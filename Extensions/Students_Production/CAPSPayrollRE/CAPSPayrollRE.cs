
using System;
using System.Xml;
using Microsoft.MetadirectoryServices;

namespace Mms_ManagementAgent_CAPSPayrollRE
{
    /// <summary>
    /// Summary description for MAExtensionObject.
	/// </summary>
	public class MAExtensionObject : IMASynchronization
	{
		#region declare global working environment
		string strPhysicalDeliveryOfficeNameDefault;
		XmlNodeList xmlPhysicalDeliveryOfficeNameList;
		#endregion

		public MAExtensionObject()
		{
            //
            // TODO: Add constructor logic here
            //
        }
		void IMASynchronization.Initialize ()
		{
			// open xml configuration document 'CAPSPayrollRE.config'
			XmlDocument xmlREConfig = new XmlDocument();
			xmlREConfig.Load(Utils.ExtensionsDirectory.ToString() + "\\CAPSPayrollRE.config");

			xmlPhysicalDeliveryOfficeNameList = xmlREConfig.SelectNodes("provisioning-extensions/sal.school");

			// open xml configuration document 'DBB_MVExtension.config'
			XmlDocument xmlConfig = new XmlDocument();
			xmlConfig.Load(Utils.ExtensionsDirectory.ToString() + "\\DBB_MVExtension.config");

			strPhysicalDeliveryOfficeNameDefault = xmlConfig.SelectSingleNode("provisioning-extensions/dbb.local/Person/physicalDeliveryOfficeNameDefault").InnerText;
        }

        void IMASynchronization.Terminate ()
        {
            //
            // TODO: write termination code
            //
        }

        bool IMASynchronization.ShouldProjectToMV (CSEntry csentry, out string MVObjectType)
        {
			//
			// TODO: Remove this throw statement if you implement this method
			//
			throw new EntryPointNotImplementedException();
		}

        DeprovisionAction IMASynchronization.Deprovision (CSEntry csentry)
        {
			//
			// TODO: Remove this throw statement if you implement this method
			//
			throw new EntryPointNotImplementedException();
        }	

        bool IMASynchronization.FilterForDisconnection (CSEntry csentry)
        {
            //
            // TODO: write connector filter code
            //
            throw new EntryPointNotImplementedException();
		}

		void IMASynchronization.MapAttributesForJoin (string FlowRuleName, CSEntry csentry, ref ValueCollection values)
        {
			switch (FlowRuleName)
			{
				case "MatchEmployeeNumber":
					if (csentry["PERS.PIN"].IsPresent)
						{values.Add("S" + csentry["PERS.PIN"].StringValue);}
					break;

				default:
					throw new EntryPointNotImplementedException();
					break;
			}
        }

        bool IMASynchronization.ResolveJoinSearch (string joinCriteriaName, CSEntry csentry, MVEntry[] rgmventry, out int imventry, ref string MVObjectType)
        {
			//
			// TODO: write join resolution code
			//
			throw new EntryPointNotImplementedException();
		}

        void IMASynchronization.MapAttributesForImport( string FlowRuleName, CSEntry csentry, MVEntry mventry)
        {
            switch (FlowRuleName)
			{
				case "ConvertU2Date":
					DateTime dtDOB = DateTime.Parse("31/12/1967").AddDays(Convert.ToInt32(csentry["PERS.DOB"].Value));
					mventry["dateOfBirth"].Value = dtDOB.ToShortDateString();
					break;

				case "GenerateDateLastUpdated":
					mventry["dateLastUpdated"].Value = DateTime.Now.ToShortDateString();
					break;

				case "GenerateDisplayName":
					mventry["displayName"].Value = csentry["PERS.PREF.NAME"].Value + " " + csentry["PERS.SURNAME"].Value;
					break;

				case "GenerateEmployeeNumber":
					mventry["employeeNumber"].Value = "S" + csentry["PERS.PIN"].Value;
					break;

				case "GenerateSAMAccountName":
					bool blnAccountNameTruncated = false;
					int intSamAccountAffix = 0;
					string strSamAccountAttempt;
					string strSamAccountName = csentry["PERS.PREF.NAME"].StringValue + "." + csentry["PERS.SURNAME"].StringValue;
					
					// truncate samAccountName if too long
					if (strSamAccountName.Length >= 20)
					{
						strSamAccountName = csentry["PERS.SURNAME"].StringValue;
						blnAccountNameTruncated = true;
					}
					
					strSamAccountName = strSamAccountName.ToLower();

					// filter invalid username characters /\[]:;|=,+*?<>@" plus any other undesirables
					strSamAccountName = strSamAccountName.Replace("`", "'");
					char[] arrInvalidChar = "/\\[]:;|=,+*?<>@\"~ ".ToCharArray();
					if (strSamAccountName.IndexOfAny(arrInvalidChar) >= 0)
					{
						foreach (char charInvalidChar in arrInvalidChar)
						{strSamAccountName = strSamAccountName.Replace(charInvalidChar.ToString(), "");}
					}

					// check sAMAccountName is unique
					strSamAccountAttempt = strSamAccountName;
					MVEntry[] findResultList = null;
					while (!mventry["sAMAccountName"].IsPresent)
					{
						findResultList = Utils.FindMVEntries("sAMAccountName", strSamAccountAttempt);
						if (findResultList.Length == 0)
						{
							mventry["sAMAccountName"].Value = strSamAccountAttempt;
						}
						else
						{
							// append numeric affix to the user name
							intSamAccountAffix++;
							strSamAccountAttempt = strSamAccountName + intSamAccountAffix.ToString();
							
							// truncate samAccountName if too long
							if (!blnAccountNameTruncated && strSamAccountAttempt.Length >= 20)
							{
								strSamAccountName = csentry["PERS.SURNAME"].StringValue;
								blnAccountNameTruncated = true;
							}
						}
					}
					break;

				case "ResolveADSCodes":
					mventry["dbbADSCode"].Values.Clear();
					if (csentry["ADS.Code"].IsPresent)
					{
						DateTime dtADSEndDate;
						DateTime dtADSStartDate;
						int intLeader;
						string strADSCodeStatus;
						string strADSCodeTemp;
						string strADSLeaderCodeTemp;
						string[] arrADSEndDate;
						string[] arrADSStartDate;
						
						for (int i = 0; i < csentry["ADS.Code"].Values.Count; i++)
						{
							strADSCodeStatus = "";
							strADSCodeTemp = csentry["ADS.Code"].Values[i].ToString();

							// check ADS Code status
							arrADSStartDate = csentry["ADS.START"].Values[i].ToString().Split("_".ToCharArray());
							if (arrADSStartDate[1].Length > 0)
							{
								dtADSStartDate = DateTime.Parse("31/12/1967").AddDays(Convert.ToInt32(arrADSStartDate[1]));
								if (dtADSStartDate > DateTime.Today)
									{strADSCodeStatus = "pending";}
							}
							else 
							{strADSCodeStatus = "pending";}

							arrADSEndDate = csentry["ADS.END"].Values[i].ToString().Split("_".ToCharArray());
							if (arrADSEndDate[1].Length > 0)
							{
								dtADSEndDate = DateTime.Parse("31/12/1967").AddDays(Convert.ToInt32(arrADSEndDate[1]));
								if (dtADSEndDate < DateTime.Today)
								{strADSCodeStatus = "expired";}
							}

							if (strADSCodeStatus.Length > 0)
							{
								strADSCodeTemp += "_" + strADSCodeStatus;
								mventry["dbbADSCode"].Values.Add(strADSCodeTemp);
							}
							else
							{
								// add raw ADS code
								mventry["dbbADSCode"].Values.Add(strADSCodeTemp);
								
								// check if user is a Team Manager and add ADS Leadership Code
								if (strADSCodeTemp.Substring(6,1) == "1")
								{
									// level 1
									strADSLeaderCodeTemp = strADSCodeTemp.Remove(6,1);
									strADSLeaderCodeTemp = strADSLeaderCodeTemp.Insert(6,"Z");
									mventry["dbbADSCode"].Values.Add(strADSLeaderCodeTemp);

									// level 2
									strADSLeaderCodeTemp = strADSCodeTemp;
									intLeader = strADSLeaderCodeTemp.IndexOf("0",1) - 1;
									if (intLeader < 0)
										{intLeader = 5;}
									strADSLeaderCodeTemp = strADSLeaderCodeTemp.Remove(intLeader,1);
									strADSLeaderCodeTemp = strADSLeaderCodeTemp.Insert(intLeader,"0");
									strADSLeaderCodeTemp = strADSLeaderCodeTemp.Remove(6,1);
									strADSLeaderCodeTemp = strADSLeaderCodeTemp.Insert(6,"Z");
									mventry["dbbADSCode"].Values.Add(strADSLeaderCodeTemp);
								}
								
								// add ADS group code
								strADSCodeTemp = strADSCodeTemp.Remove(6,1);
								strADSCodeTemp = strADSCodeTemp.Insert(6,"0");
								mventry["dbbADSCode"].Values.Add(strADSCodeTemp);
							}
						}
					}

					//set home folder group membership
					if (csentry["SAL.SCHOOL"].IsPresent)
					{
						foreach (XmlNode xmlPhysicalDeliveryOfficeName in xmlPhysicalDeliveryOfficeNameList)
						{
							if (xmlPhysicalDeliveryOfficeName.Attributes["code"].Value == csentry["SAL.SCHOOL"].StringValue)
							{mventry["dbbADSCode"].Values.Add(xmlPhysicalDeliveryOfficeName["physicalDeliveryOfficeName"].InnerText);}
						}
					}
					else
					{
						mventry["dbbADSCode"].Values.Add(strPhysicalDeliveryOfficeNameDefault);
					}
					
					//set internet users group membership
					mventry["dbbADSCode"].Values.Add("InternetUsers");
					break;

				case "ResolvePhysicalDeliveryOfficeName":
					if (csentry["SAL.SCHOOL"].IsPresent)
					{
						foreach (XmlNode xmlPhysicalDeliveryOfficeName in xmlPhysicalDeliveryOfficeNameList)
						{
							if (xmlPhysicalDeliveryOfficeName.Attributes["code"].Value == csentry["SAL.SCHOOL"].StringValue)
							{mventry["physicalDeliveryOfficeName"].Value = xmlPhysicalDeliveryOfficeName["physicalDeliveryOfficeName"].InnerText;}
						}
					}
					else
					{
						mventry["physicalDeliveryOfficeName"].Value = strPhysicalDeliveryOfficeNameDefault;
					}
					break;
			
				case "ResolveStatus":
					if (csentry["PERS.FTE.HRS"].IsPresent)
					{
						if (csentry["PERS.FTE.HRS"].Value == "0")
							{mventry["employeeStatus"].Value = "Inactive";}
						else
							{mventry["employeeStatus"].Value = "Active";}
					}
					if (csentry["ADS.ACTIVE"].IsPresent)
					{
						if (csentry["ADS.ACTIVE"].StringValue != "Y")
							{mventry["employeeStatus"].Value = "Inactive";}
						else
							{mventry["employeeStatus"].Value = "Active";}
					}
					break;
					
				default:
					throw new EntryPointNotImplementedException();
			}
        }

        void IMASynchronization.MapAttributesForExport (string FlowRuleName, MVEntry mventry, CSEntry csentry)
        {
            //
			// TODO: write your export attribute flow code
			//
            throw new EntryPointNotImplementedException();
        }
	}
}
