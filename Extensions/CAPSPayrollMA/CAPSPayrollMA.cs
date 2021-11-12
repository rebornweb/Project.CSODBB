using System;
using System.IO;
using System.Xml;
using System.Text;
using System.Collections;
using System.Collections.Specialized;
using Microsoft.MetadirectoryServices;
using System.Data;
using IBMU2.UODOTNET;

namespace CAPSPayrollMA
{
    /// <summary>
    /// MIIS 2003 Extensible Connectivity Management Agent for CAPS Payroll.
    /// Developed by Commander Infrastructure Solutions 2006-2007.
    /// </summary>
    public class CAPSPayroll : IMAExtensibleFileImport, IMAExtensibleFileExport
    {
        private const string PARAM_ACCOUNT = "account";
        private const string PARAM_SERVICE = "service";
        private const string PARAM_PERSONTABLE = "personTable";
        private const string PARAM_ADSTABLE = "adsTable";
        private const string PARAM_PAYROLLTITLESTABLE = "payrollTitlesTable";
        private const string PARAM_RELOADFILEPATH = "reload file path";
        private const string VAR_OBJECTTYPE = "ObjectType";
        private const string VAR_OBJECTTYPEPERSON = "person";
        private const string VAR_OBJECTTYPEGROUP = "group";

        private string _reloadExistingFilePath = string.Empty;
        private string _account = "CSOBB";
        private string _service = "uvcs";
        private string _personTable = "PAPERSONAL";
        private string _adsTable = "PAADSCODES"; //PASUBJECTS
        private string _payrollTitlesTable = "PACLASSN";
        private string _anchorColumn = "ID";

        #region Private

        private void ValidateConfiguration( 
            ConfigParameterCollection configParameters, 
            bool blnFullImport, 
            TypeDescriptionCollection tdObjectTypes  
        )
        {
            // validate the operating environment is supported by this MA.
            if (!blnFullImport)
            { throw new TerminateRunException("This MA only supports full import"); }

            //if (tdObjectTypes.Count > 1)
            //{ throw new TerminateRunException("This MA only supports one object type of 'person'"); }

            if (tdObjectTypes[VAR_OBJECTTYPEPERSON].Attributes.Count == 0)
            { throw new TerminateRunException("No attributes in schema definition for the person object, please configure this MA correctly as per instructions"); }
            else if (tdObjectTypes[VAR_OBJECTTYPEPERSON].Attributes.Count == 0)
            { throw new TerminateRunException("Multiple column anchor attributes are not supported"); }

            if (tdObjectTypes[VAR_OBJECTTYPEGROUP].Attributes.Count == 0)
            { throw new TerminateRunException("No attributes in schema definition for the group object, please configure this MA correctly as per instructions"); }
            else if (tdObjectTypes[VAR_OBJECTTYPEGROUP].Attributes.Count == 0)
            { throw new TerminateRunException("Multiple column anchor attributes are not supported"); }

            try
            {
                if (configParameters[PARAM_ACCOUNT].Value.Length > 0)
                {
                    _account = configParameters[PARAM_ACCOUNT].Value;
                }
            }
            catch (Microsoft.MetadirectoryServices.NoSuchParameterException)
            {
                // ignore - use default account
            }
            catch (Exception)
            {
                throw;
            }

            try
            {
                if (configParameters[PARAM_SERVICE].Value.Length > 0)
                {
                    _service = configParameters[PARAM_SERVICE].Value;
                }
            }
            catch (Microsoft.MetadirectoryServices.NoSuchParameterException)
            {
                // ignore - use default service
            }
            catch (Exception)
            {
                throw;
            }

            try
            {
                if (configParameters[PARAM_RELOADFILEPATH].Value.Length > 0)
                {
                    _reloadExistingFilePath = configParameters[PARAM_RELOADFILEPATH].Value;
                }
            }
            catch (Microsoft.MetadirectoryServices.NoSuchParameterException)
            {
                // ignore - create new file
            }
            catch (Exception)
            {
                throw;
            }

            try
            {
                if (configParameters[PARAM_PERSONTABLE].Value.Length > 0)
                {
                    _personTable = configParameters[PARAM_PERSONTABLE].Value;
                }
            }
            catch (Microsoft.MetadirectoryServices.NoSuchParameterException)
            {
                // ignore - use default person table
            }
            catch (Exception)
            {
                throw;
            }

            try
            {
                if (configParameters[PARAM_ADSTABLE].Value.Length > 0)
                {
                    _adsTable = configParameters[PARAM_ADSTABLE].Value;
                }
            }
            catch (Microsoft.MetadirectoryServices.NoSuchParameterException)
            {
                // ignore - use default ADS table
            }
            catch (Exception)
            {
                throw;
            }

            try
            {
                if (configParameters[PARAM_PAYROLLTITLESTABLE].Value.Length > 0)
                {
                    _payrollTitlesTable = configParameters[PARAM_PAYROLLTITLESTABLE].Value;
                }
            }
            catch (Microsoft.MetadirectoryServices.NoSuchParameterException)
            {
                // ignore - use default payroll titles table
            }
            catch (Exception)
            {
                throw;
            }

            foreach (AttributeDescription ad in tdObjectTypes[VAR_OBJECTTYPEGROUP].AnchorAttributes)
            {
                _anchorColumn = ad.Name;
                // anchor name must be common to both person and group objects:
                if (tdObjectTypes[VAR_OBJECTTYPEPERSON].AnchorAttributes[_anchorColumn].Equals(null))
                {
                    throw new TerminateRunException("Anchor attributes must be common for all ObjectTypes");
                }
                break;
            }

            bool _isMultipleMultiValueAttributes = false;
            foreach (AttributeDescription ad in tdObjectTypes[VAR_OBJECTTYPEGROUP].Attributes)
            {
                // anchor name must be common to both person and group objects:
                if (tdObjectTypes[VAR_OBJECTTYPEPERSON].Attributes[ad.Name].IsMultiValued)
                {
                    if (_isMultipleMultiValueAttributes)
                    {
                        throw new TerminateRunException("Multiple multi value attributes not supported for Object Type " + VAR_OBJECTTYPEGROUP);
                    }
                    _isMultipleMultiValueAttributes = true;
                }
                break;
            }
        }

