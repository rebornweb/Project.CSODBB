using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.IdentityManagement.WebUI.Controls;
using System.Web.UI.WebControls;

namespace UnifySolutions.FIM.GenerateUniqueAccountNameLibrary
{
	public class GenerateUniqueAccountNameUI : ActivitySettingsPart
	{

        /// <summary>
        /// Called when a user clicks the Save button in the Workflow Designer. 
        /// Returns an instance of the RequestLoggingActivity class that 
        /// has its properties set to the values entered into the text box controls
        /// used in the UI of the activity. 
        /// </summary>
        public override System.Workflow.ComponentModel.Activity GenerateActivityOnWorkflow(Microsoft.ResourceManagement.Workflow.Activities.SequentialWorkflow workflow)
        {
            if (!this.ValidateInputs())
            {
                return null;
            }
            GenerateUniqueAccountName generatUniqueAccountName = new GenerateUniqueAccountName();
            // generatUniqueAccountName.Name = this.GetText("txtActivityName");
            generatUniqueAccountName.ActivityTitle = this.GetText("txtActivityTitle");
            // generatUniqueAccountName.UniqueAccountNameExpression = this.GetText("txtUniqueAccountNameInput");
            generatUniqueAccountName.AccountNameOption1 = this.GetText("txtAccountNameOption1");
            // generatUniqueAccountName.AccountNameOption2 = this.GetText("txtAccountNameOption2");
            // generatUniqueAccountName.AccountNameOption3 = this.GetText("txtAccountNameOption3");
            // generatUniqueAccountName.AccountNameOption4 = this.GetText("txtAccountNameOption4");
            // generatUniqueAccountName.AccountNameOption5 = this.GetText("txtAccountNameOption5");
            generatUniqueAccountName.NumberOfAccountNameOptions = this.GetText("txtNumberOfAccountNameOption");
            generatUniqueAccountName.UniqueAccountNameCounter = this.GetText("txtUniqueAccountNameIteration");
            generatUniqueAccountName.LogFileName = this.GetText("txtLogFileName");
            generatUniqueAccountName.RemoveCharactersNotAllowed = this.GetIsChecked("cbRemoveCharactersNotAllowed");
            return generatUniqueAccountName;
        }

        public override void LoadActivitySettings(System.Workflow.ComponentModel.Activity activity)
        {
            GenerateUniqueAccountName generatUniqueAccountName = activity as GenerateUniqueAccountName;
            if (null != generatUniqueAccountName)
            {
                // this.SetText("txtActivityName", generatUniqueAccountName.Name);
                this.SetText("txtActivityTitle", generatUniqueAccountName.ActivityTitle);
                // this.SetText("txtUniqueAccountNameInput", generatUniqueAccountName.UniqueAccountNameExpression);
                this.SetText("txtAccountNameOption1", generatUniqueAccountName.AccountNameOption1);
                // this.SetText("txtAccountNameOption2", generatUniqueAccountName.AccountNameOption2);
                // this.SetText("txtAccountNameOption3", generatUniqueAccountName.AccountNameOption3);
                // this.SetText("txtAccountNameOption4", generatUniqueAccountName.AccountNameOption4);
                // this.SetText("txtAccountNameOption5", generatUniqueAccountName.AccountNameOption5);
                this.SetText("txtNumberOfAccountNameOption", generatUniqueAccountName.NumberOfAccountNameOptions);
                this.SetText("txtUniqueAccountNameIteration", generatUniqueAccountName.UniqueAccountNameCounter);
                this.SetText("txtLogFileName", generatUniqueAccountName.LogFileName);
                this.SetIsChecked("cbRemoveCharactersNotAllowed", generatUniqueAccountName.RemoveCharactersNotAllowed);
            }
        }

        /// <summary>
        /// Saves the activity settings.
        /// </summary>
        public override ActivitySettingsPartData PersistSettings()
        {
            ActivitySettingsPartData data = new ActivitySettingsPartData();
            // data["ActivityName"] = this.GetText("txtActivityName");
            data["ActivityTitle"] = this.GetText("txtActivityTitle");
            // data["UniqueAccountNameInput"] = this.GetText("txtUniqueAccountNameInput");
            data["AccountNameOption1Data"] = this.GetText("txtAccountNameOption1");
            // data["AccountNameOption2Data"] = this.GetText("txtAccountNameOption2");
            // data["AccountNameOption3Data"] = this.GetText("txtAccountNameOption3");
            // data["AccountNameOption4Data"] = this.GetText("txtAccountNameOption4");
            // data["AccountNameOption5Data"] = this.GetText("txtAccountNameOption5");
            data["NumberOfAccountNameOptions"] = this.GetText("txtNumberOfAccountNameOption");
            data["UniqueAccountNameIteration"] = this.GetText("txtUniqueAccountNameIteration");
            data["LogFileName"] = this.GetText("txtLogFileName");
            data["RemoveCharactersNotAllowed"] = this.GetIsChecked("cbRemoveCharactersNotAllowed");
            return data;
        }

