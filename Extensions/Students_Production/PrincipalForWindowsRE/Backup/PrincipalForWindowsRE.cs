
using System;
using System.Globalization;
using Microsoft.MetadirectoryServices;
using System.Xml;

namespace Mms_ManagementAgent_PrincipalForWindowsRE
{
    /// <summary>
    /// Summary description for MAExtensionObject.
	/// </summary>
	public class MAExtensionObject : IMASynchronization
	{
		#region declare global working environment
		string mailsuffix;
		char[] arrInvalidChar = "/\\'[]:;|=,+*?<>@\"~ ".ToCharArray();
		XmlNodeList xmlStudentMyMailSuffixList;
		#endregion

		public MAExtensionObject()
		{
			//
			// TODO: write code
			//
		}

		void IMASynchronization.Initialize ()
		{
			// open xml configuration document 'PFWRE.config'
			XmlDocument xmlREConfig = new XmlDocument();
			xmlREConfig.Load(Utils.ExtensionsDirectory.ToString() + "\\PFWRE.config");

			xmlStudentMyMailSuffixList = xmlREConfig.SelectNodes("provisioning-extensions/MAName");
		}

        void IMASynchronization.Terminate ()
        {
            //
            // TODO: write termination code
            //
        }

        bool IMASynchronization.ShouldProjectToMV (CSEntry csentry, out string MVObjectType)
        {
			//
			// TODO: Remove this throw statement if you implement this method
			//
			throw new EntryPointNotImplementedException();
		}

        DeprovisionAction IMASynchronization.Deprovision (CSEntry csentry)
        {
			//
			// TODO: Remove this throw statement if you implement this method
			//
			throw new EntryPointNotImplementedException();
        }	

        bool IMASynchronization.FilterForDisconnection (CSEntry csentry)
        {
            //
            // TODO: write connector filter code
            //
            throw new EntryPointNotImplementedException();
		}

		void IMASynchronization.MapAttributesForJoin (string FlowRuleName, CSEntry csentry, ref ValueCollection values)
        {
			switch (FlowRuleName)
			{
				case "CompareU2Date":
					if (csentry["S.DOB"].IsPresent)
					{
						DateTime dtCSDOB = DateTime.Parse("31/12/1967").AddDays(csentry["S.DOB"].IntegerValue);
						values.Add(dtCSDOB.ToShortDateString());
					}
					break;

				case "MatchPhysicalDeliveryOfficeName":
					values.Add(csentry.MA.Name.Substring(0,5));
					break;

				default:	
					throw new EntryPointNotImplementedException();
			}
        }

        bool IMASynchronization.ResolveJoinSearch (string joinCriteriaName, CSEntry csentry, MVEntry[] rgmventry, out int imventry, ref string MVObjectType)
        {
			//
			// TODO: write join resolution code
			//
			throw new EntryPointNotImplementedException();
		}