        private System.Type ConvertAttribToSystemType(AttributeType convColumn)
        {
            System.Type _return = System.Type.GetType("System.String");
            switch (convColumn)
            {
                case AttributeType.Binary:
                    _return = System.Type.GetType("System.Object");
                    break;
                case AttributeType.Boolean:
                    _return = System.Type.GetType("System.Boolean");
                    break;
                case AttributeType.Integer:
                    _return = System.Type.GetType("System.Int32");
                    break;
                case AttributeType.Reference:
                case AttributeType.String:
                default:
                    break;
            }
            return _return;
        }

        private DataTable GetADSCodeTable(TypeDescriptionCollection tdObjectTypes)
        {

            DataTable namesTable = new DataTable(_adsTable);
            // Create an array for DataColumn objects.
            DataColumn[] keys = new DataColumn[1];

            // Add first column to the table.
            DataColumn idColumn = new DataColumn(_anchorColumn);
            idColumn.DataType = ConvertAttribToSystemType(tdObjectTypes[VAR_OBJECTTYPEGROUP].AnchorAttributes[_anchorColumn].DataType); //System.Type.GetType("System.String");
            namesTable.Columns.Add(idColumn);
            keys[0] = idColumn;
            namesTable.PrimaryKey = keys;

            // add second column
            foreach (AttributeDescription ad in tdObjectTypes[VAR_OBJECTTYPEGROUP].Attributes)
            {
                if ((!ad.IsMultiValued) 
                    && (ad.Name != _anchorColumn) 
                    && (ad.Name != VAR_OBJECTTYPE))
                {
                    idColumn = new DataColumn(ad.Name);
                    idColumn.DataType = ConvertAttribToSystemType(ad.DataType); // System.Type.GetType("System.String");
                    namesTable.Columns.Add(idColumn);
                }
            }

            return namesTable;

        }

