#######################################################
#               Created By: Ryon Riley                #
#######################################################

# Set the execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

# Install necessary modules
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name ExchangeOnlineManagement -Confirm:$false | Out-Null
Install-Module -Name MSOnline -Confirm:$false | Out-Null

Write-Host "Enter the Office365 account credentials when prompted..." -ForegroundColor "Yellow"
Start-Sleep -s 1

# Get O365 admin credentials
$UserCredential = Get-Credential

# Connect to the O365 service
Connect-ExchangeOnline -Credential $UserCredential

# Enter path to the .csv file
$CSV = Read-Host "Enter the path to the CSV file"

# For each item in the .csv file, create a user account and add to specified groups
Import-Csv -Path $CSV | foreach {
    try {
        New-Mailbox -Name $_.UserPrincipalName.Split("@")[0] -FirstName $_.FirstName -LastName $_.LastName -DisplayName $_.DisplayName -MicrosoftOnlineServicesID $_.UserPrincipalName | Out-Null
        $groupNames = $_.groupNames -split ","
        foreach($group in $groupNames) {
            Add-DistributionGroupMember -Identity $group -Member $_.UserPrincipalName
        }
        Write-Host "User" $_.DisplayName "created successfully." -ForegroundColor "Green"
    }
    catch {
        "An error occured. Either the user already exists or check the .csv file formatting and try again."
    }
    Write-Host "All users created successfully." -ForegroundColor "Yellow"
}

<#

Connect-MsolService -Credential $UserCredential

# Get current licensing information
$prefix = (Get-MsolAccountSku).AccountSkuId.Split(":")[0]
$licensing = (Get-MsolAccountSku).AccountSkuId

Import-Csv -Path $CSV | foreach {
    try {
        Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -AddLicenses $_.AccountSkuId
    }
        Write-Host "User" $_.DisplayName "assigned license" $_.AccountSkuId "successfully" -ForegroundColor "Green"
    catch {
        "An error occured. Check the .csv file formatting and try again."
    }
    Write-Host "All users updated successfully." -ForegroundColor "Yellow"
}

#>

Disconnect-ExchangeOnline -Confirm:$false | Out-Null