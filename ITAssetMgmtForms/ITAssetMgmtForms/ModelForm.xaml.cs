﻿using System;
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


namespace ITAssetMgmtForms
{
    /// <summary>
    /// Interaction logic for ModelForm.xaml
    /// </summary>
    public partial class ModelForm : UserControl
    {
        public ModelForm()
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
        }

        private void expMain_Loaded(object sender, RoutedEventArgs e)
        {
            HeaderedContentControl headeredContentControl = new HeaderedContentControl();
            headeredContentControl.OverridesDefaultStyle = true;
            headeredContentControl.Foreground = Brushes.Black;
            headeredContentControl.Header = "Main";
            this.expMain.Header = headeredContentControl;
        }
        private void expDetails_Loaded(object sender, RoutedEventArgs e)
        {
            HeaderedContentControl headeredContentControl = new HeaderedContentControl();
            headeredContentControl.OverridesDefaultStyle = true;
            headeredContentControl.Foreground = Brushes.Black;
            headeredContentControl.Header = "References";
            this.expDetails.Header = headeredContentControl;
        }

        //

        private void btnAdd_Click_Hardware(object sender, RoutedEventArgs e)
        {
            AddItemToListView(this.Hardware, ITAssetMgmtForms.Resources.guidHardwareClass);
        }

        private void btnRemove_Click_Hardware(object sender, RoutedEventArgs e)
        {
            RemoveItemFromWorkItemListView(this.Hardware);
        }

        private void btnOpen_Click_Hardware(object sender, RoutedEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Hardware.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_Hardware(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Hardware.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        //
        private void btnAdd_Click_Scanner(object sender, RoutedEventArgs e)
        {
            AddItemToListView(this.Scanner, ITAssetMgmtForms.Resources.guidScannerClass);
        }

        private void btnRemove_Click_Scanner(object sender, RoutedEventArgs e)
        {
            RemoveItemFromWorkItemListView(this.Scanner);
        }

        private void btnOpen_Click_Scanner(object sender, RoutedEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Scanner.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_Scanner(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Scanner.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        //

        private void btnAdd_Click_Monitor(object sender, RoutedEventArgs e)
        {
            AddItemToListView(this.Monitor, ITAssetMgmtForms.Resources.guidMonitorClass);
        }

        private void btnRemove_Click_Monitor(object sender, RoutedEventArgs e)
        {
            RemoveItemFromWorkItemListView(this.Monitor);
        }

        private void btnOpen_Click_Monitor(object sender, RoutedEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Monitor.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_Monitor(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Monitor.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }
        //

        private void btnAdd_Click_OtherDevice(object sender, RoutedEventArgs e)
        {
            AddItemToListView(this.OtherDevice, ITAssetMgmtForms.Resources.guidOtherHWClass);
        }

        private void btnRemove_Click_OtherDevice(object sender, RoutedEventArgs e)
        {
            RemoveItemFromWorkItemListView(this.OtherDevice);
        }

        private void btnOpen_Click_OtherDevice(object sender, RoutedEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)OtherDevice.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_OtherDevice(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)OtherDevice.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }


        //
        private void btnAdd_Click_Printer(object sender, RoutedEventArgs e)
        {
            AddItemToListView(this.Printer, ITAssetMgmtForms.Resources.guidPrinterClass);
        }

        private void btnRemove_Click_Printer(object sender, RoutedEventArgs e)
        {
            RemoveItemFromWorkItemListView(this.Printer);
        }

        private void btnOpen_Click_Printer(object sender, RoutedEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Printer.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_Printer(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Printer.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }
        //

        private void btnAdd_Click_NetworkDevice(object sender, RoutedEventArgs e)
        {
            AddItemToListView(this.NetworkDevice, ITAssetMgmtForms.Resources.guidNetworkDeviceClass);
        }

        private void btnRemove_Click_NetworkDevice(object sender, RoutedEventArgs e)
        {
            RemoveItemFromWorkItemListView(this.NetworkDevice);
        }

        private void btnOpen_Click_NetworkDevice(object sender, RoutedEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)NetworkDevice.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_NetworkDevice(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)NetworkDevice.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }
        //

        private void btnAdd_Click_StorageDevice(object sender, RoutedEventArgs e)
        {
            AddItemToListView(this.StorageDevice, ITAssetMgmtForms.Resources.guidStorageDeviceClass);
        }

        private void btnRemove_Click_StorageDevice(object sender, RoutedEventArgs e)
        {
            RemoveItemFromWorkItemListView(this.StorageDevice);
        }

        private void btnOpen_Click_StorageDevice(object sender, RoutedEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)StorageDevice.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_MobileDevice(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)MobileDevice.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }
        //
        private void btnAdd_Click_MobileDevice(object sender, RoutedEventArgs e)
        {
            AddItemToListView(this.MobileDevice, ITAssetMgmtForms.Resources.guidMobileDeviceClass);
        }

        private void btnRemove_Click_MobileDevice(object sender, RoutedEventArgs e)
        {
            RemoveItemFromWorkItemListView(this.MobileDevice);
        }

        private void btnOpen_Click_MobileDevice(object sender, RoutedEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)MobileDevice.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_StorageDevice(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)NetworkDevice.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }
        //
        private void InstancePicker_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            SingleInstancePicker singleInstancePicker = (SingleInstancePicker)sender;
            FormUtilities.Instance.PopoutForm(singleInstancePicker.Instance);
        }
        //

        internal static void AddItemToListView(ListView listView, Guid classId)
        {
            if (listView != null && listView.Items != null)
            {
                InstancePickerDialog ciPicker = new InstancePickerDialog();
                ciPicker.ClassId = classId;
                ciPicker.SelectionMode = SelectionMode.Multiple;

                if (listView.Items.Count > 0)
                {
                    ciPicker.SetPickedInstances((Collection<IDataItem>)listView.ItemsSource);
                }

                bool? result = ciPicker.ShowDialog();
                if (result != null && result == true)
                {
                    Collection<IDataItem> items = listView.ItemsSource as Collection<IDataItem>;
                    foreach (IDataItem item in ciPicker.RemovedInstances)
                        items.Remove(item);

                    foreach (IDataItem item in ciPicker.PickedInstances)
                        if (!items.Contains(item))
                            items.Add(item);
                }
            }
        }

        internal static void RemoveItemFromWorkItemListView(ListView listView)
        {
            if (listView.ItemsSource == null ||
                            listView.SelectedItems == null ||
                            listView.SelectedItems.Count == 0)
            {
                return;
            }

            Collection<IDataItem> items = listView.ItemsSource as Collection<IDataItem>;
            if (items != null)
            {
                foreach (object obj in new ArrayList(listView.SelectedItems))
                {
                    /* NOTE: The use of the IDataItem interface here is not supported/documented.
                    * This interface may change in the future and no migration path is guaranteed 
        by Microsoft.
                    */
                    items.Remove(obj as IDataItem);
                }
            }
        }

        private void Hardware_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Printer_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void NetworkDevice_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void StorageDevice_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void MobileDevice_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Scanner_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Monitor_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void OtherDevice_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }
    }
}
