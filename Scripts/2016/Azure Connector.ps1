Import-Module Smlets
Import-Module Azure
Import-Module AzureRM.Resources
Import-Module AzureRM.Compute
Import-Module AzureRM.Profile
Import-Module Azure.Storage


#Object Classes
$AzureVMCl = Get-SCSMClass -Name AzureVM$  #-ComputerName $SCSMSrv -Credential $creds
$AzureNet = Get-SCSMClass -Name AzureNet$ #-ComputerName $SCSMSrv -Credential $creds
$AzureNetGW = Get-SCSMClass -Name AzureVNetGateway$ #-ComputerName $SCSMSrv -Credential $creds
$AzureSubnet = Get-SCSMClass -Name AzureSubnet$ #-ComputerName $SCSMSrv -Credential $creds
$AzureLocation = Get-SCSMClass -Name AzureLocation$ #-ComputerName $SCSMSrv -Credential $creds
$AzureSubscription = Get-SCSMClass -Name AzureSubscription$ #-ComputerName $SCSMSrv -Credential $creds
$AzureResourceGroupCL = Get-SCSMClass -Name AzureResourceGroup$
$AzureConsumptionCL = Get-SCSMClass -Name AzureConsumption$
$azureSQLDBCl = Get-SCSMClass -Name AzureSQLDatabase$
$AzureSQLServer = Get-SCSMClass -Name AzureSQLServer$
$AzureWebAppCl = Get-SCSMClass -Name AzureWebApp$

#Relationship Classes
$AzureSubscriptionHaAdminUser = Get-SCSMRelationshipClass -Name Relationship.AzureSubscriptionHaAdminUser$
$AzureNetHasSubnet = Get-SCSMRelationshipClass -Name Relationship.AzureNetHasSubnet$
$AzureNetHasGatewaySubnet = Get-SCSMRelationshipClass -Name Relationship.AzureNetHasGatewaySubnet$
$AzureResourceGroupHasLocation = Get-SCSMRelationshipClass -Name Relationship.AzureResourceGroupHasLocation$
$AzureSubscriptionHasResourceGroup = Get-SCSMRelationshipClass -Name Relationship.AzureSubscriptionHasResourceGroup$
$AzureResourceGroupHasAzureVMs = Get-SCSMRelationshipClass -Name Relationship.AzureResourceGroupHasAzureVMs$
$AzureVMsHasSubnet = Get-SCSMRelationshipClass -Name Relationship.AzureVMsHasSubnet$
$AzureLocationHasNLocation = Get-SCSMRelationshipClass -Name Relationship.AzureLocationHasNLocation$
$AzureGatewayHasConsumption = Get-SCSMRelationshipClass -Name Relationship.AzureGatewayHasConsumption$
$AzureVMHasConsumption = Get-SCSMRelationshipClass -Name Relationship.AzureVMHasConsumption$
$AzureSubscriptionHasConsumption = Get-SCSMRelationshipClass -Name Relationship.AzureSubscriptionHasConsumption$
$AzureSQLServerHasDatabase = Get-SCSMRelationshipClass -Name Relationship.AzureSQLServerHasDatabase$
$AzureResourceGroupHasSQLServer = Get-SCSMRelationshipClass -Name Relationship.AzureResourceGroupHasSQLServer$
$AzureSQLDatabaseHasConsumption = Get-SCSMRelationshipClass -Name Relationship.AzureSQLDatabaseHasConsumption$
$AzureSQLServerHasLocation = Get-SCSMRelationshipClass -Name Relationship.AzureSQLServerHasLocation$
$AzureResourceGroupHasWebApplication = Get-SCSMRelationshipClass -Name Relationship.AzureResourceGroupHasWebApplication$
$AzureWebApplicationHasLocation = Get-SCSMRelationshipClass -Name Relationship.AzureWebApplicationHasLocation$
$AzureWebApplicationHasConsumption = Get-SCSMRelationshipClass -Name Relationship.AzureWebApplicationHasConsumption$
$AzureResourceGroupHasNetwork = Get-SCSMRelationshipClass -Name Relationship.AzureResourceGroupHasNetwork$








