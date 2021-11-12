
using System;
using Microsoft.MetadirectoryServices;

namespace Mms_ManagementAgent_DBB_MOSSExtension
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
		    const String DN_DELIM = "=";
            switch (FlowRuleName)
			{
				case "cd.person#1:AccountName->sAMAccountName":
                    if (csentry.DN.Depth > 1)
                    {
                        values.Add(csentry.DN[0].ToString().Split(Char.Parse(DN_DELIM))[1]);
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
            // Date formats for the UNIFY SharePoint Broker are as XML serialized dates
            // e.g. 2009-06-23T00:00:00
            switch (FlowRuleName)
			{
				case "cd.person:SPS-Birthday<-mv.dbbStaff:dateOfBirth":
                    DateTime _dob;
                    if (mventry["dateOfBirth"].IsPresent)
                    {
                        if (DateTime.TryParse(mventry["dateOfBirth"].StringValue, out _dob))
                        {
                            csentry["SPS-Birthday"].Value = System.Xml.XmlConvert.ToString(_dob, System.Xml.XmlDateTimeSerializationMode.RoundtripKind);
                        }
                    }
					break;

				default:
					throw new EntryPointNotImplementedException();
			}
        }
	}
}
