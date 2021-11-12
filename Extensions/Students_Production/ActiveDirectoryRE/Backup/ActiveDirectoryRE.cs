
using System;
using System.Collections;
using System.Xml;
using Microsoft.MetadirectoryServices;

namespace Mms_ManagementAgent_ActiveDirectoryRE
{
    /// <summary>
    /// Summary description for MAExtensionObject.
	/// </summary>
	public class MAExtensionObject : IMASynchronization
	{
		#region declare global working environment
		string strDisabledOU;
		string strGroupOU;
		string dtLastUpdatedValue;
		XmlNodeList xmlEduADSCodePrefixList;

		// migration mode environment
		bool blnMigrationMode = false;
		string strForwarderOU;
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

			strDisabledOU = xmlConfig.SelectSingleNode("provisioning-extensions/dbb.local/Disabled/OU").InnerText;
			strGroupOU = xmlConfig.SelectSingleNode("provisioning-extensions/dbb.local/Group/OU").InnerText;
			xmlEduADSCodePrefixList = xmlConfig.SelectNodes("provisioning-extensions/dbb.local/Person/eduADSCodePrefix");

			#region MIGRATION - check if the solution is in migration mode
			try
			{
				blnMigrationMode = Convert.ToBoolean(xmlConfig.SelectSingleNode("provisioning-extensions/migration-mode/enabled").InnerText);
				strForwarderOU = xmlConfig.SelectSingleNode("provisioning-extensions/migration-mode/forwarders/OU").InnerText;
			}
			catch {}
			#endregion // this migration section can be deleted after the Diocese is running entirely on the new infrastructure.

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
            //
            // TODO: write join mapping code
            //
            throw new EntryPointNotImplementedException();
        }

        bool IMASynchronization.ResolveJoinSearch (string joinCriteriaName, CSEntry csentry, MVEntry[] rgmventry, out int imventry, ref string MVObjectType)
        {
            //
            // TODO: write join resolution code
            //
            throw new EntryPointNotImplementedException();
		}

        void IMASynchronization.MapAttributesForImport(string FlowRuleName, CSEntry csentry, MVEntry mventry)
        {
			switch (FlowRuleName)
			{
				#region MIGRATION - perform migration mode functions
				case "ImportAltRecipient":
					if (!mventry["otherMailbox"].Values.Contains(csentry["altRecipient"].ReferenceValue.ToString()))
						{mventry["otherMailbox"].Values.Add(csentry["altRecipient"].ReferenceValue.ToString());}
				break;
				#endregion // this migration section can be deleted after the Diocese is running entirely on the new infrastructure.

				default:
					throw new EntryPointNotImplementedException();
			}
        }

