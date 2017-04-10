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

namespace ITAssetMgmtForms
{
    /// <summary>
    /// Interaction logic for SupportAgreementForm.xaml
    /// </summary>
    public partial class SupportAgreementForm : UserControl
    {
        private RelatedItemsPane _relatedItemsPane;
        public SupportAgreementForm()
        {
            InitializeComponent();
            _relatedItemsPane = new RelatedItemsPane(new ConfigItemRelatedItemsConfiguration());
            tabItemRelItems.Content = _relatedItemsPane;
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
            this.expMain.Header = headeredContentControl;
        }

          //

        private void InstancePicker_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            SingleInstancePicker singleInstancePicker = (SingleInstancePicker)sender;
            FormUtilities.Instance.PopoutForm(singleInstancePicker.Instance);
        }

        //

          private void btnAdd_Click_HardwareAsset(object sender, RoutedEventArgs e)
        {
            AddItemToListView(this.HardwareAsset, ITAssetMgmtForms.Resources.guidHardwareAssetClass);
        }

        private void btnRemove_Click_HardwareAsset(object sender, RoutedEventArgs e)
        {
            RemoveItemFromWorkItemListView(this.HardwareAsset);
        }

        private void btnOpen_Click_HardwareAsset(object sender, RoutedEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)HardwareAsset.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_HardwareAsset(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)HardwareAsset.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }
        //

        private void btnAdd_Click_PurchaseOrder(object sender, RoutedEventArgs e)
        {
            AddItemToListView(this.PurchaseOrder, ITAssetMgmtForms.Resources.guidPurchaseOrderClass);
        }


        private void btnRemove_Click_PurchaseOrder(object sender, RoutedEventArgs e)
        {
            RemoveItemFromWorkItemListView(this.PurchaseOrder);
        }

        private void btnOpen_Click_PurchaseOrder(object sender, RoutedEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)PurchaseOrder.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_PurchaseOrder(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)PurchaseOrder.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }
        //
        private void btnAdd_Click_Invoice(object sender, RoutedEventArgs e)
        {
            AddItemToListView(this.Invoice, ITAssetMgmtForms.Resources.guidInvoiceClass);
        }

        private void btnRemove_Click_Invoice(object sender, RoutedEventArgs e)
        {
            RemoveItemFromWorkItemListView(this.Invoice);
        }

        private void btnOpen_Click_Invoice(object sender, RoutedEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Invoice.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_Invoice(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Invoice.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }
        //
        private void btnAdd_Click_SoftwareAsset(object sender, RoutedEventArgs e)
        {
            AddItemToListView(this.SoftwareAsset, ITAssetMgmtForms.Resources.guidSoftwareAssetClass);
        }

        private void btnRemove_Click_SoftwareAsset(object sender, RoutedEventArgs e)
        {
            RemoveItemFromWorkItemListView(this.SoftwareAsset);
        }

        private void btnOpen_Click_SoftwareAsset(object sender, RoutedEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)SoftwareAsset.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_SoftwareAsset(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)SoftwareAsset.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }
      
        //
        private void btnAdd_Click_Contact(object sender, RoutedEventArgs e)
        {
            AddItemToListView(this.Contact, ITAssetMgmtForms.Resources.guidContactClass);
        }

        private void btnRemove_Click_Contact(object sender, RoutedEventArgs e)
        {
            RemoveItemFromWorkItemListView(this.Contact);
        }

        private void btnOpen_Click_Contact(object sender, RoutedEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Contact.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

        private void MouseDoubleClick_Contact(object sender, MouseButtonEventArgs e)
        {
            IDataItem emoProjectionObject = (IDataItem)Contact.SelectedItem;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
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

        private void Contact_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Invoice_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void SoftwareAsset_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void PurchaseOrder_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }
        private void HardwareAsset_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

    }
    
}
