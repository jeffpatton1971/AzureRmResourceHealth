function Get-AzureRmResourceHealth
{
	param
	(
		[Parameter(Mandatory=$True,ParameterSetName='strings',Position=1)]
		[string]$SubscriptionId,
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