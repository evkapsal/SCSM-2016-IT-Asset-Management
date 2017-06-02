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

namespace ITAssetMgmtForms
{
    /// <summary>
    /// Interaction logic for Resources.xaml
    /// </summary>
    public partial class Resources : ResourceDictionary
    {

        //Enum
        public static Guid guidCurrencyEnumRoot = new Guid("e2077777-6a4a-cfb3-7d33-d76bac6a48f5");
        public static Guid guidReadinessEnumRoot = new Guid("d8e9a85a-f68c-0288-89a8-d035bdc5427a");
        public static Guid guidLifecycleEnumRoot = new Guid("89d31ab6-7682-4a4a-a497-8cec0e27a3a4");
        public static Guid guidCostLifecycleEnumRoot = new Guid("fb85866b-5015-ec43-6164-ac81075c2c5e");
        public static Guid guidTypeEnumRoot = new Guid("dd6e8f6c-6a95-0ea2-56e3-9a80a4f4e574");
        public static Guid guidOwnershipEnumRoot = new Guid("2b45294f-c4f2-178b-62d6-e4c180ee4280");
        public static Guid guidCompanyStatusEnumRoot = new Guid("cd133070-aea8-46f6-f7f9-5aa3f69f8258");
        public static Guid guidContactRoleEnumRoot = new Guid("9ee0ea99-4cb2-2b33-b326-cbda8d625370");
        public static Guid guidContactStatusEnumRoot = new Guid("cf3f7a2d-e12c-8edc-cb05-99f5bb2c7629");
        public static Guid guidOSTypeEnumRoot = new Guid("43ed0329-c09a-4177-50aa-83e0b2cd0b3d");
        public static Guid guidAssetClassEnumRoot = new Guid("ea05177d-026e-36c7-f843-9c77b860e21b");
        public static Guid guidCostCenterStatusEnumRoot = new Guid("2dd12b40-fcce-750e-2eec-968f31a8350d");
        public static Guid guidAgreementStatusEnumRoot = new Guid("f984af98-69bd-ebc2-0aa1-85158b6d0d46");
        public static Guid guidDeviceTypeEnumRoot = new Guid("dd6e8f6c-6a95-0ea2-56e3-9a80a4f4e574");
        public static Guid guidProcessorFamilyEnumRoot = new Guid("527a1dca-b1c9-6223-6fac-72d860020e59");
        public static Guid guidInvoiceTypeEnumRoot = new Guid("e127b2a5-9c54-e185-f509-cd4cb73f9e8b");
        public static Guid guidInvoiceLifecycleEnumRoot = new Guid("f3bea1f6-42ba-fffe-905f-a77b666229b8");
        public static Guid guidOrganizationStatusEnumRoot = new Guid("4c3893f0-6402-2328-3772-2110b10378af");
        public static Guid guidOrganizationTypeEnumRoot = new Guid("508488fd-c6df-c2f5-295c-77df5e90c448");
        public static Guid guidLocationTypeEnumRoot = new Guid("ba3acea0-365a-c2b6-6491-58cc51efd379");
        public static Guid guidPurchaseOrderEnumRoot = new Guid("db76f5ea-92df-2974-11c4-a60b2e2a6230");
        public static Guid guidPurchaseOrderLifeCycleEnumRoot = new Guid("c8953683-b292-2b2b-220e-b43f3f319b95");
        public static Guid guidSupportTypeEnumRoot = new Guid("ec7f9e00-2800-5db4-c8c0-7a02534b5d24");
        public static Guid guidSoftwareLicAgreementType = new Guid("4310c85c-1881-6487-8c98-f1510ee93f34");
        public static Guid guidHardwareAgreementType = new Guid("d746e4c6-1980-73db-f186-c12737450da9");
        public static Guid guidSupportAgreementDurationEnumRoot = new Guid("f021331e-e614-4026-eaef-8f0fc0b7342d");
        public static Guid guidSupportAgreementTypeEnumRoot = new Guid("d3199973-a83d-b296-cce3-35afcc6d5429");
        public static Guid guidDesignatedUseEnumRoot = new Guid("f8458810-b137-bb8e-50fa-52d42d3b3702");
        public static Guid guidManagemementScopeEnumRoot = new Guid("1bc1f300-c10c-9ed5-d6a0-f95b3f85f35e");
        public static Guid guidLicensingCategoryEnumRoot = new Guid("466240eb-8f93-2143-4a2a-ddd2adf0cdc5");
        public static Guid guidAssetStatusEnumRoot = new Guid("df83475d-d6d1-7236-fc6d-ec8fe52022b0");
        public static Guid guidLicenseModelEnumRoot = new Guid("2468306a-9140-8333-d141-3473609ea48a");
        public static Guid guidLicenseType = new Guid("962c7506-44a6-42ce-1808-087b1f408e9d");
        public static Guid guidLicensingProgramm = new Guid("f2882e51-4628-6bbd-ec6d-f4d37e6c8f7c");
        public static Guid guidLicensingUnit = new Guid("faaa0a26-de75-4125-566e-a590eba94bd9");
        public static Guid guidLicensingChannel = new Guid("d276bf28-19ce-d328-9d03-fba044184a53");
        public static Guid guidRoleClassificationEnum = new Guid("49167c8b-9fad-b800-aa9f-d2ffce40c26c");
        public static Guid guidSettingClassificationEnum = new Guid("27cd9d10-4f83-5bed-188c-cd09528b0e35");
        public static Guid guidOsettingClassificationEnum = new Guid("abad592b-1a05-31eb-5492-f3ee85b41d0c");
        public static Guid guidConnectorStatusEnum = new Guid("ce43cee1-1441-72e9-ade4-f74db4f4823c");
        public static Guid guidConnectorTypeEnum = new Guid("25fc65cd-1453-073f-b4aa-45a8a1d23252");
        public static Guid guidLeaseAgreementTypeEnum = new Guid("69f41cb6-0554-30b6-e3b1-d66e8f329977");
        public static Guid guidLicStatusEnumRoot = new Guid("9c64f79c-a4db-400d-0a7f-8c83e4fe7b8c");
        public static Guid guidNetDeviceTypeEnumRoot = new Guid("dc217cb4-937e-a093-38f9-41605e246a6a");
        public static Guid guidNetDeviceStatusEnumRoot = new Guid("d2c2c408-b55a-8eaa-c347-c43e18e95870");
        public static Guid guidStorageDeviceStatusEnumRoot = new Guid("c17a00b1-79e4-e5f4-0dc8-62439392474a");
        public static Guid guidDeviceConnEnumRoot = new Guid("45f1174c-6db6-ed25-ffbc-0da053f1565a");
        public static Guid guidPrinterConnEnumRoot = new Guid("8d8932eb-6c03-4b9c-d790-a4d54773bfd7");
        public static Guid guidPrinterTypeEnumRoot = new Guid("a92eb9e7-3849-9db9-13eb-b78e2fcc3233");
        public static Guid guidColorTypeEnumRoot = new Guid("4e154e95-06d1-96e1-5d0b-5daedca02dc9");
        public static Guid guidMobileDevTypeEnumRoot = new Guid("d0868e20-bcf6-ac62-cdaa-9ab36bf1a025");
        public static Guid guidOSMobDevTypeEnum = new Guid("a96dc1af-2ff7-7fbb-b148-a82d9ae89287");
        public static Guid guidMonTypeTypeEnum = new Guid("1692fd09-3149-31cd-6348-54e8d12e1100");
        public static Guid guidMonUseTypeTypeEnum = new Guid("ccec976e-0b83-eae9-90e6-788fa619cfca");
        public static Guid guidScanDevTypeEnum = new Guid("244b92b3-21b3-efca-ebd8-3e0530cd0eef");
        public static Guid guidScanConnTypeEnum = new Guid("7b4398de-48c7-41f3-8825-381572df6a33");
        public static Guid guidDocFdTypeEnum = new Guid("770fc68a-91ea-e1f3-acab-5876577f8ec3");
        public static Guid guidODevTypeEnum = new Guid("e9543c0d-5a7f-db40-b12b-628dc6c52142");
        public static Guid guidOConnTypeEnum = new Guid("0fdc8a41-6062-5a7e-fc53-bd19a936ed49");
        public static Guid guidODeskTypeEnum = new Guid("a4a6521e-04ae-fedf-0ac5-86171cbea7c2");
        public static Guid guidconfitemassetstatusEnum = new Guid("df83475d-d6d1-7236-fc6d-ec8fe52022b0");



