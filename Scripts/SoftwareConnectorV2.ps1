<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.99
	 Created on:   	1/3/2016 17:10 PM
	 Created by:   	Evangelos Kapsalakis 
	 Organization: 	Microsoft Hellas
	 Filename:     	Software Connector
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


Import-Module SMLets

$ITSMSoftwareConnectorClass = Get-SCSMClass -Name SoftwareConnector$
$Connector = Get-SCSMObject -Class $ITSMSoftwareConnectorClass
if ($Connector.IsActive -eq $true)
{
	
	Function Get-StringHash([String]$String)
	{
		$StringBuilder = New-Object System.Text.StringBuilder
		[System.Security.Cryptography.HashAlgorithm]::Create('MD5').ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String)) | %{
			[Void]$StringBuilder.Append($_.ToString("x2"))
		}
		$StringBuilder.ToString()
	}
	
	
	Try
	{
		$ActiveId = (Get-SCSMEnumeration -Name ITSMConnectorStatus.Running$).id
		Set-SCSMObject -SMObject $Connector -Property "Status" -Value $ActiveId
	}
	Catch { }
	
	
	Try
	{
		$events = [System.Diagnostics.EventLog]::SourceExists("Software Connector");
	}
	catch { }
	finally
	{
		if ($events -ne $true)
		{
			New-EventLog -LogName 'Operations Manager' -Source 'Software Connector'
			Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Software Connector Succesfully Create Event Log Source"
		}
		
		Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Software Connector Start Processing Software Objects"
	}
	
	$ErrorID = 10101
	$InfoID = 10100
	$WarningId = 10102
	
	#Object Classes
	$SoftwareClass = Get-SCSMClass -Name System.SoftwareItem$
	$ITSMSoftwareClass = Get-SCSMClass -Name Software$
	$ITSMVersionClass = Get-SCSMClass -Name SoftwareVersion$
	$ITSMPublisherClass = Get-SCSMClass -Name SoftwarePublisher$
	$ITSMSoftwareAssetClass = Get-SCSMClass -Name SoftwareAsset$
	$ITSMHardwareAssetClass = Get-SCSMClass -Name HardwareAsset$
	#Relationship Classes
	$SoftwareRelCl = Get-SCSMRelationshipClass -Name System.DeviceHasSoftwareItemInstalled$
	$ITSMSoftHasPubRelCl = Get-SCSMRelationshipClass -Name Relationship.SoftwareHasPublisher$
	$ITSMSoftHasVersionRelCl = Get-SCSMRelationshipClass -Name Relationship.SoftwareHasVersion$
	$ITSMSoftAssetHasSoftRelCl = Get-SCSMRelationshipClass -Name Relationship.SoftwareAssetHasSoftware$
	$ITSMSoftIsForHardwareAssetRelCl = Get-SCSMRelationshipClass -Name Relationship.SoftwareIsInstalledOnHardwareAsset$
	$PendingDeleteEnumId = (Get-SCSMEnumeration -Name System.ConfigItem.ObjectStatusEnum.PendingDelete$).Id
	$InactiveId = (Get-SCSMEnumeration -Name ITSMConnectorStatus.Inactive$).id
	$ReadinessStatusEnumId = (Get-SCSMEnumeration -Name ReadinessStatus.InUse$).id
	$NotAvailableStatusEnumId = (Get-SCSMEnumeration -Name ReadinessStatus.NotAvailable$).id
	$ConfigItemRelCl = Get-SCSMRelationshipClass -Name System.ConfigItemRelatesToConfigItem$
	$VersionIsForAsset = Get-SCSMRelationshipClass -Name Relationship.SoftwareVersionInstalledOnAssets$
	
	$SoftwareInstalled = Get-SCSMObject -Class $SoftwareClass -Filter "ObjectStatus -ne $PendingDeleteEnumId"
	if ($SoftwareInstalled)
	{
		foreach ($iSoftware in $SoftwareInstalled)
		{
			$iSoftName = $null
			$iSoftPublisher = $null
			$iSoftVersion = $null
			$iSoftwareProductCode = $null
			$HashString = $null
			$iSoftIsInstalled = $null
			$iSoftInstalledCount = $null
			$iSoftExists = $null
			$NotAvailable = $false
			
			$iSoftName = $iSoftware.DisplayName
			$iSoftPublisher = $iSoftware.Publisher
			$iSoftVersion = $iSoftware.VersionString
			$iSoftwareProductCode = $iSoftware.ProductCode
			
			
			[string]$HashString = ($iSoftName + $iSoftPublisher + $iSoftwareProductCode)
			$iSoftHash = Get-StringHash -String $HashString
			
			$iSoftExists = (Get-SCSMObject -Class $ITSMSoftwareClass -Filter "ObjectHash -eq '$iSoftHash' and ObjectStatus -ne '$PendingDeleteEnumId'")
			if (!$iSoftExists)
			{
				
				$iSofthashtable = $null
				$iSofthashtable = @{
					"DisplayName" = $iSoftName;
					"SoftwareName" = $iSoftName;
					"ProductCode" = $iSoftwareProductCode;
					"LastDiscoveredDate" = (Get-Date);
					"ObjectHash" = $iSoftHash;
					"Installed" = $iSoftInstalledCount;
				}
				
				$SoftItem = $null
				$SoftItem = New-SCSMObject -Class $ITSMSoftwareClass -PropertyHashtable $iSofthashtable -PassThru
				if ($SoftItem)
				{
					try
					{
						if ($iSoftPublisher.Length -gt 0)
						{
							$PublisherExists = $null
							$PublisherExists = Get-SCSMObject -Class $ITSMPublisherClass -Filter "DisplayName -eq $iSoftPublisher" -ErrorAction SilentlyContinue
							if ($PublisherExists)
							{
								New-SCSMRelationshipObject -Source $SoftItem -Target $PublisherExists -Relationship $ITSMSoftHasPubRelCl -Bulk
							}
							else
							{
								$PubHashTable = @{
									"DisplayName" = $iSoftPublisher;
									"PublisherName" = $iSoftPublisher;
								}
								
								$Publisher = $null
								$Publisher = New-SCSMObject -Class $ITSMPublisherClass -PropertyHashtable $PubHashTable -PassThru
								if ($Publisher.PublisherName)
								{
									New-SCSMRelationshipObject -Source $SoftItem -Target $Publisher -Relationship $ITSMSoftHasPubRelCl -Bulk
								}
							}
						}
						if ($iSoftVersion.Length -gt 0)
						{
							$VersionHashStr = $null
							$VersionHash = $null
							$Version = $null
							
							$VersionHashStr = $iSoftHash + $iSoftVersion
							$VersionHash = Get-StringHash -String $VersionHashStr
							$Version = Get-SCSMObject -Class $ITSMVersionClass -Filter "VersionHash -eq $VersionHash"
							if ($Version)
							{
								#Check Already Relationship
								$VerForSoft = (Get-SCSMRelationshipObject -BySource $Version | ? { RelationshipId -eq $ITSMSoftHasVersionRelCl.id }).TargetObject
								if ($VerForSoft.id -ne $SoftItem.id)
								{
									New-SCSMRelationshipObject -Source $Version -Target $SoftItem -Relationship $ITSMSoftHasVersionRelCl -Bulk
								}
								
							}
							else
							{
								
								$VerHashTable = $null
								$VerHashTable = @{
									"DisplayName" = $iSoftVersion;
									"SoftwareVersionMaj" = $iSoftVersion;
									"VersionHash" = $VersionHash;
								}
								
								$Version = $null
								$Version = New-SCSMObject -Class $ITSMVersionClass -PropertyHashtable $VerHashTable -PassThru
								New-SCSMRelationshipObject -Source $Version -Target $SoftItem -Relationship $ITSMSoftHasVersionRelCl -Bulk
							}
						}
						
						$SoftWareAsset = $null
						$SoftWareAsset = Get-SCSMObject -Class $ITSMSoftwareAssetClass -Filter "DisplayName -eq $SoftItem.DisplayName" -ErrorAction SilentlyContinue
						
						if (!$SoftWareAsset)
						{
							
							$SoftAssTable = $null
							$SoftAssTable = @{
								"DisplayName" = $iSoftName;
								"AssetName" = $iSoftName;
								"SerialNumber" = $iSoftwareProductCode;
								"ReadinessStatus" = $Ready;
							}
							
							$SoftWareAsset = $null
							$SoftWareAsset = New-SCSMObject -Class $ITSMSoftwareAssetClass -PropertyHashtable $SoftAssTable -PassThru
							New-SCSMRelationshipObject -Source $SoftWareAsset -Target $SoftItem -Relationship $ITSMSoftAssetHasSoftRelCl -Bulk
							
						}
						
						$iSoftIsInstall = $null
						
						$iSoftIsInstall = Get-SCSMRelationshipObject -ByTarget $iSoftware | ? { $_.RelationShipId -eq $SoftwareRelCl.id }
						if ($iSoftIsInstall)
						{
							$Count = $iSoftIsInstall.Count
							Set-SCSMObject -SMObject $Version -Property "Installed" -Value $Count
							$FinalCount = $SoftItem.Installed + $Count
							Set-SCSMObject -SMObject $SoftItem -Property "Installed" -Value $FinalCount
							if ($FinalCount -gt 0)
							{
								Set-SCSMObject -SMObject $SoftWareAsset -Property "ReadinessStatus" -Value $ReadinessStatusEnumId
							}
							
							foreach ($Computer in $iSoftIsInstall)
							{
								$HardwareAsset = $null
								$HardwareAssetPr = $null
								$HardwareAssetPr = $Computer.SourceObject
								$HardwareAsset = Get-SCSMObject -Class $ITSMHardwareAssetClass -Filter "DisplayName -eq $($HardwareAssetPr.Name)"
								if ($HardwareAsset)
								{
									New-SCSMRelationshipObject -Source $Version -Target $HardwareAsset -Relationship $VersionIsForAsset -Bulk
									New-SCSMRelationshipObject -Source $SoftItem -Target $HardwareAsset -Relationship $ITSMSoftIsForHardwareAssetRelCl -Bulk
								}
								
								
							}
							
						}
						
						New-SCSMRelationshipObject -Relationship $ConfigItemRelCl -Source $SoftItem -Target $iSoftware -Bulk
					}
					catch
					{
						Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId $WarningId -Category 0 -EntryType Warning -Message "Something Wrong Happened with Software Connector while Processing New Software: $($SoftItem.DisplayName) with Exception Message: $($_.Exception.Message) and Exception: $($_.Exception.InnerException)"
					}
				}
				
				
			}
			else
			{
				try
				{
					if ($iSoftVersion.Length -gt 0)
					{
						$VersionHashStr = $null
						$VersionHash = $null
						$Version = $null
						$VersionFromSof = $null
						$VersionHashStr = $iSoftHash + $iSoftVersion
						$VersionHash = Get-StringHash -String $VersionHashStr
						$Version = Get-SCSMObject -Class $ITSMVersionClass -Filter "VersionHash -eq $VersionHash"
						if ($Version)
						{
							#Check Already Relationship
							$VerForSoft = (Get-SCSMRelationshipObject -BySource $Version | ? { $_.RelationshipId -eq $ITSMSoftHasVersionRelCl.id }).TargetObject
							if ($VerForSoft.id -ne $iSoftExists.id)
							{
								New-SCSMRelationshipObject -Source $Version -Target $iSoftExists -Relationship $ITSMSoftHasVersionRelCl -Bulk
							}
							
						}
						else
						{
							
							$VerHashTable = $null
							$VerHashTable = @{
								"DisplayName" = $iSoftVersion;
								"SoftwareVersionMaj" = $iSoftVersion;
								"VersionHash" = $VersionHash;
							}
							
							$Version = $null
							$Version = New-SCSMObject -Class $ITSMVersionClass -PropertyHashtable $VerHashTable -PassThru
							New-SCSMRelationshipObject -Source $Version -Target $iSoftExists -Relationship $ITSMSoftHasVersionRelCl -Bulk
						}
						
					}
					$iASoftIsInstalled = $null
					$iASoftInstalledCount = $null
					$iASoftIsInstalled = Get-SCSMRelationshipObject -ByTarget $iSoftware | ? { $_.RelationshipId -eq $SoftwareRelCl.id }
					if ($iASoftIsInstalled)
					{
						$iASoftInstalledCount = $null
						$AlreadyInstalledByVersion = $null
						$AlreadyInstalledBySoft = $null
						$RemVal = $null
						
						[int]$iASoftInstalledCount = $iASoftIsInstalled.Count
						[int]$AlreadyInstalledByVersion = $Version.Installed
						if ($AlreadyInstalledByVersion -ne $iASoftInstalledCount)
						{
							[int]$AlreadyInstalledBySoft = $iSoftExists.Installed
							[int]$RemVal = $AlreadyInstalledBySoft - $AlreadyInstalledByVersion
							
							$NewValiSoft= $null
							$NewValiSoft= Set-SCSMObject -SMObject $iSoftExists -Property "Installed" -Value $RemVal -PassThru
							Set-SCSMObject -SMObject $Version -Property "Installed" -Value $iASoftInstalledCount
							
							$NewValAss = $null
							$FinalVal= $null
							[int]$NewValAss = $NewValiSoft.Installed
							[int]$FinalVal = $iASoftInstalledCount + $NewValAss
							Set-SCSMObject -SMObject $iSoftExists -Property "Installed" -Value $FinalVal
							
						}
						$SoftAssEx = Get-SCSMObject -Class $ITSMSoftwareAssetClass -Filter "DisplayName -eq $($iSoftExists.DisplayName)"
						if ($SoftAssEx)
						{
							if ($FinalVal -gt 0)
							{
								Set-SCSMObject -SMObject $SoftAssEx -Property "ReadinessStatus" -Value $ReadinessStatusEnumId
							}
							else
							{
								Set-SCSMObject -SMObject $SoftAssEx -Property "ReadinessStatus" -Value $NotAvailableStatusEnumId
							}
						}
						
						
						
						
						foreach ($Comp in $iASoftIsInstalled)
						{
							
							$HardwareAsset = $null
							$HardwareAssetPr = $null
							$HardwareAssetPr = $Comp.SourceObject
							$HardwareAsset = Get-SCSMObject -Class $ITSMHardwareAssetClass -Filter "DisplayName -eq $($HardwareAssetPr.Name)"
							if ($HardwareAsset)
							{
								$AlreadyVersionRelated= $null
								$AlreadyVersionRelated = Get-SCSMRelationshipObject -ByTarget $HardwareAsset | ?{ ($_.RelationshipId -eq $VersionIsForAsset.id) -and ($_.SourceObject.id -eq $($Version.id)) }
								if (!$AlreadyVersionRelated)
								{
									New-SCSMRelationshipObject -Source $Version -Target $HardwareAsset -Relationship $VersionIsForAsset -Bulk
								}
								
								$AlreadyRelated= $null
								$AlreadyRelated = Get-SCSMRelationshipObject -ByTarget $HardwareAsset | ?{ ($_.RelationshipId -eq $ITSMSoftIsForHardwareAssetRelCl.id) -and ($_.SourceObject.id -eq $($iSoftExists.id)) }
								if (!$AlreadyRelated)
								{
									New-SCSMRelationshipObject -Source $iSoftExists -Target $HardwareAsset -Relationship $ITSMSoftIsForHardwareAssetRelCl -Bulk
								}
							}
							
							
						}
						
					}
					
				}
				
				Catch
				{
					Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId $WarningId -Category 0 -EntryType Warning -Message "Something Wrong Happened with Software Connector while Processing Already Added Software: $($iSoftExists.DisplayName) with Exception Message: $($_.Exception.Message) and Exception: $($_.Exception.InnerException)"
				}
			}
			
			
			
			
			
		}
		
	}
	Set-SCSMObject -SMObject $Connector -Property "Status" -Value $InactiveId
	Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Software Connector Finished Processing Software Objects"
}