
# INSTALL AND CONNECT TO SHAREPOINT PNP MODULE
# Install Powershell 7 
# Link

# Install PnP Online Module
Install-Module -Name PnP.PowerShell -Force
Update-Module -Name PnP.PowerShell

# Import the SharePoint PnP PowerShell module
Import-Module PnP.PowerShell

# Verify Version = 2.1 or higher
Get-Module -Name PnP.PowerShell

# Clear any existing PnP Online connections
Disconnect-PnPOnline

# Register PnP in Azure AD
Register-PnPEntraIDAppForInteractiveLogin -ApplicationName "PnP PowerShell" -SharePointDelegatePermissions "AllSites.FullControl" -Tenant Accessgrouporg -Interactive

# Login Pop up details
#   example@exampe.org
#   psswor



################## - Connect to PnP Powershell Azure AD - ##################

# Define credentials
$SiteUrl = "example.sharepoint.com"
$Email = "email@example.com"
$Password = "pass"
$Cred = New-Object System.Management.Automation.PSCredential ($Email, $SecurePassword)

# Connect to PnP Online
Connect-PnPOnline -Url $SiteUrl -ClientId 73eadc33-26bb-4dd3-8af0-a08833a031fa -Credentials $Cred

################## - Connect to PnP Powershell Azure AD - ##################

