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
using Microsoft.Maps.MapControl.WPF;

namespace PreviewForms
{
    /// <summary>
    /// Interaction logic for LocationPreview.xaml
    /// </summary>
    public partial class LocationPreview : UserControl
    {
        public LocationPreview()
        {
            InitializeComponent();
            Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession session = (Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession)FrameworkServices.GetService<Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession>();
            EnterpriseManagementGroup mg = session.ManagementGroup;
            EnterpriseManagementObject HWConnector = mg.EntityObjects.GetObject<EnterpriseManagementObject>(new Guid("6ec06321-f6c7-6d8c-fa80-cb4df7d63f48"), ObjectQueryOptions.Default);
            string iMapkey = HWConnector[null, "Mapkey"].Value.ToString();
            myMap.CredentialsProvider = new ApplicationIdCredentialsProvider(iMapkey);
        }

        private void OnPreviewSubmit(object sender, PreviewFormCommandEventArgs e)
        {
            IDataItem DisplayName = this.DataContext as IDataItem;
            String strDisplayName;
            strDisplayName = DisplayName["DisplayName"].ToString();
            DisplayName["DisplayName"] = strDisplayName;

            IDataItem item = this.DataContext as IDataItem;
            string iType = (item["Type"] as IDataItem)["DisplayName"].ToString();

            BindMap();

        }

        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            this.AddHandler(FormEvents.PreviewSubmitEvent, new EventHandler<PreviewFormCommandEventArgs>(this.OnPreviewSubmit));

            BindMap();
        }

        private void UserControl_DataContextChanged(object sender, DependencyPropertyChangedEventArgs e)
        {
           
            BindMap();
        }

        private void BindMap()
        {
            if (DataContext == null) return;

            IDataItem data = this.DataContext as IDataItem;

            if (data == null) return;

            if (!data.HasProperty("Longtitude") || !data.HasProperty("Latitude")) return;

            if (data["Longtitude"] == null || data["Latitude"] == null) return;

            String strLong = data["Longtitude"].ToString();
            String strLat = data["Latitude"].ToString();

            double iLo = 0;
            double iLa = 0; //TODO Put default coordinates here

            double.TryParse(strLong, out iLo);
            double.TryParse(strLat, out iLa);

            myMap.Center = new Microsoft.Maps.MapControl.WPF.Location(iLa, iLo);
            myPin.Location = new Microsoft.Maps.MapControl.WPF.Location(iLa, iLo);
        }

        private void expMain_Loaded(object sender, RoutedEventArgs e)
        {
            HeaderedContentControl headeredContentControl = new HeaderedContentControl();
            headeredContentControl.OverridesDefaultStyle = true;
            headeredContentControl.Foreground = Brushes.Black;
            headeredContentControl.Header = "Main";
            this.expMain.Header = headeredContentControl;
        }

        private void MouseDoubleClick_Organization(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Organization.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_HardwareAgreement(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)HardwareAgreement.SelectedItem;
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

        private void MouseDoubleClick_PurchaseOrder(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)PurchaseOrder.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_CostCenter(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)CostCenter.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_Invoice(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Invoice.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_HardwareAsset(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)HardwareAsset.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_SoftwareAsset(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)SoftwareAsset.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
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

        private void PurchaseOrder_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void CostCenter_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Invoice_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }


        private void HardwareAsset_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void SoftwareAsset_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Organization_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

    }
}
