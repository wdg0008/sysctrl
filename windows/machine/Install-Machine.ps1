<#
.SYNOPSIS
    This script installs all machine-scope packages that it declares in the $packageGroups variable using WinGet.
.DESCRIPTION
    This script requires administrative rights to work because some packages are installed for the whole system.
    It defines a list of package groups and their corresponding package IDs, and installs them using WinGet.
.EXAMPLE
    .\Install-Machine.ps1
#>

using namespace System.Security.Principal

$identity = [WindowsIdentity]::GetCurrent()
$principal = [WindowsPrincipal]::new($identity)

if (-not $principal.IsInRole([WindowsBuiltInRole]::Administrator))
{
    $currentHost = (Get-Process -Id $PID).Path
    $currentDirectory = (Get-Location).Path
    $arguments = @(
        '-NoProfile'
        '-ExecutionPolicy', 'Bypass'
        '-File', "`"$PSCommandPath`""
    )

    Start-Process -FilePath $currentHost -ArgumentList $arguments -WorkingDirectory $currentDirectory -Verb RunAs
    exit
}

# Begin by running basic system configuration with DSC to prepare Windows and Visual Studio
& $PSScriptRoot\Configure-WindowsFeatures.ps1

$wingetConfigureArguments = @(
    'configure'
    '--accept-configuration-agreements'
)

$configurationFiles = @(
    '01-system-settings.winget'
    '03-compiler-toolchains.winget'
)

foreach ($configurationFile in $configurationFiles) {
    $configurationPath = Join-Path $PSScriptRoot $configurationFile
    Write-Host "Applying $configurationFile..." -ForegroundColor Yellow

    & winget @wingetConfigureArguments $configurationPath

    if ($LASTEXITCODE -ne 0) {
        throw "WinGet failed to apply $configurationFile with exit code $LASTEXITCODE."
    }
}

Write-Host "Installing machine-scope packages...`n" -ForegroundColor Cyan

$wingetArguments = @(
    'install'
    '--exact'
    '--accept-source-agreements'
    '--accept-package-agreements'
    '--silent'
)

$packageIds = @(
    # Dev Tools
    'Docker.DockerDesktop'
    'RedHat.Podman'
    'Kitware.CMake'
    'Git.Git'
    'GNU.Octave'
    'Rustlang.Rustup'
    'EclipseAdoptium.Temurin.25.JDK'
    'Microsoft.VisualStudioCode'
    'Microsoft.VisualStudio.Locator'
    'Xmake-io.Xmake'
    'DimitriVanHeesch.Doxygen'
    'PuTTY.PuTTY'
    'Mobata.MobaXterm'
    'Microsoft.PowerToys'
    # Office and Productivity
    'TheDocumentFoundation.LibreOffice'
    'Microsoft.Office'
    'Microsoft.Teams'
    'Zoom.Zoom'
    'Webex.Webex'
    # Utilities
    'REALiX.HWiNFO'
    'TechPowerUp.GPU-z'
    'OBSProject.OBSStudio'
    'KeePassXCTeam.KeePassXC'
    'VideoLAN.VLC'
    'MicroDicom.DICOMViewer'
    'TexasInstruments.TIConnect' # No user-scope package
    # Design Tools
    'AnalogDevices.LTspice'
    'KiCad.Kicad'
    'Ultimaker.Cura'
)

foreach ($packageId in $packageIds) {
    Write-Host "Installing $packageId..."
    winget @wingetArguments --id $packageId
}