        /// <summary>
        ///  Restores the activity settings in the UI
        /// </summary>
        public override void RestoreSettings(ActivitySettingsPartData data)
        {
            if (null != data)
            {
                // this.SetText("txtActivityName", (string)data["ActivityName"]);
                this.SetText("txtActivityTitle", (string)data["ActivityTitle"]);
                // this.SetText("txtUniqueAccountNameInput", (string)data["UniqueAccountNameInput"]);
                this.SetText("txtAccountNameOption1", (string)data["AccountNameOption1Data"]);
                // this.SetText("txtAccountNameOption2", (string)data["AccountNameOption2Data"]);
                // this.SetText("txtAccountNameOption3", (string)data["AccountNameOption3Data"]);
                // this.SetText("txtAccountNameOption4", (string)data["AccountNameOption4Data"]);
                // this.SetText("txtAccountNameOption5", (string)data["AccountNameOption5Data"]);
                this.SetText("txtNumberOfAccountNameOption", (string)data["NumberOfAccountNameOptions"]);
                this.SetText("txtUniqueAccountNameIteration", (string)data["UniqueAccountNameIteration"]);
                this.SetText("txtLogFileName", (string)data["LogFileName"]);
                this.SetIsChecked("cbRemoveCharactersNotAllowed", (bool)data["RemoveCharactersNotAllowed"]);
            }
        }

        /// <summary>
        ///  Switches the activity between read only and read/write mode
        /// </summary>
        public override void SwitchMode(ActivitySettingsPartMode mode)
        {
            bool readOnly = (mode == ActivitySettingsPartMode.View);
            // this.SetTextBoxReadOnlyOption("txtActivityName", readOnly);
            this.SetTextBoxReadOnlyOption("txtActivityTitle", readOnly);
            // this.SetTextBoxReadOnlyOption("txtUniqueAccountNameInput", readOnly);
            this.SetTextBoxReadOnlyOption("txtAccountNameOption1", readOnly);
            // this.SetTextBoxReadOnlyOption("txtAccountNameOption2", readOnly);
            // this.SetTextBoxReadOnlyOption("txtAccountNameOption3", readOnly);
            // this.SetTextBoxReadOnlyOption("txtAccountNameOption4", readOnly);
            // this.SetTextBoxReadOnlyOption("txtAccountNameOption5", readOnly);
            this.SetTextBoxReadOnlyOption("txtNumberOfAccountNameOption", readOnly);
            this.SetTextBoxReadOnlyOption("txtUniqueAccountNameIteration", readOnly);
            this.SetTextBoxReadOnlyOption("txtLogFileName", readOnly);
            this.SetCheckBoxReadOnlyOption("cbRemoveCharactersNotAllowed", readOnly);
        }

        /// <summary>
        ///  Returns the activity name.
        /// </summary>
        public override string Title
        {
            get { return "Generate Unique AccountName Activity"; }
        }

        /// <summary>
        ///  In general, this method should be used to validate information entered
        ///  by the user when the activity is added to a workflow in the Workflow
        ///  Designer.
        ///  We could add code to verify that the log file path already exists on
        ///  the server that is hosting the FIM Portal and check that the activity
        ///  has permission to write to that location. However, the code
        ///  would only check if the log file path exists when the
        ///  activity is added to a workflow in the workflow designer. This class
        ///  will not be used when the activity is actually run.
        ///  For this activity we will just return true.
        /// </summary>
        public override bool ValidateInputs()
        {
            return true;
        }

