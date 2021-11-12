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

namespace UnifySolutions.FIM.GenerateUniqueAccountNameLibrary
{
    public partial class GenerateUniqueAccountName : SequenceActivity
    {
        const string FIMADMIN_GUID = "7fb2b853-24f0-4498-9534-4e10589723c4";

        private bool _bUniqueAttributeValueIsFound = false;
        private string[] AccountNames;
        private string returnAccountName = "";
        private int _loopCount = 0;
        private bool _loopAgain = true;

        private string LogFilePath = "C:\\Temp\\FIMWorkflowCustomActivity.log";

        public static DependencyProperty UniqueAccountNameExpressionProperty = DependencyProperty.Register("UniqueAccountNameExpression", typeof(string), typeof(GenerateUniqueAccountName));
        public static DependencyProperty UniqueAccountNameCounterProperty = DependencyProperty.Register("UniqueAccountNameCounter", typeof(string), typeof(GenerateUniqueAccountName));
        public static DependencyProperty AccountNameOption1Property = DependencyProperty.Register("AccountNameOption1", typeof(string), typeof(GenerateUniqueAccountName));
        public static DependencyProperty AccountNameOption2Property = DependencyProperty.Register("AccountNameOption2", typeof(string), typeof(GenerateUniqueAccountName));
        public static DependencyProperty AccountNameOption3Property = DependencyProperty.Register("AccountNameOption3", typeof(string), typeof(GenerateUniqueAccountName));
        public static DependencyProperty AccountNameOption4Property = DependencyProperty.Register("AccountNameOption4", typeof(string), typeof(GenerateUniqueAccountName));
        public static DependencyProperty AccountNameOption5Property = DependencyProperty.Register("AccountNameOption5", typeof(string), typeof(GenerateUniqueAccountName));
        /// public static DependencyProperty UniqueAccountNameRemoveIllegalCharactersProperty = DependencyProperty.Register("UniqueAccountNameRemoveIllegalCharacters", typeof(string), typeof(GenerateUniqueAccountName));

        public GenerateUniqueAccountName()
        {
            InitializeComponent();
        }

        public string UniqueAccountNameExpression
        {
            get { return (string)this.GetValue(GenerateUniqueAccountName.UniqueAccountNameExpressionProperty); }
            set { this.SetValue(GenerateUniqueAccountName.UniqueAccountNameExpressionProperty, value); }
        }

        public string AccountNameOption1
        {
            get { return (string)this.GetValue(GenerateUniqueAccountName.AccountNameOption1Property); }
            set { this.SetValue(GenerateUniqueAccountName.AccountNameOption1Property, value); }
        }

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

        public string UniqueAccountNameCounter
        {
            get { return (string)this.GetValue(GenerateUniqueAccountName.UniqueAccountNameCounterProperty); }
            set { this.SetValue(GenerateUniqueAccountName.UniqueAccountNameCounterProperty, value); }
        }

        /*
        public bool UniqueAccountNameRemoveIllegalCharacters
        {
            get { return (bool)this.GetValue(GenerateUniqueAccountName.UniqueAccountNameRemoveIllegalCharactersProperty); }
            set { this.SetValue(GenerateUniqueAccountName.UniqueAccountNameRemoveIllegalCharactersProperty, value); }
        }
         * */

