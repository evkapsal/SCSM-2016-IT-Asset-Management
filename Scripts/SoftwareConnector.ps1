<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.99
	 Created on:   	12/30/2015 12:29 PM
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
			$NotAvailable = $false
			
			$iSoftName = $iSoftware.DisplayName
			$iSoftPublisher = $iSoftware.Publisher
			$iSoftVersion = $iSoftware.VersionString
			$iSoftwareProductCode = $iSoftware.ProductCode
			
			[array]$iSoftIsInstalled = Get-SCSMRelationshipObject -ByTarget $iSoftware | ? { $_.RelationShipId -eq $SoftwareRelCl.id }
			[int]$iSoftInstalledCount = $iSoftIsInstalled.count
			
			if ($iSoftInstalledCount -le 0)
			{
				[bool]$NotAvailable = $true
			}
			
			[string]$HashString = ($iSoftName + $iSoftPublisher + $iSoftVersion + $iSoftwareProductCode + $iSoftInstalledCount.ToString())
			$iSoftHash = Get-StringHash -String $HashString
			
			$iSoftExists = (Get-SCSMObject -Class $ITSMSoftwareClass -Filter "SoftwareName -eq '$iSoftName' and ProductCode -eq '$iSoftwareProductCode' and ObjectStatus -ne '$PendingDeleteEnumId'")
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
								
								$Publisher = New-SCSMObject -Class $ITSMPublisherClass -PropertyHashtable $PubHashTable -PassThru
								if ($Publisher.PublisherName)
								{
									New-SCSMRelationshipObject -Source $SoftItem -Target $Publisher -Relationship $ITSMSoftHasPubRelCl -Bulk
								}
							}
						}
						
						
						if ($iSoftVersion)
						{
							$VersionExists = $null
							$VersionExists = Get-SCSMObject -Class $ITSMVersionClass -Filter "DisplayName -eq $iSoftVersion" -ErrorAction SilentlyContinue
							if ($VersionExists)
							{
								if ($VersionExists.Count -gt 1)
								{
									foreach ($Ver in $VersionExists)
									{
										$VerForSoft = (Get-SCSMRelationshipObject -ByTarget $SoftItem | ? { RelationshipId -eq $ITSMSoftHasVersionRelCl.id }).SourceObject
										if ($VerForSoft.id -eq $Ver.id)
										{
											New-SCSMRelationshipObject -Source $Ver -Target $SoftItem -Relationship $ITSMSoftHasVersionRelCl -Bulk
										}
									}
								}
							}
							else
							{
								
								$VerHashTable = $null
								$VerHashTable = @{
									"DisplayName" = $iSoftVersion;
									"SoftwareVersionMaj" = $iSoftVersion;
								}
								
								$Version = $null
								$Version = New-SCSMObject -Class $ITSMVersionClass -PropertyHashtable $VerHashTable -PassThru
								New-SCSMRelationshipObject -Source $Version -Target $SoftItem -Relationship $ITSMSoftHasVersionRelCl -Bulk
							}
						}
						
						$SoftAsset = $null
						$SoftAsset = Get-SCSMObject -Class $ITSMSoftwareAssetClass -Filter "DisplayName -eq $SoftItem.DisplayName" -ErrorAction SilentlyContinue
						
						if (!$SoftAsset)
						{
							$Ready = $null
							if ($NotAvailable -eq $true)
							{ $Ready = $NotAvailableStatusEnumId }
							else
							{ $Ready = $ReadinessStatusEnumId }
							
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
							$Count = $null
							[int]$Count = $iSoftIsInstall.Count
							if ($Count)
							{
								if ($SoftItem.Installed -le 0)
								{
									Set-SCSMObject -SMObject $SoftItem -Property "Installed" -Value $Count
									Set-SCSMObject -SMObject $SoftItem -Property "ReadinessStatus" -Value $ReadinessStatusEnumId
								}
								elseif ($SoftItem.Installed -lt $Count)
								{
									[int]$FinalCount = $Count + $iSoftIsInstall.Count
									Set-SCSMObject -SMObject $SoftItem -Property "Installed" -Value $FinalCount
								}
							}
							foreach ($Computer in $iSoftIsInstall)
							{
								$HardwareAsset = $null
								$HardwareAssetPr = $null
								$HardwareAssetPr = $Computer.SourceObject
								$HardwareAsset = Get-SCSMObject -Class $ITSMHardwareAssetClass -Filter "DisplayName -eq $($HardwareAssetPr.Name)"
								if ($HardwareAsset)
								{
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
				$AlreadyExists = $null
				$AlreadyExists = (Get-SCSMObject -Class $ITSMSoftwareClass -Filter "ObjectHash -eq $iSoftHash")
				if (!$AlreadyExists)
				{
					try
					{
						#CheckVersion
						$iSoftEx = $null
						
						$iSoftEx = Get-SCSMObject -Class $ITSMSoftwareClass -Filter "SoftwareName -eq '$iSoftName' and ProductCode -eq '$iSoftwareProductCode' and ObjectStatus -ne '$PendingDeleteEnumId'"
						if ($iSoftEx)
						{
							$VersionFromSof = $null
							$VersionFromSof = (Get-SCSMRelationshipObject -ByTarget $iSoftEx | ? { $_.RelationshipId -eq $ITSMSoftHasVersionRelCl.Id })
							if ($VersionFromSof.Count -gt 1)
							{
								foreach ($Vr in $VersionFromSof)
								{
									if ($iSoftVersion -ne $Vr.SourceObject.DisplayName)
									{
										$VerHashTable = $null
										$VerHashTable = @{
											"DisplayName" = $iSoftVersion;
											"SoftwareVersionMaj" = $iSoftVersion;
										}
										
										$Version = $null
										$Version = New-SCSMObject -Class $ITSMVersionClass -PropertyHashtable $VerHashTable -PassThru
										New-SCSMRelationshipObject -Source $Version -Target $iSoftEx -Relationship $ITSMSoftHasVersionRelCl -Bulk
									}
								}
							}
							else
							{
								if ($iSoftVersion -ne $VersionFromSof.SourceObject.DisplayName)
								{
									$VerHashTable = $null
									$VerHashTable = @{
										"DisplayName" = $iSoftVersion;
										"SoftwareVersionMaj" = $iSoftVersion;
									}
									
									$Version = $null
									$Version = New-SCSMObject -Class $ITSMVersionClass -PropertyHashtable $VerHashTable -PassThru
									New-SCSMRelationshipObject -Source $Version -Target $iSoftEx -Relationship $ITSMSoftHasVersionRelCl -Bulk
								}
								
							}
							$iASoftIsInstalled = $null
							$iASoftInstalledCount = $null
							$iASoftIsInstalled = Get-SCSMRelationshipObject -ByTarget $iSoftware | ? { $_.RelationShipId -eq $SoftwareRelCl.id }
							if ($iASoftIsInstalled)
							{
								[int]$iASoftInstalledCount = $iASoftIsInstalled.Count
								if ($iSoftEx.Installed -le 0)
								{
									$FinalCount = $null
									$FinalCount = $iASoftInstalledCount
									Set-SCSMObject -SMObject $iSoftEx -Property "Installed" -Value $iASoftInstalledCount
									Set-SCSMObject -SMObject $iSoftEx -Property "ReadinessStatus" -Value $ReadinessStatusEnumId
								}
								elseif ($iSoftEx.Installed -lt $iASoftInstalledCount)
								{
									$FinalCount = $null
									[int]$FinalCount = $iASoftInstalledCount + $iSoftEx.Installed
									Set-SCSMObject -SMObject $iSoftEx -Property "Installed" -Value $FinalCount
								}
								elseif ($iSoftEx.Installed -gt $iASoftInstalledCount)
								{
									$FinalCount = $null
									[int]$FinalCount = $iASoftInstalledCount + $iSoftEx.Installed
									Set-SCSMObject -SMObject $iSoftEx -Property "Installed" -Value $FinalCount
								}
								
								
								foreach ($Comp in $iASoftIsInstalled)
								{
									
									$HardwareAsset = $null
									$HardwareAssetPr = $null
									$HardwareAssetPr = $Comp.SourceObject
									$HardwareAsset = Get-SCSMObject -Class $ITSMHardwareAssetClass -Filter "DisplayName -eq $($HardwareAssetPr.Name)"
									if ($HardwareAsset)
									{
										$AlreadyRelated = Get-SCSMRelationshipObject -ByTarget $HardwareAsset | ?{ ($_.RelationshipId -eq $ITSMSoftIsForHardwareAssetRelCl.id) -and ($_.SourceObject -eq $iSoftEx) }
										if (!$AlreadyRelated)
										{
											New-SCSMRelationshipObject -Source $iSoftEx -Target $HardwareAsset -Relationship $ITSMSoftIsForHardwareAssetRelCl -Bulk
										}
									}
									
									
								}
								
								[string]$HashString = ($iSoftEx.SoftwareName + $iSoftPublisher + $iSoftVersion + $iSoftwareProductCode + $FinalCount)
								$iSoftHash = Get-StringHash -String $HashString
								Set-SCSMObject -SMObject $iSoftEx -Property "ObjectHash" -Value $HashString
							}
						}
					}
					Catch
					{
						Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId $WarningId -Category 0 -EntryType Warning -Message "Something Wrong Happened with Software Connector while Processing Already Added Software: $($iSoftEx.DisplayName) with Exception Message: $($_.Exception.Message) and Exception: $($_.Exception.InnerException)"
					}
				}
			}
		}
		
		
		Set-SCSMObject -SMObject $Connector -Property "Status" -Value $InactiveId
		Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Software Connector Finished Processing Software Objects"
	}
}