        /// <summary>
        ///  Creates a Table that contains the controls used by the activity UI
        ///  in the Workflow Designer of the FIM portal. Adds that Table to the
        ///  collection of Controls that defines each activity that can be selected
        ///  in the Workflow Designer of the FIM Portal. Calls the base class of 
        ///  ActivitySettingsPart to render the controls in the UI.
        /// </summary>
        protected override void CreateChildControls()
        {
            Table controlLayoutTable;
            controlLayoutTable = new Table();

            //Width is set to 100% of the control size
            controlLayoutTable.Width = Unit.Percentage(100.0);
            controlLayoutTable.BorderWidth = 0;
            controlLayoutTable.CellPadding = 2;
            //Add a TableRow for each textbox in the UI 
            // controlLayoutTable.Rows.Add(this.AddTableRowTextBox("Display Name:", "txtActivityName", 400, 100, false, "Enter the activity name."));
            controlLayoutTable.Rows.Add(this.AddTableRowTextBox("Activity Display Name:", "txtActivityTitle", 400, 100, false, "Enter the activity name."));
            // controlLayoutTable.Rows.Add(this.AddTableRowTextBox("Unique AccountName Input:", "txtUniqueAccountNameInput", 400, 100, false, "Enter Workflow parameter."));
            controlLayoutTable.Rows.Add(this.AddTableRowTextBox("AccountName Format Option:", "txtAccountNameOption1", 400, 100, false, "Enter AccountName format option workflow parameter without the postfix number."));
            // controlLayoutTable.Rows.Add(this.AddTableRowTextBox("AccountName Option 2:", "txtAccountNameOption2", 400, 100, false, "Enter Workflow parameter option 2."));
            // controlLayoutTable.Rows.Add(this.AddTableRowTextBox("AccountName Option 3:", "txtAccountNameOption3", 400, 100, false, "Enter Workflow parameter option 3."));
            // controlLayoutTable.Rows.Add(this.AddTableRowTextBox("AccountName Option 4:", "txtAccountNameOption4", 400, 100, false, "Enter Workflow parameter option 4."));
            // controlLayoutTable.Rows.Add(this.AddTableRowTextBox("AccountName Option 5:", "txtAccountNameOption5", 400, 100, false, "Enter Workflow parameter option 5."));
            controlLayoutTable.Rows.Add(this.AddTableRowTextBox("Number Of AccountName Format Options:", "txtNumberOfAccountNameOption", 400, 100, false, "Enter the number of AccountName format options."));
            controlLayoutTable.Rows.Add(this.AddTableRowTextBox("Number Of Iteration for last AccountName Format Option:", "txtUniqueAccountNameIteration", 400, 100, false, "Enter the number of iterations for the last AccountName format option."));
            controlLayoutTable.Rows.Add(this.AddTableRowTextBox("Log FileName (with fullpath):", "txtLogFileName", 400, 100, false, ""));
            // This should not be an option
            // controlLayoutTable.Rows.Add(this.AddTableRowTextBox("RemoveIllegalCharacters:", "txtUniqueAccountNameIteration", 400, 100, false, "Enter the number of appending number to be appended."));
            controlLayoutTable.Rows.Add(this.AddTableRowCheckBox("Remove Not Allowed Characters:", "cbRemoveCharactersNotAllowed", true));
            this.Controls.Add(controlLayoutTable);
            
            base.CreateChildControls();
        }

        #region Utility Functions
        //Create a TableRow that contains a label and a textbox.
        private TableRow AddTableRowTextBox(String labelText, String controlID, int width, int
                                             maxLength, Boolean multiLine, String defaultValue)
        {
            TableRow row = new TableRow();
            TableCell labelCell = new TableCell();
            TableCell controlCell = new TableCell();
            Label oLabel = new Label();
            TextBox oText = new TextBox();

            oLabel.Text = labelText;
            oLabel.CssClass = base.LabelCssClass;
            labelCell.Controls.Add(oLabel);
            oText.ID = controlID;
            oText.CssClass = base.TextBoxCssClass;
            oText.Text = defaultValue;
            oText.MaxLength = maxLength;
            oText.Width = width;
            if (multiLine)
            {
                oText.TextMode = TextBoxMode.MultiLine;
                oText.Rows = System.Math.Min(6, (maxLength + 60) / 60);
                oText.Wrap = true;
            }
            controlCell.Controls.Add(oText);
            row.Cells.Add(labelCell);
            row.Cells.Add(controlCell);
            return row;
        }

        string GetText(string textBoxID)
        {
            TextBox textBox = (TextBox)this.FindControl(textBoxID);
            return textBox.Text ?? String.Empty;
        }
        void SetText(string textBoxID, string text)
        {
            TextBox textBox = (TextBox)this.FindControl(textBoxID);
            if (textBox != null)
                textBox.Text = text;
            else
                textBox.Text = "";
        }

        //Set the text box to read mode or read/write mode
        void SetTextBoxReadOnlyOption(string textBoxID, bool readOnly)
        {
            TextBox textBox = (TextBox)this.FindControl(textBoxID);
            textBox.ReadOnly = readOnly;
        }

 
        private TableRow AddTableRowCheckBox(string labelText, string controlID, bool defaultValue)
        {
            TableRow row = new TableRow();
            TableCell labelCell = new TableCell();
            TableCell controlCell = new TableCell();
            Label label = new Label();
            CheckBox checkbox = new CheckBox();

            label.Text = labelText;
            label.CssClass = this.LabelCssClass;
            labelCell.Controls.Add(label);

            checkbox.ID = controlID;
            checkbox.Checked = defaultValue;

            controlCell.Controls.Add(checkbox);
            row.Cells.Add(labelCell);
            row.Cells.Add(controlCell);
            return row;
        }
    
        private bool GetIsChecked(string checkBoxID) 
        {
            CheckBox checkBox = (CheckBox)(this.FindControl(checkBoxID));
            return checkBox.Checked;
        }

        private void SetIsChecked(string checkBoxID, bool isChecked)
        {
            CheckBox checkBox = (CheckBox)(this.FindControl(checkBoxID));
            // if (checkBox IsNot Nothing Then
            // if (checkBox.Checked)
            {
                checkBox.Checked = isChecked;
            }
            // else
            // {
                // checkBox.Checked = true;
            // }
        }

        private void SetCheckBoxReadOnlyOption(string textBoxID, bool readOnly)
        {
            CheckBox checkBox = (CheckBox)(this.FindControl(textBoxID));
            checkBox.Enabled = !readOnly;
        }
        #endregion
    }
}
