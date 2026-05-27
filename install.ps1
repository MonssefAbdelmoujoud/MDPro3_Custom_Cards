param (
    [Parameter(Mandatory=$true)]
    [string]$MDProPath
)

$RepoZipUrl = "https://github.com/MonssefAbdelmoujoud/MDPro3_Custom_Cards/archive/refs/heads/main.zip"

$TempDir = Join-Path $env:TEMP "MDPro3_Custom_Cards_Update"
$ZipPath = Join-Path $TempDir "pack.zip"
$ExtractPath = Join-Path $TempDir "extracted"

Write-Host "====================================="
Write-Host " MDPro3 Custom Cards Installer"
Write-Host "====================================="
Write-Host ""

if (!(Test-Path $MDProPath)) {
    Write-Host "ERROR: The MDPro3 folder does not exist:"
    Write-Host $MDProPath
    exit 1
}

if (!(Test-Path (Join-Path $MDProPath "Expansions"))) {
    Write-Host "ERROR: This does not look like a valid MDPro3 folder."
    Write-Host "Missing folder: Expansions"
    exit 1
}

if (Test-Path $TempDir) {
    Remove-Item $TempDir -Recurse -Force
}

New-Item -ItemType Directory -Path $TempDir | Out-Null
New-Item -ItemType Directory -Path $ExtractPath | Out-Null

Write-Host "Downloading latest custom cards from GitHub..."
Invoke-WebRequest -Uri $RepoZipUrl -OutFile $ZipPath

Write-Host "Extracting..."
Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath

$RepoFolder = Get-ChildItem $ExtractPath | Select-Object -First 1
$SourceRoot = Join-Path $RepoFolder.FullName "MDPro3Files"

if (!(Test-Path $SourceRoot)) {
    Write-Host "ERROR: MDPro3Files folder was not found in the downloaded repo."
    exit 1
}

$BackupRoot = Join-Path $MDProPath ("Backup_CustomCards_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
New-Item -ItemType Directory -Path $BackupRoot | Out-Null

Write-Host "Backup folder created:"
Write-Host $BackupRoot
Write-Host ""

$FilesToInstall = Get-ChildItem $SourceRoot -Recurse -File

Write-Host "Backing up files that will be replaced..."

foreach ($File in $FilesToInstall) {
    $RelativePath = $File.FullName.Substring($SourceRoot.Length).TrimStart('\', '/')
    $TargetFile = Join-Path $MDProPath $RelativePath

    if (Test-Path $TargetFile) {
        $BackupFile = Join-Path $BackupRoot $RelativePath
        $BackupFolder = Split-Path $BackupFile -Parent

        if (!(Test-Path $BackupFolder)) {
            New-Item -ItemType Directory -Path $BackupFolder -Force | Out-Null
        }

        Copy-Item $TargetFile $BackupFile -Force
    }
}

Write-Host "Installing files..."

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
Write-Host "====================================="
Write-Host " Installation complete!"
Write-Host "====================================="
Write-Host ""
Write-Host "Backup saved here:"
Write-Host $BackupRoot
Write-Host ""
Write-Host "You can now start MDPro3."