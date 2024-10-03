# Ensure script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as an Administrator." -ForegroundColor Yellow
    exit
}

# Update all installed packages using winget
Write-Host "Updating all installed packages using winget..." -ForegroundColor Yellow
winget upgrade --all --silent --accept-source-agreements --accept-package-agreements

# Install and import necessary modules
Write-Host "Installing and importing necessary modules..." -ForegroundColor Yellow
Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
Import-Module -Name PSWindowsUpdate -ErrorAction SilentlyContinue

# Check for Windows updates, download, and install them
Write-Host "Checking for Windows updates..." -ForegroundColor Yellow
Get-WindowsUpdate -AcceptAll -Install -AutoReboot

# Check for updates again after the first reboot
Write-Host "Checking for Windows updates again after reboot..." -ForegroundColor Yellow
Get-WindowsUpdate -AcceptAll -Install -AutoReboot

# Perform a disk check and schedule it for the next reboot if necessary
Write-Host "Performing disk check..." -ForegroundColor Yellow
cmd.exe /c "echo y|chkdsk C: /f /r"

# Run System File Checker to repair system files
Write-Host "Running System File Checker (sfc)..." -ForegroundColor Yellow
sfc /scannow

# Use DISM to repair the Windows image
Write-Host "Repairing Windows image using DISM..." -ForegroundColor Yellow
dism.exe /online /cleanup-image /restorehealth

# Clean up temporary files and run Disk Cleanup
Write-Host "Cleaning up temporary files and running Disk Cleanup..." -ForegroundColor Yellow
$TempFolders = @("C:\Windows\Temp", "$env:LOCALAPPDATA\Temp")
foreach ($folder in $TempFolders) {
    Remove-Item "$folder\*" -Recurse -Force -ErrorAction SilentlyContinue
}
Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -NoNewWindow -Wait

# Update Windows Store apps
Write-Host "Updating Windows Store apps..." -ForegroundColor Yellow
Get-AppxPackage -AllUsers | Foreach {Start-Process -NoNewWindow -Wait -FilePath "powershell" -ArgumentList "Add-AppxPackage -DisableDevelopmentMode -Register '$($_.InstallLocation)\AppXManifest.xml'"}

# Delete registry keys to avoid OOBE Sysprep process hang
Write-Host "Deleting registry keys to avoid OOBE Sysprep process hang..." -ForegroundColor Yellow
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\SysPrepExternal\Cleanup" -Recurse -Force

# Run Sysprep with the specified options
Write-Host "Running Sysprep..." -ForegroundColor Yellow
Start-Process -FilePath "C:\Windows\System32\sysprep\sysprep.exe" -ArgumentList "/oobe /generalize /shutdown /mode:vm" -NoNewWindow -Wait

Write-Host "System cleanup, update, and Sysprep completed. The system will shut down now." -ForegroundColor Green
