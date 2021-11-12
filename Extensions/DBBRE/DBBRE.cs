
using System;
using Microsoft.MetadirectoryServices;
using SiteHelper;

namespace Mms_ManagementAgent_DBBRE
{
    /// <summary>
    /// Summary description for MAExtensionObject.
	/// </summary>
	public class MAExtensionObject : IMASynchronization
	{
        const long ADS_UF_SCRIPT = 0x0001;                          // The logon script will be executed
        const long ADS_UF_ACCOUNTDISABLE = 0x0002;                  // Disable user account
        const long ADS_UF_HOMEDIR_REQUIRED = 0x0008;                // Requires a root directory
        const long ADS_UF_LOCKOUT = 0x0010;                         // Account is locked out
        const long ADS_UF_PASSWD_NOTREQD = 0x0020;                  // No password is required
        const long ADS_UF_PASSWD_CANT_CHANGE = 0x0040;              // The user cannot change the password
        const long ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED = 0x0080; // Encrypted password allowed
        const long ADS_UF_TEMP_DUPLICATE_ACCOUNT = 0x0100;          // Local user account
        const long ADS_UF_NORMAL_ACCOUNT = 0x0200;                  // Typical user account

        SiteHelper.Cache _siteCache;

		public MAExtensionObject()
		{
        }
		
