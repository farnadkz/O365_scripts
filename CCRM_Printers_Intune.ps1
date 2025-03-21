Start-Transcript -Path C:\Windows\Temp\CCRM_Printers.log
$CanonInf = (Get-ChildItem -Path "C:\Windows\System32\DriverStore\FileRepository" -Recurse | where {$_.Name -eq "CNLB0MA64.INF" }).FullName






$Canon = "Driver\CNLB0MA64.INF"





If ($CanonInf -eq $null) {




#Canon Printer




#CCRM North Office
C:\Windows\SysNative\pnputil.exe /a $Canon
Add-PrinterPort -Name "10.140.10.20" -PrinterHostAddress "10.140.10.20"
$CanonInf = (Get-ChildItem -Path "C:\Windows\System32\DriverStore\FileRepository" -Recurse | where {$_.Name -eq "CNLB0MA64.INF" }).FullName
Add-PrinterDriver -Name "Canon Generic Plus UFR II" -InfPath $CanonInf
Add-Printer -Name "\\10.140.10.20\CCRM North Office" -DriverName "Canon Generic Plus UFR II" -PortName "10.140.10.20"




#CCRM 465 Office
Add-PrinterPort -Name "10.140.10.50" -PrinterHostAddress "10.140.10.50"
Add-Printer -Name "\\10.140.10.50\CCRM 465 Office" -DriverName "Canon Generic Plus UFR II" -PortName "10.140.10.50"

#CCRM South Office
Add-PrinterPort -Name "10.140.10.21" -PrinterHostAddress "10.140.10.21"
Add-Printer -Name "\\10.140.10.21\CCRM South Office" -DriverName "Canon Generic Plus UFR II" -PortName "10.140.10.21"

#CCRM CCVP Office
Add-PrinterPort -Name "10.140.33.22" -PrinterHostAddress "10.140.33.22"
Add-Printer -Name "\\10.140.33.22\CCRM CCVP Office" -DriverName "Canon Generic Plus UFR II" -PortName "10.140.33.22"


#OmniaBio Second Floor
Add-PrinterPort -Name "10.190.8.25" -PrinterHostAddress "10.190.8.25"
Add-Printer -Name "\\10.190.8.25\Omniabio 2nd floor" -DriverName "Canon Generic Plus UFR II" -PortName "10.190.8.25"

#OmniaBio Third Floor
Add-PrinterPort -Name "10.190.8.23" -PrinterHostAddress "10.190.8.23"
Add-Printer -Name "\\10.190.8.23\Omniabio 3rd floor" -DriverName "Canon Generic Plus UFR II" -PortName "10.190.8.23"




}




else
{"Already installed, Removing..."





Remove-Printer -Name "CCRM North Office"
Remove-PrinterPort -Name "10.140.10.20"
Start-Sleep -Seconds 2







Remove-Printer -Name "CCRM 465 Office"
Remove-PrinterPort -Name "10.140.10.50"
Start-Sleep -Seconds 2




Remove-Printer -Name "CCRM CCVP Office"
Remove-PrinterPort -Name "10.140.33.22"
Start-Sleep -Seconds 2

Remove-Printer -Name "Omniabio 2nd floor"
Remove-PrinterPort -Name "10.190.8.25"
Start-Sleep -Seconds 2

Remove-Printer -Name "Omniabio 3rd floor"
Remove-PrinterPort -Name "10.190.8.23"
Start-Sleep -Seconds 2



Remove-Printer -Name "CCRM South Office"
Remove-PrinterPort -Name "10.140.10.21"
Remove-PrinterDriver -Name "Canon Generic Plus UFR II"
C:\Windows\SysNative\pnputil.exe /d $Canon





}
Stop-Transcript