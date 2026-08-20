<#
.SYNOPSIS
    This script configures all .winget files in the current working directory.
.DESCRIPTION
    This script requires administrative rights to work becasue some are installed for the whole system.
    It searches recursively in the working folder for .winget files and runs the winget configure command on each of them.
.EXAMPLE
    .\Configure-All.ps1
#>
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
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

$wingetFiles = Get-ChildItem -Path (Get-Location) -Filter '*.winget' -File -Recurse

if (-not $wingetFiles) {
    Write-Host 'No .winget files found in the current working directory.'
    exit 0
}

foreach ($file in $wingetFiles) {
    Write-Host "Validating $($file.Name)..."
    & winget configure --file $file.FullName --accept-configuration-agreements --disable-interactivity

    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
