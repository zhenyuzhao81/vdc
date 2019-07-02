Param(
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionName,
    [Parameter(Mandatory=$false)]
    [string]
    $OfferType = "MS-AZR-0017P"
)

New-AzSubscription `
    -Name $SubscriptionName `
    -EnrollmentAccountObjectId ((Get-AzEnrollmentAccount)[0].ObjectId) `
    -OfferType $OfferType;