        void IMASynchronization.MapAttributesForImport( string FlowRuleName, CSEntry csentry, MVEntry mventry)
        {

			#region declare variables
			// determine mail prefix
			string strname = csentry["S.PREF"].StringValue.ToLower() + "." + csentry["SURNAME"].StringValue.ToLower();
			strname = strname.Replace("`", "'");
			if (strname.IndexOfAny(arrInvalidChar) >= 0)
			{
				foreach (char charInvalidChar in arrInvalidChar)
				{strname = strname.Replace(charInvalidChar.ToString(), "");}
			}

			// determine mail suffix
			foreach (XmlNode xmlStudentMyMailSuffix in xmlStudentMyMailSuffixList)
			{
				if (xmlStudentMyMailSuffix.Attributes["code"].Value == csentry.MA.Name.Substring(0,5))
				{mailsuffix = xmlStudentMyMailSuffix["StudentMyMailSuffix"].InnerText;}
			}
			#endregion

			switch (FlowRuleName)
			{
				case "ConvertU2Date":
					DateTime dtDOB = DateTime.Parse("31/12/1967").AddDays(csentry["S.DOB"].IntegerValue);
					mventry["dateOfBirth"].Value = dtDOB.ToShortDateString();
					break;
				
				case "GenerateDateLastUpdated":
					mventry["dateLastUpdated"].Value = DateTime.Now.ToShortDateString();
					break;

				case "GenerateDisplayName":
					mventry["displayName"].Value = csentry["S.PREF"].StringValue;
					if (csentry["S.SECOND.INIT"].IsPresent)
					{
						mventry["displayName"].Value += " " + csentry["S.SECOND.INIT"].StringValue;
					}
					mventry["displayName"].Value += " " + csentry["SURNAME"].StringValue + " (" + csentry.MA.Name.Substring(0,5) + ")";
					break;

				case "GeneratePhysicalDeliveryOfficeName":
					mventry["physicalDeliveryOfficeName"].Value = csentry.MA.Name.Substring(0,5);
					break;

				case "GenerateSAMAccountName":
					bool blnAccountNameTruncated = false;
					int intSamAccountAffix = 0;
					string strSamAccountAttempt;
					string strSamAccountName = csentry["S.PREF"].StringValue + "." + csentry["SURNAME"].StringValue;
					
					// truncate samAccountName if too long
					if (strSamAccountName.Length >= 20)
					{
						strSamAccountName = csentry["SURNAME"].StringValue;
						blnAccountNameTruncated = true;
					}
					
					strSamAccountName = strSamAccountName.ToLower();

					// filter invalid username characters /\[]:;|=,+*?<>@" plus any other undesirables
					strSamAccountName = strSamAccountName.Replace("`", "'");
					if (strSamAccountName.IndexOfAny(arrInvalidChar) >= 0)
					{
						foreach (char charInvalidChar in arrInvalidChar)
						{strSamAccountName = strSamAccountName.Replace(charInvalidChar.ToString(), "");}
					}

					// check sAMAccountName is unique
					strSamAccountAttempt = strSamAccountName;
					MVEntry[] findResultList = null;
					while (!mventry["sAMAccountName"].IsPresent)
					{
						findResultList = Utils.FindMVEntries("sAMAccountName", strSamAccountAttempt);
						if (findResultList.Length == 0)
						{
							mventry["sAMAccountName"].Value = strSamAccountAttempt;
						}
						else
						{
							// append numeric affix to the user name
							intSamAccountAffix++;
							strSamAccountAttempt = strSamAccountName + intSamAccountAffix.ToString();
							
							// truncate samAccountName if too long
							if (!blnAccountNameTruncated && strSamAccountAttempt.Length >= 20)
							{
								strSamAccountName = csentry["SURNAME"].StringValue;
								blnAccountNameTruncated = true;
							}
						}
					}
					break;

				case "GenerateTitle":
					try
					{mventry["title"].Value = "Year " + Convert.ToInt16(csentry["S.YEAR"].StringValue).ToString() + " Student";}
					catch
					{mventry["title"].Value = "Year " + csentry["S.YEAR"].StringValue + " Student";}
					break;

				case "ResolveDbbEduYearLevel":
					try
					{mventry["dbbEduYearLevel"].Value = Convert.ToInt16(csentry["S.YEAR"].StringValue).ToString();}
					catch
					{mventry["dbbEduYearLevel"].Value = csentry["S.YEAR"].StringValue;}
					break;

				case "ResolveL":
					if (csentry["S.ADDRESS.1"].IsPresent && csentry["S.SUBURB"].IsPresent)
					{mventry["l"].Value = csentry["S.SUBURB"].StringValue;}
					else if (csentry["S.RES.ADDR2"].IsPresent && csentry["S.RES.SUB"].IsPresent)
					{mventry["l"].Value = csentry["S.RES.SUB"].StringValue;}
					break;

				case "ResolvePostalCode":
					if (csentry["S.ADDRESS.1"].IsPresent && csentry["S.POSTCODE"].IsPresent)
					{mventry["postalCode"].Value = csentry["S.POSTCODE"].StringValue;}
					else if (csentry["S.RES.ADDR2"].IsPresent && csentry["S.RES.POST"].IsPresent)
					{mventry["postalCode"].Value = csentry["S.RES.POST"].StringValue;}
					break;

				case "ResolveSt":
					if (csentry["S.ADDRESS.1"].IsPresent && csentry["S.STATE"].IsPresent)
					{mventry["st"].Value = csentry["S.STATE"].StringValue;}
					else if (csentry["S.RES.ADDR2"].IsPresent && csentry["S.RES.STATE"].IsPresent)
					{mventry["st"].Value = csentry["S.RES.STATE"].StringValue;}
					break;

				case "ResolveStreetAddress":
					if (csentry["S.ADDRESS.1"].IsPresent)
					{mventry["streetAddress"].Value = csentry["S.ADDRESS.1"].StringValue;}
					else if (csentry["S.RES.ADDR2"].IsPresent)
					{mventry["streetAddress"].Value = csentry["S.RES.ADDR2"].StringValue;}
					break;

				case "ResolvetargetAddress":
					mventry["targetAddress"].Value = "SMTP:" + strname + mailsuffix;
					break;

				case "Resolvemail":
					mventry["mail"].Value = strname + mailsuffix;
					break;

				case "ResolvemailNickname":
					mventry["mailNickname"].Value = strname;
					break;

				case "ResolveTelephoneNumber":
					if (csentry["S.ADDRESS.1"].IsPresent && csentry["S.PHONE"].IsPresent)
					{mventry["telephoneNumber"].Value = csentry["S.PHONE"].StringValue;}
					else if (csentry["S.RES.PHONE"].IsPresent)
					{mventry["telephoneNumber"].Value = csentry["S.RES.PHONE"].StringValue;}
					else if (csentry["S.PHONE"].IsPresent)
					{mventry["telephoneNumber"].Value = csentry["S.PHONE"].StringValue;}
					break;

				case "SetADGroupMembership":
					string role_level;
					string year_level;
					string dbbADSCode1;
					string dbbADSCode2;
					string dbbADSCode3;

					//Set AD role group
					mventry["dbbADSCode"].Values.Clear();
					role_level = csentry["S.CLASS.DESC"].StringValue;
					dbbADSCode1 = csentry.MA.Name.Substring(0,5) + role_level;
			
					//Set AD year group
					try
					{year_level = Convert.ToInt16(csentry["S.Year"].StringValue).ToString();}
					catch
					{year_level = csentry["S.YEAR"].StringValue;}
					if (csentry["S.YEAR"].StringValue.ToLower() == "k")
					{dbbADSCode2 = csentry.MA.Name.Substring(0,5) + 0;}
					else
					{dbbADSCode2 = csentry.MA.Name.Substring(0,5) + year_level;}

					//Set AD home folder group
					dbbADSCode3 = csentry.MA.Name.Substring(0,5) + "StudentHome";

					string[] dbbADSCodes = new string[3] {dbbADSCode1, dbbADSCode2, dbbADSCode3};
					foreach (string str in dbbADSCodes)	
					{mventry["dbbADSCode"].Values.Add(str);}
					break;
				default:

					throw new EntryPointNotImplementedException();
			}
        }

        void IMASynchronization.MapAttributesForExport (string FlowRuleName, MVEntry mventry, CSEntry csentry)
        {
            //
			// TODO: write your export attribute flow code
			//
            throw new EntryPointNotImplementedException();
        }
	}
}
