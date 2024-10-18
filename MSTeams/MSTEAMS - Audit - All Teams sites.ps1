# Import the MS Teams module.
Import-Module MicrosoftTeams

# Get all Teams
$teams = Get-Team

# Create an empty object to store all team member information
$allTeamMembers = New-Object System.Collections.ArrayList

# Loop through each Team
foreach ($team in $teams) {
  # Get members and their roles for the current Team
  $members = Get-TeamUser -GroupId $team.GroupId | Select-Object Name, Role

  # Create a new object for each member
  foreach ($member in $members) {
    $memberInfo = New-Object PSObject -Property @{
      "Team Name" = $team.DisplayName
      "Member Name" = $member.Name
      "Role" = $member.Role
    }
    $allTeamMembers.Add($memberInfo)
  }
}

# Export the results to a CSV file
$exportPath = "C:\Users\dave\Desktop\TeamMembers.csv"
$allTeamMembers | Export-Csv -Path $exportPath -NoTypeInformation

# Informative message
Write-Host "Team member information exported to '$exportPath'"
