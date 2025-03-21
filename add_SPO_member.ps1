# Variables for site details and user credentials
$siteUrl = Read-Host -Prompt "Please Enter the SPO site Link"   # Target SharePoint site URL
$last_index = $siteUrl.LastIndexOf("/")
$site_name = $siteUrl.Substring($last_index + 1)

# Create a SharePoint Online session and connect
Connect-SPOService -url "https://ccrmca-admin.sharepoint.com"

# List of users to add with their roles (update with user emails and their desired roles)
$user =  Read-Host "Enter User Email Address to add to site" #list of users

# Loop through each user and add them to the site with the specified role    

    try {
        # Assign the user to the SharePoint site with a specific role
        Set-SPOUser -Site $siteUrl -LoginName $user -IsSiteCollectionAdmin $false  # Add user as non-admin

        # Here we simulate setting permissions by assigning users to a SharePoint group
            Add-SPOUser -Site $siteUrl -LoginName $user -Group "$site_name Members"

        Write-Host "Successfully added $user to the site."
    }
    catch {
        Write-Host "Error adding $user : $_"
    }