        private void GetWorkflowData_ExecuteCode(object sender, EventArgs e)
        {
            SequentialWorkflow parentWorkflow = null;
            if (!SequentialWorkflow.TryGetContainingWorkflow(this, out parentWorkflow))
            {
                throw new InvalidOperationException("Cannot resolve parent workflow.");
            }

            // valid the input UniqueAccountNameOption format
            string validateInput = this.UniqueAccountNameExpression;
            string resolvedInput = "";

            // Output the Request type and object type
            this.Log("GetWorkflowData_ExecuteCode : validateInput : " + validateInput.ToString());

            if (!validateInput.StartsWith("[//WorkflowData/"))
            {
                throw new WorkflowTerminatedException("Incorrect input format. Expected [//WorkflowData/xxx].");
            }

            // strip out the only take the parameter name 
            string WFDataParameter = validateInput.Replace("[//WorkflowData/", "").Replace("]", "");

            this.Log("GetWorkflowData_ExecuteCode : WFDataParameter : " + WFDataParameter);

            // obtain the input parameter's value from the Workflow Dictionary
            object outputValue;
            parentWorkflow.WorkflowDictionary.TryGetValue(WFDataParameter, out outputValue);


            if (outputValue == null)
            {
                throw new WorkflowTerminatedException("Cannot extract the value for the parameter " + validateInput);
            }

            resolvedInput = outputValue.ToString();
            this.Log("GetWorkflowData_ExecuteCode : resolvedInput : " + resolvedInput);

            returnAccountName = resolvedInput;

            //
            // process the input value
            //

            // 
            /// if (resolvedInput.Length > 20)
            /// {
            /// throw new OperationCanceledException("The value supplied exceed the allowed limits of max 20 characters.");
            /// }

            // removed the illegal characters
            /// if (this.UniqueAccountNameRemoveIllegalCharacters == true)
            /// {
            // remove the illegal characters
            // resolvedInput
            /// }

            //
            // Search FIM database for unique name 
            //

            /*
            // get the list of current
            SequenceActivity sa = (SequenceActivity)((CodeActivity)sender).Parent;
            ResourceType currentItem = EnumerateResourcesActivity.GetCurrentIterationItem(sa) as ResourceType;
             * */

            // parse the number of iterations
            int numberOfLoop = 10;
            try
            {
                numberOfLoop = Convert.ToInt32(this.UniqueAccountNameCounter);
                this.Log("GetWorkflowData_ExecuteCode : numberOfLoop convert : " + this.UniqueAccountNameCounter);
            }
            catch (FormatException fe)
            {
            }
            catch (OverflowException oe)
            {
            }
            finally
            {
                // numberOfLoop = 10; // Max allowed is 10 when there is problem with conversion
            }

            this.Log("GetWorkflowData_ExecuteCode : numberOfLoop : " + numberOfLoop.ToString());

            // construct the list of possible AccountNames based on the number of iteration specified
            AccountNames = new string[numberOfLoop];
            AccountNames[0] = resolvedInput;
            this.Log("GetWorkflowData_ExecuteCode : AccountNames[0] : " + AccountNames[0]);
            for (int counter = 1; counter < numberOfLoop; counter++)
            {
                AccountNames[counter] = resolvedInput + counter;
                this.Log("GetWorkflowData_ExecuteCode : AccountNames[counter] : " + AccountNames[counter]);
            }

            this.Log("GetWorkflowData_ExecuteCode : End");
        }

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
                throw new InvalidOperationException("Cannot resolve parent workflow.");
            }

            this.Log("GetWorkflowData_ExecuteCode : _loopCount=" + _loopCount.ToString() + ", AccountNames[_loopCount]=" + AccountNames[_loopCount]);

            // Updating the enumerateResourcesActivity 
            // this.enumerateResourcesActivity.ActorId = parentWorkflow.ActorId;

            /// this.enumerateResourcesActivity_ActorId = new Guid(FIMADMIN_GUID);
            this.enumerateResourcesActivity_ActorId = parentWorkflow.ActorId;
            this.enumerateResourcesActivity_XPathFilter = "/Person" + "[AccountName='" + AccountNames[_loopCount] + "']";
            // this.enumerateResourcesActivity_XPathFilter = "/Person" + ", [AccountName=" + AccountNames[_loopCount] + "]";
            this.Log("GetWorkflowData_ExecuteCode : enumerateResourcesActivity_XPathFilter=" + this.enumerateResourcesActivity_XPathFilter.ToString());

            /*
            this.enumerateResourcesActivity.Name = "enumerateResourcesActivity";
            this.Log("GetWorkflowData_ExecuteCode : 1");
            this.enumerateResourcesActivity.PageSize = 100;
            this.Log("GetWorkflowData_ExecuteCode : 2");
            this.enumerateResourcesActivity.Selection = new string[] { "AccountName" };
            this.Log("GetWorkflowData_ExecuteCode : 3");
            this.enumerateResourcesActivity.SortingAttributes = null;
            this.Log("GetWorkflowData_ExecuteCode : 4");
            this.enumerateResourcesActivity.TotalResultsCount = 0;
            this.Log("GetWorkflowData_ExecuteCode : 5");
            this.enumerateResourcesActivity.XPathFilter = "/Person";
            // this.enumerateResourcesActivity.XPathFilter = "/Person" + "[AccountName=" + returnAccountName + "]";
             */

