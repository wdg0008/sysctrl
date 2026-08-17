# if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
#     $currentHost = (Get-Process -Id $PID).Path
#     $currentDirectory = (Get-Location).Path
#     $arguments = @(
#         '-NoProfile'
#         '-ExecutionPolicy', 'Bypass'
#         '-File', "`"$PSCommandPath`""
#     )

#     Start-Process -FilePath $currentHost -ArgumentList $arguments -WorkingDirectory $currentDirectory -Verb RunAs
#     exit
# }

$wingetFiles = Get-ChildItem -Path (Get-Location) -Filter '*.winget' -File

if (-not $wingetFiles) {
    Write-Host 'No .winget files found in the current working directory.'
    exit 0
}

foreach ($file in $wingetFiles) {
    Write-Host "Validating $($file.Name)..."
    & winget configure validate --file $file.FullName

    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
