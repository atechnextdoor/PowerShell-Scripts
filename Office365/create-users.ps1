#######################################################
#               Created By: Ryon Riley                #
#######################################################

Write-Host "Enter 'A' when prompted after the module install starts." -ForegroundColor "Yellow"
Start-Sleep -s 1

# Set the execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

# Install necessary modules
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name ExchangeOnlineManagement | Out-Null
Install-Module MSOnline | Out-Null

Write-Host "Enter the Office365 account credentials when prompted..." -ForegroundColor "Yellow"
Start-Sleep -s 1

# Connect to the O365 service
Connect-ExchangeOnline -ShowProgress $true | Out-Null

# Enter path to the .csv file
$CSV = Read-Host "Enter the path to the CSV file"

# For each item in the .csv file, create a user account and add to specified groups
Import-Csv -Path $CSV | foreach {
    try {
        New-Mailbox -Name $_.UserPrincipalName.Split("@")[0] -FirstName $_.FirstName -LastName $_.LastName -DisplayName $_.DisplayName -MicrosoftOnlineServicesID $_.UserPrincipalName
        $groupNames = $_.groupNames -split ","
        foreach($group in $groupNames) {
            Add-DistributionGroupMember -Identity $group -Member $_.UserPrincipalName
        }
        Write-Host "User" $_.DisplayName "created successfully." -ForegroundColor "Green"
    }
    catch {
        "An error occured. Check the .csv file formatting and try again."
    }
    Write-Host "All users created successfully." -ForegroundColor "Yellow"
}

Disconnect-ExchangeOnline -Confirm:$false | Out-Null
