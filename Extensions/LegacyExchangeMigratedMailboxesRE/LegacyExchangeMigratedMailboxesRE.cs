
using System;
using Microsoft.MetadirectoryServices;

namespace Mms_ManagementAgent_LegacyExchangeMigratedMailboxesRE
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
            throw new EntryPointNotImplementedException();
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
            switch (FlowRuleName)
            {
                case "cd.organizationalPerson:->mv.dbbStaff:isInactive":
                    // if there is an organizationalPerson connector AND a Remote-Address, the organizationalPerson
                    // object needs to be archived by the school NT admin
                    if (!mventry["isInactive"].IsPresent)
                    {
                        mventry["isInactive"].BooleanValue = true;
                    }
                    break;

                case "cd.Remote-Address:->mv.dbbStaff:isActive":
                    if (!mventry["isActive"].IsPresent)
                    {
                        mventry["isActive"].BooleanValue = true;
                    }
                    break;

                default:
                    throw new EntryPointNotImplementedException();
            }
        }

        void IMASynchronization.MapAttributesForExport (string FlowRuleName, MVEntry mventry, CSEntry csentry)
        {
            CSEntry _csentry;
            switch (FlowRuleName)
			{
				case "cd.organizationalPerson:Alt-Recipient<-mv.dbbStaff:mail":
                    if (csentry["Alt-Recipient"].IsPresent)
                    {
                        csentry["Alt-Recipient"].Values.Clear();
                    }
                    if (mventry["mail"].IsPresent)
                    {
                        string _rdn = "cn=" + mventry["mail"].StringValue;

                        // check for the presence of an Remote-Address object before setting this attribute
                        bool _setAltRecipient = false;
                        foreach (ConnectedMA _cma in mventry.ConnectedMAs)
                        {
                            if (_cma.Name.Equals(csentry.MA.Name))
                            {
                                for (int i = 0; i <= _cma.Connectors.Count - 1; i++)
                                {
                                    _csentry = _cma.Connectors.ByIndex[i];
                                    if (_csentry.ObjectType.Equals("Remote-Address"))
                                    {
                                        _setAltRecipient = true;
                                    }
                                }
                            }
                        }
                        if (_setAltRecipient)
                        {
                            csentry["Alt-Recipient"].ReferenceValue = csentry.MA.EscapeDNComponent(_rdn).Concat(Properties.Settings.Default.forwarderContainer);
                        }
                    }
                    break;

                case "cd.Remote-Address:Hide-From-Address-Book<-mv.dbbStaff:":
                    // if there is an organizationalPerson connector AND a Remote-Address, the Remote-Address object
                    // needs to be hidden from the GAL
                    bool _hideFromGAL = false;
                    foreach (ConnectedMA _cma in mventry.ConnectedMAs)
                    {
                        if (_cma.Name.Equals(csentry.MA.Name))
                        {
                            for (int i = 0; i <= _cma.Connectors.Count - 1; i++)
                            {
                                _csentry = _cma.Connectors.ByIndex[i];
                                if (_csentry.ObjectType.Equals("organizationalPerson"))
                                {
                                    _hideFromGAL = true;
                                }
                            }
                        }
                    }
                    csentry["Hide-From-Address-Book"].BooleanValue = _hideFromGAL;
                    break;

				default:
					throw new EntryPointNotImplementedException();
			}
        }
	}
}
