<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.99
	 Created on:   	1/4/2016 5:43 PM
	 Created by:   	 
	 Organization: 	 
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
Import-Module SMLets

$ITSMLicConnectorClass = Get-SCSMClass -Name LicenseSyncConnector$
$Connector = Get-SCSMObject -Class $ITSMLicConnectorClass
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
		$events = [System.Diagnostics.EventLog]::SourceExists("License Connector");
	}
	catch { }
	finally
	{
		if ($events -ne $true)
		{
			New-EventLog -LogName 'Operations Manager' -Source 'License Connector'
			Write-EventLog -LogName 'Operations Manager' -Source 'License Connector' -EventId 10000 -Category 0 -EntryType Information -Message "License Connector Succesfully Create Event Log Source"
		}
		
		Write-EventLog -LogName 'Operations Manager' -Source 'License Connector' -EventId 10000 -Category 0 -EntryType Information -Message "License Connector Start Processing Licensing Objects"
	}
	
	$ErrorID = 10101
	$InfoID = 10100
	$WarningId = 10102
	
	
	#Classes
	$ITSMSoftwareAgreementCl = Get-SCSMClass -Name SoftwareAgreement$
	$ITSMSoftwareCl = Get-SCSMClass -Name Software$
	$ITSMSoftwareAssetCl = Get-SCSMClass -Name SoftwareAsset$
	$ITSMLicensingClassCl = Get-SCSMClass -Name LicenseStatus$
	
	#RelationshipClasses
	$ITSMSoftAssetHasSoftAgreementRelCl = Get-SCSMRelationshipClass -Name Relationship.SoftwareAssetHasAgreement$
	$ITSMSoftAssetHasSoftRelCl = Get-SCSMRelationshipClass -Name Relationship.SoftwareAssetHasSoftware$
	$ITSMLicStatusHasAgreement = Get-SCSMRelationshipClass -Name Relationship.LicStatusIsForSoftwareAgreement$
	$ITSMLicStatusHaSoftware = Get-SCSMRelationshipClass -Name Relationship.LicStatusHasSoftware$
	
	#EnumTypes
	$BaseCalcEnumId = (Get-SCSMEnumeration -Name ManagementScope.BaseLicenseCalculation$).id
	$LicStatusHealthy = (Get-SCSMEnumeration -Name LicStatus.Healthy$).id
	$LicStatusWarning = (Get-SCSMEnumeration -Name LicStatus.Warning).id
	$LicStatusError = (Get-SCSMEnumeration -Name LicStatus.Error$).id
	
	#Main Script
	$AssetForCalc = $null
	$AssetForCalc = Get-SCSMObject -Class $ITSMSoftwareAssetCl -Filter "ManagementScope -eq $BaseCalcEnumId"
	if ($AssetForCalc)
	{
		foreach ($Assets in $AssetForCalc)
		{
			$RelatedAgreements = $null
			$RelatedAgreements += (Get-SCSMRelationshipObject -BySource $Assets | ?{ $_.RelationshipId -eq $ITSMSoftAssetHasSoftAgreementRelCl.id })
			if ($RelatedAgreements)
			{
				[int]$AgreementLicNumber = 0
				[int]$ExpiredLics = 0
				
				foreach ($RelA in $RelatedAgreements)
				{
					$RelatedAgreement = $null
					$RelatedAgreement = $RelA.TargetObject
					
					$RelAgreementObj = $null
					$RelAgreementObj = Get-SCSMObject -Id $RelatedAgreement.Id
					
					[int]$AgreementLicNumber = $AgreementLicNumber + $RelAgreementObj.Quantity
					[DateTime]$AgreementExpirationDate = $RelAgreementObj.ExpirationDate
					[Datetime]$Today = (Get-Date)
					if ($AgreementExpirationDate -lt $Today)
					{
						$ExpiredLics = $ExpiredLics + $RelAgreementObj.Quantity
					}
				}
				
				$RelatedSoft = $null
				$RelatedSoft = (Get-SCSMRelationshipObject -BySource $Assets | ?{ $_.RelationshipId -eq $ITSMSoftAssetHasSoftRelCl.id }).TargetObject
				$RelatedSoftObj = $null
				$RelatedSoftObj = Get-SCSMObject -Id $RelatedSoft.id
				[Int]$InstalledLicNumber = $RelatedSoftObj.Installed
				
				$HashString = $null
				$ObjectHash = $null
				$AvailableLic = $null
				[int]$AvailableLic = $AgreementLicNumber - $InstalledLicNumber
				if ($ExpiredLics)
				{
					$AvailableLic = $AvailableLic - $ExpiredLics
				}
				$HashString = ($AvailableLic.ToString() + $AgreementLicNumber.ToString() + $InstalledLicNumber.ToString() + $($RelatedSoft.DisplayName))
				$ObjectHash = Get-StringHash -String $HashString
				
				$HasAlreadyLicStatus = $null
				$HasAlreadyLicStatus = (Get-SCSMRelationshipObject -ByTarget $RelatedSoft | ?{ $_.RelationshipId -eq $ITSMLicStatusHaSoftware.id }).SourceObject
				if (!$HasAlreadyLicStatus)
				{
					try
					{
						#calcs
						$PercentageInstalled = $null
						$PercentageInstalled = "{0:N2}" -f (($InstalledLicNumber/$AgreementLicNumber) * 100)
						
						if ($PercentageInstalled -lt 100 -and $PercentageInstalled -ge 90)
						{
							$LicStatus = $null
							$Status = $null
							[int]$LicStatus = 2
							$Status = $LicStatusWarning
						}
						elseif ($PercentageInstalled -gt 100)
						{
							$LicStatus = $null
							$Status = $null
							[int]$LicStatus = 1
							$Status = $LicStatusError
						}
						else
						{
							$LicStatus = $null
							$Status = $null
							[int]$LicStatus = 3
							$Status = $LicStatusHealthy
							
						}
						
						
						
						#NewLicObject
						$LicHashTable = $null
						$LicHashTable = @{
							"DisplayName" = $($RelatedSoft.DisplayName) + " License";
							"Used" = $InstalledLicNumber;
							"Installed" = $AgreementLicNumber;
							"Available" = $AvailableLic;
							"LastUpdate" = (Get-Date);
							"GridStat" = $LicStatus;
							"Status" = $Status;
							"LicObjectHash" = $ObjectHash;
							"Expired" = $ExpiredLics;
						}
						
						#create Object
						$LicObj = $null
						$LicObj = New-SCSMObject -Class $ITSMLicensingClassCl -PropertyHashtable $LicHashTable -PassThru
						#create Relationships
						if ($RelatedAgreements)
						{
							foreach ($RelAgg in $RelatedAgreements)
							{
								New-SCSMRelationshipObject -Source $LicObj -Target $RelAgg -Relationship $ITSMLicStatusHasAgreement -Bulk
							}
						}
						
						New-SCSMRelationshipObject -Source $LicObj -Target $RelatedSoftObj -Relationship $ITSMLicStatusHaSoftware -Bulk
						
					}
					catch
					{
						Write-EventLog -LogName 'Operations Manager' -Source 'License Connector' -EventId $WarningId -Category 0 -EntryType Warning -Message "Something Wrong Happened with License Connector while Processing New License Object: $($LicObj.DisplayName) with Exception Message: $($_.Exception.Message) and Exception: $($_.Exception.InnerException)"
					}
					
					
				}
				
				else
				{
					try
					{
						$HasAlreadyLicStatusobj = $null
						$HasAlreadyLicStatusobj = Get-SCSMObject -Id $HasAlreadyLicStatus.id
						
						if ($HasAlreadyLicStatusobj.LicObjectHash -ne $ObjectHash)
						{
							#calcs
							$PercentageInstalled = $null
							$PercentageInstalled = "{0:N2}" -f (($InstalledLicNumber/$AgreementLicNumber) * 100)
							
							if ($PercentageInstalled -lt 100 -and $PercentageInstalled -ge 90)
							{
								$LicStatus = $null
								$Status = $null
								[int]$LicStatus = 2
								$Status = $LicStatusWarning
							}
							elseif ($PercentageInstalled -lt 90)
							{
								$LicStatus = $null
								$Status = $null
								[int]$LicStatus = 3
								$Status = $LicStatusHealthy
							}
							else
							{
								$LicStatus = $null
								$Status = $null
								[int]$LicStatus = 1
								$Status = $LicStatusError
								
							}
							
							
							$UpDLicHashTable = @{
								"Used" = $InstalledLicNumber;
								"Installed" = $AgreementLicNumber;
								"Available" = $AvailableLic;
								"LastUpdate" = (Get-Date);
								"GridStat" = $LicStatus;
								"Status" = $Status;
								"LicObjectHash" = $ObjectHash;
								"Expired" = $ExpiredLics;
							}
							
							Set-SCSMObject -SMObject $HasAlreadyLicStatusobj -PropertyHashtable $UpDLicHashTable
							
							#Check Relationships
							if ($RelatedAgreements)
							{
								foreach ($ARelAgg in $RelatedAgreements)
								{
									$HasAgreementAlreadyAssigned = $null
									$HasAgreementAlreadyAssigned = Get-SCSMRelationshipObject -BySource $HasAlreadyLicStatusobj | ? { ($_.RelationshipId -eq $ITSMLicStatusHasAgreement.id) -and ($_.SourceObject.id -eq $ARelAgg.id) }
									if (!$HasAgreementAlreadyAssigned)
									{
										New-SCSMRelationshipObject -Source $HasAlreadyLicStatusobj -Target $ARelAgg -Relationship $ITSMLicStatusHasAgreement -Bulk
										
									}
								}
								
							}
							
						}
						
					}
					catch
					{
						Write-EventLog -LogName 'Operations Manager' -Source 'License Connector' -EventId $WarningId -Category 0 -EntryType Warning -Message "Something Wrong Happened with License Connector while Processing Already Exists License Object: $($HasAlreadyLicStatus.DisplayName) with Exception Message: $($_.Exception.Message) and Exception: $($_.Exception.InnerException)"
					}
					
				}
			}
			
		}
		
		
	}
	
	Set-SCSMObject -SMObject $Connector -Property "Status" -Value $InactiveId
	Set-SCSMObject -SMObject $Connector -Property "LastSynced" -Value (Get-Date)
	Set-SCSMObject -SMObject $Connector -Property "SyncNow" -Value $false
	Write-EventLog -LogName 'Operations Manager' -Source 'License Connector' -EventId 10000 -Category 0 -EntryType Information -Message "License Connector Finished Processing Software Assets and Agreements Objects"
}
