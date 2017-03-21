function Get-AzureRmResourceHealth
{
	<#
		.SYNOPSIS
			Return health information for one or more resources in Azure
		.DESCRIPTION
			This function leverages the ResourceHealth API in Azure to return information
			about the various resources within a given subscription. You can narrow the
			scope to a specific resource group, or down to a given resource object, like a VM.
		.PARAMETER SubscriptionId
			A string representing the GUID of a subscription
		.PARAMETER ResourceGroupName
			The name of a Resource Group, this is optional
		.PARAMETER ResourceType
			The type of object, this is optional
		.PARAMETER ResourceName
			The name of the object, this is optional
		.EXAMPLE
			Get-AzureRmResourceHealth


			Name                  : current
			ResourceName          : app-svc-plan01
			ResourceType          : Microsoft.Web/serverFarms
			ResourceGroupName     : AppServicesRG
			ExtensionResourceName : current
			Location              : southcentralus
			Availability          : Available
			Summary               : The App Service plan is running normally
			DetailedStatus        :
			ReasonType            :
			OccuredTime           : 2017-03-16T00:25:00Z
			ReasonChronicity      : Persistent
			ReportedTime          : 2017-03-21T15:28:14.1389029Z

			Name                  : current
			ResourceName          : app-svc-plan02
			ResourceType          : Microsoft.Web/serverFarms
			ResourceGroupName     : AppServicesRG
			ExtensionResourceName : current
			Location              : southcentralus
			Availability          : Available
			Summary               : The App Service plan is running normally
			DetailedStatus        :
			ReasonType            :
			OccuredTime           : 2017-03-16T04:57:30Z
			ReasonChronicity      : Persistent
			ReportedTime          : 2017-03-21T15:28:16.1982473Z

			Description
			-----------
			The default is to return health information for the entire subscription
		.EXAMPLE
			Get-AzureRmResourceHealth -ResourceGroupName ProdVMRG


			Name                  : current
			ResourceName          : prd-vm-01
			ResourceType          : Microsoft.Compute/virtualMachines
			ResourceGroupName     : ProdVMRG
			ExtensionResourceName : current
			Location              : southcentralus
			Availability          : Available
			Summary               : There aren’t any known Azure platform problems affecting this virtual machine
			DetailedStatus        :
			ReasonType            :
			OccuredTime           : 2017-03-20T20:56:00Z
			ReasonChronicity      : Persistent
			ReportedTime          : 2017-03-21T15:21:00Z

			Name                  : current
			ResourceName          : prd-vm-02
			ResourceType          : Microsoft.Compute/virtualMachines
			ResourceGroupName     : ProdVMRG
			ExtensionResourceName : current
			Location              : southcentralus
			Availability          : Available
			Summary               : There aren’t any known Azure platform problems affecting this virtual machine
			DetailedStatus        :
			ReasonType            :
			OccuredTime           : 2017-03-20T20:56:00Z
			ReasonChronicity      : Persistent
			ReportedTime          : 2017-03-21T15:21:00Z

			Description
			-----------
			This example returns informnation from a specific resource group
		.EXAMPLE
			Get-AzureRmResourceHealth -ResourceGroupName AppServicesRG -ResourceType Microsoft.Web/serverFarms -ResourceName app-svc-plan01


			Name                  : current
			ResourceName          : app-svc-plan01
			ResourceType          : Microsoft.Web/serverFarms
			ResourceGroupName     : AppServicesRG
			ExtensionResourceName : current
			Location              : southcentralus
			Availability          : Available
			Summary               : The App Service plan is running normally
			DetailedStatus        :
			ReasonType            :
			OccuredTime           : 2017-03-16T00:25:00Z
			ReasonChronicity      : Persistent
			ReportedTime          : 2017-03-21T15:31:54.9785874Z

			Name                  : 2017-03-16+00%3a20%3a39Z
			ResourceName          : app-svc-plan01
			ResourceType          : Microsoft.Web/serverFarms
			ResourceGroupName     : AppServicesRG
			ExtensionResourceName : 2017-03-16+00%3a20%3a39Z
			Location              : southcentralus
			Availability          : Unknown
			Summary               : We are currently unable to determine the health of your App Service plan
			DetailedStatus        :
			ReasonType            :
			OccuredTime           : 2017-03-16T00:20:39Z
			ReasonChronicity      : Transient
			ReportedTime          :

			Name                  : 2017-03-07+18%3a29%3a32Z
			ResourceName          : app-svc-plan01
			ResourceType          : Microsoft.Web/serverFarms
			ResourceGroupName     : AppServicesRG
			ExtensionResourceName : 2017-03-07+18%3a29%3a32Z
			Location              : southcentralus
			Availability          : Available
			Summary               : The App Service plan is running normally
			DetailedStatus        :
			ReasonType            :
			OccuredTime           : 2017-03-07T18:29:32Z
			ReasonChronicity      : Persistent
			ReportedTime          :

			Description
			-----------
			This example returns information from a specific resource in Azure
		.LINK
			
	#>
	param
	(
		[Parameter(Mandatory=$False,ParameterSetName='strings',Position=1)]
		[string]$SubscriptionId = (Get-AzureRmSubscription).SubscriptionId,
		[Parameter(Mandatory=$False,ParameterSetName='strings',Position=2)]
		[string]$ResourceGroupName,
		[Parameter(Mandatory=$False,ParameterSetName='strings',Position=3)]
		[string]$ResourceType,
		[Parameter(Mandatory=$False,ParameterSetName='strings',Position=4)]
		[string]$ResourceName
	)
	try
	{
		$ErrorActionPreference = 'Stop';
		$Error.Clear();

		$ApiVersion = '2015-01-01';
		
		if ($SubscriptionId)
		{
			$Subscription = Get-AzureRmSubscription -SubscriptionId $SubscriptionId;
			$SubscriptionPart = "/subscriptions/$($Subscription.SubscriptionId)";
		}

		$ResoucrGroupPart = "";
		if ($ResourceGroupName)
		{
			$ResourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName
			$ResoucrGroupPart = "/resourceGroups/$($ResourceGroup.ResourceGroupName)";
		}

		$ResourceProviderPart = "";
		if ($ResourceType)
		{
			$Resource = Get-AzureRmResource -ResourceName $ResourceName -ResourceType $ResourceType -ResourceGroupName $ResourceGroup.ResourceGroupName;
			$ResourceProviderPart = "/providers/$($ResourceType)/$($ResourceName)";
		}

		$ResourceHealthPart = '/providers/Microsoft.ResourceHealth/availabilityStatuses';
		
		$ResourceId = "$($SubscriptionPart)$($ResoucrGroupPart)$($ResourceProviderPart)$($ResourceHealthPart)"

		$resourceHealth = Get-AzureRmResource -ResourceId $ResourceID -ApiVersion $ApiVersion;
		return ($resourceHealth |ForEach-Object {New-Object -TypeName psobject -Property @{
			Name=$_.Name;
			ResourceName=$_.ResourceName;
			ResourceType=$_.ResourceType;
			ExtensionResourceName=$_.ExtensionResourceName;
			ResourceGroupName=$_.ResourceGroupName;
			Location=$_.Location;
			Availability=$_.Properties.availabilityState;
			Summary=$_.Properties.summary;
			DetailedStatus=$_.Properties.detailedStatus;
			ReasonType=$_.Properties.reasonType;
			OccuredTime=$_.Properties.occuredTime;
			ReasonChronicity=$_.Properties.reasonChronicity;
			ReportedTime=$_.Properties.reportedTime;
		}} |Select-Object -Property Name, ResourceName, ResourceType, ResourceGroupName, ExtensionResourceName, Location, Availability, Summary, DetailedStatus, ReasonType, OccuredTime, ReasonChronicity, ReportedTime)
	}
	catch
	{
		throw $_;
	}
}