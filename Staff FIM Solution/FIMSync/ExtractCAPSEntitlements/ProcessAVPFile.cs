using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Xml;

namespace ExtractCAPSEntitlements
{
    class ProcessAVPFile
    {
        private const string XML_FN = "AVPInput.xml";
        private const string XML_BASE = "<capsData/>";
        private const string TEST_RANGE = ""; //TODO: leave as empty string; for testing purposes reset this to say "07", but remove once tested!!!

        public ProcessAVPFile(string avpInputFileName, string xmlOutputFileName)
        {
            if (File.Exists(avpInputFileName))
            {
                // Open the stream and read it back.
                using (StreamReader sr = File.OpenText(avpInputFileName))
                {
                    byte[] b = new byte[1024];
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.LoadXml(XML_BASE);
                    XmlNode nodObject = null;
                    String avpLine = null;
                    while ((avpLine = sr.ReadLine()) != null)
                    {
                        if (nodObject == null)
                        {
                            nodObject = xmlDoc.DocumentElement.AppendChild(xmlDoc.CreateElement("object"));
                        }
                        // this AVP file doesn't contain any multi-line data, so no need to handle
                        if (avpLine.Length.Equals(0))
                        {
                            if (nodObject.Attributes["ObjectType"].Value.Equals("person"))
                            {
                                ExtractSiteFromPerson(xmlDoc, nodObject);
                                if (nodObject.SelectNodes("roles/role").Count > 0)
                                {
                                    ExtractEntitlementsFromPerson(xmlDoc, nodObject);
                                }
                            }
                            string trace = string.Format("{0}: {1}", nodObject.Attributes["ObjectType"].Value, nodObject.Attributes["ID"].Value);
#if DEBUG
                            //Console.WriteLine(trace);
#endif
                            nodObject = null;
                        }
                        else
                        {
                            if (avpLine.Contains(":"))
                            {
                                AppendObjectAttribute(xmlDoc, nodObject, avpLine);
                            }
                            else
                            {
                                throw new ApplicationException(String.Format("Line <{0}> is not a valid attribute/value pair", avpLine));
                            }
                        }
                    }
                    SaveOutputFileIfUpdated(xmlDoc, avpInputFileName, xmlOutputFileName);
                }
            }
            else
            {
                throw new ApplicationException(String.Format("File {0} does not exist",avpInputFileName));
            }
        }

        private void SaveOutputFileIfUpdated(XmlDocument xmlDoc, string avpInputFileName, string xmlOutputFileName)
        {
            string filePath = Path.GetDirectoryName(avpInputFileName);
            string newFile = xmlOutputFileName.ToLower().Replace(".xml", ".new");
            xmlDoc.Save(Path.Combine(filePath, newFile));

            // compare new file to the old one
            XmlDocument xmlDocOriginal = new XmlDocument();
            bool originalExists = File.Exists(Path.Combine(filePath, xmlOutputFileName));
            if (originalExists)
            {
                xmlDocOriginal.Load(Path.Combine(filePath, xmlOutputFileName));
            }
            if (originalExists && xmlDocOriginal.InnerXml.Equals(xmlDoc.InnerXml))
            {
                // Do Nothing
            }
            else
            {
                // Copy new file over existing one
                File.Copy(Path.Combine(filePath, newFile), Path.Combine(filePath, xmlOutputFileName), true);
            }
        }

