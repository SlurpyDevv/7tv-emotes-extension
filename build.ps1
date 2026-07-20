Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

$zipPath = Join-Path $PSScriptRoot '..\extension-upload.zip'
if (Test-Path $zipPath) { Remove-Item -LiteralPath $zipPath -Force }

$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
$base = $PSScriptRoot

foreach ($f in @('panel.html', 'video_overlay.html', 'config.html', 'privacy_policy.html')) {
    $full = Join-Path $base $f
    if (Test-Path $full) {
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $full, $f) | Out-Null
    }
}

foreach ($dir in @('css', 'js', 'img')) {
    Get-ChildItem (Join-Path $base $dir) -Recurse -File | ForEach-Object {
        $entry = $_.FullName.Substring($base.Length + 1) -replace '\\', '/'
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, $entry) | Out-Null
    }
}

$zip.Dispose()
Write-Host "Built extension-upload.zip"