#
#function Get-AzureVMConsumption
#{
#	
#	param
#	(
#		[parameter(Mandatory = $true)]
#		[guid]$iTenantID,
#		[parameter(Mandatory = $true)]
#		[guid]$isubscriptionid,
#		[parameter(Mandatory = $true)]
#		[date]$reportedStartTime,
#		[parameter(Mandatory = $true)]
#		[date]$reportedEndTime,
#		[parameter(Mandatory = $true)]
#		$cred		
#		
#	)
#	
#	Add-AzureAccount
#	
#	#Choose subscription 'old' Azure
#	$subscriptionid = $isubscriptionid
#	
#	
#	# Set date range for exported usage data
#	$reportedTime = New-TimeSpan –Start $reportedStartTime –End $reportedEndTime
#	#here------>
#	$StartTimeInt = 0
#	$EndTimeInt = $reportedTime.Days - 1
#	$results1 = @()
#	
#	
#	# Set path to exported CSV file
#	#$filename = "$env:USERPROFILE\Desktop\usageData-${subscriptionId}-${reportedStartTime}-${reportedEndTime}.csv"
#	
#	# Set Azure AD Tenant for selected Azure Subscription
#	$adTenant = $iTenantID
#	
#	Login-AzureRmAccount -Credential $cred -ServicePrincipal -TenantId $adTenant | Out-Null
#	
#	# Set parameter values for Azure AD auth to REST API
#	$clientId = "1950a258-227b-4e31-a9cf-717495945fc2" # Well-known client ID for Azure PowerShell
#	$redirectUri = "urn:ietf:wg:oauth:2.0:oob" # Redirect URI for Azure PowerShell
#	$resourceAppIdURI = "https://management.core.windows.net/" # Resource URI for REST API
#	$authority = "https://login.windows.net/$adTenant" # Azure AD Tenant Authority
#	
#	# Load ADAL Assemblies
#	$adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
#	$adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
#	
#	Add-Type -Path $adal
#	Add-Type -Path $adalforms
#	
#	# Create Authentication Context tied to Azure AD Tenant
#	$authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
#	
#	# Acquire Azure AD token
#	$authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId, $redirectUri, "Auto")
#	
#	# Create Authorization Header
#	$authHeader = $authResult.CreateAuthorizationHeader()
#	
#	# Set REST API parameters
#	$apiVersion = "2015-06-01-preview"
#	$granularity = "Daily" # Can be Hourly or Daily
#	$showDetails = "true"
#	$contentType = "application/json;charset=utf-8"
#	
#	# Set HTTP request headers to include Authorization header
#	$requestHeader = @{ "Authorization" = $authHeader }
#	
#	Do
#	{
#		
#		# Set initial URI for calling Billing REST API
#		$uri = "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.Commerce/UsageAggregates?api-version=$apiVersion&reportedStartTime=$newStartTime&reportedEndTime=$newEndTime&aggregationGranularity=$granularity&showDetails=$showDetails"
#		
#		# Get all usage data in raw format
#		$usageData = Invoke-RestMethod -Uri $Uri -Method Get -Headers $requestHeader -ContentType $contentType
#		$AzureVMs = Find-AzureRmResource -ExpandProperties | ? { $_.ResourceType -match 'Compute' }
#		$AzureVMUses = $usageData.value.properties | ? { $_.meterCategory -eq 'Virtual Machines' -and $_.infofields -match "project" }
#		$projects = $AzureVMUses
#		foreach ($AzureVMUse in $AzureVMUses)
#		{
#			
#			$x = new-object psObject | select elementType, elementName, aliasName, sampleTime, totalTime
#			
#			$x.elementType = $AzureVMUse.infoFields.meteredServiceType
#			$x.elementName = $AzureVMUse.meterSubCategory
#			$x.aliasName = $AzureVMUse.infoFields.project
#			$x.sampleTime = $AzureVMUse.usageStartTime
#			$x.totalTime = $AzureVMUse.quantity
#			
#			$Results1 += $x
#		}
#		
#		$newStartTime = $newEndTime.AddDays(1)
#		$newEndTime = $newStartTime.AddDays(1)
#		
#	}
#	until ($newEndTime -eq (Get-Date -Date $reportedEndTime) -or $newStartTime -eq (Get-Date -Date $reportedEndTime))
#	
#	$Results1 | Export-Csv -notypeinformation -Path $filename
#	
#	
#	
#}


#if ((get-date).Day -eq 1)
#{
#	$startdate = (Get-date).AddMonths(-1)
#	$enddate = (Get-date).AddDays(-1)
#	Get-AzureVMConsumption -iTenantID $te
#}

$AzureConnectorClass = Get-SCSMClass -Name AzureConnector$ #-ComputerName $SCSMSrv -Credential $creds

