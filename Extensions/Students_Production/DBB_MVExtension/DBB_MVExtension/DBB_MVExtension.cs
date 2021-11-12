
using System;
using System.DirectoryServices;
using System.Xml;
using Microsoft.MetadirectoryServices;

namespace Mms_Metaverse
{
	/// <summary>
	/// MIIS 2003 Metaverse Rules Extension for The Catholic Diocese of Broken Bay.
	/// Developed by Commander Infrastructure Solutions 2006-2007.
	/// </summary>
	public class MVExtensionObject : IMVSynchronization
	{
		#region declare global working environment
		int intStudentLifecycle;
		string strDisabledOU;
		string strPersonOU;
		string strPersonUPN;
		string strStudentOU;
		string strStudentUPN;
		string strMyMailForwarder;
		XmlNodeList xmlExchPrivateMDBList;

		// migration mode environment
		bool blnMigrationMode = false;
		string strForwarderContainer;
		#endregion

		public MVExtensionObject()
		{
			//
			// TODO: Add termination logic here
			//
		}

		void IMVSynchronization.Initialize ()
		{
			// open xml configuration document 'DBB_MVExtension.config'
			XmlDocument xmlConfig = new XmlDocument();
			xmlConfig.Load(Utils.ExtensionsDirectory.ToString() + "\\DBB_MVExtension.config");

			strDisabledOU = xmlConfig.SelectSingleNode("provisioning-extensions/dbb.local/Disabled/OU").InnerText;

			// load person object configuration information
			strPersonOU = xmlConfig.SelectSingleNode("provisioning-extensions/dbb.local/Person/OU").InnerText;
			strPersonUPN = xmlConfig.SelectSingleNode("provisioning-extensions/dbb.local/Person/UPN").InnerText;
			xmlExchPrivateMDBList = xmlConfig.SelectNodes("provisioning-extensions/dbb.local/Person/msExchPrivateMDB");
			
			// load student object configuration information
			strStudentOU = xmlConfig.SelectSingleNode("provisioning-extensions/dbb.local/Student/OU").InnerText;
			strStudentUPN = xmlConfig.SelectSingleNode("provisioning-extensions/dbb.local/Student/UPN").InnerText;
			strMyMailForwarder = xmlConfig.SelectSingleNode("provisioning-extensions/migration-mode/forwarders/student").InnerText;
			intStudentLifecycle = Convert.ToInt16(xmlConfig.SelectSingleNode("provisioning-extensions/Student/Lifecycle").InnerText);

			// retrieve mailbox counts from available mailstores (service account must be a domain account for this to work)
			DirectoryEntry dsDirectoryEntry = new DirectoryEntry();
			foreach (XmlNode xmlExchPrivateMDB in xmlExchPrivateMDBList)
			{
				DirectorySearcher dsMailboxes = new DirectorySearcher(dsDirectoryEntry, "(homeMDB=" + xmlExchPrivateMDB.InnerText + ")");
				XmlAttribute xmlExchPrivateMDBCount = xmlConfig.CreateAttribute("Count");
				xmlExchPrivateMDBCount.Value = dsMailboxes.FindAll().Count.ToString();
				xmlExchPrivateMDB.Attributes.Append(xmlExchPrivateMDBCount);
				dsMailboxes.Dispose();
			}
			dsDirectoryEntry.Dispose();

			#region MIGRATION - check if the solution is in migration mode
			try
			{
				blnMigrationMode = Convert.ToBoolean(xmlConfig.SelectSingleNode("provisioning-extensions/migration-mode/enabled").InnerText);
				strForwarderContainer = xmlConfig.SelectSingleNode("provisioning-extensions/migration-mode/forwarders/container").InnerText;
			}
			catch {}
			#endregion // this migration section can be deleted after the Diocese is running entirely on the new infrastructure.

		}

		void IMVSynchronization.Terminate ()
		{
			//
			// TODO: Add termination logic here
			//
		}

