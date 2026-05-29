---
name: build-cursorignore
version: 2.0.0
description: Cursor Agent only. Scans project root, detects stack, writes .cursorignore and .cursorindexingignore to block junk files from AI context and indexing. Single pass, no phases — run /build-cursorignore and it writes immediately.
disable-model-invocation: true
---

; PROMPT NOTATION — not compilable Lisp. Execute as agent instructions.

(build_cursorignore_skill
  ;; ─── PHASE 0: HOST GATE ───────────────────────────────────────
  (host_gate
    (require Cursor_Agent)
    (else_stop "This skill requires Cursor Agent. Install from ~/.cursor/skills/build-cursorignore/."))

  ;; ─── PHASE 1: COMMAND ─────────────────────────────────────────
  (command /build-cursorignore)

  ;; ─── PHASE 2: OUTCOMES ────────────────────────────────────────
  (outcomes
    (cursorignore         at_project_root  blocks_files_from_ai_context_and_indexing)
    (cursorindexingignore  at_project_root  blocks_files_from_indexing_only)
    (chat_summary          token_estimate_before_after))

  ;; ─── PHASE 3: SCAN ────────────────────────────────────────────
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
      (android    local.properties gradle/)
      (bun        bunfig.toml)
      (deno       deno.json deno.jsonc deno.lock)
      (flutter    pubspec.yaml)
      (elixir     mix.exs)
      (scala      build.sbt))

    (detect_noise_dirs
      (candidates
        .agents/ .awakened/ .claude/ .codex/ node_modules/ .next/ dist/ build/ out/ target/ .gradle/ vendor/
        .venv/ venv/ env/ __pycache__/ .cache/ .parcel-cache/ .turbo/
        .rollup.cache/ storybook-static/ coverage/ .nyc_output/ .pytest_cache/
        .mypy_cache/ .ruff_cache/ htmlcov/ Pods/ DerivedData/ .build/
        tmp/ temp/ logs/ .tox/ captures/ .vercel/ .netlify/ .terraform/
        .serverless/ .pulumi/ .cdktf/ .eggs/ *.egg-info/))

    (forbid
      edit_any_file
      ask_user_before_scanning
      multi_turn_confirmation_loop))

  ;; ─── PHASE 4: STACK DETECTION ─────────────────────────────────
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
      (android_section    when android)
      (bun_section         when bun)
      (deno_section        when deno)
      (flutter_section     when flutter)
      (elixir_section      when elixir)
      (scala_section       when scala))

    (append_detected_noise_dirs to_both_files))

  ;; ─── PHASE 5: WRITE ───────────────────────────────────────────
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

  ;; ─── PHASE 6: CLOSEOUT ────────────────────────────────────────
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

  ;; ─── PHASE 7: EDGE CASES ──────────────────────────────────────
  (edge_cases
    (no_invoke         → reply_exact_command_only "/build-cursorignore")
    (empty_root        → warn "Could not list project root. Are you in the right directory?")
    (file_already_full → use_managed_block_append not_full_overwrite)
    (all_noise_absent  → write_universal_baseline_only no_stack_sections)
    (monorepo          → detect_per_subpackage_package_json include_all_found_stacks)
    (windows_paths     → use_forward_slash_in_ignore_patterns)))
