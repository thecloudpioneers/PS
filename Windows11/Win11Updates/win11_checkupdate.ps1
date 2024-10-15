# Preliminary: Set PS Gallery Repository Policy to Trusted
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

try {
    # Install PSWindowsUpdate Module (if not present)
    if (-not (Get-Module PSWindowsUpdate -ListAvailable)) {
        Install-Module PSWindowsUpdate -Force -AllowClobber -ErrorAction Stop
    }

    # Restart Windows Update Service
    Restart-Service wuauserv -ErrorAction Stop

    # Wait until service is running (up to 1 minute)
    $timeout = 60  # Seconds to wait
    $startTime = Get-Date
    do {
        Start-Sleep -Seconds 5 # Check every 5 seconds
    } while ((Get-Service wuauserv).Status -ne "Running" -and ((Get-Date) - $startTime).TotalSeconds -lt $timeout)

    # Install Windows Updates
    #Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot -ErrorAction Stop
    Get-WindowsUpdate -Install -AcceptAll -UpdateType Software -IgnoreReboot -Verbose -ErrorAction SilentlyContinue
    Write-Output "Windows updates installed successfully."
    exit 1
} catch {
    Write-Output "An error occurred: $_"
    exit 0
}
