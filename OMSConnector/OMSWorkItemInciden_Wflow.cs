//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:2.0.50727.8745
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace WorkflowAuthoring
{
    using System;
    using System.ComponentModel;
    using System.ComponentModel.Design;
    using System.Workflow.ComponentModel.Design;
    using System.Workflow.ComponentModel;
    using System.Workflow.ComponentModel.Serialization;
    using System.Workflow.ComponentModel.Compiler;
    using System.Drawing;
    using System.Collections;
    using System.Workflow.Activities;
    using System.Workflow.Runtime;
    
    
    public partial class OMSWorkItemInciden_Wflow : System.Workflow.Activities.SequentialWorkflowActivity
    {
        
        public static System.Workflow.ComponentModel.DependencyProperty windowsPowerShellScript1_iIDProperty = DependencyProperty.Register("windowsPowerShellScript1_iID", typeof(System.String), typeof(WorkflowAuthoring.OMSWorkItemInciden_Wflow));
        
        public static System.Workflow.ComponentModel.DependencyProperty windowsPowerShellScript1_IDProperty = DependencyProperty.Register("windowsPowerShellScript1_ID", typeof(System.String), typeof(WorkflowAuthoring.OMSWorkItemInciden_Wflow));
        
        public string windowsPowerShellScript1_iID
        {
            get
            {
                return ((string)(base.GetValue(WorkflowAuthoring.OMSWorkItemInciden_Wflow.windowsPowerShellScript1_iIDProperty)));
            }
            set
            {
                base.SetValue(WorkflowAuthoring.OMSWorkItemInciden_Wflow.windowsPowerShellScript1_iIDProperty, value);
            }
        }
        
        public string windowsPowerShellScript1_ID
        {
            get
            {
                return ((string)(base.GetValue(WorkflowAuthoring.OMSWorkItemInciden_Wflow.windowsPowerShellScript1_IDProperty)));
            }
            set
            {
                base.SetValue(WorkflowAuthoring.OMSWorkItemInciden_Wflow.windowsPowerShellScript1_IDProperty, value);
            }
        }
    }
}
