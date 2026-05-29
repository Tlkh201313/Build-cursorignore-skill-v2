# Plan: Build the `build-cursorignore` Cursor Skill

## What This Skill Does

A Cursor Agent skill that scans a project root, detects the tech stack, and writes two ignore files to reduce AI token consumption across all models (Claude, GPT-4o, Gemini).

**Trigger:** `/build-cursorignore` in Cursor Agent

**Outputs:**
- `.cursorignore` — blocks files from AI context AND indexing (hard block)
- `.cursorindexingignore` — blocks files from indexing only (soft block, can still @reference)

---

## Research Findings

### `.cursorignore` vs `.cursorindexingignore` (current as of 2025)

| Aspect | `.cursorignore` | `.cursorindexingignore` |
|--------|-----------------|------------------------|
| **Scope** | Blocks from AI features AND indexing | Blocks from indexing only |
| **AI access** | AI cannot read, reference, or use these files | AI can still read if explicitly referenced (@Files) |
| **Indexing** | Files not indexed | Files not indexed |
| **@-symbols** | Not available through @-symbols | Can still be manually referenced |
| **Use case** | Secrets, credentials, useless files (node_modules, build artifacts) | Large generated files, test fixtures, lockfiles |
| **Security level** | Hard block (best-effort) | Soft block (indexing only) |
| **Introduced** | Behavior changed in v0.46 to be more aggressive | Introduced in v0.46 to replace old .cursorignore indexing-only behavior |

### Key Gotchas

1. **`.cursorignore` is best-effort, not guaranteed.** Official docs: "We do not guarantee that files in it are blocked from being sent up."
2. **Negation patterns (`!`) are fragile in Cursor 1.6+.** Multiple sources report breakage.
3. **Leading dots in directory names are dangerous.** `.claude/` can block EVERYTHING in 1.6.x.
4. **`.gitignore` is automatically respected.** No need to duplicate entries.
5. **Terminal and MCP are NOT limited by `.cursorignore`.** Agent can still read blocked files through terminal commands.
6. **The filename is `.cursorindexingignore` (with "ing")** — not `.cursorindexignore`.
7. **Managed blocks are NOT a documented Cursor feature.** They're a skill convention for surgical re-runs.

### Sources

| # | URL | Key Contribution |
|---|-----|-----------------|
| 1 | https://cursor-ai.cadn.net.cn/context_ignore-files.en.html | Official docs mirror — behavior spec, default ignore list |
| 2 | https://eastondev.com/blog/en/posts/dev/20260115-cursor-codebase-index-optimization/ | Config templates, monorepo strategies |
| 3 | https://markaicode.com/cursor-ignore-files-control-what-ai-sees/ | Practical step-by-step, project-type configs |
| 4 | https://dredyson.com/the-hidden-pitfalls-of-cursorignore-in-cursor-ide-what-every-developer-needs-to-know-but-doesnt/ | Gotchas in Cursor 1.6+ |
| 5 | https://forum.cursor.com/t/cursorindexingignore-or-cursorindexignore/133325 | Confirmed correct filename |

---

## Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Frontmatter format | Pipe table (per spec) | User spec is explicit |
| `.cursorignore` content | Universal junk + secrets + useless binaries | Hard block — AI should never see these |
| `.cursorindexingignore` content | Superset: all of `.cursorignore` + lockfiles + test fixtures + generated code + images | Soft block — AI can `@reference` if needed |
| Lock files | Commented in `.cursorignore`, active in `.cursorindexingignore` | Some teams want lockfiles AI-accessible |
| Image/media | `.cursorindexingignore` only | AI can still `@reference` images if user drags them in |
| Negation `!` patterns | Avoid entirely | Unreliable in Cursor 1.6+ |
| `.gitignore` duplication | None | Both files auto-respect `.gitignore` |
| Install method | `npx skills add` (primary) + manual scripts (fallback) | `npx skills` is the standard CLI |
| Monorepo | Detect per-subpackage `package.json`, merge all stacks | Keeps skill simple |

---

## File Structure

```
build-cursorignore-skill/              ← GitHub repo root
├── SKILL.md                           ← Skill brain (pipe-table frontmatter + pseudo-Lisp body)
├── README.md                          ← Install + usage instructions
├── OVERVIEW.md                        ← One-page summary
├── PLAN.md                            ← THIS FILE — detailed implementation plan
├── assets/
│   ├── cursorignore.baseline.template ← Universal baseline for .cursorignore
│   └── cursorindexingignore.baseline.template ← Universal baseline for .cursorindexingignore
├── install.sh                         ← macOS/Linux/WSL install script
└── install.ps1                        ← Windows PowerShell install script
```

