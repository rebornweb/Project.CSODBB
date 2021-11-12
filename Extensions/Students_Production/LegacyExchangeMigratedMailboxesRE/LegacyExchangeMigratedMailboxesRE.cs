
using System;
using System.Xml;
using Microsoft.MetadirectoryServices;

namespace Mms_ManagementAgent_LegacyExchangeMigratedMailboxesRE
{
    /// <summary>
    /// Summary description for MAExtensionObject.
	/// </summary>
	public class MAExtensionObject : IMASynchronization
	{
		#region declare global working environment
		bool blnMigrationMode = false;
		string strForwarderContainer;
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
			strForwarderContainer = xmlConfig.SelectSingleNode("provisioning-extensions/migration-mode/forwarders/container").InnerText;
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

        void IMASynchronization.MapAttributesForImport( string FlowRuleName, CSEntry csentry, MVEntry mventry)
        {
			//
			// TODO: write your import attribute flow code
			//
			throw new EntryPointNotImplementedException();
        }

        void IMASynchronization.MapAttributesForExport (string FlowRuleName, MVEntry mventry, CSEntry csentry)
        {
			switch (FlowRuleName)
			{
				case "ResolveAlt-Recipient":
					if (blnMigrationMode)
					{csentry["Alt-Recipient"].ReferenceValue = mventry.ConnectedMAs["Legacy Exchange, migrated mailboxes"].EscapeDNComponent("cn=" + mventry["mail"].StringValue).Concat(strForwarderContainer);}
					break;

				default:
					throw new EntryPointNotImplementedException();
			}

        }
	}
}
