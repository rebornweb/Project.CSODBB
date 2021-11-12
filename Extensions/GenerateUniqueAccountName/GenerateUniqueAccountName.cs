using System;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections;
using System.Drawing;
using System.Linq;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;
using Microsoft.ResourceManagement.Workflow.Activities;
using Microsoft.ResourceManagement.WebServices.WSResourceManagement;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
namespace UnifySolutions.FIM.GenerateUniqueAccountNameLibrary
{
    public partial class GenerateUniqueAccountName : SequenceActivity
    {
        const string FIMADMIN_GUID = "7fb2b853-24f0-4498-9534-4e10589723c4";
        const int NUMBER_OF_ACCOUNTNAME_OPTIONS = 10;
        const int AD_SAMACCOUNTNAME_MAX_LENGTH = 20;
        private bool _bUniqueAttributeValueIsFound = false; // For binding with the IfElseActivity condition
        private string[] AccountNames; // List of AccountNames for checking the duplication
        private string returnUniqueAccountName = ""; // the unique AccountName found
        private int _loopCount = 0;
        private bool _loopAgain = true; // For binding with the WhileActivity condition
        private int _numberOfIterations = 0;
        private int _numberOfOptions = 0;
        // private const string[] CharNotAllowed = new string[] { "\"", "/", "\\", "[", "]", ":", ";", "|", "=", ",", "+", "*", "?", "<", ">" };
        // private const string CharNotAllowed = "\"|/|\\|[|]|:|;||=|,|+|*|?|<|>";
        private const string notAllowChars = "\" / \\ [ ] : ; | = , + * ? < >";
        Regex AllowedCharactersRegEx = new Regex("[^a-zA-Z0-9.]");

