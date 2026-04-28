$inputFolders = Read-Host "Enter folder names (separated by commas)"

$folders = $inputFolders -split "," | ForEach-Object { $_.Trim() }

$basePath = Read-Host "Enter base path (leave blank for current directory)"
if ([string]::IsNullOrWhiteSpace($basePath)) {
    $basePath = Get-Location
}

# Create folders
foreach ($folder in $folders) {
    if ($folder -ne "") {
        $fullPath = Join-Path -Path $basePath -ChildPath $folder

        if (-not (Test-Path $fullPath)) {
            New-Item -ItemType Directory -Path $fullPath | Out-Null
            Write-Host "Created: $fullPath"
        } else {
            Write-Host "Already exists: $fullPath"
        }
    }
}

Write-Host "Done."