        void IMASynchronization.Initialize ()
		{
            _siteCache = new SiteHelper.Cache();
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
                case ("organizationalUnit"):
                    if (csentry.DN.ToString().EndsWith(Properties.Settings.Default.StaffOU))
                    {
                        MVObjectType = "organizationalUnit";
                        _ShouldProject = true;
                    }
                    break;

                case ("group"):
                    if (csentry["info"].IsPresent && csentry["info"].Value.Length <= Properties.Settings.Default.maxInfoStringLength)
                    {
                        // info is freeform in AD so we need to ensure that only valid looking but unmatched values are projected
                        // (i.e. don't allow a second AD Connector)
                        if (!IsADConnector("info", GetIDFromInfo(csentry), "dbbGroup"))
                        {
                            MVObjectType = "dbbGroup";
                            _ShouldProject = true;
                        }
                    }
                    break;

                case ("user"):
                    if (csentry["employeeNumber"].IsPresent)
                    {
                        if (csentry["employeeNumber"].StringValue.ToLower().StartsWith("s")
                            || csentry["employeeNumber"].StringValue.ToLower().StartsWith("b"))
                        {
                            MVObjectType = "dbbStaff";
                            _ShouldProject = true;
                        }
                        else
                        {
                            // Default for employeeNumber present
                            MVObjectType = "dbbStudent";
                            _ShouldProject = true;
                        }
                    }
                    else
                    {
                        // Default
                        MVObjectType = "dbbOther";
                        _ShouldProject = true;
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

        private bool IsADConnector(string mvAttribute, string mvValue, string mvObjectType)
        {
            bool _isADConnector = false;
            foreach (MVEntry mvMatch in Utils.FindMVEntries(mvAttribute,mvValue))
            {
                if (mvMatch.ObjectType.Equals(mvObjectType))
                {
                    if (mvMatch.ConnectedMAs["DBB"].Connectors.Count > 0)
                    {
                        _isADConnector = true;
                        break;
                    }
                }
            }
            return _isADConnector;
        }

		void IMASynchronization.MapAttributesForJoin (string FlowRuleName, CSEntry csentry, ref ValueCollection values)
        {
            switch (FlowRuleName)
            {
                case ("cd.organizationalUnit#2:ou->ou"):
                    if (csentry.DN.ToString().EndsWith(Properties.Settings.Default.StaffOU))
                    {
                        values.Add(csentry["ou"].StringValue);
                    }
                    break;

                case "cd.group#3:info->dbbADSCode":
                    // Don't allow a second AD Connector
                    if (csentry["info"].IsPresent)
                    {
                        if (!IsADConnector("dbbADSCode", GetIDFromInfo(csentry), "dbbGroup"))
                        {
                            values.Add(GetIDFromInfo(csentry));
                        }
                    }
                    break;

                case ("cd.group#3:info,sAMAccountName->sAMAccountName"):
                    // don't allow join on sAMAccountName if info attribute is set to something that failed
                    // the first join rule
                    if (!csentry["info"].IsPresent)
                    {
                        // also, don't allow a second AD Connector
                        if (!IsADConnector("sAMAccountName",csentry["sAMAccountName"].Value,"dbbGroup"))
                        {
                            values.Add(csentry["sAMAccountName"].Value);
                        }
                    }
                    break;

                case "cd.user#3:employeeNumber,physicalDeliveryOfficeName->employeeID":
                    if (csentry["employeeNumber"].IsPresent
                        && csentry["physicalDeliveryOfficeName"].IsPresent
                        && _siteCache.IsSiteMOE(csentry["physicalDeliveryOfficeName"].StringValue))
                    {
                        // only join if an account from a MOE site
                        values.Add(csentry["employeeNumber"].Value);
                    }
                    break;

                case "cd.user#3:employeeNumber,sAMAccountName->sAMAccountName":
                    if (!csentry["employeeNumber"].IsPresent)
                    {
                        values.Add(csentry["sAMAccountName"].Value);
                    }
                    break;

                default:
                    throw new EntryPointNotImplementedException();
            }
        }

        bool IMASynchronization.ResolveJoinSearch (
            string joinCriteriaName, 
            CSEntry csentry, 
            MVEntry[] rgmventry, 
            out int imventry, 
            ref string MVObjectType)
        {
            throw new EntryPointNotImplementedException();
		}

        private string GetIDFromInfo(CSEntry csGroup)
        {
            string _result = null;
            int _pos = -1;
            // this attribute is MV in AD, and we are only interested in the first line
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

        void IMASynchronization.MapAttributesForImport( string FlowRuleName, CSEntry csentry, MVEntry mventry)
        {
            string _adsCode = string.Empty;
            switch (FlowRuleName)
            {
                case "cd.group:info->mv.dbbGroup:uid":
                    _adsCode = GetIDFromInfo(csentry);
                    mventry["uid"].Value = _adsCode;
                    break;

                case "cd.group:info->mv.dbbGroup:dbbADSCode":
                    _adsCode = GetIDFromInfo(csentry);
                    mventry["dbbADSCode"].Value = _adsCode;
                    break;

                case "cd.group:info->mv.dbbGroup:info":
                    _adsCode = GetIDFromInfo(csentry);
                    if (mventry["info"].IsPresent && !_adsCode.Equals(mventry["info"].StringValue))
                    {
                        // cause disconnect if info changes
                        Utils.TransactionProperties.Add("dbbADSCode", _adsCode);
                    }
                    mventry["info"].Value = _adsCode;
                    break;

                case "cd.organizationalUnit:<dn>->mv.organizationalUnit:parentOU":
                    if (csentry.DN.Depth > 1)
                    {
                        mventry["parentOU"].Value = csentry.DN.Subcomponents(1, 2).ToString();
                    }
                    break;

                case "cd.user:altRecipient->mv.dbbStaff:altRecipient":
                    mventry["altRecipient"].Values.Clear();
                    if (csentry["altRecipient"].IsPresent)
                    {
                        mventry["altRecipient"].Value = csentry["altRecipient"].ReferenceValue.ToString();
                    }
                    break;

                case "cd.user:employeeNumber->mv.dbbStaff:dbbObjectClass":
                case "cd.user:employeeNumber->mv.dbbStudent:dbbObjectClass":
                case "cd.user:employeeNumber->mv.dbbOther:dbbObjectClass":
                    if (csentry["employeeNumber"].IsPresent)
                    {
                        if (csentry["employeeNumber"].StringValue.ToLower().StartsWith("s")
                            || csentry["employeeNumber"].StringValue.ToLower().StartsWith("b"))
                        {
                            mventry["dbbObjectClass"].Value = "dbbStaff";
                        }
                        else
                        {
                            mventry["dbbObjectClass"].Value = "dbbStudent";
                        }
                    }
                    else
                    {
                        mventry["dbbObjectClass"].Value = "dbbOther";
                    }
                    break;

                case "cd.user:userAccountControl->mv.dbbStaff:employeeStatus":
                    if (csentry["userAccountControl"].IsPresent)
                    {
                        switch (csentry["userAccountControl"].IntegerValue)
                        {
                            case ADS_UF_NORMAL_ACCOUNT & ~ADS_UF_ACCOUNTDISABLE:
                                mventry["employeeStatus"].Value = "active";
                                break;

                            default:
                                mventry["employeeStatus"].Value = "terminated";
                                break;
                        }
                    }
                    break;

                default:
                    throw new EntryPointNotImplementedException();
            }
        }

        private bool IsContactRequired(MVEntry mventry)
        {
            bool _contactRequired = mventry["altRecipient"].IsPresent
                && mventry["employeeStatus"].IsPresent
                && mventry["employeeStatus"].StringValue.ToLower().Equals("active");
            bool _isActiveSite = false;
            if (mventry["physicalDeliveryOfficeName"].IsPresent)
            {
                _isActiveSite = _siteCache.IsSiteActive(mventry["physicalDeliveryOfficeName"].StringValue);
                if (_contactRequired)
                {
                    // only require contacts for inactive sites
                    _contactRequired = !_isActiveSite;
                }
            }
            return _contactRequired;
        }

        void IMASynchronization.MapAttributesForExport (string FlowRuleName, MVEntry mventry, CSEntry csentry)
        {
            string _sAMAccountName = string.Empty;
            string _physicalDeliveryOfficeName = string.Empty;

            switch (FlowRuleName)
            {

                case "cd.user:altRecipient<-mv.dbbStaff:altRecipient,employeeStatus,physicalDeliveryOfficeName":
                    if (mventry["altRecipient"].IsPresent && IsContactRequired(mventry))
                    {
                        csentry["altRecipient"].ReferenceValue = csentry.MA.CreateDN(mventry["altRecipient"].StringValue);
                    }
                    else
                    { 
                        csentry["altRecipient"].Delete(); 
                    }
                    break;

                case "cd.user:extensionAttribute6<-mv.dbbStaff:altRecipient,employeeStatus,physicalDeliveryOfficeName":
                    if (mventry["altRecipient"].IsPresent && IsContactRequired(mventry))
                    {
                        ReferenceValue _dn = csentry.MA.CreateDN(mventry["altRecipient"].StringValue);
                        csentry["extensionAttribute6"].Value = _dn.Subcomponents(0, 1).ToString().Split('=')[1].ToLower();
                    }
                    else
                    {
                        csentry["extensionAttribute6"].Delete();
                    }
                    break;

                case "cd.user:extensionAttribute14<-mv.dbbStaff:dbbADSCodes":
                    csentry["extensionAttribute14"].Delete();
                    if (mventry["dbbADSCodes"].IsPresent)
                    {
                        foreach (Value vADSCode in mventry["dbbADSCodes"].Values)
                        {
                            foreach (string strEduADSCodePrefix in Properties.Settings.Default.eduADSCodePrefixes)
                            {
                                if (vADSCode.ToString().IndexOf(strEduADSCodePrefix) == 0)
                                { 
                                    csentry["extensionAttribute14"].StringValue = "edu";
                                    break;
                                }
                            }
                        }
                    }
                    break;

                case "cd.user:profilePath<-mv.dbbStaff:physicalDeliveryOfficeName,sAMAccountName":
                    if (mventry["sAMAccountName"].IsPresent)
                    {
                        _sAMAccountName = mventry["sAMAccountName"].StringValue;
                    }
                    if (mventry["physicalDeliveryOfficeName"].IsPresent)
                    {
                        _physicalDeliveryOfficeName = mventry["physicalDeliveryOfficeName"].StringValue.ToLower();
                    }
                    //csentry["profilePath"].Delete();
                    string _profilePathLoc = string.Empty;
                    bool _isSiteMoe = false;
                    if (_physicalDeliveryOfficeName.Length > 0)
                    {
                        _profilePathLoc = _siteCache.ProfilePathLoc(_physicalDeliveryOfficeName);
                        _isSiteMoe = _siteCache.IsSiteMOE(_physicalDeliveryOfficeName);
                        if (_isSiteMoe && (_profilePathLoc.Length > 0))
                        {
                            csentry["profilePath"].Value = "\\\\dbb\\";
                            csentry["profilePath"].Value += _profilePathLoc.ToLower();
                            csentry["profilePath"].Value += "\\Profiles\\";
                            csentry["profilePath"].Value += _sAMAccountName;
                        }
                    }
                    break;

                case "cd.user:extensionAttribute9<-mv.dbbStaff:physicalDeliveryOfficeName,sAMAccountName":
                    if (mventry["sAMAccountName"].IsPresent)
                    {
                        _sAMAccountName = mventry["sAMAccountName"].StringValue;
                    }
                    if (mventry["physicalDeliveryOfficeName"].IsPresent)
                    {
                        _physicalDeliveryOfficeName = mventry["physicalDeliveryOfficeName"].StringValue.ToLower();
                    }
                    csentry["extensionattribute9"].Delete();
                    if (_physicalDeliveryOfficeName.Length > 0)
                    {
                        csentry["extensionattribute9"].Value = "\\\\dbb\\" + _physicalDeliveryOfficeName + "\\users\\" + _sAMAccountName + "\\My Documents";
                    }
                    break;

                case "cd.user:userAccountControl<-mv.dbbStaff:employeeStatus":
                    long currentValue = ADS_UF_NORMAL_ACCOUNT;
                    string newValue = string.Empty;
                    if (csentry["userAccountControl"].IsPresent)
                    {
                        currentValue = csentry["userAccountControl"].IntegerValue;
                    }
                    if (mventry["employeeStatus"].IsPresent)
                    {
                        newValue = mventry["employeeStatus"].Value.ToLower();
                    }
                    switch (newValue)
                    {
                        case "terminated": //NASS or CAPS
                            csentry["userAccountControl"].IntegerValue = currentValue
                                | ADS_UF_ACCOUNTDISABLE;
                            break;
                        default:
                            csentry["userAccountControl"].IntegerValue = (currentValue 
                                | ADS_UF_NORMAL_ACCOUNT)
                                & ~ADS_UF_ACCOUNTDISABLE;
                            break;
                    }
                    break;

                case "cd.user:employeeNumber<-mv.dbbStaff:dbbObjectClass,employeeID":
                    if (mventry["employeeID"].IsPresent)
                    {
                        // only write back employeeNumber if the object class matches
                        if (mventry["dbbObjectClass"].IsPresent && !mventry["dbbObjectClass"].StringValue.ToLower().Equals(mventry.ObjectType.ToLower()))
                        {
                            // do nothing
                        }
                        else
                        {
                            csentry["employeeNumber"].Value = mventry["employeeID"].StringValue;
                        }
                    }
                    break;

                default:
                    throw new EntryPointNotImplementedException();
            }
        }
	}
}
