<#
.SYNOPSIS
    This script installs all user-scope packages defined in the script.
.DESCRIPTION
    This script does not require administrative rights to work.
    It defines a list of package groups and their corresponding package IDs, and installs them using WinGet.
.EXAMPLE
    .\Install-User.ps1
#>

Write-Host "Installing user-scope packages...`n" -ForegroundColor Cyan

$wingetArguments = @(
    "install"
    "--exact"
    "--accept-source-agreements"
    "--accept-package-agreements"
    "--silent"
)

# Object[]
# ├── String       # 'Dev Tools'
# └── Object[]     # package IDs

$packageGroups = @(
    @(
        "Dev Tools"
        @(
            "Microsoft.PowerShell"
            "Microsoft.PowerToys"
            "Python.PythonInstallManager"
        )
    )
    @(
        "Office and Productivity"
        @(
            "9WZDNCRFJ3PV"
            "JGraph.Draw"
            "MiKTex.MiKTeX"
            "Obsidian.Obsidian"
        )
    )
    @(
        "Utilities"
        @(
            "TexasInstruments.TIConnect"
            "LocalSend.LocalSend"
            "RickMeyers.e-Sword"
            "Discord.Discord"
        )
    )
    @(
        "Microsoft Store Apps"
        @(
            "9MSVH128X2ZT" # WinUI 2 Gallery
            "9NBLGGH4TLCQ" # Windows Community Toolkit Sample App
            "9NDLX60WX4KQ" # WPF Gallery
            "9NKLCF1LVZ5H" # CommunityToolkit.MVVM Sample App
            "9P3JFPWWDZRC" # WinUI 3 Gallery
        )
    )
)

foreach ($group in $packageGroups) {
    $groupName = $group[0]
    $packageIds = $group[1]

    Write-Host "Installing $groupName...`n" -ForegroundColor Yellow

    foreach ($packageId in $packageIds) {
        Write-Host "Installing $packageId..."
        winget @wingetArguments --id $packageId

        if ($LASTEXITCODE -ne 0) {
            throw "WinGet failed to install $packageId with exit code $LASTEXITCODE."
        }
    }
}

Write-Host "`nAll user-scope packages have been installed successfully.`n`n" -ForegroundColor Green
