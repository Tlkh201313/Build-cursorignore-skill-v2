# build-cursorignore

A Cursor Agent skill that scans your project, detects the tech stack, and writes `.cursorignore` and `.cursorindexingignore` to reduce AI token consumption. Works with all models — Claude, GPT-4o, Gemini.

## Install

### Method 1: `npx skills add` (Recommended)

```bash
# Global (available across all projects)
npx skills add owner/build-cursorignore -g -a cursor

# Project-local (committed with project)
npx skills add owner/build-cursorignore -a cursor
```

### Method 2: Install Scripts

**macOS / Linux / WSL:**

```bash
curl -fsSL https://raw.githubusercontent.com/owner/build-cursorignore/main/install.sh | bash
```

**Windows PowerShell:**

```powershell
irm https://raw.githubusercontent.com/owner/build-cursorignore/main/install.ps1 | iex
```

### Method 3: Manual Git Clone

```bash
# macOS / Linux
git clone --depth 1 https://github.com/owner/build-cursorignore.git /tmp/build-cursorignore
cp -r /tmp/build-cursorignore ~/.cursor/skills/build-cursorignore
rm -rf /tmp/build-cursorignore

# Windows PowerShell
git clone --depth 1 https://github.com/owner/build-cursorignore.git "$env:TEMP\build-cursorignore"
Copy-Item -Recurse "$env:TEMP\build-cursorignore" "$env:USERPROFILE\.cursor\skills\build-cursorignore"
Remove-Item -Recurse "$env:TEMP\build-cursorignore"
```

## Run

Open Cursor Agent and type:

```
/build-cursorignore
```

The skill scans your project root, detects the tech stack, and writes both ignore files in a single pass.

## What Gets Written

| File | Purpose |
|------|---------|
| `.cursorignore` | Blocks listed paths from AI context AND indexing. Hard exclusion. |
| `.cursorindexingignore` | Blocks from indexing only. Files can still be `@referenced` manually. |

Both files use managed blocks. Re-runs only touch content inside the managed block — your custom lines are never overwritten.

## After Running

Open a **new** Cursor chat. Ignore files take effect on the next session load.

## Re-run Safe

Uses managed blocks — user lines outside the block are never touched. Run `/build-cursorignore` anytime to update the baseline.

## Update

```bash
npx skills update build-cursorignore
```

Or re-run the install script — it replaces the existing installation.

## Uninstall

```bash
npx skills remove build-cursorignore
```

Or delete the skill folder manually:

```bash
# macOS / Linux
rm -rf ~/.cursor/skills/build-cursorignore

# Windows
Remove-Item -Recurse "$env:USERPROFILE\.cursor\skills\build-cursorignore"
```

## Works With All Models

Claude, GPT-4o, Gemini — ignore files are model-agnostic. They reduce token consumption regardless of which model you use in Cursor.
