using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Xml;
using System.Text;
using System.Collections.Specialized;
using Microsoft.MetadirectoryServices;

namespace Miis_FileExport
{
    public class MAFileExport :
        IMAExtensibleFileImport,
        IMAExtensibleFileExport
    {
        //
        // Constructor
        //
        public MAFileExport(
            )
        {
        }

        private const string PARAM_SQLDATABASE = "Database";
        private const string PARAM_SQLTIMEOUT = "Timeout";

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

        public void GenerateImportFile(string strFilename, string strBOPSDBServer, string strUsername, string strPassword, ConfigParameterCollection configParameters, bool blnFullImport, TypeDescriptionCollection tdObjectTypes, ref string customData)
        {
            // validate the operating environment is supported by this MA.
            if (!blnFullImport)
            { throw new TerminateRunException("This MA only supports full import"); }

            if (tdObjectTypes.Count > 1)
            { throw new TerminateRunException("This MA only supports one object type of 'person'"); }

            if (tdObjectTypes["person"].Attributes.Count == 0)
            { throw new TerminateRunException("No attributes in schema definition for the person object, please configure this MA correctly as per instructions"); }


            // create required core objects
            DataSet dsBOPS = new DataSet("BOPSDB");
            DataTable dtPerson = dsBOPS.Tables.Add("Person");
            DataTable dtADSRole = dsBOPS.Tables.Add("ADSRole");

            // initiate connection to the BOPS SQL database
            //SqlConnection sqlBOPSConn = new SqlConnection("Data Source=" + strBOPSDBServer + ";Initial Catalog=BOPSDB;Integrated Security=SSPI");
            SqlConnection sqlBOPSConn = new SqlConnection(ConstructConnectionString(strBOPSDBServer, strUsername, strPassword, configParameters));
            sqlBOPSConn.Open();
            SqlDataAdapter sqlBOPSAdapter = new SqlDataAdapter();
            SqlCommand sqlBOPSCmd = new SqlCommand();
            sqlBOPSCmd.Connection = sqlBOPSConn;
            sqlBOPSCmd.CommandType = CommandType.Text; ;

            // load Employee table
            sqlBOPSCmd.CommandText = "SELECT * FROM vw_idmPerson";
            sqlBOPSAdapter.SelectCommand = sqlBOPSCmd;
            sqlBOPSAdapter.Fill(dtPerson);

            // generate the output file in AVP format
            StreamWriter swAVPFile = new StreamWriter(strFilename, false, System.Text.Encoding.Unicode);

            foreach (DataRow drPerson in dtPerson.Rows)
            {
                dtADSRole.Clear();
                if (drPerson["ContractID"] != null)
                {
                    // load ADSRole table
                    sqlBOPSCmd.CommandText = "SELECT * FROM vw_idmADSRole WHERE ContractID = '" + drPerson["ContractID"].ToString() + "'";
                    sqlBOPSAdapter.SelectCommand = sqlBOPSCmd;
                    sqlBOPSAdapter.Fill(dtADSRole);
                }

                foreach (AttributeDescription taAttribute in tdObjectTypes["person"].Attributes)
                {
                    if (taAttribute.IsMultiValued)
                    {
                        foreach (DataRow drADSRole in dtADSRole.Rows)
                        {
                            if (taAttribute.Name == "ADSCode")
                            { swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, drADSRole[taAttribute.Name])); }
                            else
                            { swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, drADSRole["ADSCode"] + "_" + drADSRole[taAttribute.Name])); }
                        }
                    }
                    else
                    {
                        try
                        { swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, drPerson[taAttribute.Name])); }
                        catch { }
                    }
                }
                swAVPFile.WriteLine(); // new record, seperated by empty line
            }

            // clean up
            swAVPFile.Close();
            swAVPFile = null;

            sqlBOPSCmd.Dispose();
            sqlBOPSAdapter.Dispose();
            sqlBOPSConn.Close();
            sqlBOPSConn.Dispose();

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
