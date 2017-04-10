using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using Microsoft.EnterpriseManagement.GenericForm;
using Microsoft.EnterpriseManagement.UI.FormsInfra;
using Microsoft.EnterpriseManagement.UI.SdkDataAccess;
using Microsoft.EnterpriseManagement.ConsoleFramework;
//// Requires Microsoft.EnterpriseManagement.UI.Foundation
using Microsoft.EnterpriseManagement.UI.DataModel;
//Contains IDataItem
////Requires Microsoft.EnterpriseManagement.ServiceManager.Application.Common
using Microsoft.EnterpriseManagement.ServiceManager.Application.Common;
using Microsoft.EnterpriseManagement.Configuration;
using Microsoft.EnterpriseManagement;
using Microsoft.EnterpriseManagement.Common; //Contains ConsoleContextHelper
using System.Windows.Forms;

namespace ITAssetManagementTasks
{
    class HWConnectorUIOpen : ConsoleCommand
    {

        public override void ExecuteCommand(IList<NavigationModelNodeBase> nodes, NavigationModelNodeTask task, ICollection<string> parameters)
        {
           
            //Getting the emg
            Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession session = (Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession)FrameworkServices.GetService<Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession>();
            EnterpriseManagementGroup emg = session.ManagementGroup;
            IDataItem HWConnectorUI = Microsoft.EnterpriseManagement.UI.Extensions.Shared.ConsoleContextHelper.Instance.GetProjectionInstance(new Guid("6ec06321-f6c7-6d8c-fa80-cb4df7d63f48"), new Guid("70e05905-0d8a-4113-0109-d1ffd47bdc43"));
            IDataItem emoProjectionObject = (IDataItem)HWConnectorUI;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
            
            
        }
    }


    class HWConnectorSyncNow : ConsoleCommand
    {

        public override void ExecuteCommand(IList<NavigationModelNodeBase> nodes, NavigationModelNodeTask task, ICollection<string> parameters)
        {

            //Getting the emg
            Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession session = (Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession)FrameworkServices.GetService<Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession>();
            EnterpriseManagementGroup mg = new EnterpriseManagementGroup("localhost");
            EnterpriseManagementObject HWConnector = mg.EntityObjects.GetObject<EnterpriseManagementObject>(new Guid("6ec06321-f6c7-6d8c-fa80-cb4df7d63f48"), ObjectQueryOptions.Default);
            HWConnector[null,"SyncNow"].Value = (bool)true;
            HWConnector.Commit();
            MessageBox.Show("Hardware Synchronization will Start in a while...", "IT Asset Management" , MessageBoxButtons.OK);
         
        }
    }

    class SWConnectorSyncNow : ConsoleCommand
    {

        public override void ExecuteCommand(IList<NavigationModelNodeBase> nodes, NavigationModelNodeTask task, ICollection<string> parameters)
        {

            //Getting the emg
            Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession session = (Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession)FrameworkServices.GetService<Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession>();
            EnterpriseManagementGroup mg = new EnterpriseManagementGroup("localhost");
            EnterpriseManagementObject SWConnector = mg.EntityObjects.GetObject<EnterpriseManagementObject>(new Guid("2338f5c9-020a-9c82-28bb-e955ad8751a7"), ObjectQueryOptions.Default);
            SWConnector[null, "SyncNow"].Value = (bool)true;
            SWConnector.Commit();
            MessageBox.Show("Software Synchronization will Start in a while...", "IT Asset Management", MessageBoxButtons.OK);



        }
    }



    class LicConnectorSyncNow : ConsoleCommand
    {

        public override void ExecuteCommand(IList<NavigationModelNodeBase> nodes, NavigationModelNodeTask task, ICollection<string> parameters)
        {

            //Getting the emg
            Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession session = (Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession)FrameworkServices.GetService<Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession>();
            EnterpriseManagementGroup mg = new EnterpriseManagementGroup("localhost");
            EnterpriseManagementObject LicConnector = mg.EntityObjects.GetObject<EnterpriseManagementObject>(new Guid("21c88509-5a22-365b-bdb3-a2122ea4508a"), ObjectQueryOptions.Default);
            LicConnector[null, "SyncNow"].Value = (bool)true;
            LicConnector.Commit();
            MessageBox.Show("License Synchronization will Start in a while...", "IT Asset Management", MessageBoxButtons.OK);



        }
    }


    class SWConnectorUIOpen : ConsoleCommand
    {

