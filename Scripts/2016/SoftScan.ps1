Import-Module smlets
$wincl= Get-SCSMClass -Name Windows.Computer$
$comps= Get-SCSMObject -Class $wincl
$SoftwareClass=  Get-SCSMClass -Name System.SoftwareItem$
$Active= Get-SCSMEnumeration -Name System.ConfigItem.AssetStatusEnum.Deployed
$HasSoftwareInstalled= Get-SCSMRelationshipClass -Name System.DeviceHasSoftwareItemInstalled$

foreach ($comp in $comps)
{

Try
	{
	$Test= Test-Connection -ComputerName $comp.displayname
	}
catch
	{
	$Test= $null
	}
finally{
	if($Test)
		{
		$Apps = $null
		$Apps= gwmi Win32_Product -ComputerName $comp | ?{$_.InstallState -eq 5}
		

			ForEach ($Software in $Apps)
			{
				$Name= $Software.Name
				$Version= $Software.Version
				$PackageCode= $Software.PackageCode
				[int]$Language= $Software.Language
				$Vendor= $Software.Vendor
				
				$Hashtable= @{
					ProductName= $Name;
					DisplayName= $Name; 
					VersionString= $Version;
					ProductCode= $PackageCode;
					LocaleID= $Language;
					IsVirtualApplication=$false;
					Publisher= $Vendor;
					MajorVersion= $Version
					MinorVersion= $Version
					AssetStatus= $Active
					}
	try{
		$HasBeenInserted=$null
		$HasBeenInserted= Get-SCSMObject -Class $SoftwareClass -Filter "DisplayName -eq '$Name' -and VersionString -eq '$Version'"
		}
	finally{
	if(!$HasBeenInserted){
			
			$NewSoftware=$null
			$NewSoftware= New-SCSMObject -Class $SoftwareClass -PropertyHashtable $Hashtable -PassThru
			$AssignRelationship= New-SCSMRelationshipObject -Relationship $HasSoftwareInstalled -Source $comp -Target $NewSoftware -Bulk	
						 }
	else{
		$GetRel=$null
		$GetRel= Get-SCSMRelationshipObject -BySource $comp |? {$_.TargetObject.DisplayName -eq $HasBeenInserted.DisplayName}
		if(!$GetRel)
			{
			$AssignRelationship= New-SCSMRelationshipObject -Relationship $HasSoftwareInstalled -Source $comp  -Target $HasBeenInserted -Bulk
			}
		}
	
	}
	
	
			}
		}
	}

}