
using System;
using Microsoft.MetadirectoryServices;

namespace Mms_ManagementAgent_CAPSPayrollRE
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
            string _returnObjectType = string.Empty;
            bool _shouldProject = false;
            string _capsPin = string.Empty;
            if (AllowCAPSConnector(csentry, out _capsPin))
            {
                _returnObjectType = "dbbStaff";
                _shouldProject = true;
            }
            MVObjectType = _returnObjectType;
            return _shouldProject;
			//throw new EntryPointNotImplementedException();
		}

        DeprovisionAction IMASynchronization.Deprovision (CSEntry csentry)
        {
			throw new EntryPointNotImplementedException();
        }	

        bool IMASynchronization.FilterForDisconnection (CSEntry csentry)
        {
            throw new EntryPointNotImplementedException();
		}

        private bool AllowCAPSConnector(CSEntry csentry, out string CapsPin)
        {
            // don't join or project if disconnected as a result of an active BOPS connector (see provisioning)
            bool _allowConnector = csentry["PERS.PIN"].IsPresent;
            CapsPin = string.Empty; 
            if (_allowConnector)
            {
                CapsPin = "S" + csentry["PERS.PIN"].StringValue;
                foreach (MVEntry _mvBOPSJoiner in Utils.FindMVEntries("capsID", CapsPin))
                {
                    if (!DerivedCAPEmployeeStatus(csentry).Equals("active"))
                    {
                        _allowConnector = false;
                    }
                }
            }
            return _allowConnector;
        }

		void IMASynchronization.MapAttributesForJoin (string FlowRuleName, CSEntry csentry, ref ValueCollection values)
        {
            switch (FlowRuleName)
			{
                case "cd.person#3:ADS.ACTIVE,PERS.FTE.HRS,PERS.PIN->capsID":
                case "cd.person#3:ADS.ACTIVE,PERS.FTE.HRS,PERS.PIN->employeeID":
                    string _capsPin = string.Empty;
                    if (AllowCAPSConnector(csentry, out _capsPin))
                    {
                        values.Add(_capsPin);
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

        private string DerivedCAPEmployeeStatus(CSEntry csentry)
        {
            string _CAPSEmployeeStatus = "active";
            if (csentry["PERS.FTE.HRS"].IsPresent && csentry["PERS.FTE.HRS"].Value.Equals("0"))
            {
                _CAPSEmployeeStatus = "terminated";
            }
            else if (csentry["ADS.ACTIVE"].IsPresent && !csentry["ADS.ACTIVE"].StringValue.Equals("Y"))
            {
                _CAPSEmployeeStatus = "terminated";
            }
            return _CAPSEmployeeStatus;
        }

        void IMASynchronization.MapAttributesForImport( string FlowRuleName, CSEntry csentry, MVEntry mventry)
        {
            switch (FlowRuleName)
			{
				case "cd.person:PERS.DOB->mv.dbbStaff:dateOfBirth":
                    if (csentry["PERS.DOB"].IsPresent)
                    {
                        DateTime _dob = DateTime.Parse("31/12/1967").AddDays(Convert.ToInt32(csentry["PERS.DOB"].Value));
                        // store date in MV in XML serialized date format
                        mventry["dateOfBirth"].Value = System.Xml.XmlConvert.ToString(_dob, System.Xml.XmlDateTimeSerializationMode.RoundtripKind);
                    }
                    break;

				case "cd.person:ADS.ACTIVE,PERS.FTE.HRS->mv.dbbStaff:employeeStatus":
                    mventry["employeeStatus"].Value = DerivedCAPEmployeeStatus(csentry);
                    break;

				case "cd.person:PERS.PIN,SAL.SCHOOL->mv.dbbStaff:physicalDeliveryOfficeName":
                    if (csentry["SAL.SCHOOL"].IsPresent)
                    {
                        foreach (MVEntry _MVSite in Utils.FindMVEntries("siteID",csentry["SAL.SCHOOL"].StringValue))
                        {
                            mventry["physicalDeliveryOfficeName"].Value = _MVSite["physicalDeliveryOfficeName"].StringValue;
                            break;
                        }
                    }
                    else
                    {
                        mventry["physicalDeliveryOfficeName"].Value = Properties.Settings.Default.physicalDeliveryOfficeNameDefault;
                    }
                    break;

				case "cd.person:PERS.PREF.NAME,PERS.SURNAME->mv.dbbStaff:displayName":
                    if (csentry["PERS.PREF.NAME"].IsPresent && csentry["PERS.SURNAME"].IsPresent)
                    {
                        mventry["displayName"].Value = csentry["PERS.PREF.NAME"].Value + " " + csentry["PERS.SURNAME"].Value;
                    }
                    break;

				case "cd.person:ADS.CODE,ADS.END,ADS.START,SAL.SCHOOL->mv.dbbStaff:dbbADSCodes":
                    mventry["dbbADSCodes"].Values.Clear();
                    if (csentry["ADS.Code"].IsPresent)
                    {
                        DateTime _ADSEndDate;
                        DateTime _ADSStartDate;
                        string _ADSCodeStatus;
                        string _ADSCodeTemp;
                        string[] _ArrADSEndDate;
                        string[] _ArrADSStartDate;

                        for (int i = 0; i < csentry["ADS.Code"].Values.Count; i++)
                        {
                            _ADSCodeStatus = string.Empty;
                            _ADSCodeTemp = csentry["ADS.Code"].Values[i].ToString();

                            // check ADS Code status
                            // *** Handle incomplete sets of START DATE records ***
                            if (i < csentry["ADS.START"].Values.Count)
                            {
                                _ArrADSStartDate = csentry["ADS.START"].Values[i].ToString().Split("_".ToCharArray());
                                if (_ArrADSStartDate[1].Length > 0)
                                {
                                    _ADSStartDate = DateTime.Parse("31/12/1967").AddDays(Convert.ToInt32(_ArrADSStartDate[1]));
                                    if (_ADSStartDate > DateTime.Today)
                                    { _ADSCodeStatus = "pending"; }
                                }
                                else
                                { _ADSCodeStatus = "pending"; }
                            }
                            else throw new UnexpectedDataException("Number of items in the ADS.START value collection does not match that of the ADS.Code collection");

                            // *** Handle incomplete sets of END DATE records ***
                            if (i < csentry["ADS.END"].Values.Count)
                            {
                                _ArrADSEndDate = csentry["ADS.END"].Values[i].ToString().Split("_".ToCharArray());
                                if (_ArrADSEndDate[1].Length > 0)
                                {
                                    _ADSEndDate = DateTime.Parse("31/12/1967").AddDays(Convert.ToInt32(_ArrADSEndDate[1]));
                                    if (_ADSEndDate < DateTime.Today)
                                    { _ADSCodeStatus = "expired"; }
                                }
                            }
                            else throw new UnexpectedDataException("Number of items in the ADS.END value collection does not match that of the ADS.Code collection");

                            if (_ADSCodeStatus.Length > 0)
                            {
                                // Add nothing
                            }
                            else
                            {
                                // add raw ADS code
                                mventry["dbbADSCodes"].Values.Add(_ADSCodeTemp);
                            }
                        }
                    }
                    break;

				case "cd.person:PERS.PIN->mv.dbbStaff:employeeID":
                    if (csentry["PERS.PIN"].IsPresent)
                    {
                        mventry["employeeID"].Value = "S" + csentry["PERS.PIN"].Value;
                    }
                    break;

                case "cd.person:PERS.PIN->mv.dbbStaff:capsID":
                    if (csentry["PERS.PIN"].IsPresent)
                    {
                        mventry["capsID"].Value = "S" + csentry["PERS.PIN"].Value;
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