            this.Log("InitializedEnumerateResourceActivity_ExecuteCode: Ends");
        }

        private void InitialiazeUpdateResourceCodeActivity_ExecuteCode(object sender, EventArgs e)
        {
            this.Log("InitialiazeUpdateResourceCodeActivity_ExecuteCode: Starts");
            // do something for If condition, eg update the attribute value
            SequentialWorkflow parentWorkflow = null;
            if (!SequentialWorkflow.TryGetContainingWorkflow(this, out parentWorkflow))
            {
                throw new InvalidOperationException("Cannot resolve parent workflow.");
            }

            this.updateResourceActivity.ActorId = parentWorkflow.ActorId;
            this.updateResourceActivity.ResourceId = parentWorkflow.TargetId;
            this.updateResourceActivity.UpdateParameters = new UpdateRequestParameter[]
                {
                    // new UpdateRequestParameter("AccountName", UpdateMode.Modify, this.returnAccountName)
                    new UpdateRequestParameter("AccountName", UpdateMode.Modify, this.returnAccountName)
                };
            this.Log("InitialiazeUpdateResourceCodeActivity_ExecuteCode: Ends");
        }

        private void SetErrorCodeActivity_ExecuteCode(object sender, EventArgs e)
        {
            // do something for Else condition, eg throw an error
            throw new WorkflowTerminatedException("No unique AccountName value found.");
        }

        private void CheckUniqueCodeActivity_ExecuteCode(object sender, EventArgs e)
        {
            // if there AccountName already exist
            this.Log("CheckUniqueCodeActivity_ExecuteCode: Starts");
            this.Log("CheckUniqueCodeActivity_ExecuteCode : enumerateResourcesActivity.TotalResultsCount : " + this.enumerateResourcesActivity.TotalResultsCount.ToString());
            if (this.enumerateResourcesActivity_TotalResultsCount > 0)
            {
                // more than one match is found
                if (_loopCount < this.AccountNames.Length - 1)
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
                ///returnAccountName = "Test1User1a";
                returnAccountName = AccountNames[_loopCount];
            }

            _loopCount++; // increment the counter.
            this.Log("CheckUniqueCodeActivity_ExecuteCode: Ends");
        }

        #region Utility Functions

        // Prefix the current time to the message and log the message to the log file.
        private void Log(string message)
        {
            using (StreamWriter log = new StreamWriter(this.LogFilePath, true))
            {
                log.WriteLine(DateTime.Now.ToString("yyyy-MM-dd hh:mm:ss") + ": " + message);
                //since the previous line is part of a "using" block, the file will automatically
                //be closed (even if writing to the file caused an exception to be thrown).
                //For more information see
                // http://msdn.microsoft.com/en-us/library/yh598w02.aspx
            }
        }
        #endregion

        public static DependencyProperty enumerateResourcesActivity_ActorIdProperty = DependencyProperty.Register("enumerateResourcesActivity_ActorId", typeof(System.Guid), typeof(UnifySolutions.FIM.GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName));

        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Misc")]
        public Guid enumerateResourcesActivity_ActorId
        {
            get
            {
                return ((System.Guid)(base.GetValue(UnifySolutions.FIM.GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName.enumerateResourcesActivity_ActorIdProperty)));
            }
            set
            {
                base.SetValue(UnifySolutions.FIM.GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName.enumerateResourcesActivity_ActorIdProperty, value);
            }
        }

        public static DependencyProperty enumerateResourcesActivity_XPathFilterProperty = DependencyProperty.Register("enumerateResourcesActivity_XPathFilter", typeof(System.String), typeof(UnifySolutions.FIM.GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName));

        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Misc")]
        public String enumerateResourcesActivity_XPathFilter
        {
            get
            {
                return ((string)(base.GetValue(UnifySolutions.FIM.GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName.enumerateResourcesActivity_XPathFilterProperty)));
            }
            set
            {
                base.SetValue(UnifySolutions.FIM.GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName.enumerateResourcesActivity_XPathFilterProperty, value);
            }
        }

        public static DependencyProperty enumerateResourcesActivity_TotalResultsCountProperty = DependencyProperty.Register("enumerateResourcesActivity_TotalResultsCount", typeof(System.Int32), typeof(UnifySolutions.FIM.GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName));

        [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
        [BrowsableAttribute(true)]
        [CategoryAttribute("Misc")]
        public Int32 enumerateResourcesActivity_TotalResultsCount
        {
            get
            {
                return ((int)(base.GetValue(UnifySolutions.FIM.GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName.enumerateResourcesActivity_TotalResultsCountProperty)));
            }
            set
            {
                base.SetValue(UnifySolutions.FIM.GenerateUniqueAccountNameLibrary.GenerateUniqueAccountName.enumerateResourcesActivity_TotalResultsCountProperty, value);
            }
        }
    }
}
