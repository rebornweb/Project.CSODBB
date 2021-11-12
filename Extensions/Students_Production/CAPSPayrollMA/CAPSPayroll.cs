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
	public class CAPSPayroll:IMAExtensibleFileImport, IMAExtensibleFileExport
	{
		#region EntryPoint: GenerateImportFile

		public void GenerateImportFile(string strFilename, string strCAPSPayrollServer, string strUsername, string strPassword, ConfigParameterCollection configParameters, bool blnFullImport, TypeDescriptionCollection tdObjectTypes, ref string customData)
		{
			// validate the operating environment is supported by this MA.
			if(!blnFullImport)
			{throw new TerminateRunException("This MA only supports full import");}

			if (tdObjectTypes.Count > 1)
			{throw new TerminateRunException("This MA only supports one object type of 'person'");}

			if (tdObjectTypes["person"].Attributes.Count == 0)
			{throw new TerminateRunException("No attributes in schema definition for the person object, please configure this MA correctly as per instructions");}
	
	
			// create required core objects
			bool blnResolveTitles = false;
			Hashtable objFields = new Hashtable();
			Hashtable objTitles = new Hashtable();
			int intADSIndex;
			int intFieldIndex;
			string strOutput;

			// attempt connection to the CAPS Payroll server using the supplied information.
			UniSession objCAPSPayrollSession = UniObjects.OpenSession(strCAPSPayrollServer, strUsername, strPassword, "CSOBB", "uvcs");
			
			// load field identifiers into local hashtable
			UniDictionary objFieldDictionary = objCAPSPayrollSession.CreateUniDictionary("PAPERSONAL");
			foreach(AttributeDescription taAttribute in tdObjectTypes["person"].Attributes)
			{
				if (taAttribute.Name != "CLAS.CLASSN.DESC")
				{
					objFields.Add(taAttribute.Name, objFieldDictionary.GetLoc(taAttribute.Name).StringValue);
				}
				else
				{
					blnResolveTitles = true;
				}

			}
			objFieldDictionary.Close();

			// load payroll titles into local hashtable
			if (blnResolveTitles)
			{
				UniDictionary objTitleDictionary = objCAPSPayrollSession.CreateUniDictionary("PACLASSN");
				intFieldIndex = Convert.ToInt16(objTitleDictionary.GetLoc("CLASSN.DESC").StringValue);
				objTitleDictionary.Close();

				UniFile objPayrollTitleUniFile = objCAPSPayrollSession.CreateUniFile("PACLASSN");
				UniSelectList objTitleList = objCAPSPayrollSession.CreateUniSelectList(2);
				objTitleList.Select(objPayrollTitleUniFile);
				UniDynArray daTitleRecords = objTitleList.ReadList();
				for(int intRecordIndex=1; intRecordIndex <= daTitleRecords.Dcount(); intRecordIndex++)
				{
					objPayrollTitleUniFile.RecordID = daTitleRecords.Extract(intRecordIndex).ToString();
					if (objPayrollTitleUniFile.RecordID.Length > 0) 
					{
						UniDynArray daRecord = objPayrollTitleUniFile.Read();
						objTitles.Add(objPayrollTitleUniFile.RecordID, daRecord.Extract(intFieldIndex).ToString());
						daRecord.Dispose();
					}
				}
				objPayrollTitleUniFile.Close();
				daTitleRecords.Dispose();
				objTitleList.Dispose();
				objPayrollTitleUniFile.Dispose();
				objTitleDictionary.Dispose();
			}

			// load 
			UniFile objPayrollUniFile = objCAPSPayrollSession.CreateUniFile("PAPERSONAL");
			UniSelectList objFieldList = objCAPSPayrollSession.CreateUniSelectList(2);
			objFieldList.Select(objPayrollUniFile);
			UniDynArray daPayrollRecords = objFieldList.ReadList();

			// generate the output file in AVP format
			StreamWriter swAVPFile = new StreamWriter(strFilename, false, System.Text.Encoding.Unicode);
			for(int intRecordIndex=1; intRecordIndex <= daPayrollRecords.Dcount(); intRecordIndex++)
			{
				objPayrollUniFile.RecordID = daPayrollRecords.Extract(intRecordIndex).ToString();
				if (objPayrollUniFile.RecordID.Length > 0) 
				{
					UniDynArray daRecord = objPayrollUniFile.Read();
					foreach (AttributeDescription taAttribute in tdObjectTypes["person"].Attributes)
					{	
						if (taAttribute.Name == "PERS.PIN") 
						{
							swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, objPayrollUniFile.RecordID));
						}
						else if (taAttribute.IsMultiValued)
						{
							intFieldIndex = Convert.ToInt16(objFields[taAttribute.Name].ToString());
							for (int intValueIndex = 1; intValueIndex <= daRecord.Dcount(intFieldIndex); intValueIndex++)
							{
								if (taAttribute.Name == "ADS.START" | taAttribute.Name == "ADS.END")
								{
									intADSIndex = Convert.ToInt16(objFields["ADS.CODE"].ToString());
									strOutput = daRecord.Extract(intADSIndex, intValueIndex).ToString();
									if (strOutput.Length > 0)
									{
										strOutput += "_";
										strOutput += daRecord.Extract(intFieldIndex, intValueIndex).ToString();
										swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, strOutput));
									}
								}
								else 
								{
									strOutput = daRecord.Extract(intFieldIndex, intValueIndex).ToString();
									if (strOutput.Length > 0)
										{swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, strOutput));}
								}

							}
						}
						else if (taAttribute.Name == "CLAS.CLASSN.DESC")
						{
							intFieldIndex = Convert.ToInt16(objFields["CLAS.CLASSN.CD"].ToString());
							try
							{
								strOutput = objTitles[daRecord.Extract(intFieldIndex).ToString()].ToString();
								if (strOutput.Length > 0)
								{swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, strOutput));}
							}
							catch {}
						}
						else
						{
							intFieldIndex = Convert.ToInt16(objFields[taAttribute.Name].ToString());
							strOutput = daRecord.Extract(intFieldIndex).ToString();
							if (strOutput.Length > 0)
								{swAVPFile.WriteLine(String.Format("{0}:{1}", taAttribute.Name, strOutput));}
						}
					}
					daRecord.Dispose();
				}
				swAVPFile.WriteLine(); // new record, seperated by empty line
			}

			// clean up
			swAVPFile.Close();
			swAVPFile = null;
			daPayrollRecords.Dispose();
			objFieldList.Dispose();
			objFieldDictionary.Dispose();
			objPayrollUniFile.Close();
			objPayrollUniFile.Dispose();
			UniObjects.CloseSession(objCAPSPayrollSession);
			objCAPSPayrollSession.Dispose();
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
