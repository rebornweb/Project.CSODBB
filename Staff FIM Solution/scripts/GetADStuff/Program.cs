using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.DirectoryServices;
using System.IO;
using System.Xml;

namespace GetADStuff
{
    class Program
    {
        static void Main(string[] args)
        {
            const string MODE_XML = "XML";
            const string BASE_XML = "<adObjects/>";

            DirectoryEntry de = new DirectoryEntry(Properties.Settings.Default.LdapRoot);
            DirectorySearcher ds = new DirectorySearcher(de, Properties.Settings.Default.LdapQuery);
            foreach (string property in Properties.Settings.Default.LdapProperties)
            {
                ds.PropertiesToLoad.Add(property);
            }
            ds.PageSize = 100;
            ds.SearchScope = SearchScope.Subtree;
            SearchResultCollection src = ds.FindAll();
            if (File.Exists(Properties.Settings.Default.FilePath + Properties.Settings.Default.Mode))
            {
                File.Delete(Properties.Settings.Default.FilePath + Properties.Settings.Default.Mode);
            }
            StreamWriter sw = null;
            XmlDocument dataDoc = null;
            if (Properties.Settings.Default.Mode.Equals(MODE_XML))
            {
                dataDoc = new XmlDocument();
                dataDoc.LoadXml(BASE_XML);
            }
            else
            {
                sw = new StreamWriter(Properties.Settings.Default.FilePath + Properties.Settings.Default.Mode, false);
                sw.Flush();
            }
            int rowCount = 0;
            if (src != null)
            {
                foreach (SearchResult sr in src)
                {
                    DirectoryEntry rde = sr.GetDirectoryEntry();
                    rowCount +=1;
                    if (Properties.Settings.Default.Mode.Equals(MODE_XML))
                    {
                        WriteToXML(dataDoc, rde, rowCount);
                    }
                    else
                    {
                        WriteToAVP(sw, rde, rowCount);
                    }
                    rde.Dispose();
                }
            }
            de.Dispose();
            if (Properties.Settings.Default.Mode.Equals(MODE_XML))
            {
                dataDoc.Save(Properties.Settings.Default.FilePath + Properties.Settings.Default.Mode);
            }
            else
            {
                sw.Close();
            }
        } 

        static private void WriteToXML(XmlDocument dataDoc, DirectoryEntry rde, int rowCount)
        {
            string objectClass = string.Empty;
            string adsCode = string.Empty;
            XmlNode node = dataDoc.DocumentElement.AppendChild(dataDoc.CreateElement("adObject"));
            node.Attributes.SetNamedItem(dataDoc.CreateAttribute("ix")).InnerText = rowCount.ToString();
            foreach (string adProp in Properties.Settings.Default.LdapProperties) //rde.Properties.PropertyNames)
            {
                foreach (string value in rde.Properties[adProp])
                {
                    node.Attributes.SetNamedItem(dataDoc.CreateAttribute(adProp)).InnerText = value;
                }
            }
            // determine object class
            XmlNode att = null;
            att = node.Attributes.GetNamedItem("info");
            if (att != null && att.InnerText.StartsWith("O"))
            {
                objectClass = "globalGroup";
                adsCode = att.InnerText;
            }
            att = node.Attributes.GetNamedItem("description");
            if (objectClass.Length.Equals(0) && att != null && att.InnerText.StartsWith("O"))
            {
                objectClass = "domainLocalGroup";
                adsCode = att.InnerText;
            }
            else
            {
                objectClass = "unmanagedGlobalGroup";
            //    adsCode = "X" + rowCount.ToString();
            }
            if (!adsCode.Length.Equals(0))
            {
                node.Attributes.SetNamedItem(dataDoc.CreateAttribute("adsCode")).InnerText = adsCode;
            }
            node.Attributes.SetNamedItem(dataDoc.CreateAttribute("objectClass")).InnerText = objectClass;
        } 

        static private void WriteToAVP(StreamWriter sw, DirectoryEntry rde, int rowCount)
        {
            string objectClass = string.Empty;
            string cn = string.Empty;
            string ads = string.Empty;
            string description = string.Empty;
            string sAMAccountName = string.Empty;
            string info = string.Empty;
            foreach (string adProp in rde.Properties.PropertyNames)
            {
                foreach (string value in rde.Properties[adProp])
                {
                    //record += value.ToString() + "|";
                    switch (adProp)
                    {
                        case "info":
                            info = value;
                            if (value.StartsWith("O"))
                            {
                                ads = value;
                                objectClass = "globalGroup";
                            }
                            break;
                        case "cn":
                            cn = value;
                            break;
                        case "description":
                            if (value.StartsWith("O"))
                            {
                                description = value;
                            }
                            break;
                        case "sAMAccountName":
                            sAMAccountName = value;
                            break;
                        default:
                            break;
                    }

                    //sw.WriteLine(string.Format("{0}: {1}", myKey, value));
                }
            }
            if (ads.Length.Equals(0) && !description.Length.Equals(0))
            {
                ads = description;
            }
            if (ads.Length.Equals(0))
            {
                ads = string.Format("X{0}", rowCount.ToString());
            }
            if (!ads.Length.Equals(0))
            {
                // only interested in ADS data!!!
                sw.WriteLine(string.Format("{0}: {1}", "ix", rowCount.ToString()));
                sw.WriteLine(string.Format("{0}: {1}", "adsCode", ads));
                sw.WriteLine(string.Format("{0}: {1}", "sAMAccountName", sAMAccountName));
                sw.WriteLine(string.Format("{0}: {1}", "cn", cn));
                if (info.Length.Equals(0))
                {
                    sw.WriteLine(string.Format("{0}: {1}", "info", info));
                }
                if (objectClass.Length.Equals(0))
                {
                    if (cn.EndsWith("-G"))
                    {
                        objectClass = "unmanagedGlobalGroup";
                    }
                    else
                    {
                        objectClass = "domainLocalGroup";
                    }
                }
                sw.WriteLine(string.Format("{0}: {1}", "objectClass", objectClass));
                //sw.WriteLine(record.Remove(record.Length - 1, 1));
                sw.WriteLine();
            }
        }
    }
}
