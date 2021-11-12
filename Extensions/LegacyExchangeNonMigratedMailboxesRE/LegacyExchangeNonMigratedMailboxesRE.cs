
using System;
using Microsoft.MetadirectoryServices;

namespace Mms_ManagementAgent_LegacyExchangeNonMigratedMailboxesRE
{
    /// <summary>
    /// Summary description for MAExtensionObject.
	/// </summary>
	public class MAExtensionObject : IMASynchronization
	{
		public MAExtensionObject()
		{
        }
		void IMASynchronization.Initialize ()
		{
        }

        void IMASynchronization.Terminate ()
        {
        }

        bool IMASynchronization.ShouldProjectToMV (CSEntry csentry, out string MVObjectType)
        {
			throw new EntryPointNotImplementedException();
		}

        DeprovisionAction IMASynchronization.Deprovision (CSEntry csentry)
        {
			throw new EntryPointNotImplementedException();
        }	

        bool IMASynchronization.FilterForDisconnection (CSEntry csentry)
        {
            bool _returnValue = false;
            return _returnValue;
        }

		void IMASynchronization.MapAttributesForJoin (string FlowRuleName, CSEntry csentry, ref ValueCollection values)
        {
            throw new EntryPointNotImplementedException();
        }

        bool IMASynchronization.ResolveJoinSearch (string joinCriteriaName, CSEntry csentry, MVEntry[] rgmventry, out int imventry, ref string MVObjectType)
        {
            throw new EntryPointNotImplementedException();
		}

        void IMASynchronization.MapAttributesForImport( string FlowRuleName, CSEntry csentry, MVEntry mventry)
        {
            string _ForwardingAddress = Properties.Settings.Default.forwarderOU;
            switch (FlowRuleName)
			{
				case "cd.organizationalPerson:mail->mv.dbbStaff:otherMailbox":
                    if (csentry["mail"].IsPresent)
                    {
                        ReferenceValue _dn = csentry.MA.EscapeDNComponent("CN=" + csentry["mail"].StringValue);
                        _ForwardingAddress = _dn.Concat(_ForwardingAddress).ToString();
                        if (!mventry["otherMailbox"].Values.Contains(_ForwardingAddress))
                        { 
                            mventry["otherMailbox"].Values.Add(_ForwardingAddress); 
                        }	// used to set forwarder to legacy mailbox (Exchange 5.5) - now just info
                    }
                    break;

                case "cd.organizationalPerson:mail->mv.dbbStaff:altRecipient":
                    if (csentry["mail"].IsPresent)
                    {
                        // set forwarder to legacy mailbox (Exchange 5.5)
                        ReferenceValue _dn = csentry.MA.EscapeDNComponent("CN=" + csentry["mail"].StringValue);
                        _ForwardingAddress = _dn.Concat(_ForwardingAddress).ToString();
                        if (mventry["altRecipient"].IsPresent && (mventry["altRecipient"].Value.IndexOf("@") >= 0))
                        {
                            // there can be multiple Exchange 5.5 mailboxes, so ...
                            // only update if the email suffix still matches (i.e. only allow for name changes)
                            int _posAt = mventry["altRecipient"].Value.IndexOf("@");
                            string _existingSuffix = mventry["altRecipient"].Value.Substring(_posAt);
                            if (_ForwardingAddress.Contains(_existingSuffix))
                            {
                                mventry["altRecipient"].Value = _ForwardingAddress;
                            }
                        }
                        else
                        {
                            mventry["altRecipient"].Value = _ForwardingAddress;
                        }
                    }
                    break;

				default:
					throw new EntryPointNotImplementedException();
			}
        }

        void IMASynchronization.MapAttributesForExport (string FlowRuleName, MVEntry mventry, CSEntry csentry)
        {
            throw new EntryPointNotImplementedException();
        }
	}
}
