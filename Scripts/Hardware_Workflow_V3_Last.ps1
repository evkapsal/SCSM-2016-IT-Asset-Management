#NOTES
#===========================================================================
#Created with:  SAPIEN Technologies, Inc., PowerShell Studio 2015
#Created on:    12/8/2016 15:30 PM
#Created by:     Evangelos Kapsalakis
#Organization:   Microsoft Hellas
#Filename:  Hardware Connector V3
#===========================================================================
#.DESCRIPTION
#A description of the file.

Import-Module SMLets

$HardwareConnectorAdminSettingCl = Get-SCSMClass -Name HardwareConnector$
$HardwareConnectorAdminSettingObj = Get-SCSMObject -Class $HardwareConnectorAdminSettingCl
if ($HardwareConnectorAdminSettingObj.IsActive -eq $true)
{
	#Set-SCSMObject -SMObject $HardwareConnectorAdminSettingObj -Property "SyncNow" -Value $false
	
	Try
	{
		$ActiveId = (Get-SCSMEnumeration -Name ITSMConnectorStatus.Running$).id
		Set-SCSMObject -SMObject $HardwareConnectorAdminSettingObj -Property "Status" -Value $ActiveId
	}
	Catch { }
	
	
	
	##
	try
	{
		$SQLSrv = (Get-SCSMConnector -ComputerName "CORPSCSM01" | ?{ $_.DataProviderName -eq "SmsConnector" }).ServerName
		$DBName = (Get-SCSMConnector -ComputerName "CORPSCSM01" | ?{ $_.DataProviderName -eq "SmsConnector" }).DatabaseName
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
	
	$ErrorID = 10101
	$InfoID = 10100
	$WarningId = 10102
	$PreFix = $HardwareConnectorAdminSettingObj.AssetTagPrefix
	
	$ActiveObjEnum = (Get-SCSMEnumeration -Name ObjectStatusEnum.Active).id
	$ReadinessStatusEnumId = (Get-SCSMEnumeration -Name ReadinessStatus.InUse).id
	$ReadinessStatusNotUsedEnumId= (Get-SCSMEnumeration -Name ReadinessStatus.ReadyForUse).id
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
	$DevHasSoftInstalledRelClId= (Get-SCSMRelationshipClass -Name System.DeviceHasSoftwareItemInstalled$).id
	$DevHasUpdInstalledRelClId= (Get-SCSMRelationshipClass -Name System.DeviceHasSoftwareUpdateInstalled$).id
	
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
		(AgentName  like 'Heartbeat Discovery' and DATEDIFF(Day, AgentTime, Getdate())>=30) OR
		(AgentName  like 'SMS_AD_SYSTEM_DISCOVERY_AGENT' and DATEDIFF(Day, AgentTime, Getdate())>=30)")
		
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
				[int]$Sockets = (Get-SCSMRelatedObject -SMObject $WindowsComputer.Object | ?{ $_.ClassName -eq "Microsoft.Windows.Peripheral.Processor" } | Measure-Object).Count
				
				try
				{
					try
					{
						$Res = Get-ProcessorDetails -COMP $($WindowsComputer.DisplayName) -Server $SQLSrv -Database $DBName
					}
					Catch
					{
						Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Query SCCM DB For Computer: $($WindowsComputer.DisplayName). Please Ensure that SCSM Workflow Account has Read Permission on SQL Server: $SQLSrv and Database: $DBName."
					}
					Finally
					{
						if (($Res.Processors | Measure-Object).Count -gt 1)
						{
							
							$FPhyProcSum = $($Res.Processors) -join '+'
							$LogicProc = Invoke-Expression $FPhyProcSum
							
							$FPhyCorSum = $($Res.Cores) -join '+'
							$PhysProc = Invoke-Expression $FPhyCorSum
							
						}
						else
						{
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
				
				if ($($HWExists.LastModifiedSync) -ne $($ActualHw.LastModified))
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
				}
			}
				<#	[string]$CompModel = $WindowsComputer.Model
					[string]$CompManufacturer = $WindowsComputer.Manufacturer
					
					##Processing Cores and Processors
					[int]$Sockets = (Get-SCSMRelatedObject -SMObject $WindowsComputer.Object | ?{ $_.ClassName -eq "Microsoft.Windows.Peripheral.Processor" } | Measure-Object).Count
					
					try
					{
						try
						{
							$Res = Get-ProcessorDetails -COMP $($WindowsComputer.DisplayName) -Server $SQLSrv -Database $DBName
						}
						Catch
						{
							Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Query SCCM DB For Update Computer: $($WindowsComputer.DisplayName). Please Ensure that SCSM Workflow Account has Read Permission on SQL Server: $SQLSrv and Database: $DBName."
						}
						Finally
						{
							if (($Res.Processors.GetType().BaseType.Name) -ne "Object")
							{
								
								$FPhyProcSum = $($Res.Processors) -join '+'
								$LogicProc = Invoke-Expression $FPhyProcSum
								
								$FPhyCorSum = $($Res.Cores) -join '+'
								$PhysProc = Invoke-Expression $FPhyCorSum
								
							}
							else
							{
								$LogicProc = $Res.Processors
								$PhysProc = $Res.Cores
							}
							
						}
					}
					finally
					{
						if ($Sockets -eq 2)
						{
							[int]$PhysicalCores = $PhysProc /2
						}
						elseif ($Sockets -eq 4)
						{
							[int]$PhysicalCores = $PhysProc /4
						}
						else { [int]$PhysicalCores = $PhysProc }
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
					
					[String]$ConnDetails = "$CompName" + "$Nip" + "$NMac" + "$OSDisplayName" + "$Memory" + "$SerialNumber" + "$AssetTag" + "$($LastModified.ToString())"
					$ObjHash = Get-StringHash -String $ConnDetails
					
					
					
					if ($ActualHw.ObjectHash -ne $ObjHash)
					{
						
						
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
							"Memory" = $Memory;
							"ProcessorFamily" = $Fam;
							"SerialNumber" = $SerialNumber;
							"ObjectHash" = $ObjHash;
							"AssetTag" = $AssetTag;
							"LastDiscoveredDate" = (Get-Date);
							"LastModifiedSync" = $LastModified;
						}
						
						$UpdatedObject = Set-SCSMObject -SMObject $ActualHw -PropertyHashtable $PropertyHashTable -PassThru
						
						
					}
					else
					{
						Set-SCSMObject -SMObject $ActualHw -Property "LastDiscoveredDate" -Value (Get-Date)
					}
					
					if ($DeviceUser)
					{
						
						$id = $DeviceUser.id
						$DevUsrExists = Get-SCSMObject -Class (Get-SCSMClass -Name Microsoft.AD.User$) -Filter "id -eq $id" -ErrorAction SilentlyContinue
					}
					
					try
					{
						$ExUsr = (Get-SCSMRelationshipObject -BySource $ActualHw | ? { $_.RelationshipId -eq $($HardwareHasUserRelCl.id) }).TargetObject
						if ($ExUsr.id -ne $DevUsrExists.id)
						{
							Get-SCSMRelationshipObject -BySource $ActualHw | ? { $_.RelationshipId -eq "$HardwareHasUserRelCl.id" } | Remove-SCSMRelationshipObject
							New-SCSMRelationshipObject -Relationship $HardwareHasUserRelCl -Source $ActualHw -Target $DevUsrExists -Bulk
						}
					}
					Catch
					{
						Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $WarningId -Category 0 -EntryType Warning -Message "Something Wrong Happened with Hardware Connector while assigning the New User in Computer: $CompName and User: $DevUsrExists with Exception: $($_.Exception.Message)"
					}
					
					$HWAss = Get-SCSMObject -Class $HardwareAssetClass -Filter "AssetName -eq $CompName"
					if ($HWAss)
					{
						
						$AssetTable = @{
							"AssetName" = $CompName;
							"DisplayName" = $CompName;
							"Type" = $DevType;
							"AssetTag" = $AssetTag;
							"SerialNumber" = $SerialNumber;
						}
						Set-SCSMObject -SMObject $HWAss -PropertyHashtable $AssetTable
						
						$HwExUsr = (Get-SCSMRelationshipObject -BySource $HWAss | ? { $_.RelationshipId -eq $($HardwareAssetHasUser.id) }).TargetObject
						if ($HwExUsr.id -ne $DeviceUser.id)
						{
							Try
							{
								Get-SCSMRelationshipObject -BySource $HWAss | ? { $_.RelationshipId -eq "$HardwareAssetHasUser.id" } | Remove-SCSMRelationshipObject
								New-SCSMRelationshipObject -Relationship $HardwareAssetHasUser -Source $HWAss -Target $DeviceUser -Bulk
							}
							Catch
							{
								Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $WarningId -Category 0 -EntryType Warning -Message "Something Wrong Happened with Hardware Connector while assigning the New User in Hardware Asset: $CompName and User: $DevUsrExists with Exception: $($_.Exception.Message)"
							}
							
						}
						
					}
					
				}
			}
			
			
		}
			#>
			
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
			$NetDevExists = Get-SCSMObject -Class $NetworkDeviceClass -Filter "SNMPAddress -eq $($NetDevice.SNMPAddress)"
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
						New-SCSMRelationshipObject -Relationship $HardwareAssetRefHardwareRelCl -Source $DevAsset -Target $NewNetDevice -Bulk
					}
				}
				catch
				{
				}
				
				
				
			}
			else
			{
				if ($($NetDevExists.LastModifiedSync) -ne $($NetDevice.LastModified))
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
										Set-SCSMObject -SMObject $NetDevExists -Property $Propery -Value " "
									}
									catch
									{
										Write-EventLog -LogName 'Operations Manager' -Source 'Hardware Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Hardware Connector Cannot Update Object: $NetDevExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
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
				if ($($PrinterExists.LastModifiedSync) -ne $($Printer.LastModified))
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
				if ($($MobileDeviceExists.LastModifiedSync) -ne $($MobileDevice.LastModified))
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