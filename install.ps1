param(
  [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
$SkillName = "build-cursorignore"
$CursorSkillsDir = Join-Path $env:USERPROFILE ".cursor\skills"
$InstallDir = Join-Path $CursorSkillsDir $SkillName
$RepoUrl = "https://github.com/Tlkh201313/Build-cursorignore-skill-v2.git"

if ($Uninstall) {
  if (Test-Path $InstallDir) {
    Remove-Item -Recurse -Force $InstallDir
    Write-Host "Removed $InstallDir"
  } else {
    Write-Host "Not installed: $InstallDir"
  }
  exit 0
}

# Check git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Host "Error: git is required. Install from https://git-scm.com" -ForegroundColor Red
  exit 1
}

# Create skills dir
if (-not (Test-Path $CursorSkillsDir)) {
  New-Item -ItemType Directory -Path $CursorSkillsDir -Force | Out-Null
}

# Remove old install
if (Test-Path $InstallDir) {
  Remove-Item -Recurse -Force $InstallDir
  Write-Host "Removed existing installation"
}

# Clone to temp
$TmpDir = Join-Path $env:TEMP "build-cursorignore-install"
if (Test-Path $TmpDir) { Remove-Item -Recurse -Force $TmpDir }

try {
  git clone --depth 1 $RepoUrl "$TmpDir\$SkillName"
  if (-not (Test-Path "$TmpDir\$SkillName\SKILL.md")) {
    Write-Host "Error: Clone succeeded but SKILL.md not found" -ForegroundColor Red
    exit 1
  }
  Copy-Item -Recurse "$TmpDir\$SkillName" $InstallDir
  Write-Host "Installed to $InstallDir" -ForegroundColor Green
  Write-Host "Run /build-cursorignore in Cursor Agent to use."
} catch {
  Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
} finally {
  if (Test-Path $TmpDir) { Remove-Item -Recurse -Force $TmpDir }
}
