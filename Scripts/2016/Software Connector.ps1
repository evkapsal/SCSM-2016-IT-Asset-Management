
#NOTES
#===========================================================================
#Created with:  SAPIEN Technologies, Inc., PowerShell Studio 2015
#Created on:    13/5/2017 24:00 PM
#Created by:     Evangelos Kapsalakis
#Organization:   Microsoft Hellas
#Filename:  Software Connector V5.1
#===========================================================================
#.DESCRIPTION
#This Script proccesing Software Items from SCSM CMDB

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
		   $iCSoft= $iSoftName.Replace($iSoftVersion,"")
		   
		   [string]$HashString = ($iCSoft + $iSoftPublisher + $iSoftwareProductCode)
		   $iSoftHash = Get-StringHash -String $HashString
		   
		   $iSoftExists = (Get-SCSMObject -Class $ITSMSoftwareClass -Filter "ObjectHash -eq '$iSoftHash' and ObjectStatus -ne '$PendingDeleteEnumId'")
		   if (!$iSoftExists)
		   {
		    
			    $iSofthashtable = $null
			    $iSofthashtable = @{
							     "DisplayName" = $iCSoft;
							     "SoftwareName" = $iSoftName;
							     "ProductCode" = $iSoftwareProductCode;
							     "LastDiscoveredDate" = (Get-Date);
							     "ObjectHash" = $iSoftHash;
							     "Installed" = $iSoftInstalledCount;
							     "LastModifiedSync" = $LastModified;
							    }
		    	#Create Soft Item
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
									           $Result = Invoke-RestMethod -Uri $Uri -Method 'GET' -ContentType 'application/json' -Headers @{'Ocp-Apim-Subscription-Key' = $env:MS_BingSearch_API_key }
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
				        $VerForSoft = (Get-SCSMRelationshipObject -BySource $Version | ? { RelationshipId -eq $($ITSMSoftHasVersionRelCl.id) }).TargetObject
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
			   #Process Changes
			     try
			     {
				 	$ObjLast =$null   	
			    	$ObjLast = Get-Date -Date $($iSoftExists.LastModifiedSync) -Format "yyyy-MM-dd hh:mm"
			      	$SoftObjs = Get-SCSMObject -Class $SoftwareClass -Filter "DisplayName -eq $($iSoftware.DisplayName)"
			      }   
			     finally
			     {
			       $ObjHistory = $null
			       $emg = $null
			       
			       $emg = New-Object Microsoft.EnterpriseManagement.EnterpriseManagementGroup "localhost"
			       $ObjHistory = $emg.EntityObjects.GetObjectHistoryTransactions($iSoftware) 
			       foreach ($ObjHist in $ObjHistory)
			       {
				   	if((Get-Date -Date $ObjHist.DateOccurred.Date -Format "yyyy-MM-dd hh:mm") -gt $ObjLast )
					{
				        try
				        {
				         $PropertyChanges = $null
				         $RelationshipChanges = $null
				         
				         $PropertyChanges = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges
				         $RelationshipChanges = $ObjHist.ObjectHistory.Values.RelationshipHistory
				        }
				        Catch
				        {
				         $PropertyChanges = $null
				         $RelationshipChanges = $null
				        }
				        Finally
				        {
								if($PropertyChanges -or $RelationshipChanges)
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
						           	try {
							           $Propery = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges.Key
							           $Value = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges.Value
							           $ChangeType = $ObjHist.ObjectHistory.Values.ClassHistory.PropertyChanges.ChangeType
							           }
									finally{
												if($ChangeType)
														{
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
						          
									try{
								          $Srcs = Get-SCSMObject -Id $SourceObj
										  $Srcn= (Get-SCSMRelationshipObject -ByTarget $Srcs | ? {$_.SourceObject.ManagementPackClassIds -eq "2e3768dc-30bb-acd6-6877-077e3806efdf"}).SourceObject
										  $Src= (Get-SCSMRelationshipObject -ByTarget $Srcn | ? {$_.RelationshipID -eq "22dc3c89-1634-c792-3373-637ddc3cbaa9"}).SourceObject
								          $Tars = Get-SCSMObject -Id $TargetObj
										  $Tar= (Get-SCSMRelationshipObject -ByTarget $Tars | ? {$_.SourceObject.ManagementPackClassIds -eq "bde5f9f4-f8f5-92f3-c37c-03c61f412718"}).SourceObject
								          $Rel = Get-SCSMRelationshipClass -Name Relationship.SoftwareIsInstalledOnHardwareAsset$
									  	}
									catch{}
									finally
							        {
									  if($Src -and $Tar -and $Rel)
									  	{
								          if ($RChangeType -eq "Insert")
								          {
								           try
								           {
										   $alreayinserted = $null
										   $alreayinserted= Get-SCSMRelationshipObject -ByTarget $Src | ? {$_.SourceObject -eq $Tar}
											   if(!$alreayinserted)
											    {
									            New-SCSMRelationshipObject -Source $Tar -Target $Src -Relationship $Rel -Bulk
												$iTar= Get-SCSMObject -Id $Tar.Id
												Set-SCSMObject -SMObject $Tar -Property "Installed" -Value ($($iTar.Installed) + 1)
												Set-SCSMObject -SMObject $Tar -Property "LastDiscoveredDate" -Value (Get-Date)
												$SftVrs= (Get-SCSMRelationshipObject -ByTarget $Tar | ? {$_.RelationshipId -eq "8c4fc188-a99a-d7cb-deba-ef0a3199d637"}).SourceObject
												if ($SftVrs)
													{
													$iSftVrs= Get-SCSMObject -Id $SftVrs.id
													New-SCSMRelationshipObject -Source $iSftVrs -Target $Src -Relationship $VersionIsForAsset -Bulk
													Set-SCSMObject -SMObject $SftVrs -Property "Installed" -Value ($iSftVrs.Installed + 1)
													}
												}
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
								            New-SCSMRelationshipObject -Source $Tar -Target $Src -Relationship $Rel -Bulk
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
								            Get-SCSMRelationshipObject -BySource $Tar | ? {$_.TargetObject -eq $Src } | Remove-SCSMRelationshipObject
											$iTar= Get-SCSMObject -Id $Tar.Id
											Set-SCSMObject -SMObject $Tar -Property "Installed" -Value ($($iTar.Installed) - 1)
											Set-SCSMObject -SMObject $Tar -Property "LastDiscoveredDate" -Value (Get-Date)
											
											$SftVrs= (Get-SCSMRelationshipObject -ByTarget $Tar | ? {$_.RelationshipId -eq "8c4fc188-a99a-d7cb-deba-ef0a3199d637"}).SourceObject
											if ($SftVrs)
													{
													$iSftVrs= Get-SCSMObject -Id $SftVrs.id
													Get-SCSMRelationshipObject -bySource $iSftVrs | ?{$_.TargetObject -eq $Src} | Remove-SCSMRelationshipObject
													Set-SCSMObject -SMObject $SftVrs -Property "Installed" -Value ($iSftVrs.Installed - 1)
													}
											
								           }
								           catch
								           {
								            
								            Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId $ErrorID -Category 0 -EntryType Error -Message "Software Connector Cannot Update Object Relationships:$iSoftExists For Relationship:$Rel with Source:$Src and Target:$Tar for Change Type:$ChangeType with Error: $($_.Exception.Message)"
								            
								           }
								          }
							          	}
									}
						         }
						        }
						}
				    }
				   }
			       Set-SCSMObject -SMObject $iSoftExists -Property "LastModifiedSync" -Value $LastModified
			     }
			    
				 #Process Version
				 if ($iSoftVersion.Length -gt 0)
			     {
				       $VersionHashStr = $null
				       $VersionHash = $null
				       $Version = $null
				       
				       $VersionHashStr = $iSoftHash + $iSoftVersion
				       $VersionHash = Get-StringHash -String $VersionHashStr
				       $Version = Get-SCSMObject -Class $ITSMVersionClass -Filter "VersionHash -eq $VersionHash"
				       if (!$Version)
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
								New-SCSMRelationshipObject -Source $iSoftExists -Target $iSoftware -Relationship $ConfigItemRelCl -Bulk
								$iMSoftIsInstall = Get-SCSMRelationshipObject -ByTarget $iSoftware  | ? { ($_.RelationShipId -eq $SoftwareRelCl.id )}
								$iCount = (measure-object -InputObject $iMSoftIsInstall).Count
						       	Set-SCSMObject -SMObject $Version -Property "Installed" -Value $iCount
						       	$FinalCount = $iSoftExists.Installed + $Count
						       	Set-SCSMObject -SMObject $iSoftExists -Property "Installed" -Value $FinalCount
								foreach($Objs in $iMSoftIsInstall.SourceObject)
								{
								$HW= (Get-SCSMRelationshipObject -ByTarget $Objs | ? {$_.RelationshipId -eq "4448664f-b657-407a-cdbe-b7433af0ccdb"}).SourceObject
								$ASST= (Get-SCSMRelationshipObject -ByTarget $HW | ? {$_.RelationshipId -eq "22dc3c89-1634-c792-3373-637ddc3cbaa9"}).SourceObject
								New-SCSMRelationshipObject -Source $Version -Target $ASST -Relationship $VersionIsForAsset -Bulk
								New-SCSMRelationshipObject -Source $iSoftExists -Target $ASST -Relationship $ITSMSoftIsForHardwareAssetRelCl -Bulk
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
		  $SoftCount = (Get-SCSMRelationshipObject -bytarget $Pub | ? {$_.RelationshipId -eq $($ITSMSoftHasPubRelCl.Id)}).Count
		  Set-SCSMObject -SMObject $Pub -property "SoftwareCount" -Value $SoftCount
	 }
 
 Set-SCSMObject -SMObject $Connector -Property "Status" -Value $InactiveId
 Set-SCSMObject -SMObject $Connector -Property "LastSynced" -Value (Get-Date)
 Set-SCSMObject -SMObject $Connector -Property "SyncNow" -Value $false
 Write-EventLog -LogName 'Operations Manager' -Source 'Software Connector' -EventId 10000 -Category 0 -EntryType Information -Message "Software Connector Finished Processing Software Objects"
}
