<#
.SYNOPSIS
    Install Texas Instruments AM243x SDK and dependencies
.DESCRIPTION
    Downloads and runs the installers from TI silently in the background.
    Can be configured to delete them afterwards, but that is deisbled by default.
    Versions are fixed, but can be changed by swapping download URLs.
    Requires administrative priveleges to execute some installers.
.EXAMPLE
    .\Install-AM243X.ps1
#>

Set-location $env:USERPROFILE\Downloads

# Download links for the files (click "Download options" on TI website)
$installerURLs = @(
    "https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-ayxs93eZNN/4.0.5.LTS/ti_cgt_armllvm_4.0.5.LTS_windows-x64_installer.exe",
    "https://dr-download.ti.com/software-development/software-development-kit-sdk/MD-ouHbHEm1PK/10.00.00.20/mcu_plus_sdk_am243x_10_00_00_20-windows-x64-installer.exe",
    "https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-nsUM6f7Vvb/1.21.2.3837/sysconfig-1.21.2_3837-setup.exe",
    "https://dr-download.ti.com/software-development/software-programming-tool/MD-QeJBJLj8gq/8.8.1/uniflash_sl.8.8.1.4983.exe",
    "https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-FaNNGkDH7s/2.3.3/ti_cgt_pru_2.3.3_windows_installer.exe"
)

# Extract filenames from URLs
# "Split-Path -Leaf" strips everything and leaves only the final portion (the filename)
$outFileNames = foreach ($url in $installerURLs) {
    Split-Path -Leaf $url
}

# Array to keep track of specific background download jobs
$bitsJobs = @()

# Iterate using an indexed For-Loop to start downloads
Write-Host "Starting asynchronous downloads..." -ForegroundColor Cyan
for ($i = 0; $i -lt $installerURLs.Count; $i++) {
    $url = $installerURLs[$i]
    $file = $outFileNames[$i]
    
    Write-Host " -> Queuing $file"
    # Start the download in the background and save the job reference
    $bitsJobs += Start-BitsTransfer -Source $url -Destination ".\$file" -Asynchronous
}

# Wait for all background downloads to finish
Write-Host "`nWaiting for downloads to complete..." -ForegroundColor Yellow
while ($bitsJobs | Where-Object { $_.JobState -in 'Connecting', 'Transferring' }) {
    Start-Sleep -Seconds 2
    Write-Host -NoNewline "."
}

# Finalize the files on disk
# BITS requires you to 'Complete' the transfer, which renames the temp files to their final names
$bitsJobs | Where-Object JobState -eq 'Transferred' | Complete-BitsTransfer
Write-Host "`nDownloads Finished!" -ForegroundColor Green

# Iterate again to install sequentially
Write-Host "`nStarting Unattended Installations to C:\ti..." -ForegroundColor Cyan
for ($i = 0; $i -lt $outFileNames.Count; $i++) {
    $exe = $outFileNames[$i]
    $arguments = "--debuglevel 3 --mode unattended --installer-language en --prefix C:\ti"
    
    Write-Host " -> Installing $exe..." -ForegroundColor Yellow
    
    # We use Start-Process -Wait so the script pauses until the installer completely finishes
    # This prevents multiple MSI/Installers from running at once and corrupting the system
    Start-Process -FilePath ".\$exe" -ArgumentList $arguments -Wait -NoNewWindow
}

# Grab random executables TI requires
Write-Host "Downloading dfu-util..." -ForegroundColor Cyan
$dfuUtilURL = "http://dfu-util.sourceforge.net/releases/dfu-util-0.8-binaries/win32-mingw32/dfu-util-static.exe"
$dfuUtilPath = "C:\ti\dfu-util.exe"
Start-BitsTransfer -Source $dfuUtilURL -Destination $dfuUtilPath

Write-Host "Downloading zadig..." -ForegroundColor Cyan
$zadigURL = "https://github.com/pbatard/libwdi/releases/download/v1.4.1/zadig-2.7.exe"
$zadigPath = "C:\ti\zadig-2.7.exe"
Start-BitsTransfer -Source $zadigURL -Destination $zadigPath

# Uncomment to remove your downloaded installers
# Remove-Item *.exe
