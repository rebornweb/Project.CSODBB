using System;
using System.IO;
using System.Xml;
using System.Text;
using System.Collections;
using System.Collections.Specialized;
using Microsoft.MetadirectoryServices;
using System.Data;
using IBMU2.UODOTNET;

namespace PrincipalForWindowsMA
{
	/// <summary>
	/// MIIS 2003 Extensible Connectivity Management Agent for Principal for Windows.
	/// Developed by Commander Infrastructure Solutions 2006-2007.
	/// </summary>
	 
	public class PrincipalForWindowsDB:IMAExtensibleFileImport, IMAExtensibleFileExport
	{
		#region EntryPoint: GenerateImportFile

		public void GenerateImportFile(string strFilename, string strPfWServer, string strUsername, string strPassword, ConfigParameterCollection configParameters, bool blnFullImport, TypeDescriptionCollection tdObjectTypes, ref string customData)
		{
			// validate the operating environment is supported by this MA.
			if(!blnFullImport)
				{throw new TerminateRunException("This MA only supports full import");}

			if (tdObjectTypes.Count > 1)
			{throw new TerminateRunException("This MA only supports one object type of 'student'");}

			if (tdObjectTypes["student"].Attributes.Count == 0)
				{throw new TerminateRunException("No attributes in schema definition for the student object, please configure this MA correctly as per instructions");}

			// create required core objects
			ArrayList pfwRecords = new ArrayList();
			bool blnNextRecordExists = true;
			RecLists pfwAttribute;
			string strOutput;
			string strPfWInstance = "RECORDS"; // default instance
			string strUniCommand;

			try 
			{
				if (configParameters["Instance"].Value.Length > 0)
				{strPfWInstance = configParameters["Instance"].Value;}
			}
			catch (NoSuchParameterException) {}


			// attempt connection to the PfW server using the supplied information.
			UniSession objPfWSession = UniObjects.OpenSession(strPfWServer, strUsername, strPassword, strPfWInstance, "uvcs");
			UniFile objStudentUniFile = objPfWSession.CreateUniFile("STUDENT");
			UniSelectList objIDList = objPfWSession.CreateUniSelectList(1);
			objIDList.Select(objStudentUniFile);
			UniDynArray daIDList = objIDList.ReadList();
			UniCommand objUniCommand = objPfWSession.CreateUniCommand();

			// enumerate the configured list of attributes and retrieve the attribute values from the PfW server
			foreach(AttributeDescription taAttribute in tdObjectTypes["student"].Attributes)
			{
				strUniCommand = "SELECT STUDENT FROM 1 TO 2 SAVING " + taAttribute.Name;
				objUniCommand.Command = strUniCommand;
				objUniCommand.Execute();

				UniSelectList objFieldList = objPfWSession.CreateUniSelectList(2);

				pfwAttribute.FieldName = taAttribute.Name;
				pfwAttribute.Fields = new ArrayList();

				while (!objFieldList.LastRecordRead)
					{pfwAttribute.Fields.Add(objFieldList.Next());}
				
								
				// verify data returned by the PfW server
				pfwAttribute.Fields.RemoveAt(pfwAttribute.Fields.Count - 1); // trim null field at end of recordlist as objFieldList.LastRecordRead is not accurate.

				if (pfwAttribute.Fields.Count==0)
					{throw new DataException(taAttribute.Name + " returned 0 rows");}

				if (pfwAttribute.Fields.Count != daIDList.Dcount()) 
					{throw new DataException("Multi values detected in field " + taAttribute.Name);}


				// save attribute and value information
				pfwAttribute.Pointer = pfwAttribute.Fields.GetEnumerator();
				pfwAttribute.Pointer.MoveNext();
				pfwRecords.Add(pfwAttribute);

				objFieldList.Dispose();
			}

			// clean up the PfW server connection
			objUniCommand.Dispose();
			daIDList.Dispose();
			objIDList.Dispose();
			objStudentUniFile.Close();
			objStudentUniFile.Dispose();
			UniObjects.CloseSession(objPfWSession);
			objPfWSession.Dispose();

			// generate the output file in AVP format
			StreamWriter swAVPFile = new StreamWriter(strFilename, false, System.Text.Encoding.Unicode);
			while (blnNextRecordExists)
			{
				foreach (RecLists pfwAttributeData in pfwRecords)
				{
					try 
						{strOutput = pfwAttributeData.Pointer.Current.ToString();}
					catch(Exception e)
						{throw new UnexpectedDataException("Error processing field '" + pfwAttributeData.FieldName + "' " + e.Message);}
					
					swAVPFile.WriteLine(String.Format("{0}:{1}", pfwAttributeData.FieldName, strOutput));

					try
						{blnNextRecordExists = pfwAttributeData.Pointer.MoveNext();}
					catch(Exception e)
						{throw new UnexpectedDataException(e.Message);}
				}
				swAVPFile.WriteLine(); // new record, seperated by empty line
			}
			
			// clean up
			swAVPFile.Close();
			swAVPFile = null;
			pfwRecords = null;
		}
		#endregion

		#region EntryPoint: DeliverExportFile (EntryPointNotImplemented)

		public void DeliverExportFile(string fileName, string connectTo, string user, string password, ConfigParameterCollection configParameters, TypeDescriptionCollection types)
		{
			throw new EntryPointNotImplementedException();
		}

		#endregion
	}

	public struct RecLists
	{
		public string FieldName;
		public ArrayList Fields;
		public System.Collections.IEnumerator Pointer;
	}
}