---

## Stack Detection (19 stacks)

| Stack | Signal Files | Stack-Specific Ignore Patterns |
|-------|-------------|-------------------------------|
| js_ts | package.json, bun.lockb, pnpm-lock.yaml, yarn.lock, package-lock.json | (none — universal covers it) |
| next_js | next.config.{js,ts,mjs}, .next/ | `.next/`, `*.tsbuildinfo` |
| nuxt | nuxt.config.{ts,js}, .nuxt/ | `.nuxt/`, `.output/` |
| vite | vite.config.{ts,js} | `.vite/` |
| remix | remix.config.js, app/root.tsx | `build/` (Remix build dir) |
| svelte | svelte.config.js | `.svelte-kit/` |
| astro | astro.config.{mjs,ts} | `.astro/` |
| python | requirements.txt, pyproject.toml, setup.py, Pipfile | (none — universal covers it) |
| django | manage.py | `db.sqlite3`, `staticfiles/`, `media/` |
| flask | wsgi.py | `instance/` |
| java | pom.xml, build.gradle, gradlew | `target/`, `.gradle/`, `.m2/` |
| kotlin | build.gradle.kts | `target/`, `.gradle/`, `.m2/` |
| rust | Cargo.toml | `target/` |
| go | go.mod | (none — universal covers it) |
| php | composer.json, artisan | `vendor/`, `storage/`, `bootstrap/cache/` |
| ruby | Gemfile | `vendor/` |
| rails | config/application.rb, app/controllers/ | `vendor/`, `storage/`, `tmp/`, `log/` |
| ios_swift | *.xcodeproj/, *.xcworkspace/, Podfile | `Pods/`, `DerivedData/`, `xcuserdata/` |
| android | local.properties, gradle/ | `.gradle/`, `build/`, `captures/`, `local.properties` |

### Noise Dir Candidates (28)

```
node_modules/ .next/ dist/ build/ out/ target/ .gradle/ vendor/
.venv/ venv/ env/ __pycache__/ .cache/ .parcel-cache/ .turbo/
.rollup.cache/ storybook-static/ coverage/ .nyc_output/ .pytest_cache/
.mypy_cache/ .ruff_cache/ htmlcov/ Pods/ DerivedData/ .build/
tmp/ temp/ logs/ .tox/ captures/ .vercel/ .netlify/ .terraform/
.serverless/ .pulumi/ .cdktf/ .eggs/ *.egg-info/
```

---

## Install / Update / Uninstall Commands

### Method 1: `npx skills add` (Recommended — All Platforms)

```bash
# ── INSTALL ──────────────────────────────────────────────────────
# Global (available across all projects)
npx skills add owner/build-cursorignore -g -a cursor

# Project-local (committed with project)
npx skills add owner/build-cursorignore -a cursor

# ── UPDATE ───────────────────────────────────────────────────────
npx skills update build-cursorignore

# Or simply re-run the install command (replaces in place)
npx skills add owner/build-cursorignore -g -a cursor -y

# ── UNINSTALL ────────────────────────────────────────────────────
npx skills remove build-cursorignore

# Remove from global scope
npx skills remove --global build-cursorignore
```

### Method 2: Install Scripts (No Node Required)

#### macOS / Linux / WSL / Git Bash

```bash
# ── INSTALL ──────────────────────────────────────────────────────
curl -fsSL https://raw.githubusercontent.com/owner/build-cursorignore/main/install.sh | bash

# ── UPDATE ───────────────────────────────────────────────────────
# Same command — replaces existing installation
curl -fsSL https://raw.githubusercontent.com/owner/build-cursorignore/main/install.sh | bash

# ── UNINSTALL ────────────────────────────────────────────────────
curl -fsSL https://raw.githubusercontent.com/owner/build-cursorignore/main/install.sh | bash -s -- --uninstall
```

#### Windows PowerShell

```powershell
# ── INSTALL ──────────────────────────────────────────────────────
irm https://raw.githubusercontent.com/owner/build-cursorignore/main/install.ps1 | iex

# ── UPDATE ───────────────────────────────────────────────────────
# Same command — replaces existing installation
irm https://raw.githubusercontent.com/owner/build-cursorignore/main/install.ps1 | iex

# ── UNINSTALL ────────────────────────────────────────────────────
irm https://raw.githubusercontent.com/owner/build-cursorignore/main/install.ps1 | iex -Args "--uninstall"
```

