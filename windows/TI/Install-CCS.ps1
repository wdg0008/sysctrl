<#
.SYNOPSIS
    Install Texas Instruments Code Composer Studio
.DESCRIPTION
    Downloads the full Windows installer for 12.8.1 to install all components silently
    Requires administrative priveleges but no user interaction
.EXAMPLE
    .\Install-CCS.ps1
#>

Set-location $env:USERPROFILE\Downloads

# 1. Define variables used in CCS setup
$ccsUrl = "https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-J1VdearkvK/12.8.1/CCS12.8.1.00005_win64.zip"
$zipFile = "CCS12.8.1.00005_win64.zip"
$extractFolder = "CCS_Extracted"

# The executable path based on how Expand-Archive handles the root folder of the ZIP
$setupExe = "$extractFolder\CCS12.8.1.00005_win64\ccs_setup_12.8.1.00005.exe"

# Passing no component flags tells the TI installer to install EVERYTHING.
$ccsArgs = "--mode unattended"

# 2. Download the ZIP file
Write-Host "Downloading Code Composer Studio 12.8.1..." -ForegroundColor Cyan
Start-BitsTransfer -Source $ccsUrl -Destination $zipFile

# 3. Extract the ZIP file
# Note: CCS is a massive IDE, so this step can take several minutes.
Write-Host "Extracting CCS (this may take a few minutes)..." -ForegroundColor Yellow
Expand-Archive -Path $zipFile -DestinationPath $extractFolder -Force

# 4. Run the Unattended Installation
Write-Host "Starting silent installation (All Product Families)..." -ForegroundColor Cyan

# Start the installer and wait for it to release system locks
Start-Process -FilePath $setupExe -ArgumentList $ccsArgs -Wait -NoNewWindow

# 5. Clean up the massive installation files to save disk space
Write-Host "Cleaning up installation files..." -ForegroundColor Yellow
Remove-Item -Path $zipFile -Force
Remove-Item -Path $extractFolder -Recurse -Force

Write-Host "Code Composer Studio has been successfully installed!" -ForegroundColor Green