        private string _logFilename = "C:\\Temp\\FIMWorkflowCustomActivity.log";
        private bool _logginOn = false;
        public static DependencyProperty ActivityTitleProperty = DependencyProperty.Register("ActivityTitle", typeof(string), typeof(GenerateUniqueAccountName));
        public static DependencyProperty AccountNameOption1Property = DependencyProperty.Register("AccountNameOption1", typeof(string), typeof(GenerateUniqueAccountName));
        // public static DependencyProperty AccountNameOption2Property = DependencyProperty.Register("AccountNameOption2", typeof(string), typeof(GenerateUniqueAccountName));
        // public static DependencyProperty AccountNameOption3Property = DependencyProperty.Register("AccountNameOption3", typeof(string), typeof(GenerateUniqueAccountName));
        // public static DependencyProperty AccountNameOption4Property = DependencyProperty.Register("AccountNameOption4", typeof(string), typeof(GenerateUniqueAccountName));
        // public static DependencyProperty AccountNameOption5Property = DependencyProperty.Register("AccountNameOption5", typeof(string), typeof(GenerateUniqueAccountName));
        public static DependencyProperty NumberOfAccountNameOptionsProperty = DependencyProperty.Register("NumberOfAccountNameOptions", typeof(string), typeof(GenerateUniqueAccountName));
        public static DependencyProperty UniqueAccountNameCounterProperty = DependencyProperty.Register("UniqueAccountNameCounter", typeof(string), typeof(GenerateUniqueAccountName));
        public static DependencyProperty LogFileNameProperty = DependencyProperty.Register("LogFileName", typeof(string), typeof(GenerateUniqueAccountName));
        public static DependencyProperty RemoveCharactersNotAllowedProperty = DependencyProperty.Register("RemoveCharactersNotAllowed", typeof(bool), typeof(GenerateUniqueAccountName));
        public GenerateUniqueAccountName()
        {
            InitializeComponent();
        }
        public string ActivityTitle
        {
            get { return (string)this.GetValue(GenerateUniqueAccountName.ActivityTitleProperty); }
            set { this.SetValue(GenerateUniqueAccountName.ActivityTitleProperty, value); }
        }
        public string LogFileName
        {
            get { return (string)this.GetValue(GenerateUniqueAccountName.LogFileNameProperty); }
            set { this.SetValue(GenerateUniqueAccountName.LogFileNameProperty, value); }
        }
        public string AccountNameOption1
        {
            get { return (string)this.GetValue(GenerateUniqueAccountName.AccountNameOption1Property); }
            set { this.SetValue(GenerateUniqueAccountName.AccountNameOption1Property, value); }
        }
        /*
        public string AccountNameOption2
        {
        get { return (string)this.GetValue(GenerateUniqueAccountName.AccountNameOption2Property); }
        set { this.SetValue(GenerateUniqueAccountName.AccountNameOption2Property, value); }
        }
        public string AccountNameOption3
        {
        get { return (string)this.GetValue(GenerateUniqueAccountName.AccountNameOption3Property); }
        set { this.SetValue(GenerateUniqueAccountName.AccountNameOption3Property, value); }
        }
        public string AccountNameOption4
        {
        get { return (string)this.GetValue(GenerateUniqueAccountName.AccountNameOption4Property); }
        set { this.SetValue(GenerateUniqueAccountName.AccountNameOption4Property, value); }
        }
        public string AccountNameOption5
        {
        get { return (string)this.GetValue(GenerateUniqueAccountName.AccountNameOption5Property); }
        set { this.SetValue(GenerateUniqueAccountName.AccountNameOption5Property, value); }
        }
        */
        public string NumberOfAccountNameOptions
        {
            get { return (string)this.GetValue(GenerateUniqueAccountName.NumberOfAccountNameOptionsProperty); }
            set { this.SetValue(GenerateUniqueAccountName.NumberOfAccountNameOptionsProperty, value); }
        }
        public string UniqueAccountNameCounter
        {
            get { return (string)this.GetValue(GenerateUniqueAccountName.UniqueAccountNameCounterProperty); }
            set { this.SetValue(GenerateUniqueAccountName.UniqueAccountNameCounterProperty, value); }
        }
        public bool RemoveCharactersNotAllowed
        {
            get { return (bool)this.GetValue(GenerateUniqueAccountName.RemoveCharactersNotAllowedProperty); }
            set { this.SetValue(GenerateUniqueAccountName.RemoveCharactersNotAllowedProperty, value); }
        }
        private void GetWorkflowData_ExecuteCode(object sender, EventArgs e)
        {
            this.Log("GetWorkflowData_ExecuteCode : Starts");
            SequentialWorkflow parentWorkflow = null;
            if (!SequentialWorkflow.TryGetContainingWorkflow(this, out parentWorkflow))
            {
                this.Log("Exception thrown: InvalidOperationException(\"Cannot resolve parent workflow.\")");
                throw new InvalidOperationException("Cannot resolve parent workflow.");
            }
            // get the valid the input format
            _logFilename = this.LogFileName;
            if (!string.IsNullOrEmpty(_logFilename))
            {
                if ((Directory.Exists(Path.GetDirectoryName(_logFilename))) || (File.Exists(_logFilename)))
                {
                    _logginOn = true;
                }
            }
            // parse the number of AccountName format options
            _numberOfOptions = NUMBER_OF_ACCOUNTNAME_OPTIONS; // default value
            try
            {
                _numberOfOptions = Convert.ToInt32(this.NumberOfAccountNameOptions);
                this.Log("Number of AccountName format Options specified : " + this._numberOfOptions);
            }
            catch (FormatException fe)
            {
            }
            catch (OverflowException oe)
            {
            }
            // parse the number of iterations
            _numberOfIterations = NUMBER_OF_ACCOUNTNAME_OPTIONS; // default value
            try
            {
                _numberOfIterations = Convert.ToInt32(this.UniqueAccountNameCounter);
                this.Log("Number of Uniquename Iteration specified : " + this._numberOfIterations);
            }
            catch (FormatException fe)
            {
            }
            catch (OverflowException oe)
            {
            }
            // construct the list of possible AccountNames based on the number of options specified
            string WFDataParameter = "";
            string WFDataParameterValue = "";
            //string WFDataParameterValueTemp = "";
            object outputValue;
            int optionsCount = 0;
            string option = this.AccountNameOption1;
            AccountNames = new string[_numberOfOptions + _numberOfIterations];
            this.Log("Specified AccountName format option: " + option);
            this.Log("RemoveCharactersNotAllowed: " + this.RemoveCharactersNotAllowed.ToString());
            if (!option.StartsWith("[//WorkflowData/"))
            {
                this.Log("Invalid Workflow AccountName format input specified: " + option + ". Expected format: [//WorkflowData/xxx].");
                throw new WorkflowTerminatedException("Invalid Workflow AccountName format input specified: " + option + ". Expected format: [//WorkflowData/xxx].");
            }
            for (int optionsCounter = 0, optionNumber = 1; optionsCounter < _numberOfOptions; optionsCounter++, optionNumber++)
            {
                if (option.StartsWith("[//WorkflowData/"))
                {
                    // strip out to extract the only take the parameter name and append a number to it
                    WFDataParameter = option.Replace("[//WorkflowData/", "").Replace("]", "") + optionNumber.ToString();
                    this.Log("AccountName format option WFDataParameter : " + WFDataParameter);
                    // obtain the input parameter's value from the Workflow Dictionary
                    parentWorkflow.WorkflowDictionary.TryGetValue(WFDataParameter, out outputValue);
                    if (outputValue == null)
                    {
                        this.Log("Error: Cannot extract the value for the parameter: [//WorkflowData/" + WFDataParameter + "]");
                        continue;
                        // throw new WorkflowTerminatedException("Cannot extract the value for the parameter " + option);
                    }
                    WFDataParameterValue = outputValue.ToString();
                    //
                    // process the input value
                    //
                    // 
                    // removed the illegal characters
                    if (this.RemoveCharactersNotAllowed == true)
                    {
                        // remove the illegal characters
                        this.Log("AccountName value after removing the not allowed characters: " + WFDataParameterValue);
                        WFDataParameterValue = AllowedCharactersRegEx.Replace(WFDataParameterValue, String.Empty);
                    }
                    if (WFDataParameterValue.Length > AD_SAMACCOUNTNAME_MAX_LENGTH)
                    {
                        // automatically truncat it
                        WFDataParameterValue = WFDataParameterValue.Substring(0, AD_SAMACCOUNTNAME_MAX_LENGTH);
                        this.Log("Warning: AccountName value exceed the max allowed characters (20). This is automatically truncated to " + WFDataParameterValue);
                        // throw new OperationCanceledException("The value supplied exceed the allowed limits of max 20 characters.");
                    }
                    this.Log("AccountName format option WFDataParameterValue : " + WFDataParameterValue);
                    AccountNames[optionsCount] = WFDataParameterValue;
                    this.Log("Resolved AccountName value, AccountNames[" + optionsCount.ToString() + "]=" + WFDataParameterValue);
                    optionsCount++;
                }
                else
                {
                    // ignore the one that does not have a valid syntax
                    // throw new WorkflowTerminatedException("Incorrect input format. Expected [//WorkflowData/xxx].");
                }
            }
            if (optionsCount == 0)
            {
                this.Log("No Workflow AccountName format value found for the specified input:" + option);
                throw new WorkflowTerminatedException("No Workflow AccountName format value found for the specified input:" + option);
            }
            if (_numberOfOptions != optionsCount)
            {
                _numberOfOptions = optionsCount; // reset the number of AccountName format options based on the value data available
                this.Log("Warning: There is invalid AccountName format option input.");
            }
            // construct the list of possible AccountNames based on the number of iteration specified for the last Option
            string lastAccountNameOptionValue = AccountNames[_numberOfOptions - 1];
            string tmpAccountName = "";
            for (int count = 1, index = _numberOfOptions; index < (_numberOfOptions + _numberOfIterations); index++, count++)
            {
                // Need to check and truncat any AccountName exceeding 20 chars
                if ((lastAccountNameOptionValue.Length < 19) && (index < 10))
                {
                    // not truncating
                    tmpAccountName = lastAccountNameOptionValue;
                }
                else if ((lastAccountNameOptionValue.Length > 19) && (index < 10))
                {
                    // truncated to 19 chars
                    tmpAccountName = lastAccountNameOptionValue.Substring(0, 19);
                }
                else if ((lastAccountNameOptionValue.Length > 18) && (index > 10))
                {
                    // truncated to 18 chars
                    tmpAccountName = lastAccountNameOptionValue.Substring(0, 18);
                }
                else if ((lastAccountNameOptionValue.Length > 17) && (index > 100))
                {
                    // truncated to 18 chars
                    tmpAccountName = lastAccountNameOptionValue.Substring(0, 17);
                }
                AccountNames[index] = tmpAccountName + count.ToString();
                this.Log("Resolved Iterated AccountName value, AccountNames[" + index.ToString() + "]=" + tmpAccountName + count.ToString());
            }
            this.Log("Number of valid AccountName format options specified: " + _numberOfOptions.ToString());
            this.Log("Number of iternation specified: " + _numberOfIterations.ToString());
            this.Log("GetWorkflowData_ExecuteCode : End");
        }
        /* private string RemoveNotAllowedChars(string strInput, string notAllowChars)
        {
        string[] arrNotAllowChars = notAllowChars.Split(' ');
        // so removing the unallowed characters
        string strOutput = strInput.Replace(" ", ""); // Firstly remove any whitespaces
        foreach (string notAllowChar in arrNotAllowChars)
        {
        string tempStr = strOutput.Replace(notAllowChar, "");
        strOutput = tempStr;
        }
        return strOutput;
        }
        */
        private void InitializeWhileCodeActivity_ExecuteCode(object sender, EventArgs e)
        {
            this.Log("InitializeWhileCodeActivity_ExecuteCode");
        }
        private void InitializedEnumerateResourceActivity_ExecuteCode(object sender, EventArgs e)
        {
            this.Log("InitializedEnumerateResourceActivity_ExecuteCode: Starts");
            SequentialWorkflow parentWorkflow = null;
            if (!SequentialWorkflow.TryGetContainingWorkflow(this, out parentWorkflow))
            {
                this.Log("Exception thrown: InvalidOperationException(\"Cannot resolve parent workflow.\")");
                throw new InvalidOperationException("Cannot resolve parent workflow.");
            }
            this.Log("AccountNames[" + _loopCount.ToString() + "]=" + AccountNames[_loopCount]);
            //
            // prepare for FIM database search for unique AccountName
            //
            // Updating the enumerateResourcesActivity 
            // this.enumerateResourcesActivity_ActorId = new Guid(FIMADMIN_GUID);
            this.enumerateResourcesActivity_ActorId = parentWorkflow.ActorId;
            this.enumerateResourcesActivity_XPathFilter = "/Person" + "[AccountName=\"" + AccountNames[_loopCount] + "\"]";
            this.Log("enumerateResourcesActivity_XPathFilter=" + this.enumerateResourcesActivity_XPathFilter.ToString());
            this.Log("InitializedEnumerateResourceActivity_ExecuteCode: Ends");
        }
        private void InitialiazeUpdateResourceCodeActivity_ExecuteCode(object sender, EventArgs e)
        {
            this.Log("InitialiazeUpdateResourceCodeActivity_ExecuteCode: Starts");
            // do something for the If condition, eg update the attribute value
            SequentialWorkflow parentWorkflow = null;
            if (!SequentialWorkflow.TryGetContainingWorkflow(this, out parentWorkflow))
            {
                this.Log("Exception thrown: InvalidOperationException(\"Cannot resolve parent workflow.\")");
                throw new InvalidOperationException("Cannot resolve parent workflow.");
            }
            this.updateResourceActivity.ActorId = parentWorkflow.ActorId;
            this.updateResourceActivity.ResourceId = parentWorkflow.TargetId;
            this.updateResourceActivity.UpdateParameters = new UpdateRequestParameter[]
{
new UpdateRequestParameter("AccountName", UpdateMode.Modify, this.returnUniqueAccountName)
};
            this.Log("InitialiazeUpdateResourceCodeActivity_ExecuteCode: Ends");
        }
        private void SetErrorCodeActivity_ExecuteCode(object sender, EventArgs e)
        {
            // do something for the Else condition, eg throw an error
            this.Log("Exception thrown: WorkflowTerminatedException(\"No unique AccountName value found.\")");
            throw new WorkflowTerminatedException("No unique AccountName value found.");
        }
        private void CheckUniqueCodeActivity_ExecuteCode(object sender, EventArgs e)
        {
            // if there AccountName already exist
            this.Log("CheckUniqueCodeActivity_ExecuteCode: Starts");
            // this.Log("enumerateResourcesActivity.TotalResultsCount : " + this.enumerateResourcesActivity.TotalResultsCount.ToString());
            if (this.enumerateResourcesActivity_TotalResultsCount > 0)
            {
                this.Log("Try number " + (_loopCount + 1).ToString() + ": Unique AccountName is NOT found for AccountName=" + AccountNames[_loopCount]);
                // a match is found, thus duplication
                if (_loopCount < (_numberOfOptions + _numberOfIterations - 1))
                {
                    _loopAgain = true;
                }
                else
                {
                    _loopAgain = false;
                }
            }
            else
            {
                // no match is found, thus unique
                _loopAgain = false;
                _bUniqueAttributeValueIsFound = true;
                returnUniqueAccountName = AccountNames[_loopCount];
                this.Log("Try number " + (_loopCount + 1).ToString() + ": Unique AccountName is found for AccountName= " + AccountNames[_loopCount]);
            }
            _loopCount++; // increment the counter.
            this.Log("CheckUniqueCodeActivity_ExecuteCode: Ends");
        }
        #region Utility Functions
        // Prefix the current time to the message and log the message to the log file.
        private void Log(string message)
        {
            if (_logginOn == true)
            {
                using (StreamWriter log = new StreamWriter(this._logFilename, true))
                {
                    log.WriteLine(DateTime.Now.ToString("yyyy-MM-dd hh:mm:ss") + ": " + message);
                    // since the previous line is part of a "using" block, the file will automatically
                    // be closed (even if writing to the file caused an exception to be thrown).
                    // For more information see
                    // http://msdn.microsoft.com/en-us/library/yh598w02.aspx
                }
            }
        }
        #endregion
        public static DependencyProperty enumerateResourcesActivity_ActorIdProperty = DependencyProperty.Register("enumerateResourcesActivity_ActorId", typeof(System.Guid), typeof(GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName));
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Misc")]
        public Guid enumerateResourcesActivity_ActorId
        {
            get
            {
                return ((System.Guid)(base.GetValue(GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName.enumerateResourcesActivity_ActorIdProperty)));
            }
            set
            {
                base.SetValue(GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName.enumerateResourcesActivity_ActorIdProperty, value);
            }
        }
        public static DependencyProperty enumerateResourcesActivity_XPathFilterProperty = DependencyProperty.Register("enumerateResourcesActivity_XPathFilter", typeof(System.String), typeof(GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName));
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Misc")]
        public String enumerateResourcesActivity_XPathFilter
        {
            get
            {
                return ((string)(base.GetValue(GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName.enumerateResourcesActivity_XPathFilterProperty)));
            }
            set
            {
                base.SetValue(GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName.enumerateResourcesActivity_XPathFilterProperty, value);
            }
        }
        public static DependencyProperty enumerateResourcesActivity_TotalResultsCountProperty = DependencyProperty.Register("enumerateResourcesActivity_TotalResultsCount", typeof(System.Int32), typeof(GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName));
        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Misc")]
        public Int32 enumerateResourcesActivity_TotalResultsCount
        {
            get
            {
                return ((int)(base.GetValue(GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName.enumerateResourcesActivity_TotalResultsCountProperty)));
            }
            set
            {
                base.SetValue(GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName.enumerateResourcesActivity_TotalResultsCountProperty, value);
            }
        }
    }
}
