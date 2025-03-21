#Script to provision new users in Azure AD 

#Start
$Groups = 'CCRM_Combined MFA & SSPR Registration', 'CCRM_Conditional Access Policies_Deployment', 'MFA required', 'C-PRJ-CCRM iLobby', 'MasterControl Enterprise Application', 'MEM_CORP - Automatic Enrollment - Windows' #, 'Exclude from MFA'
#Start-Transcript -Path "C:\Users\FarnadKazemzadeh\ONB_transcript\transcript.txt" -Append
Connect-AzureAD 
Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All -NoWelcome

#A. Getting Information
$UserName = Read-Host -Prompt 'Please Type the Email address of the user'


#B. Get User info
##1. Azure Id

$id = (Get-MgUser -UserId $UserName).id
##2. User UPN

####FOR NOW THIS IS JUST $UserName

#C. Set Usage Location (required for licensing)
Update-MgUser -UserId $UserName -UsageLocation "CA"


#D. Add user to  groups, List will need to be editted as  groups get added / removed
foreach ($group in $Groups) {
    $groupid = (Get-MgGroup -Filter "startsWith(DisplayName, '$group')").id
    New-MgGroupMember -GroupId $groupid -DirectoryObjectId $id
    Write-Host "Added user to group '$group'" -ForegroundColor Green
}

#E. Add Licensing to user, If licensing changes, edit this list.
####Currently the M365 F1 Communication License

Set-MgUserLicense -UserId $UserName -AddLicenses @{SkuId = "50f60901-3181-4b75-8a2c-4c8e4c1d5a72"} -RemoveLicenses @()
Write-Host "License Added" -ForegroundColor Green 

#Sleep
Write-Host "Sleeping 30 seconds to allow MS servers to Sync Mailbox license" -ForegroundColor Green 
Start-Sleep -Seconds 30


& $PSScriptRoot/exchange_provisioning.ps1

Start-Sleep -Seconds 5