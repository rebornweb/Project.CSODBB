
using System;
using Microsoft.MetadirectoryServices;
using System.Collections;
using SiteHelper;

namespace Mms_Metaverse
{

	/// <summary>
	/// Summary description for MVExtensionObject.
	/// </summary>
    public class MVExtensionObject : IMVSynchronization
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

        public MVExtensionObject()
        {
        }

        void IMVSynchronization.Initialize ()
        {
            _siteCache = new SiteHelper.Cache();
        }

        void IMVSynchronization.Terminate ()
        {
        }

        void IMVSynchronization.Provision (MVEntry mventry)
        {
            ConnectedMA _ManagementAgent;            // Management agent object
            int _Connectors = 0;                     // Management agent connectors
            ReferenceValue _DN = null;               // Distinguished name attribute
            string _Container = string.Empty;        // Container name
            string _RDN = string.Empty;              // Relative distinguished name strings
            CSEntry _csentry = null;                 // Connector space entry object
            string _MsExchPrivateMDB = "dummy";   // dummy value to stop CheckRequiredParameter exception
            string _ExceptionMessage = string.Empty;
            string _Password = string.Empty;      // default user password
            int _Seq = 0;
            string _sAMAccountNameAttempt = string.Empty;
            bool _isCAPSConnector = false;
            bool _isBOPSConnector = false;
            bool _isActive = false;

            // Process Provisioning for all enabled MAs
            foreach (string strMA in Properties.Settings.Default.ActiveMAs)
            {
                // Get the management agent connectors.
                _ManagementAgent = mventry.ConnectedMAs[strMA];
                _Connectors = _ManagementAgent.Connectors.Count;
                _Container = string.Empty;
                _RDN = string.Empty;
                _DN = null;

                switch (_ManagementAgent.Name)
                {

#region "CAPS Provisioning"
                    case "CAPS Payroll":
                        switch (mventry.ObjectType)
                        {
                            case "dbbStaff":
                                if (_Connectors.Equals(1))
                                {
                                    _isBOPSConnector = (mventry.ConnectedMAs["NASS"].Connectors.Count > 0);
                                    _csentry = _ManagementAgent.Connectors.ByIndex[0];
                                    _isActive = mventry["employeeStatus"].IsPresent && mventry["employeeStatus"].StringValue.ToLower().Equals("active");
                                    if (_isBOPSConnector
                                        && !_isActive
                                        && mventry["capsID"].IsPresent 
                                        && !DerivedCAPEmployeeStatus(_csentry).Equals("active"))
                                    {
                                        // need to disconnect the inactive CAPS-projected dbbStaff MV object to allow
                                        // BOPS to become authoritative
                                        _csentry.Deprovision();
                                    }
                                }
                                else if (!_Connectors.Equals(0))
                                {
                                    _ExceptionMessage = "Multiple " + mventry.ObjectType
                                        + " connectors on Management Agent "
                                        + _ManagementAgent.Name;
                                    throw new UnexpectedDataException(_ExceptionMessage);
                                }
                                break;
                        }
                        break;
#endregion

#region "NASS Provisioning"
                    case "NASS":

                        switch (mventry.ObjectType)
                        {
                            case "dbbStaff":
                                if (_Connectors.Equals(1))
                                {
                                    _isCAPSConnector = (mventry.ConnectedMAs["CAPS Payroll"].Connectors.Count > 0);
                                    _csentry = _ManagementAgent.Connectors.ByIndex[0];
                                    _isActive = mventry["employeeStatus"].IsPresent && mventry["employeeStatus"].StringValue.ToLower().Equals("active");
                                    if (_isCAPSConnector)
                                    {
                                        if (!mventry["capsID"].IsPresent)
                                        {
                                            // need to disconnect from the CAPS-projected dbbStaff MV object
                                            _csentry.Deprovision();
                                        }
                                    }
                                }
                                else if (!_Connectors.Equals(0))
                                {
                                    _ExceptionMessage = "Multiple " + mventry.ObjectType
                                        + " connectors on Management Agent "
                                        + _ManagementAgent.Name;
                                    throw new UnexpectedDataException(_ExceptionMessage);
                                }
                                break;
                        }
                        break;
#endregion

#region "DerivedADS.nestedGroup Updater Provisioning"
                    case "DerivedADS.nestedGroup Updater":
                        switch (mventry.ObjectType)
                        {
                            case "dbbStudent": //Phase 2
                            case "organizationalUnit":
                            case "dbbSite":
                            case "dbbOther":
                            case "dbbGroup":
                                break;

                            case "dbbGroupNested":
                                //Only provision a nested group if it is NOT linked to an ADS code (info attribute)
                                if (mventry["sAMAccountName"].IsPresent)
                                {
                                    _RDN = mventry["sAMAccountName"].Value;
                                    _DN = _ManagementAgent.EscapeDNComponent(_RDN);
                                    if (_Connectors.Equals(0))
                                    {
                                        if (mventry["cn"].IsPresent && !mventry["info"].IsPresent)
                                        {
                                            try
                                            {
                                                _csentry = _ManagementAgent.Connectors.StartNewConnector("groupNested");
                                                _csentry.DN = _DN;
                                                _csentry["ID"].Value = mventry["sAMAccountName"].StringValue;
                                                _csentry.CommitNewConnector();
                                            }
                                            catch (ObjectAlreadyExistsException)
                                            {
                                                // previously did nothing - now throwing the error
                                                throw;
                                            }
                                            catch (Exception ex)
                                            {
                                                throw new UnexpectedDataException(ex.Message);
                                            }
                                        }
                                    }
                                    else if (_Connectors.Equals(1))
                                    {
                                        _csentry = _ManagementAgent.Connectors.ByIndex[0];
                                        if (_csentry.ObjectType.Equals("groupNested"))
                                        {
                                            // deprovision if either the DN has changed or an ADS code is now assigned
                                            // or if this is not connected to AD (i.e. no CN present)
                                            // (if a rename then will be reprovisioned)
                                            if (!_csentry.DN.Equals(_DN) || mventry["info"].IsPresent || !mventry["cn"].IsPresent)
                                            {
                                                _csentry.Deprovision();
                                            }
                                        }
                                    }
                                    else if (1 < _Connectors)
                                    {
                                        _ExceptionMessage = "Multiple " + mventry.ObjectType
                                            + " connectors on Management Agent "
                                            + _ManagementAgent.Name;
                                        throw new UnexpectedDataException(_ExceptionMessage);
                                    }
                                }
                                break;
                        }
                        break;

#endregion

#region "DerivedADS.group Updater Provisioning"
                    case "DerivedADS.group Updater":

                        _isBOPSConnector = (mventry.ConnectedMAs["NASS"].Connectors.Count > 0);
                        _isCAPSConnector = (mventry.ConnectedMAs["CAPS Payroll"].Connectors.Count > 0);
                        switch (mventry.ObjectType)
                        {
                            case "dbbStudent": //Phase 2
                            case "organizationalUnit":
                            case "dbbSite":
                            case "dbbOther":
                            case "dbbGroupNested":
                                break;

                            case "dbbGroup":
                                if (mventry["dbbADSCode"].IsPresent && mventry["sAMAccountName"].IsPresent)
                                {
                                    _RDN = mventry["sAMAccountName"].Value; //dbbADSCode
                                    _DN = _ManagementAgent.EscapeDNComponent(_RDN);
                                    if (_Connectors.Equals(0))
                                    {
                                        _csentry = _ManagementAgent.Connectors.StartNewConnector("group");
                                        _csentry.DN = _DN;
                                        _csentry["ID"].Value = mventry["sAMAccountName"].StringValue;
                                        _csentry["BaseID"].Value = mventry["dbbADSCode"].StringValue;
                                        if (!mventry["groupType"].IsPresent)
                                        {
                                            _csentry["GroupType"].Value = "unknown";
                                        }
                                        _csentry.CommitNewConnector();
                                    }
                                    else if (_Connectors.Equals(1))
                                    {
                                        _csentry = _ManagementAgent.Connectors.ByIndex[0];
                                        if (_csentry.ObjectType.Equals("group") && !_csentry.ConnectionRule.Equals(RuleType.Join))
                                        {
                                            //TODO: revisit deprovisioning under other circumstances (e.g. renames - manual for time being)
                                        }
                                    }
                                    else if (1 < _Connectors)
                                    {
                                        _ExceptionMessage = "Multiple " + mventry.ObjectType
                                            + " connectors on Management Agent "
                                            + _ManagementAgent.Name;
                                        throw new UnexpectedDataException(_ExceptionMessage);
                                    }
                                }
                                else
                                {
                                    for (int i = _ManagementAgent.Connectors.Count - 1; i >= 0; i--)
                                    {
                                        _ManagementAgent.Connectors.ByIndex[i].Deprovision();
                                    }
                                    break;
                                }
                                break;

                            case "dbbStaff":
                                if (mventry["employeeID"].IsPresent)
                                {
                                    _RDN = mventry["employeeID"].Value;
                                    _DN = _ManagementAgent.EscapeDNComponent(_RDN);
                                    if (_Connectors.Equals(0))
                                    {
                                        // only provision if not re-joining on CapsPin!
                                        if (!RejoinBopsOnCapsID(mventry))
                                        {
                                            // ... and then only if there is either a BOPS or CAPS connector
                                            if (_isBOPSConnector || _isCAPSConnector)
                                            {
                                                _csentry = _ManagementAgent.Connectors.StartNewConnector("person");
                                                _csentry.DN = _DN;
                                                _csentry["ID"].Value = mventry["employeeID"].StringValue;
                                                _csentry["BaseID"].Value = mventry["employeeID"].StringValue;
                                                _csentry.CommitNewConnector();
                                            }
                                        }
                                    }
                                    else if (_Connectors.Equals(1))
                                    {
                                        _csentry = _ManagementAgent.Connectors.ByIndex[0];
                                        if (RejoinBopsOnCapsID(mventry))
                                        {
                                            _csentry.Deprovision();
                                        }
                                        // check that there is either a BOPS or CAPS connector, and deprovision otherwise
                                        // provided the user is not in any groups
                                        else if (!_isBOPSConnector && !_isCAPSConnector)
                                        {
                                            _csentry.Deprovision();
                                        }
                                        else if (!_isCAPSConnector
                                            && mventry["employeeID"].IsPresent
                                            && !_csentry.DN.Equals(_ManagementAgent.CreateDN(mventry["employeeID"].StringValue)))
                                        {
                                            //deprovision if employeeID has changed
                                            ArrayList _masToDisconnect = new ArrayList();
                                            foreach (ConnectedMA _conMA in mventry.ConnectedMAs)
                                            {
                                                // deprovision all except the AD connector
                                                if (!_conMA.Name.Equals("DBB")
                                                    && _conMA.Connectors.Count > 0)
                                                {
                                                    _masToDisconnect.Add(_conMA.Name);
                                                }
                                            }
                                            foreach (string _maName in _masToDisconnect)
                                            {
                                                for (int i = mventry.ConnectedMAs[_maName].Connectors.Count - 1; i >= 0; i--)
                                                {
                                                    _csentry = mventry.ConnectedMAs[_maName].Connectors.ByIndex[i];
                                                    _csentry.Deprovision();
                                                }
                                            }
                                        }
                                    }
                                    else if (1 < _Connectors)
                                    {
                                        _ExceptionMessage = "Multiple " + mventry.ObjectType
                                            + " connectors on Management Agent "
                                            + _ManagementAgent.Name;
                                        throw new UnexpectedDataException(_ExceptionMessage);
                                    }
                                }
                                else
                                {
                                    for (int i = _ManagementAgent.Connectors.Count - 1; i >= 0; i--)
                                    {
                                        _csentry = _ManagementAgent.Connectors.ByIndex[i];
                                        _csentry.Deprovision();
                                    }
                                    break;
                                }
                                break;

                            default:
                                _ExceptionMessage = "Unexpected ObjectType: " + mventry.ObjectType;
                                throw new UnexpectedDataException(_ExceptionMessage);
                        }
                        break;
#endregion

#region "Legacy Exchange - migrated mailboxes Provisioning"
                    case "Legacy Exchange - migrated mailboxes":
                        switch (mventry.ObjectType)
                        {
                            case "dbbStudent": //Phase 2
                                break;

                            case "dbbStaff":
                                // this MA needs to handle multiple connectors, so long as there is only ever
                                // one (joined, optional) mailbox object, and one (provisioned, mandatory) custom recipient
                                bool _isActiveSite = false;
                                string _forwarderContainer = string.Empty;
                                if (mventry["physicalDeliveryOfficeName"].IsPresent 
                                    && mventry["mail"].IsPresent
                                    && mventry["employeeStatus"].IsPresent)
                                {
                                    _isActiveSite = _siteCache.IsSiteActive(mventry["physicalDeliveryOfficeName"].StringValue);
                                    _forwarderContainer = _siteCache.GetSiteForwarderContainer(mventry["physicalDeliveryOfficeName"].StringValue);
                                    if ((_forwarderContainer.Length > 0) && mventry["employeeStatus"].StringValue.ToLower().Equals("active"))
                                    {
                                        _DN = _ManagementAgent.EscapeDNComponent("cn=" + mventry["mail"].StringValue).Concat(_forwarderContainer);
                                    }
                                }
                                if (_DN == null)
                                {
                                    if (_Connectors > 0)
                                    {
                                        // clear forwarder(s) no longer required
                                        for (int i = _ManagementAgent.Connectors.Count - 1; i >= 0; i--)
                                        {
                                            _csentry = _ManagementAgent.Connectors.ByIndex[i];
                                            if (_csentry.ObjectType.Equals("Remote-Address"))
                                            {
                                                _csentry.Deprovision();
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    int _numForwarders = 0;
                                    // count the number of existing forwarders
                                    for (int i = 0; i <= _ManagementAgent.Connectors.Count - 1; i++)
                                    {
                                        _csentry = _ManagementAgent.Connectors.ByIndex[i];
                                        if (_csentry.ObjectType.Equals("Remote-Address"))
                                        {
                                            _numForwarders++;
                                        }
                                    }
                                    if (_numForwarders == 0)
                                    {
                                        //provision new contact
                                        _csentry = ExchangeUtils.Create55CustomRecipient(_ManagementAgent, _DN, mventry["mail"].StringValue, mventry["mail"].StringValue, mventry["mail"].StringValue, Properties.Settings.Default.ORAddress + mventry["mail"].StringValue + ";");
                                        _csentry.CommitNewConnector();
                                    }
                                    else if (_numForwarders > 1)
                                    {
                                        // remove redundant forwarders
                                        for (int i = _ManagementAgent.Connectors.Count - 1; i >= 1; i--)
                                        {
                                            _csentry = _ManagementAgent.Connectors.ByIndex[i];
                                            if (_csentry.ObjectType.Equals("Remote-Address"))
                                            {
                                                if (_numForwarders > 1)
                                                {
                                                    _csentry.Deprovision();
                                                    _numForwarders--;
                                                }
                                            }
                                        }
                                    }
                                }
                                break;
                        }
                        break;
#endregion

#region "DBB Contacts Provisioning"
                    case "DBB Contacts":
                        switch (mventry.ObjectType)
                        {
                            case "dbbStudent": //Phase 2
                                break;

                            case "dbbStaff":
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
                                if (_contactRequired)
                                {
                                    if (_Connectors.Equals(0))
                                    {
                                        // provision SMTP forwarding address in Exchange 2003
                                        // in cases where there are multiple "otherMailbox" values, CANNOT just use the first!!!
                                        _DN = _ManagementAgent.CreateDN(mventry["altRecipient"].StringValue);
                                        string _forwardingAddress = _DN.ToString().Substring(3, _DN.ToString().IndexOf(",") - 3);
                                        _csentry = ExchangeUtils.CreateMailEnabledContact(_ManagementAgent, _DN, _forwardingAddress, _forwardingAddress);
                                        _csentry["msExchHideFromAddressLists"].BooleanValue = true;
                                        _csentry["employeeNumber"].Value = mventry["employeeID"].StringValue;
                                        _csentry.CommitNewConnector();
                                    }
                                    else if (_Connectors.Equals(1))
                                    {
                                        _csentry = _ManagementAgent.Connectors.ByIndex[0];
                                        _csentry.DN = _csentry.MA.CreateDN(mventry["altRecipient"].StringValue);
                                    }
                                    else
                                    {
                                        // delete all but the first contact
                                        for (int i = _ManagementAgent.Connectors.Count - 1; i > 0; i--)
                                        {
                                            _csentry = _ManagementAgent.Connectors.ByIndex[i];
                                            if (_csentry.ObjectType.Equals("contact"))
                                            {
                                                // clear forwarder(s) 
                                                _csentry.Deprovision();
                                            }
                                        }
                                    }
                                }
                                else if (0 < _Connectors)
                                {
                                    // delete all forwarders
                                    for (int i = _ManagementAgent.Connectors.Count - 1; i >= 0; i--)
                                    {
                                        _csentry = _ManagementAgent.Connectors.ByIndex[i];
                                        if (_csentry.ObjectType.Equals("contact"))
                                        {
                                            _csentry.Deprovision();
                                        }
                                    }
                                }
                                break;
                        }
                        break;
#endregion

#region "DBB (AD) Provisioning"
                    case "DBB":

                        if (mventry["displayName"].IsPresent)
                        {
                            switch (mventry.ObjectType)
                            {
                                case "organizationalUnit":
                                case "dbbGroupNested":
                                    break;

                                case "dbbStudent":
                                    if (_Connectors.Equals(1))
                                    {
                                        if (mventry["dbbObjectClass"].IsPresent
                                            && !mventry["dbbObjectClass"].StringValue.Equals("dbbStudent"))
                                        {
                                            _csentry = _ManagementAgent.Connectors.ByIndex[0];
                                            _csentry.Deprovision();
                                        }
                                    }
                                    else if (1 < _Connectors)
                                    {
                                        _ExceptionMessage = "Multiple " + mventry.ObjectType
                                            + " connectors on Management Agent "
                                            + _ManagementAgent.Name;
                                        throw new UnexpectedDataException(_ExceptionMessage);
                                    }
                                    break;

                                case "dbbOther":
                                    // MV class for AD users with no employeeNumber attribute
                                    if (_Connectors.Equals(1))
                                    {
                                        if (mventry["dbbObjectClass"].IsPresent
                                            && !mventry["dbbObjectClass"].StringValue.Equals("dbbOther"))
                                        {
                                            _csentry = _ManagementAgent.Connectors.ByIndex[0];
                                            _csentry.Deprovision();
                                        }
                                    }
                                    else if (1 < _Connectors)
                                    {
                                        _ExceptionMessage = "Multiple " + mventry.ObjectType
                                            + " connectors on Management Agent "
                                            + _ManagementAgent.Name;
                                        throw new UnexpectedDataException(_ExceptionMessage);
                                    }
                                    break;

                                case "dbbGroup":

                                    // If there are no connectors, create the connector, set the distinguished
                                    // name attribute, and then add the new connector to the collection.
                                    // Special case is not to reprovision immediately on a disconnect due to the info
                                    // attribute in AD being edited for a group.
                                    if (_Connectors.Equals(0) && !Utils.TransactionProperties.Contains("dbbADSCode"))
                                    {
                                        if (mventry["dbbADSCode"].IsPresent && mventry["member"].IsPresent)
                                        {
                                            // Construct the distinguished name.
                                            _Container = Properties.Settings.Default.GroupsOU;
                                            _sAMAccountNameAttempt = GetGroupSAMAccountNotInMV(mventry, _Seq);
                                            _RDN = "CN=" + _sAMAccountNameAttempt;
                                            _DN = _ManagementAgent.EscapeDNComponent(_RDN).Concat(_Container);
                                            _csentry = _ManagementAgent.Connectors.StartNewConnector("group");
                                            // commit group details
                                            _csentry.DN = _DN;
                                            _csentry["sAMAccountName"].Value = _sAMAccountNameAttempt;
                                            _csentry["info"].Value = mventry["dbbADSCode"].StringValue;
                                            _csentry["mailNickname"].Value = DeriveMailNickname(_sAMAccountNameAttempt);

                                            bool _Retry = true;
                                            while (_Retry)
                                            {
                                                try
                                                {
                                                    _csentry.CommitNewConnector();
                                                    _Retry = false;
                                                }
                                                catch (ObjectAlreadyExistsException)
                                                {
                                                    _Seq++;
                                                    _sAMAccountNameAttempt = GetGroupSAMAccountNotInMV(mventry, _Seq);
                                                    _RDN = "CN=" + _sAMAccountNameAttempt;
                                                    _DN = _ManagementAgent.EscapeDNComponent(_RDN).Concat(_Container);
                                                    _csentry.DN = _DN;
                                                    _csentry["sAMAccountName"].Value = _sAMAccountNameAttempt;
                                                    _csentry["mailNickname"].Value = DeriveMailNickname(_sAMAccountNameAttempt);
                                                }
                                                catch (Exception ex)
                                                {
                                                    _Retry = false;
                                                    throw new UnexpectedDataException(ex.Message);
                                                }
                                            }
                                        }
                                    }
                                    else if (1 <= _Connectors && Utils.TransactionProperties.Contains("dbbADSCode"))
                                    {
                                        // info has changed so need to disconnect (all) and possibly rejoin
                                        for (int i = _ManagementAgent.Connectors.Count - 1; i >= 0; i--)
                                        {
                                            _csentry = _ManagementAgent.Connectors.ByIndex[i];
                                            _csentry.Deprovision();
                                        }
                                    }
                                    else if (1 < _Connectors)
                                    {
                                        _ExceptionMessage = "Multiple " + mventry.ObjectType
                                            + " connectors on Management Agent "
                                            + _ManagementAgent.Name;
                                        throw new UnexpectedDataException(_ExceptionMessage);
                                    }
                                    break;

                                case "dbbStaff":

                                    // Construct the distinguished name.
                                    _Container = Properties.Settings.Default.StaffOU;
                                    _RDN = "CN=" + mventry["displayName"].Value;
                                    if (mventry["OrganisationName"].IsPresent)
                                    {
                                        // determine the target sub-OU based on Organisation Name
                                        if (Properties.Settings.Default.OrganisationOUs.Contains(mventry["OrganisationName"].StringValue))
                                        {
                                            _Container = "OU=" + mventry["OrganisationName"].StringValue + "," + _Container;
                                        }
                                    }
                                    _DN = _ManagementAgent.EscapeDNComponent(_RDN).Concat(_Container);

                                    // If there are no connectors, create the connector, set the distinguished
                                    // name attribute, and then add the new connector to the collection.      
                                    if (_Connectors.Equals(0))
                                    {
                                        if (mventry["employeeID"].IsPresent 
                                            && mventry["displayName"].IsPresent
                                            && mventry["employeeStatus"].IsPresent
                                            && mventry["employeeStatus"].StringValue.ToLower().Equals("active")
                                            && !RejoinBopsOnCapsID(mventry))
                                        {
                                            // commit user account details
                                            bool _Retry = true;
                                            _sAMAccountNameAttempt = GetUserSAMAccountNotInMV(mventry, _Seq);
                                            _MsExchPrivateMDB = DeriveMailbox(mventry["sn"].StringValue);
                                            while (_Retry)
                                            {
                                                try
                                                {
                                                    // generate the user's account using ExchangeUtils.CreateMailbox
                                                    if (_sAMAccountNameAttempt.Length == 0)
                                                    {
                                                        // Ensure an account is always generated regardless
                                                        _sAMAccountNameAttempt = Guid.NewGuid().ToString();
                                                    }
                                                    _csentry = ExchangeUtils.CreateMailbox(_ManagementAgent, _DN, _sAMAccountNameAttempt, _MsExchPrivateMDB);
                                                    _Retry = false;
                                                }
                                                catch (ObjectAlreadyExistsException)
                                                {
                                                    _Seq++;
                                                    _sAMAccountNameAttempt = GetUserSAMAccountNotInMV(mventry, _Seq);
                                                    _RDN = "CN=" + _sAMAccountNameAttempt;
                                                    _DN = _ManagementAgent.EscapeDNComponent(_RDN).Concat(_Container);
                                                }
                                                catch (Exception ex)
                                                {
                                                    _Retry = false;
                                                    throw new UnexpectedDataException(ex.Message);
                                                }
                                            }
                                            if (_csentry != null)
                                            {
                                                // force the following attributes for the new user account (overides attribute flow precedence)
                                                _csentry["userAccountControl"].IntegerValue = ADS_UF_NORMAL_ACCOUNT & ~ADS_UF_ACCOUNTDISABLE; // enable normal account
                                                _csentry["displayName"].Value = mventry["displayName"].StringValue;
                                                _csentry["unicodepwd"].Values.Add(InitialPassword(mventry));
                                                _csentry["pwdLastSet"].IntegerValue = 0; // force password reset on first logon
                                                _csentry["sAMAccountName"].Value = _sAMAccountNameAttempt;
                                                _csentry["userPrincipalName"].Value = _sAMAccountNameAttempt + "@" + Properties.Settings.Default.UPN;
                                                _csentry["employeeNumber"].Value = mventry["employeeID"].StringValue;
                                                _csentry.CommitNewConnector();
                                            }
                                        }
                                    }
                                    else if (_Connectors.Equals(1))
                                    {
                                        _csentry = _ManagementAgent.Connectors.ByIndex[0];
                                        if (mventry["dbbObjectClass"].IsPresent
                                            && !mventry["dbbObjectClass"].StringValue.Equals("dbbStaff"))
                                        {
                                            _csentry.Deprovision();
                                        }
                                        else if (mventry["employeeStatus"].IsPresent
                                       && !mventry["employeeStatus"].StringValue.ToLower().Equals("active"))
                                        {
                                            if (mventry["employeeID"].IsPresent)
                                            {
                                                HandleDisabledUser(_csentry, _ManagementAgent, _RDN, mventry["employeeID"].StringValue);
                                            }
                                            else
                                            {
                                                HandleDisabledUser(_csentry, _ManagementAgent, _RDN, string.Empty);
                                            }
                                        }
                                        else
                                        {
                                            if (!_csentry.DN.Equals(_DN))
                                            {
                                                // rename, if necessary forcing uniqueness within the OU
                                                bool _renameRequired = true;
                                                int _counter = 0;
                                                while (_renameRequired)
                                                {
                                                    try
                                                    {
                                                        _csentry.DN = _DN;
                                                        _renameRequired = false;
                                                    }
                                                    catch (ObjectAlreadyExistsException)
                                                    {
                                                        _counter++;
                                                        if (_counter >= Properties.Settings.Default.maxSAMAccountNameRetries)
                                                        {
                                                            _renameRequired = false;
                                                            throw new UnexpectedDataException("Account rename attempt limit exceeded");
                                                        }
                                                        _RDN = "CN=" + mventry["displayName"].Value + _counter.ToString();
                                                        _DN = _ManagementAgent.EscapeDNComponent(_RDN).Concat(_Container);
                                                    }
                                                    catch (Exception)
                                                    {
                                                        throw;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else if (1 < _Connectors)
                                    {
                                        _ExceptionMessage = "Multiple " + mventry.ObjectType
                                            + " connectors on Management Agent "
                                            + _ManagementAgent.Name;
                                        throw new UnexpectedDataException(_ExceptionMessage);
                                    }
                                    break;

                                case "dbbSite":
                                    // TODO: PHASE2: provision containers based on Organisation
                                    break;

                                default:
                                    _ExceptionMessage = "Unexpected ObjectType: " + mventry.ObjectType;
                                    throw new UnexpectedDataException(_ExceptionMessage);
                            }
                        }
                        break;
#endregion

                    default:
                        _ExceptionMessage = "Unexpected Management Agent: " + _ManagementAgent.Name;
                        throw new UnexpectedDataException(_ExceptionMessage);
                }
            }
        }

        bool IMVSynchronization.ShouldDeleteFromMV(CSEntry csentry, MVEntry mventry)
        {
            throw new EntryPointNotImplementedException();
        }

#region "Private Routines"
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

        private string GetGroupSAMAccountNotInMV(MVEntry mvGroup, int Seq)
        {
            // Generate a valid Group sAMAccountName that doesn't already exist in the MV
            bool _Retry = true;
            string _UniqueSAMAccountName = string.Empty;
            while (_Retry)
            {
                _UniqueSAMAccountName = GeneratedGroupSAMAccountName(mvGroup, Seq);
                _Retry = false;
                foreach (MVEntry mvFound in Utils.FindMVEntries("sAMAccountName", _UniqueSAMAccountName))
                {
                    // only process groups, and only those which are not for the same group being processed
                    // (e.g. in a delete/recreate scenario, or a rename)
                    if (mvFound.ObjectType.Equals("dbbGroup") && !(mvGroup.Equals(mvFound)))
                    {
                        _Retry = true;
                        Seq++;
                    }
                }
            }
            return _UniqueSAMAccountName;
        }

        private string GeneratedGroupSAMAccountName(MVEntry mvGroup, int Seq)
        {
            // Generate a valid Group sAMAccountName 
            string _SamAccountName = mvGroup["displayName"].StringValue;
            _SamAccountName = GetSafeSAMAccountName(_SamAccountName, false);
            // truncate samAccountName if too long
            if (_SamAccountName.Length >= Properties.Settings.Default.maxSAMAccountNameLength - 2)
            {
                _SamAccountName = _SamAccountName.Substring(0, Properties.Settings.Default.maxSAMAccountNameLength - 2);
            }
            if (Seq > 0)
            {
                // make sure sequence number can be appended without exceeding the string length
                while (_SamAccountName.Length + Seq.ToString().Length > Properties.Settings.Default.maxSAMAccountNameLength - 2)
                {
                    _SamAccountName = _SamAccountName.Substring(0, _SamAccountName.Length - 1);
                }
                _SamAccountName = _SamAccountName + Seq.ToString();
            }
            if (!_SamAccountName.ToUpper().EndsWith("-G"))
            {
                _SamAccountName += "-G";
            }
            return _SamAccountName;
        }

        private string GetUserSAMAccountNotInMV(MVEntry mvUser, int Seq)
        {
            // Generate a valid User sAMAccountName that doesn't already exist in the MV
            bool _Retry = true;
            string _UniqueSAMAccountName = string.Empty;
            while (_Retry)
            {
                _UniqueSAMAccountName = GeneratedUserSAMAccountName(mvUser, Seq);
                _Retry = false;
                foreach (MVEntry mvFound in Utils.FindMVEntries("sAMAccountName", _UniqueSAMAccountName))
                {
                    // only process groups, and only those which are not for the same group being processed
                    // (e.g. in a delete/recreate scenario, or a rename)
                    if ((mvFound.ObjectType.Equals("dbbStaff") 
                        || mvFound.ObjectType.Equals("dbbStudent")
                        || mvFound.ObjectType.Equals("dbbOther"))
                         && !(mvUser.Equals(mvFound)))
                    {
                        _Retry = true;
                        Seq++;
                    }
                }
            }
            return _UniqueSAMAccountName;
        }

        private string GeneratedUserSAMAccountName( MVEntry mvUser, int Seq)
        {
            // Generate a valid User sAMAccountName 
            string _SamAccountName = string.Empty;

            if (Seq < Properties.Settings.Default.maxSAMAccountNameRetries)
            {
                if (mvUser["givenName"].IsPresent && mvUser["sn"].IsPresent)
                {
                    _SamAccountName = mvUser["givenName"].StringValue + "." + mvUser["sn"].StringValue;
                    _SamAccountName = GetSafeSAMAccountName(_SamAccountName, true);
                    // truncate samAccountName if too long
                    if (_SamAccountName.Length >= Properties.Settings.Default.maxSAMAccountNameLength)
                    {
                        _SamAccountName = _SamAccountName.Substring(0, Properties.Settings.Default.maxSAMAccountNameLength);
                    }
                    // don't end in a "."
                    if (_SamAccountName.EndsWith("."))
                    {
                        _SamAccountName = _SamAccountName.Substring(0, _SamAccountName.Length - 1);
                    }
                }
                else
                {
                    throw new UnexpectedDataException("AccountName cannot be generated when Surname and/or PreferredName are missing.");
                }

                if (Seq > 0)
                {
                    // make sure sequence number can be appended without exceeding the string length
                    while (_SamAccountName.Length + Seq.ToString().Length > Properties.Settings.Default.maxSAMAccountNameLength)
                    {
                        _SamAccountName = _SamAccountName.Substring(0, _SamAccountName.Length - 1);
                    }
                    _SamAccountName = _SamAccountName + Seq.ToString();
                }
            }
            return _SamAccountName;
        }

        private string GetSafeSAMAccountName(string sAMAccountName, bool IsUser)
        {
            // convert to lower case
            string _SamAccountName = sAMAccountName;
            char[] arrInvalidChar = "/\\[]:;|=,+*?<>@\"~".ToCharArray();
            // filter invalid username characters /\[]:;|=,+*?<>@" plus any other undesirables
            _SamAccountName = _SamAccountName.Replace("`", "'");
            if (IsUser)
            {
                _SamAccountName = sAMAccountName.ToLower();
                arrInvalidChar = "/\\[]:;|=,+*?<>@\"~ ".ToCharArray();
            }
            if (_SamAccountName.IndexOfAny(arrInvalidChar) >= 0)
            {
                foreach (char charInvalidChar in arrInvalidChar)
                { _SamAccountName = _SamAccountName.Replace(charInvalidChar.ToString(), ""); }
            }
            return _SamAccountName;
        }

        private void HandleDisabledUser(CSEntry csDisabledUser, ConnectedMA MA, string RDN, string EmployeeID)
        {
            // move to disabled users OU
            bool _Success = false;
            while (!_Success)
            {
                try
                {
                    csDisabledUser.DN = MA.EscapeDNComponent(RDN).Concat(Properties.Settings.Default.DisabledUserAccountsOU);
                    _Success = true;
                }
                catch (ObjectAlreadyExistsException ex)
                {
                    if (EmployeeID.Length == 0)
                    {
                        throw ex;
                    }
                    else
                    {
                        RDN += "(" + EmployeeID + ")";
                    }
                }
                catch (Exception)
                {

                    throw;
                }
            }
        }

        private string InitialPassword(MVEntry mvUser)
        {
            // Generate an initial password
            String _Password = string.Empty;
            if (mvUser["dateOfBirth"].IsPresent)
            {
                DateTime dtDateOfBirth = DateTime.Parse(mvUser["dateOfBirth"].StringValue);
                _Password = dtDateOfBirth.Day.ToString("0#");
                _Password += dtDateOfBirth.Month.ToString("0#");
                _Password += dtDateOfBirth.Year.ToString();
            }
            else
            {
                _Password = Properties.Settings.Default.defaultUserPassword;
            }
            return _Password;
        }

        private bool RejoinBopsOnCapsID(MVEntry mvCommonUser)
        {
            // return true if BOPS user is to rejoin on (foreign) CAPS ID
            bool _result = false;
            if (mvCommonUser["CapsID"].IsPresent && mvCommonUser["employeeID"].IsPresent)
            {
                if (mvCommonUser["employeeID"].Value.StartsWith("B"))
                {
                    _result = true;
                }
            }
            return _result;
        }

        private String DeriveMailbox(String NameToDeriveMailboxSelection)
        {
            // Derive _MsExchPrivateMDB
            String _MsExchPrivateMDB = string.Empty;
            int intLowerChar = 0;
            int intUpperChar = 0;
            int intSnChar = Convert.ToInt16(Convert.ToChar(NameToDeriveMailboxSelection.Substring(0, 1).ToLower()));
            foreach (string strDN in Properties.Settings.Default.ExchangeMBXDNs)
            {
                intLowerChar = Convert.ToInt16(Convert.ToChar(strDN.Substring(strDN.IndexOf("(") + 1, 1).ToLower()));
                intUpperChar = Convert.ToInt16(Convert.ToChar(strDN.Substring(strDN.IndexOf(")") - 1, 1).ToLower()));
                if (intSnChar >= intLowerChar && intSnChar <= intUpperChar)
                {
                    _MsExchPrivateMDB = strDN;
                    break;
                }
            }
            return _MsExchPrivateMDB;
        }

        private String DeriveMailNickname(String sAMAccountName)
        {
            return sAMAccountName.Replace("-G", string.Empty).Replace(" ", string.Empty);
        }
#endregion
    }
}
