<#
.SYNOPSIS
    Master orchestration script to install the complete TI toolchain.
.DESCRIPTION
    Invokes separate scripts to install CCS and the AM243x SDK from Texas Instruments.
    These are downloaded from the TI servers on script execution.
    Versions are fixed to the Sitara toolchain in use, but can be edited by swapping URLs.
    Requires administrative priveleges to execute some installers.
.EXAMPLE
    .\Setup-SitaraDev.ps1
#>

# Stop the master script immediately if one of the worker scripts throws a terminating error
$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Green
Write-Host "  Starting Master TI Installation Script  " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# 1. Execute the CCS Setup Script
Write-Host "`n---> Phase 1: Installing Code Composer Studio..." -ForegroundColor Cyan
& "$PSScriptRoot\Install-CCS.ps1"

# 2. Execute the SDK Setup Script
Write-Host "`n---> Phase 2: Installing SDK and Dependencies..." -ForegroundColor Cyan
& "$PSScriptRoot\Install-AM243X.ps1"

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "  Master Installation Sequence Complete!  " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Final summary messages
Write-Host "`nAll TI tools have been successfully installed!`n" -ForegroundColor Green
Write-Host "`nRemember to install OpenSSL manually: https://slproweb.com/products/Win32OpenSSL.html"
Write-Host "`nEnsure a supported Python 3.x is installed: https://apps.microsoft.com/detail/9nq7512cxl7t"
Write-Host "`nOnce Python is properly configured, run the following:"
Write-Host "`npython -m pip install pyserial xmodem tqdm`n" -ForegroundColor Magenta