		void IMVSynchronization.Provision (MVEntry mventry)
		{
			// declare working environment
			int intLowerChar;
			int intUpperChar;
			int intSnChar;
			int intExchPrivateMDBCount = 0;
			string strMsExchPrivateMDB = "dummy"; // dummy value to stop CheckRequiredParameter exception
			string strPassword = "";
			ReferenceValue rvDN;
			
			// process provisioning depending on metaverse object type
			switch (mventry.ObjectType)
			{
				case "person":
					if (mventry["employeeStatus"].StringValue == "Active")
					{
						#region Create new AD user if no user account exists
						if (mventry.ConnectedMAs["dbb.local"].Connectors.Count == 0)
						{
							// provision new AD account in dbb.local
							ConnectedMA maAD = mventry.ConnectedMAs["dbb.local"];

							// locate an appropriate mailbox store for the new user
							foreach (XmlNode xmlExchPrivateMDB in xmlExchPrivateMDBList)
							{
								intLowerChar = Convert.ToInt16(Convert.ToChar(xmlExchPrivateMDB.InnerText.Substring(xmlExchPrivateMDB.InnerText.IndexOf("(") + 1,1).ToLower()));
								intUpperChar = Convert.ToInt16(Convert.ToChar(xmlExchPrivateMDB.InnerText.Substring(xmlExchPrivateMDB.InnerText.IndexOf(")") - 1,1).ToLower()));
								intSnChar = Convert.ToInt16(Convert.ToChar(mventry["sn"].StringValue.Substring(0,1).ToLower()));
							
								if (intSnChar >= intLowerChar && intSnChar <= intUpperChar)
								{
									if (intExchPrivateMDBCount == 0 | Convert.ToInt16(xmlExchPrivateMDB.Attributes["Count"].Value) < intExchPrivateMDBCount)
									{
										strMsExchPrivateMDB = xmlExchPrivateMDB.InnerText;
										intExchPrivateMDBCount = Convert.ToInt16(xmlExchPrivateMDB.Attributes["Count"].Value);
									}
								}
							}

							// update mailbox store mailbox count for new mailbox
							foreach (XmlNode xmlExchPrivateMDB in xmlExchPrivateMDBList)
							{
								if (strMsExchPrivateMDB == xmlExchPrivateMDB.InnerText)
								{
									intExchPrivateMDBCount = Convert.ToInt16(xmlExchPrivateMDB.Attributes["Count"].Value);
									intExchPrivateMDBCount++;
									xmlExchPrivateMDB.Attributes["Count"].Value = intExchPrivateMDBCount.ToString();
								}
							}

							// generate the user's account using ExchangeUtils.CreateMailbox
							rvDN = maAD.EscapeDNComponent("CN=" + mventry["displayName"].StringValue).Concat(strPersonOU);
							CSEntry csADUser = ExchangeUtils.CreateMailbox(maAD, rvDN, mventry["sAMAccountName"].StringValue, strMsExchPrivateMDB);
							csADUser["userAccountControl"].IntegerValue = 512; // enable normal account

							// force the following attributes for the new user account (overides attribute flow precedence)
							csADUser["displayName"].Value = mventry["displayName"].StringValue;
							csADUser["sAMAccountName"].Value = mventry["sAMAccountName"].StringValue;
							csADUser["userPrincipalName"].Value = mventry["sAMAccountName"].StringValue + "@" + strPersonUPN;

							// generate initial password
							if (mventry["dateOfBirth"].IsPresent)
							{
								DateTime dtDateOfBirth = DateTime.Parse(mventry["dateOfBirth"].StringValue);
								strPassword = dtDateOfBirth.Day.ToString("0#");
								strPassword += dtDateOfBirth.Month.ToString("0#");
								strPassword += dtDateOfBirth.Year.ToString();
							}
							else
							{
								strPassword = "01011900";
							}
							csADUser["unicodepwd"].Values.Add(strPassword);
							csADUser["pwdLastSet"].IntegerValue = 0; // force password reset on first logon
						
							// commit user account details
							csADUser.CommitNewConnector();
						}
						#endregion

						#region MIGRATION - perform migration mode functions
						if (blnMigrationMode)
						{
							if (mventry.ConnectedMAs["Legacy Exchange, migrated mailboxes"].Connectors.Count >= 1)
							{
								try
								{
									// provision SMTP forwarding address in Exchange 5.5
									ConnectedMA maLegacy55 = mventry.ConnectedMAs["Legacy Exchange, migrated mailboxes"];
									rvDN = maLegacy55.EscapeDNComponent("cn=" + mventry["mail"].StringValue).Concat(strForwarderContainer);
									CSEntry csRemoteAddress = ExchangeUtils.Create55CustomRecipient(maLegacy55, rvDN, mventry["mail"].StringValue, mventry["mail"].StringValue, mventry["mail"].StringValue, "X400:c=US;a= ;p=Exchange5.5;o=NT4DOMAIN;s" + mventry["mail"].StringValue + ";");
									csRemoteAddress["Hide-From-Address-Book"].BooleanValue = true;
									csRemoteAddress.CommitNewConnector();
								}
								catch (ObjectAlreadyExistsException) {}

								// clear legacy forwarder
								if (mventry.ConnectedMAs["dbb.local"].Connectors.Count > 1)
								{
									try
									{
										rvDN = mventry.ConnectedMAs["dbb.local"].CreateDN(mventry["otherMailbox"].Values[0].ToString());
										mventry.ConnectedMAs["dbb.local"].Connectors.ByDN[rvDN].Deprovision();
									}
									catch (ObjectNotFoundException) {}
									
									try
									{
										mventry.ConnectedMAs["Legacy Exchange, non-migrated mailboxes"].Connectors.DeprovisionAll();
									}
									catch (ObjectNotFoundException) {}
								}

							}
							if (mventry.ConnectedMAs["Legacy Exchange, non-migrated mailboxes"].Connectors.Count == 1)
							{
								if (mventry.ConnectedMAs["Legacy Exchange, migrated mailboxes"].Connectors.Count == 0)
								{
									try
									{
										// provision SMTP forwarding address in Exchange 2003
										ConnectedMA maAD = mventry.ConnectedMAs["dbb.local"];
										rvDN = maAD.CreateDN(mventry["otherMailbox"].Values[0].ToString());
										string strForwardingAddress = rvDN.ToString().Substring(3, rvDN.ToString().IndexOf(",")-3);
										CSEntry csLegacyForwarder = ExchangeUtils.CreateMailEnabledContact(maAD, rvDN, strForwardingAddress, strForwardingAddress);
										csLegacyForwarder["msExchHideFromAddressLists"].BooleanValue = true;
										csLegacyForwarder.CommitNewConnector();
									}
									catch (ObjectAlreadyExistsException) {}
								}
							}
						}
						#endregion // this migration section can be deleted after the Diocese is running entirely on the new infrastructure.
					}

					else
					{
						#region Move the user account in AD to the Disabled OU
						if (mventry.ConnectedMAs["dbb.local"].Connectors.Count >= 1)
						{
							CSEntry csADUser = mventry.ConnectedMAs["dbb.local"].Connectors.ByIndex[0];
							csADUser.DN = mventry.ConnectedMAs["dbb.local"].EscapeDNComponent("CN=" + mventry["displayName"].StringValue).Concat(strDisabledOU);
						}
						#endregion
					}
					break;

				case "student":
					
					// declare working environment
					bool blnConnectedToPfw = false;
					string strSubOU = "";

					// check if the student is connected to an instance of PfW
					foreach (ConnectedMA ma in mventry.ConnectedMAs)
					{
						if (ma.Name.IndexOf("PFW") >= 0)
						{blnConnectedToPfw = true;}
					}

					if (blnConnectedToPfw)
					{
						#region Ensure AD user account is in the correct OU
						if (mventry["dbbEduYearLevel"].IsPresent)
						{
							try
							{
								int intYearLevel = Convert.ToInt16(mventry["dbbEduYearLevel"].StringValue);
								if (intYearLevel >= 7)
								{strSubOU = "OU=Secondary,";}
								else if (intYearLevel <= 2)
								{strSubOU = "OU=Infant,";}
								else
								{strSubOU = "OU=Primary,";}
							}
							catch (FormatException)
							{
								if (mventry["dbbEduYearLevel"].StringValue.ToLower() == "k")
								{strSubOU = "OU=Infant,";}
							}
						}
						#endregion

						#region Create new AD user if no user account exists
						if (mventry.ConnectedMAs["dbb.local"].Connectors.Count == 0)
						{
							// provision new AD account in dbb.local
							ConnectedMA maAD = mventry.ConnectedMAs["dbb.local"];
							CSEntry csADUser = maAD.Connectors.StartNewConnector("user");
							csADUser.DN = maAD.EscapeDNComponent("CN=" + mventry["displayName"].StringValue).Concat(strSubOU + strStudentOU);
							csADUser["userAccountControl"].IntegerValue = 512;

							// force the following attributes for the new user account (overides attribute flow precedence)
							if (mventry["initials"].IsPresent)
							{csADUser["displayName"].Value = mventry["sn"].StringValue + ", " + mventry["givenName"].StringValue + " " + mventry["initials"].StringValue + " (" + mventry["dbbEduYearLevel"].StringValue + ")";}
							else
							{csADUser["displayName"].Value = mventry["sn"].StringValue + ", " + mventry["givenName"].StringValue + " (" + mventry["dbbEduYearLevel"].StringValue + ")";}
							csADUser["sAMAccountName"].Value = mventry["sAMAccountName"].StringValue; // value forced into the Metaverse to allow the AD MA to be the primary future data source.
							csADUser["userPrincipalName"].Value = mventry["sAMAccountName"].StringValue + "@" + strStudentUPN;
								
							// generate initial password
							if (mventry["dateOfBirth"].IsPresent)
							{
								DateTime dtDateOfBirth = DateTime.Parse(mventry["dateOfBirth"].StringValue);
								strPassword = dtDateOfBirth.Day.ToString("0#");
								strPassword += dtDateOfBirth.Month.ToString("0#");
								strPassword += dtDateOfBirth.Year.ToString();
							}
							else
							{
								strPassword = "01011900";
							}
							csADUser["unicodepwd"].Values.Add(strPassword);
							csADUser["pwdLastSet"].IntegerValue = 0; // force password reset on first logon

							// commit user account details
							csADUser.CommitNewConnector();
						}
						#endregion

						#region Create student mymail(CastNet) custom recipient

						if (mventry.ConnectedMAs["dbb.local"].Connectors.Count == 1)
						{
							try
							{
								// provision SMTP forwarding address in Exchange 2003
								ConnectedMA maAD = mventry.ConnectedMAs["dbb.local"];
								rvDN = maAD.CreateDN("CN=" + mventry["displayName"].StringValue).Concat(strMyMailForwarder);
								string strForwardingAddress = mventry["mail"].StringValue;
								CSEntry csMyMailForwarder = ExchangeUtils.CreateMailEnabledContact(maAD, rvDN, mventry["targetAddress"].StringValue, strForwardingAddress);
								csMyMailForwarder["msExchHideFromAddressLists"].BooleanValue = true;

								// force the following attributes
								if (mventry["initials"].IsPresent)
								{csMyMailForwarder["displayName"].Value = mventry["sn"].StringValue + ", " + mventry["givenName"].StringValue + " " + mventry["initials"].StringValue + " (" + mventry["dbbEduYearLevel"].StringValue + ")";}
								else
								{csMyMailForwarder["displayName"].Value = mventry["sn"].StringValue + ", " + mventry["givenName"].StringValue + " (" + mventry["dbbEduYearLevel"].StringValue + ")";}
								csMyMailForwarder["physicalDeliveryOfficeName"].Value = mventry["physicalDeliveryOfficeName"].StringValue;
								csMyMailForwarder["title"].Value = mventry["title"].StringValue;

								// commit new contact connector
								csMyMailForwarder.CommitNewConnector();
								
							}
							catch (ObjectAlreadyExistsException) {}
						}						
							#endregion

							#region Update existing accounts if it exists
						else
						{
							if (mventry.ConnectedMAs["dbb.local"].Connectors.Count >= 1)
							{
								// update AD user and contact
								CSEntry csADUser = mventry.ConnectedMAs["dbb.local"].Connectors.ByIndex[0];
								csADUser.DN = mventry.ConnectedMAs["dbb.local"].EscapeDNComponent("CN=" + mventry["displayName"].StringValue).Concat(strSubOU + strStudentOU);
								CSEntry csMyMailForwarder = mventry.ConnectedMAs["dbb.local"].Connectors.ByIndex[1];
								csMyMailForwarder.DN = mventry.ConnectedMAs["dbb.local"].EscapeDNComponent("CN=" + mventry["displayName"].StringValue).Concat(strMyMailForwarder);
							}
						}
						#endregion
					}

					else
					{
						#region Move the user account and exchange contact in AD to the Disabled OU or deprovision aged connectors
						if (mventry.ConnectedMAs["dbb.local"].Connectors.Count >= 1)
						{
							CSEntry csADUser = mventry.ConnectedMAs["dbb.local"].Connectors.ByIndex[0];
							if (csADUser.DN.ToString().IndexOf(strDisabledOU) >= 0)
							{
								// deprovision all connectors if older than a predetermined age (requires a Full Synchronisation cycle)
								DateTime dtLastUpdated = DateTime.Parse(mventry["dateLastUpdated"].StringValue).AddDays(intStudentLifecycle);
								if (dtLastUpdated < DateTime.Now)
								{mventry.ConnectedMAs.DeprovisionAll();}
							}
							else
							{
								csADUser.DN = mventry.ConnectedMAs["dbb.local"].EscapeDNComponent("CN=" + mventry["displayName"].StringValue).Concat(strDisabledOU);
							}
							break;
						}
						#endregion
					}

					break;

				default:
					break;
			}

		}	

		bool IMVSynchronization.ShouldDeleteFromMV (CSEntry csentry, MVEntry mventry)
		{
			throw new EntryPointNotImplementedException();
		}
	}
}
