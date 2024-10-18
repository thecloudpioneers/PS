############################################### - SP - Add User to Specifc Site as Site Collection Admin - ###############################################
#Variables for processing
$AdminURL = "https://crescent-admin.sharepoint.com/"
$AdminName = "salaudeen@crescent.onmicrosoft.com"
$SiteCollURL = "https://crescent.sharepoint.com/sites/Sales/"
$SiteCollectionAdmin = "mark@crescent.onmicrosoft.com"
 
#User Name and Password to connect
#$SecurePWD = read-host -assecurestring "Enter Password for $AdminName"
$SecurePWD = ConvertTo-SecureString "Password1" -asplaintext -force 
$Credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $AdminName, $SecurePWD
  
#Connect to SharePoint Online
Connect-SPOService -url $AdminURL -credential $Credential
 
#Add Site collection Admin
Set-SPOUser -site $SiteCollURL -LoginName $SiteCollectionAdmin -IsSiteCollectionAdmin $True
#Read more: https://www.sharepointdiary.com/2015/08/sharepoint-online-add-site-collection-administrator-using-powershell.html#ixzz8p20kHLvt
############################################### - SP - Add User to Specifc Site as Site Collection Admin - ###############################################

############################################### - SP - Add User to All Sites as Site Collection Admin - ###############################################

#Variables for processing
$AdminURL = "https://Crescent-admin.sharepoint.com/"
 
#Connect to SharePoint Online
Connect-SPOService -url $AdminURL
 
$Sites = Get-SPOSite -Limit ALL
 
Foreach ($Site in $Sites)
{
    Write-host "Adding Site Collection Admin for:"$Site.URL
    Set-SPOUser -site $Site -LoginName $AdminName -IsSiteCollectionAdmin $True
}


#Read more: https://www.sharepointdiary.com/2015/08/sharepoint-online-add-site-collection-administrator-using-powershell.html#ixzz8p210pHMt
############################################### - SP - Add User to All Sites as Site Collection Admin - ###############################################
#Variables for processing
$AdminURL = "https://crescent-admin.sharepoint.com/"
$AdminName="SPAdmin@crescent.com"
 
#Connect to SharePoint Online
Connect-SPOService -url $AdminURL -credential (Get-Credential)
 
#Get All Site Collections
$AllSites = Get-SPOSite -Limit ALL
# OR All Communitcation sites (Use below and comment above )
# $AllSites = Get-SPOSite -Template SITEPAGEPUBLISHING#0
# OR All Communitcation sites (Use below and comment above )
# OR Filter based on site
#$Sites = Get-SPOSite -Limit All | Where {$_.Url -like 'https://crescent.sharepoint.com/sites/Project*'}

#Loop through each site and add site admins
Foreach ($Site in $AllSites)
{
    Write-host "Adding Site Collection Admin for:"$Site.URL
    Set-SPOUser -site $Site.Url -LoginName $AdminName -IsSiteCollectionAdmin $True
}
#Read more: https://www.sharepointdiary.com/2015/08/sharepoint-online-add-site-collection-administrator-using-powershell.html#ixzz8p21MFkGt
############################################### - SP - Add User to All Sites as Site Collection Admin - ###############################################

############################################### - SP - Report Audit - All sites site collection admins - ###############################################

Add-PSSnapin "Microsoft.SharePoint.Powershell" -ErrorAction SilentlyContinue
 
# Specify the path to save the CSV file
$csvPath = "C:\Temp\iteCollectionAdmins.csv"
 
# Create an empty array to hold the results
$results = @()
 
# Get all site collections in the farm
$sites = Get-SPSite -Limit All
 
# Loop through each site collection
foreach ($site in $sites) {
  # Get site collection administrators
    $admins = Get-SPUser -Site $site.Url | Where-Object { $_.IsSiteAdmin -eq $true }
 
    # Loop through each administrator
    foreach ($admin in $admins) {
        # Create a custom object to store the data
        $adminDetails = New-Object PSObject -Property @{
            SiteCollectionUrl = $site.Url
            AdminLogin        = $admin.LoginName
            AdminEmail        = $admin.Email
            AdminName         = $admin.DisplayName
        }
        # Add the object to the results array
        $results += $adminDetails
    }
 
    # Dispose of the site object to free up resources
    $site.Dispose()
}
 
# Export the results to a CSV file
$results | Export-Csv -Path $csvPath -NoTypeInformation
 
# Notify the user that the script has completed
Write-Host "Export complete! The site collection administrators list has been saved to $csvPath"
#Read more: https://www.sharepointdiary.com/2013/08/site-collection-administrators-report.html#ixzz8p25DWkOH
############################################### - SP - Report Audit - All sites site collection admins - ###############################################


