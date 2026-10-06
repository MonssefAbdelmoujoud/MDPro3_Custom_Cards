param (
    [string]$MDProPath = $PSScriptRoot
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

# Finishers and special frames are card ID lists in MDPro3's own Data\SpecialCards.json
# (Data\Settings.json holds a second copy of the finisher lists).
# MDPro3 updates rewrite those files, so our card IDs are added to them instead of replacing them.
$SpecialAdditions = Join-Path $RepoFolder.FullName "SpecialCards_Custom.json"

if (Test-Path $SpecialAdditions) {
    Write-Host ""
    Write-Host "Adding custom cards to MDPro3's special card lists..."

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
Write-Host "You can now start MDPro3."