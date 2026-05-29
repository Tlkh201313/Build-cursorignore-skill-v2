# build-cursorignore

> Auto-generate `.cursorignore` and `.cursorindexingignore` for any project. One command, zero config.

[![Cursor Compatible](https://img.shields.io/badge/Cursor-Agent-blue?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZD0iTTEyIDJMMiA3bDEwIDUgMTAtNS0xMC01ek0yIDE3bDEwIDUgMTAtNU0yIDEybDEwIDUgMTAtNSIgZmlsbD0iI2ZmZiIvPjwvc3ZnPg==)](https://cursor.sh)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![npx skills](https://img.shields.io/badge/npx-skills-764abc?logo=nodedotjs)](https://github.com/vercel-labs/skills)

---

## What It Does

Scans your project root, detects the tech stack (24 stacks), and writes two ignore files that block junk from Cursor's AI context. Reduces indexing time and token consumption across **all models** — Claude, GPT-4o, Gemini.

| Output | Effect |
|--------|--------|
| `.cursorignore` | **Hard block** — AI cannot see or index these files |
| `.cursorindexingignore` | **Soft block** — excluded from indexing, but you can `@` them manually |

---

## Quick Start

### One-liner (copy into any AI agent)

```
npx skills add Tlkh201313/Build-cursorignore-skill-v2 -a cursor && echo "Run /build-cursorignore in Cursor Agent"
```

### Or install manually

```bash
npx skills add Tlkh201313/Build-cursorignore-skill-v2 -a cursor
```

Then in Cursor Agent:

```
/build-cursorignore
```

Done. Open a **new chat** to activate.

---

## Table of Contents

- [Install](#install)
- [Run](#run)
- [After Running](#after-running)
- [Verify It Works](#verify-it-works)
- [What Gets Blocked](#what-gets-blocked)
- [Supported Stacks](#supported-stacks)
- [Re-run Safe](#re-run-safe)
- [Update / Uninstall](#update--uninstall)
- [FAQ](#faq)

---

## Install

### Method 1: `npx skills add` (Recommended)

```bash
npx skills add Tlkh201313/Build-cursorignore-skill-v2 -a cursor
```

### Method 2: Manual Git Clone

```bash
git clone --depth 1 https://github.com/Tlkh201313/Build-cursorignore-skill-v2.git ~/.cursor/skills/build-cursorignore
```

---

## Run

Open Cursor Agent and type:

```
/build-cursorignore
```

Single pass — scans, detects stack, writes both files. No prompts, no confirmation.

---

## After Running

1. **Open a new Agent chat** — ignore files load on session start
2. **Wait for re-indexing** — ~30s on small repos, a few minutes on large ones
3. No restart needed

---

## Verify It Works

### Check indexing status

1. **Cursor Settings** → `Ctrl+Shift+J` (Windows) / `Cmd+Shift+J` (Mac)
2. Go to **Indexing** (or **Features → Codebase Indexing**)
3. Confirm indexed file count is lower than total

### Smoke test

In a new chat, ask `@Codebase` about something inside an ignored path (e.g., `node_modules/`). It should **not** appear in results.

> To force a file back in: `@` it directly. Works for `.cursorindexingignore` paths only.

---

## What Gets Blocked

### Always blocked (universal baseline)

| Category | Examples |
|----------|----------|
| Dependencies | `node_modules/`, `vendor/`, `bower_components/` |
| Build output | `dist/`, `build/`, `.next/`, `.nuxt/`, `target/` |
| Caches | `.cache/`, `__pycache__/`, `.turbo/`, `.gradle/` |
| Logs | `*.log`, `logs/`, `npm-debug.log*` |
| Coverage | `coverage/`, `.nyc_output/`, `htmlcov/` |
| Secrets | `.env.local`, `*.pem`, `*.key`, `secrets.json` |
| OS junk | `.DS_Store`, `Thumbs.db`, `desktop.ini` |
| Large binaries | `*.mp4`, `*.zip`, `*.tar.gz` |

### Stack-specific (auto-detected)

| Stack | Extra patterns |
|-------|---------------|
| Next.js | `.next/`, `*.tsbuildinfo` |
| Nuxt | `.nuxt/`, `.output/` |
| Python/Django | `db.sqlite3`, `staticfiles/`, `__pycache__/` |
| Rust | `target/` |
| Android | `.gradle/`, `build/`, `local.properties` |
| iOS/Swift | `Pods/`, `DerivedData/`, `xcuserdata/` |

See [assets/](assets/) for full template content.

---

## Supported Stacks

`js_ts` · `next_js` · `nuxt` · `vite` · `remix` · `svelte` · `astro` · `python` · `django` · `flask` · `java` · `kotlin` · `rust` · `go` · `php` · `ruby` · `rails` · `ios_swift` · `android` · `bun` · `deno` · `flutter` · `elixir` · `scala`

Monorepos: detects `package.json` in subfolders, merges all stacks.

---

## Re-run Safe

Uses managed blocks — your custom lines outside the block are never touched.

```
# >>> build-cursorignore:baseline BEGIN >>>
... (auto-generated content) ...
# <<< build-cursorignore:baseline END <<<
```

Run `/build-cursorignore` anytime to refresh the baseline.

---

## Update / Uninstall

```bash
# Update
npx skills update build-cursorignore

# Uninstall
npx skills remove build-cursorignore
```

---

## FAQ

**Q: Does this work with all Cursor models?**
Yes. Ignore files are model-agnostic — Claude, GPT-4o, Gemini all respect them.

**Q: Will this delete my existing `.cursorignore`?**
No. It only writes inside managed blocks. Your custom lines are safe.

**Q: Can I still `@` a blocked file?**
Only files in `.cursorindexingignore`. Files in `.cursorignore` are hard-blocked.

**Q: Do I need to duplicate `.gitignore` entries?**
No. Cursor auto-respects `.gitignore`.

**Q: Terminal commands can still read blocked files?**
Yes. `.cursorignore` only blocks AI context and indexing, not terminal access.

---

## License

MIT
