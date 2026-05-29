# build-cursorignore — Overview

## Output

| File | What it is |
|------|-----------|
| `.cursorignore` | Blocks listed paths from AI context AND indexing. Hard exclusion. |
| `.cursorindexingignore` | Blocks from indexing only. Files can still be `@referenced` manually. |

## Why This Matters

Every file Cursor loads into context costs tokens. `node_modules` alone can contain 30,000+ files. Excluding it can reduce indexing from 5 minutes to 30 seconds and AI query time by 60%+. This skill automates the configuration so you never forget.

## What It Does

1. Scans your project root (read-only — no files edited during scan)
2. Detects tech stack from signal files (19 stacks: JS/TS, Next.js, Nuxt, Python, Django, Flask, Java, Kotlin, Rust, Go, PHP, Ruby, Rails, iOS/Swift, Android, and more)
3. Detects noise directories actually present in your project
4. Writes `.cursorignore` with managed blocks (universal baseline + stack-specific + detected noise)
5. Writes `.cursorindexingignore` with managed blocks (superset: includes test fixtures, generated code, lockfiles, API specs)
6. Reports what was written in plain English

## Managed Blocks

Both files use managed block markers:

```
# >>> build-cursorignore:baseline BEGIN >>>
... (content managed by skill) ...
# <<< build-cursorignore:baseline END <<<

# >>> build-cursorignore:indexing BEGIN >>>
... (content managed by skill) ...
# <<< build-cursorignore:indexing END <<<
```

Lines outside the managed block are never touched. Safe to re-run.
