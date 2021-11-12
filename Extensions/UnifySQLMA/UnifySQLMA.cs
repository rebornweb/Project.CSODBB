
using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Xml;
using System.Text;
using System.Collections;
using System.Collections.Specialized;
using System.Collections.Generic;
using Microsoft.MetadirectoryServices;
using System.Security.Principal;
using System.Net;
using Microsoft.SqlServer.Management.Common;

namespace Mms_ManagementAgent_SQLxMA
{
    public class MAFileImport :
        IMAExtensibleFileImport,
        IMAExtensibleFileExport
    {
        //
        // Constructor
        //
        public MAFileImport() { }

        // ------------------ C O N S T A N T S ------------------------
        private const string PARAM_SQLTABLENAME = "Table";
        private const string PARAM_SQLDELTATABLENAME = "DeltaView";
        private const string PARAM_SQLMVTABLENAME = "MVTable";
        private const string PARAM_SQLDATABASE = "Database";
        private const string PARAM_SQLTIMEOUT = "Timeout";
		private const string PARAM_SQLMVMULTIVALUEATTRIBUTECOLUMN = "MVAttributeColumn";

        private string GetSqlTimeOut
        (
            ConfigParameterCollection configParameters
        )
        {
            string sqlTimeOut = "60";
            try
            {
                if (!configParameters[PARAM_SQLTIMEOUT].Value.Equals(string.Empty))
                {
                    sqlTimeOut = configParameters[PARAM_SQLTIMEOUT].Value;
                }
            }
            // Ignore if the parameter "Timeout" doesn't exist (defaults if not supplied)
            catch { }
            return sqlTimeOut;
        }

        private string ConstructConnectionString
        (
            string connectTo,
            string user,
            string password,
            ConfigParameterCollection configParameters
        )
        {

            string connectionString = string.Empty;

            if ((user != null) && (user != string.Empty))
            {
                connectionString = String.Format("Data Source={0};Initial Catalog={1};Connect Timeout={2};User ID={3};Password={4}",
                    connectTo,
                    configParameters[PARAM_SQLDATABASE].Value,
                    GetSqlTimeOut(configParameters),
                    user,
                    password);
            }
            else
            {
                // use INTEGRATED SECURITY
                connectionString = String.Format("Data Source={0};Initial Catalog={1};Integrated Security=True;Connect Timeout={2}",
                    connectTo,
                    configParameters[PARAM_SQLDATABASE].Value,
                    GetSqlTimeOut(configParameters));
            }
            return connectionString;
        } //ConstructConnectionString

        #region EntryPoint: GenerateImportFile

        public void GenerateImportFile(
            string strFilename,
            string strMAINDBServer,
            string strUsername,
            string strPassword,
            ConfigParameterCollection configParameters,
            bool blnFullImport,
            TypeDescriptionCollection tdObjectTypes,
            ref string customData)
        {
            string[] objectTypes = { };
            string mvTableName = string.Empty;
			string mvAttributeColumnName = string.Empty;
            TypeDescription firstObjectType = null;
            ArrayList attributeList = null;
			ArrayList mvAttributeList = null;

            // validate the presence of required parameters by this MA.
            try
            {
                if (configParameters[PARAM_SQLTABLENAME].Value.Equals(string.Empty))
                { throw new TerminateRunException("Required (SQL) Table parameter has not been specified"); }
            }
            catch { throw new TerminateRunException("Required (SQL) Table parameter has not been specified"); }

            try
            {
                if (configParameters[PARAM_SQLDATABASE].Value.Equals(string.Empty))
                { throw new TerminateRunException("Required (SQL) Database parameter has not been specified"); }
            }
            catch { throw new TerminateRunException("Required (SQL) Database parameter has not been specified"); }

            try
            {
                if (!blnFullImport && configParameters[PARAM_SQLDELTATABLENAME].Value.Equals(string.Empty))
                { throw new TerminateRunException("A delta import has been initiated without the required Delta View parameter being specified"); }
            }
            catch { throw new TerminateRunException("A delta import has been initiated without the required Delta View parameter being specified"); }

            try
            {
                if (!configParameters[PARAM_SQLMVTABLENAME].Value.Equals(string.Empty))
                {
                    mvTableName = configParameters[PARAM_SQLMVTABLENAME].Value;
                }
				if (!configParameters[PARAM_SQLMVMULTIVALUEATTRIBUTECOLUMN].Value.Equals(string.Empty))
                {
					mvAttributeColumnName = configParameters[PARAM_SQLMVMULTIVALUEATTRIBUTECOLUMN].Value;
                }
            }
            // Ignore if the parameter "MVObjectTypes" doesn't exist (validation occurs only if MV attributes specified)
            catch { }

            // validate the operating environment is supported by this MA.
            if (tdObjectTypes.ObjectTypeAttributeName == null)
            { throw new TerminateRunException("The object type attribute has not been defined for this MA"); }

            if (!blnFullImport && tdObjectTypes.ChangeType.AttributeName == null)
            { throw new TerminateRunException("A delta import has been initiated without a Change Type attribute being specified"); }


            // create required core objects
            DataSet dsMAIN = new DataSet("MAIN_DS");
            DataTable dtParent = dsMAIN.Tables.Add("PARENT_DT");
            SqlConnection sqlMAINConn = null;
            char DOMAIN_DELIM = Convert.ToChar("\\");

            // initiate connection to the MAIN SQL database
            if ((strUsername != null) && (strUsername.Length >= 0) && (strUsername.Contains("\\")))
            {
                ServerConnection serverConnection = new ServerConnection();
                serverConnection.ConnectAsUser = true;
                serverConnection.ConnectAsUserName = strUsername.Split(DOMAIN_DELIM)[1].ToString();
                serverConnection.ConnectAsUserPassword = strPassword;
                serverConnection.DatabaseName = configParameters[PARAM_SQLDATABASE].Value;
                serverConnection.StatementTimeout = Convert.ToInt32(GetSqlTimeOut(configParameters));
                serverConnection.Connect();
                sqlMAINConn = serverConnection.SqlConnectionObject;
            }
            else
            {
                sqlMAINConn = new SqlConnection(ConstructConnectionString(strMAINDBServer, strUsername, strPassword, configParameters));
                sqlMAINConn.Open();
            }
            SqlDataAdapter sqlMAINAdapter = new SqlDataAdapter();
            SqlCommand sqlMAINCmd = new SqlCommand();
            sqlMAINCmd.Connection = sqlMAINConn;
            sqlMAINCmd.CommandType = CommandType.Text;

            // load Parent Object table
            if (blnFullImport)
            {
                sqlMAINCmd.CommandText = "SELECT * FROM " + configParameters[PARAM_SQLTABLENAME].Value;
            }
            else
            {
                sqlMAINCmd.CommandText = "SELECT * FROM " + configParameters[PARAM_SQLDELTATABLENAME].Value;
            }
            sqlMAINAdapter.SelectCommand = sqlMAINCmd;
            sqlMAINAdapter.Fill(dtParent);

            // generate the output file in AVP format
            StreamWriter swAVPFile = new StreamWriter(strFilename, false, System.Text.Encoding.ASCII); //.Unicode);

			mvAttributeList = new ArrayList();

            foreach (TypeDescription TD in tdObjectTypes)
            {
                //---------------------------------------------------------------
                // Construct the columns to select from the SQL table (and AVP file) by
                // enumerating through the attributes of the first object type.
                // This assumes that the DB MA schema exposes all attributes 
                // available for all object types
                //---------------------------------------------------------------

                firstObjectType = TD;
                attributeList = new ArrayList();
                foreach (AttributeDescription AD in TD.Attributes)
                {
					attributeList.Add(AD.Name);
					if (AD.IsMultiValued)
					{
						if (!mvAttributeList.Contains(AD.Name))
						{
							// note that multivalue attributes can be shared between multiple object types,
							// and hence we can only add one data relationship per mv attribute (not per occurrance)
							mvAttributeList.Add(AD.Name);
							// validate that a multivalue attribute table parameter is present
							if (mvTableName.Equals(string.Empty))
							{
								throw new TerminateRunException("A multivalue attribute has been specified with no corresponding Delta View parameter");
							}

							DataTable dtChild = dsMAIN.Tables.Add(AD.Name);
							// load Child DS
							sqlMAINCmd.CommandText = "SELECT * FROM " + mvTableName + " Where [" + tdObjectTypes.ObjectTypeAttributeName + "] = '" + AD.Name + "' ";
							sqlMAINAdapter.SelectCommand = sqlMAINCmd;
							sqlMAINAdapter.Fill(dtChild);
							// add a relation for each anchor attribute - presumption is that column names are common between data sets
							// as this is a requirement of the corresponding SQL MA approach
							int i = 0;
							DataColumn[] parentColumnNames = new DataColumn[TD.AnchorAttributes.Count];
							DataColumn[] childColumnNames = new DataColumn[TD.AnchorAttributes.Count];
							foreach (AttributeDescription anchorAttr in TD.AnchorAttributes)
							{
								parentColumnNames[i] = dtParent.Columns[anchorAttr.Name];
								childColumnNames[i] = dtChild.Columns[anchorAttr.Name];
								i += 1;
							}
							dsMAIN.Relations.Add(new DataRelation(AD.Name, parentColumnNames, childColumnNames, false));
							//if (blnFullImport)
							//{
							//    dsMAIN.Relations.Add(new DataRelation(AD.Name, parentColumnNames, childColumnNames, true));
							//}
							//else
							//{
							//    // change table will not have unique rows, so cannot force constraint
							//    dsMAIN.Relations.Add(new DataRelation(AD.Name, parentColumnNames, childColumnNames, false));
							//}
						}
					}
                }

                // there must be at least one attribute detected by now!
                if (attributeList.Count.Equals(1))
                {
                    throw new TerminateRunException(
                       "No attributes in schema definition");
                }

                // write the data for this record type
                foreach (DataRow drParent in dtParent.Rows)
                {
                    if (firstObjectType.Name.Equals(drParent[tdObjectTypes.ObjectTypeAttributeName]))
                    {
                        // write object type row
                        swAVPFile.WriteLine(String.Format(tdObjectTypes.ObjectTypeAttributeName + ":{0}", drParent[tdObjectTypes.ObjectTypeAttributeName]));

                        // write change type row
                        if (!blnFullImport)
                        {
                            swAVPFile.WriteLine(String.Format(tdObjectTypes.ChangeType.AttributeName + ":{0}", drParent[tdObjectTypes.ChangeType.AttributeName]));
                        }

                        //TODO: handle carriage returns in data
                        foreach (string strAttributeName in attributeList)
                        {
                            AttributeDescription taAttribute = firstObjectType.Attributes[strAttributeName];
                            if (taAttribute.IsMultiValued)
                            {
                                foreach (DataRow drChildren in drParent.GetChildRows(taAttribute.Name))
                                {
									swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, drChildren[mvAttributeColumnName])); //StringValue"]));
                                }
                            }
                            else
                            {
                                try
                                { swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, drParent[taAttribute.Name])); }
                                catch { }
                            }
                        }
                        swAVPFile.WriteLine(); // new record, seperated by empty line
                    }
                }
            }

            // clean up
            swAVPFile.Close();
            swAVPFile = null;

            sqlMAINCmd.Dispose();
            sqlMAINAdapter.Dispose();
            sqlMAINConn.Close();
            sqlMAINConn.Dispose();

        }

        #endregion

        #region EntryPoint: DeliverExportFile (EntryPointNotImplemented)

        public void DeliverExportFile(
            string fileName,
            string connectTo,
            string user,
            string password,
            ConfigParameterCollection configParameters,
            TypeDescriptionCollection types)
        {
            throw new EntryPointNotImplementedException();
        }

        #endregion
    }
}