        void IMASynchronization.MapAttributesForExport (string FlowRuleName, MVEntry mventry, CSEntry csentry)
        {
            switch (FlowRuleName)
			{
				#region MIGRATION - perform migration mode functions
				case "SetLegacyForwarder":
					if (mventry["otherMailbox"].Values.Count > 0)
						{csentry["altRecipient"].ReferenceValue = csentry.MA.CreateDN(mventry["otherMailbox"].Values[0].ToString());}
					else
						{csentry["altRecipient"].Delete();}
					break;

				case "SetLegacyForwarderDisplay":
					if (mventry["otherMailbox"].Values.Count > 0)
					{
						string strExtensionAttribute6 = mventry["otherMailbox"].Values[0].ToString().ToLower();
						csentry["extensionAttribute6"].StringValue = strExtensionAttribute6.Substring(3, strExtensionAttribute6.IndexOf(",") - 3);
					}
					else
					{csentry["extensionAttribute6"].Delete();}
					break;

				#endregion // this migration section can be deleted after the Diocese is running entirely on the new infrastructure.

				case "SetADSGroupMembership":

					if (csentry["info"].IsPresent)
					{
						// store groups that are members of this group
						ArrayList arrGroups = new ArrayList();
						foreach (Value vMember in csentry["member"].Values)
						{
							if (vMember.ToString().IndexOf(strGroupOU) >= 0)
							{arrGroups.Add(vMember);}
						}
					
						// clear group membership (ensures expired ADS codes and alien accounts are removed from the group)
						csentry["member"].Values.Clear();
						
						MVEntry[] arrMVEntries = Utils.FindMVEntries("dbbADSCode", csentry["info"].StringValue);
						foreach (MVEntry mvUser in arrMVEntries)
						{
							if (mvUser["employeeStatus"].StringValue == "Active" && mvUser.ConnectedMAs["dbb.local"].Connectors.Count > 0)
								{csentry["member"].Values.Add(mvUser.ConnectedMAs["dbb.local"].Connectors.ByIndex[0].DN);}
						}

						// return groups to group membership
						foreach (Value vGroup in arrGroups)
						{
							if (vGroup.ToString().IndexOf(strGroupOU) > 0)
							{csentry["member"].Values.Add(vGroup);}
						}
					}
					break;

				case "SetExtensionAttribute14":
					csentry["extensionAttribute14"].Delete();
					if (mventry["dbbADSCode"].IsPresent)
					{
						foreach (Value vADSCode in mventry["dbbADSCode"].Values)
						{
							foreach (XmlNode xmlEduADSCodePrefix in xmlEduADSCodePrefixList)
							{
								if (vADSCode.ToString().IndexOf(xmlEduADSCodePrefix.InnerText) == 0)
									{csentry["extensionAttribute14"].StringValue = "edu";}
							}
						}
					}
					break;

				case "GenerateDisplayName":
					if(mventry["dbbEduYearLevel"].IsPresent)
					{
						if (mventry["initials"].IsPresent)
						{csentry["displayName"].Value = mventry["sn"].StringValue + ", " + mventry["givenName"].StringValue + " " + mventry["initials"].StringValue + " (" + mventry["dbbEduYearLevel"].StringValue + ")";}
						else
						{csentry["displayName"].Value = mventry["sn"].StringValue + ", " + mventry["givenName"].StringValue + " (" + mventry["dbbEduYearLevel"].StringValue + ")";}
					}
					break;

				case "SetUserAccountControl":
					if (csentry.DN.ToString().IndexOf(strDisabledOU) >= 0)
					{csentry["userAccountControl"].IntegerValue = 514;} // disable normal account
					break;

				case "SetmsExchHideFromAddressLists":
					// Set student contact from Exchange Address lists if connector has been filtered
					if(mventry["dbbEduYearLevel"].IsPresent)
					{
						dtLastUpdatedValue = mventry["dateLastUpdated"].StringValue;
						DateTime dtLastUpdated = DateTime.Parse(dtLastUpdatedValue);
						if (dtLastUpdated < DateTime.Now.AddDays(-1))
						{csentry["msExchHideFromAddressLists"].BooleanValue = true;}
						else
						{csentry["msExchHideFromAddressLists"].BooleanValue = false;} //change to false for remote site migration
					}
					break;

				case "SetphysicalDeliveryOfficeName":
					// Set physicalDeliveryOfficeName value for aged student mymail connectors
					if(mventry["dbbEduYearLevel"].IsPresent)
					{
						dtLastUpdatedValue = mventry["dateLastUpdated"].StringValue;
						DateTime dtLastUpdated = DateTime.Parse(dtLastUpdatedValue);
						if (dtLastUpdated < DateTime.Now.AddDays(-1))
						{csentry["physicalDeliveryOfficeName"].Delete();}
						else
						{csentry["physicalDeliveryOfficeName"].Value = mventry["physicalDeliveryOfficeName"].Value;}
					}
					break;

				case "Settitle":
					// Set title value for aged student mymail connectors
					if(mventry["dbbEduYearLevel"].IsPresent)
					{
						dtLastUpdatedValue = mventry["dateLastUpdated"].StringValue;
						DateTime dtLastUpdated = DateTime.Parse(dtLastUpdatedValue);
						if (dtLastUpdated < DateTime.Now.AddDays(-1))
						{csentry["title"].Delete();}
						else
						{csentry["title"].Value = mventry["title"].Value;}
					}
					break;

				case "SetExtensionAttribute9":
					string sAMAccountName = mventry["sAMAccountName"].StringValue;
					string physicalDeliveryOfficeName = mventry["physicalDeliveryOfficeName"].StringValue.ToLower();

					if (mventry["physicalDeliveryOfficeName"].IsPresent)
					{
						if (mventry.ObjectType.Equals("person"))
						{csentry["extensionattribute9"].Value = "\\\\dbb\\" + physicalDeliveryOfficeName + "\\users\\" + sAMAccountName + "\\My Documents";}
						if (mventry.ObjectType.Equals("student"))
						{csentry["extensionattribute9"].Value = "\\\\dbb\\" + physicalDeliveryOfficeName + "\\Students\\" + sAMAccountName + "\\My Documents";}
					}
					break;

				case "SetprofilePath":
					if (mventry.ObjectType.Equals("person"))
					{
						if (mventry["physicalDeliveryOfficeName"].Value.Equals("OCCCP"))
						{csentry["profilePath"].Value = "\\\\dbb\\occcp\\Profiles\\" + mventry["sAMAccountName"].StringValue;}
					}
					break;

				default:
					throw new EntryPointNotImplementedException();
			}
        }
	}
}
