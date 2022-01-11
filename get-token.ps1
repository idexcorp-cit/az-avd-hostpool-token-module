$json = [Console]::In.ReadLine()

$object = $json | ConvertFrom-Json

$secret = ConvertTo-SecureString -String $env:ARM_CLIENT_SECRET -AsPlainText -Force;
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $env:ARM_CLIENT_ID, $secret;
if(-not(Get-InstalledModule Az -ErrorAction SilentlyContinue)) {
    Install-Module Az.Accounts -Confirm:$False -Force | Out-Null;
    Install-Module Az.DesktopVirtualization -Confirm:$False -Force | Out-Null;
};
Connect-AzAccount -ServicePrincipal -TenantId $env:ARM_TENANT_ID -Credential $credential -SubscriptionId $env:ARM_SUBSCRIPTION_ID -WarningAction Ignore | Out-Null;
$registrationInfo = Get-AzWvdRegistrationInfo -ResourceGroupName  $object.resourceGroupName -HostPoolName $object.hostPoolName -SubscriptionId $object.subscriptionId
if((Get-Date) -gt $registrationInfo.ExpirationTime) {
    $newRegistrationInfo = New-AzWvdRegistrationInfo -ExpirationTime $((Get-Date).ToUniversalTime().AddHours($object.tokenValidHours).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ')) -ResourceGroupName $object.resourceGroupName -HostPoolName $object.hostPoolName -SubscriptionId $object.subscriptionId    
    $token = $newRegistrationInfo.Token
    $expirationTime = $newRegistrationInfo.ExpirationTime
} else {
    $token = $registrationInfo.Token
    $expirationTime = $registrationInfo.ExpirationTime
}

Write-Output "{ ""token"" : ""$token"", ""expiration_time"" : ""$expirationTime"" }"