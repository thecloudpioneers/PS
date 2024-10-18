# Define credentials and variables
$SiteUrl = ""
$Email = ""
$Password = ""
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($Email, $SecurePassword)

# Report output location
$ReportOutputLocation = "C:\Temp\4TeamsAndMembers.csv"

# Specific team (leave blank to generate for all teams)
$SpecificTeam = ""

# Verbose preference
$VerbosePreference = "Continue"

# Install and import Microsoft Teams module if not installed
if (-not (Get-Module -ListAvailable -Name MicrosoftTeams)) {
    Install-Module -Name MicrosoftTeams -Force -Scope CurrentUser
}
Import-Module -Name MicrosoftTeams

# Connect to Microsoft Teams
Connect-MicrosoftTeams -Credential $Cred

# Get all Teams or a specific team
if ($SpecificTeam) {
    $teams = Get-Team | Where-Object { $_.DisplayName -eq $SpecificTeam }
} else {
    $teams = Get-Team
}

# Initialize an array to hold the results
$result = @()

foreach ($team in $teams) {
    Write-Verbose "Processing team: $($team.DisplayName)"

    # Get team members
    $members = Get-TeamUser -GroupId $team.GroupId
    $memberNamesArray = $members | Where-Object { $_.Role -eq "Member" } | ForEach-Object { $_.Name }
    $memberNames = $memberNamesArray -join ", "

    # Create a custom object for the CSV
    $teamInfo = [PSCustomObject]@{
        TeamName     = $team.DisplayName
        TeamObjectID = $team.GroupId
        TeamOwners   = "Standardized Owner"
        TeamMembers  = $memberNames
    }

    # Add the custom object to the result array
    $result += $teamInfo
}

# Export the result to a CSV file
$result | Export-Csv -Path $ReportOutputLocation -NoTypeInformation -Verbose

# Informative message
Write-Host "Team member information exported to '$ReportOutputLocation'"
