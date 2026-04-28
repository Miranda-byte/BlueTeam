# Ask user for folder names (comma-separated)
$inputFolders = Read-Host "Enter folder names (separated by commas)"

# Split input into an array and trim spaces
$folders = $inputFolders -split "," | ForEach-Object { $_.Trim() }

# Ask for base directory (optional)
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