FUNCTION ResetPassword

{

#Declare Variables

$DomainUser =
$DomainPassword =
$DC = 
$DN =

#First Run Things

if(!$Skip){Import-Module ActiveDirectory}

clear-host
Write-Host -ForegroundColor Cyan "This module will reset a user's AD Account password to 'PasswordX' where 'X' is a randomly generated number between 0-99"
Write-Host -ForegroundColor Cyan "It will help if you already know the SAMAccountName of the user, but I'll help you find them if not"
Write-Host -ForegroundColor Cyan "Note: The SAMAccountName is the account name a user authenticates with"
if($Skip -eq "Y"){clear-host}
if(!$Skip){Pause}
clear-host

#Get new password

$RNG = get-random -Maximum 99
$SecurePassword = ConvertTo-SecureString $DomainPassword -AsPlainText -Force
$DomainCredential = New-Object System.Management.Automation.PSCredential ($DomainUser, $SecurePassword)

$Q1 = Read-Host "Do you know the SAM account name of the target user? Y/N"
if($Q1 -eq 'Y'){
    #Reset Password
    Write-Host "Would you like the user to change their password on next logon?"
    $Change = Read-Host "Y/N"
    if($Change -eq "Y"){Write-Host "User will be prompted for password change upon next logon"}
    elseif($Change -eq "N"){write-host "Password will be reset without a prompt for the user to change it"}
    else{Write-Error "Unhandled input, resetting module"
    Start-Sleep -Seconds 1
    ResetPassword}
    write-host "Please enter the SAM Account name of the user"
    $User = Read-Host "Username"
    Write-Progress -Activity "Fetching Object and resetting password..."
    get-aduser -identity "$User" -server $DC -Credential $DomainCredential  | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "Password$RNG" -Force) -server $DC -Credential $DomainCredential
    if($Change -eq "Y"){Set-aduser $User -changepasswordatlogon $true -server $DC -Credential $DomainCredential}
    Write-Host -ForegroundColor Green "Password reset successful, new password is Password$RNG"
    Pause
    exit
}
elseif($Q1 -eq 'N'){
    #Search forest by surname
    Write-Host "Please enter the user's surname"
    $Search = Read-Host "Surname"
    Write-Progress -Activity "Searching AD for objects like $Search"
    get-aduser -filter "samaccountname -like '*$search*'" -SearchBase $DN -server $DC -Credential $DomainCredential
write-host "Did you find the account?"
$Confirm = Read-host "Y/N"
if($Confirm -eq "Y"){Write-Host "Excellent! Let's go back to the first question so you can use the SAMAccountName you've found"
Start-Sleep -Seconds 2
$Skip = "Y"
Clear-Host
ResetPassword}

elseif($Confirm -eq 'N'){
    #Search forest by first name
    Write-Host "Let's try the first name instead"
$Search2 = Read-Host "Please enter the user's first name"
Write-Progress -Activity "Searching AD for objects like $Search2"
get-aduser -filter "name -like '*$search2*'" -SearchBase $DN -server $DC -Credential $DomainCredential
Pause
Write-host "Please note the SAMAccountName, and we'll try to reset the Password"
Start-Sleep -Seconds 2
$Skip = "Y"
ResetPassword
}
}
#Idiot proofing
if($confirm -ne "Y" -or "N"){Write-Error "Unhandled input, resetting module"
Start-Sleep -Seconds 1
ResetPassword}
if($Q1 -ne "Y" -or "N"){Write-Error "Unhandled input, resetting module"
Start-Sleep -Seconds 1
ResetPassword}
}


