#Script to provision new Regular users in Azure AD

#Start
$Groups = 'CCRM_Combined MFA & SSPR Registration', 'CCRM_Conditional Access Policies_Deployment', 'MFA required', 'C-PRJ-CCRM iLobby', 'MasterControl Enterprise Application', 'MEM_CORP - Automatic Enrollment - Windows', 'CCRM_Licensing_Microsoft Defender for Endpoint P2',  'CCRM_Licensing_Microsoft Enterprise Combo'#, 'Exclude from MFA'
#Start-Transcript -Path "C:\Users\FarnadKazemzadeh\ONB_transcript\reg_user_transcript.txt" -Append
Connect-AzureAD 
Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All -NoWelcome


#A. Getting Information
$UserName = Read-Host -Prompt "Please Type the Email address of the user"

#B. Get User Azure Id 
$id = (Get-MgUser -UserId $UserName).id

#C. Set Usage Location (required for licensing)
Update-MgUser -UserId $UserName -UsageLocation "CA"

#D. Add user to predefined groups, List will need to be editted as  groups get added / removed
##### UNIFIED LABELING is currently not added as its a protected group, manually add until I solve
foreach ($group in $Groups) {
    Try {
    $groupid = (Get-MgGroup -Filter "startsWith(DisplayName, '$group')").id 
    New-MgGroupMember -GroupId $groupid -DirectoryObjectId $id
    }
    Catch {
        Write-Host "Error adding user to group '$group' " -ForegroundColor Orange
    }
    Write-Host "Added user to group '$group'" -ForegroundColor Green 
}

#E. Add Licensing to user, If licensing changes, edit the list up top.
####Currently Only Manual addition is Teams Dial out, rest are inherited from Groups
Try {
Set-MgUserLicense -UserId $UserName -AddLicenses @{SkuId = "1c27243e-fb4d-42b1-ae8c-fe25c9616588"} -RemoveLicenses @()
}
Catch {
    Write-Error "Error adding license"
}
Write-Host "License Added" -ForegroundColor Green 


Write-Host "Sleeping 10 seconds to allow MS servers to Sync Mailbox license" -ForegroundColor Green 
Start-Sleep -Seconds 10

& $PSScriptRoot/exchange_provisioning.ps1

Start-Sleep -Seconds 5

####### Write-Host "ADD USER TO CCRM_Microsoft 365 Unified Labeling Manually For now" -ForegroundColor Cyan
# $groupid = (Get-MgGroup -Filter "startsWith(DisplayName, 'CCRM_Microsoft 365 Unified Labeling')").id 
# New-MgGroupMember -GroupId $groupid -DirectoryObjectId $id
# Write-Host "Added user to group CCRM_Microsoft 365 Unified Labeling" -ForegroundColor Green 

Start-Sleep -Seconds 5