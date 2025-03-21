#-----------------------------------------------ONEDRIVE TASKS-----------------------------------------------"
 
Write-Host "Checking for elevated permissions..."
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You do not have sufficient privileges to run this script!`nPlease run this script as an administrator!"
}
 
$InstalledModule = Get-InstalledModule
 
if ($InstalledModule.Name -like "Microsoft.Online.SharePoint.PowerShell") {
    Write-Host "Microsoft.Online.SharePoint.PowerShell Module Installed" -ForegroundColor Green
    Import-Module  "Microsoft.Online.SharePoint.PowerShell" -WarningAction SilentlyContinue
 
}else {
    Write-Host "Installing Microsoft.Online.SharePoint.PowerShell Module " -ForegroundColor Red -BackgroundColor Black
    Install-Module -Name "Microsoft.Online.SharePoint.PowerShell" -Force 
    Import-Module  Microsoft.Online.SharePoint.PowerShell
}
 
Write-Host
Write-Host "---------------------------------------------------------" -ForegroundColor Green
Write-Host
Write-Host "Initiating the OFFBOARDING in ONEDRIVE"
Write-Host "Please provide your cloud credentials in the popup window"
Write-Host
Write-Host "---------------------------------------------------------" -ForegroundColor Green
Write-Host
 
#Set Runtime Parameters
$TenantUrl="https://ccrmca-admin.sharepoint.com/"
$Error.Clear()
 
$userdata = Read-Host "Who is the user being Offboarded?"
$usermanagerdata = Read-Host "Who needs access to this onedrive? username@ccrm.ca"
$SiteCollAdmin = $usermanagerdata
$userSAN = $userdata
 
$userSAN_ = $userSAN.Replace("@", "_").Replace(".", "_")
 
#Add Site Collection Admin to the OneDrive
Connect-SPOService -Url $TenantUrl
 
 
$userODURL = Get-SPOSite -IncludePersonalSite $true -Limit all -Filter "Url -like -my.sharepoint.com/personal/$userSAN_" | Select-Object -ExpandProperty Url
Set-SPOUser -Site $userODURL -LoginName $SiteCollAdmin -IsSiteCollectionAdmin $True -ErrorAction Continue
 
if ($error) {
    Write-Host "There was an error. Access NOT granted" -ForegroundColor red
    }
else {
Write-Host Write-Host "OneDrive FULL ACCESS Granted" -ForegroundColor Green
}