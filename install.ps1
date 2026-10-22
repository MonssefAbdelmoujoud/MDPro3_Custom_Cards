param (
    [string]$MDProPath = $PSScriptRoot
)

$ProgressPreference = 'SilentlyContinue'

$RepoZipUrl = "https://github.com/MonssefAbdelmoujoud/MDPro3_Custom_Cards/archive/refs/heads/main.zip"

$TempDir = Join-Path $env:TEMP "MDPro_Custom_Cards_Update"
$ZipPath = Join-Path $TempDir "pack.zip"
$ExtractPath = Join-Path $TempDir "extracted"

Write-Host "====================================="
Write-Host " MDPro Custom Cards Installer"
Write-Host "====================================="
Write-Host ""

Write-Host "Using MDPro folder:"
Write-Host $MDProPath
Write-Host ""

if (!(Test-Path $MDProPath)) {
    Write-Host "ERROR: The MDPro folder does not exist:"
    Write-Host $MDProPath
    exit 1
}

foreach ($Required in @("Expansions", "Picture")) {
    if (!(Test-Path (Join-Path $MDProPath $Required))) {
        Write-Host "ERROR: This does not look like a valid MDPro folder."
        Write-Host "Missing folder:"
        Write-Host (Join-Path $MDProPath $Required)
        exit 1
    }
}

# The repo stores game data files under MDPro3_Data; MDPro4 keeps the same files under MDPro4_Data.
$DataFolder = Get-ChildItem $MDProPath -Directory -Filter "MDPro*_Data" | Sort-Object Name -Descending | Select-Object -First 1

if ($null -eq $DataFolder) {
    Write-Host "ERROR: No MDPro3_Data or MDPro4_Data folder was found in:"
    Write-Host $MDProPath
    exit 1
}

$DataFolderName = $DataFolder.Name
$IsMDPro3 = $DataFolderName -eq "MDPro3_Data"
Write-Host "Detected game data folder: $DataFolderName"
Write-Host ""

