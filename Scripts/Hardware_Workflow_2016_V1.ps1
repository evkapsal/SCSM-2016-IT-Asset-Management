﻿#===========================================================================
#Created with:  SAPIEN Technologies, Inc., PowerShell Studio 2015
#Created on:    23/4/2017 22:00 PM
#Created by:     Evangelos Kapsalakis
#Organization:   Microsoft Hellas
#Filename:  Hardware Connector 2016 V1.0
#===========================================================================
#.DESCRIPTION
#A description of the file.

Import-Module "C:\Program Files\WindowsPowerShell\Modules\SMLets\0.5.0.1\SMLets"

$HardwareConnectorAdminSettingCl = Get-SCSMClass -Name HardwareConnector$
$HardwareConnectorAdminSettingObj = Get-SCSMObject -Class $HardwareConnectorAdminSettingCl
if ($HardwareConnectorAdminSettingObj.IsActive -eq $true)
{
	#Set-SCSMObject -SMObject $HardwareConnectorAdminSettingObj -Property "SyncNow" -Value $false
	
	TryCmdlets
	{
		$ActiveId = (Get-SCSMEnumeration -Name ITSMConnectorStatus.Running$).id
		Set-SCSMObject -SMObject $HardwareConnectorAdminSettingObj -Property "Status" -Value $ActiveId
	}
	Catch { }
	
	
	
	##
	try
	{
		$SQLSrv = (Get-SCSMConnector | ?{ $_.DataProviderName -eq "SmsConnector" }).ServerName
		$DBName = (Get-SCSMConnector | ?{ $_.DataProviderName -eq "SmsConnector" }).DatabaseName
	}
	catch { }
	
	Try
	{
		$events = [System.Diagnostics.EventLog]::SourceExists("Hardware Connector");
	}
	catch { }
	finally
	{
		if ($events -ne $true)
		{
			New-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector'
			Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Hardware Connector Succesfully Create Event Log Source"
		}
		
		Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Hardware Connector Start Processing Hardware Objects"
	}
	
	#EventIDs for Logging
	
	$ErrorID = 10101
	$InfoID = 10100
	$WarningId = 10102
	$PreFix = $HardwareConnectorAdminSettingObj.AssetTagPrefix
	
	#Instanciante Variables
	
	$ActiveObjEnum = (Get-SCSMEnumeration -Name ObjectStatusEnum.Active).id
	$ReadinessStatusEnumId = (Get-SCSMEnumeration -Name ReadinessStatus.InUse).id
	$ReadinessStatusNotUsedEnumId = (Get-SCSMEnumeration -Name ReadinessStatus.ReadyForUse).id
	$HardwareHasUserRelCl = Get-SCSMRelationshipClass -Name Relationship.HardwareHasUser$
	$HardwareAssetHasUser = Get-SCSMRelationshipClass -Name Relationship.HardwareAssetHasUser$
	$ConfigItemRelCl = Get-SCSMRelationshipClass -Name System.ConfigItemRelatesToConfigItem$
	$ComputerProjectionClass = Get-SCSMTypeProjection Microsoft.Windows.Computer.ProjectionType$
	$NetworkClass = Get-SCSMClass -Name System.NetworkManagement.Node$
	$NetworkDeviceClass = Get-SCSMClass -Name NetworkDevice$ | ?{ $_.ManagementPack -eq "IT_Asset_Management_Base" }
	$UserClass = Get-SCSMClass -Name System.Domain.User$
	$NetDevUserRelationShip = Get-SCSMRelationshipClass -Name Relationship.NetworkDeviceHasUser$
	$NetDevModelRel = Get-SCSMRelationshipClass -Name Relationship.NetworkDeviceHasModel$
	$NetDevManufactRel = Get-SCSMRelationshipClass -Name Relationship.NetworkDeviceHasManufacturer$
	$DevModel = Get-scsmclass -name DeviceModel$
	$DevManufacturer = Get-scsmclass -name DeviceManufacturer$
	$ModelHasManufacturerRelCl = Get-SCSMRelationshipClass -Name Relationship.DeviceModelHasManufacturer$
	$HardwareHasModel = Get-SCSMRelationshipClass -Name Relationship.HardwareHasModel$
	$NetHardwareAssetTypeId = (Get-SCSMEnumeration -Name HardwareAssetType.NetworkDevice$).id
	$SystemPrinterClass = Get-SCSMClass -Name Microsoft.AD.Printer$
	$PrinterClass = Get-SCSMClass -Name Printer$ | ?{ $_.ManagementPack -eq "IT_Asset_Management_Base" }
	$ScannerClass = Get-s
	$StorageDeviceClass = Get-SCSMClass -Name StorageDevice$
	$SystemMobileClass = Get-SCSMClass -Name Microsoft.SystemCenter.ConfigurationManager.MobileDevice$
	$MobileDeviceClass = Get-SCSMClass -Name MobileDevice$ | ?{ $_.ManagementPack -eq "IT_Asset_Management_Base" }
	$PendingDeleteEnumId = (Get-SCSMEnumeration -Name System.ConfigItem.ObjectStatusEnum.PendingDelete$).Id
	$PrinterHasUserClass = Get-SCSMRelationshipClass -Name Relationship.PrinterHasUser$
	$PrinterAssetEnumId = (Get-SCSMEnumeration -Name HardwareAssetType.Printer$).id
	$ActiveDeviceStatusEnumId = (Get-SCSMEnumeration -Name DeviceStatus.Active$).id
	$WindowsMobileEnumId = (Get-SCSMEnumeration -Name ODdevType.Windows$).id
	$AndroidMobileEnumId = (Get-SCSMEnumeration -Name ODdevType.Android$).id
	$IoSMobileEnumId = (Get-SCSMEnumeration -Name ODdevType.IOS$).id
	$OtherMobileEnumId = (Get-SCSMEnumeration -Name ODdevType.Other$).id
	$MobileDevHasUsr = Get-SCSMRelationshipClass -Name Relationship.MobileDeviceHasUser$
	$MobDevHasManufacturer = Get-SCSMRelationshipClass -Name Relationship.MobileDeviceHasManufacturer$
	$MobDevHasModel = Get-SCSMRelationshipClass -Name Relationship.MobileDeviceHasModel$
	$AssetMobileEnumId = (Get-SCSMEnumeration -Name HardwareAssetClass.Mobile$).id
	$HardwareConnectorAdminSettingCl = Get-SCSMClass -Name HardwareConnector$
	$HardwareConnectorAdminSettingObj = Get-SCSMObject -Class $HardwareConnectorAdminSettingCl
	$HAssetRefMobRelCl = Get-SCSMRelationshipClass -Name Relationship.HardwareAssetReferencesMobileDevice$
	$HAssetRefPrinterRelCl = Get-SCSMRelationshipClass -Name Relationship.HardwareAssetReferencesPrinter$
	$HAssetRefNetRelCl = Get-SCSMRelationshipClass -Name Relationship.HardwareAssetReferencesNetworkDevice$
	$HAssetRefStorRelCl = Get-SCSMRelationshipClass -Name Relationship.HardwareAssetReferencesStorageDevice$
	$HardwareClass = Get-SCSMClass  Hardware$ | ? { $_.ManagementPack -eq "IT_Asset_Management_Base" }
	$HardwareAssetClass = Get-SCSMClass -Name HardwareAsset$
	$HardwareAssetRefHardwareRelCl = Get-SCSMRelationshipClass -Name Relationship.HardwareAssetReferencesHardware$
	$HardwareHasManufacturerRelCl = Get-SCSMRelationshipClass -Name Relationship.HardwareHasManufacturer$
	$HardwareHasModelRelCl = Get-SCSMRelationshipClass -Name Relationship.HardwareHasModel$
	$ContainDiskRelCl = Get-SCSMRelationshipClass -Name Relationship.HardwareContainsDisks$
	$ContainVolumeRelCl = Get-SCSMRelationshipClass -Name Relationship.HardwareContainsVolumes$
	$DevHasSoftInstalledRelClId = (Get-SCSMRelationshipClass -Name System.DeviceHasSoftwareItemInstalled$).id
	$DevHasUpdInstalledRelClId = (Get-SCSMRelationshipClass -Name System.DeviceHasSoftwareUpdateInstalled$).id
	
	#Asset Class Enum
	$ComputerHWAssetEnumId = (Get-SCSMEnumeration -Name HardwareAssetClass.Computer$).id
	$VMHWAssetEnumId = (Get-SCSMEnumeration -Name HardwareAssetClass.VirtualMachine$).id
	
	#Asset Types Enum
	$SrvAssetTypeEnumId = (Get-SCSMEnumeration -Name HardwareAssetType.Server$).id
	$DesktopAssetTypeEnumId = (Get-SCSMEnumeration -Name HardwareAssetType.Desktop$).id
	$VMAssetTypeEnumId = (Get-SCSMEnumeration -Name HardwareAssetType.VirtualMachine$).id
	
	#OS Enum
	$CompOSId = (Get-SCSMEnumeration -Name OperatingSystemFoundation.Windows).id
	$ServerOSId = (Get-SCSMEnumeration -Name OperatingSystemType.Server).id
	$ClientOSId = (Get-SCSMEnumeration -Name OperatingSystemType.Client).id
	
	#Processor Family Enum
	$Amd64Id = (Get-SCSMEnumeration -Name ProcessorFamily.Amd$).id
	$x86 = (Get-SCSMEnumeration -Name ProcessorFamily.X86$).id
	
	#Rel Cl
	$UsrUsDevRelClId = (Get-SCSMRelationshipClass -Name System.UserUsesDevice$).id
	
	#Function For Hashing String
	Function Get-StringHash([String]$String)
	{
		$StringBuilder = New-Object System.Text.StringBuilder
		[System.Security.Cryptography.HashAlgorithm]::Create('MD5').ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String)) | %{
			[Void]$StringBuilder.Append($_.ToString("x2"))
		}
		$StringBuilder.ToString()
	}
	
	#Function For Executing SQL Query to SCCM For Processor Details.
	Function Get-ProcessorDetails
	{
		param (
			[string]$COMP,
			[string]$Server,
			[string]$Database
		)
		
		[string]$UserSQLQuery = $("SELECT NumberOfCores0 ,NumberOfLogicalProcessors0 
        FROM [dbo].[v_GS_PROCESSOR] CPU 
        INNER JOIN v_R_System VR
        ON CPU.ResourceID = VR.ResourceID
        WHERE SystemName0 = '$COMP'")
		
		function ExecuteSqlQuery ($Server, $Database, $SQLQuery)
		{
			$Datatable = New-Object System.Data.DataTable
			
			$Connection = New-Object System.Data.SQLClient.SQLConnection
			$Connection.ConnectionString = "server='$Server';database='$Database';trusted_connection=true;"
			$Connection.Open()
			$Command = New-Object System.Data.SQLClient.SQLCommand
			$Command.Connection = $Connection
			$Command.CommandText = $SQLQuery
			$Reader = $Command.ExecuteReader()
			$Datatable.Load($Reader)
			$Connection.Close()
			
			return $Datatable
		}
		
		$resultsDataTable = New-Object System.Data.DataTable
		$resultsDataTable = ExecuteSqlQuery $Server $Database $UserSqlQuery
		
		$PLResult = New-Object PSObject -Property @{
			Cores = $resultsDataTable.NumberOfCores0
			Processors = $resultsDataTable.NumberOfLogicalProcessors0
			ServerName = $COMP
		}
		return $PLResult
	}
	
	function Get-InactiveComputers
	{
		param (
			[string]$Server,
			[string]$Database
		)
		
		[string]$UserSqlQuery = $("select a.Name0 from v_R_System a
  join v_AgentDiscoveries b on b.ResourceId=a.ResourceId where
  (AgentName  like 'Heartbeat Discovery' and DATEDIFF(Day, AgentTime, Getdate())&gt;=30) OR
  (AgentName  like 'SMS_AD_SYSTEM_DISCOVERY_AGENT' and DATEDIFF(Day, AgentTime, Getdate())&gt;=30)")
		
		function ExecuteSqlQuery ($Server, $Database, $SQLQuery)
		{
			$Datatable = New-Object System.Data.DataTable
			$Connection = New-Object System.Data.SQLClient.SQLConnection
			$Connection.ConnectionString = "server='$Server';database='$Database';trusted_connection=true;"
			$Connection.Open()
			$Command = New-Object System.Data.SQLClient.SQLCommand
			$Command.Connection = $Connection
			$Command.CommandText = $UserSQLQuery
			$Reader = $Command.ExecuteReader()
			$Datatable.Load($Reader)
			$Connection.Close()
			
			return $Datatable
		}
		
		$resultsDataTable = New-Object System.Data.DataTable
		$resultsDataTable = ExecuteSqlQuery $Server $Database $UserSqlQuery
		
		$PLResult = $resultsDataTable.Name0
		return $PLResult
		
	}
	
	$InactiveComputers = $null
	$InactiveComputers = Get-InactiveComputers -Server $SQLSrv -Database $DBName
	
	#Process Windows Computers
	Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Hardware Connector Start Processing of Computer Objects"
	$WindowsComputers = Get-SCSMObjectProjection -Projection $ComputerProjectionClass -Filter "ObjectStatus -eq $ActiveObjEnum"
	if ($WindowsComputers)
	{
		foreach ($WindowsComputer in $WindowsComputers)
		{
			$DevUsrExists = $null
			$CompName = $WindowsComputer.PrincipalName
			
			$HWExists = Get-SCSMObject -Class $HardwareClass -Filter "DeviceName -eq $CompName" -ErrorAction SilentlyContinue
			if (!$HWExists)
			{
				#write-verbose "[INFO]`t Processing Computer $CompName..."
				Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $InfoID -Category 0 -EntryType Information -Message "Hardware Connector Found $CompName. Start Processing Item."
				$CompManufacturer = $null
				$CompModel = $null
				[string]$CompModel = $WindowsComputer.Model
				[string]$CompManufacturer = $WindowsComputer.Manufacturer
				[datetime]$LastModified = $WindowsComputer.Object.LastModified
				
				
				##Processing Cores and Processors
				$Sockets = $null
				[int]$Sockets = (Get-SCSMRelatedObject -SMObject $WindowsComputer.Object | ?{ $_.ClassName -eq "Microsoft.Windows.Peripheral.Processor" } | Measure-Object).Count
				
				try
				{
					try
					{
						$Res = $null
						$Res = Get-ProcessorDetails -COMP $($WindowsComputer.NetbiosComputerName) -Server $SQLSrv -Database $DBName
					}
					Catch
					{
						$Res = $null
						Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Query SCCM DB For Computer: $($WindowsComputer.DisplayName). Please Ensure that SCSM Workflow Account has Read Permission on SQL Server: $SQLSrv and Database: $DBName."
					}
					Finally
					{
						if (($Res.Processors | Measure-Object).Count -gt 1)
						{
							$FPhyProcSum = $null
							$LogicProc = $null
							$FPhyProcSum = $($Res.Processors) -join '+'
							$LogicProc = Invoke-Expression $FPhyProcSum
							
							$FPhyCorSum = $($Res.Cores) -join '+'
							$PhysProc = Invoke-Expression $FPhyCorSum
							
						}
						else
						{
							$LogicProc = $null
							$PhysProc = $null
							$LogicProc = $Res.Processors
							$PhysProc = $Res.Cores
						}
						
					}
				}
				finally
				{
					[int]$PhysicalCores = $PhysProc
				}
				
				try
				{
					$SerialNumber = $null
					$SerialNumber = $WindowsComputer.DeployedComputer[0].SerialNumber
				}
				catch
				{
					$SerialNumber = "Not Present"
				}
				
				$OSDisplayName = (Get-SCSMRelatedObject -SMObject $WindowsComputer.Object | ? { $_.ClassName -eq "Microsoft.Windows.OperatingSystem" }).OSVersionDisplayName
				$OSVersion = (Get-SCSMRelatedObject -SMObject $WindowsComputer.Object | ? { $_.ClassName -eq "Microsoft.Windows.OperatingSystem" }).OSVersion
				$Memory = (Get-SCSMRelatedObject -SMObject $WindowsComputer.Object | ? { $_.ClassName -eq "Microsoft.Windows.OperatingSystem" }).PhysicalMemory
				$DataWidth = (Get-SCSMRelatedObject -SMObject $WindowsComputer.Object | ? { $_.ClassName -eq "Microsoft.Windows.Peripheral.Processor" }).DataWidth
				#$SystemType= (Get-SCSMObject -Class (Get-SCSMClass -Name Microsoft.SystemCenter.ConfigurationManager.DeployedComputer) -Filter "SerialNumber -eq $SerialNumber").SystemType[0]
				
				$Nets = Get-SCSMRelatedObject -SMObject $WindowsComputer.Object | ? { $_.ClassName -eq "Microsoft.Windows.ComputerNetworkAdapter" } -ErrorAction SilentlyContinue
				If (!$Nets)
				{
					$Nets = Get-SCSMRelatedObject -SMObject $WindowsComputer.Object | ? { $_.ClassName -eq "Microsoft.Windows.Peripheral.NetworkAdapter" } -ErrorAction SilentlyContinue
				}
				
				$Nip = $WindowsComputer.IPAddress
				
				foreach ($Net in $Nets)
				{
					if (!$Nip)
					{
						$Nip += ($Net.IPAddress + "  ")
					}
					$NMAc = $null
					$NMAC += ($Net.MACAddress + "  ")
				}
				
				try
				{
					$DeviceUser = $null
					$PDeviceUser = $null
					$PDeviceUser = (Get-SCSMRelationshipObject -ByTarget $WindowsComputer.object | ? { $_.RelationshipId -eq $UsrUsDevRelClId })
					if ($PDeviceUser.SourceObject)
					{
						if ($PDeviceUser.SourceObject.count -eq 1)
						{
							$DeviceUser = $PDeviceUser.SourceObject
						}
						else
						{
							$DeviceUser = $PDeviceUser.SourceObject[0]
						}
					}
				}
				catch
				{
					$DeviceUser = $null
				}
				
				switch -wildcard ($OSDisplayName)
				{
					"*Server*"{ $OSTypeEnum = $ServerOSId }
					default { $OSTypeEnum = $ClientOSId }
				}
				
				switch ($DataWidth)
				{
					"64"{ $Fam = $Amd64Id }
					default { $Fam = $x86 }
				}
				
				if ($OSTypeEnum -eq $ServerOSId) { $DevType = $SrvAssetTypeEnumId }
				Else { $DevType = $DesktopAssetTypeEnumId }
				
				switch ($WindowsComputer.IsVirtualMachine)
				{
					"True" { $AssHwType = $VMHWAssetEnumId }
					"False"{ $AssHwType = $ComputerHWAssetEnumId }
				}
				
				
				if ($AssHwType -eq $VMHWAssetEnumId) { $DevType = $VMAssetTypeEnumId }
				
				
				
				if ($SerialNumber -ne "Not Present")
				{
					if ($AssHwType -ne $VMHWAssetEnumId)
					{
						$AssetTag = $null
						$AssetTag = "$PreFix" + "$SerialNumber"
					}
					else
					{
						$AssetTag = $null
						$AssetTag = "$PreFix" + "VM:" + "$CompName"
					}
				}
				else { $AssetTag = $null }
				
				[String]$ConnDetails = "$CompName" + "$Nip" + "$NMac" + "$OSDisplayName" + "$Memory" + "$SerialNumber" + "$AssetTag" + $($LastModified.ToString())
				$ObjHash = Get-StringHash -String $ConnDetails
				
				$PropertyHashTable = @{
					"DisplayName" = $CompName;
					"AssetClass" = $AssHwType;
					"DeviceManufacturer" = $CompManufacturer;
					"DeviceModel" = $CompModel;
					"DeviceName" = $CompName;
					"DeviceType" = $DevType;
					"IPAddress" = $Nip;
					"MACAddress" = $NMac;
					"OSFoundation" = $CompOSId;
					"OSName" = $OSDisplayName;
					"OSType" = $OSTypeEnum;
					"OSVersion" = $OSVersion;
					"PhysicalCores" = $PhysicalCores;
					"PhysicalProcessors" = $LogicProc;
					"PhysicalSockets" = $Sockets
					"Memory" = $Memory;
					"ProcessorFamily" = $Fam;
					"SerialNumber" = $SerialNumber;
					"ObjectHash" = $ObjHash;
					"AssetTag" = $AssetTag;
					"LastDiscoveredDate" = (Get-Date);
					"LastModifiedSync" = $LastModified;
					
				}
				
				$NewHW = New-SCSMObject -Class $HardwareClass -PropertyHashtable $PropertyHashTable -PassThru
				#write-verbose "[INFO]`t Creating Hardware for Computer $CompName..."
				
				try
				{
					$disks = $null
					$disks = Get-SCSMRelatedObject -SMObject $WindowsComputer.Object | ?{ ($_.Classname -eq "Microsoft.Windows.Peripheral.PhysicalDisk") -and ($_.ObjectStatus -ne $PendingDeleteEnumId) }
				}
				catch { }
				finally
				{
					foreach ($disk in $disks)
					{
						New-SCSMRelationshipObject -Relationship $ContainDiskRelCl -Source $NewHW -Target $disk -Bulk
					}
				}
				
				try
				{
					$volumes = $null
					$volumes = Get-SCSMRelatedObject -SMObject $WindowsComputer.Object | ?{ ($_.Classname -eq "Microsoft.Windows.Peripheral.LogicalDisk") -and ($_.ObjectStatus -ne $PendingDeleteEnumId) }
				}
				catch { }
				finally
				{
					foreach ($volume in $volumes)
					{
						New-SCSMRelationshipObject -Relationship $ContainVolumeRelCl -Source $NewHW -Target $volume -Bulk
					}
				}
				
				if ($AssHwType -ne $VMHWAssetEnumId)
				{
					
					if ($CompManufacturer)
					{
						$iNewMan = $null
						$iNewMan = Get-SCSMObject -Class $DevManufacturer -Filter "DisplayName -like *$CompManufacturer*"
						if ($iNewMan)
						{
							$iRelMan = New-SCSMRelationshipObject -Source $NewHW -Target $iNewMan -Relationship $HardwareHasManufacturerRelCl -Bulk
							
						}
						else
						{
							
							$iVendorHashTable = @{
								
								"DisplayName" = $CompManufacturer;
								"ManufacturerName" = $CompManufacturer;
								
							}
							
							
							$iNewMan = New-SCSMObject -Class $DevManufacturer -PropertyHashtable $iVendorHashTable -PassThru
							$iRelMan = New-SCSMRelationshipObject -Source $NewHW -Target $iNewMan -Relationship $HardwareHasManufacturerRelCl -Bulk
							
							
							# Find Manufacturer Web Site
							
							if ($iNewMan)
							{
								
								$Key = ($HardwareConnectorAdminSettingObj.Searchkey)
								$env:MS_BingSearch_API_key = "$Key"
								$Uri = 'https://api.cognitive.microsoft.com/bing/v5.0/search?q=' + $CompManufacturer
								$Result = Invoke-RestMethod -Uri $Uri -Method 'GET' -ContentType 'application/json' -Headers @{ 'Ocp-Apim-Subscription-Key' = $env:MS_BingSearch_API_key }
								$Url = $Result.webPages.value[0].displayUrl
								$ManUrl = "http://" + $Url
								
								if ($ManUrl)
								{
									Set-SCSMObject -SMObject $iNewMan -Property "ManufacturerWebSite" -Value $ManUrl
									
								}
							}
						}
					}
					
					if ($CompModel)
					{
						$iModEx = $null
						$iModEx = Get-SCSMObject -Class $DevModel -Filter "DisplayName -eq $CompModel"
						if ($iModEx)
						{
							$iRelModel = New-SCSMRelationshipObject -Source $NewHW -Target $iModEx -Relationship $HardwareHasModelRelCl -Bulk
							#$RelDevMan = New-SCSMRelationshipObject -Source $iModEx -Target $iNewMan -Relationship $ModelHasManufacturerRelCl -Bulk
							
						}
						else
						{
							
							$iModelHashTable = @{
								
								"DisplayName" = $($CompModel);
								"ModelName" = $($CompModel);
								
							}
							
							$iModEx = New-SCSMObject -Class $DevModel -PropertyHashtable $iModelHashTable -PassThru
							
							#Find Web Site For Model
							
							if ($iModEx)
							{
								$Key = ($HardwareConnectorAdminSettingObj.Searchkey)
								$env:MS_BingSearch_API_key = "$Key"
								$Uri = 'https://api.cognitive.microsoft.com/bing/v5.0/search?q=' + $CompModel
								$Result = Invoke-RestMethod -Uri $Uri -Method 'GET' -ContentType 'application/json' -Headers @{ 'Ocp-Apim-Subscription-Key' = $env:MS_BingSearch_API_key }
								$Url = $Result.webPages.value[0].displayUrl
								$ModelUrl = "http://" + $Url
								
								
								if ($ModelUrl)
								{
									Set-SCSMObject -SMObject $iModEx -Property "ModelWebSite" -Value $ModelUrl
								}
							}
						}
						
						#Relationships
						
						$iRelModel = New-SCSMRelationshipObject -Source $NewHW -Target $iModEx -Relationship $HardwareHasModel -Bulk
						$iRelDevMan = New-SCSMRelationshipObject -Source $iModEx -Target $iNewMan -Relationship $ModelHasManufacturerRelCl -Bulk
						$CompCI = Get-SCSMObject -Id $WindowsComputer.Object.Id
						New-SCSMRelationshipObject -Relationship $ConfigItemRelCl -Source $NewHW -Target $CompCI -Bulk
						
						#Numeric Values Model and Manufacturer
						
						[int]$ModelDeployedCount = (Get-SCSMRelationshipObject -ByTarget $iModEx | ? RelationShipId -eq $HardwareHasModel.id).Count
						Set-SCSMObject -SMObject $iModEx -Property "ModelCount" -Value $ModelDeployedCount
						
						
					}
					
				}
				else
				{
					$CompCI = Get-SCSMObject -Id $WindowsComputer.Object.Id
					New-SCSMRelationshipObject -Relationship $ConfigItemRelCl -Source $NewHW -Target $CompCI -Bulk
				}
				
				if ($DeviceUser)
				{
					
					$id = $DeviceUser.id
					$DevUsrExists = Get-SCSMObject -Class (Get-SCSMClass -Name Microsoft.AD.User$) -Filter "id -eq $id" -ErrorAction SilentlyContinue
				}
				
				if ($DevUsrExists)
				{
					#write-verbose "[INFO]`t Assigning Relationship for Hardware $CompName with User $DevUsrExists..."
					Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $InfoID -Category 0 -EntryType Information -Message "Hardware Connector Assigning Relationship for Computer with Computer Name : $CompName and User: $DevUsrExists"
					New-SCSMRelationshipObject -Relationship $HardwareHasUserRelCl -Source $NewHW -Target $DevUsrExists -Bulk -ErrorAction SilentlyContinue
					
				}
				
				$AssExists = Get-SCSMObject -Class $HardwareAssetClass -Filter "AssetName -eq $CompName"
				if (!$AssExists)
				{
					#Check if is Active
					$IsActive = $null
					$RStatus = $null
					$IsActive = $InactiveComputers -contains $($CompCI.DisplayName)
					if ($IsActive -ne $true)
					{ $RStatus = $ReadinessStatusEnumId }
					else { $RStatus = $ReadinessStatusNotUsedEnumId }
					
					$AssetTable = @{
						"AssetName" = $CompName;
						"DisplayName" = $CompName;
						"Type" = $DevType;
						"ReadinessStatus" = $RStatus;
						"AssetTag" = $AssetTag;
						"SerialNumber" = $SerialNumber;
					}
					
					$Asset = New-SCSMObject -Class $HardwareAssetClass -PropertyHashtable $AssetTable -PassThru
					#write-verbose "[INFO]`t Creating Hardware Asset for Hardware $CompName ..."
					Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $InfoID -Category 0 -EntryType Information -Message "Hardware Connector Succesfully Create Hardware Asset for Computer Object: $CompName"
					New-SCSMRelationshipObject -Relationship $HardwareAssetRefHardwareRelCl -Source $Asset -Target $NewHW -Bulk
					if ($DevUsrExists)
					{
						#write-verbose "[INFO]`t Assigning Realtionship for Hardware Asset $CompName  ans User $DevUsrExists..."
						Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $InfoID -Category 0 -EntryType Information -Message "Hardware Connector Assigning Relationship for Hardware Asset with Computer Name : $CompName and User: $DevUsrExists"
						New-SCSMRelationshipObject -Relationship $HardwareAssetHasUser -Source $Asset -Target $DevUsrExists -Bulk -ErrorAction SilentlyContinue
					}
					
				}
			}
			else
			{
				$ActualHw = Get-SCSMObject -Class $HardwareClass -Filter "DeviceName -eq $($WindowsComputer.PrincipalName)"
				[datetime]$LastModified = $WindowsComputer.Object.LastModified
				$ObjLast = Get-Date -Date $($ActualHW.LastModifiedSync) -Format "yyyy-MM-dd hh:mm"
				$WinCLast = Get-Date -Date $($WindowsComputer.LastModified) -Format "yyyy-MM-dd hh:mm"
				if ($ObjLast -ne $WinCLast)
				{
					$ObjHistory = $null
					$emg = $null
					
					$emg = New-Object Microsoft.EnterpriseManagement.EnterpriseManagementGroup "localhost"
					$ObjHistory = $emg.EntityObjects.GetObjectHistoryTransactions($WindowsComputer.Object) | ? { $_.DateOccurred -gt $($HWExists.LastModifiedSync) }
					foreach ($ObjHist in $ObjHistory)
					{
						try
						{
							$PropertyChanges = $null
							$RelationshipChanges = $null
							
							$PropertyChanges = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges
							$RelationshipChanges = $ObjHist.ObjectHistory.Values.ClassHistory.RelationshipChanges
						}
						Catch
						{
							$PropertyChanges = $null
							$RelationshipChanges = $null
						}
						Finally
						{
							if ($PropertyChanges)
							{
								if ($PropertyChanges.Count -gt 1)
								{
									foreach ($PropertyChange in $PropertyChanges.Values.Second)
									{
										$Propery = $null
										$Value = $null
										$ChangeType = $null
										
										$Propery = $PropertyChange.Type.Name
										$Value = $PropertyChange.Value
										$ChangeType = $ObjHist.ObjectHistory.Values.ClassHistory.ChangeType
										
										if ($ChangeType -eq "Insert")
										{
											try
											{
												Set-SCSMObject -SMObject $ActualHw -Property $Propery -Value $Value
											}
											catch
											{
												Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $ActualHw For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
											}
										}
										elseIf ($ChangeType -eq "Modify")
										{
											try
											{
												Set-SCSMObject -SMObject $ActualHw -Property $Propery -Value $Value
											}
											catch
											{
												Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $ActualHw For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
											}
										}
										elseif ($ChangeType -eq "Delete")
										{
											try
											{
												Set-SCSMObject -SMObject $ActualHw -Property $Propery -Value " "
											}
											catch
											{
												Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $ActualHw For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
											}
										}
									}
								}
								else
								{
									$Propery = $null
									$Value = $null
									$ChangeType = $null
									
									$Propery = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges.Key
									$Value = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges.Value
									$ChangeType = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges.ChangeType
									
									if ($ChangeType -eq "Insert")
									{
										try
										{
											Set-SCSMObject -SMObject $ActualHw -Property $Propery -Value $Value
										}
										catch
										{
											Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $ActualHw For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
										}
									}
									elseIf ($ChangeType -eq "Modify")
									{
										try
										{
											Set-SCSMObject -SMObject $ActualHw -Property $Propery -Value $Value
										}
										catch
										{
											Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $ActualHw For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
										}
									}
									elseif ($ChangeType -eq "Delete")
									{
										try
										{
											Set-SCSMObject -SMObject $ActualHw -Property $Propery -Value ""
										}
										catch
										{
											Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $ActualHw For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
										}
									}
									
								}
								
								
							}
							elseif (($RelationshipChanges.ManagementPackRelationshipTypeId -ne $DevHasSoftInstalledRelClId) -or ($RelationshipChanges.ManagementPackRelationshipTypeId -ne $DevHasUpdInstalledRelClId))
							{
								$SourceObj = $null
								$TargetObj = $null
								$RelationshipClassObj = $null
								$RChangeType = $null
								
								$SourceObj = $ObjHist.ObjectHistory.Values.RelationshipHistory.SourceObjectId
								$TargetObj = $ObjHist.ObjectHistory.Values.RelationshipHistory.TargetObjectId
								$RelationshipClassObj = $ObjHist.ObjectHistory.Values.RelationshipHistory.ManagementPackRelationshipTypeId
								$RChangeType = $ObjHist.ObjectHistory.Values.RelationshipHistory.ChangeType
								
								$Src = $null
								$Tar = $null
								$Rel = $null
								
								$Src = Get-SCSMObject -Id $SourceObj
								$Tar = Get-SCSMObject -Id $TargetObj
								$Rel = Get-SCSMRelationshipClass -id = $RelationshipClassObj
								
								if ($RChangeType -eq "Insert")
								{
									try
									{
										New-SCSMRelationshipObject -Source $Src -Target $Tar -Relationship $Rel -Bulk
									}
									catch
									{
										Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object Relationships:$ActualHw For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
									}
								}
								elseIf ($RChangeType -eq "Modify")
								{
									try
									{
										New-SCSMRelationshipObject -Source $Src -Target $Tar -Relationship $Rel -Bulk
									}
									catch
									{
										Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object Relationships:$ActualHw For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
									}
								}
								elseif ($RChangeType -eq "Delete")
								{
									try
									{
										Get-SCSMRelationshipObject -BySource $Src | ? { ($_.RelationshipClassId -eq $Rel) } | Remove-SCSMRelationshipObject
									}
									catch
									{
										
										Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object Relationships:$ActualHw For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
										
									}
								}
								
							}
							
						}
					}
					Set-SCSMObject -SMObject $ActualHw -Property "LastModifiedSync" -Value $LastModified
				}
			}
			
		}
		
	}
	Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Hardware Connector Finished Process of Computer Objects"
	
	#Process Network Devices
	Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Hardware Connector Start Processing of Network Objects"
	$NetworkDevices = Get-SCSMObject -Class $NetworkClass -Filter "ObjectStatus -ne $PendingDeleteEnumId"
	if ($NetworkDevices)
	{
		foreach ($NetDevice in $NetworkDevices)
		{
			[datetime]$LastModified = $NetDevice.LastModified
			$NetDevExists = Get-SCSMObject -Class $NetworkDeviceClass -Filter "SNMPAddress -eq '$($NetDevice.SNMPAddress)' and ObjectStatus -ne '$PendingDeleteEnumId'"
			if (!$NetDevExists)
			{
				[datetime]$LastModified = $NetDevice.LastModified
				[string]$NetDevHash = $($NetDevice.SNMPAddress) + $($NetDevice.sysName) + $($NetDevice.Model) + $($NetDevice.Vendor) + $($LastModified.ToString())
				$ObjectHash = Get-StringHash -String $NetDevHash
				
				$NetHashTable = @{
					
					"DisplayName" = $($NetDevice.SNMPAddress);
					"DeviceName" = $($NetDevice.sysName);
					"Ports" = $($NetDevice.PortNumber);
					"SNMPAddress" = $($NetDevice.SNMPAddress);
					"SupportsSNMP" = $($NetDevice.SupportsSNMP);
					"ObjectHash" = $ObjectHash
					"LastDiscoveredDate" = (Get-Date);
					"Location" = $($NetDevice.Location);
					"SNMPVersion" = $($NetDevice.SNMPVersion);
					"Description" = $($NetDevice.Description);
					"Status" = $ActiveDeviceStatusEnumId;
					"LastModifiedSync" = $LastModified;
					
					
				}
				try
				{
					$NewNetDevice = New-SCSMObject -Class $NetworkDeviceClass -PropertyHashtable $NetHashTable -PassThru
					New-SCSMRelationshipObject -Relationship $ConfigItemRelCl -Source $NewNetDevice -Target $NetDevice -Bulk
					
					if ($NetDevice.PrimaryOwnerName)
					{
						$Owner = Get-SCSMObject -Class $UserClass -Filter "DisplayName -like $($NetDevice.PrimaryOwnerName)"
						if ($Owner)
						{
							$MustRelateOwner = New-SCSMRelationshipObject -Source $NewNetDevice -Target $Owner -Relationship $NetDevUserRelationShip -Bulk
						}
					}
					
					if ($NetDevice.Vendor)
					{
						$NewMan = $null
						$NewMan = Get-SCSMObject -Class $DevManufacturer -Filter "DisplayName -eq $($NetDevice.Vendor)"
						if ($NewMan)
						{
							$RelMan = New-SCSMRelationshipObject -Source $NewNetDevice -Target $NewMan -Relationship $NetDevModelRel -Bulk
							
						}
						else
						{
							
							$VendorHashTable = @{
								
								"DisplayName" = $($NetDevice.Vendor);
								"ManufacturerName" = $($NetDevice.Vendor);
								
							}
							
							$NewMan = New-SCSMObject -Class $DevManufacturer -PropertyHashtable $VendorHashTable -PassThru
							$RelMan = New-SCSMRelationshipObject -Source $NewNetDevice -Target $NewMan -Relationship $NetDevManufactRel -Bulk
							
							
						}
						
						if ($NewMan)
						{
							
							$Key = ($HardwareConnectorAdminSettingObj.Searchkey)
							$env:MS_BingSearch_API_key = "$Key"
							$Uri = 'https://api.cognitive.microsoft.com/bing/v5.0/search?q=' + $($NetDevice.Vendor)
							$Result = Invoke-RestMethod -Uri $Uri -Method 'GET' -ContentType 'application/json' -Headers @{ 'Ocp-Apim-Subscription-Key' = $env:MS_BingSearch_API_key }
							$Url = $Result.webPages.value[0].displayUrl
							$ManUrl = "http://" + $Url
							
							if ($ManUrl)
							{
								Set-SCSMObject -SMObject $NewMan -Property "ManufacturerWebSite" -Value $ManUrl
								
							}
						}
						
					}
					
					
					if ($NetDevice.Model)
					{
						$ModEx = $null
						$ModEx = Get-SCSMObject -Class $DevModel -Filter "DisplayName -eq $($NetDevice.Model)"
						if ($ModEx)
						{
							$RelModel = New-SCSMRelationshipObject -Source $NewNetDevice -Target $ModEx -Relationship $NetDevModelRel -Bulk
							$RelDevMan = New-SCSMRelationshipObject -Source $RelModel -Target $NewMan -Relationship $ModelHasManufacturerRelCl -Bulk
							
						}
						else
						{
							
							$ModelHashTable = @{
								
								"DisplayName" = $($NetDevice.Model);
								"ModelName" = $($NetDevice.Model);
								
							}
							
							$ModEx = New-SCSMObject -Class $DevModel -PropertyHashtable $ModelHashTable -PassThru
						}
						if ($NetDevice.Model)
						{
							
							$Key = ($HardwareConnectorAdminSettingObj.Searchkey)
							$env:MS_BingSearch_API_key = "$Key"
							$Uri = 'https://api.cognitive.microsoft.com/bing/v5.0/search?q=' + $($NetDevice.Model)
							$Result = Invoke-RestMethod -Uri $Uri -Method 'GET' -ContentType 'application/json' -Headers @{ 'Ocp-Apim-Subscription-Key' = $env:MS_BingSearch_API_key }
							$Url = $Result.webPages.value[0].displayUrl
							$ModelUrl = "http://" + $Url
							
							
							if ($ModelUrl)
							{
								Set-SCSMObject -SMObject $ModEx -Property "ModelWebSite" -Value $ModelUrl
							}
						}
						$RelModel = New-SCSMRelationshipObject -Source $NewNetDevice -Target $ModEx -Relationship $NetDevModelRel -Bulk
						$RelDevMan = New-SCSMRelationshipObject -Source $ModEx -Target $NewMan -Relationship $ModelHasManufacturerRelCl -Bulk
						
					}
					
					$DevAssetEx = Get-SCSMObject -Class $HardwareAssetClass -Filter "DisplayName -eq $($NewNetDevice.DisplayName)"
					if (!$DevAssetEx)
					{
						$AssetHashTable = @{
							"AssetName" = $($NewNetDevice.DisplayName);
							"DisplayName" = $($NewNetDevice.DisplayName);
							"Type" = $NetHardwareAssetTypeId;
							"ReadinessStatus" = $ReadinessStatusEnumId;
							"AssetTag" = $AssetTag;
						}
						$DevAsset = New-SCSMObject -Class $HardwareAssetClass -PropertyHashtable $AssetHashTable -PassThru
						New-SCSMRelationshipObject -Relationship $HAssetRefNetRelCl -Source $DevAsset -Target $NewNetDevice -Bulk
					}
				}
				catch
				{
				}
				
				
				
			}
			else
			{
				$NObjLast = Get-Date -Date $($NetDevExists.LastModifiedSync) -Format "yyyy-MM-dd hh:mm"
				$NetDvLast = Get-Date -Date $($NetDevice.LastModified) -Format "yyyy-MM-dd hh:mm"
				if ($NObjLast -ne $NetDvLast)
				{
					$ObjHistory = $null
					$emg = $null
					$emg = New-Object Microsoft.EnterpriseManagement.EnterpriseManagementGroup "localhost"
					$ObjHistory = $emg.EntityObjects.GetObjectHistoryTransactions($NetDevice) | ? { $_.DateOccurred -gt $($NetDevExists.LastModifiedSync) }
					foreach ($ObjHist in $ObjHistory)
					{
						try
						{
							$PropertyChanges = $null
							$RelationshipChanges = $null
							
							$PropertyChanges = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges
							$RelationshipChanges = $ObjHist.ObjectHistory.Values.ClassHistory.RelationshipChanges
						}
						Catch
						{
							$PropertyChanges = $null
							$RelationshipChanges = $null
						}
						Finally
						{
							if ($PropertyChanges)
							{
								if ($PropertyChanges.Count -gt 1)
								{
									foreach ($PropertyChange in $PropertyChanges.Values.Second)
									{
										$Propery = $null
										$Value = $null
										$ChangeType = $null
										
										$Propery = $PropertyChange.Type.Name
										$Value = $PropertyChange.Value
										$ChangeType = $ObjHist.ObjectHistory.Values.ClassHistory.ChangeType
										
										if ($ChangeType -eq "Insert")
										{
											try
											{
												Set-SCSMObject -SMObject $NetDevExists -Property $Propery -Value $Value
											}
											catch
											{
												Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $NetDevExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
											}
										}
										elseIf ($ChangeType -eq "Modify")
										{
											try
											{
												Set-SCSMObject -SMObject $NetDevExists -Property $Propery -Value $Value
											}
											catch
											{
												Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $NetDevExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
											}
										}
										elseif ($ChangeType -eq "Delete")
										{
											try
											{
												Set-SCSMObject -SMObject $NetDevExists -Property $Propery -Value " "
											}
											catch
											{
												Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $NetDevExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
											}
										}
									}
								}
								else
								{
									$Propery = $null
									$Value = $null
									$ChangeType = $null
									
									$Propery = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges.Key
									$Value = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges.Value
									$ChangeType = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges.ChangeType
									
									if ($ChangeType -eq "Insert")
									{
										try
										{
											Set-SCSMObject -SMObject $NetDevExists -Property $Propery -Value $Value
										}
										catch
										{
											Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $NetDevExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
										}
									}
									elseIf ($ChangeType -eq "Modify")
									{
										try
										{
											Set-SCSMObject -SMObject $NetDevExists -Property $Propery -Value $Value
										}
										catch
										{
											Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $NetDevExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
										}
									}
									elseif ($ChangeType -eq "Delete")
									{
										try
										{
											Set-SCSMObject -SMObject $NetDevExists -Property $Propery -Value ""
										}
										catch
										{
											Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $NetDevExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
										}
									}
								}
							}
							elseif ($RelationshipChanges)
							{
								$SourceObj = $null
								$TargetObj = $null
								$RelationshipClassObj = $null
								$RChangeType = $null
								
								$SourceObj = $ObjHist.ObjectHistory.Values.RelationshipHistory.SourceObjectId
								$TargetObj = $ObjHist.ObjectHistory.Values.RelationshipHistory.TargetObjectId
								$RelationshipClassObj = $ObjHist.ObjectHistory.Values.RelationshipHistory.ManagementPackRelationshipTypeId
								$RChangeType = $ObjHist.ObjectHistory.Values.RelationshipHistory.ChangeType
								
								$Src = $null
								$Tar = $null
								$Rel = $null
								
								$Src = Get-SCSMObject -Id $SourceObj
								$Tar = Get-SCSMObject -Id $TargetObj
								$Rel = Get-SCSMRelationshipClass -id = $RelationshipClassObj
								
								if ($RChangeType -eq "Insert")
								{
									try
									{
										New-SCSMRelationshipObject -Source $Src -Target $Tar -Relationship $Rel -Bulk
									}
									catch
									{
										Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object Relationships:$NetDevExists For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
									}
								}
								elseIf ($RChangeType -eq "Modify")
								{
									try
									{
										New-SCSMRelationshipObject -Source $Src -Target $Tar -Relationship $Rel -Bulk
									}
									catch
									{
										Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object Relationships:$NetDevExists For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
									}
								}
								elseif ($RChangeType -eq "Delete")
								{
									try
									{
										Get-SCSMRelationshipObject -BySource $Src | ? { ($_.RelationshipClassId -eq $Rel) } | Remove-SCSMRelationshipObject
									}
									catch
									{
										Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object Relationships:$NetDevExists For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
									}
								}
								
								
							}
							
						}
					}
					Set-SCSMObject -SMObject $NetDevExists -Property "LastModifiedSync" -Value $LastModified
				}
			}
			
		}
	}
	Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Hardware Connector Finished Process of Network Objects"
	
	#Process Printers
	Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Hardware Connector Start Processing of Printer Objects"
	$Printers = Get-SCSMObject -Class $SystemPrinterClass -Filter "ObjectStatus -ne $PendingDeleteEnumId"
	if ($Printers)
	{
		foreach ($Printer in $Printers)
		{
			$PrinterExists = Get-SCSMObject -Class $PrinterClass -Filter "DevId -eq $($Printer.Id)"
			if (!$PrinterExists)
			{
				[datetime]$LastModified = $Printer.LastModified
				[string]$PObjHash = $($Printer.DisplayName) + $($Printer.PrintNetworkAddress) + $($LastModified.ToString())
				$ObjHashPrinter = Get-StringHash -String $PObjHash
				
				$PrinterHashTable = @{
					"DisplayName" = $($Printer.DisplayName);
					"PrinterName" = $($Printer.DisplayName);
					"IPAddress" = $($Printer.PrintNetworkAddress);
					"SpeedPPS" = $($Printer.PrintPagesPerMinute);
					"LastDiscoveredDate" = (Get-Date);
					"ObjectHash" = $ObjHashPrinter;
					"Status" = $ActiveDeviceStatusEnumId;
					"LastModifiedSync" = $LastModified;
					"DevId" = $($Printer.Id);
				}
				
				$NewPrinter = New-SCSMObject -Class $PrinterClass -PropertyHashtable $PrinterHashTable -PassThru
				New-SCSMRelationshipObject -Relationship $ConfigItemRelCl -Source $NewPrinter -Target $Printer -Bulk
				
				
				If ($Printer.ManagedBy)
				{
					$Owner = Get-SCSMObject -Class $UserClass -Filter "DisplayName -eq $($Printer.ManagedBy)"
					if ($Owner)
					{
						$MustRelateOwner = New-SCSMRelationshipObject -Source $NewPrinter -Target $Owner -Relationship $PrinterHasUserClass -Bulk
					}
					
				}
				
				$PDevAssetEx = Get-SCSMObject -Class $HardwareAssetClass -Filter "DisplayName -eq $($NewPrinter.DisplayName)"
				if (!$PDevAssetEx)
				{
					$PAssetHashTable = @{
						"AssetName" = $($NewPrinter.DisplayName);
						"DisplayName" = $($NewPrinter.DisplayName);
						"Type" = $PrinterAssetEnumId;
						"ReadinessStatus" = $ReadinessStatusEnumId;
						"AssetTag" = $AssetTag;
					}
					$PDevAsset = New-SCSMObject -Class $HardwareAssetClass -PropertyHashtable $PAssetHashTable -PassThru
					New-SCSMRelationshipObject -Relationship $HAssetRefPrinterRelCl -Source $PDevAsset -Target $NewPrinter -Bulk
				}
				
			}
			else
			{
				$PObjLast = Get-Date -Date $($PrinterExists.LastModifiedSync) -Format "yyyy-MM-dd hh:mm"
				$PrtDvLast = Get-Date -Date $($Printer.LastModified) -Format "yyyy-MM-dd hh:mm"
				[DateTime]$LastModified = $Printer.LastModified
				if ($PObjLast -ne $PrtDvLast)
				{
					$ObjHistory = $null
					$emg = $null
					$emg = New-Object Microsoft.EnterpriseManagement.EnterpriseManagementGroup "localhost"
					$ObjHistory = $emg.EntityObjects.GetObjectHistoryTransactions($Printer) | ? { $_.DateOccurred -gt $($PrinterExists.LastModifiedSync) }
					foreach ($ObjHist in $ObjHistory)
					{
						try
						{
							$PropertyChanges = $null
							$RelationshipChanges = $null
							
							$PropertyChanges = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges
							$RelationshipChanges = $ObjHist.ObjectHistory.Values.ClassHistory.RelationshipChanges
						}
						Catch
						{
							$PropertyChanges = $null
							$RelationshipChanges = $null
						}
						Finally
						{
							if ($PropertyChanges)
							{
								if ($PropertyChanges.Count -gt 1)
								{
									foreach ($PropertyChange in $PropertyChanges.Values.Second)
									{
										$Propery = $null
										$Value = $null
										$ChangeType = $null
										
										$Propery = $PropertyChange.Type.Name
										$Value = $PropertyChange.Value
										$ChangeType = $ObjHist.ObjectHistory.Values.ClassHistory.ChangeType
										
										if ($ChangeType -eq "Insert")
										{
											try
											{
												Set-SCSMObject -SMObject $PrinterExists -Property $Propery -Value $Value
											}
											catch
											{
												Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $PrinterExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
											}
										}
										elseIf ($ChangeType -eq "Modify")
										{
											try
											{
												Set-SCSMObject -SMObject $PrinterExists -Property $Propery -Value $Value
											}
											catch
											{
												Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $PrinterExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
											}
										}
										elseif ($ChangeType -eq "Delete")
										{
											try
											{
												Set-SCSMObject -SMObject $PrinterExists -Property $Propery -Value " "
											}
											catch
											{
												Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $PrinterExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
											}
										}
									}
								}
								else
								{
									$Propery = $null
									$Value = $null
									$ChangeType = $null
									
									$Propery = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges.Key
									$Value = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges.Value
									$ChangeType = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges.ChangeType
									
									if ($ChangeType -eq "Insert")
									{
										try
										{
											Set-SCSMObject -SMObject $PrinterExists -Property $Propery -Value $Value
										}
										catch
										{
											Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $PrinterExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
										}
									}
									elseIf ($ChangeType -eq "Modify")
									{
										try
										{
											Set-SCSMObject -SMObject $PrinterExists -Property $Propery -Value $Value
										}
										catch
										{
											Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $PrinterExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
										}
									}
									elseif ($ChangeType -eq "Delete")
									{
										try
										{
											Set-SCSMObject -SMObject $PrinterExists -Property $Propery -Value ""
										}
										catch
										{
											Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $PrinterExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
										}
									}
									
								}
							}
							elseif ($RelationshipChanges)
							{
								$SourceObj = $null
								$TargetObj = $null
								$RelationshipClassObj = $null
								$RChangeType = $null
								
								$SourceObj = $ObjHist.ObjectHistory.Values.RelationshipHistory.SourceObjectId
								$TargetObj = $ObjHist.ObjectHistory.Values.RelationshipHistory.TargetObjectId
								$RelationshipClassObj = $ObjHist.ObjectHistory.Values.RelationshipHistory.ManagementPackRelationshipTypeId
								$RChangeType = $ObjHist.ObjectHistory.Values.RelationshipHistory.ChangeType
								
								$Src = $null
								$Tar = $null
								$Rel = $null
								
								$Src = Get-SCSMObject -Id $SourceObj
								$Tar = Get-SCSMObject -Id $TargetObj
								$Rel = Get-SCSMRelationshipClass -id = $RelationshipClassObj
								
								if ($RChangeType -eq "Insert")
								{
									try
									{
										New-SCSMRelationshipObject -Source $Src -Target $Tar -Relationship $Rel -Bulk
									}
									catch
									{
										Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object Relationships:$PrinterExists For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
									}
								}
								elseIf ($RChangeType -eq "Modify")
								{
									try
									{
										New-SCSMRelationshipObject -Source $Src -Target $Tar -Relationship $Rel -Bulk
									}
									catch
									{
										Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object Relationships:$PrinterExists For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
									}
								}
								elseif ($RChangeType -eq "Delete")
								{
									try
									{
										Get-SCSMRelationshipObject -BySource $Src | ? { ($_.RelationshipClassId -eq $Rel) } | Remove-SCSMRelationshipObject
									}
									catch
									{
										Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object Relationships:$PrinterExists For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
									}
								}
								
								
							}
							
						}
					}
					Set-SCSMObject -SMObject $PrinterExists -Property "LastModifiedSync" -Value $LastModified
				}
			}
		}
		
		
	}
	Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Hardware Connector Finished Process of Printer Objects"
	
	#Process Mobile Devices
	Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Hardware Connector Start Processing of Mobile Objects"
	$MobileDevices = Get-SCSMObject -Class $SystemMobileClass -Filter "ObjectStatus -ne $PendingDeleteEnumId"
	if ($MobileDevices)
	{
		foreach ($MobileDevice in $MobileDevices)
		{
			$MobileDeviceExists = Get-SCSMObject -Class $MobileDeviceClass -Filter "DevId -eq $($MobileDevice.Id)"
			[datetime]$LastModified = $MobileDevice.LastModified
			[string]$MObjHash = $($MobileDevice.DeviceImei) + $($MobileDevice.DevicePhoneNumber) + $($MobileDevice.FirmwareVersion) + $($MobileDevice.DeviceMobileOperator) + $($MobileDevice.DeviceOS) + $($LastModified.ToString())
			$ObjHashMobile = Get-StringHash -String $MPObjHash
			if (!$MobileDeviceExists)
			{
				switch -wildcard ($MobileDevice.DeviceOS)
				{
					"*Windows*" { $DiplayNameP = "Windows Device" }
					"*Android*" { $DiplayNameP = "Android Device" }
					"*IOS*" { $DiplayNameP = "IOS Device" }
					default { $DiplayNameP = "Other Mobile Device" }
					
				}
				switch -wildcard ($MobileDevice.DeviceOS)
				{
					"*Windows*" { $MobileType = $WindowsMobileEnumId }
					"*Android*" { $MobileType = $AndroidMobileEnumId }
					"*IOS*" { $MobileType = $IoSMobileEnumId }
					default { $MobileType = $OtherMobileEnumId }
					
				}
				
				$MobileHashTable = @{
					"DisplayName" = $DiplayNameP;
					"DeviceName" = $DiplayNameP;
					"DeviceImei" = $($MobileDevice.DeviceImei);
					"DeviceOS" = $($MobileDevice.DeviceOS);
					"OSType" = $MobileType;
					"ProcessorType" = $($MobileDevice.ProcessorType);
					"FirmwareVersion" = $($MobileDevice.FirmwareVersion);
					"HardwareVersion" = $($MobileDevice.HardwareVersion);
					"OEM" = $($MobileDevice.OEM);
					"HorizontalResolution" = $($MobileDevice.HorizontalResolution);
					"VerticalResolution" = $($MobileDevice.VerticalResolution);
					"DeviceHash" = $ObjHashMobile;
					"LastDiscoveredDate" = (Get-Date);
					"Status" = $ActiveDeviceStatusEnumId;
					"DevicePhoneNumber" = $($MobileDevice.DevicePhoneNumber);
					"DeviceMobileOperator" = $($MobileDevice.DeviceMobileOperator);
					"ExchangeServer" = $($MobileDevice.ExchangeServer);
					"LastModifiedSync" = $LastModified;
					"DevId" = $($MobileDevice.Id);
					
				}
				$NewMobileDevice = New-SCSMObject -Class $MobileDeviceClass -PropertyHashtable $MobileHashTable -PassThru
				New-SCSMRelationshipObject -Relationship $ConfigItemRelCl -Source $NewMobileDevice -Target $MobileDevice -Bulk
				
				if ($MobileDevice.DeviceManufacturer)
				{
					$DNewMan = $null
					$DNewMan = Get-SCSMObject -Class $DevManufacturer -Filter "DisplayName -eq $($MobileDevice.DeviceManufacturer)"
					if ($DNewMan)
					{
						$DRelMan = New-SCSMRelationshipObject -Source $NewMobileDevice -Target $DNewMan -Relationship $MobDevHasManufacturer -Bulk
						
					}
					else
					{
						
						$MobDevHashTable = @{
							
							"DisplayName" = $($MobileDevice.DeviceManufacturer);
							"ManufacturerName" = $($MobileDevice.DeviceManufacturer);
							
						}
						
						$DNewMan = New-SCSMObject -Class $DevManufacturer -PropertyHashtable $MobDevHashTable -PassThru
						$DRelMan = New-SCSMRelationshipObject -Source $NewMobileDevice -Target $DNewMan -Relationship $MobDevHasManufacturer -Bulk
						
						
						
						
					}
				}
				if ($MobileDevice.DeviceModel)
				{
					$DModEx = $null
					$DModEx = Get-SCSMObject -Class $DevModel -Filter "DisplayName -eq $($MobileDevice.DeviceModel)"
					if ($DModEx)
					{
						$DRelModel = New-SCSMRelationshipObject -Source $NewMobileDevice -Target $DModEx -Relationship $MobDevHasModel -Bulk
						if ($DNewMan)
						{
							$DRelDevMan = New-SCSMRelationshipObject -Source $DModEx -Target $DNewMan -Relationship $ModelHasManufacturerRelCl -Bulk
						}
					}
					else
					{
						
						$MobileModelHashTable = @{
							
							"DisplayName" = $($MobileDevice.DeviceModel);
							"ModelName" = $($MobileDevice.DeviceModel);
							
						}
						
						$DModEx = New-SCSMObject -Class $DevModel -PropertyHashtable $MobileModelHashTable -PassThru
						if ($MobileDevice.DeviceModel)
						{
							$Key = ($HardwareConnectorAdminSettingObj.Searchkey)
							$env:MS_BingSearch_API_key = "$Key"
							$Uri = 'https://api.cognitive.microsoft.com/bing/v5.0/search?q=' + $($MobileDevice.DeviceModel)
							$Result = Invoke-RestMethod -Uri $Uri -Method 'GET' -ContentType 'application/json' -Headers @{ 'Ocp-Apim-Subscription-Key' = $env:MS_BingSearch_API_key }
							$Url = $Result.webPages.value[0].displayUrl
							$ModelUrl = "http://" + $Url
							
							
							if ($ModelUrl)
							{
								Set-SCSMObject -SMObject $DModEx -Property "ModelWebSite" -Value $ModelUrl
							}
						}
						$RelModel = New-SCSMRelationshipObject -Source $NewNetDevice -Target $ModEx -Relationship $NetDevModelRel -Bulk
						$RelDevMan = New-SCSMRelationshipObject -Source $ModEx -Target $NewMan -Relationship $ModelHasManufacturerRelCl -Bulk
						
					}
					$DRelModel = New-SCSMRelationshipObject -Source $NewMobileDevice -Target $DModEx -Relationship $MobDevHasModel -Bulk
					if ($DNewMan)
					{
						$DRelDevMan = New-SCSMRelationshipObject -Source $DModEx -Target $DNewMan -Relationship $ModelHasManufacturerRelCl -Bulk
					}
					
				}
				
				
				$MDevAssetEx = Get-SCSMObject -Class $HardwareAssetClass -Filter "DisplayName -eq $DiplayNameP"
				if (!$MDevAssetEx)
				{
					$MAssetHashTable = @{
						"AssetName" = $DiplayNameP;
						"DisplayName" = $DiplayNameP;
						"Type" = $AssetMobileEnumId;
						"ReadinessStatus" = $ReadinessStatusEnumId;
						
					}
					$MDevAsset = New-SCSMObject -Class $HardwareAssetClass -PropertyHashtable $MAssetHashTable -PassThru
					New-SCSMRelationshipObject -Relationship $HAssetRefMobRelCl -Source $MDevAsset -Target $NewMobileDevice -Bulk
				}
			}
			else
			{
				[DateTime]$LastModified = $MobileDevice.LastModified
				$MObjLast = Get-Date -Date $($MobileDeviceExists.LastModifiedSync) -Format "yyyy-MM-dd hh:mm"
				$MobDvLast = Get-Date -Date $($MobileDevice.LastModified) -Format "yyyy-MM-dd hh:mm"
				if ($MObjLast -ne $MobDvLast)
				{
					$ObjHistory = $null
					$emg = $null
					$emg = New-Object Microsoft.EnterpriseManagement.EnterpriseManagementGroup "localhost"
					$ObjHistory = $emg.EntityObjects.GetObjectHistoryTransactions($MobileDevice) | ? { $_.DateOccurred -gt $($MobileDeviceExists.LastModifiedSync) }
					foreach ($ObjHist in $ObjHistory)
					{
						try
						{
							$PropertyChanges = $null
							$RelationshipChanges = $null
							
							$PropertyChanges = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges
							$RelationshipChanges = $ObjHist.ObjectHistory.Values.ClassHistory.RelationshipChanges
						}
						Catch
						{
							$PropertyChanges = $null
							$RelationshipChanges = $null
						}
						Finally
						{
							if ($PropertyChanges)
							{
								if ($PropertyChanges.Count -gt 1)
								{
									foreach ($PropertyChange in $PropertyChanges.Values.Second)
									{
										$Propery = $null
										$Value = $null
										$ChangeType = $null
										
										$Propery = $PropertyChange.Type.Name
										$Value = $PropertyChange.Value
										$ChangeType = $ObjHist.ObjectHistory.Values.ClassHistory.ChangeType
										
										if ($ChangeType -eq "Insert")
										{
											try
											{
												Set-SCSMObject -SMObject $MobileDeviceExists -Property $Propery -Value $Value
											}
											catch
											{
												Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $MobileDeviceExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
											}
										}
										elseIf ($ChangeType -eq "Modify")
										{
											try
											{
												Set-SCSMObject -SMObject $MobileDeviceExists -Property $Propery -Value $Value
											}
											catch
											{
												Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $MobileDeviceExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
											}
										}
										elseif ($ChangeType -eq "Delete")
										{
											try
											{
												Set-SCSMObject -SMObject $MobileDeviceExists -Property $Propery -Value " "
											}
											catch
											{
												Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $MobileDeviceExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
											}
										}
									}
								}
								else
								{
									$Propery = $null
									$Value = $null
									$ChangeType = $null
									
									$Propery = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges.Key
									$Value = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges.Value
									$ChangeType = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges.ChangeType
									
									if ($ChangeType -eq "Insert")
									{
										try
										{
											Set-SCSMObject -SMObject $MobileDeviceExists -Property $Propery -Value $Value
										}
										catch
										{
											Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $MobileDeviceExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
										}
									}
									elseIf ($ChangeType -eq "Modify")
									{
										try
										{
											Set-SCSMObject -SMObject $MobileDeviceExists -Property $Propery -Value $Value
										}
										catch
										{
											Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $MobileDeviceExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
										}
									}
									elseif ($ChangeType -eq "Delete")
									{
										try
										{
											Set-SCSMObject -SMObject $MobileDeviceExists -Property $Propery -Value ""
										}
										catch
										{
											Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $MobileDeviceExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
										}
									}
									
								}
							}
							elseif ($RelationshipChanges)
							{
								$SourceObj = $null
								$TargetObj = $null
								$RelationshipClassObj = $null
								$RChangeType = $null
								
								$SourceObj = $ObjHist.ObjectHistory.Values.RelationshipHistory.SourceObjectId
								$TargetObj = $ObjHist.ObjectHistory.Values.RelationshipHistory.TargetObjectId
								$RelationshipClassObj = $ObjHist.ObjectHistory.Values.RelationshipHistory.ManagementPackRelationshipTypeId
								$RChangeType = $ObjHist.ObjectHistory.Values.RelationshipHistory.ChangeType
								
								$Src = $null
								$Tar = $null
								$Rel = $null
								
								$Src = Get-SCSMObject -Id $SourceObj
								$Tar = Get-SCSMObject -Id $TargetObj
								$Rel = Get-SCSMRelationshipClass -id = $RelationshipClassObj
								
								if ($RChangeType -eq "Insert")
								{
									try
									{
										New-SCSMRelationshipObject -Source $Src -Target $Tar -Relationship $Rel -Bulk
									}
									catch
									{
										Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object Relationships:$MobileDeviceExists For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
									}
								}
								elseIf ($RChangeType -eq "Modify")
								{
									try
									{
										New-SCSMRelationshipObject -Source $Src -Target $Tar -Relationship $Rel -Bulk
									}
									catch
									{
										Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object Relationships:$MobileDeviceExists For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
									}
								}
								elseif ($RChangeType -eq "Delete")
								{
									try
									{
										Get-SCSMRelationshipObject -BySource $Src | ? { ($_.RelationshipClassId -eq $Rel) } | Remove-SCSMRelationshipObject
									}
									catch
									{
										Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object Relationships:$MobileDeviceExists For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
									}
								}
								
								
							}
							
						}
					}
					Set-SCSMObject -SMObject $MobileDeviceExists -Property "LastModifiedSync" -Value $LastModified
				}
			}
		}
	}
	Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Hardware Connector Finished Process of Mobile Objects"
	
	
	#Process Manufacturers And Final Models Count.
	$Manufs = Get-SCSMObject -Class $DevManufacturer
	foreach ($m in $Manufs)
	{
		Set-SCSMObject -SMObject $m -Property "DeviceCount" -Value "0"
		$Models = Get-SCSMRelationshipObject -bytarget $m | ? RelationshipId -eq $ModelHasManufacturerRelCl.Id
		foreach ($Model in $Models)
		{
			$Mo = $null
			$Mo = Get-SCSMObject -Id $Model.SourceObject.Id
			[int]$DeviceCountinModel = $Mo.ModelCount
			$FnV = $null
			$FnV = (Get-SCSMObject -Id $m.Id).DeviceCount
			$FinalVMod = $null
			$FinalVMod = ($FnV) + ($DeviceCountinModel)
			Set-SCSMObject -SMObject $m -property "DeviceCount" -Value $FinalVMod
		}
	}
	
	$InactiveId = (Get-SCSMEnumeration -Name ITSMConnectorStatus.Inactive).id
	Set-SCSMObject -SMObject $HardwareConnectorAdminSettingObj -Property "Status" -Value $InactiveId
	Set-SCSMObject -SMObject $HardwareConnectorAdminSettingObj -Property "LastSynced" -Value (Get-Date)
	Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId 10100 -Category 0 -EntryType Information -Message "Hardware Connector Finished Process Hardware Objects"
}
# SIG # Begin signature block
# MIIUAAYJKoZIhvcNAQcCoIIT8TCCE+0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUj/s49jXhQbKxQmVy0B4/23ZD
# pQmggg60MIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BJ8wggOHoAMCAQICEhEh1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQUFADBS
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEoMCYGA1UE
# AxMfR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBHMjAeFw0xNjA1MjQwMDAw
# MDBaFw0yNzA2MjQwMDAwMDBaMGAxCzAJBgNVBAYTAlNHMR8wHQYDVQQKExZHTU8g
# R2xvYmFsU2lnbiBQdGUgTHRkMTAwLgYDVQQDEydHbG9iYWxTaWduIFRTQSBmb3Ig
# TVMgQXV0aGVudGljb2RlIC0gRzIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQCwF66i07YEMFYeWA+x7VWk1lTL2PZzOuxdXqsl/Tal+oTDYUDFRrVZUjtC
# oi5fE2IQqVvmc9aSJbF9I+MGs4c6DkPw1wCJU6IRMVIobl1AcjzyCXenSZKX1GyQ
# oHan/bjcs53yB2AsT1iYAGvTFVTg+t3/gCxfGKaY/9Sr7KFFWbIub2Jd4NkZrItX
# nKgmK9kXpRDSRwgacCwzi39ogCq1oV1r3Y0CAikDqnw3u7spTj1Tk7Om+o/SWJMV
# TLktq4CjoyX7r/cIZLB6RA9cENdfYTeqTmvT0lMlnYJz+iz5crCpGTkqUPqp0Dw6
# yuhb7/VfUfT5CtmXNd5qheYjBEKvAgMBAAGjggFfMIIBWzAOBgNVHQ8BAf8EBAMC
# B4AwTAYDVR0gBEUwQzBBBgkrBgEEAaAyAR4wNDAyBggrBgEFBQcCARYmaHR0cHM6
# Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADAWBgNV
# HSUBAf8EDDAKBggrBgEFBQcDCDBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3Js
# Lmdsb2JhbHNpZ24uY29tL2dzL2dzdGltZXN0YW1waW5nZzIuY3JsMFQGCCsGAQUF
# BwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNv
# bS9jYWNlcnQvZ3N0aW1lc3RhbXBpbmdnMi5jcnQwHQYDVR0OBBYEFNSihEo4Whh/
# uk8wUL2d1XqH1gn3MB8GA1UdIwQYMBaAFEbYPv/c477/g+b0hZuw3WrWFKnBMA0G
# CSqGSIb3DQEBBQUAA4IBAQCPqRqRbQSmNyAOg5beI9Nrbh9u3WQ9aCEitfhHNmmO
# 4aVFxySiIrcpCcxUWq7GvM1jjrM9UEjltMyuzZKNniiLE0oRqr2j79OyNvy0oXK/
# bZdjeYxEvHAvfvO83YJTqxr26/ocl7y2N5ykHDC8q7wtRzbfkiAD6HHGWPZ1BZo0
# 8AtZWoJENKqA5C+E9kddlsm2ysqdt6a65FDT1De4uiAO0NOSKlvEWbuhbds8zkSd
# wTgqreONvc0JdxoQvmcKAjZkiLmzGybu555gxEaovGEzbM9OuZy5avCfN/61PU+a
# 003/3iCOTpem/Z8JvE3KGHbJsE2FUPKA0h0G9VgEB7EYMIIF9TCCBN2gAwIBAgIQ
# KkVe0MLlP86cwi4qAhN8pjANBgkqhkiG9w0BAQsFADB4MQswCQYDVQQGEwJJTDEW
# MBQGA1UEChMNU3RhcnRDb20gTHRkLjEpMCcGA1UECxMgU3RhcnRDb20gQ2VydGlm
# aWNhdGlvbiBBdXRob3JpdHkxJjAkBgNVBAMTHVN0YXJ0Q29tIENsYXNzIDEgRFYg
# U2VydmVyIENBMB4XDTE2MDgyMDEyMDkzNloXDTE3MDgyMDEyMDkzNlowKTELMAkG
# A1UEBhMCR1IxGjAYBgNVBAMMEXNpZ24ubXNoZWxsYXMuY29tMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlhTZTQAyYBBLvnzT2hpfFY0vS/X6CcYDHNR2
# lvwFJQBvpX2eM5k2jqiBDiDX4gY9YiwWukq+MiGGblNQiYa7d2Qgjs5TjoS/lMNJ
# lZI/WIYj3H5e77qT7VwRS5KCmydId8Zud8avSa95l5sK45cnrFiT+flN0fe7b7nw
# gv+4n7++1AlwvgzAfPdO/pY5RrTzQ+vOkhPF+jCFJ0gfG981DOWlISkorMnVwv2h
# dXVN9bEzQ2THs+QQFeu1rzOlUEaTaaRm6kDlNZzz4XKU9U1gNxsT5Z52xD2sgZno
# PAo6g/0Cm7jGuD8IAG32yrDACI2EtIAPDxCQajmivMx1ojivgwIDAQABo4ICyDCC
# AsQwDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcD
# ATAJBgNVHRMEAjAAMB0GA1UdDgQWBBQNOShOI1UPPhQjPuSYSAnfVeTifTAfBgNV
# HSMEGDAWgBTXkU4BxLC/+Mhnk0Sc5zP6rZMMrzBvBggrBgEFBQcBAQRjMGEwJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLnN0YXJ0c3NsLmNvbTA5BggrBgEFBQcwAoYt
# aHR0cDovL2FpYS5zdGFydHNzbC5jb20vY2VydHMvc2NhLnNlcnZlcjEuY3J0MDgG
# A1UdHwQxMC8wLaAroCmGJ2h0dHA6Ly9jcmwuc3RhcnRzc2wuY29tL3NjYS1zZXJ2
# ZXIxLmNybDAcBgNVHREEFTATghFzaWduLm1zaGVsbGFzLmNvbTAjBgNVHRIEHDAa
# hhhodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS8wUQYDVR0gBEowSDAIBgZngQwBAgEw
# PAYLKwYBBAGBtTcBAgUwLTArBggrBgEFBQcCARYfaHR0cHM6Ly93d3cuc3RhcnRz
# c2wuY29tL3BvbGljeTCCAQUGCisGAQQB1nkCBAIEgfYEgfMA8QB2AGj2mPgfZIK+
# OozuuSgdTPxxUV1nk9RE0QpnrLtPT/vEAAABVqgDmKcAAAQDAEcwRQIgJLiVb+Ja
# a6BunnPE5hXdwenireOqMnkM24O7C6oTupUCIQDN0bYMsAwYmQVqO6EVxeQ+VbYd
# iWfbnPrw79AZeM68YAB3AKS5CZC0GFgUh7sTosxncAo8NZgE+RvfuON3zQ7IDdwQ
# AAABVqgDmcMAAAQDAEgwRgIhAPrLozUMYEWEdyPT0wBhuz9cUeGuWw4YluLGMO25
# xAxwAiEAhKlyExSyer/qcuThyqGQEYR7YcuaHp7nVAnS8ffNsXQwDQYJKoZIhvcN
# AQELBQADggEBACe6BNqcaS4N6cBHguRXo1XBottsPHUEqk+WaFsKvBndjzr01BkI
# NhymaC64eMtnHRIybThGNhSQ+JLmGijM+Su414IJu0R1hkDUVo0hsNdCyL+1aBL1
# pjqDvy/iqgP5wN9PU/5DAIvz8vAFJQC62Ci9x4whhtkiHjFsPwevgPU3om4rjaTb
# 4wzAoDn49nXcEQO6WPuQJTgyzJoUL3+isk2PFW1XLS3IvXsbUNQ7V56woOCiPEyh
# zGSpn/dhKYgfCgVlHvA2V3fzOBjlXq3PsKC38/gIc9HTcjcXN3oHsAGUI0jfjeSD
# TS39FyssETg4QlSXrf4QZmjpf5v2ZJ+EvloxggS2MIIEsgIBATCBjDB4MQswCQYD
# VQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjEpMCcGA1UECxMgU3RhcnRD
# b20gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxJjAkBgNVBAMTHVN0YXJ0Q29tIENs
# YXNzIDEgRFYgU2VydmVyIENBAhAqRV7QwuU/zpzCLioCE3ymMAkGBSsOAwIaBQCg
# WjAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEE
# AYI3AgEEMCMGCSqGSIb3DQEJBDEWBBQTN3h6GXBzEvuIcutwowd2jhST8TANBgkq
# hkiG9w0BAQEFAASCAQAuEjDYPOZmTdlEhmk9HMI+LA950apYg7CLGdJtT8UYIGTx
# aAKfgM1ToSXB7g28/aMb47J4L0ivelSvkP/GMnftFQIeNFrc8pHdcHKADot8+z41
# W32456QAysluVBWXo5QFQHWm4pr9KjferwNyyw+2JFJEeEAAyKcTX5WnfdmfVNmO
# bUedCWSfx/tA+HFBAyf4n436VCPc5D5CqeKjstmyOeDZ16dJLSeDsESVJOmlg2Jv
# RIVfaxWkFZmE17fjnlF/ogXfi8n/a4rodCDYBnDXsYzLYtwOAT7V4c5v+Ld0Qs8X
# JQvx733416xf895OPGnISbSCe+9QQRR6BX1h/UyyoYICojCCAp4GCSqGSIb3DQEJ
# BjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNp
# Z24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0g
# RzICEhEh1pmnZJc+8fhCfukZzFNBFDAJBgUrDgMCGgUAoIH9MBgGCSqGSIb3DQEJ
# AzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2MDgyMDEzMDQxOFowIwYJ
# KoZIhvcNAQkEMRYEFKMHJH4K7uCEMsccI+bngW9tYR7vMIGdBgsqhkiG9w0BCRAC
# DDGBjTCBijCBhzCBhAQUY7gvq2H1g5CWlQULACScUCkz7HkwbDBWpFQwUjELMAkG
# A1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0ds
# b2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh1pmnZJc+8fhCfukZzFNB
# FDANBgkqhkiG9w0BAQEFAASCAQB/FqbWtJ04tzUzbjTzfA1HtcqGqo526GVNJQWx
# yFCPCdM+o27FuXQpOqDHj5YhHqiaAOiZWswLi8PzdITrpPzb5eDtxeLkhku//BTj
# EzRAIl3mR3SLQ2qm4DUAJI3zvL8htyC465OmpAztfqjJzxp9J5OQc9vdJ2x6W6sQ
# pG1xfqLcEJeagDjiFpfwbiOXoqAsyIylG7PJNYA+s/CqlNIJj5EIvHelvLD0k3Ii
# 5EAoZ9nfiUuL6Gj52Uj9pmIsubhEIj1/v83FlM5DgHGH3yl9CpDP44n8Ez/S9MQ6
# XW165XU0NTYu688ZcxD1NzQYaVEi1N2F6TIp05H/51o9s4VA