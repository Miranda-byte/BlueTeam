$inputFolders = Read-Host "Enter the name of the file you want to load"
$folders = Get-Content $inputFolders

$filetype = Read-Host "Would it be Directories or Files"

$basePath = Read-Host "Enter base path (leave blank for current directory)"
if ([string]::IsNullOrWhiteSpace($basePath)) {
    $basePath = Get-Location
}

# Create folders
foreach ($folder in $folders) {
    if ($folder -ne "") {
        $fullPath = Join-Path -Path $basePath -ChildPath $folder
        if (-not (Test-Path $fullPath)) {
            New-Item -ItemType $filetype -Path $fullPath | Out-Null
            Write-Host "Created: $fullPath"
        } else {
            Write-Host "Already exists: $fullPath"
        }
    }
}
Write-Host "Done."