        private DataTable GetADSCodePersonsTable(TypeDescriptionCollection tdObjectTypes)
        {
            // this table has a dual column key for unique ADS.CODE/PERS.PIN combinations

            DataTable namesTable = new DataTable(_personTable);
            // Create an array for DataColumn objects.
            DataColumn[] keys = new DataColumn[2];

            // Add first column to the table.
            DataColumn idColumn = new DataColumn(_anchorColumn);
            idColumn.DataType = ConvertAttribToSystemType(tdObjectTypes[VAR_OBJECTTYPEGROUP].AnchorAttributes[_anchorColumn].DataType); //System.Type.GetType("System.String");
            namesTable.Columns.Add(idColumn);
            keys[0] = idColumn;

            // add second column - grab what should be the only multivalue column
            foreach (AttributeDescription ad in tdObjectTypes[VAR_OBJECTTYPEGROUP].Attributes)
            {
                if (ad.IsMultiValued)
                {
                    idColumn = new DataColumn(ad.Name);
                    idColumn.DataType = ConvertAttribToSystemType(ad.DataType); // System.Type.GetType("System.String");
                    namesTable.Columns.Add(idColumn);
                    keys[1] = idColumn;
                    break;
                }
            }
            namesTable.PrimaryKey = keys;
            //// add ADSCode start/end
            //DataColumn startColumn = new DataColumn("ADS.START");
            //startColumn.DataType = System.Type.GetType("System.String");
            //namesTable.Columns.Add(startColumn);
            //DataColumn endColumn = new DataColumn("ADS.END");
            //endColumn.DataType = System.Type.GetType("System.String");
            //namesTable.Columns.Add(endColumn);

            return namesTable;

        }

        private DataSet GetADSCodesDataSet(
            UniSession objCAPSPayrollSession,
            string dtName,
            TypeDescriptionCollection tdObjectTypes
        )
        {
            // load ADS codes into a Data table
            DataSet _dsADSCodes = new DataSet(dtName);
            try
            {
                DataTable _dtADSCodes = GetADSCodeTable(tdObjectTypes);
                _dsADSCodes.Tables.Add(_dtADSCodes);
                UniDictionary _objADSDictionary = objCAPSPayrollSession.CreateUniDictionary(_adsTable);
                int _intADSDescIndex = Convert.ToInt16(_objADSDictionary.GetLoc("DESC").StringValue);
                UniFile _objADSCodeUniFile = objCAPSPayrollSession.CreateUniFile(_adsTable);
                UniSelectList _objADSCodeList = objCAPSPayrollSession.CreateUniSelectList(2);
                _objADSCodeList.Select(_objADSCodeUniFile);
                UniDynArray _daADSRecords = _objADSCodeList.ReadList();
                for (int intRecordIndex = 1; intRecordIndex <= _daADSRecords.Dcount(); intRecordIndex++)
                {
                    _objADSCodeUniFile.RecordID = _daADSRecords.Extract(intRecordIndex).ToString();
                    if (_objADSCodeUniFile.RecordID.Length > 0)
                    {
                        UniDynArray _daADSRecord = _objADSCodeUniFile.Read();
                        _dsADSCodes.Tables[_adsTable].NewRow();
                        DataRow _rwADS = _dsADSCodes.Tables[_adsTable].NewRow();
                        _rwADS[0] = _objADSCodeUniFile.RecordID;
                        _rwADS[1] = _daADSRecord.Extract(_intADSDescIndex).ToString();
                        _dsADSCodes.Tables[_adsTable].Rows.Add(_rwADS);
                        _daADSRecord.Dispose();
                    }
                }
                // dispose all
                _objADSCodeUniFile.Close();
                _daADSRecords.Dispose();
                _objADSCodeList.Dispose();
                _objADSCodeUniFile.Dispose();
                _objADSDictionary.Close();
                _objADSDictionary.Dispose();
                _dtADSCodes.Dispose();
            }
            catch (Exception ex)
            {
                throw new TerminateRunException("UNIVERSE ADS Load Error: " + Environment.NewLine + ex.Message);
            }
            return _dsADSCodes;
        }

