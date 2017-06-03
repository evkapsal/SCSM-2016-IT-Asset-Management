using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Collections.ObjectModel;
using System.Collections;
using Microsoft.EnterpriseManagement.Common;
using Microsoft.EnterpriseManagement.UI.Core.Connection;
using Microsoft.EnterpriseManagement.ConsoleFramework;
using Microsoft.EnterpriseManagement.Configuration;
using Microsoft.EnterpriseManagement.UI.SdkDataAccess.DataAdapters;
using Microsoft.EnterpriseManagement.GenericForm;
using Microsoft.EnterpriseManagement;
using Microsoft.EnterpriseManagement.ServiceManager.Application.Common;

////Requires Microsoft.EnterpriseManagement.UI.SMControls
using Microsoft.EnterpriseManagement.UI.WpfControls;    //Contains InstancePickerDialog, UserPicker, and ListPicker

////Requires Microsoft.EnterpriseManagement.UI.WpfViews
using Microsoft.EnterpriseManagement.UI.WpfViews;       //Contains FormEvents

//// Requires Microsoft.EnterpriseManagement.UI.Foundation
using Microsoft.EnterpriseManagement.UI.DataModel;      //Contains IDataItem

////Requires Microsoft.EnterpriseManagement.UI.FormsInfra
using Microsoft.EnterpriseManagement.UI.FormsInfra;     //Contains PreviewFormCommandEventArgs
namespace PreviewForms
{
    /// <summary>
    /// Interaction logic for CompanyPreview.xaml
    /// </summary>
    public partial class CompanyPreview : UserControl
    {
        public CompanyPreview()
        {
            InitializeComponent();
        }
        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            this.AddHandler(FormEvents.PreviewSubmitEvent, new EventHandler<PreviewFormCommandEventArgs>(this.OnPreviewSubmit));
        }
        private void OnPreviewSubmit(object sender, PreviewFormCommandEventArgs e)
        {
            IDataItem DisplayName = this.DataContext as IDataItem;
            String strDisplayName;
            strDisplayName = DisplayName["DisplayName"].ToString();
            DisplayName["DisplayName"] = strDisplayName;

            IDataItem LastModified = this.DataContext as IDataItem;
            String strLastModified;
            strLastModified = LastModified["LastModified"].ToString();
            LastModified["LastModified"] = strLastModified;
        }
        private void expMain_Loaded(object sender, RoutedEventArgs e)
        {
            HeaderedContentControl headeredContentControl = new HeaderedContentControl();
            headeredContentControl.OverridesDefaultStyle = true;
            headeredContentControl.Foreground = Brushes.Black;
            headeredContentControl.Header = "Main";
            this.expMain.Header = headeredContentControl;
        }
        private void MouseDoubleClick_HardwareAgreement(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)HardwareAgreement.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_Contact(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Contact.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_PurchaseOrder(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)PurchaseOrder.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void PurchaseOrder_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void MouseDoubleClick_Invoice(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Invoice.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_SoftwareAgreement(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)SoftwareAgreement.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_SupportAgreement(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)SupportAgreement.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void Invoice_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Contact_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void SupportAgreement_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void SoftwareAgreement_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void HardwareAgreement_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }
    }
}
