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
    /// Interaction logic for HardwareAssetPreview.xaml
    /// </summary>
    public partial class HardwareAssetPreview : UserControl
    {
        public HardwareAssetPreview()
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
            string iOwnershipType = (item["OwnershipType"] as IDataItem)["DisplayName"].ToString();
            string iNetworkDevice = (item["NetworkDevice"] as IDataItem)["DisplayName"].ToString();
            string iScannerDevice = (item["ScannerDevice"] as IDataItem)["DisplayName"].ToString();
            string iMobileDevice = (item["MobileDevice"] as IDataItem)["DisplayName"].ToString();
            string iOtherDevice = (item["OtherDevice"] as IDataItem)["DisplayName"].ToString();
            string iHardwareAgreement = (item["HardwareAgreement"] as IDataItem)["DisplayName"].ToString();
            string iLeaseAgreement = (item["LeaseAgreement"] as IDataItem)["DisplayName"].ToString();
            string iDesignatedUse = (item["DesignatedUse"] as IDataItem)["DisplayName"].ToString();
            string iHardware = (item["Hardware"] as IDataItem)["DisplayName"].ToString();
            string iPrinter = (item["Printer"] as IDataItem)["DisplayName"].ToString();
            string iStorageDevice = (item["StorageDevice"] as IDataItem)["DisplayName"].ToString();
            string iMonitorDevice = (item["MonitorDevice"] as IDataItem)["DisplayName"].ToString();
            string iAssignedUser = (item["AssignedUser"] as IDataItem)["DisplayName"].ToString();
            string iLocation = (item["Location"] as IDataItem)["DisplayName"].ToString();


            LocationBindMap();

        }
        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            this.AddHandler(FormEvents.PreviewSubmitEvent, new EventHandler<PreviewFormCommandEventArgs>(this.OnPreviewSubmit));

            LocationBindMap();
        }

        private void UserControl_DataContextChanged(object sender, DependencyPropertyChangedEventArgs e)
        {

            LocationBindMap();
        }

        private void LocationBindMap()
        {

            Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession session = (Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession)FrameworkServices.GetService<Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession>();
            EnterpriseManagementGroup mg = session.ManagementGroup;

            if (DataContext == null) return;

            IDataItem data = this.DataContext as IDataItem;

            if (data == null) return;

            string hai = data["$Id$"].ToString();

            if (hai == null) return;

            ManagementPackRelationship mprHardwareAssetHasLocation = mg.EntityTypes.GetRelationshipClass(new Guid("59079379-fddb-c6e4-0b9d-3dcf3d5f9233"));
            ManagementPackClass mpcLocation = mg.EntityTypes.GetClass(new Guid("3faa8fb6-1f35-2c91-f8d4-f7a8d3e5d35a"));
            try
            {
                IList<EnterpriseManagementRelationshipObject<EnterpriseManagementObject>> relobj = mg.EntityObjects.GetRelationshipObjectsWhereSource<EnterpriseManagementObject>(new Guid(hai), mprHardwareAssetHasLocation, DerivedClassTraversalDepth.Recursive, TraversalDepth.OneLevel, ObjectQueryOptions.Default);
                if (relobj == null) return;
                
                    String Long = relobj[0].TargetObject[null, "Longtitude"].ToString();
                    String Lat = relobj[0].TargetObject[null, "Latitude"].ToString();

                    if (Long == null || Lat == null) return;


                    double iLo = 0;
                    double iLa = 0;

                    double.TryParse(Long, out iLo);
                    double.TryParse(Lat, out iLa);

                    myMap.Center = new Microsoft.Maps.MapControl.WPF.Location(iLa, iLo);
                    myPin.Location = new Microsoft.Maps.MapControl.WPF.Location(iLa, iLo);
                
            }
            catch
            {
                double iLo = 0;
                double iLa = 0;

                myMap.Center = new Microsoft.Maps.MapControl.WPF.Location(iLa, iLo);
                myPin.Location = new Microsoft.Maps.MapControl.WPF.Location(iLa, iLo);

            }
            

           
        }

        private void expMain_Loaded(object sender, RoutedEventArgs e)
        {
            HeaderedContentControl headeredContentControl = new HeaderedContentControl();
            headeredContentControl.OverridesDefaultStyle = true;
            headeredContentControl.Foreground = Brushes.Black;
            headeredContentControl.Header = "Main";
            this.expMain.Header = headeredContentControl;
        }
    }
}
