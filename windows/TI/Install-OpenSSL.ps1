<#
.SYNOPSIS
    Downloads and silently installs the latest Win64 OpenSSL Light installer.
.DESCRIPTION
    This script connects to the SLProWeb JSON endpoint, finds the latest Win64 Light
    EXE installer, downloads it to C:\TEMP, and then runs the installer silently.
    
    This script automatically checks for Administrative privileges at startup. If 
    run from a non-admin session, it will prompt for elevation (UAC) and relaunch itself.
#>

# Stop the script if any command fails
$ErrorActionPreference = "Stop"

# =========================================================================
# PHASE 0: Self-Elevation Check (UAC Prompt if Needed)
# =========================================================================
$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "This script requires Administrator privileges. Requesting elevation..." -ForegroundColor Yellow
    
    # Capture the exact path to this script and any arguments passed to it
    $scriptPath = $MyInvocation.MyCommand.Path
    $arguments = $MyInvocation.UnboundArguments
    
    # Relaunch PowerShell as Admin, pointing back to this exact script
    try {
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"", $arguments -Verb RunAs
    } catch {
        Write-Error "Elevation request was denied by the user. Exiting."
    }
    
    # Exit the original, non-elevated script session immediately
    Exit
}

# =========================================================================
# PHASE 1: Fetch and Parse the JSON Manifest
# =========================================================================
Write-Host "Running with full Administrative privileges." -ForegroundColor Green
Write-Host "Fetching the official OpenSSL installer manifest..." -ForegroundColor Cyan
$jsonUrl = "https://slproweb.com/download/win32_openssl_hashes.json"

try {
    # Invoke-RestMethod automatically parses JSON into a PowerShell object
    $manifest = Invoke-RestMethod -Uri $jsonUrl
} catch {
    Write-Error "Failed to fetch or parse the JSON manifest from $jsonUrl. The site might be down or the URL has changed."
    return # Exit if fetching fails
}

# =========================================================================
# PHASE 2: Find the Correct Installer in the Manifest
# =========================================================================
Write-Host "Searching for the latest Win64 OpenSSL Light EXE..." -ForegroundColor Cyan
$allFileObjects = $manifest.files.psobject.Properties.Value

$candidateFiles = $allFileObjects | Where-Object {
    $_.PSObject.Properties.Name -contains 'basever' -and
    $_.arch -eq 'INTEL' -and
    $_.bits -eq 64 -and
    $_.light -eq $true -and
    $_.installer -eq 'exe'
}

if ($null -eq $candidateFiles) {
    Write-Error "No installers matched the specified criteria (Win64, Light, Intel, EXE)."
    return
}

# Sort by numeric base version, then by alphabetical patch letter
$latestFile = $candidateFiles | Sort-Object -Property @{Expression={[version]$_.basever}}, @{Expression={$_.subver}} -Descending | Select-Object -First 1

if (-not $latestFile) {
    Write-Error "Could not determine the latest version from the filtered candidates."
    return
}

# =========================================================================
# PHASE 3: Download the Installer to C:\TEMP
# =========================================================================
$fullUrl = $latestFile.url
$fileName = Split-Path -Leaf $fullUrl
$tempDir = "C:\TEMP"

# Ensure the C:\TEMP directory exists before downloading
if (-not (Test-Path -Path $tempDir -PathType Container)) {
    Write-Host "Creating directory: $tempDir" -ForegroundColor Yellow
    New-Item -Path $tempDir -ItemType Directory | Out-Null
}
$localPath = Join-Path $tempDir $fileName

Write-Host "Found latest version: $fileName" -ForegroundColor Green
Write-Host "Downloading to $localPath..." -ForegroundColor Cyan
Start-BitsTransfer -Source $fullUrl -Destination $localPath
Write-Host "Download complete!" -ForegroundColor Green

# =========================================================================
# PHASE 4: Silently Install with Custom Task Selection
# =========================================================================
Write-Host "Starting silent installation..." -ForegroundColor Yellow

$installerArgs = @(
    "/VERYSILENT",
    "/SP-",
    "/NOCANCEL",
    "/NORESTART",
    "/TASKS=""bin"""
)
$argumentString = $installerArgs -join " "

# Since the script is already elevated, -Verb RunAs is inherited automatically
Start-Process -FilePath $localPath -ArgumentList $argumentString -Verb RunAs -Wait

Write-Host "Cleaning up installer file..." -ForegroundColor Yellow
Remove-Item -Path $localPath -Force

# =========================================================================
# PHASE 5: Append OpenSSL to System PATH (if missing)
# =========================================================================
$targetFolder = "C:\Program Files\OpenSSL-Win64\bin"
Write-Host "Updating System PATH environment variable..." -ForegroundColor Cyan

# Fetch the raw System-level PATH
$rawPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

# Split and check if it already exists
$pathElements = $rawPath -split ';'
$alreadyExists = $pathElements -contains $targetFolder

if ($alreadyExists) {
    Write-Host " -> '$targetFolder' is already present in the System PATH." -ForegroundColor Green
} else {
    Write-Host " -> '$targetFolder' not found in PATH. Appending..." -ForegroundColor Yellow
    
    # Append securely
    $newPath = "$rawPath;$targetFolder"
    
    # Save permanently to the machine
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
    
    # Update local session variable
    $env:Path = "$env:Path;$targetFolder"
    
    Write-Host " -> System PATH updated successfully!" -ForegroundColor Green
}

Write-Host "`nOpenSSL installation complete!" -ForegroundColor Green
