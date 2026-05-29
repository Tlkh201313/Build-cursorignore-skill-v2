# Usage Guide

## How It Works

| File | Effect |
|------|--------|
| `.cursorignore` | **Hard block** — excluded from AI context AND indexing. Files are invisible to all models. |
| `.cursorindexingignore` | **Soft block** — excluded from search indexing only. You can still `@` a file to reference it manually. |

> **Note:** Cursor also respects `.gitignore` automatically — no need to duplicate those entries.

---

## Install

```bash
npx skills add Tlkh201313/Build-cursorignore-skill-v2 -a cursor
```

Then in Cursor Agent:

```
/build-cursorignore
```

The skill scans your project, detects the stack, and writes both ignore files in one pass.

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

Or delete the folder manually:

```bash
# macOS / Linux
rm -rf ~/.cursor/skills/build-cursorignore

# Windows
Remove-Item -Recurse "$env:USERPROFILE\.cursor\skills\build-cursorignore"
```

---

## If You Meant "Index" for Something Else

- **Linear / MCP tools** — connect in **Settings → MCP**, not codebase indexing
- **This skill repo** — no package.json; indexing is just your markdown/skill files minus ignored paths
