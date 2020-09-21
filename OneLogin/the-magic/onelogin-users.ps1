#######################################################
#         Requirements: PowerShell 5 or later         #
#               Created By: Ryon Riley                #
#######################################################

# Starting script text
Write-Host "Starting script, please wait..." -ForeGroundColor Yellow
Start-Sleep -s 1

# Install the OneLogin PS Module
Write-Host "Installing the OneLogin module..." -ForegroundColor Yellow
Install-Module OneLogin -Confirm:$False

# Import the module
Write-Host "Importing the OneLogin module..." -ForegroundColor Yellow
Import-Module OneLogin

# Clear screen
Write-Host "Done. Let's get started!" -ForegroundColor Green
Start-Sleep -s 1
Clear-Host

# Change directories
Set-Location "$PSScriptRoot\..\"
$CurrentLoc = Get-Location
$host.ui.RawUI.WindowTitle = "Current Location: $CurrentLoc"

# Link to create API credentials
Write-Host "Get the API Credential Pair using these instructions: https://bit.ly/olapi" -ForegroundColor DarkCyan

# Specify OneLogin credentials (Client ID[username] & Secret[password])
$username = Read-Host -Prompt "Enter your Client ID"
$pass = Read-Host -Prompt "Enter your Client Secret"

if ($username -ne "" -and $pass -ne "") {
    $password = ConvertTo-SecureString "$pass" -AsPlainText -Force
    $OLCred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)

    # Connect to OneLogin
    Connect-OneLogin -Credential $OLCred -Region us
}
else {
    Write-Host "You must enter a Client ID and Secret, try again..." -ForeGroundColor Red
    Start-Sleep -s 1
    Exit
}

# Function to get all users & save to .csv
function retrieve-users {
    Set-Location "$PSScriptRoot\..\output-files"
    $outputDir = Get-Location
    Write-Host "Saving file 'user-data.csv' to: $outputDir, and printing out table below:" -ForegroundColor Yellow
    Get-OneLoginUser -All | Select-Object -Property email, id, firstname, lastname, status_value | Export-Csv -Path .\user-data.csv -NoTypeInformation
    Get-OneLoginUser -All | Select-Object -Property email, id, firstname, lastname, status_value | Format-Table

    $Total = (Import-Csv "$PSScriptRoot\..\output-files\user-data.csv").count
    Write-Host "Total users: $Total `n" -ForegroundColor Green

    # Set Location back to .csv location
    Set-Location "$PSScriptRoot\..\"
}

# Function to add users
function add-users {
    # Retrieve CSV path
    Write-Host "Make sure your .csv has columns named firstname, lastname, email, and username" -ForegroundColor DarkCyan
    $CSVPath = Read-Host -Prompt "Specify the path of the .csv file"

     # Test path of csv
    $TestPath = Test-Path $CSVPath -ErrorAction SilentlyContinue

    if ($TestPath -eq $True) {
        # Import CSV
        $csv = Import-Csv -Path $CSVPath

        # Create each user
        foreach ($item in $csv) {
            # Check if user exists
            $CheckUser = Get-OneLoginUser -Filter @{email = $item.email}

            if ($CheckUser -eq $null) {
                Write-Host "Creating user:"$item.email"" -ForegroundColor Yellow
                New-OneLoginUser $item.firstname $item.lastname $item.email $item.username | Out-Null
            }
            else {
                Write-Host "User"$item.email"already exists!" -ForegroundColor Red
            }
        }
        Write-Host "All users have been created or already exist! `n" -ForegroundColor Green
    }
    else {
        Write-Host "Check your csv path and try again. `n" -ForeGroundColor Red
    }
}

# Function to deactivate users
function deactivate-users {
    # Retrieve CSV path
    $CSVPath = Read-Host -Prompt "Specify the path of the .csv file"

     # Test path of csv
    $TestPath = Test-Path $CSVPath -ErrorAction SilentlyContinue

    if ($TestPath -eq $True) {
        # Import CSV and add data to array
        $csv = Import-Csv -Path $CSVPath

        # Run Logoff & Lockout on each user
        foreach ($item in $csv) {
            # Get status of user
            $UserStatus = (Get-OneLoginUser -Filter @{email = $item.email}).Status
            $User = Get-OneLoginUser -Filter @{email = $item.email}

            if ($UserStatus -ne "3" -and $User -ne $null) {
                Write-Host "Deactivating user:"$item.email"" -ForegroundColor Yellow
                $User | Invoke-OneLoginUserLogoff -Confirm:$False
                $User | Invoke-OneLoginUserLockout -Confirm:$False
            }
            else {
                Write-Host "User"$item.email"was already deactivated or doesn't exist!" -ForegroundColor Red
            }
        }
            Write-Host "All users have been deactivated or already were! `n" -ForegroundColor Green
        }
    else {
        Write-Host "Check your csv path and try again. `n" -ForeGroundColor Red
    }
}

# Function to add users
function delete-users {
    # Retrieve CSV path
    Write-Host "Make sure your .csv has a column named email!" -ForegroundColor DarkCyan
    Write-Warning "Double check your csv path before entering!"
    $CSVPath = Read-Host -Prompt "Specify the path of the .csv file"

    # Test path of csv
    $TestPath = Test-Path $CSVPath -ErrorAction SilentlyContinue

    if ($TestPath -eq $True) {
        # Import csv
        $csv = Import-Csv -Path $CSVPath

        # Remove each user
        foreach ($item in $csv) {
            # Check if user exists
            $CheckUser = Get-OneLoginUser -Filter @{email = $item.email}
            
            if ($CheckUser -ne $null) {
                Write-Host "Removing user:"$item.email"" -ForegroundColor Yellow
                $User = Get-OneLoginUser -Filter @{email = $item.email}
                $User | Remove-OneLoginUser -Confirm:$False
            }
            else {
                Write-Host "User"$item.email"already removed!" -ForegroundColor Red
            }
        }
        Write-Host "All users have been removed or already are gone! `n" -ForegroundColor Green
    }
    else {
        Write-Host "Check your csv path and try again. `n" -ForeGroundColor Red
    }
}

# Determine what you want to do
while (($decision = Read-Host -Prompt "What would you like to do? [get/add/deactivate/remove/quit]") -ne "quit") {
    switch ($decision) {
        "get" {retrieve-users}
        "add" {add-users}
        "deactivate" {deactivate-users}
        "remove" {delete-users}
        "quit" {exit}
        default {Write-Host "Pick an action: get, add, deactivate, remove, or quit! `n" -ForegroundColor Red}
    }
}
