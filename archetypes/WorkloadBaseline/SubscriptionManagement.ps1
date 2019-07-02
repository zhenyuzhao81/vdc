[CmdletBinding()]
param (
[Parameter(Mandatory=$false)]
[string] 
$SubscriptionName,
[Parameter(Mandatory=$false)]
[string] 
$SubscriptionId,
[Parameter(Mandatory=$false)]
[string] 
$TenantId,
[Parameter(Mandatory=$false)]
[string] 
$ManagementGroupName,
[Parameter(Mandatory=$false)]
[string]
$OfferType='MS-AZR-0017P'
)

# TODO: Remove after testing
$TenantId = "b590c310-f80d-4c5b-981f-7dc9c87ea414";
$ManagementGroupName = "Demo-Mgmt-Group";
$SubscriptionName = "Demo-KN";

Function Create-Subscription {
    param (
        [Parameter(Mandatory=$true)]
        [string] $SubscriptionName
    )

    try {
        # Get the Enrollment Account's Object Id for creating 
        # new subscription
        $enrollmentAccountObjectId = `
            (Get-AzEnrollmentAccount)[0].ObjectId;

        # Create a New Subscription
        New-AzSubscription `
            -OfferType $OfferType `
            -Name $SubscriptionName;
            -EnrollmentAccountObjectId $enrollmentAccountObjectId;
    }
    Catch {
        Write-Error "An exception occurred when trying to create a new subscription";
        Write-Errro $_;
        Throw "Error was thrown when attempting to create a new subscription";
    }
}

Function Add-SubscriptionToManagementGroup {
    param (
        [Parameter(Mandatory=$true)]
        [string] $ManagementGroupName,
        [Parameter(Mandatory=$true)]
        [Guid] $SubscriptionId
    )

    try {
        # Check if the Management Group exists
        $managementGroup = `
            Get-AzManagementGroup `
                -GroupName $ManagementGroupName `
                -ErrorAction SilentlyContinue;

        if($null -eq $managementGroup) {

            # Create a new Management Group since it does
            # not exists
            New-AzManagementGroup `
                -GroupName $ManagementGroupName;

            # Add the Subscription to the Management Group
            # that was created in the previous step
            New-AzManagementGroupSubscription `
                -GroupName $ManagementGroupName `
                -SubscriptionId $SubscriptionId;
        }
        else {

            # Add the Subscription to an existing Resource
            # Group
            New-AzManagementGroupSubscription `
                -GroupName $ManagementGrouopName `
                -SubscriptionId $SubscriptionId;
        }
    }
    Catch {
        Write-Error "An exception occurred when trying to associate a subscription to management group";
        Write-Errro $_;
        Throw "Error was thrown when attempting to associate a subscription to management group";
    }
}


# Check if a Subscription Id is provided. If a Subscription
# Id is not provided, create a new subscription.
if([string]::IsNullOrEmpty($SubscriptionId)) {

    $tenant = `
        Get-AzTenant `
            -TenantId  $TenantId;
    
    Set-AzContext -Tenant $tenant;

    # If no Subscription Id is passed, then create
    # a new Subscription
    Create-Subscription `
        -SubscriptionName $SubscriptionName;

}
# If a Subscription Id is provided, use the subscription
else {

    # If a subscription Id is passed, then check if the 
    # subscription exists
    $subscription = `
        Get-AzSubscription `
            -SubscriptionId $SubscriptionId `
            -TenantId $TenantId;

    # If the subscription does not exists, throw exception
    if($null -ne $subscription) {
        Throw "Subscription referenced by Id $SubscriptionId does not exists";
    }

}

# After creating / check for the subsciption by Id, proceed with associating 
# the subscription to management group.
Add-SubscriptionToManagementGroup `
    -ManagementGroupName $ManagementGroupName `
    -SubscriptionId $SubscriptionId;