# native-bash-toolchain-no-poetry — Plan

- **Issue:** #393
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-21T19-00
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature

## Required References

- Research (authoritative behavior-parity contract): `docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/research/2026-07-21T18-45-native-bash-shell-qc-research.md`
- Spec: `docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/spec.md`
- User story: `docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/user-story.md`
- AC source: `docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/issue.md` (AC1–AC9)
- General code change policy: `.claude/rules/general-code-change.md`
- General unit test policy: `.claude/rules/general-unit-test.md`
- Python toolchain: `.claude/rules/python.md`
- CI workflow authoring: `.claude/rules/ci-workflows.md`
- Tone policy: `.claude/rules/tonality.md`

All work must comply with these policies; their content is not duplicated here.

## Conventions Used in This Plan

- `<FEATURE>` = `docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393`
- `<ts>` = ISO-8601 execution timestamp in `yyyy-MM-ddTHH-mm` format, generated when the task runs.
- All evidence artifacts are written under `<FEATURE>/evidence/<kind>/` (canonical scheme per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`). No evidence may be written under `artifacts/`.
- Every command-step evidence artifact must contain: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- Shell toolchain commands (`shfmt`, `shellcheck`, `bats`, `kcov`, and the new wrapper) run in a WSL shell at the repository root. If a required binary is unavailable in the local WSL environment, the artifact records the actual exit code and the environment; the task's acceptance criteria state whether a fallback source is permitted.
- Toolchain loop rule (applies to every phase-gate and final-QA task): if any stage fails or rewrites files, restart that language's loop from its formatting stage and repeat until all stages pass in a single pass.
- Language toolchains in scope:
  - Shell (new native toolchain): shfmt → shellcheck → bats → kcov coverage, via `bash scripts/bash/shell-qc.sh <format|check|test [--coverage]>`.
  - Python: Black → Ruff → Pyright → Pytest (`poetry run black .` / `poetry run ruff check .` / `poetry run pyright` / `poetry run pytest --cov --cov-branch --cov-report=term-missing`).
  - Workflow YAML: no local execution stage; verified by review against `.claude/rules/ci-workflows.md` plus a green CI run against the branch head (`modified-workflow-needs-green-run`), recorded as a pre-merge gate in Phase 5.

## Acceptance Criteria Mapping

| AC | Summary | Primary tasks |
|---|---|---|
| AC1 | Native wrapper `scripts/bash/shell-qc.sh` with `check`/`format`/`test`, no Python/Poetry | P1-T1..P1-T7, P2-T6 |
| AC2 | `test --coverage` runs bats under kcov, emits Cobertura `cov.xml` | P1-T4, P2-T6, P5-T4, P5-T9 |
| AC3 | Discovery parity (roots, suffix/shebang, exclusions, test dirs) | P1-T1, P1-T4, P2-T1, P2-T2, P2-T5 |
| AC4 | `shell_qc.py` deleted; five `pyproject.toml` entries removed | P3-T4, P3-T5, P4-T8 |
| AC5 | No shell-toolchain component invokes Python or Poetry | P1-T6, P3-T1, P3-T3, P4-T3, P4-T8 |
| AC6 | Both workflows invoke the native wrapper; no Poetry install / `poetry run` | P4-T1, P4-T2, P4-T3, P5-T9 |
| AC7 | `.claude/rules/shell.md` exists, path-scoped, documents toolchain | P4-T4 |
| AC8 | Wrapper covered by bats tests under `tests/shell/` | P2-T1..P2-T8, P5-T3 |
| AC9 | Green CI run against branch head for modified workflows | P5-T9 |

Cross-cutting contract (not an AC but load-bearing): byte-identical skip markers consumed by `scripts/dev_tools/fix_all.py::shell_test_was_skipped` — `No shell test directories found; skipping.` and `bats not installed; skipping shell tests.` (P0-T10, P1-T4, P2-T6).

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Compliance and Baseline Capture

- [x] [P0-T1] Read the policy files in order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/ci-workflows.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`; record the read in `<FEATURE>/evidence/baseline/phase0-instructions-read.<ts>.md`.
  - Acceptance: artifact exists and contains `Timestamp:`, `Policy Order:`, and the explicit list of files read.
- [x] [P0-T2] Capture Python formatting baseline: run `poetry run black --check .`; write `<FEATURE>/evidence/baseline/python-format.<ts>.md`.
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (files-would-reformat count or clean).
- [x] [P0-T3] Capture Python lint baseline: run `poetry run ruff check .`; write `<FEATURE>/evidence/baseline/python-lint.<ts>.md`.
  - Acceptance: artifact contains the four required fields; `Output Summary:` records the finding count.
- [x] [P0-T4] Capture Python type-check baseline: run `poetry run pyright`; write `<FEATURE>/evidence/baseline/python-typecheck.<ts>.md`.
  - Acceptance: artifact contains the four required fields; `Output Summary:` records error/warning counts.
- [x] [P0-T5] Capture Python test and coverage baseline: run `poetry run pytest --cov --cov-branch --cov-report=term-missing`; write `<FEATURE>/evidence/baseline/python-test.<ts>.md`.
  - Acceptance: artifact contains the four required fields; `Output Summary:` records pass/fail counts and numeric line and branch coverage percentages, including the per-file line for `scripts/dev_tools/shell_qc.py` (expected 0% of 222 statements).
- [x] [P0-T6] Capture existing shell toolchain help baseline: run `poetry run shell-qc --help`; write `<FEATURE>/evidence/baseline/shell-qc-help.<ts>.md`.
  - Acceptance: artifact contains the four required fields and the verbatim usage text (parity reference for the wrapper's `--help`).
- [x] [P0-T7] Capture existing shell `check` baseline: run `poetry run shell-qc check` (WSL shell at repo root; if WSL Poetry is unavailable, run on the host and record the environment); write `<FEATURE>/evidence/baseline/shell-check.<ts>.md`.
  - Acceptance: artifact contains the four required fields; `Output Summary:` records findings or the missing-tool block verbatim.
- [x] [P0-T8] Capture existing shell `test` baseline: run `poetry run shell-qc test` (same environment rule as P0-T7); write `<FEATURE>/evidence/baseline/shell-test.<ts>.md`.
  - Acceptance: artifact contains the four required fields; `Output Summary:` records bats results or the verbatim skip/missing-tool output.
- [x] [P0-T9] Capture bash coverage baseline: run `poetry run shell-qc test --coverage` (same environment rule as P0-T7). If kcov is unavailable locally (exit 127), instead record the `Bash coverage (lines): NN.N%` value from the most recent green `_shell-coverage.yml` run on `main`, citing the run URL. Write `<FEATURE>/evidence/baseline/shell-coverage.<ts>.md`.
  - Acceptance: artifact contains the four required fields and a numeric bash line-coverage percentage with its source (local run or cited CI run URL). This skip branch is the only authorized fallback.
- [x] [P0-T10] Record the skip-marker and missing-tool contract: read `scripts/dev_tools/fix_all.py` (`shell_test_was_skipped`) and `scripts/dev_tools/shell_qc.py`; write the verbatim strings `No shell test directories found; skipping.`, `bats not installed; skipping shell tests.`, `No shell scripts found; skipping.`, the two coverage-mode missing-tool messages, and the exact five-line missing-tool block into `<FEATURE>/evidence/baseline/skip-marker-contract.<ts>.md`.
  - Acceptance: artifact contains `Timestamp:` and the verbatim strings, each attributed to its source file and line range.
- [x] [P0-T11] Produce the full live-reference inventory: run `rg -n "shell_qc|shell-qc"` across the repository, excluding `docs/features/completed/**`, `docs/features/archive/**`, other features' evidence folders, and `<FEATURE>/**`; write `<FEATURE>/evidence/baseline/reference-inventory.<ts>.md` listing every live hit with file and line.
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; the hit set is reconciled against the ten-row inventory in `spec.md` (§ Full reference-update inventory: `pyproject.toml` ×5, `scripts/dev_tools/shell_qc.py`, `scripts/dev_tools/fix_all_branches.py` ×3, `scripts/dev_tools/fix_all.py` markers, `.vscode/tasks.json` ×3, `.github/workflows/_shell-coverage.yml`, `.github/workflows/_build-check.yml`, `README.md`, two policy-audit templates); any additional live hit is listed and assigned a Phase 4 update or an explicit documented exclusion.

### Phase 1 — Native Bash Library and Wrapper

- [x] [P1-T1] Create `scripts/bash/shell_qc_lib.sh` containing discovery functions `discover_shell_scripts`, `is_shell_script`, and `extract_shebang_command` implementing the parity contract (research § 2.1): roots `tools/` and `scripts/` relative to cwd with missing roots silently skipped; `find` pruning of `.venv`, `.git`, `node_modules`, `dist`, `build` at any depth; `.sh` suffix (lowercased) or lowercased-first-line shebang resolving to `bash` or `sh` including `env` and `env -S`/`-flag` forms; unreadable files treated as non-shell; output de-duplicated and sorted via `LC_ALL=C sort -u`. (AC3)
  - Acceptance: file exists; functions match the contract; `set -euo pipefail`-safe; no `python`/`poetry` invocation.
- [x] [P1-T2] Add `resolve_tool` and `print_missing_tool_block` to `scripts/bash/shell_qc_lib.sh`: `resolve_tool` honors the `SHELL_QC_<TOOL>_BIN` override for `shfmt`, `shellcheck`, `bats`, `kcov` (empty or nonexistent value treated as missing; otherwise `command -v`); `print_missing_tool_block` emits the exact five-line block from P0-T10 with package name defaulting to the tool name; missing-tool exit code is 127. (AC1)
  - Acceptance: functions present; the five-line block is byte-identical to the baseline capture.
- [x] [P1-T3] Add `run_check` and `run_format` to `scripts/bash/shell_qc_lib.sh`: no scripts → print `No shell scripts found; skipping.` and return 0; `check` preflights shfmt then shellcheck (127 each), runs `shfmt -d` once over the full file list, then `shellcheck` per file, returning `max(shfmt_exit, max_shellcheck_exit)`; `format` preflights shfmt (127) and runs `shfmt -w` over the full list, returning its exit code; expected-nonzero tools captured with `|| rc=$?`, never invoked bare under `set -e`. (AC1)
  - Acceptance: functions present and match research § 2.2–2.3 exactly.
- [x] [P1-T4] Add `run_test`, `run_test_coverage`, and `extract_cobertura_line_rate` to `scripts/bash/shell_qc_lib.sh`: test dirs `tests/shell` then `tests/bash` (existing only); no dirs → print exactly `No shell test directories found; skipping.` and return 0; bats missing → non-coverage prints exactly `bats not installed; skipping shell tests.` and returns 0, coverage prints `bats not installed; cannot run shell tests with coverage.` and returns 127; non-coverage runs `bats <dir>` per dir, running all dirs and returning the max exit; coverage: kcov missing → message plus missing-tool block, 127; output dir from `SHELL_QC_KCOV_OUT_DIR` (default `artifacts/pester/kcov`, resolved against repo root when relative) deleted/recreated with `.kcov_runs`; per-dir `kcov --cobertura-only --include-pattern=<abs-root>/tools,<abs-root>/scripts --exclude-pattern=<abs-root>/tests <run_dir> <abs bats path> <test_dir>` stopping at first failure; on success `kcov --merge` into the output dir; `.kcov_runs` always removed; on success parse the first `line-rate` attribute from `cov.xml` and print `Bash coverage (lines): NN.N%` with exactly one decimal, printing nothing (still exit 0) when `cov.xml` is missing or unparseable. (AC2, AC3, skip-marker contract)
  - Acceptance: functions present and match research § 2.4–2.5; the two fix_all skip markers are byte-identical to P0-T10.
- [x] [P1-T5] Create executable wrapper `scripts/bash/shell-qc.sh`: `set -euo pipefail`; sources `scripts/bash/shell_qc_lib.sh` via its own directory; `case` dispatch for `check`, `format`, `test [--coverage]`, `--help`/`-h`/`help` (usage to stdout, exit 0); unknown or missing subcommand and unknown `test` flags print usage to stderr and exit 2; `main "$@"` guarded so the file can be sourced; final `exit "$exit_code"` is the last statement so intermediate `|| rc=$?` captures cannot mask a failure. (AC1)
  - Acceptance: file exists, is executable, dispatches all documented paths with the documented exit codes.
- [x] [P1-T6] Verify implementation constraints on both new files: `rg -n "python|poetry" scripts/bash/shell-qc.sh scripts/bash/shell_qc_lib.sh` returns no invocation hits, and `wc -l` reports each file under 500 lines (split the library if not). (AC1, AC5)
  - Acceptance: zero Python/Poetry invocations; both files < 500 lines.
- [x] [P1-T7] Run the self-hosting shell gate in WSL: `bash scripts/bash/shell-qc.sh format` then `bash scripts/bash/shell-qc.sh check`; both new files are discovered by the wrapper itself and must be shfmt-clean and shellcheck-clean; restart from `format` if `check` fails or `format` rewrote files. Write `<FEATURE>/evidence/qa-gates/shell-selfhost-check.<ts>.md`.
  - Acceptance: artifact contains the four required fields for both commands; final pass has `EXIT_CODE: 0` for both with no rewrites.

### Phase 2 — Fixtures and Bats Test Suite

- [x] [P2-T1] Add shebang fixtures under `tests/fixtures/shell_qc/scripts/`: an `env -S` flags form (`#!/usr/bin/env -S bash`), an `sh` shebang form (`#!/bin/sh`), and an uppercase form (`#!/usr/bin/env BASH`), each extensionless. (AC3)
  - Acceptance: three fixture files exist and are tracked by git.
- [x] [P2-T2] Add excluded-dir fixture `tests/fixtures/shell_qc/scripts/node_modules/skip_me.sh` and force-track it (`git add -f`, since `.gitignore` line 3 ignores `node_modules`). (AC3)
  - Acceptance: `git ls-files tests/fixtures/shell_qc/scripts/node_modules/skip_me.sh` returns the path.
- [x] [P2-T3] Add Cobertura fixture `tests/fixtures/shell_qc/cov/cov.xml` with a known `line-rate` (e.g. `0.75`) for the summary-format test. (AC2)
  - Acceptance: fixture exists; its `line-rate` maps to the expected `Bash coverage (lines): 75.0%` output.
- [x] [P2-T4] Add checked-in recording stubs `tests/fixtures/shell_qc/stub-bin/{shfmt,shellcheck,bats,kcov}`: each executable, echoes its argv to stdout, and exits with the code named by an environment variable (default 0), for wiring via the `SHELL_QC_<TOOL>_BIN` seam. (AC8)
  - Acceptance: four executable stubs exist and are tracked; no test writes files at runtime.
- [x] [P2-T5] Create `tests/shell/test_shell_qc_discovery.bats`: sources `scripts/bash/shell_qc_lib.sh`; covers `.sh` suffix, extensionless bash shebang, `env` form, `env -S` flags form, uppercase shebang, `sh` shebang, excluded-dir pruning (`node_modules` fixture absent from results), non-shell files ignored (`ignored.txt`, `pwsh_script.ps1`), and de-duplicated sorted output; runs discovery cwd-relative inside `tests/fixtures/shell_qc/` (e.g. `run bash -c "cd '$FIXTURE_ROOT' && ..."`); uses no temporary files. (AC3, AC8)
  - Acceptance: file exists; every listed scenario has a named test; suite passes under `bats tests/shell`.
- [x] [P2-T6] Create `tests/shell/test_shell_qc_commands.bats` covering, via the stub-bin seam and `SHELL_QC_KCOV_OUT_DIR`: `check` no-scripts skip message and exit 0; `check` exit 127 with the exact five-line block when shfmt or shellcheck is missing; max-exit semantics (shfmt fails, shellcheck fails, both); single `shfmt -d` invocation with the full file list and per-file shellcheck invocations (asserted from stub argv echoes); `format` passes `-w`; `test` no-test-dir skip with exact string `No shell test directories found; skipping.`; bats-missing non-coverage skip with exact string `bats not installed; skipping shell tests.` and exit 0; bats-missing coverage exit 127; kcov-missing exit 127 with message and block; kcov argv shape (`--cobertura-only`, include/exclude patterns, run dir, absolute bats path, test dir); `kcov --merge` invocation; coverage summary `Bash coverage (lines): 75.0%` from the P2-T3 fixture; `--help` exit 0; unknown subcommand exit 2. (AC1, AC2, AC8, skip-marker contract)
  - Acceptance: file exists; every listed scenario has a named test; the two fix_all skip markers are asserted byte-identically; suite passes under `bats tests/shell`; no temporary files.
- [x] [P2-T7] Verify each new bats file is under 500 lines (`wc -l`); if either approaches the limit, split along the discovery/commands boundary already used.
  - Acceptance: every bats file < 500 lines.
- [x] [P2-T8] Run the shell toolchain gate in WSL: `bash scripts/bash/shell-qc.sh format`, then `check`, then `bash scripts/bash/shell-qc.sh test`; restart from `format` on any failure or rewrite. Write `<FEATURE>/evidence/qa-gates/shell-test-phase2.<ts>.md`. (AC8)
  - Acceptance: artifact contains the four required fields per command; final pass is all-green (`EXIT_CODE: 0` each).

### Phase 3 — Consumer Repointing and Python Surface Removal

- [x] [P3-T1] Update `scripts/dev_tools/fix_all_branches.py`: replace the three command lists `["poetry", "run", "python", "-m", "scripts.dev_tools.shell_qc", "<cmd>"]` with `["bash", "scripts/bash/shell-qc.sh", "<cmd>"]` for `format`, `check`, and `test` (lines 181–188, 205–212, 224–232 per research § 7.2). (AC5)
  - Acceptance: no `scripts.dev_tools.shell_qc` reference remains in the file; the three step names are unchanged.
- [x] [P3-T2] Run the targeted pytest suites: `poetry run pytest tests/scripts/dev_tools/test_fix_all_branches.py tests/scripts/dev_tools/test_fix_all.py`; the fake-runner suite keys by step name, so no test edit is expected — adjust a test only if it asserts the old command string, and record any such edit. Write `<FEATURE>/evidence/qa-gates/python-fixall-tests.<ts>.md`.
  - Acceptance: artifact contains the four required fields; `EXIT_CODE: 0`; any test edit is listed with justification.
- [x] [P3-T3] Update `.vscode/tasks.json`: for the three shell-qc tasks (format/check/test), change `command` from `poetry` to `bash` and `args` from `["run", "shell-qc", "<cmd>"]` to `["scripts/bash/shell-qc.sh", "<cmd>"]`; leave the `bash -n` type-check task unchanged. (AC5)
  - Acceptance: `rg "shell-qc" .vscode/tasks.json` shows only `scripts/bash/shell-qc.sh` references; JSON remains valid.
- [x] [P3-T4] Remove the five console-script entries from `pyproject.toml`: `shell-qc`, `shell-qc-check`, `shell-qc-format`, `shell-qc-test` (lines 50–53) and `dev.shell-qc` (line 86). Do NOT regenerate `poetry.lock`: removing `[tool.poetry.scripts]` entries changes the built wheel, not the dependency set, so the lock file is unaffected — this resolves the spec's open question. Record the resolution in the artifact. (AC4)
  - Acceptance: `rg "shell.qc" pyproject.toml` returns no hits; `git status` shows `poetry.lock` unmodified; resolution note written to `<FEATURE>/evidence/other/poetry-lock-resolution.<ts>.md`.
- [x] [P3-T5] Delete `scripts/dev_tools/shell_qc.py`. (AC4)
  - Acceptance: file absent from the working tree and staged for deletion.
- [x] [P3-T6] Run the full Python toolchain loop: `poetry run black .` → `poetry run ruff check .` → `poetry run pyright` → `poetry run pytest --cov --cov-branch --cov-report=term-missing`; restart from Black on any failure or rewrite. Write `<FEATURE>/evidence/qa-gates/python-postremoval.<ts>.md`.
  - Acceptance: artifact contains the four required fields per stage; final pass all-green; `Output Summary:` records numeric line and branch coverage and notes the expected increase versus P0-T5 from removing 222 uncovered statements.

### Phase 4 — CI Workflow Migration, Rule Doc, and Reference Updates

- [x] [P4-T1] Rewrite `.github/workflows/_shell-coverage.yml`: remove the `Set up Python`, `Install Poetry` (`snok/install-poetry@v1`), `Load cached venv` (`actions/cache` on `.venv`), `Install dependencies`, and `Install project` steps; keep checkout, the shell tooling install (apt shellcheck + bats, pinned shfmt 3.8.0 binary), the kcov cache/build/install (v43 from source), and the `upload-artifact` step (`artifacts/pester/kcov/**`, `if-no-files-found: error`) unchanged; replace the run step with `bash scripts/bash/shell-qc.sh test --coverage`. (AC6)
  - Acceptance: the file contains no `poetry`, `snok/install-poetry`, or `setup-python` reference; the run step is the single native-wrapper command; the artifact-upload contract is unchanged.
- [x] [P4-T2] Update `.github/workflows/_build-check.yml`: remove `shell-qc --help` from the wheel-install verification (keep `atomic-executor --help`); add a step `Shell QC smoke (native)` with `run: bash scripts/bash/shell-qc.sh --help` requiring no tool installs. (AC6)
  - Acceptance: no `shell-qc --help` wheel smoke remains; the native smoke step is present.
- [x] [P4-T3] Verify exit-code propagation and Python/Poetry absence in both modified workflows: each new/changed `run:` step is a single bash command whose non-zero exit fails the step directly; neither workflow contains a deliberately-failing nested command (so no `.claude/rules/ci-workflows.md` reset pattern is needed — record this determination); `rg "poetry|python" ` over both files shows no hit on the shell path. Write `<FEATURE>/evidence/qa-gates/workflow-review.<ts>.md`. (AC5, AC6)
  - Acceptance: artifact records the review findings with file/line citations; green-run verification is deferred to P5-T9 (`modified-workflow-needs-green-run` pre-merge gate).
- [x] [P4-T4] Create `.claude/rules/shell.md` with YAML frontmatter `paths: ["**/*.sh", "**/*.bats", "scripts/bash/**", "tests/shell/**"]` and a `description:`, matching the structure of `.claude/rules/python.md`/`.claude/rules/powershell.md`, containing: (1) toolchain order — shfmt (format) → shellcheck (check) → type-check N/A (optional `bash -n`) → bats (test) with kcov coverage, and the restart-from-format loop rule; (2) native invocation `bash scripts/bash/shell-qc.sh <cmd>`, no Python/Poetry, WSL on Windows, `ubuntu-latest` in CI; (3) the discovery contract (roots, suffix/shebang incl. `env` forms, exclusions, test dirs); (4) coverage expectations — Cobertura `cov.xml` under `artifacts/pester/kcov`, `Bash coverage (lines): NN.N%`, kcov measures line coverage only (uniform >= 85% line threshold applies; no bash branch-coverage gate exists); (5) CI-vs-local version drift — CI pins shfmt 3.8.0, apt shellcheck/bats, kcov v43; CI versions are canonical when results disagree; (6) coding standards — `set -euo pipefail`, shellcheck-clean without unjustified suppressions, shfmt default formatting, 500-line limit, tests in `tests/shell/*.bats` mirroring `scripts/bash/`, no temp files in tests. Professional tone per `.claude/rules/tonality.md`. (AC7)
  - Acceptance: file exists with the frontmatter and all six sections; content is consistent with the implemented wrapper behavior.
- [x] [P4-T5] Update `README.md`: replace the Poetry `shell-qc` command documentation with `bash scripts/bash/shell-qc.sh format|check|test [--coverage]`; remove the console-script name-list entry; repoint the file link from `scripts/dev_tools/shell_qc.py` to `scripts/bash/shell-qc.sh` (lines 16, 68, 366–370 per research § 7.2).
  - Acceptance: `rg "shell_qc|poetry run shell-qc" README.md` returns no hits.
- [x] [P4-T6] Update `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`: replace the `poetry run shell-qc <cmd>` invocation examples with the native `bash scripts/bash/shell-qc.sh <cmd>` invocation.
  - Acceptance: no `poetry run shell-qc` reference remains in the template.
- [x] [P4-T7] Update `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` with the same replacement (mirrored template; content must match P4-T6's edit).
  - Acceptance: no `poetry run shell-qc` reference remains; the two templates' invocation sections are identical.
- [x] [P4-T8] Run the final reference sweep: `rg -n "shell_qc|shell-qc"` across the repository, excluding `docs/features/completed/**`, `docs/features/archive/**`, other features' frozen evidence, `<FEATURE>/**`, and the new shell toolchain files/tests/fixtures/rule doc; reconcile against P0-T11. Write `<FEATURE>/evidence/qa-gates/reference-sweep.<ts>.md`. (AC4, AC5)
  - Acceptance: artifact contains the four required fields; zero unexpected live references remain (expected remaining hits are only the new native-toolchain surfaces and frozen/excluded paths, each listed).

### Phase 5 — Final QA Loop and CI Verification

Loop rule for this phase: shell stages P5-T1→P5-T4 and Python stages P5-T5→P5-T8 each form a loop; if any stage fails or rewrites files, restart that language's loop from its first stage and re-record. Workflow YAML has no local stage; its gate is P5-T9.

- [x] [P5-T1] Run final shell formatting: `bash scripts/bash/shell-qc.sh format` (WSL); write `<FEATURE>/evidence/qa-gates/final-shell-format.<ts>.md`.
  - Acceptance: artifact contains the four required fields; `EXIT_CODE: 0`; no files rewritten on the recorded final pass.
- [x] [P5-T2] Run final shell lint/format-check: `bash scripts/bash/shell-qc.sh check` (WSL); write `<FEATURE>/evidence/qa-gates/final-shell-check.<ts>.md`.
  - Acceptance: artifact contains the four required fields; `EXIT_CODE: 0`.
- [x] [P5-T3] Run final shell tests: `bash scripts/bash/shell-qc.sh test` (WSL); write `<FEATURE>/evidence/qa-gates/final-shell-test.<ts>.md`. (AC8)
  - Acceptance: artifact contains the four required fields; `EXIT_CODE: 0`; `Output Summary:` records bats pass counts.
- [x] [P5-T4] Run final shell coverage: `bash scripts/bash/shell-qc.sh test --coverage` (WSL); write `<FEATURE>/evidence/qa-gates/final-shell-coverage.<ts>.md`. If kcov is unavailable locally (exit 127), record that exit and obtain the numeric `Bash coverage (lines): NN.N%` value from the green `_shell-coverage.yml` run captured in P5-T9, citing the run URL; this is the only authorized fallback. (AC2)
  - Acceptance: artifact contains the four required fields and a numeric bash line-coverage percentage with its source; the `cov.xml` artifact location (`artifacts/pester/kcov` or CI upload) is recorded.
- [x] [P5-T5] Run final Python formatting: `poetry run black .`; write `<FEATURE>/evidence/qa-gates/final-python-format.<ts>.md`.
  - Acceptance: artifact contains the four required fields; `EXIT_CODE: 0`; no files rewritten on the recorded final pass.
- [x] [P5-T6] Run final Python lint: `poetry run ruff check .`; write `<FEATURE>/evidence/qa-gates/final-python-lint.<ts>.md`.
  - Acceptance: artifact contains the four required fields; `EXIT_CODE: 0`.
- [x] [P5-T7] Run final Python type check: `poetry run pyright`; write `<FEATURE>/evidence/qa-gates/final-python-typecheck.<ts>.md`.
  - Acceptance: artifact contains the four required fields; `EXIT_CODE: 0` (zero errors).
- [x] [P5-T8] Run final Python tests with coverage: `poetry run pytest --cov --cov-branch --cov-report=term-missing`; write `<FEATURE>/evidence/qa-gates/final-python-test.<ts>.md`.
  - Acceptance: artifact contains the four required fields; `EXIT_CODE: 0`; `Output Summary:` records numeric line and branch coverage percentages.
- [ ] [P5-T9] Push the branch and verify green CI runs against the branch head for the modified workflows: `ci.yml` (which calls `_shell-coverage.yml`) and `_build-check.yml` (`workflow_dispatch` is available on both reusable workflows if a direct run is needed); confirm the `_shell-coverage.yml` run uploads `cov.xml` under `artifacts/pester/kcov/**` and prints the coverage summary line, and that `_build-check.yml` passes the native `--help` smoke. Write `<FEATURE>/evidence/qa-gates/ci-green-run.<ts>.md` with the run URLs, conclusions, and the coverage summary line. (AC2, AC6, AC9; satisfies `modified-workflow-needs-green-run`)
  - Acceptance: artifact records green (successful) run URLs against the branch head for both modified workflows and the observed `Bash coverage (lines): NN.N%` value.
- [ ] [P5-T10] Verify coverage deltas and thresholds: compare P0-T5 baseline versus P5-T8 final Python line and branch coverage (no regression permitted; final values must satisfy >= 85% line and >= 75% branch; changed Python files must not lose coverage on changed lines) and compare the P0-T9 baseline versus the P5-T4/P5-T9 bash line-coverage value (the new `scripts/bash/shell_qc_lib.sh`/`shell-qc.sh` files enter the kcov denominator; record their effect on the headline and flag any regression versus baseline for remediation). Write `<FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md`.
  - Acceptance: artifact records baseline, post-change, and changed-code numeric values for Python plus baseline and post-change numeric values for bash, with an explicit pass/remediation-required verdict per comparison; if any required numeric value is unavailable the verdict is remediation-required, never PASS.
- [x] [P5-T11] Produce the AC verification record: for each of AC1–AC9, cite the concrete evidence artifact(s), file(s), or CI run URL(s) that satisfy it, plus the skip-marker contract verification (P2-T6 assertions against P0-T10). Write `<FEATURE>/evidence/qa-gates/ac-verification.<ts>.md`.
  - Acceptance: artifact maps all nine ACs to evidence with no gaps; any unsatisfied AC is marked with a remediation step rather than omitted.

## Test Plan

- Unit (bats): `tests/shell/test_shell_qc_discovery.bats` and `tests/shell/test_shell_qc_commands.bats` against `scripts/bash/shell_qc_lib.sh`/`shell-qc.sh`, using checked-in fixtures (`tests/fixtures/shell_qc/`) and stub binaries (`tests/fixtures/shell_qc/stub-bin/`) via the `SHELL_QC_<TOOL>_BIN` seam; no temporary files.
- Unit (pytest): existing `tests/scripts/dev_tools/test_fix_all_branches.py` and `test_fix_all.py` re-run after the repointing (P3-T2); fakes key by step name, so no edit is expected.
- Integration: the real kcov success path is exercised end-to-end by `_shell-coverage.yml` on CI (P5-T9); bats unit tests do not require a real kcov binary.
- Coverage evidence: Python baseline `<FEATURE>/evidence/baseline/python-test.<ts>.md`, final `<FEATURE>/evidence/qa-gates/final-python-test.<ts>.md`; bash baseline `<FEATURE>/evidence/baseline/shell-coverage.<ts>.md`, final `<FEATURE>/evidence/qa-gates/final-shell-coverage.<ts>.md`; comparison `<FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md`.

## Sequencing Constraints (Enforced by Phase Order)

1. The wrapper, library, and byte-identical skip markers (Phase 1) and their tests (Phase 2) exist and pass before `fix_all_branches.py` is repointed (P3-T1) and before the `pyproject.toml`/module removal (P3-T4, P3-T5), so no intermediate commit leaves the shell toolchain without a working entry point.
2. Workflow edits (Phase 4) land only after the native wrapper is verified locally, so the first CI run of the migrated workflows exercises a tested entry point.
3. The green-run gate (P5-T9) is a pre-merge requirement per `modified-workflow-needs-green-run`; the branch must not merge without it.

## Open Questions / Notes

- `poetry.lock` regeneration: resolved — not required. `[tool.poetry.scripts]` entries affect the built wheel's entry points, not the dependency set the lock file tracks; the lock is not regenerated in this change (P3-T4 records this resolution).
- A pre-existing template stub `plan.2026-07-21T18-19.md` exists in the feature folder from scaffolding; this file (`plan.2026-07-21T19-00.md`) is the operative plan.
- The `pyright` subcommand of the removed Python module is intentionally not ported (spec Non-Goals); Pyright remains reachable via `poetry run pyright`.
