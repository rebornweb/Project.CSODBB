
using System;
using Microsoft.MetadirectoryServices;

namespace Mms_ManagementAgent_DBBContactRE
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
            bool _ShouldProject = false;
            MVObjectType = string.Empty;
            switch (csentry.ObjectType)
            {
                case ("contact"):
                    if (csentry["employeeNumber"].IsPresent)
                    {
                        if (!csentry["employeeNumber"].StringValue.ToLower().StartsWith("s") && !csentry["employeeNumber"].StringValue.ToLower().StartsWith("b"))
                        {
                            // TODO: Phase 2
                            //MVObjectType = "dbbStudent";
                            //ShouldProject = true;
                        }
                        else
                        {
                            MVObjectType = "dbbStaff";
                            _ShouldProject = true;
                        }
                    }
                    break;

                default:
                    throw new EntryPointNotImplementedException();
            }
            return _ShouldProject;
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
            switch (FlowRuleName)
            {
                case "cd.contact#4:mail->otherMailbox":
                    if (csentry["mail"].IsPresent)
                    {
                        ReferenceValue _rdn = csentry.MA.EscapeDNComponent("CN=" + csentry["mail"].StringValue);
                        string _otherMailbox = _rdn.Concat(csentry.DN.Subcomponents(1, csentry.DN.Depth)).ToString();
                        values.Add(_otherMailbox);
                    }
                   
                    break;

                default:
                    throw new EntryPointNotImplementedException();
            }
        }

        bool IMASynchronization.ResolveJoinSearch (string joinCriteriaName, CSEntry csentry, MVEntry[] rgmventry, out int imventry, ref string MVObjectType)
        {
            throw new EntryPointNotImplementedException();
		}

        void IMASynchronization.MapAttributesForImport( string FlowRuleName, CSEntry csentry, MVEntry mventry)
        {
            throw new EntryPointNotImplementedException();
        }

        void IMASynchronization.MapAttributesForExport (string FlowRuleName, MVEntry mventry, CSEntry csentry)
        {
            switch (FlowRuleName)
            {
                case "cd.contact:displayName<-mv.dbbStaff:altRecipient":
                    if (mventry["altRecipient"].IsPresent)
                    {
                        ReferenceValue _dn = csentry.MA.CreateDN(mventry["altRecipient"].StringValue);
                        csentry["displayName"].Value = _dn.Subcomponents(0, 1).ToString().Split('=')[1];
                    }
                    break;

                default:
                    throw new EntryPointNotImplementedException();
            }
        }
	}
}