        private Hashtable GetFieldsHashtable(
            UniSession objCAPSPayrollSession,
            string htName,
            TypeDescriptionCollection tdObjectTypes,
            out bool resolveTitles
        )
        {
            // load field identifiers into local hashtable
            Hashtable _htFields = new Hashtable();
            resolveTitles = false;
            try
            {
                UniDictionary _objFieldDictionary = objCAPSPayrollSession.CreateUniDictionary(htName);
                foreach (AttributeDescription _taAttribute in tdObjectTypes[VAR_OBJECTTYPEPERSON].Attributes)
                {
                    if ((_taAttribute.Name != "CLAS.CLASSN.DESC")
                        && (_taAttribute.Name != _anchorColumn)
                        && (_taAttribute.Name != VAR_OBJECTTYPE))
                    {
                        _htFields.Add(_taAttribute.Name, _objFieldDictionary.GetLoc(_taAttribute.Name).StringValue);
                    }
                    else
                    {
                        resolveTitles = true;
                    }

                }
                _objFieldDictionary.Close();
                _objFieldDictionary.Dispose();
            }
            catch (Exception ex)
            {
                throw new TerminateRunException("UNIVERSE Fields Load Error: " + Environment.NewLine + ex.Message);
            }
            return _htFields;
        }

        private Hashtable GetTitlesHashtable(
            UniSession objCAPSPayrollSession,
            string htName,
            TypeDescriptionCollection tdObjectTypes
        )
        {
            // load payroll titles into local hashtable
            Hashtable _htTitles = new Hashtable();
            try
            {

                UniDictionary objTitleDictionary = objCAPSPayrollSession.CreateUniDictionary(_payrollTitlesTable);
                int _fieldIndex = Convert.ToInt16(objTitleDictionary.GetLoc("CLASSN.DESC").StringValue);
                objTitleDictionary.Close();

                UniFile objPayrollTitleUniFile = objCAPSPayrollSession.CreateUniFile(_payrollTitlesTable);
                UniSelectList objTitleList = objCAPSPayrollSession.CreateUniSelectList(2);
                objTitleList.Select(objPayrollTitleUniFile);
                UniDynArray daTitleRecords = objTitleList.ReadList();
                for (int intRecordIndex = 1; intRecordIndex <= daTitleRecords.Dcount(); intRecordIndex++)
                {
                    objPayrollTitleUniFile.RecordID = daTitleRecords.Extract(intRecordIndex).ToString();
                    if (objPayrollTitleUniFile.RecordID.Length > 0)
                    {
                        UniDynArray daRecord = objPayrollTitleUniFile.Read();
                        _htTitles.Add(objPayrollTitleUniFile.RecordID, daRecord.Extract(_fieldIndex).ToString());
                        daRecord.Dispose();
                    }
                }
                objPayrollTitleUniFile.Close();
                daTitleRecords.Dispose();
                objTitleList.Dispose();
                objPayrollTitleUniFile.Dispose();
                objTitleDictionary.Dispose();
            }
            catch (Exception ex)
            {
                throw new TerminateRunException("UNIVERSE Titles Load Error: " + Environment.NewLine + ex.Message);
            }
            return _htTitles;
        }

