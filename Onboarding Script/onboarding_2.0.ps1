#Script to Provision New users in AAD, EXO & Admin Center

#function to return remaining number of licenses in tenant
function get-Licenses {
    param (
        $licenseName
    )
    $allLicenses = Get-MgSubscribedSku
    $desiredLicense = $allLicenses | Where-Object { $_.SkuPartNumber -eq $licenseName }
    if ($desiredLicense) {
        # Get the total number of licenses available in the tenant
        $totalLicenses = $desiredLicense.PrepaidUnits.Enabled
    
        # Get the number of licenses assigned to users
        $assignedLicenses = $desiredLicense.ConsumedUnits
    
        # Calculate the remaining licenses
        $remainingLicenses = $totalLicenses - $assignedLicenses
        Write-Output $remainingLicenses
    }
}



#Groups assigned to users during onboarding by IT:
$Groups_E3 = 'CCRM_Combined MFA & SSPR Registration', 'CCRM_Conditional Access Policies_Deployment', 'MFA required', 'C-PRJ-CCRM iLobby', 'MasterControl Enterprise Application', 'MEM_CORP - Automatic Enrollment - Windows', 'CCRM_Licensing_Microsoft Defender for Endpoint P2', 'CCRM_Licensing_Microsoft Enterprise Combo'
$Groups_Business_Prem = 'CCRM_Combined MFA & SSPR Registration', 'CCRM_Conditional Access Policies_Deployment', 'MFA required', 'C-PRJ-CCRM iLobby', 'MasterControl Enterprise Application', 'MEM_CORP - Automatic Enrollment - Windows', 'CCRM_Licensing_Microsoft Defender for Endpoint P2'
#Licenses assigned to users during onboarding by IT
$licenses_team_audio = @{SkuId = "1c27243e-fb4d-42b1-ae8c-fe25c9616588" }
$licenses_Business_Prem = @{SkuId = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46" }

#Connect to Tenant
Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All -NoWelcome

#Get user UPN (Email Address)
$user_name = Read-Host -Prompt "Please enter the Email addresses of the Users being Onboarded"
$domain = ($user_name -split "@")[1]
#Get user's Azure ID
$user_Id = (Get-MgUser -UserId $user_name).id

#Set Licensing Parameters
Update-MgUser -UserId $user_name -UsageLocation "CA"

#Assign Groups to user based on $Groups list
#Write-Host (get-Licenses "ENTERPRISEPACK")
#Write-Host (get-Licenses "SPB")
if (((get-Licenses "ENTERPRISEPACK") -gt 0) -and ((get-Licenses "ATP_ENTERPRISE") -gt 0) -and ((get-Licenses "EMS") -gt 0)) {
    Write-Host "Found E3 Licenses, Adding to E3" -ForegroundColor Cyan
    Write-Host (get-Licenses "ATP_ENTERPRISE") 
    Write-Host (get-Licenses "EMS")

    foreach ($group in $Groups_E3) {
        $group_id = (Get-MgGroup -Filter "startsWith(DisplayName, '$group')").Id
        $group_members = Get-MgGroupMember -All -GroupId $group_id
        New-MgGroupMember -GroupId $group_id -DirectoryObjectId $user_Id
        $check_group_member = $group_members | Where-Object { $_.id -eq $user_Id }
        if ($check_group_member -ne '') {
            Write-Host "Added User to Group '$group'" -ForegroundColor Green
        }
        else {
            Write-Host "Error adding user to '$group'" -ForegroundColor Red
        }
    }
    #Assign Licenses to User
    Set-MgUserLicense -UserId $user_name -AddLicenses $licenses_team_audio -RemoveLicenses @()
    $usersLicenses = Get-MgUserLicenseDetail -All -UserId $user_Id
    $is_License_Assigned = $usersLicenses | Where-Object { $_.SkuId -eq $licenses_team_audio.SkuId } 
    if ($is_License_Assigned) {
        Write-Host "Teams License has been assigned" -ForegroundColor Green
    }
    else {
        Write-Host "Teams License has not been assigned" -ForegroundColor Red
    }
    
}
elseif ((get-Licenses "SPB") -gt 0) {
    Write-Host "Found Bussiness Premium Licenses, adding to BP" -ForegroundColor Cyan
    foreach ($group in $Groups_Business_Prem) {
        $group_id = (Get-MgGroup -Filter "startsWith(DisplayName, '$group')").Id
        $group_members = Get-MgGroupMember -All -GroupId $group_id
        New-MgGroupMember -GroupId $group_id -DirectoryObjectId $user_Id
        $check_group_member = $group_members | Where-Object { $_.Id -eq $user_Id }
        if ($check_group_member) {
            Write-Host "Added User to Group '$group'" -ForegroundColor Green
        }
        else {
            Write-Host "Error adding user to '$group'" -ForegroundColor Red
        }
    }
    #Assign Licenses to User
    Set-MgUserLicense -UserId $user_name -AddLicenses $licenses_team_audio -RemoveLicenses @()
    Set-MgUserLicense -UserId $user_name -AddLicenses $licenses_Business_Prem -RemoveLicenses @()
    $usersLicenses = Get-MgUserLicenseDetail -All -UserId $user_Id
    $is_License_Assigned = $usersLicenses | Where-Object { $_.SkuId -eq $license.SkuId }
    if ($is_License_Assigned) {
        Write-Host "Teams License has been assigned" -ForegroundColor Green
    }
    else {
        Write-Host "Teams License has not been assigned" -ForegroundColor Red
    }
}

else {
    Write-Host "No Licenses Remaining, please add more"
}

if ($domain -eq "omniabio.com" -or $domain -eq "Omniabio.com"){
   & $PSScriptRoot/exchange_provisioning_omniabio.ps1
}
if ($domain -eq "ccrm.ca" -or $domain -eq "CCRM.ca"){
    & $PSScriptRoot/exchange_provisioning_ccrm.ps1
}