        #region "Process Object"
        private void AppendObjectAttribute(XmlDocument xmlDoc, XmlNode nodObject, string avpLine)
        {
            string attName = avpLine.Split(':')[0];
            string attValue = avpLine.Split(':')[1];
            XmlAttribute attObjectType = nodObject.Attributes["ObjectType"];
            string objectType = string.Empty;
            if (attObjectType != null)
            {
                objectType = attObjectType.Value;
            }
            XmlNode nodRole = null;
            XmlAttribute attr = null;
            switch (attName)
            {
                case "ADS.CODE":
                    // Add a new role to the object's role collection.
                    if (objectType == "person")
                    {
                        AppendADSRoleNode(xmlDoc, nodObject, AppendADSRolesNode(xmlDoc, nodObject), attValue);
                    }
                    break;
                case "ADS.START":
                    if (objectType == "person" && !attValue.Split('_')[1].Length.Equals(0))
                    {
                        // Add a new role to the object's role collection and set the start date
                        nodRole = AppendADSRoleNode(xmlDoc, nodObject, AppendADSRolesNode(xmlDoc, nodObject), attValue.Split('_')[0]);
                        if (nodRole != null)
                        {
                            attr = xmlDoc.CreateAttribute(attName);
                            attr.Value = GetDateFromInterval(attValue.Split('_')[1]);
                            nodRole.Attributes.SetNamedItem(attr);
                        }
                    }
                    break;
                case "ADS.END":
                    if (objectType == "person" && !attValue.Split('_')[1].Length.Equals(0))
                    {
                        // Add a new role to the object's role collection and set the end date
                        nodRole = AppendADSRoleNode(xmlDoc, nodObject, AppendADSRolesNode(xmlDoc, nodObject), attValue.Split('_')[0]);
                        if (nodRole != null)
                        {
                            attr = xmlDoc.CreateAttribute(attName);
                            attr.Value = GetDateFromInterval(attValue.Split('_')[1]);
                            nodRole.Attributes.SetNamedItem(attr);
                        }
                    }
                    break;
                case "PERS.PINS":
                    string currentValue = string.Empty;
                    if (nodObject.Attributes.GetNamedItem(attName) != null)
                    {
                        currentValue = nodObject.Attributes.GetNamedItem(attName).Value + ";";
                    }
                    currentValue += attValue;
                    attr = xmlDoc.CreateAttribute(attName);
                    attr.Value = currentValue;
                    nodObject.Attributes.SetNamedItem(attr);
                    break;
                case "PERS.DOB":
                    attr = xmlDoc.CreateAttribute(attName);
                    attr.Value = GetDateFromInterval(attValue);
                    nodObject.Attributes.SetNamedItem(attr);
                    break;
                default:
                    // Add a new attribute to the object collection.
                    attr = xmlDoc.CreateAttribute(attName);
                    attr.Value = attValue;
                    nodObject.Attributes.SetNamedItem(attr);
                    break;
            }
        }

        private string GetDateFromInterval(string adsInterval)
        {

            string dateValue = string.Empty;
            int days = 0;
            if (int.TryParse(adsInterval, out days))
            {
                dateValue = GetFIMDateString(DateTime.Parse("31/12/1967").AddDays(days));
            }
            return dateValue;
        }

        private string GetFIMDateString(DateTime dateToConvert)
        {
            const string strTimeFormatString = "yyyy-MM-ddTHH:mm:00.000";
            return dateToConvert.ToUniversalTime().ToString(strTimeFormatString);
        }


        private XmlNode AppendADSRolesNode(XmlDocument xmlDoc, XmlNode nodPerson)
        {
            XmlNode nodRoles = nodPerson.SelectSingleNode("roles");
            if (nodRoles == null)
            {
                nodRoles = nodPerson.AppendChild(xmlDoc.CreateElement("roles"));
            }
            return nodRoles;
        }

        private XmlNode AppendADSRoleNode(XmlDocument xmlDoc, XmlNode nodPerson, XmlNode nodRoles, string adsCode)
        {
            XmlNode nodRole = nodRoles.SelectSingleNode("role[@ADS.CODE='" + adsCode + "']");
            XmlAttributeCollection attrColl = null;
            XmlAttribute attr = null;
            // test range only - REMOVE ONCE TESTED
            if (TEST_RANGE.Length.Equals(0) || adsCode.StartsWith(TEST_RANGE))
            {
                if (nodRole == null)
                {
                    nodRole = nodRoles.AppendChild(xmlDoc.CreateElement("role"));
                }
                attrColl = nodRole.Attributes;
                attr = xmlDoc.CreateAttribute("ADS.CODE");
                attr.Value = adsCode;
                attrColl.SetNamedItem(attr);
            }
            return nodRole;
        }
#endregion 

