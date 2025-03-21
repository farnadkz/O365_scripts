#Script to remove users from Exclude MFA group

#Setup
$Group = 'Exclude from MFA'
#Start-Transcript -Path "C:\Users\FarnadKazemzadeh\ONB_transcript\remove_mfa.txt" -Append

#connecting to services
Connect-AzureAD 
Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All

#A. Getting Information
$UserName = Read-Host -Prompt "Please Type the Email address of the user"

#B. Get User Azure Id 
$id = (Get-MgUser -UserId $UserName).id

#removing from group
$groupid = (Get-MgGroup -Filter "startsWith(DisplayName, '$Group')").id 
Remove-MgGroupMemberDirectoryObjectByRef -GroupId $groupid -DirectoryObjectId $id
