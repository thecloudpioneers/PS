############### SharePoint Online - Permission Report - Shared Links ###############


# Parameters
$SiteUrl = "https://Crescent.sharepoint.com/sites/Marketing"
$ReportOutput = "C:\Temp\SharingLinkPermissions.csv"
$ListName = "Branding"

#$ServiceURL = "https://accessgrouporg-admin.sharepoint.com"
$SiteURL = "https://accessgrouporg.sharepoint.com/sites/TeamIT"
$ReportOutput ="C:\Temp\FolderPermissionRpt.csv"
$ListName = "Documents"
#endregion

#####################################################################
################## - Connect to PnP Powershell Azure AD - ##################
#####################################################################
# Define credentials
$Email = "onedrivesharepointaudit@accesslex.org"
$Password = "!%j0m6lp!w/Wdd%!7q"
$Cred = New-Object System.Management.Automation.PSCredential ($Email, $SecurePassword)

# Connect to PnP Online
Connect-PnPOnline -Url $SiteUrl -ClientId 73eadc33-26bb-4dd3-8af0-a08833a031fa -Credentials $Cred
#####################################################################
################## - Connect to PnP Powershell Azure AD - ##################
#####################################################################

#Connect to the Site collection
# Connect-PnPOnline -Url $SiteUrl -ClientId 73eadc33-26bb-4dd3-8af0-a08833a031fa
#Connect to PnP Online
#Connect-PnPOnline -Url $SiteURL -Interactive


$Ctx = Get-PnPContext
$Results = @()
$global:counter = 0
 
#Get all list items in batches
$ListItems = Get-PnPListItem -List $ListName -PageSize 2000
$ItemCount = $ListItems.Count
   
#Iterate through each list item
ForEach($Item in $ListItems)
{
    Write-Progress -PercentComplete ($global:Counter / ($ItemCount) * 100) -Activity "Getting Shared Links from '$($Item.FieldValues["FileRef"])'" -Status "Processing Items $global:Counter to $($ItemCount)";
 
    #Check if the Item has unique permissions
    $HasUniquePermissions = Get-PnPProperty -ClientObject $Item -Property "HasUniqueRoleAssignments"
    If($HasUniquePermissions)
    {
        #Get Users and Assigned permissions
        $RoleAssignments = Get-PnPProperty -ClientObject $Item -Property RoleAssignments
        ForEach($RoleAssignment in $RoleAssignments)
        {
            $Members = Get-PnPProperty -ClientObject $RoleAssignment -Property RoleDefinitionBindings, Member
            #Get list of users
            $Users = Get-PnPProperty -ClientObject ($RoleAssignment.Member) -Property Users -ErrorAction SilentlyContinue
            #Get Access type
            $AccessType = $RoleAssignment.RoleDefinitionBindings.Name
            If ($RoleAssignment.Member.Title -like "SharingLinks*")
            {
                If ($Users -ne $null)
                {
                    ForEach ($User in $Users)
                    {
                        #Collect the data
                        $Results += New-Object PSObject -property $([ordered]@{
                        Name  = $Item.FieldValues["FileLeafRef"]           
                        RelativeURL = $Item.FieldValues["FileRef"]
                        FileType = $Item.FieldValues["File_x0020_Type"]
                        UserName = $user.Title
                        UserAccount  = $User.LoginName
                        Email  =  $User.Email
                        Access = $AccessType
                        })
                    }
                        
                }
            }       
        }
    }      
    $global:counter++
}
$Results | Export-CSV $ReportOutput -NoTypeInformation
Write-host -f Green "Sharing Links Report Generated Successfully!"


#Read more: https://www.sharepointdiary.com/2020/11/generate-shared-links-permission-report-in-sharepoint-online.html#ixzz8mryHqPaR
