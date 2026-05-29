param(
  [switch]$Uninstall
)

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

if (-not (Test-Path $CursorSkillsDir)) {
  New-Item -ItemType Directory -Path $CursorSkillsDir -Force | Out-Null
}

if (Test-Path $InstallDir) {
  Remove-Item -Recurse -Force $InstallDir
  Write-Host "Removed existing installation"
}

$TmpDir = Join-Path $env:TEMP "build-cursorignore-install"
if (Test-Path $TmpDir) { Remove-Item -Recurse -Force $TmpDir }

try {
  git clone --depth 1 $RepoUrl "$TmpDir\$SkillName"
  Copy-Item -Recurse "$TmpDir\$SkillName" $InstallDir
  Write-Host "Installed to $InstallDir"
  Write-Host "Run /build-cursorignore in Cursor Agent to use."
} finally {
  if (Test-Path $TmpDir) { Remove-Item -Recurse -Force $TmpDir }
}