$AzureConnectorObj = Get-SCSMObject -Class $AzureConnectorClass #-ComputerName $SCSMSrv -Credential $creds
if ($AzureConnectorObj.IsActive -eq $true)
{
	$AzureAppId = $AzureConnectorObj.CredentialsPath
	$AzureKey = $AzureConnectorObj.CredentialsKey
	$AzureTenantId = $AzureConnectorObj.TenantID
	
	$pass = ConvertTo-SecureString $AzureKey -AsPlainText –Force
	$cred = New-Object -TypeName pscredential –ArgumentList $AzureAppId, $pass
	Login-AzureRmAccount -Credential $cred -ServicePrincipal -TenantId $AzureTenantId | Out-Null
	
	$subs = Get-AzureRmSubscription -TenantId $AzureTenantId
	foreach ($sub in $subs)
	{
		Select-AzureRmSubscription -SubscriptionId $($sub.Id) | Out-Null
		
		try
		{
			$AzureITSMSubscription = $null
			$AzureITSMSubscription = Get-SCSMObject -Class $AzureSubscription -Filter "SubscriptionId -eq $($sub.Id)" #-ComputerName $SCSMSrv -Credential $creds
		}
		catch
		{
			$AzureITSMSubscription = $null
		}
		finally
		{
			if (!$AzureITSMSubscription)
			{
				$SubObjHash = @{
					"SubscriptionName" = $($sub.Name);
					"SubscriptionId"   = $($sub.id);
					"Environment"	  = "Production";
					"IsDefault"	    = $true;
				}
				
				$AzureITSMSubscription = New-SCSMObject -Class $AzureSubscription -PropertyHashtable $SubObjHash -PassThru #-ComputerName $SCSMSrv -Credential $creds
			}
		}
		
		
		#Process Virtual Networks
		$AzVNetResources = $null
		$AzVNetResources = Get-AzureRmResource | ?{ $_.ResourceType -eq "Microsoft.Network/virtualNetworks" }
		foreach ($AzVNetResource in $AzVNetResources)
		{
			
			$AzureNetResourceGroup = $null
			$AzureNetResourceGroup = $AzVNetResource.ResourceGroupName
			
			try
			{
				$AzureITSMVnetResourceGroup = $null
				$AzureITSMVnetResourceGroup = Get-SCSMObject -Class $AzureResourceGroupCL -Filter "Name -eq $($AzureNetResourceGroup)"
				
			}
			catch
			{
				$AzureITSMVnetResourceGroup = $null
			}
			finally
			{
				
				if (!$AzureITSMVnetResourceGroup)
				{
					$AzRg = $null
					$AzRg = Get-AzureRmResourceGroup -Name $AzVNetResource.ResourceGroupName
					$AzureResHashTable = @{
						"DisplayName"	   = $($AzRg.ResourceGroupName);
						"ResourceName"	  = $($AzRg.ResourceGroupName);
						"ResourceId"	    = $($AzRg.ResourceId);
						"ProvisioningState" = $($AzRg.ProvisioningState);
					}
					
					$AzureITSMVnetResourceGroup = $null
					$AzureITSMVnetResourceGroup = New-SCSMObject -Class $AzureResourceGroupCL -PropertyHashtable $AzureResHashTable -PassThru
					New-SCSMRelationshipObject -Source $AzureITSMSubscription -Target $AzureITSMVnetResourceGroup -Relationship $AzureSubscriptionHasResourceGroup -Bulk
					
					try
					{
						$AzITSMLocation = $null
						$AzITSMLocation = Get-SCSMObject -Class $AzureLocation -Filter "LocationName -eq $($AzRg.Location)"
						
					}
					catch
					{
						
					}
					finally
					{
						if (!$AzITSMLocation)
						{
							$AzLocHashtable = $null
							$AzLocHashtable = @{
								
								"LocationName" = $($AzRg.Location);
								"DisplayName"  = $($AzRg.Location);
							}
							$AzITSMLocation = New-SCSMObject -Class $AzureLocation -PropertyHashtable $AzLocHashtable -PassThru
							New-SCSMRelationshipObject -Source $AzureITSMVnetResourceGroup -Target $AzITSMLocation -Relationship $AzureResourceGroupHasLocation -Bulk
							
						}
						
						else
						{
							New-SCSMRelationshipObject -Source $AzureITSMVnetResourceGroup -Target $AzITSMLocation -Relationship $AzureResourceGroupHasLocation -Bulk
							
						}
					}
					
				}
				
				if ($AzureITSMVnetResourceGroup)
				{
					$AzureITSMVNet = $null
					$AzureITSMVNet = Get-SCSMObject -Class $AzureNet -Filter "NetworkName -eq $($AzVNetResource.Name)"
					if (!$AzureITSMVNet)
					{
						$AzureVNet = $null
						$AzureVNet = Get-AzureRmVirtualNetwork -ResourceGroupName $($AzVNetResource.ResourceGroupName) -Name $($AzVNetResource.Name)
						#Build DNS [string] Variable
						try
						{
							$DnsAddrs = $null
							$DnsAddrs = $AzureVNet.DhcpOptions.DnsServers
							if ($DnsAddrs)
							{
								[string]$DNS = $null
								foreach ($DnsAddr in $DnsAddrs)
								{
									
									[string]$DNS += $DnsAddr + " "
									
								}
								$DNS = $DNS.Replace(" ", ",")
							}
							else { $DNS = "NOT PRESENT" }
						}
						catch
						{
							
						}
						#Build IP Address [string] Variable
						try
						{
							$IPAddrs = $null
							$IPAddrs = $AzureVNet.AddressSpace.AddressPrefixes
							if ($IPAddrs)
							{
								[string]$IPAdd = $null
								foreach ($IPAddr in $IPAddrs)
								{
									
									$IPAdd += $IPAddr
								}
							}
							else { $IPAdd = "NOT PRESENT" }
						}
						catch
						{
							
						}
						
						$VnetHashtable = @{
							
							"NetworkName"		  = $($AzureVNet.Name);
							"Location"			 = $($AzureVNet.Location);
							"DisplayName"		  = $($AzureVNet.Name);
							"id"				   = $($AzureVNet.ResourceGuid);
							"AddressSpacePrefixes" = $IPAdd;
							"DnsServers"		   = $DNS;
							"State"			    = $($AzureVNet.ProvisioningState);
							
						}
						
						$AzureITSMVNet = New-SCSMObject -Class $AzureNet -PropertyHashtable $VnetHashtable -PassThru
						New-SCSMRelationshipObject -Source $AzureITSMVnetResourceGroup -Target $AzureITSMVNet -Relationship $AzureResourceGroupHasNetwork -Bulk
						
						try
						{
							$Subnets = $null
							$Subnets = $AzureVNet.Subnets
							if ($Subnets)
							{
								foreach ($Subnet in $Subnets)
								{
									$AzureITSMSubnet = $null
									$AzureITSMSubnet = Get-SCSMObject -Class $AzureSubnet -Filter "SubnetName -eq $($Subnet.Name)"
									if (!$AzureITSMSubnet)
									{
										if ($($Subnet.Id) -like "*GatewaySubnet*")
										{
											[bool]$IsGateway = $true
										}
										else { [bool]$IsGateway = $false }
										
										
										$SubnetHashTable = @{
											"SubnetName"	  = $($Subnet.Name);
											"DisplayName"	 = $($Subnet.Name);
											"AddressPrefix"   = $($Subnet.AddressPrefix);
											"IsGatewaySubnet" = $IsGateway;
											
										}
										
										$AzureITSMSubnet = New-SCSMObject -Class $AzureSubnet -PropertyHashtable $SubnetHashTable -PassThru
										New-SCSMRelationshipObject -Source $AzureITSMVNet -Target $AzureITSMSubnet -Relationship $AzureNetHasSubnet -Bulk
										
									}
									else
									{
										
										try
										{
											$HasSubnetalready = $null
											$HasSubnetalready = Get-SCSMRelationshipObject -ByTarget $AzureITSMSubnet | ? { ($_.RelationshipId -eq "$($AzureNetHasSubnet.id)") -and ($_.SourceObject -eq "$($AzureITSMVNet)") }
											if (!$HasSubnetalready)
											{
												New-SCSMRelationshipObject -Source $AzureITSMVNet -Target $AzureITSMSubnet -Relationship $AzureNetHasSubnet -Bulk
											}
										}
										catch
										{
											
										}
									}
									
									
									
									
								}
							}
							
							$AZNetGw = $null
							$AZNetGw = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $AzureNetResourceGroup
							if ($AZNetGw)
							{
								try
								{
									$ITSMVnetGw = $null
									$ITSMVnetGw = Get-SCSMObject -Class $AzureNetGW -Filter "GatewayName -eq $($AZNetGw.Name) "
								}
								catch
								{
								}
								finally
								{
									if (!$ITSMVnetGw)
									{
										$GwPubIpCfgId = $null
										$GwPubIpCfgId = $AZNetGw.IpConfigurations.publicipaddress.id
										$PublicIp = $null
										$PublicIp = (Get-AzureRmPublicIpAddress -ResourceGroupName $AzureNetResourceGroup | ? { $_.id -eq $GwPubIpCfgId }).IpAddress
										$GwSKU = $null
										$GwSKU = $AZNetGw.Sku.Tier
										
										
										$ITSMVnetGeHashTable = @{
											
											"GatewayName"	 = $($AZNetGw.Name);
											"DisplayName"	 = $($AZNetGw.Name);
											"GatewaySKU"	  = $GwSKU;
											"OperationStatus" = $($AZNetGw.ProvisioningState);
											"VIPAddress"	  = $PublicIp;
											"DefaultSite"	 = $($AZNetGw.GatewayDefaultSite);
											"GatewayType"	 = $($AZNetGw.GatewayType);
											
										}
										
										$ITSMVnetGateway = New-SCSMObject -Class $AzureNetGW -PropertyHashtable $ITSMVnetGeHashTable -PassThru
										New-SCSMRelationshipObject -Source $AzureITSMVNet -Target $ITSMVnetGateway -Relationship $AzureNetHasGatewaySubnet -Bulk
										
									}
									
								}
								
								
								
							}
						}
						catch
						{
							
						}
						
						
						
					}
					
					
				}
				
				
				
			}
			
			
			
			
			
		}
		
		
		
		#Process Azure  VMs
		$AzVMResources = $null
		$AzVMResources = Get-AzureRmResource | ?{ $_.ResourceType -eq "Microsoft.Compute/virtualMachines" }
		foreach ($AzVMResource in $AzVMResources)
		{
			$RGName = $null
			$RGVmName = $null
			$AzureRmVM = $null
			$RGName = $AzVMResource.ResourceGroupName
			$RGVmName = $AzVMResource.Name
			
			try
			{
				$AzureITSVMResourceGroup = $null
				$AzureITSVMResourceGroup = Get-SCSMObject -Class $AzureResourceGroupCL -Filter "ResourceName -eq $RGName"
				
			}
			catch
			{
			}
			finally
			{
				
				if (!$AzureITSVMResourceGroup)
				{
					$AzRg = $null
					$AzRg = Get-AzureRmResourceGroup -Name $RGName
					
					$AzureResHashTable = $null
					$AzureResHashTable = @{
						"DisplayName"	   = $($AzRg.ResourceGroupName);
						"ResourceName"	  = $($AzRg.ResourceGroupName);
						"ResourceId"	    = $($AzRg.ResourceId);
						"ProvisioningState" = $($AzRg.ProvisioningState);
					}
					
					$AzureITSVMResourceGroup = New-SCSMObject -Class $AzureResourceGroupCL -PropertyHashtable $AzureResHashTable -PassThru
					New-SCSMRelationshipObject -Source $AzureITSMSubscription -Target $AzureITSVMResourceGroup -Relationship $AzureSubscriptionHasResourceGroup -Bulk
					
					try
					{
						$AzITSMLocation = Get-SCSMObject -Class $AzureLocation -Filter "LocationName -eq $($AzRg.Location)"
						
					}
					catch
					{
						
					}
					finally
					{
						if (!$AzITSMLocation)
						{
							$AzLocHashtable = @{
								
								"LocationName" = $($AzRg.Location);
								"DisplayName"  = $($AzRg.Location);
							}
							$AzITSMLocation = New-SCSMObject -Class $AzureLocation -PropertyHashtable $AzLocHashtable -PassThru
							New-SCSMRelationshipObject -Source $AzureITSVMResourceGroup -Target $AzITSMLocation -Relationship $AzureResourceGroupHasLocation -Bulk
							
						}
						
						else
						{
							New-SCSMRelationshipObject -Source $AzureITSVMResourceGroup -Target $AzITSMLocation -Relationship $AzureResourceGroupHasLocation -Bulk
							
						}
					}
					
					
					
					
				}
				
				$AzureRmVM = Get-AzureRMVM -ResourceGroupName $($AzureITSVMResourceGroup.ResourceName) -Name $RGVmName
				if ($AzureRmVM)
				{
					Try
					{
						$AzureITSMVM = $null
						$AzureITSMVM = Get-SCSMObject -Class $AzureVMCl -Filter "VMName -eq $($AzureRmVM.Name) "
					}
					Catch
					{
						
					}
					Finally
					{
						if (!$AzureITSMVM)
						{
							$Nic = $null
							$Nic = Get-AzureRmNetworkInterface -ResourceGroupName $($AzureITSVMResourceGroup.ResourceName) | ? { ($_.VirtualMachine.Id -eq $($AzureRmVM.id)) -and ($_.Primary -eq $true) }
							if ($Nic)
							{
								#AzureVMPublicIP
								$VMPBIP = $null
								$VMPBIP = (Get-AzureRmPublicIpAddress -ResourceGroupName $($AzureITSVMResourceGroup.ResourceName) | ? { $_.id -eq $($Nic.IpConfigurations.PublicIpAddress.id) }).IpAddress
								$SubnetRM = $null
								$SubnetRM = ((Get-AzureRmVirtualNetwork -ResourceGroupName $($AzureITSVMResourceGroup.ResourceName)).Subnets | ? { $_.Id -eq $($Nic.IpConfigurations.subnet.id) }).Name
								if ($SubnetRM)
								{
									$AzureITSMSubnet = $null
									$AzureITSMSubnet = Get-SCSMObject -Class $AzureSubnet -Filter "SubnetName -eq $SubnetRM"
									If (!$AzureITSMSubnet)
									{
										
										$Subnet = $null
										$Subnet = ((Get-AzureRmVirtualNetwork -ResourceGroupName $RGVmName).Subnets | ? { $_.Id -eq $($Nic.IpConfigurations.subnet.id) })
										$SubnetHashTable = $null
										$SubnetHashTable = @{
											"SubnetName"	  = $($Subnet.Name);
											"DisplayName"	 = $($Subnet.Name);
											"AddressPrefix"   = $($Subnet.AddressPrefix);
											"IsGatewaySubnet" = $IsGateway;
											
										}
										
										$AzureITSMSubnet = New-SCSMObject -Class $AzureSubnet -PropertyHashtable $SubnetHashTable -PassThru
										New-SCSMRelationshipObject -Source $AzureITSMVNet -Target $AzureITSMSubnet -Relationship $AzureNetHasSubnet -Bulk
										
									}
								}
							}
							
							$AzureITSMVMHashTable = @{
								"VMName"		  = $($AzureRmVM.Name);
								"InstanceSize"    = $($AzureRmVM.HardwareProfile.VMsize);
								"OperatingSystem" = $($AzureRmVM.StorageProfile.ImageReference.Sku);
								"VMHDPath"	    = $($AzureRmVM.StorageProfile.OsDisk.Vhd.Uri);
								"IPAddress"	   = $($Nic.IpConfigurations.PrivateIpAddress);
								"PublicIPAddress" = $VMPBIP;
								"PowerState"	  = $(($AzureRmVM | Get-AzureRmVM -Status).Statuses[1].DisplayStatus)
								"status"		  = $($AzureRmVM.ProvisioningState);
								"DisplayName"	 = $($AzureRmVM.Name);
								
							}
							
							$AzureITSMVM = New-SCSMObject -Class $AzureVMCl -PropertyHashtable $AzureITSMVMHashTable -PassThru
							New-SCSMRelationshipObject -Source $AzureITSVMResourceGroup -Target $AzureITSMVM -Relationship $AzureResourceGroupHasAzureVMs -Bulk
							New-SCSMRelationshipObject -Source $AzureITSMVM -Target $AzureITSMSubnet -Relationship $AzureVMsHasSubnet -Bulk
							
						}
					}
					
					
				}
				
				
				
			}
		}
		
		
		#Process Azure SQL PaaS
		$AzSQLSrvResources = $null
		$AzSQLSrvResources = Get-AzureRmResource | ? { $_.ResourceType -eq "Microsoft.Sql/servers" }
		foreach ($AzSQLSrvResource in $AzSQLSrvResources)
		{
			try
			{
				$AzureITSQLResourceGroup = $null
				$AzureITSQLResourceGroup = Get-SCSMObject -Class $AzureResourceGroupCL -Filter "ResourceName -eq $($AzSQLSrvResource.ResourceGroupName)"
			}
			catch
			{
			}
			finally
			{
				
				if (!$AzureITSQLResourceGroup)
				{
					$AzSRg = $null
					$AzSRg = Get-AzureRmResourceGroup -Name $($AzSQLSrvResource.ResourceGroupName)
					
					$AzureSQLResHashTable = $null
					$AzureSQLResHashTable = @{
						"DisplayName"	   = $($AzSRg.ResourceGroupName);
						"ResourceName"	  = $($AzSRg.ResourceGroupName);
						"ResourceId"	    = $($AzSRg.ResourceId);
						"ProvisioningState" = $($AzSRg.ProvisioningState);
					}
					
					$AzureITSQLResourceGroup = New-SCSMObject -Class $AzureResourceGroupCL -PropertyHashtable $AzureSQLResHashTable -PassThru
					New-SCSMRelationshipObject -Source $AzureITSMSubscription -Target $AzureITSQLResourceGroup -Relationship $AzureSubscriptionHasResourceGroup -Bulk
					
					
					try
					{
						$AzITSMLocation = $null
						$AzITSMLocation = Get-SCSMObject -Class $AzureLocation -Filter "LocationName -eq $($AzSRg.Location)"
						
					}
					catch
					{
						
					}
					finally
					{
						if (!$AzITSMLocation)
						{
							$AzLocHashtable = $null
							$AzLocHashtable = @{
								
								"LocationName" = $($AzSRg.Location);
								"DisplayName"  = $($AzSRg.Location);
							}
							$AzITSMLocation = New-SCSMObject -Class $AzureLocation -PropertyHashtable $AzLocHashtable -PassThru
							New-SCSMRelationshipObject -Source $AzureITSQLResourceGroup -Target $AzITSMLocation -Relationship $AzureResourceGroupHasLocation -Bulk
							
						}
						
						else
						{
							New-SCSMRelationshipObject -Source $AzureITSQLResourceGroup -Target $AzITSMLocation -Relationship $AzureResourceGroupHasLocation -Bulk
							
						}
					}
				}
				
				$AzSQLSrvs = Get-AzureRmSqlServer -ResourceGroupName $($AzSQLSrvResource.ResourceGroupName)
				foreach ($AzSQLSrv in $AzSQLSrvs)
				{
					
					try
					{
						$ITSMSQLServer = Get-SCSMObject -Class $AzureSQLServer -Filter "SQLServerName -eq $($AzSQLSrvResource.ServerName)"
						
					}
					catch
					{
					}
					finally
					{
						if (!$ITSMSQLServer)
						{
							
							$AzSQLHashTbl = @{
								
								"SQLServerName"		 = $($AzSQLSrv.ServerName);
								"DisplayName"		   = $($AzSQLSrv.ServerName);
								"ServerVersion"		 = $($AzSQLSrv.ServerVersion);
								"SqlAdministratorLogin" = $($AzSQLSrv.SqlAdministratorLogin);
								
							}
							
							$ITSMSQLServer = New-SCSMObject -Class $AzureSQLServer -PropertyHashtable $AzSQLHashTbl -PassThru
							New-SCSMRelationshipObject -Source $AzureITSQLResourceGroup -Target $ITSMSQLServer -Relationship $AzureResourceGroupHasSQLServer -Bulk
							New-SCSMRelationshipObject -Source $ITSMSQLServer -Target $AzITSMLocation -Relationship $AzureSQLServerHasLocation -Bulk
							
						}
					}
					
					
					$AzSQLDBs = Get-AzureRmSqlDatabase -ServerName $($ITSMSQLServer.SQLServerName) -ResourceGroupName $($AzureITSQLResourceGroup.ResourceName)
					foreach ($AzSQLDB in $AzSQLDBs)
					{
						try
						{
							$ITSMSQLDB = $null
							$ITSMSQLDB = Get-SCSMObject -Class $azureSQLDBCl -Filter "DatabaseName -eq $($AzSQLDB.DatabaseName)"
						}
						catch { }
						Finally
						{
							if (!$ITSMSQLDB)
							{
								
								if ($AzSQLDB.DatabaseName -ne "master")
								{
									$DataMasking = $null
									$Masking = $null
									
									$DataMasking = ((Get-AzureRmSqlDatabaseDataMaskingPolicy -ServerName $($ITSMSQLServer.SQLServerName) -DatabaseName $($AzSQLDB.DatabaseName) -ResourceGroupName $($AzureITSQLResourceGroup.ResourceName)).DataMaskingState).ToString()
									switch ($DataMasking)
									{
										"Disabled" { $Masking = $false }
										"Enabled" { $Masking = $true }
									}
									switch ($AzSQLDB.ReadScale)
									{
										"Disabled" { $ReadS = $false }
										"Enabled" { $ReadS = $true }
									}
									$SQLConnectionString = $null
									$SQLConnectionString = (Get-AzureRmSqlDatabaseSecureConnectionPolicy -ServerName $($ITSMSQLServer.SQLServerName) -DatabaseName $($AzSQLDB.DatabaseName) -ResourceGroupName $($AzureITSQLResourceGroup.ResourceName)).ConnectionStrings.AdoNetConnectionString
									$SQLProxyDNS = $null
									$SQLProxyDNS = (Get-AzureRmSqlDatabaseSecureConnectionPolicy -ServerName $($ITSMSQLServer.SQLServerName) -DatabaseName $($AzSQLDB.DatabaseName) -ResourceGroupName $($AzureITSQLResourceGroup.ResourceName)).ProxyDnsName
									$SQLProxyPort = $null
									$SQLProxyPort = (Get-AzureRmSqlDatabaseSecureConnectionPolicy -ServerName $($ITSMSQLServer.SQLServerName) -DatabaseName $($AzSQLDB.DatabaseName) -ResourceGroupName $($AzureITSQLResourceGroup.ResourceName)).ProxyPort
									
									$SQLDbHashtbl = $null
									$SQLDbHashtbl = @{
										"DatabaseName"	  = $($AzSQLDB.DatabaseName);
										"DisplayName"	   = $($AzSQLDB.DatabaseName);
										"DatabaseId"	    = $($AzSQLDB.DatabaseId);
										"Edition"		   = ($($AzSQLDB.Edition)).ToString();
										"CollationName"	 = $($AzSQLDB.CollationName);
										"MaxSizeBytes"	  = $($AzSQLDB.MaxSizeBytes);
										"Status"		    = $($AzSQLDB.Status);
										"CreationDate"	  = $($AzSQLDB.CreationDate);
										"ReadScale"		 = $ReadS;
										"DataMaskingState"  = $Masking;
										"ProxyDnsName"	  = $SQLProxyDNS;
										"ConnectionStrings" = $SQLConnectionString;
										"ProxyPort"		 = $SQLProxyPort;
									}
									
									$ITSMSQLDB = New-SCSMObject -Class $azureSQLDBCl -PropertyHashtable $SQLDbHashtbl -PassThru
									New-SCSMRelationshipObject -Source $ITSMSQLServer -Target $ITSMSQLDB -Relationship $AzureSQLServerHasDatabase -Bulk
								}
							}
						}
						
						
					}
					
				}
			}
			
			
			
			
		}
		
		
		
		#Process Azure Web Apps
		$AzWebAppResources = $null
		$AzWebAppResources = Get-AzureRmResource | ? { $_.ResourceType -eq "Microsoft.Web/sites" }
		foreach ($AzWebAppResource in $AzWebAppResources)
		{
			try
			{
				$AzureWebResourceGroup = $null
				$AzureWebResourceGroup = Get-SCSMObject -Class $AzureResourceGroupCL -Filter "ResourceName -eq $($AzWebAppResource.ResourceGroupName)"
			}
			catch
			{}
			finally
			{
				if (!$AzureWebResourceGroup)
				{
					
					$AzSRg = $null
					$AzSRg = Get-AzureRmResourceGroup -Name $($AzWebAppResource.ResourceGroupName)
					
					$AzureWebResHashTable = $null
					$AzureWebResHashTable = @{
						"DisplayName"	   = $($AzSRg.ResourceGroupName);
						"ResourceName"	  = $($AzSRg.ResourceGroupName);
						"ResourceId"	    = $($AzSRg.ResourceId);
						"ProvisioningState" = $($AzSRg.ProvisioningState);
					}
					
					$AzureWebResourceGroup = New-SCSMObject -Class $AzureResourceGroupCL -PropertyHashtable $AzureWebResHashTable -PassThru
					New-SCSMRelationshipObject -Source $AzureITSMSubscription -Target $AzureWebResourceGroup -Relationship $AzureSubscriptionHasResourceGroup -Bulk
					
					
					try
					{
						$AzITSMLocation = $null
						$AzITSMLocation = Get-SCSMObject -Class $AzureLocation -Filter "LocationName -eq $($AzSRg.Location)"
						
					}
					catch
					{
						
					}
					finally
					{
						if (!$AzITSMLocation)
						{
							$AzLocHashtable = $null
							$AzLocHashtable = @{
								
								"LocationName" = $($AzSRg.Location);
								"DisplayName"  = $($AzSRg.Location);
							}
							$AzITSMLocation = New-SCSMObject -Class $AzureLocation -PropertyHashtable $AzLocHashtable -PassThru
							New-SCSMRelationshipObject -Source $AzureWebResourceGroup -Target $AzITSMLocation -Relationship $AzureResourceGroupHasLocation -Bulk
							
						}
						
						else
						{
							New-SCSMRelationshipObject -Source $AzureWebResourceGroup -Target $AzITSMLocation -Relationship $AzureResourceGroupHasLocation -Bulk
							
						}
					}
				}
				
				$AzureWebApps=$null
				$AzureWebApps = Get-AzureRmWebApp -ResourceGroupName $($AzureWebResourceGroup.ResourceName)
				
				foreach ($AzureWebApp in $AzureWebApps)
				{
					$AzureITSMWebApp =$null
					$AzureITSMWebApp = Get-SCSMObject -Class $AzureWebAppCl -Filter "SiteName -eq $($AzureWebApps.SiteName)"
					if (!$AzureITSMWebApp)
					{
						$AzureWebHasTbl = @{
							
							"SiteName"	= $($AzureWebApp.SiteName);
							"HostNames" = $($AzureWebApp.HostNames);
							"RepositorySiteName" = $($AzureWebApp.RepositorySiteName);
							"UsageState" = $($AzureWebApp.UsageState).ToString();
							"AvailabilityState" = $($AzureWebApp.AvailabilityState).ToString();
							"State" = $($AzureWebApp.State);
							"LastModifiedTimeUtc" = $($AzureWebApp.LastModifiedTimeUtc);
							"Enabled" = $($AzureWebApp.Enabled);
							"ClientAffinityEnabled" = $($AzureWebApp.ClientAffinityEnabled);
							"OutboundIpAddresses" = $($AzureWebApp.OutboundIpAddresses);
							"DefaultHostName" = $($AzureWebApp.DefaultHostName);
							
						}
						
						$AzureITSMWebApp = New-SCSMObject -Class $AzureWebAppCl -PropertyHashtable $AzureWebHasTbl -PassThru
						New-SCSMRelationshipObject -Source $AzureWebResourceGroup -Target $AzureITSMWebApp -Relationship $AzureResourceGroupHasWebApplication -Bulk
						New-SCSMRelationshipObject -Source $AzureITSMWebApp -Target $AzITSMLocation -Relationship $AzureWebApplicationHasLocation -Bulk
						
					}
					
				}
				
			}
			
			
		}
		
	}
	
	
	
}


