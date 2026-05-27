param (
    [string]$MDProPath = "$env:USERPROFILE\Desktop\MDPro3"
)

$ProgressPreference = 'SilentlyContinue'

$RepoZipUrl = "https://github.com/MonssefAbdelmoujoud/MDPro3_Custom_Cards/archive/refs/heads/main.zip"

$TempDir = Join-Path $env:TEMP "MDPro3_Custom_Cards_Update"
$ZipPath = Join-Path $TempDir "pack.zip"
$ExtractPath = Join-Path $TempDir "extracted"

Write-Host "====================================="
Write-Host " MDPro3 Custom Cards Installer"
Write-Host "====================================="
Write-Host ""

Write-Host "Using MDPro3 folder:"
Write-Host $MDProPath
Write-Host ""

if (!(Test-Path $MDProPath)) {
    Write-Host "ERROR: The MDPro3 folder does not exist:"
    Write-Host $MDProPath
    Write-Host ""
    Write-Host "Make sure your MDPro3 folder is on your Desktop and named exactly:"
    Write-Host "MDPro3"
    exit 1
}

if (!(Test-Path (Join-Path $MDProPath "Expansions"))) {
    Write-Host "ERROR: This does not look like a valid MDPro3 folder."
    Write-Host "Missing folder:"
    Write-Host (Join-Path $MDProPath "Expansions")
    exit 1
}

if (!(Test-Path (Join-Path $MDProPath "Picture"))) {
    Write-Host "ERROR: This does not look like a valid MDPro3 folder."
    Write-Host "Missing folder:"
    Write-Host (Join-Path $MDProPath "Picture")
    exit 1
}

if (Test-Path $TempDir) {
    Remove-Item $TempDir -Recurse -Force
}

New-Item -ItemType Directory -Path $TempDir | Out-Null
New-Item -ItemType Directory -Path $ExtractPath | Out-Null

Write-Host "Downloading latest custom cards from GitHub..."

try {
    Invoke-WebRequest -Uri $RepoZipUrl -OutFile $ZipPath -UseBasicParsing
}
catch {
    Write-Host ""
    Write-Host "ERROR: Failed to download files from GitHub."
    Write-Host $_.Exception.Message
    exit 1
}

Write-Host "Download complete."
Write-Host "Extracting files..."

try {
    Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force
}
catch {
    Write-Host ""
    Write-Host "ERROR: Failed to extract downloaded zip file."
    Write-Host $_.Exception.Message
    exit 1
}

$RepoFolder = Get-ChildItem $ExtractPath | Select-Object -First 1
$SourceRoot = Join-Path $RepoFolder.FullName "MDPro3Files"

if (!(Test-Path $SourceRoot)) {
    Write-Host ""
    Write-Host "ERROR: MDPro3Files folder was not found in the downloaded repo."
    Write-Host "Expected location:"
    Write-Host $SourceRoot
    exit 1
}

$FilesToInstall = Get-ChildItem $SourceRoot -Recurse -File

if ($FilesToInstall.Count -eq 0) {
    Write-Host ""
    Write-Host "ERROR: No files found inside MDPro3Files."
    exit 1
}

Write-Host "Installing custom card files..."
Write-Host ""

foreach ($File in $FilesToInstall) {
    $RelativePath = $File.FullName.Substring($SourceRoot.Length).TrimStart('\', '/')
    $TargetFile = Join-Path $MDProPath $RelativePath
    $TargetFolder = Split-Path $TargetFile -Parent

    if (!(Test-Path $TargetFolder)) {
        New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
    }

    Copy-Item $File.FullName $TargetFile -Force
    Write-Host "Installed: $RelativePath"
}

Write-Host ""
Write-Host "Cleaning temporary files..."

if (Test-Path $TempDir) {
    Remove-Item $TempDir -Recurse -Force
}

Write-Host ""
Write-Host "====================================="
Write-Host " Installation complete!"
Write-Host "====================================="
Write-Host ""
Write-Host "You can now start MDPro3."