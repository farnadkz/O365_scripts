#Script to provision new users in exchange
Connect-ExchangeOnline -ShowBanner:$false 
$Response  = 'y'
$dlName = $null
$dlList = @('CCRM Permanent Employee Distribution List')
Write-Host "CONNECTED TO EXCHANGE ONLINE" -ForegroundColor Green
#A. SendAs Permissions for Scanner
Add-RecipientPermission $user_name -AccessRights SendAs -Trustee "Scanner@ccrm.ca" -Confirm:$false
if (Get-RecipientPermission -Identity $user_name | Where-Object {$_.Trustee -eq "Scanner@ccrm.ca" -and $_.AccessRights -eq "SendAs"}) {
    Write-Host "Scanner added Succesfully" -ForegroundColor Green
}
else {
    Write-Host "Scanner not added" -ForegroundColor Red
}
#B. adding Unified labeling

#Add-UnifiedGroupLinks -Identity "CCRM_Microsoft 365 Unified Labeling" -LinkType Members -Links $UserName
#Write-Host "User Added to Unified Labeling" -ForegroundColor Green

#C. Add Users to Distribution Lists

Do {
    Write-Host "DISTRIBUTION LIST MUST MATCH EXACT CASE AS SHOWN IN EXCHANGE" -ForegroundColor Yellow
    Write-Host "Employee Distribution list is added automatically" -ForegroundColor Yellow
    Write-Host "Common DL's: 'OmniaBio People Managers Distribution List', 'CCRM People Managers Distribution List'"
    $Response = Read-Host "Enter Distribution list name to add user to, or n to finish.)"
    If ($Response -eq 'n' -Or $Response -eq 'N') {break}
    if ($Response -eq '' -or $Response -eq ' ') {continue}
    $dlList += $Response
}
Until ($Response -eq 'n')

foreach ($DL in $dlList) {
    Add-DistributionGroupMember -Identity $DL -Member $user_name
    Write-Host "Added User to '$DL'" -ForegroundColor Green 
}