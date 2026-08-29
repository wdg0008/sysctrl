<#
.SYNOPSIS
    Sets up a new Windows machine with the necessary tools and configurations.
.DESCRIPTION
    This script installs and configures the essential software and settings for a new Windows machine.
    It begins with machine-wide configuration and continues with user-specific setup.
.EXAMPLE
    .\Setup-Windows.ps1
#>

Write-Host "Starting Windows machine setup..." -ForegroundColor Cyan
& $PSScriptRoot\machine\Install-Machine.ps1

Write-Host "`nStarting user-scope setup..." -ForegroundColor Cyan
& $PSScriptRoot\user\Install-User.ps1
