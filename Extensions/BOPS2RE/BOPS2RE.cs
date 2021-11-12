
using System;
using Microsoft.MetadirectoryServices;

namespace Mms_ManagementAgent_BOPS2RE
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
            string _objectType = string.Empty;
            switch (csentry.ObjectType)
            {
                case "person":
                    if (!csentry["CapsPin"].IsPresent)
                    {
                        _objectType = "dbbStaff";
                        _ShouldProject = true;
                    }
                    break;
                default:
                    throw new EntryPointNotImplementedException();
            }
            MVObjectType = _objectType;
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
                case "cd.person#3:CapsPin->employeeID":
                    if (csentry["CapsPin"].IsPresent)
                    {
                        values.Add(csentry["CapsPin"].StringValue);
                    }
                    break;

                case "cd.person#3:ID->employeeID":
                    if (csentry["ID"].IsPresent)
                    {
                        values.Add(csentry["ID"].StringValue);
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
            switch (FlowRuleName)
			{
                case "cd.person:DOB->mv.dbbStaff:dateOfBirth":
                    if (csentry["DOB"].IsPresent)
                    {
                        DateTime _dob = DateTime.Parse(csentry["DOB"].StringValue);
                        // store date in MV in XML serialized date format
                        mventry["dateOfBirth"].Value = System.Xml.XmlConvert.ToString(_dob, System.Xml.XmlDateTimeSerializationMode.RoundtripKind);
                    }
                    break;

                case "cd.person:PositionLocation->mv.dbbStaff:physicalDeliveryOfficeName":
                    if (csentry["PositionLocation"].IsPresent)
                    { mventry["physicalDeliveryOfficeName"].Value = csentry["PositionLocation"].StringValue; }
                    else
                    { mventry["physicalDeliveryOfficeName"].Value = Properties.Settings.Default.physicalDeliveryOfficeNameDefault; }
                    break;

                case "cd.person:PreferredName,Surname->mv.dbbStaff:displayName":
                    if (csentry["PreferredName"].IsPresent && csentry["Surname"].IsPresent)
                    {
                        mventry["displayName"].Value = csentry["PreferredName"].Value + " " + csentry["Surname"].Value;
                    }
                    break;

                case "cd.person:CapsPin->mv.dbbStaff:capsID":
                    string _capsPin = string.Empty;
                    if (csentry["CapsPin"].IsPresent)
                    {
                        _capsPin = csentry["CapsPin"].StringValue;
                        mventry["capsID"].Value = _capsPin;
                    }
                    else if (mventry["capsID"].IsPresent)
                    {
                        // ensure the BOPS connector is discconnected from the CAPS-projected record
                        // i.e. trigger a provisioning disconnect BOPS connector if previously connected on CAPSID FK
                        mventry["capsID"].Delete();
                    }
                    break;

                case "cd.person:EmployeeStatus->mv.dbbStaff:employeeStatus":
                    if (csentry["EmployeeStatus"].IsPresent)
                    {
                        mventry["employeeStatus"].StringValue = csentry["EmployeeStatus"].Value.ToLower();
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
