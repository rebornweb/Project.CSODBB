using System;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections;
using System.Drawing;
using System.Reflection;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;
using Microsoft.ResourceManagement.Workflow.Activities;

namespace UnifySolutions.FIM.GenerateUniqueAccountNameLibrary
{
    public partial class GenerateUniqueAccountName
    {
        #region Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        [System.Diagnostics.DebuggerNonUserCode]
        private void InitializeComponent()
        {
            this.CanModifyActivities = true;
            System.Workflow.ComponentModel.ActivityBind activitybind1 = new System.Workflow.ComponentModel.ActivityBind();
            System.Workflow.ComponentModel.ActivityBind activitybind2 = new System.Workflow.ComponentModel.ActivityBind();
            System.Workflow.ComponentModel.ActivityBind activitybind3 = new System.Workflow.ComponentModel.ActivityBind();
            System.Workflow.Activities.Rules.RuleConditionReference ruleconditionreference1 = new System.Workflow.Activities.Rules.RuleConditionReference();
            System.Workflow.Activities.Rules.RuleConditionReference ruleconditionreference2 = new System.Workflow.Activities.Rules.RuleConditionReference();
            System.Workflow.Activities.Rules.RuleConditionReference ruleconditionreference3 = new System.Workflow.Activities.Rules.RuleConditionReference();
            this.throwActivityUniqueValueNotFoundException = new System.Workflow.ComponentModel.ThrowActivity();
            this.SetErrorCodeActivity = new System.Workflow.Activities.CodeActivity();
            this.updateResourceActivity = new Microsoft.ResourceManagement.Workflow.Activities.UpdateResourceActivity();
            this.InitialiazeUpdateResourceCodeActivity = new System.Workflow.Activities.CodeActivity();
            this.CheckUniqueCodeActivity = new System.Workflow.Activities.CodeActivity();
            this.enumerateResourcesActivity = new Microsoft.ResourceManagement.Workflow.Activities.EnumerateResourcesActivity();
            this.InitializedEnumerateResourceActivity = new System.Workflow.Activities.CodeActivity();
            this.cancellationHandlerActivity2 = new System.Workflow.ComponentModel.CancellationHandlerActivity();
            this.faultHandlersActivity2 = new System.Workflow.ComponentModel.FaultHandlersActivity();
            this.UniqueValueFoundNotFound = new System.Workflow.Activities.IfElseBranchActivity();
            this.UniqueValueFound = new System.Workflow.Activities.IfElseBranchActivity();
            this.faultHandlersActivity3 = new System.Workflow.ComponentModel.FaultHandlersActivity();
            this.cancellationHandlerActivity3 = new System.Workflow.ComponentModel.CancellationHandlerActivity();
            this.sequenceActivity = new System.Workflow.Activities.SequenceActivity();
            this.ifElseUniqueValueFound = new System.Workflow.Activities.IfElseActivity();
            this.whileActivity = new System.Workflow.Activities.WhileActivity();
            this.InitializeWhileCodeActivity = new System.Workflow.Activities.CodeActivity();
            this.readResourceActivity = new Microsoft.ResourceManagement.Workflow.Activities.ReadResourceActivity();
            this.GetWorkflowDataCodeAcivity = new System.Workflow.Activities.CodeActivity();
            this.currentRequestActivity = new Microsoft.ResourceManagement.Workflow.Activities.CurrentRequestActivity();
            // 
            // throwActivityUniqueValueNotFoundException
            // 
            this.throwActivityUniqueValueNotFoundException.Enabled = false;
            this.throwActivityUniqueValueNotFoundException.Name = "throwActivityUniqueValueNotFoundException";
            // 
            // SetErrorCodeActivity
            // 
            this.SetErrorCodeActivity.Name = "SetErrorCodeActivity";
            this.SetErrorCodeActivity.ExecuteCode += new System.EventHandler(this.SetErrorCodeActivity_ExecuteCode);
            // 
            // updateResourceActivity
            // 
            this.updateResourceActivity.ActorId = new System.Guid("00000000-0000-0000-0000-000000000000");
            this.updateResourceActivity.Name = "updateResourceActivity";
            this.updateResourceActivity.ResourceId = new System.Guid("00000000-0000-0000-0000-000000000000");
            this.updateResourceActivity.UpdateParameters = null;
            // 
            // InitialiazeUpdateResourceCodeActivity
            // 
            this.InitialiazeUpdateResourceCodeActivity.Name = "InitialiazeUpdateResourceCodeActivity";
            this.InitialiazeUpdateResourceCodeActivity.ExecuteCode += new System.EventHandler(this.InitialiazeUpdateResourceCodeActivity_ExecuteCode);
            // 
            // CheckUniqueCodeActivity
            // 
            this.CheckUniqueCodeActivity.Name = "CheckUniqueCodeActivity";
            this.CheckUniqueCodeActivity.ExecuteCode += new System.EventHandler(this.CheckUniqueCodeActivity_ExecuteCode);
            // 
            // enumerateResourcesActivity
            // 
            activitybind1.Name = "GenerateUniqueAccountName";
            activitybind1.Path = "enumerateResourcesActivity_ActorId";
            this.enumerateResourcesActivity.Name = "enumerateResourcesActivity";
            this.enumerateResourcesActivity.PageSize = 100;
            this.enumerateResourcesActivity.Selection = new string[] {
        "AccountName"};
            this.enumerateResourcesActivity.SortingAttributes = null;
            activitybind2.Name = "GenerateUniqueAccountName";
            activitybind2.Path = "enumerateResourcesActivity_TotalResultsCount";
            activitybind3.Name = "GenerateUniqueAccountName";
            activitybind3.Path = "enumerateResourcesActivity_XPathFilter";
            this.enumerateResourcesActivity.SetBinding(Microsoft.ResourceManagement.Workflow.Activities.EnumerateResourcesActivity.ActorIdProperty, ((System.Workflow.ComponentModel.ActivityBind)(activitybind1)));
            this.enumerateResourcesActivity.SetBinding(Microsoft.ResourceManagement.Workflow.Activities.EnumerateResourcesActivity.XPathFilterProperty, ((System.Workflow.ComponentModel.ActivityBind)(activitybind3)));
            this.enumerateResourcesActivity.SetBinding(Microsoft.ResourceManagement.Workflow.Activities.EnumerateResourcesActivity.TotalResultsCountProperty, ((System.Workflow.ComponentModel.ActivityBind)(activitybind2)));
            // 
            // InitializedEnumerateResourceActivity
            // 
            this.InitializedEnumerateResourceActivity.Name = "InitializedEnumerateResourceActivity";
            this.InitializedEnumerateResourceActivity.ExecuteCode += new System.EventHandler(this.InitializedEnumerateResourceActivity_ExecuteCode);
            // 
            // cancellationHandlerActivity2
            // 
            this.cancellationHandlerActivity2.Name = "cancellationHandlerActivity2";
            // 
            // faultHandlersActivity2
            // 
            this.faultHandlersActivity2.Name = "faultHandlersActivity2";
            // 
            // UniqueValueFoundNotFound
            // 
            this.UniqueValueFoundNotFound.Activities.Add(this.SetErrorCodeActivity);
            this.UniqueValueFoundNotFound.Activities.Add(this.throwActivityUniqueValueNotFoundException);
            ruleconditionreference1.ConditionName = "IfUniqueValueNotFound";
            this.UniqueValueFoundNotFound.Condition = ruleconditionreference1;
            this.UniqueValueFoundNotFound.Name = "UniqueValueFoundNotFound";
            // 
            // UniqueValueFound
            // 
            this.UniqueValueFound.Activities.Add(this.InitialiazeUpdateResourceCodeActivity);
            this.UniqueValueFound.Activities.Add(this.updateResourceActivity);
            ruleconditionreference2.ConditionName = "IfUniqueValueFound";
            this.UniqueValueFound.Condition = ruleconditionreference2;
            this.UniqueValueFound.Name = "UniqueValueFound";
            // 
            // faultHandlersActivity3
            // 
            this.faultHandlersActivity3.Name = "faultHandlersActivity3";
            // 
            // cancellationHandlerActivity3
            // 
            this.cancellationHandlerActivity3.Name = "cancellationHandlerActivity3";
            // 
            // sequenceActivity
            // 
            this.sequenceActivity.Activities.Add(this.InitializedEnumerateResourceActivity);
            this.sequenceActivity.Activities.Add(this.enumerateResourcesActivity);
            this.sequenceActivity.Activities.Add(this.CheckUniqueCodeActivity);
            this.sequenceActivity.Name = "sequenceActivity";
            // 
            // ifElseUniqueValueFound
            // 
            this.ifElseUniqueValueFound.Activities.Add(this.UniqueValueFound);
            this.ifElseUniqueValueFound.Activities.Add(this.UniqueValueFoundNotFound);
            this.ifElseUniqueValueFound.Activities.Add(this.faultHandlersActivity2);
            this.ifElseUniqueValueFound.Activities.Add(this.cancellationHandlerActivity2);
            this.ifElseUniqueValueFound.Name = "ifElseUniqueValueFound";
            // 
            // whileActivity
            // 
            this.whileActivity.Activities.Add(this.sequenceActivity);
            this.whileActivity.Activities.Add(this.cancellationHandlerActivity3);
            this.whileActivity.Activities.Add(this.faultHandlersActivity3);
            ruleconditionreference3.ConditionName = "WhileCondition";
            this.whileActivity.Condition = ruleconditionreference3;
            this.whileActivity.Name = "whileActivity";
            // 
            // InitializeWhileCodeActivity
            // 
            this.InitializeWhileCodeActivity.Name = "InitializeWhileCodeActivity";
            this.InitializeWhileCodeActivity.ExecuteCode += new System.EventHandler(this.InitializeWhileCodeActivity_ExecuteCode);
            // 
            // readResourceActivity
            // 
            this.readResourceActivity.ActorId = new System.Guid("00000000-0000-0000-0000-000000000000");
            this.readResourceActivity.Enabled = false;
            this.readResourceActivity.Name = "readResourceActivity";
            this.readResourceActivity.Resource = null;
            this.readResourceActivity.ResourceId = new System.Guid("00000000-0000-0000-0000-000000000000");
            this.readResourceActivity.SelectionAttributes = null;
            // 
            // GetWorkflowDataCodeAcivity
            // 
            this.GetWorkflowDataCodeAcivity.Name = "GetWorkflowDataCodeAcivity";
            this.GetWorkflowDataCodeAcivity.ExecuteCode += new System.EventHandler(this.GetWorkflowData_ExecuteCode);
            // 
            // currentRequestActivity
            // 
            this.currentRequestActivity.CurrentRequest = null;
            this.currentRequestActivity.Name = "currentRequestActivity";
            // 
            // GenerateUniqueAccountName
            // 
            this.Activities.Add(this.currentRequestActivity);
            this.Activities.Add(this.GetWorkflowDataCodeAcivity);
            this.Activities.Add(this.readResourceActivity);
            this.Activities.Add(this.InitializeWhileCodeActivity);
            this.Activities.Add(this.whileActivity);
            this.Activities.Add(this.ifElseUniqueValueFound);
            this.Name = "GenerateUniqueAccountName";
            this.CanModifyActivities = false;

        }

        #endregion

        private FaultHandlersActivity faultHandlersActivity3;
        private CancellationHandlerActivity cancellationHandlerActivity3;
        private SequenceActivity sequenceActivity;
        private WhileActivity whileActivity;
        private CodeActivity GetWorkflowDataCodeAcivity;
        private CurrentRequestActivity currentRequestActivity;
        private CodeActivity InitializeWhileCodeActivity;
        private ReadResourceActivity readResourceActivity;
        private EnumerateResourcesActivity enumerateResourcesActivity;
        private CodeActivity InitializedEnumerateResourceActivity;
        private CodeActivity CheckUniqueCodeActivity;
        private IfElseBranchActivity UniqueValueFoundNotFound;
        private IfElseBranchActivity UniqueValueFound;
        private IfElseActivity ifElseUniqueValueFound;
        private ThrowActivity throwActivityUniqueValueNotFoundException;
        private CodeActivity SetErrorCodeActivity;
        private UpdateResourceActivity updateResourceActivity;
        private CodeActivity InitialiazeUpdateResourceCodeActivity;
        private FaultHandlersActivity faultHandlersActivity2;
        private CancellationHandlerActivity cancellationHandlerActivity2;



































































    }
}
