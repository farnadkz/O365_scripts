# Variables for site details and user credentials
$siteUrl = Read-Host -Prompt "Please Enter the SPO site Link"   # Target SharePoint site URL
$last_index = $siteUrl.LastIndexOf("/")
$site_name = $siteUrl.Substring($last_index+1)

# Create a SharePoint Online session and connect
Connect-SPOService -url "https://ccrmca-admin.sharepoint.com"

# List of users to add with their roles (update with user emails and their desired roles)
$users = @(
    @{ Email = "adm.hsingla@ccrm.ca"; Role = "Contribute" } # User1 with Contribute role
)

# Loop through each user and add them to the site with the specified role
foreach ($user in $users) {
    $email = $user.Email
    $role = $user.Role

    try {
        # Assign the user to the SharePoint site with a specific role
        Set-SPOUser -Site $siteUrl -LoginName $email -IsSiteCollectionAdmin $false  # Add user as non-admin

        # Optionally assign a specific role (Contribute, Read, etc.)
        # Here we simulate setting permissions by assigning users to a SharePoint group
        if ($role -eq "Contribute") {
            Add-SPOUser -Site $siteUrl -LoginName $email -Group "$site_name Members"
        }
        elseif ($role -eq "Read") {
            Add-SPOUser -Site $siteUrl -LoginName $email -Group "Visitors"
        }

        Write-Host "Successfully added $email to the site with role $role."
    }
    catch {
        Write-Host "Error adding $email : $_"
    }
}

