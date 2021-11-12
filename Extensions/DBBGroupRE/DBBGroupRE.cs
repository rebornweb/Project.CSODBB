
using System;
using Microsoft.MetadirectoryServices;

namespace Mms_ManagementAgent_DBBGroupRE
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
            bool _result = false;
            MVObjectType = string.Empty;
            if (csentry["member"].IsPresent)
            {
                MVObjectType = "dbbGroupNested";
                _result = true;
            }
            return _result;
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
                case "cd.group:info->mv.dbbGroupNested:info":
                    mventry["info"].Value = GetIDFromInfo(csentry);
                    break;

                default:
                    throw new EntryPointNotImplementedException();
            }
        }

        private string GetIDFromInfo(CSEntry csGroup)
        {
            string _result = null;
            int _pos = -1;
            //this attribute is MV in AD, and we are only interested in the first line
            if (csGroup["info"].IsPresent)
            {
                if (csGroup["info"].Value.Contains(Environment.NewLine))
                {
                    _pos = csGroup["info"].Value.IndexOf(Environment.NewLine);
                    _result = csGroup["info"].Value.Substring(0, _pos - 1);
                }
                else
                {
                    _result = csGroup["info"].Value;
                }
            }
            return _result;
        }

        void IMASynchronization.MapAttributesForExport (string FlowRuleName, MVEntry mventry, CSEntry csentry)
        {
            throw new EntryPointNotImplementedException();
        }
	}
}
