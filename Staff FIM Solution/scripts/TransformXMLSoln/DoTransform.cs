using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.IO;
using System.Windows.Forms;
using System.Xml;
using System.Xml.Xsl;

namespace TransformXML
{
    public partial class frmDoTransform : Form
    {
        public frmDoTransform()
        {
            InitializeComponent();
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void frmDoTransform_Load(object sender, EventArgs e)
        {
            try
            {
                InitializeDialogs();
                SetSaveButtonAvailability();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Application Configuration Error:" + ex.Message);
                MessageBox.Show("Application shutting down ... please correct configuration and try again.");
                this.Close();
            }
        }

        private void InitializeDialogs()
        {
            openXmlFile = new OpenFileDialog();
            openXmlFile.DefaultExt = ".xml";
            if (!Directory.Exists(Properties.Settings.Default.XmlFilePath))
            {
                throw new Exception("Configuration property XmlFilePath is invalid.");
            }
            openXmlFile.InitialDirectory = Properties.Settings.Default.XmlFilePath;

            openXslFile = new OpenFileDialog();
            openXslFile.DefaultExt = ".xsl*";
            openXslFile.InitialDirectory = Properties.Settings.Default.XslFilePath; // Application.StartupPath;
            openXslFile.FileName = Properties.Settings.Default.XslFileName;

            saveTransformedFile = new SaveFileDialog();
            saveTransformedFile.DefaultExt = ".htm";
            saveTransformedFile.InitialDirectory = Properties.Settings.Default.XmlFilePath;
        }

        private void SetSaveButtonAvailability()
        {
            if (this.txtTransformedOut.Text.Length.Equals(0)
                || this.txtXmlIn.Text.Length.Equals(0)
                || this.txtXslIn.Text.Length.Equals(0))
            {
                this.btnSave.Enabled = false;
            }
            else
            {
                this.btnSave.Enabled = true;
            }
        }

        private void btnXmlIn_Click(object sender, EventArgs e)
        {
            if (openXmlFile.ShowDialog() == DialogResult.OK)
            {
                this.txtXmlIn.Text = openXmlFile.FileName;
            }
            SetDefaultTransformedOut();
            SetSaveButtonAvailability();
        }

        private void btnXslIn_Click(object sender, EventArgs e)
        {
            if (openXslFile.ShowDialog() == DialogResult.OK)
            {
                this.txtXslIn.Text = openXslFile.FileName;
                this.txtTransformedOut.Clear();
            }
            SetDefaultTransformedOut();
            SetSaveButtonAvailability();
        }

        private void btnTransformedOut_Click(object sender, EventArgs e)
        {
            if (saveTransformedFile.ShowDialog() == DialogResult.OK)
            {
                this.txtTransformedOut.Text = saveTransformedFile.FileName;
            }
            SetSaveButtonAvailability();
        }

        private void SetDefaultTransformedOut()
        {
            if (this.txtTransformedOut.Text.Length.Equals(0))
            {
                string newFileExtn = string.Format(".{0}.html", DateTime.Now.ToFileTimeUtc());
                this.txtTransformedOut.Text = this.txtXmlIn.Text.Replace(".xml", newFileExtn);
            }
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
            if (!File.Exists(this.txtXmlIn.Text))
            {
                MessageBox.Show("Please select a valid xml file to transform");
                this.txtXmlIn.Focus();
            }
            else if (!File.Exists(this.txtXslIn.Text))
            {
                MessageBox.Show("Please select a valid transform file");
                this.txtXslIn.Focus();
            }
            else if (!Directory.Exists(Path.GetDirectoryName(this.txtTransformedOut.Text)))
            {
                MessageBox.Show("Please select a valid output directory");
                this.txtTransformedOut.Focus();
            }
            else
            {
                this.Cursor = Cursors.WaitCursor;
                this.Enabled = false;
                try
                {
                    XsltSettings xslSettings = new XsltSettings(true,true);
                    //xslSettings.EnableScript = true;
                    //xslSettings.EnableDocumentFunction = true;
                    XslCompiledTransform xslToUse = new XslCompiledTransform(false);
                    xslToUse.Load(this.txtXslIn.Text, xslSettings, new XmlUrlResolver());
                    xslToUse.Transform(this.txtXmlIn.Text, this.txtTransformedOut.Text);
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message);
                }
                this.Enabled = true;
                this.Cursor = Cursors.Default;
            }
        }

        private void btnReset_Click(object sender, EventArgs e)
        {
            this.txtXslIn.Clear();
            this.txtXmlIn.Clear();
            this.txtTransformedOut.Clear();
        }

    }
}
