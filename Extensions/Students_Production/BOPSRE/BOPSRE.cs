
using System;
using System.Xml;
using Microsoft.MetadirectoryServices;

namespace Mms_ManagementAgent_BOPSRE
{
    /// <summary>
    /// Summary description for MAExtensionObject.
	/// </summary>
	public class MAExtensionObject : IMASynchronization
	{
		#region declare global working environment
		string strPhysicalDeliveryOfficeNameDefault;
		#endregion
		
		public MAExtensionObject()
		{
            //
            // TODO: Add constructor logic here
            //
        }
		void IMASynchronization.Initialize ()
		{
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
					if (csentry["EmployeeID"].IsPresent)
					{values.Add("B" + csentry["EmployeeID"].StringValue);}
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
				case "GenerateDateLastUpdated":
					mventry["dateLastUpdated"].Value = DateTime.Now.ToShortDateString();
					break;

				case "GenerateDisplayName":
					mventry["displayName"].Value = csentry["PreferredName"].Value + " " + csentry["Surname"].Value;
					break;

				case "GenerateEmployeeNumber":
					mventry["employeeNumber"].Value = "B" + csentry["EmployeeID"].Value;
					break;
				
				case "GenerateSAMAccountName":
					bool blnAccountNameTruncated = false;
					int intSamAccountAffix = 0;
					string strSamAccountAttempt;
					string strSamAccountName = csentry["PreferredName"].StringValue + "." + csentry["Surname"].StringValue;
					
					// truncate samAccountName if too long
					if (strSamAccountName.Length >= 20)
					{
						strSamAccountName = csentry["Surname"].StringValue;
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
								strSamAccountName = csentry["Surname"].StringValue;
								blnAccountNameTruncated = true;
							}
						}
					}
					break;
				
				case "ResolveADSCodes":
					mventry["dbbADSCode"].Values.Clear();
					if (csentry["ADSCode"].IsPresent)
					{
						DateTime dtADSEndDate;
						DateTime dtADSStartDate;
						int intLeader;
						string strADSCodeStatus;
						string strADSCodeTemp;
						string strADSLeaderCodeTemp;
						string[] arrADSEndDate;
						string[] arrADSStartDate;
						
						for (int i = 0; i < csentry["ADSCode"].Values.Count; i++)
						{
							strADSCodeStatus = "";
							strADSCodeTemp = csentry["ADSCode"].Values[i].ToString();

							// check ADS Code status
							arrADSStartDate = csentry["ADSRoleStartDate"].Values[i].ToString().Split("_".ToCharArray());
							if (arrADSStartDate[1].Length > 0)
							{
								dtADSStartDate = DateTime.Parse(arrADSStartDate[1]);
								if (dtADSStartDate > DateTime.Today)
								{strADSCodeStatus = "pending";}
							}
							else 
							{strADSCodeStatus = "pending";}

							arrADSEndDate = csentry["ADSRoleEndDate"].Values[i].ToString().Split("_".ToCharArray());
							if (arrADSEndDate[1].Length > 0)
							{
								dtADSEndDate = DateTime.Parse(arrADSEndDate[1]);
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

					//set home folders group membership
					if (csentry["PositionLocation"].IsPresent)
					{mventry["dbbADSCode"].Values.Add(csentry["PositionLocation"].StringValue);}
					else
					{mventry["dbbADSCode"].Values.Add(strPhysicalDeliveryOfficeNameDefault);}
					
					//set internet users group membership
					mventry["dbbADSCode"].Values.Add("InternetUsers");
					break;

				case "ResolvePhysicalDeliveryOfficeName":
					if (csentry["PositionLocation"].IsPresent)
						{mventry["physicalDeliveryOfficeName"].Value = csentry["PositionLocation"].StringValue;}
					else
						{mventry["physicalDeliveryOfficeName"].Value = strPhysicalDeliveryOfficeNameDefault;}
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