        //Class
        public static Guid guidODeskClass = new Guid("189d74fe-03ad-a8ed-1c0b-2b57c3562a8c");
        public static Guid guidHardwareClass = new Guid("2e3768dc-30bb-acd6-6877-077e3806efdf");
        public static Guid guidScannerClass = new Guid("9f8b1a6b-70f9-f117-29e8-3e9ab02bbcb5");
        public static Guid guidOtherHWClass = new Guid("53fe3561-e7cd-2514-cab9-87f04fc39586");
        public static Guid guidCostCenterClass = new Guid("a85061f2-e0df-5d2b-9d08-639e3b511b04");
        public static Guid guidOrganizationClass = new Guid("6a01dc05-c370-3bae-d6aa-23c1397a3b4c");
        public static Guid guidHardwareAgreementClass = new Guid("bebd8a97-1874-58a8-68d6-8eff4210c1a0");
        public static Guid guidSupplierClass = new Guid("fceeb437-6b19-f16e-d27d-bb608b80e2e7");
        public static Guid guidPurchaseOrderClass = new Guid("a7e0acde-8f34-af22-aa37-54cf8ca4e987");
        public static Guid guidInvoiceClass = new Guid("16592ae2-ce10-e9c1-17ad-21695552d7e2");
        public static Guid guidAdUserClass = new Guid("eca3c52a-f273-5cdc-f165-3eb95a2b26cf");
        public static Guid guidLocationClass = new Guid("3faa8fb6-1f35-2c91-f8d4-f7a8d3e5d35a");
        public static Guid guidContactClass = new Guid("0324f587-fca9-bd3d-26f1-5e47eea54a4e");
        public static Guid guidSoftwareAgreementClass = new Guid("fb4fb64b-2d16-07ba-e859-ba3b44f84e24");
        public static Guid guidSupportAgreementClass = new Guid("f78260b8-74b4-ab4d-3bfa-aa01d0ef7b7a");
        public static Guid guidCostClass = new Guid("16fe24b6-f71f-1eb3-4708-be969467a748");
        public static Guid guidHardwareAssetClass = new Guid("9bac589e-2e28-badd-e4f7-1285492a45e7");
        public static Guid guidSoftwareAssetClass = new Guid("b8530ee6-a378-8a53-a69b-6036e446d512");
        public static Guid guidSoftwarePublisherClass = new Guid("939518b8-688f-8288-45b5-c0e1de692817");
        public static Guid guidSoftwareVersionClass = new Guid("d61ce355-823c-6ef9-93f5-fb2371b1e906");
        public static Guid guidSKUClass = new Guid("4c5531b9-fee0-179a-d38e-54abfcdde84c");
        public static Guid guidLicenseKeyClass = new Guid("b9791872-e4e2-6ce7-bdf9-d2dfb3e098d3");
        public static Guid guiSoftwareClass = new Guid("bde5f9f4-f8f5-92f3-c37c-03c61f412718");
        public static Guid guidSettingClass = new Guid("7dd81475-455e-614a-6d25-338b49928aad");
        public static Guid guidOtherSettingClass = new Guid("abb13117-da00-dcec-105c-93a12e9e9515");
        public static Guid guidShortcutclass = new Guid("c7a42ed0-46c2-77ec-f091-6ec266464c39");
        public static Guid guidUserRoleClass = new Guid("9ec422b1-923a-ee46-86ce-24e7bd2dbba5");
        public static Guid guidLeaseAgreementClass = new Guid("0c7c5038-d313-d121-0321-1f06c081736f");
        public static Guid guidDeviceManufacturerClass = new Guid("993309e5-bc79-9b80-3194-c9bf1be6a67d");
        public static Guid guidDeviceModelClass = new Guid("1fea4db7-0f4e-cd18-fad2-314951083c59");
        public static Guid guidPrinterClass = new Guid("f569a973-430d-1a28-630b-d1f6c8cff6fe");
        public static Guid guidNetworkDeviceClass = new Guid("a1364b8e-d1c3-47ce-2559-8b97af333a92");
        public static Guid guidStorageDeviceClass = new Guid("d7a66e3d-58db-ee06-d2cd-7c92612cc93a");
        public static Guid guidMobileDeviceClass = new Guid("33f6a317-83ec-685d-c143-c271ad911cf7");
        public static Guid guidWindowsDiskClass = new Guid("d6cb51c3-66a7-165d-ebfb-2fc8b525967d");
        public static Guid guidWindowsVolumeClass = new Guid("abf81a57-0a02-f2d9-e240-7dfd9cd58dda");
        public static Guid guidMonitorClass = new Guid("487aa8c7-dbcf-645c-28b1-9da18ed47660");
        public static Guid guidAzureSubscrtiptionClass = new Guid("59b58bb0-6280-5fc9-d98a-939db98fe61a");
        public static Guid guidAzureResourceGroup = new Guid("77a4a25b-df90-9b6d-de25-b8b7c12de1e3");
        public static Guid guidAzureNet = new Guid("c55c095f-c458-b3c7-9baf-1a42c2bcdffd");
        public static Guid guidAzureSubnet = new Guid("3eb8daf9-5794-c949-5b39-aaeeedd621c5");
        public static Guid guidAzureVM = new Guid("518f907b-b6aa-9c91-76e4-7218985944fd");
        public static Guid guidAzureVNetGateway = new Guid("4a487e44-a232-fd33-7316-0bf2db3fb823");
        public static Guid guidAzureLocation = new Guid("69a29a53-f423-5cf9-1b19-d3028cd880c1");
        public static Guid guidAzureConsumption = new Guid("7b401fc8-4d6e-cf24-3cfa-c6fa8884dc5a");
        public static Guid guidAzureSQlServerClass = new Guid("6a10a6ea-9dcc-dac7-f039-74170936fc5f");
        public static Guid guidAzureSQLDatabaseClass = new Guid("0f5069c1-48a4-e41c-9a0c-0e1de18351a7");
        public static Guid guidAzureWebAppClass = new Guid("2bb5bb3a-ec05-50ba-5f3c-81c585190753");

        public Resources()
        {
            InitializeComponent();
        }

        private void InitializeComponent()
        {
            throw new NotImplementedException();
        }
    }
}
