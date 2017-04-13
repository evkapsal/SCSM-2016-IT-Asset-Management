﻿<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.99
	 Created on:   	20/8/2016 20:00 PM
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
	Set-SCSMObject -SMObject $Connector -Property "SyncNow" -Value $false
	
	Function Get-StringHash([String]$String)
	{
		$StringBuilder = New-Object System.Text.StringBuilder
		[System.Security.Cryptography.HashAlgorithm]::Create('MD5').ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String)) | %{
			[Void]$StringBuilder.Append($_.ToString("x2"))
		}
		$StringBuilder.ToString()
	}
	
	$HardwareConnectorAdminSettingCl = Get-SCSMClass -Name HardwareConnector$
	$HardwareConnectorAdminSettingObj = Get-SCSMObject -Class $HardwareConnectorAdminSettingCl
	
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
	$AssetStatusEnumDeployedId = (Get-SCSMEnumeration -Name System.ConfigItem.AssetStatusEnum.Deployed$).id
	$AssetStatusEnumUndefinedId = (Get-SCSMEnumeration -Name System.ConfigItem.AssetStatusEnum.Undefined$).id
	
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
			$LastModified = $iSoftware.LastModified
			
			
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
					"LastModifiedSync" = $LastModified;
				}
				
				$SoftItem = $null
				$SoftItem = New-SCSMObject -Class $ITSMSoftwareClass -PropertyHashtable $iSofthashtable -PassThru
				if ($SoftItem)
				{
					try
					{
						if ($iSoftPublisher.Length -gt 0)
						{
							try
							{
								$PublisherExists = $null
								$PublisherExists = Get-SCSMObject -Class $ITSMPublisherClass | ?{ $_.DisplayName -match $iSoftPublisher }
							}
							Finally
							{
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
										try
										{
											$Key = ($HardwareConnectorAdminSettingObj.Searchkey)
											$env:MS_BingSearch_API_key = "$Key"
											$Uri = 'https://api.cognitive.microsoft.com/bing/v5.0/search?q=' + $($Publisher.PublisherName)
											$Result = Invoke-RestMethod -Uri $Uri -Method 'GET' -ContentType 'application/json' -Headers @{ 'Ocp-Apim-Subscription-Key' = $env:MS_BingSearch_API_key }
											$Url = $Result.webPages.value[0].displayUrl
											$PubUrl = "http://" + $Url
										}
										finally
										{
											Set-SCSMObject -SMObject $Publisher -Property "website" -Value $PubUrl
										}
										
										New-SCSMRelationshipObject -Source $SoftItem -Target $Publisher -Relationship $ITSMSoftHasPubRelCl -Bulk
									}
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
								Set-SCSMObject -SMObject $SoftWareAsset -Property "AssetStatus" -Value $AssetStatusEnumDeployedId
							}
							else
							{
								Set-SCSMObject -SMObject $SoftWareAsset -Property "ReadinessStatus" -Value $NotAvailableStatusEnumId
								Set-SCSMObject -SMObject $SoftWareAsset -Property "AssetStatus" -Value $AssetStatusEnumUndefinedId
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
				$ObjLast = Get-Date -Date $($iSoftExists.LastModifiedSync) -Format "yyyy-MM-dd hh:mm"
				$WinCLast = Get-Date -Date $($iSoftware.LastModified) -Format "yyyy-MM-dd hh:mm"
				
				if ($ObjLast -ne $WinCLast)
				{
					
					try
					{
						$SoftObjs = Get-SCSMObject -Class $SoftwareClass -Filter "DisplayName -eq $($iSoftware.DisplayName)"
						if ($SoftObjs.count -gt 1)
						{
							foreach ($SoftObj in $SoftObjs)
							{
								$iDate = Get-Date -Date $($SoftObj.LastModified) -Format "yyyy-MM-dd hh:mm"
								if ($iDate -eq $ObjLast)
								{
									$IsOtherVersion = $true
								}
							}
						}
						else
						{
							$IsOtherVersion = $false
						}
						
					}
					finally
					{
						if ($IsOtherVersion -ne $true)
						{
							$ObjHistory = $null
							$emg = $null
							
							$emg = New-Object Microsoft.EnterpriseManagement.EnterpriseManagementGroup "localhost"
							$ObjHistory = $emg.EntityObjects.GetObjectHistoryTransactions($iSoftware) | ? { $_.DateOccurred -gt $ObjLast }
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
														Set-SCSMObject -SMObject $iSoftExists -Property $Propery -Value $Value
													}
													catch
													{
														Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Software Connector Cannot Update Object: $iSoftExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
													}
												}
												elseIf ($ChangeType -eq "Modify")
												{
													try
													{
														Set-SCSMObject -SMObject $iSoftExists -Property $Propery -Value $Value
													}
													catch
													{
														Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Software Connector Cannot Update Object: $iSoftExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
													}
												}
												elseif ($ChangeType -eq "Delete")
												{
													try
													{
														Set-SCSMObject -SMObject $iSoftExists -Property $Propery -Value " "
													}
													catch
													{
														Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Software Connector Cannot Update Object: $iSoftExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
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
													Set-SCSMObject -SMObject $iSoftExists -Property $Propery -Value $Value
												}
												catch
												{
													Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Software Connector Cannot Update Object: $iSoftExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
												}
											}
											elseIf ($ChangeType -eq "Modify")
											{
												try
												{
													Set-SCSMObject -SMObject $iSoftExists -Property $Propery -Value $Value
												}
												catch
												{
													Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Software Connector Cannot Update Object: $iSoftExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
												}
											}
											elseif ($ChangeType -eq "Delete")
											{
												try
												{
													Set-SCSMObject -SMObject $iSoftExists -Property $Propery -Value ""
												}
												catch
												{
													Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Software Connector Cannot Update Object: $iSoftExists For Property $Propery with Value: $Value and Method: $ChangeType with Error: $($_.Exception.Message)"
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
												Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Software Connector Cannot Update Object Relationships:$iSoftExists For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
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
												Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Software Connector Cannot Update Object Relationships:$iSoftExists For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
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
												
												Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Software Connector Cannot Update Object Relationships:$iSoftExists For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
												
											}
										}
										
									}
									
								}
							}
							Set-SCSMObject -SMObject $iSoftExists -Property "LastModifiedSync" -Value $LastModified
							
						}
					}
					
					
				}
			}
			
		}
		
	}
	
	
	$Publs = Get-SCSMObject -Class $ITSMPublisherClass
	foreach ($Pub in $Publs)
	{
		Set-SCSMObject -SMObject $Pub -Property "SoftwareCount" -Value "0"
		$SoftCount = $null
		$SoftCount = (Get-SCSMRelationshipObject -bytarget $Pub | ? RelationshipId -eq $ITSMSoftHasPubRelCl.Id).Count
		Set-SCSMObject -SMObject $Pub -property "SoftwareCount" -Value $SoftCount
	}
	
	Set-SCSMObject -SMObject $Connector -Property "Status" -Value $InactiveId
	Set-SCSMObject -SMObject $Connector -Property "LastSynced" -Value (Get-Date)
	Set-SCSMObject -SMObject $Connector -Property "SyncNow" -Value $false
	Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Software Connector Finished Processing Software Objects"
}
# SIG # Begin signature block
# MIIUAAYJKoZIhvcNAQcCoIIT8TCCE+0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUOGwu3VAUbAiDbWLsWuoUTJUk
# D8Oggg60MIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# AYI3AgEEMCMGCSqGSIb3DQEJBDEWBBQzh8V7ZA9tsozo6ZI4PwVAUJ//szANBgkq
# hkiG9w0BAQEFAASCAQB37gpAf3YC7qMEkeh/Ln0xFqmxD/RjhlB4nZ+ZNcgaz4X4
# SjVkPI5oilJKHwy3lTtpCUHUBjDDYQ1Ga5E3s5Ku7N5LLc4ibyI7DXhPONsFX9dc
# gL8c2+cy+xXOgvHB70+izGaeY5Z7UQ5UjVp9JNPp6/cXpX9gEX7UoVoFuP2AP8Xq
# RGD/WLc6XayoRgFLWaIFHa67w2b/Jq9xitfIyEX2yqkATdksSK3e6QvdaqvLkYs5
# VK1ePCa7YNavOHs06gkmhba2DkoKeW2T0x2HR/m+1GJfYMa7pzLW9v6b5QPvUig2
# ryO/0gZqqnVxxet0+ogML4DTq9rqOttHOv7b3DSZoYICojCCAp4GCSqGSIb3DQEJ
# BjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNp
# Z24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0g
# RzICEhEh1pmnZJc+8fhCfukZzFNBFDAJBgUrDgMCGgUAoIH9MBgGCSqGSIb3DQEJ
# AzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2MDgyMTEwNTExOFowIwYJ
# KoZIhvcNAQkEMRYEFFaI9OETPFtHU7J6FdIJi/FFDnOeMIGdBgsqhkiG9w0BCRAC
# DDGBjTCBijCBhzCBhAQUY7gvq2H1g5CWlQULACScUCkz7HkwbDBWpFQwUjELMAkG
# A1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0ds
# b2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh1pmnZJc+8fhCfukZzFNB
# FDANBgkqhkiG9w0BAQEFAASCAQBPwA/WmNOe5jQu/AZ7c5CLq9bG71p03IDDp1X9
# dKULThhuULOiaVBWuE7H522e0kqYs/iIxma8ValND28i40ky5xtqnvVlAUn7m2re
# zaqneeuSWVDUunjgKEgctrM0Zt/Cb/cnQQag6sqEYb1tONA74PwLfo2fPxefro7L
# Buq3EpV9oIYFw/8E7FdE5E+siDmEDujZ0n1xB0mIr77aycGMlrcWrV//PE5RDV9b
# B+Iys/0GXXnvszys8um6Xk6wbko/R4X1gvg/gOuXomeHMF2Pudh9ym5mBH7PYaI8
# ddgU6ZwWnnCItm6RXzF2BOofXiXACOZFmvtzYvqOBmuka+WC
# SIG # End signature block