### Method 3: Manual Git Clone

```bash
# ── macOS / Linux ────────────────────────────────────────────────
git clone --depth 1 https://github.com/owner/build-cursorignore.git /tmp/build-cursorignore
cp -r /tmp/build-cursorignore ~/.cursor/skills/build-cursorignore
rm -rf /tmp/build-cursorignore

# ── Windows PowerShell ───────────────────────────────────────────
git clone --depth 1 https://github.com/owner/build-cursorignore.git "$env:TEMP\build-cursorignore"
Copy-Item -Recurse "$env:TEMP\build-cursorignore" "$env:USERPROFILE\.cursor\skills\build-cursorignore"
Remove-Item -Recurse "$env:TEMP\build-cursorignore"

# ── UNINSTALL (all platforms) ────────────────────────────────────
# Just delete the folder:
# macOS/Linux:  rm -rf ~/.cursor/skills/build-cursorignore
# Windows:      Remove-Item -Recurse "$env:USERPROFILE\.cursor\skills\build-cursorignore"
```

---

## SKILL.md Pseudo-Lisp Body (Full Outline)

```lisp
(build_cursorignore_skill
  (host_gate
    (require Cursor_Agent)
    (else_stop "This skill requires Cursor Agent. Install from ~/.cursor/skills/build-cursorignore/."))

  (command /build-cursorignore)

  (outcomes
    (cursorignore       at_project_root  blocks_files_from_ai_context_and_indexing)
    (cursorindexingignore at_project_root  blocks_files_from_indexing_only)
    (chat_summary       token_estimate_before_after))

  (scan
    (prefer Explore_read_only)
    (target project_root)
    (list_top_level_dirs_and_files)

    (detect_stack_signals
      (js_ts      package.json bun.lockb pnpm-lock.yaml yarn.lock package-lock.json)
      (next_js    next.config.js next.config.ts next.config.mjs .next/)
      (nuxt       nuxt.config.ts nuxt.config.js .nuxt/)
      (vite       vite.config.ts vite.config.js)
      (remix      remix.config.js app/root.tsx)
      (svelte     svelte.config.js)
      (astro      astro.config.mjs astro.config.ts)
      (python     requirements.txt pyproject.toml setup.py setup.cfg Pipfile)
      (django     manage.py)
      (flask      wsgi.py)
      (java       pom.xml build.gradle build.gradle.kts gradlew)
      (kotlin     build.gradle.kts)
      (rust       Cargo.toml)
      (go         go.mod)
      (php        composer.json artisan)
      (ruby       Gemfile)
      (rails      config/application.rb app/controllers/)
      (ios_swift  *.xcodeproj/ *.xcworkspace/ Podfile)
      (android    local.properties gradle/))

    (detect_noise_dirs
      (candidates
        node_modules/ .next/ dist/ build/ out/ target/ .gradle/ vendor/
        .venv/ venv/ env/ __pycache__/ .cache/ .parcel-cache/ .turbo/
        .rollup.cache/ storybook-static/ coverage/ .nyc_output/ .pytest_cache/
        .mypy_cache/ .ruff_cache/ htmlcov/ Pods/ DerivedData/ .build/
        tmp/ temp/ logs/ .tox/ captures/ .vercel/ .netlify/ .terraform/
        .serverless/ .pulumi/ .cdktf/ .eggs/ *.egg-info/))

    (forbid
      edit_any_file
      ask_user_before_scanning
      multi_turn_confirmation_loop))

  (stack_detection
    (always_include universal_section)

    (include_if_detected
      (js_ts_section      when js_ts OR next_js OR vite OR nuxt OR remix OR svelte OR astro)
      (next_section       when next_js)
      (nuxt_section       when nuxt)
      (python_section     when python OR django OR flask)
      (java_section       when java OR kotlin)
      (rust_section       when rust)
      (go_section         when go)
      (php_section        when php)
      (ruby_section       when ruby OR rails)
      (ios_section        when ios_swift)
      (android_section    when android))

    (append_detected_noise_dirs to_both_files))

  (write
    (single_pass no_questions_no_confirmation)

    (cursorignore
      (target .cursorignore at_project_root)
      (managed_block_policy
        (markers
          begin "# >>> build-cursorignore:baseline BEGIN >>>"
          end   "# <<< build-cursorignore:baseline END <<<"))
      (content
        (start_from_template assets/cursorignore.baseline.template)
        (append_stack_specific_sections based_on_stack_detection)
        (append_detected_noise_dirs from_scan)))

    (cursorindexingignore
      (target .cursorindexingignore at_project_root)
      (managed_block_policy
        (markers
          begin "# >>> build-cursorignore:indexing BEGIN >>>"
          end   "# <<< build-cursorignore:indexing END <<<"))
      (content
        (start_from_template assets/cursorindexingignore.baseline.template)
        (append_stack_specific_sections based_on_stack_detection)
        (append_detected_noise_dirs from_scan)
        (also_add
          tests/fixtures/ e2e/recordings/ docs/api-spec/ *.snap)))

    (forbid
      delete_user_lines_outside_managed_block
      auto_edit_gitignore
      overwrite_entire_file_if_markers_absent
      asking_for_confirmation_before_writing))

  (closeout
    (chat_only)
    (say_plain_english
      (list
        "1. Wrote .cursorignore — these files are now invisible to Cursor AI across all models."
        "2. Wrote .cursorindexingignore — these paths are excluded from search indexing."
        "3. Stacks detected: [list what was found]."
        "4. Noise dirs blocked: [list dirs that were present and added]."
        "5. Estimated files removed from context: [rough count if computable, else omit]."
        "6. Next step: open a NEW Cursor chat — the ignore files take effect on the next session load."))
    (forbid
      skill_jargon pseudo_lisp_terms phase_names
      token_count_fabrication))

  (edge_cases
    (no_invoke         → reply_exact_command_only "/build-cursorignore")
    (empty_root        → warn "Could not list project root. Are you in the right directory?")
    (file_already_full → use_managed_block_append not_full_overwrite)
    (all_noise_absent  → write_universal_baseline_only no_stack_sections)
    (monorepo          → detect_per_subpackage_package_json include_all_found_stacks)
    (windows_paths     → use_forward_slash_in_ignore_patterns)))
```

