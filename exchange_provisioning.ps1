#Script to provision new users in exchange
Connect-ExchangeOnline 

$Response  = 'y'
$dlName = $null
$dlList = @('OMNIABIO Employee Distribution List')
#A. SendAs Permissions for Scanner
Start-Sleep -Seconds 30
Try {
Add-RecipientPermission $UserName -AccessRights SendAs -Trustee "Scanner@ccrm.ca" -Confirm:$false
}
Catch {
Write-Error "Scanner not added"
}
#Write-Host "Scanner added Succesfully" -ForegroundColor Green 
#B. adding Unified labeling

Try {
    Add-UnifiedGroupLinks -Identity "CCRM_Microsoft 365 Unified Labeling" -LinkType Members -Links $UserName
}
Catch {
    Write-Error "User not added to Unified Labeling"
}
#Write-Host "User Added to Unified Labeling" -ForegroundColor Green

#C. Add Users to Distribution Lists

Do {
    Write-Host "DISTRIBUTION LIST MUST MATCH EXACT CASE AS SHOWN IN EXCHANGE" -ForegroundColor DarkMagenta
    Write-Host "OmniaBio Employee Distribution list is added automatically" -ForegroundColor DarkMagenta
    $Response = read-host "Does the user need to be added to additional Distrubution Lists?(Y/n)"
    If ($Response -eq 'n' -Or $Response -eq 'N') {break}
    $dlName = Read-Host "Please Enter distribution list name" 
    $dlList += $dlName
}
Until ($Response -eq 'n')

foreach ($DL in $dlList) {
    Try {
    Add-DistributionGroupMember -Identity $DL -Member $UserName
    }
    Catch {
        Write-Error "User not added to'$DL'"
    }
    Write-Host "Added User to '$DL'" -ForegroundColor Green 
}