Import-Module smlets

#Remove System Software
$SoftwareCl= Get-SCSMClass -Name System.SoftwareItem$
$SoftObjs= Get-SCSMObject -Class $SoftwareCl
foreach ($SoftObj in $Softobjs)
{Remove-SCSMObject -SMObject $SoftObj -Force}

#Remove Hardware Computers
$HardCl= Get-SCSMClass -Name Hardware$ | ? {$_.ManagementPack -eq "IT_Asset_Management_Base"}
$HardwareItems= Get-SCSMObject -Class $HardCl
foreach($HardwareItem in $HardwareItems)
{Remove-SCSMObject -SMObject $HardwareItem -Force}

#Remove Hardware Assets
$HardAsCL= Get-SCSMClass -Name HardwareAsset$
$HardwareAssets= Get-SCSMObject -Class $HardAsCL
foreach($HardwareAsset in $HardwareAssets)
{Remove-SCSMObject -SMObject $HardwareAsset -Force}

#Remove Publishers
$PubCL= Get-SCSMClass -Name SoftwarePublisher$
$Publishers = Get-SCSMObject -Class $PubCL
foreach($Publisher in $Publishers)
{Remove-SCSMObject -SMObject $Publisher -Force}

#Remove Versions
$VersionCL= Get-SCSMClass -Name SoftwareVersion$
$Versions= Get-SCSMObject -Class $VersionCL
foreach($Version in $Versions)
{Remove-SCSMObject -SMObject $Version -Force}

#Remove Software
$SoftCL= Get-SCSMClass -Name Software$
$Softwares= Get-SCSMObject -Class $SoftCL
foreach($Software in $Softwares)
{Remove-SCSMObject -SMObject $software -Force}

#Remove Software Asset
$SftAssCl= Get-SCSMClass -Name SoftwareAsset$
$SoftAssets= Get-SCSMObject -Class $SftAssCl
foreach($SoftAsset in $SoftAssets)
{Remove-SCSMObject -SMObject $SoftAsset -Force}