        #region "Process Entitlements"
        private void ExtractSiteFromPerson(XmlDocument xmlDoc, XmlNode nodPerson)
        {
            XmlAttribute attSite = nodPerson.Attributes["SAL.SCHOOL"];
            if (attSite != null)
            {
                // locate any existing site node and create one if not found
                XmlNode nodSite = xmlDoc.DocumentElement.SelectSingleNode("object[@ObjectType='site'][@ID='" + attSite.Value + "']");
                if (nodSite == null)
                {
                    nodSite = xmlDoc.DocumentElement.AppendChild(xmlDoc.CreateElement("object"));
                    XmlAttribute attr = xmlDoc.CreateAttribute("ObjectType");
                    attr.Value = "site";
                    nodSite.Attributes.SetNamedItem(attr);
                    attr = xmlDoc.CreateAttribute("ID");
                    attr.Value = attSite.Value;
                    nodSite.Attributes.SetNamedItem(attr);
                }
            }
        }

        private void ExtractEntitlementsFromPerson(XmlDocument xmlDoc, XmlNode nodPerson)
        {
            foreach (XmlNode nodRole in nodPerson.SelectNodes("roles/role"))
            {
                AppendEntitlementNode(xmlDoc, nodPerson, nodRole);
            }
        }

        /// <summary>
        /// Append an entitlement node for every unique PIN / START / END combo (allows for multiple roles per entitlement)
        /// </summary>
        /// <param name="xmlDoc"></param>
        /// <param name="nodRole"></param>
        /// <returns></returns>
        private void AppendEntitlementNode(XmlDocument xmlDoc, XmlNode nodPerson, XmlNode nodRole)
        {
            string personPIN = nodPerson.Attributes.GetNamedItem("PERS.PIN").Value;
            string adsCode = nodRole.Attributes.GetNamedItem("ADS.CODE").Value;
            string xpath = "object[@ObjectType='entitlement'][@PERS.PIN='" + personPIN + "']";
            string startDateAsString = string.Empty;
            string endDateAsString = string.Empty;
            string id = personPIN;

            XmlAttribute attr = (XmlAttribute)nodRole.Attributes.GetNamedItem("ADS.START");
            if (attr != null)
            {
                startDateAsString = attr.Value;
                xpath += "[@ADS.START='" + startDateAsString + "']";
            }
            // BB, 5/3/2013
            else
            {
                endDateAsString = string.Empty;
                xpath += "[not(@ADS.START)]";
            }
            attr = (XmlAttribute)nodRole.Attributes.GetNamedItem("ADS.END");
            if (attr != null)
            {
                endDateAsString = attr.Value;
                xpath += "[@ADS.END='" + endDateAsString + "']";
            }
            // BB, 5/3/2013
            else
            {
                endDateAsString = string.Empty;
                xpath += "[not(@ADS.END)]";
            }
            XmlNode nodEntitlement = xmlDoc.DocumentElement.SelectSingleNode(xpath);
            if (nodEntitlement == null)
            {
                nodEntitlement = xmlDoc.DocumentElement.AppendChild(xmlDoc.CreateElement("object"));
                attr = xmlDoc.CreateAttribute("ObjectType");
                attr.Value = "entitlement";
                nodEntitlement.Attributes.SetNamedItem(attr);
                attr = xmlDoc.CreateAttribute("PERS.PIN");
                attr.Value = personPIN;
                nodEntitlement.Attributes.SetNamedItem(attr);
                if (startDateAsString.Length > 0)
                {
                    attr = xmlDoc.CreateAttribute("ADS.START");
                    attr.Value = startDateAsString;
                    nodEntitlement.Attributes.SetNamedItem(attr);
                    id += "-" + DateTime.Parse(startDateAsString).ToString("yyyyMMdd");
                }
                if (endDateAsString.Length > 0)
                {
                    attr = xmlDoc.CreateAttribute("ADS.END");
                    attr.Value = endDateAsString;
                    nodEntitlement.Attributes.SetNamedItem(attr);
                    id += "-" + DateTime.Parse(endDateAsString).ToString("yyyyMMdd");
                }
                attr = xmlDoc.CreateAttribute("ID");
                attr.Value = id;
                nodEntitlement.Attributes.SetNamedItem(attr);
                nodEntitlement.AppendChild(xmlDoc.CreateElement("roles"));
            }
            XmlNode nodRoles = nodEntitlement.SelectSingleNode("roles");
            XmlNode nodEntRole = nodRoles.AppendChild(xmlDoc.CreateElement("role"));
            attr = xmlDoc.CreateAttribute("ADS.CODE");
            attr.Value = adsCode;
            nodEntRole.Attributes.SetNamedItem(attr);
        }
        #endregion
    }
}
