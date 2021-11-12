
using System;
using System.Xml;
using Microsoft.MetadirectoryServices;

namespace Mms_ManagementAgent_LegacyExchangeNonMigratedMailboxesRE
{
    /// <summary>
    /// Summary description for MAExtensionObject.
	/// </summary>
	public class MAExtensionObject : IMASynchronization
	{
		#region declare global working environment
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

			blnMigrationMode = Convert.ToBoolean(xmlConfig.SelectSingleNode("provisioning-extensions/migration-mode/enabled").InnerText);
			strForwarderOU = xmlConfig.SelectSingleNode("provisioning-extensions/migration-mode/forwarders/OU").InnerText;
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
			bool blnReturnValue = false;
			if (csentry["Extension-Attribute-5"].IsPresent)
			{
				MVEntry[] findResultList = Utils.FindMVEntries("employeeNumber", csentry["Extension-Attribute-5"].StringValue);
				if (findResultList.Length > 0)
				{
					if (findResultList[0].ConnectedMAs["Legacy Exchange, migrated mailboxes"].Connectors.Count > 0)
					{blnReturnValue = true;}
				}
			}
			return blnReturnValue;
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
				case "GenerateForwardingAddress":	
					if (blnMigrationMode && csentry["mail"].IsPresent)
					{
						string strForwardingAddress = "CN=" + csentry["mail"].StringValue + "," + strForwarderOU;
						if (!mventry["otherMailbox"].Values.Contains(strForwardingAddress))
							{mventry["otherMailbox"].Values.Add(strForwardingAddress);}	// set forwarder to legacy mailbox (Exchange 5.5)	
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