        public override void ExecuteCommand(IList<NavigationModelNodeBase> nodes, NavigationModelNodeTask task, ICollection<string> parameters)
        {

            //Getting the emg
            Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession session = (Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession)FrameworkServices.GetService<Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession>();
            EnterpriseManagementGroup emg = session.ManagementGroup;
            IDataItem HWConnectorUI = Microsoft.EnterpriseManagement.UI.Extensions.Shared.ConsoleContextHelper.Instance.GetProjectionInstance(new Guid("2338f5c9-020a-9c82-28bb-e955ad8751a7"), new Guid("74a46790-b217-ea0f-28b7-ecbc658e8f29"));
            IDataItem emoProjectionObject = (IDataItem)HWConnectorUI;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);


        }
    }

    class LicenseSyncUIOpen : ConsoleCommand
    {

        public override void ExecuteCommand(IList<NavigationModelNodeBase> nodes, NavigationModelNodeTask task, ICollection<string> parameters)
        {

            //Getting the emg
            Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession session = (Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession)FrameworkServices.GetService<Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession>();
            EnterpriseManagementGroup emg = session.ManagementGroup;
            IDataItem HWConnectorUI = Microsoft.EnterpriseManagement.UI.Extensions.Shared.ConsoleContextHelper.Instance.GetProjectionInstance(new Guid("21c88509-5a22-365b-bdb3-a2122ea4508a"), new Guid("46e2eadd-42e1-991f-95d1-9afe089c8a98"));
            IDataItem emoProjectionObject = (IDataItem)HWConnectorUI;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);


        }
    }

    class AmazonConnUIOpen : ConsoleCommand
    {
        public override void ExecuteCommand(IList<NavigationModelNodeBase> nodes, NavigationModelNodeTask task, ICollection<string> parameters)
        {

            //Getting the emg
            Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession session = (Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession)FrameworkServices.GetService<Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession>();
            EnterpriseManagementGroup emg = session.ManagementGroup;
            IDataItem HWConnectorUI = Microsoft.EnterpriseManagement.UI.Extensions.Shared.ConsoleContextHelper.Instance.GetProjectionInstance(new Guid("69501c7e-0d07-a401-80f8-4fe8bd7147de"), new Guid("c54fe486-44ab-0dd2-a8c7-2eadc995b274"));
            IDataItem emoProjectionObject = (IDataItem)HWConnectorUI;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

    }

    class AzureConnUIOpen : ConsoleCommand
    {
        public override void ExecuteCommand(IList<NavigationModelNodeBase> nodes, NavigationModelNodeTask task, ICollection<string> parameters)
        {

            //Getting the emg
            Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession session = (Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession)FrameworkServices.GetService<Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession>();
            EnterpriseManagementGroup emg = session.ManagementGroup;
            IDataItem HWConnectorUI = Microsoft.EnterpriseManagement.UI.Extensions.Shared.ConsoleContextHelper.Instance.GetProjectionInstance(new Guid("bbb51076-e86f-ecee-f535-cdaade5bcbad"), new Guid("baec3cda-8f2d-588c-9182-cefd1847e638"));
            IDataItem emoProjectionObject = (IDataItem)HWConnectorUI;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }

    }

    class ADGroupUIOpen : ConsoleCommand
    {

        public override void ExecuteCommand(IList<NavigationModelNodeBase> nodes, NavigationModelNodeTask task, ICollection<string> parameters)
        {

            //Getting the emg
            Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession session = (Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession)FrameworkServices.GetService<Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession>();
            EnterpriseManagementGroup emg = session.ManagementGroup;
            IDataItem HWConnectorUI = Microsoft.EnterpriseManagement.UI.Extensions.Shared.ConsoleContextHelper.Instance.GetProjectionInstance(new Guid("5fb27713-acf5-28b8-d7b9-0483a255b0af"), new Guid("42ab3437-c522-c4e1-e29d-0acf1082a8ec"));
            IDataItem emoProjectionObject = (IDataItem)HWConnectorUI;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);
        }


    }


    class OMSConnectorUIOpen : ConsoleCommand
    {

        public override void ExecuteCommand(IList<NavigationModelNodeBase> nodes, NavigationModelNodeTask task, ICollection<string> parameters)
        {

            //Getting the emg
            Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession session = (Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession)FrameworkServices.GetService<Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession>();
            EnterpriseManagementGroup emg = session.ManagementGroup;
            IDataItem OMSConnectorUI = Microsoft.EnterpriseManagement.UI.Extensions.Shared.ConsoleContextHelper.Instance.GetProjectionInstance(new Guid("a34fe17a-0ca7-4b85-08c2-2039ac41ca44"), new Guid("df38f99c-ee70-647a-4d2e-fd6e41fe481f"));
            IDataItem emoProjectionObject = (IDataItem)OMSConnectorUI;
            Microsoft.EnterpriseManagement.GenericForm.FormUtilities.Instance.PopoutForm(emoProjectionObject);


        }
    }


    class OMSConnectorSyncNow : ConsoleCommand
    {

        public override void ExecuteCommand(IList<NavigationModelNodeBase> nodes, NavigationModelNodeTask task, ICollection<string> parameters)
        {

            //Getting the emg
            Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession session = (Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession)FrameworkServices.GetService<Microsoft.EnterpriseManagement.UI.Core.Connection.IManagementGroupSession>();
            EnterpriseManagementGroup mg = new EnterpriseManagementGroup("localhost");
            EnterpriseManagementObject OMSConnector = mg.EntityObjects.GetObject<EnterpriseManagementObject>(new Guid("a34fe17a-0ca7-4b85-08c2-2039ac41ca44"), ObjectQueryOptions.Default);
            OMSConnector[null, "SyncNow"].Value = (bool)true;
            OMSConnector.Commit();
            MessageBox.Show("OMS FUll Synchronization will Start in a while...", "IT Asset Management", MessageBoxButtons.OK);



        }
    }

}
