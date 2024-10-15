############################################################################################################################
######################################################## - DETECTION SCRIPT - ##############################################
############################################################################################################################
# Define the registry paths and value
$gpoRegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$mdmRegistryPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\PolicyState"
$keyName = "FeatureUpdatePausePeriodInDays"
$expectedValue = 23
 
# Check if the Group Policy registry key exists
if (Test-Path $gpoRegistryPath) {
    Write-Output "Registry key exists."
 
    # Optional: Uncomment the following block if you want to check for FeatureUpdatePausePeriodInDays
    # if (Test-Path $mdmRegistryPath) {
    #     $value = Get-ItemProperty -Path $mdmRegistryPath -Name $keyName -ErrorAction SilentlyContinue
    #     if ($value.$keyName -eq $expectedValue) {
    #         Write-Output "FeatureUpdatePausePeriodInDays is 23."
    #         exit 1
    #     } else {
    #         Write-Output "FeatureUpdatePausePeriodInDays is not 23."
    #         exit 0
    #     }
    # }
 
    exit 1
}
else {
    Write-Output "Registry key does not exist."
    exit 0
}


############################################################################################################################
######################################################## - REMIDATION SCRIPT - ##############################################
############################################################################################################################

# Define the registry paths
$gpoRegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$mdmRegistryPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy"
try {
    # Check and remove Group Policy registry key (if it exists)
    if (Test-Path $gpoRegistryPath) {
        Remove-Item -Path $gpoRegistryPath -Recurse -Force
        Write-Output "Group Policy registry key deleted."
    } else {
        Write-Output "Group Policy registry key does not exist, no action taken."
    }
    # Check and remove MDM Update Policy registry key (if it exists)
    if (Test-Path $mdmRegistryPath) {
        Remove-Item -Path $mdmRegistryPath -Recurse -Force
        Write-Output "MDM Update Policy registry key deleted."
    } else {
        Write-Output "MDM Update Policy registry key does not exist, no action taken."
    }
    # Start MDM Sync after registry keys are removed
    try {
        [Windows.Management.MdmSessionManager, Windows.Management, ContentType = WindowsRuntime]
        $session = [Windows.Management.MdmSessionManager]::TryCreateSession()
        $session.StartAsync() | Out-Null
        Write-Output "MDM sync initiated."
    }
    catch {
        Write-Output "Failed to initiate MDM sync: $($_.Exception.Message)"
    }
    # Exit with 0 to indicate successful remediation
    exit 0
}
catch {
    # If an error occurs, output the error message and exit with 1 to indicate failure
    Write-Output "Failed to delete the registry key(s): $($_.Exception.Message)"
    exit 1
}
