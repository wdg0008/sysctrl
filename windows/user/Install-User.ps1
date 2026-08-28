<#
.SYNOPSIS
    This script installs a list of pre-defined, user-scope windows packages that it declares.
.DESCRIPTION
    This script does not require administrative rights to work.
    It defines a list of package groups and their corresponding package IDs, and installs them using WinGet.
.EXAMPLE
    .\Install-User.ps1
#>

Write-Host "Removing adware...`n" -ForegroundColor Cyan

winget configure --accept-configuration-agreements .\app-removals.winget

Write-Host "Installing user-scope packages...`n" -ForegroundColor Cyan

$wingetArguments = @(
    "install"
    "--exact"
    "--accept-source-agreements"
    "--accept-package-agreements"
    "--silent"
)

$winGetPackages = @(
    # Dev Tools
    "Microsoft.PowerShell"
    "Python.PythonInstallManager"
    # Office and Productivity
    "JGraph.Draw"
    "MiKTeX.MiKTeX"
    "Obsidian.Obsidian"
    # Utilities
    "LocalSend.LocalSend"
    "Discord.Discord"
)

$storePackages = @(
    # Regular Apps
    "9MSVH128X2ZT" # WinUI 2 Gallery
    "9NBLGGH4TLCQ" # Windows Community Toolkit Sample App
    "9NDLX60WX4KQ" # WPF Gallery
    "9NKLCF1LVZ5H" # CommunityToolkit.MVVM Sample App
    "9P3JFPWWDZRC" # WinUI 3 Gallery
    "9WZDNCRFJ3PV" # Windows Scan
    "9N1F85V9T8BN" # Windows App (remote desktop)
    "9MSMLRH6LZF3" # Windows Notepad
    "9N0DX20HK701" # Windows Terminal
    "9WZDNCRFHVN5" # Windows Calculator
    # Image and Video Extensions
    "9N95Q1ZZPMH4" # MPEG-2 Video Extension
    "9MVZQVXJBQ9V" # AV1 Video Extension
    "9NCTDW2W1BH8" # Raw Image Extension
    "9MZPRTH5C0TB" # JPEG XL Image Extension
    "9N5TDP8VCMHS" # Web Media Extensions
    "9PB0TRCNRHFX" # AVC Encoder Video Extension
    "9N4D0MSMP0PT" # VP9 Video Extensions
    "9PMMSR1CGPWG" # HEIF Image Extension
    "9PG2DK419DRG" # Webp Image Extension
)

foreach ($packageId in $winGetPackages) {
    Write-Host "Installing $packageId..."
    winget @wingetArguments --id $packageId --scope user --source winget
}

foreach ($packageId in $storePackages) {
    Write-Host "Installing $packageId from Microsoft Store..."
    winget @wingetArguments --id $packageId --source msstore
}