        private void WriteAVPPersons(
            UniSession objCAPSPayrollSession,
            DataSet dsADSCodes,
            string anchorColumn,
            StreamWriter swAVPFile,
            Hashtable htFields,
            Hashtable htTitles,
            bool ResolveTitles,
            TypeDescriptionCollection tdObjectTypes
        )
        {
            string _strOutput = string.Empty;
            int _intFieldIndex;

            try
            {
                // load staff payroll records into a dynamic array
                UniFile _objPayrollUniFile = objCAPSPayrollSession.CreateUniFile(_personTable);
                UniSelectList _objFieldList = objCAPSPayrollSession.CreateUniSelectList(2);
                _objFieldList.Select(_objPayrollUniFile);
                UniDynArray _daPayrollRecords = _objFieldList.ReadList();

                for (int _intRecordIndex = 1; _intRecordIndex <= _daPayrollRecords.Dcount(); _intRecordIndex++)
                {
                    _objPayrollUniFile.RecordID = _daPayrollRecords.Extract(_intRecordIndex).ToString();
                    if (_objPayrollUniFile.RecordID.Length > 0)
                    {
                        // add record for object type
                        swAVPFile.WriteLine(String.Format("{0}:{1}", VAR_OBJECTTYPE, VAR_OBJECTTYPEPERSON));
                        UniDynArray daRecord = _objPayrollUniFile.Read();

                        ArrayList aDSCodes = new ArrayList();
                        ArrayList aDSStarts = new ArrayList();
                        ArrayList aDSEnds = new ArrayList();

                        foreach (AttributeDescription taAttribute in tdObjectTypes[VAR_OBJECTTYPEPERSON].Attributes)
                        {
                            if (taAttribute.Name == "PERS.PIN")
                            {
                                swAVPFile.WriteLine(String.Format("{0}:{1}", _anchorColumn, _objPayrollUniFile.RecordID));
                                swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, _objPayrollUniFile.RecordID));
                            }
                            else if (taAttribute.IsMultiValued)
                            {
                                _intFieldIndex = Convert.ToInt16(htFields[taAttribute.Name].ToString());
                                for (int intValueIndex = 1; intValueIndex <= daRecord.Dcount(_intFieldIndex); intValueIndex++)
                                {
                                    if (taAttribute.Name == "ADS.START" | taAttribute.Name == "ADS.END")
                                    {
                                        int _intADSCodeIndex = Convert.ToInt16(htFields["ADS.CODE"].ToString());
                                        _strOutput = daRecord.Extract(_intADSCodeIndex, intValueIndex).ToString();
                                        if (_strOutput.Length > 0)
                                        {
                                            _strOutput += "_";
                                            _strOutput += daRecord.Extract(_intFieldIndex, intValueIndex).ToString();
                                            swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, _strOutput));
                                            // save ADS start/end date for later use
                                            if (taAttribute.Name == "ADS.START")
                                            {
                                                aDSStarts.Add(_strOutput);
                                            }
                                            if (taAttribute.Name == "ADS.END")
                                            {
                                                aDSEnds.Add(_strOutput);
                                            }
                                        }
                                    }
                                    else
                                    {
                                        _strOutput = daRecord.Extract(_intFieldIndex, intValueIndex).ToString();
                                        if (_strOutput.Length > 0)
                                        {
                                            if (taAttribute.Name == "ADS.CODE")
                                            {
                                                //// store the ADS Code / PERS.PIN value pair in a child table
                                                //DataRow _rwADS = dsADSCodes.Tables[_personTable].NewRow();
                                                //_rwADS[0] = _strOutput;
                                                //_rwADS[1] = _objPayrollUniFile.RecordID;
                                                //try
                                                //{
                                                //    dsADSCodes.Tables[_personTable].Rows.Add(_rwADS);
                                                //}
                                                //catch (Exception)
                                                //{
                                                //    //ignore duplicates - these are expected with start/end date variations
                                                //}
                                                aDSCodes.Add(_strOutput);
                                            }
                                            swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, _strOutput));
                                        }
                                    }
                                }
                                if (aDSCodes.Count > 0)
                                {
                                    foreach (string adsCode in aDSCodes)
                                    {
                                        if (IsCurrentADSAssignment(adsCode,aDSStarts,aDSEnds))
                                        {
                                            // store the ADS Code / PERS.PIN value pair in a child table
                                            DataRow _rwADS = dsADSCodes.Tables[_personTable].NewRow();
                                            _rwADS[0] = adsCode;
                                            _rwADS[1] = _objPayrollUniFile.RecordID;
                                            try
                                            {
                                                dsADSCodes.Tables[_personTable].Rows.Add(_rwADS);
                                            }
                                            catch (Exception)
                                            {
                                                //ignore duplicates - these are expected with start/end date variations
                                            }
                                        }
                                    }
                                }
                            }
                            else if ((taAttribute.Name == "CLAS.CLASSN.DESC") && ResolveTitles)
                            {
                                _intFieldIndex = Convert.ToInt16(htFields["CLAS.CLASSN.CD"].ToString());
                                try
                                {
                                    _strOutput = htTitles[daRecord.Extract(_intFieldIndex).ToString()].ToString();
                                    if (_strOutput.Length > 0)
                                    { swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, _strOutput)); }
                                }
                                catch { }
                            }
                            else if ((taAttribute.Name != _anchorColumn) && (taAttribute.Name != VAR_OBJECTTYPE))
                            {
                                _intFieldIndex = Convert.ToInt16(htFields[taAttribute.Name].ToString());
                                _strOutput = daRecord.Extract(_intFieldIndex).ToString();
                                if (_strOutput.Length > 0)
                                { swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, _strOutput)); }
                            }
                        }
                        daRecord.Dispose();
                    }
                    swAVPFile.WriteLine(); // new record, seperated by empty line
                }
                _daPayrollRecords.Dispose();
                _objFieldList.Dispose();
                _objPayrollUniFile.Close();
                _objPayrollUniFile.Dispose();

            }
            catch (Exception ex)
            {
                throw new TerminateRunException("AVP Persons Write Error: " + Environment.NewLine + ex.Message);
            }
        }

        private bool IsCurrentADSAssignment(string adsCode, ArrayList adsStarts, ArrayList adsEnds)
        {
            // return true iff ADS code is still current
            const string DAY_ZERO = "31/12/1967";

            string[] arrADSStartDate = null;
            string[] arrADSEndDate = null;
            DateTime aDSEndDate;
            DateTime aDSStartDate;
            bool isCurrent = true;

            // locate a start record for the supplied adsCode
            foreach (string adsStart in adsStarts)
            {
                arrADSStartDate = adsStart.Split('_');
                if (arrADSStartDate[0].Equals(adsCode))
                {
                    if (arrADSStartDate.Length > 1 && arrADSStartDate[1].Length > 0)
                    {
                        aDSStartDate = DateTime.Parse(DAY_ZERO).AddDays(Convert.ToInt32(arrADSStartDate[1]));
                        if (aDSStartDate > DateTime.Today)
                        { isCurrent = false; }
                    }
                    else
                    { isCurrent = false; }
                    break;
                }
            }

            if (isCurrent)
            {
                // locate an end record for the supplied adsCode
                foreach (string adsEnd in adsEnds)
                {
                    arrADSEndDate = adsEnd.Split('_');
                    if (arrADSEndDate[0].Equals(adsCode))
                    {
                        if (arrADSEndDate.Length > 1 && arrADSEndDate[1].Length > 0)
                        {
                            aDSEndDate = DateTime.Parse(DAY_ZERO).AddDays(Convert.ToInt32(arrADSEndDate[1]));
                            if (aDSEndDate < DateTime.Today)
                            { isCurrent = false; }
                        }
                        break;
                    }
                }
            }

            return isCurrent;
        }

        private void WriteAVPGroups(
            DataSet dsADSCodes,
            string anchorColumn,
            StreamWriter swAVPFile,
            TypeDescriptionCollection tdObjectTypes
        )
        {
            try
            {
                DataColumn[] parentColumnNames = new DataColumn[1];
                DataColumn[] childColumnNames = new DataColumn[1];
                parentColumnNames[0] = dsADSCodes.Tables[_adsTable].Columns[anchorColumn];
                childColumnNames[0] = dsADSCodes.Tables[_personTable].Columns[anchorColumn];
                dsADSCodes.Relations.Add(new DataRelation(_adsTable, parentColumnNames, childColumnNames, false));
                foreach (DataRow dr in dsADSCodes.Tables[_adsTable].Rows)
                {
                    swAVPFile.WriteLine(String.Format("{0}:{1}", VAR_OBJECTTYPE, VAR_OBJECTTYPEGROUP));
                    swAVPFile.WriteLine(String.Format("{0}:{1}", anchorColumn, dr[0].ToString()));
                    foreach (AttributeDescription taAttribute in tdObjectTypes[VAR_OBJECTTYPEGROUP].Attributes)
                    {
                        if ((taAttribute.Name != anchorColumn)
                            && (taAttribute.Name != VAR_OBJECTTYPE))
                        {
                            if (taAttribute.IsMultiValued)
                            {
                                foreach (DataRow cr in dr.GetChildRows(_adsTable))
                                {
                                    //swAVPFile.WriteLine(String.Format("{0}:{1}", anchorColumn, cr[anchorColumn].ToString()));
                                    swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, cr[taAttribute.Name].ToString()));
                                }
                            }
                            else
                            {
                                swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, dr[taAttribute.Name].ToString()));
                            }
                        }
                    }
                    swAVPFile.WriteLine(); // new record, seperated by empty line
                }
            }
            catch (Exception ex)
            {
                throw new TerminateRunException("AVP Groups Write Error: " + Environment.NewLine + ex.Message);
            }
        }

        #endregion

        #region EntryPoint: GenerateImportFile

        public void GenerateImportFile(
            string strFilename, 
            string strCAPSPayrollServer, 
            string strUsername, 
            string strPassword, 
            ConfigParameterCollection configParameters, 
            bool blnFullImport, 
            TypeDescriptionCollection tdObjectTypes, 
            ref string customData)
        {
            ValidateConfiguration(configParameters, blnFullImport, tdObjectTypes);

            if (_reloadExistingFilePath.Length > 0)
            {
                if (File.Exists(_reloadExistingFilePath))
                {
                    if (File.Exists(strFilename))
                    {
                        File.Delete(strFilename);
                    }
                    File.Copy(_reloadExistingFilePath, strFilename);
                }
            }
            else
            {

                bool _blnResolveTitles = false;
                Hashtable _objTitles = null;

                // attempt connection to the CAPS Payroll server using the supplied information.
                UniSession _objCAPSPayrollSession = UniObjects.OpenSession( 
                    strCAPSPayrollServer, 
                    strUsername, 
                    strPassword,
                    _account, 
                    _service);

                // load ADS codes into a Data table
                DataSet _dsADSCodes = GetADSCodesDataSet(_objCAPSPayrollSession, _adsTable, tdObjectTypes);

                // load field identifiers into local hashtable
                Hashtable _objFields = GetFieldsHashtable(_objCAPSPayrollSession, _personTable, tdObjectTypes, out _blnResolveTitles);

                // load payroll titles into local hashtable
                if (_blnResolveTitles)
                {
                    _objTitles = GetTitlesHashtable(_objCAPSPayrollSession, _payrollTitlesTable, tdObjectTypes);
                }

                // generate the output file in AVP format
                _dsADSCodes.Tables.Add(GetADSCodePersonsTable(tdObjectTypes));

                StreamWriter _swAVPFile = new StreamWriter(strFilename, false, System.Text.Encoding.Unicode);

                // write person records
                WriteAVPPersons(
                    _objCAPSPayrollSession,
                    _dsADSCodes, 
                    _anchorColumn, 
                    _swAVPFile, 
                    _objFields, 
                    _objTitles, 
                    _blnResolveTitles, 
                    tdObjectTypes);

                // write groups
                WriteAVPGroups(_dsADSCodes, _anchorColumn, _swAVPFile, tdObjectTypes);

                // clean up
                _swAVPFile.Close();
                _swAVPFile = null;
                _dsADSCodes.Dispose();
                UniObjects.CloseSession(_objCAPSPayrollSession);
                _objCAPSPayrollSession.Dispose();
            }
        }

        #endregion

        #region EntryPoint: DeliverExportFile (EntryPointNotImplemented)

        public void DeliverExportFile(string fileName, string connectTo, string user, string password, ConfigParameterCollection configParameters, TypeDescriptionCollection types)
        {
            throw new EntryPointNotImplementedException();
        }

        #endregion
    }
}
