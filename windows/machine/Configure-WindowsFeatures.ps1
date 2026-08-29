<#
.SYNOPSIS
    Installs and enables core Windows functionality
.DESCRIPTION
    Sets up WSL, Windows Sandbox, Hyper-V, and other goodies as optional features and capabilities.
    Called by Install-Machine.ps1 to prepare the system for package installation.
    Requires administrative rights to run.
.EXAMPLE
    .\Configure-WindowsFeatures.ps1
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

# installed from "Add features to Windows"
# List with `Get-WindowsOptionalFeature -Online`
$features = @(
    'Microsoft-Windows-Subsystem-Linux'
    'VirtualMachinePlatform'
    'Containers-DisposableClientVM'
    'WindowsMediaPlayer'
    'SmbDirect'
    'HypervisorPlatform'
    'Microsoft-Hyper-V'
    'Containers'
)

foreach ($feature in $features) {
    $state = (Get-WindowsOptionalFeature -Online -FeatureName $feature).State

    if ($state -ne 'Enabled') {
        Write-Host "Enabling Windows feature: $feature"
        Enable-WindowsOptionalFeature `
            -Online `
            -FeatureName $feature `
            -All `
            -NoRestart
    }
    else {
        Write-Host "Already enabled: $feature"
    }
}

# installed from settings app feature menu
# List with `Get-WindowsCapability -Online`

# Match first part of string to full name with <name~~~~version>
function Install-WindowsCapabilityByName {
    param(
        [Parameter(Mandatory)]
        [string] $Name
    )

      $results = @(Get-WindowsCapability -Online -Name "$Name*")

      if ($results.Count -eq 0) {
        throw "Capability '$Name' was not found."
      }

      if ($results.Count -gt 1) {
        $results | Select-Object Name, State | Format-Table
        throw "Capability '$Name' matched multiple capabilities."
      }

      $capability = $results[0]

    if (-not $capability) {
        throw "Windows capability '$Name' was not found."
    }

    if ($capability.State -eq 'Installed') {
        Write-Host "Already installed: $($capability.Name)"
        return
    }

    Write-Host "Installing: $($capability.Name)"

    Add-WindowsCapability `
        -Online `
        -Name $capability.Name `
        -ErrorAction Stop
}

$capabilities = @(
    'OpenSSH.Client'
    'Microsoft.Windows.Notepad.System'
)

foreach ($capability in $capabilities) {
    Install-WindowsCapabilityByName $capability
}