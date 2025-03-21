Connect-ExchangeOnline
$groupname  = "TH OmniaBio Meeting Invites"
Get-DistributionGroupMember -Identity $groupname -Resultsize unlimited | Select Name,PrimarySmtpAddress,
  @{L="EmailAddresses";E={$_.EmailAddresses | ? {$_.PrefixString -ceq "smtp"} | % {$_.SmtpAddress}}} | 
    Export-Csv "C:\Users\FarnadKazemzadeh\csv_exports\$groupname.csv" -NoTypeInformation