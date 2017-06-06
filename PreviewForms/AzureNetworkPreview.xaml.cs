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
    /// Interaction logic for AzureNetworkPreview.xaml
    /// </summary>
    public partial class AzureNetworkPreview : UserControl
    {
        public AzureNetworkPreview()
        {
            InitializeComponent();
        }

        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            this.AddHandler(FormEvents.PreviewSubmitEvent, new EventHandler<PreviewFormCommandEventArgs>(this.OnPreviewSubmit));
        }
        private void OnPreviewSubmit(object sender, PreviewFormCommandEventArgs e)
        {
            IDataItem NetworkName = this.DataContext as IDataItem;
            String strNetworkName;
            strNetworkName = NetworkName["NetworkName"].ToString();
            NetworkName["NetworkName"] = strNetworkName;

            IDataItem item = this.DataContext as IDataItem;
            string iGatewaySubnet = (item["GatewaySubnet"] as IDataItem)["DisplayName"].ToString();
            string iAzureResourceGroup = (item["AzureResourceGroup"] as IDataItem)["DisplayName"].ToString();
        }
        private void expMain_Loaded(object sender, RoutedEventArgs e)
        {
            HeaderedContentControl headeredContentControl = new HeaderedContentControl();
            headeredContentControl.OverridesDefaultStyle = true;
            headeredContentControl.Foreground = Brushes.Black;
            headeredContentControl.Header = "Main";
            this.expMain.Header = headeredContentControl;
        }
        private void MouseDoubleClick_Subnet(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Subnet.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void Subnet_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }
    }
}