---

## Template Content Specs

### `assets/cursorignore.baseline.template`

Managed block markers: `# >>> build-cursorignore:baseline BEGIN >>>` / `# <<< build-cursorignore:baseline END <<<`

**13 sections:**

1. **DEPENDENCIES** — `node_modules/`, `vendor/`, `bower_components/`, `.pnp/`, `.pnp.js`
2. **BUILD OUTPUT** — `dist/`, `build/`, `out/`, `.next/`, `.nuxt/`, `.svelte-kit/`, `.astro/`, `.output/`, `storybook-static/`, `target/`, `bin/`, `obj/`
3. **CACHES** — `.cache/`, `.parcel-cache/`, `.turbo/`, `.rollup.cache/`, `.esbuild/`, `.eslintcache`, `.stylelintcache`, `.prettiercache`, `*.tsbuildinfo`, `.babel_cache/`, `__pycache__/`, `.pytest_cache/`, `.mypy_cache/`, `.ruff_cache/`, `.tox/`, `.gradle/`, `.m2/`, `.build/`
4. **LOGS** — `logs/`, `*.log`, `npm-debug.log*`, `yarn-debug.log*`, `yarn-error.log*`, `pnpm-debug.log*`, `lerna-debug.log*`, `pip-log.txt`
5. **COVERAGE & TEST ARTIFACTS** — `coverage/`, `.nyc_output/`, `htmlcov/`, `.coverage`, `lcov.info`, `playwright-report/`, `test-results/`, `cypress/screenshots/`, `cypress/videos/`, `.playwright/`
6. **ENVIRONMENT / SECRETS** — `.env.local`, `.env.*.local`, `*.pem`, `*.key`, `secrets.json`, `credentials.*`, `serviceAccountKey.json`, `.vault-token`
7. **VIRTUAL ENVIRONMENTS** — `.venv/`, `venv/`, `env/`, `.virtualenv/`, `Pipfile.lock`
8. **OS / EDITOR JUNK** — `.DS_Store`, `._*`, `.Spotlight-V100`, `.Trashes`, `Thumbs.db`, `desktop.ini`, `*.swp`, `*.swo`, `*~`, `.idea/`, `.vscode/extensions.json`
9. **MOBILE** — `Pods/`, `DerivedData/`, `*.xcworkspace/`, `xcuserdata/`, `.build/`, `captures/`, `local.properties`
10. **LOCK FILES** (commented) — `# package-lock.json`, `# yarn.lock`, `# pnpm-lock.yaml`, `# bun.lockb`
11. **LARGE BINARY ASSETS** — `*.mp4`, `*.mov`, `*.avi`, `*.mkv`, `*.zip`, `*.tar.gz`, `*.tar.bz2`, `*.rar`, `*.7z`, `*.dmg`, `*.iso`
12. **MINIFIED / COMPILED ASSETS** — `*.min.js`, `*.min.css`, `*.bundle.js`, `*.chunk.js`
13. **TERRAFORM / INFRA GENERATED** — `.terraform/`, `.terraform.lock.hcl`, `.serverless/`, `.pulumi/`, `.cdktf/`, `cdktf.out/`