$GameName = $DataFolderName -replace '_Data$', ''
if (Get-Process -Name $GameName -ErrorAction SilentlyContinue) {
    Write-Host "ERROR: $GameName is running. Close the game and run the installer again."
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

$OverFrameIds = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
$FilesToInstall | Where-Object { $_.Directory.Name -eq "OverFrame" } | ForEach-Object { [void]$OverFrameIds.Add($_.BaseName) }

$InstallList = foreach ($File in $FilesToInstall) {
    $RelativePath = $File.FullName.Substring($SourceRoot.Length).TrimStart('\', '/') -replace '/', '\'
    # Cut-in bundles (MDPro3_Data\StandaloneWindows64\MonsterCutin2) go to this game's own data folder
    $RelativePath = $RelativePath -replace '^MDPro\d+_Data(?=\\)', $DataFolderName
    # MDPro4 only reads .png from Picture\Art2 and takes .jpg artwork from Picture\Art.
    # Cards with an overframe image keep using that, so only the others are moved.
    if (!$IsMDPro3 -and $RelativePath -match '^Picture\\Art2\\[^\\]+\.jpe?g$' -and !$OverFrameIds.Contains($File.BaseName)) {
        $RelativePath = "Picture\Art\" + $File.Name
    }
    [pscustomobject]@{ Source = $File.FullName; RelativePath = $RelativePath }
}

$PlannedPaths = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
$InstallList | ForEach-Object { [void]$PlannedPaths.Add($_.RelativePath) }

# Duplicates are moved to a backup folder instead of being deleted, so nothing is lost.
$ManifestPath = Join-Path $MDProPath "CustomCards_Installed.txt"
$BackupRoot = Join-Path $MDProPath ("CustomCards_Backup\" + (Get-Date -Format "yyyyMMdd-HHmmss"))
$MovedCount = 0

function Move-ToBackup([string]$RelativePath, [string]$Reason) {
    $Source = Join-Path $MDProPath $RelativePath
    if (!(Test-Path $Source -PathType Leaf)) { return }
    $Destination = Join-Path $BackupRoot $RelativePath
    New-Item -ItemType Directory -Path (Split-Path $Destination -Parent) -Force | Out-Null
    Move-Item $Source $Destination -Force
    $script:MovedCount++
    Write-Host "Removed duplicate: $RelativePath ($Reason)"
}

Write-Host "Checking for duplicate and outdated custom card files..."

# Files a previous run installed that are no longer part of the pack (renamed, moved or deleted in the repo)
if (Test-Path $ManifestPath) {
    foreach ($OldPath in [IO.File]::ReadAllLines($ManifestPath)) {
        if ($OldPath -and !$PlannedPaths.Contains($OldPath)) {
            Move-ToBackup $OldPath "no longer in the pack"
        }
    }
}

# Older pack layouts put card images, scripts, overframes and cut-ins loose in Expansions\.
# The pack now installs them elsewhere, so loose copies with the same name are doubles.
$PlannedElsewhere = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
$InstallList | Where-Object { (Split-Path $_.RelativePath -Parent) -ne "Expansions" } |
    ForEach-Object { [void]$PlannedElsewhere.Add((Split-Path $_.RelativePath -Leaf)) }

foreach ($Loose in Get-ChildItem (Join-Path $MDProPath "Expansions") -File) {
    $LoosePath = "Expansions\" + $Loose.Name
    if (!$PlannedPaths.Contains($LoosePath) -and $PlannedElsewhere.Contains($Loose.Name)) {
        Move-ToBackup $LoosePath "the pack installs this file in another folder"
    }
}

if ($MovedCount -eq 0) {
    Write-Host "No duplicates found."
}

Write-Host ""
Write-Host "Installing custom card files..."
Write-Host ""

foreach ($Item in $InstallList) {
    $RelativePath = $Item.RelativePath
    $TargetFile = Join-Path $MDProPath $RelativePath
    $TargetFolder = Split-Path $TargetFile -Parent

    if (!(Test-Path $TargetFolder)) {
        New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
    }

    Copy-Item $Item.Source $TargetFile -Force
    Write-Host "Installed: $RelativePath"
}

# Remember what was installed so the next update can remove files the pack no longer has
[IO.File]::WriteAllLines($ManifestPath, [string[]]@($InstallList | ForEach-Object { $_.RelativePath }))

# Finishers are card ID lists in the game's own Data\SpecialCards.json
# (Data\Settings.json holds a second copy of the finisher lists).
# Game updates rewrite those files, so our card IDs are added to them instead of replacing them.
$SpecialAdditions = Join-Path $RepoFolder.FullName "SpecialCards_Custom.json"

if (Test-Path $SpecialAdditions) {
    Write-Host ""
    Write-Host "Adding custom cards to the game's special card lists..."

    foreach ($DataFile in @("Data\SpecialCards.json", "Data\Settings.json")) {
        $SpecialFile = Join-Path $MDProPath $DataFile
        if (!(Test-Path $SpecialFile)) { continue }

        try {
            $Original = [IO.File]::ReadAllText($SpecialFile)
            $Text = $Original
            $NL = if ($Original.Contains("`r`n")) { "`r`n" } else { "`n" }
            $Additions = [IO.File]::ReadAllText($SpecialAdditions) | ConvertFrom-Json -ErrorAction Stop
            $AddedCount = 0

            foreach ($Prop in $Additions.PSObject.Properties) {
                $Key = $Prop.Name

                # MDPro4 retired the Frame* lists; frames are chosen in the Card appearance menu instead
                if (!$IsMDPro3 -and $Key -like "Frame*") {
                    if ($DataFile -eq "Data\SpecialCards.json") {
                        Write-Host "Skipped: $Key (frame lists are not used by $GameName, pick the frame in Card appearance)"
                    }
                    continue
                }

                $Ids = @($Prop.Value | ForEach-Object { [int]$_ })
                $Match = [regex]::Match($Text, '"' + [regex]::Escape($Key) + '"\s*:\s*\[([^\]]*)\]')

                if ($Match.Success) {
                    $Existing = @([regex]::Matches($Match.Groups[1].Value, '\d+') | ForEach-Object { [int]$_.Value })
                    $Missing = @($Ids | Where-Object { $Existing -notcontains $_ })
                    if ($Missing.Count -eq 0) { continue }
                    $List = $Existing + $Missing
                    $New = '"' + $Key + '": [' + $NL + '    ' + ($List -join (',' + $NL + '    ')) + $NL + '  ]'
                    $Text = $Text.Substring(0, $Match.Index) + $New + $Text.Substring($Match.Index + $Match.Length)
                    $AddedCount += $Missing.Count
                }
                elseif ($DataFile -eq "Data\SpecialCards.json") {
                    # Only SpecialCards.json gets lists it does not have yet; Settings.json is only extended
                    $New = '{' + $NL + '  "' + $Key + '": [' + $NL + '    ' + ($Ids -join (',' + $NL + '    ')) + $NL + '  ],'
                    $Text = ([regex]'\{').Replace($Text, $New, 1)
                    $AddedCount += $Ids.Count
                }
            }

            if ($Text -ne $Original) {
                $null = $Text | ConvertFrom-Json -ErrorAction Stop
                [IO.File]::WriteAllText($SpecialFile, $Text, (New-Object Text.UTF8Encoding($false)))
                Write-Host "Installed: $DataFile ($AddedCount card IDs added)"
            }
            else {
                Write-Host "$DataFile is already up to date."
            }
        }
        catch {
            Write-Host "WARNING: Could not update $DataFile, it was left unchanged."
            Write-Host $_.Exception.Message
        }
    }
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
if ($MovedCount -gt 0) {
    Write-Host "$MovedCount duplicate file(s) were moved to:"
    Write-Host $BackupRoot
    Write-Host "You can delete that folder once the game works."
    Write-Host ""
}
Write-Host "You can now start $GameName."
