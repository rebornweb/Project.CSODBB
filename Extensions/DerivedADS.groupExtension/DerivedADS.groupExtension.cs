
using System;
using Microsoft.MetadirectoryServices;

namespace Mms_ManagementAgent_DerivedADS_groupExtension
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
                case "cd.group:member->mv.dbbGroup:memberLookup":
                    mventry["memberLookup"].Values.Clear();
                    foreach (Value valMember in csentry["member"].Values)
                    {
                        mventry["memberLookup"].Values.Add(valMember.ToString());
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