### `assets/cursorindexingignore.baseline.template`

Managed block markers: `# >>> build-cursorignore:indexing BEGIN >>>` / `# <<< build-cursorignore:indexing END <<<`

**Mirrors all 13 sections above, PLUS:**

- `tests/fixtures/`
- `e2e/recordings/`
- `docs/api-spec/`
- `*.snap`
- `*.lock` (active, not commented)
- `migrations/`
- `scripts/generated/`
- `generated/`
- `auto-generated/`
- `proto/generated/`
- `openapi.json`
- `swagger.json`
- `*.pbxproj`
- `*.xcscheme`

---

## README.md Content Spec

1. **What it does** — one paragraph, plain English
2. **Install** — three methods: `npx skills add`, install scripts, manual git clone
3. **Run** — `/build-cursorignore` in Cursor Agent
4. **What gets written** — `.cursorignore`, `.cursorindexingignore`
5. **After running** — "Open a new Cursor chat. Ignore files take effect on next session load."
6. **Re-run safe** — "Uses managed blocks — user lines are never touched."
7. **Update** — `npx skills update build-cursorignore` or re-run install script
8. **Uninstall** — `npx skills remove build-cursorignore` or delete folder
9. **Works with all models** — Claude, GPT-4o, Gemini, etc.

---

## OVERVIEW.md Content Spec

| Output | What it is |
|--------|-----------|
| `.cursorignore` | Blocks listed paths from AI context AND indexing. Hard exclusion. |
| `.cursorindexingignore` | Blocks from indexing only. Files can still be `@referenced` manually. |

**Why this matters:**
> Every file Cursor loads into context costs tokens. `node_modules` alone can contain 30,000+ files.
> Excluding it can reduce indexing from 5 minutes to 30 seconds and AI query time by 60%+.
> This skill automates the configuration so you never forget.

---

## Implementation Steps

| Step | File | Action |
|------|------|--------|
| 1 | `assets/cursorignore.baseline.template` | Write full template with managed block markers and 13 sections |
| 2 | `assets/cursorindexingignore.baseline.template` | Write superset template with managed block markers and 13+ sections |
| 3 | `SKILL.md` | Write pipe-table frontmatter + full pseudo-Lisp body |
| 4 | `README.md` | Write install (npx + manual + git clone), run, update, uninstall, re-run |
| 5 | `OVERVIEW.md` | Write output table + "why this matters" paragraph |
| 6 | `install.sh` | Write bash install/uninstall script for macOS/Linux/WSL |
| 7 | `install.ps1` | Write PowerShell install/uninstall script for Windows |
| 8 | Verify | Run checklist below |

---

## Checklist

- [ ] `SKILL.md` has pipe-table frontmatter with `name`, `description`, `disable-model-invocation: true`
- [ ] `SKILL.md` has single `(build_cursorignore_skill ...)` top-level form
- [ ] No phases other than single scan-and-write flow
- [ ] `assets/cursorignore.baseline.template` contains real, working glob patterns
- [ ] `assets/cursorindexingignore.baseline.template` contains real, working glob patterns
- [ ] Managed block markers present in both templates
- [ ] `README.md` explains install + run + post-run new-chat instruction
- [ ] `README.md` includes `npx skills add`, manual scripts, and git clone methods
- [ ] `README.md` includes update and uninstall commands
- [ ] `OVERVIEW.md` has output table and "why this matters" paragraph
- [ ] `PLAN.md` documents all architecture decisions
- [ ] `install.sh` works on macOS/Linux/WSL with `--uninstall` flag
- [ ] `install.ps1` works on Windows PowerShell with `--uninstall` flag
- [ ] All glob patterns use forward slashes (cross-platform compatible)
- [ ] Web research was completed before writing (confirmed in session)
