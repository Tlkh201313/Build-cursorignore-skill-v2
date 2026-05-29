# build-cursorignore

A Cursor Agent skill that scans your project, detects the tech stack, and writes `.cursorignore` and `.cursorindexingignore` to reduce AI token consumption. Works with all models — Claude, GPT-4o, Gemini.

---

## Quick Start (AI Agent Prompt)

Copy-paste this into any AI agent (Cursor, Claude, ChatGPT, etc.) to set up automatically:

```
Install the build-cursorignore skill for Cursor Agent.

Steps:
1. Run: npx skills add Tlkh201313/Build-cursorignore-skill-v2 -a cursor
2. Open Cursor Agent chat
3. Type: /build-cursorignore
4. Wait for it to scan and write .cursorignore + .cursorindexingignore
5. Open a new Cursor chat to activate the ignore files

Done. The skill auto-detects your tech stack and blocks junk files from AI context.
```

---

## Install

### Method 1: `npx skills add` (Recommended)

```bash
# Project-local (committed with project)
npx skills add Tlkh201313/Build-cursorignore-skill-v2 -a cursor

# Global (available across all projects)
npx skills add Tlkh201313/Build-cursorignore-skill-v2 -g -a cursor
```

### Method 2: Install Scripts

**macOS / Linux / WSL:**

```bash
curl -fsSL https://raw.githubusercontent.com/Tlkh201313/Build-cursorignore-skill-v2/main/install.sh | bash
```

**Windows PowerShell:**

```powershell
irm https://raw.githubusercontent.com/Tlkh201313/Build-cursorignore-skill-v2/main/install.ps1 | iex
```

### Method 3: Manual Git Clone

```bash
# macOS / Linux
git clone --depth 1 https://github.com/Tlkh201313/Build-cursorignore-skill-v2.git /tmp/build-cursorignore
cp -r /tmp/build-cursorignore ~/.cursor/skills/build-cursorignore
rm -rf /tmp/build-cursorignore

# Windows PowerShell
git clone --depth 1 https://github.com/Tlkh201313/Build-cursorignore-skill-v2.git "$env:TEMP\build-cursorignore"
Copy-Item -Recurse "$env:TEMP\build-cursorignore" "$env:USERPROFILE\.cursor\skills\build-cursorignore"
Remove-Item -Recurse "$env:TEMP\build-cursorignore"
```

---

## Run

Open Cursor Agent and type:

```
/build-cursorignore
```

The skill scans your project root, detects the tech stack, and writes both ignore files in a single pass.

---

## How It Works

| File | Effect |
|------|--------|
| `.cursorignore` | **Hard block** — excluded from AI context AND indexing. Files are invisible to all models. |
| `.cursorindexingignore` | **Soft block** — excluded from search indexing only. You can still `@` a file to reference it manually. |

> Cursor also respects `.gitignore` automatically — no need to duplicate those entries.

---

## After Running

1. **Open a new Agent chat** (recommended — ignore files load on session start)
2. **Wait for re-indexing** (~30s on small repos, a few minutes on large ones)
3. You usually don't need to restart Cursor

---

## Verify Indexing Respects Ignores

### Check indexing status

1. Open **Cursor Settings** (`Ctrl+Shift+J` on Windows / `Cmd+Shift+J` on Mac)
2. Go to **Indexing** (or **Features → Codebase Indexing** depending on version)
3. Look for indexed file count, progress bar, or "up to date"

> If indexing is off, turn **Codebase Indexing** on for this workspace.

### Quick smoke test

In a new chat, use `@Codebase` and ask about something that only exists inside an ignored path (e.g., `node_modules/` or `graphify-out/`). It should **not** appear in retrieval.

To force a path back in: `@` the file directly. Works for `.cursorindexingignore` paths. Does **not** work for `.cursorignore` hard blocks.

---

## If Behavior Looks Stale

- **Settings → Indexing** → look for **Re-index** / **Sync** / **Refresh** (wording varies by version)
- Or close and reopen the folder: **File → Close Folder**, then reopen the project

---

## What Gets Written

| File | Purpose |
|------|---------|
| `.cursorignore` | Blocks listed paths from AI context AND indexing. Hard exclusion. |
| `.cursorindexingignore` | Blocks from indexing only. Files can still be `@referenced` manually. |

Both files use managed blocks. Re-runs only touch content inside the managed block — your custom lines are never overwritten.

---

## Re-run Safe

Uses managed blocks — user lines outside the block are never touched. Run `/build-cursorignore` anytime to update the baseline.

---

## Update

```bash
npx skills update build-cursorignore
```

Or re-run the install script — it replaces the existing installation.

---

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

---

## Works With All Models

Claude, GPT-4o, Gemini — ignore files are model-agnostic. They reduce token consumption regardless of which model you use in Cursor.
