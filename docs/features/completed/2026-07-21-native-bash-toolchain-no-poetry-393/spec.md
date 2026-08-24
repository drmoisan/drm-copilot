# native-bash-toolchain-no-poetry — Spec

- **Issue:** #393
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-21T18-19
- **Status:** Draft
- **Version:** 0.2

## Overview

The repository's shell (bash) quality-control toolchain is driven by a Python module,
`scripts/dev_tools/shell_qc.py`, invoked through Poetry console scripts
(`poetry run shell-qc check|format|test`, plus `shell-qc-check|format|test`). This couples
the bash toolchain to a Python interpreter and a Poetry-managed virtual environment. The
toolchain is intended to run under WSL and must not depend on Python or Poetry. The
toolchain is also undocumented in `.claude/rules/`, which lists `python.md`, `powershell.md`,
`typescript.md`, and `csharp.md` but no bash/shell rule, so skills and agents have no
authoritative shell toolchain reference.

## Behavior

Replace the Python-driven shell toolchain with a native bash entry point that contains no
Python at all:

- A native bash wrapper `scripts/bash/shell-qc.sh` exposing `check`, `format`, and `test`
  subcommands that invoke `shfmt`, `shellcheck`, `bats` (and `kcov` for coverage) directly.
- The wrapper discovers shell scripts and bats test directories using the same rules the
  Python module used (search `tools/` and `scripts/`; test dirs `tests/shell` and
  `tests/bash`; `.sh` suffix or bash/sh shebang; exclude `.venv`, `.git`, `node_modules`,
  `dist`, `build`).
- Remove `scripts/dev_tools/shell_qc.py` and all five Poetry console-script entries
  (`shell-qc`, `shell-qc-check`, `shell-qc-format`, `shell-qc-test`, `dev.shell-qc`) from
  `pyproject.toml`.
- Migrate CI off Poetry for the shell path: `.github/workflows/_shell-coverage.yml` invokes
  the native bash wrapper (no `snok/install-poetry`, no `poetry run`) and
  `.github/workflows/_build-check.yml` replaces the `shell-qc --help` smoke with the native
  entry point.
- Add `.claude/rules/shell.md`, a path-scoped rule documenting the native toolchain
  (shfmt -> shellcheck -> bats -> kcov), invocation, and coverage expectations.

### Script discovery contract

- Search roots: `tools/` and `scripts/`, relative to the current working directory. A
  missing root is silently skipped.
- Directory exclusion at any depth, pruned during traversal: `.venv`, `.git`,
  `node_modules`, `dist`, `build`.
- A file is a shell script when either:
  - its suffix, lowercased, is `.sh`; or
  - its first line is a shebang whose resolved interpreter command is `bash` or `sh`. The
    first line is lowercased before parsing (so `#!/usr/bin/env BASH` qualifies); the `#!`
    prefix is stripped and trimmed; an empty payload is not a shell script; the payload is
    word-split; the basename of the first token is taken; if that basename is `env`, it is
    dropped along with any leading `-`-prefixed tokens (covering `env -S bash` style flags),
    and the basename of the next remaining token is evaluated; an unreadable file is treated
    as not a shell script (no error raised).
- The result set is de-duplicated and sorted lexicographically by path string
  (`LC_ALL=C sort -u` for deterministic codepoint ordering).

### `check` subcommand

1. Discover scripts. If none: print `No shell scripts found; skipping.` and exit `0`.
2. Preflight both tools before running either: missing `shfmt` prints the missing-tool block
   and exits `127`; then missing `shellcheck` prints the missing-tool block and exits `127`.
3. Run `shfmt -d <all files>` once, as a single invocation over the full file list.
4. Run `shellcheck <file>` once per file (per-file invocation so failures are attributable to
   a specific file); track the maximum shellcheck exit code across files.
5. Final exit code is `max(shfmt_exit, max_shellcheck_exit)`.

### `format` subcommand

1. Discover scripts. If none: print `No shell scripts found; skipping.` and exit `0`.
2. Missing `shfmt` prints the missing-tool block and exits `127`.
3. Run `shfmt -w <all files>`; exit with its code.

### `test` subcommand

- Test directories: `tests/shell` and `tests/bash`, whichever exist, checked in that order.
- If no test directory exists: print `No shell test directories found; skipping.` and exit
  `0`.
- If `bats` is missing:
  - in coverage mode: print `bats not installed; cannot run shell tests with coverage.` and
    exit `127`;
  - in non-coverage mode: print `bats not installed; skipping shell tests.` and exit `0`.
- Non-coverage run: `bats <dir>` once per test directory; every directory runs even if an
  earlier one fails; the final exit code is the maximum across directories.

### `test --coverage`

1. If `kcov` is missing: print `kcov not installed; cannot run shell tests with coverage.`
   followed by the missing-tool block for `kcov`; exit `127`.
2. Output directory: `artifacts/pester/kcov` (resolved against the repo root when relative,
   overridable via `SHELL_QC_KCOV_OUT_DIR`). Delete it recursively (ignoring errors), recreate
   it, and create `artifacts/pester/kcov/.kcov_runs`.
3. Per test directory, in order, using a stable run directory `.kcov_runs/<dirname>`:

   ```
   kcov --cobertura-only \
        --include-pattern=<abs-root>/tools,<abs-root>/scripts \
        --exclude-pattern=<abs-root>/tests \
        <run_dir> <resolved-bats-path> <test_dir>
   ```

   The include pattern is a single comma-joined argument covering both search roots. The
   `bats` executable is passed as a resolved absolute path (`command -v bats`). Coverage runs
   stop at the first failing directory, unlike the non-coverage path.
4. On success with at least one run directory: `kcov --merge artifacts/pester/kcov
   <run_dirs...>`; the merged directory contains a single `cov.xml`.
5. `.kcov_runs` is always removed afterward, on success or failure.
6. On overall success, parse the first `line-rate="X"` (or single-quoted equivalent)
   attribute from `cov.xml` and print `Bash coverage (lines): NN.N%` (percentage with exactly
   one decimal place). A missing or unparseable `cov.xml` prints nothing and still exits `0`.

### Missing-tool message block

Exactly five lines, with the package name defaulting to the tool name:

```
Missing required tool: <tool>
Devcontainer install (apt-get): apt-get update && apt-get install -y <package>
macOS (Homebrew): brew install <package>
Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y <package>
On Windows, use WSL for best results.
```

Exit code for any missing required tool: `127`.

### `--help` / usage

`--help`, `-h`, and `help` print usage for `check|format|test [--coverage]` and exit `0`, so
`.github/workflows/_build-check.yml` has a zero-dependency installability smoke (no
shfmt/shellcheck/bats install required). An unknown or missing subcommand prints usage to
stderr and exits `2` (argparse parity: argparse exits 2 on usage errors).

### Byte-identical skip markers (required)

`scripts/dev_tools/fix_all.py::shell_test_was_skipped` string-matches two exact skip markers
emitted by the toolchain. The native wrapper MUST emit these two strings byte-identically, or
`fix_all` will misreport skips as passes:

- `No shell test directories found; skipping.`
- `bats not installed; skipping shell tests.`

## Inputs / Outputs

- Inputs: subcommand (`check`, `format`, `test`), `--coverage` flag on `test`, `--help`/`-h`;
  environment overrides `SHELL_QC_<TOOL>_BIN` (per-tool path override for `shfmt`,
  `shellcheck`, `bats`, `kcov`; empty or nonexistent value is treated as missing) and
  `SHELL_QC_KCOV_OUT_DIR` (default `artifacts/pester/kcov`).
- Outputs: shfmt diffs (`check`) or rewritten files (`format`) on stdout/disk; shellcheck
  findings on stdout; bats TAP-style output; on `--coverage`, a Cobertura `cov.xml` under the
  resolved kcov output directory and a `Bash coverage (lines): NN.N%` summary line.
- Config keys and defaults: `SHELL_QC_KCOV_OUT_DIR` defaults to `artifacts/pester/kcov`; no
  other configuration surface.
- Versioning or backward-compatibility constraints: none — the Poetry console-script and
  Python module surfaces are removed entirely, not deprecated in place, per AC4/AC5.

## API / CLI Surface

- `bash scripts/bash/shell-qc.sh check` — lint/format-check all discovered shell scripts;
  exit 0 on no findings, non-zero on findings, 127 if `shfmt`/`shellcheck` missing.
- `bash scripts/bash/shell-qc.sh format` — rewrite all discovered shell scripts with `shfmt
  -w`; 127 if `shfmt` missing.
- `bash scripts/bash/shell-qc.sh test` — run bats against `tests/shell` and `tests/bash`.
- `bash scripts/bash/shell-qc.sh test --coverage` — run bats under `kcov`, emit `cov.xml`,
  print the coverage summary line.
- `bash scripts/bash/shell-qc.sh --help` — print usage; exit 0.
- Contracts and validation rules: unknown subcommands or unrecognized flags on `test` exit 2;
  the two skip-marker strings above are a byte-identical contract with `fix_all.py`.

## Data & State

- Data transformations and invariants: discovery output is a de-duplicated, lexicographically
  sorted file list; coverage output is a single merged Cobertura `cov.xml`.
- Caching or persistence details: the kcov output directory
  (`artifacts/pester/kcov`, override via `SHELL_QC_KCOV_OUT_DIR`) is deleted and recreated on
  each `--coverage` run; the transient `.kcov_runs` subdirectory is always removed afterward.
- Migration or backfill requirements: none. `poetry.lock` regeneration is not required for
  this change (the console-script removal changes the built wheel, not the dependency set).

## Constraints & Risks

- Behavior parity: the native wrapper must preserve the discovery, per-file linting, diff vs.
  write format modes, and coverage-merge semantics of the removed Python module.
- CI parity: shellcheck/shfmt/bats/kcov versions are pinned/installed on `ubuntu-latest`;
  local WSL versions may drift (WinGet-installed on the host). The rule doc must call this out
  and state that CI versions are canonical when local and CI results disagree.
- File-size limit: the bash wrapper and its bats tests must each stay under 500 lines (per
  `.claude/rules/general-code-change.md`). The library/wrapper split
  (`scripts/bash/shell_qc_lib.sh` + `scripts/bash/shell-qc.sh`) keeps each file comfortably
  under this limit; split the bats suite (e.g. `test_shell_qc_discovery.bats` /
  `test_shell_qc_commands.bats`) if a single file approaches 500 lines.
- Coverage: `scripts/dev_tools` is in the Python coverage denominator (`[tool.coverage.run]
  source = ["src", "scripts/dev_tools"]`); removing `shell_qc.py` removes an untested Python
  file (0% of 222 statements) from that denominator and raises the aggregate Python coverage
  total. No coverage configuration change is required.
- Test policy: no temporary files in tests (per `.claude/rules/general-unit-test.md`); use the
  checked-in fixture tree `tests/fixtures/shell_qc/` and checked-in stub binaries under
  `tests/fixtures/shell_qc/stub-bin/` instead of writing files at test time.
- Tone: all authored documentation and rule content must remain strictly professional per
  `CLAUDE.md` and `.claude/rules/tonality.md`.

## Implementation Strategy

- Implementation scope: one executable entry point plus one sourceable library.
  - `scripts/bash/shell-qc.sh` — executable wrapper: argument parsing, subcommand dispatch,
    top-level `main "$@"` guarded so the file can also be sourced.
  - `scripts/bash/shell_qc_lib.sh` — sourceable function library: discovery, shebang parsing,
    missing-tool printer, tool resolution (`resolve_tool`, honoring the `SHELL_QC_<TOOL>_BIN`
    seam), check/format/test/coverage implementations, Cobertura line-rate extraction.
  - Both new files live under `scripts/`, so the toolchain's own discovery finds them; they
    must be shfmt-clean and shellcheck-clean from the first commit (self-hosting).
  - Do not fold this logic into `scripts/bash/coverage_lib.sh` — that file is a demo fixture
    exercised by `tests/shell/test_coverage_demo.bats`; mixing concerns would violate the
    small-cohesive-modules rule.
- New classes/functions/commands: `discover_shell_scripts`, `is_shell_script`,
  `extract_shebang_command`, `resolve_tool`, `print_missing_tool_block`, `run_check`,
  `run_format`, `run_test`, `run_test_coverage`, `extract_cobertura_line_rate`; CLI
  subcommands `check`, `format`, `test [--coverage]`, `--help`/`-h`/`help`.
- Dependency changes: none added. Poetry, the Python interpreter, and the five Poetry
  console-script entries (`shell-qc`, `shell-qc-check`, `shell-qc-format`, `shell-qc-test`,
  `dev.shell-qc`) are removed as runtime dependencies of the shell toolchain. `shfmt`,
  `shellcheck`, `bats`, and `kcov` remain the same external tool dependencies as before (now
  invoked directly instead of through a Python subprocess layer).
- Logging/telemetry additions: none beyond the existing stdout messages (skip markers,
  missing-tool blocks, coverage summary line); no new telemetry surface is introduced.
- Rollout plan: no feature flag or staged rollout. This is an atomic toolchain replacement:
  the Python module, its Poetry entries, and its consumers are updated in the same change so
  there is no dual-path interim state. Fallback is `git revert` of the change set.

### Hidden consumer: `scripts/dev_tools/fix_all_branches.py`

`scripts/dev_tools/fix_all_branches.py` invokes the shell toolchain three times (format,
check, test) via `["poetry", "run", "python", "-m", "scripts.dev_tools.shell_qc", "<cmd>"]`.
This module has no other reference in `issue.md` or the research trigger path and is easy to
miss because it is not part of the CI workflow YAML or `pyproject.toml`. It MUST be repointed
to `["bash", "scripts/bash/shell-qc.sh", "<cmd>"]` in this change. The existing
`tests/scripts/dev_tools/test_fix_all_branches.py` fakes responses by step name (e.g. `"Shell:
format"`), not by command list, so this repointing does not require changes to that test
file; run pytest afterward to confirm.

### Full reference-update inventory

| File | Scope | Edit |
|---|---|---|
| `pyproject.toml` | 5 entries | Remove `shell-qc`, `shell-qc-check`, `shell-qc-format`, `shell-qc-test`, `dev.shell-qc` console-script entries. |
| `scripts/dev_tools/shell_qc.py` | whole file | Delete. |
| `scripts/dev_tools/fix_all_branches.py` | 3 command lists | Replace `["poetry","run","python","-m","scripts.dev_tools.shell_qc","<cmd>"]` with `["bash","scripts/bash/shell-qc.sh","<cmd>"]` for `format`, `check`, `test`. |
| `.vscode/tasks.json` | 3 tasks | Replace `command: poetry`, `args: ["run","shell-qc","<cmd>"]` with `command: bash`, `args: ["scripts/bash/shell-qc.sh","<cmd>"]` for the format/check/test tasks; the `bash -n` type-check task is unchanged. |
| `.github/workflows/_shell-coverage.yml` | Python/Poetry setup steps and the run step | Remove `Set up Python`, `Install Poetry`, `Load cached venv`, `Install dependencies`, `Install project`; replace the run step with `bash scripts/bash/shell-qc.sh test --coverage`. |
| `.github/workflows/_build-check.yml` | 1 smoke step | Remove the `shell-qc --help` wheel smoke; add `bash scripts/bash/shell-qc.sh --help`. |
| `README.md` | Poetry `shell-qc` documentation, console-script name list, file link | Replace with `bash scripts/bash/shell-qc.sh format\|check\|test [--coverage]`; repoint the file link from `scripts/dev_tools/shell_qc.py` to `scripts/bash/shell-qc.sh`. |
| `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` | invocation example | Replace `poetry run shell-qc <cmd>` with the native invocation. |
| `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` | invocation example | Same replacement (mirrored template). |
| `.claude/rules/shell.md` | new file | Add, per the Non-Goals/toolchain documentation below. |

**Excluded from this inventory (frozen evidence, must not be edited):** historical artifacts
under `docs/features/completed/**` and `docs/features/archive/**` that reference
`shell-qc`/`shell_qc`.

### `.claude/rules/shell.md` (new rule)

Path-scoped (e.g. `**/*.sh`, `**/*.bats`, `scripts/bash/**`, `tests/shell/**`), matching the
structure of `.claude/rules/python.md` / `.claude/rules/powershell.md`. Required content:

1. Toolchain order: formatting (`shfmt`, via `... format` / diff mode inside `... check`),
   linting (`shellcheck`, via `... check`), type-checking N/A (optionally `bash -n` syntax
   check), testing (`bats` via `... test`, coverage via `... test --coverage`). Loop rule:
   rerun from formatting when any stage fails or rewrites files.
2. Native invocation and environment: no Python or Poetry dependency; runs under WSL on
   Windows; runs on `ubuntu-latest` in CI.
3. Discovery contract: search roots `tools/` and `scripts/`; `.sh` suffix or bash/sh shebang
   (including `env` forms); excluded dirs `.venv`, `.git`, `node_modules`, `dist`, `build`;
   bats test dirs `tests/shell` and `tests/bash`.
4. Coverage expectations: kcov emits Cobertura `cov.xml` under `artifacts/pester/kcov`; the
   run prints `Bash coverage (lines): NN.N%`. kcov reports line coverage only — the uniform
   line coverage threshold applies; branch coverage is not measurable by kcov for bash and no
   bash branch-coverage gate exists.
5. CI-vs-local version drift: CI pins shfmt 3.8.0 (binary), apt-packaged shellcheck/bats, kcov
   v43 built from source; local WSL installs (winget/apt) may drift. CI versions are
   canonical; local and CI disagreement defers to CI.
6. Coding standards: `set -euo pipefail`; shellcheck-clean without suppressions unless
   justified inline (`# shellcheck disable=SCxxxx` with reason); shfmt default formatting;
   500-line file limit; tests in `tests/shell/*.bats` mirroring `scripts/bash/`; no temp files
   in tests (fixtures under `tests/fixtures/`).

## Non-Goals

- The `pyright` subcommand (`shell_qc.py`'s `run_pyright`, which shelled out to `poetry run
  pyright`) is NOT carried into the native bash toolchain. It is Python tooling, not bash
  tooling, and porting it would reintroduce the Poetry dependency this feature removes.
  Pyright remains reachable via `poetry run pyright` per `.claude/rules/python.md`, and
  `fix_all` continues to run pyright through its own Python branch, independent of this
  change.
- No feature-flagged or dual-path (Python-and-bash) interim state is provided; this is an
  atomic replacement, not a phased migration.
- No change to Poetry's role for the rest of the Python toolchain (black/ruff/pyright/pytest);
  only the shell-qc console-script surface is removed from `pyproject.toml`.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Acceptance Criteria Mapping (AC1–AC9)

| AC | Text (verbatim from issue.md) | Verifiable outcome |
|---|---|---|
| AC1 | A native bash wrapper `scripts/bash/shell-qc.sh` provides `check`, `format`, and `test` subcommands that invoke `shfmt`, `shellcheck`, and `bats` directly, with no Python and no Poetry involved. | `scripts/bash/shell-qc.sh` exists, dispatches `check`/`format`/`test`, and its implementation (including `scripts/bash/shell_qc_lib.sh`) contains no `python`/`poetry`/`.py` invocation; verified by grep of the two new files and by bats tests exercising each subcommand. |
| AC2 | The `test` subcommand supports a coverage mode that runs `bats` under `kcov` and emits a Cobertura `cov.xml`, preserving the prior behavior. | `test --coverage` invokes `kcov --cobertura-only ...` per test directory, merges runs, and produces `cov.xml` under `artifacts/pester/kcov` (or `SHELL_QC_KCOV_OUT_DIR`); verified by bats tests asserting kcov argv shape and by the `_shell-coverage.yml` CI run producing `cov.xml` as an uploaded artifact. |
| AC3 | The wrapper reproduces the prior discovery rules: searches `tools/` and `scripts/`; recognizes `.sh` suffix or bash/sh shebang; excludes `.venv`, `.git`, `node_modules`, `dist`, `build`; runs bats against `tests/shell` and `tests/bash` when present. | `discover_shell_scripts`/`is_shell_script` in `shell_qc_lib.sh` implement the documented rules; bats discovery tests cover `.sh` suffix, extensionless shebang, `env` and `env -S` forms, uppercase shebang, excluded-dir pruning, and sorted output using the fixture tree under `tests/fixtures/shell_qc/`. |
| AC4 | `scripts/dev_tools/shell_qc.py` is removed and all five Poetry console-script entries referencing it are removed from `pyproject.toml`. | `scripts/dev_tools/shell_qc.py` is deleted from the repository; `pyproject.toml` no longer contains `shell-qc`, `shell-qc-check`, `shell-qc-format`, `shell-qc-test`, or `dev.shell-qc`; verified by file-absence check and grep of `pyproject.toml`. |
| AC5 | No component of the shell toolchain (local or CI) invokes Python or Poetry. | Grep across `scripts/bash/shell-qc.sh`, `scripts/bash/shell_qc_lib.sh`, `scripts/dev_tools/fix_all_branches.py`, `.vscode/tasks.json`, `.github/workflows/_shell-coverage.yml`, and `.github/workflows/_build-check.yml` finds no `poetry`/`python -m scripts.dev_tools.shell_qc` reference tied to the shell path. |
| AC6 | `.github/workflows/_shell-coverage.yml` and `.github/workflows/_build-check.yml` invoke the native bash wrapper with no Poetry install or `poetry run`. | Both workflow files, after edit, contain `bash scripts/bash/shell-qc.sh ...` invocations and no `snok/install-poetry`, `poetry install`, or `poetry run` step tied to the shell path; verified by diff review and a green CI run (see AC9). |
| AC7 | `.claude/rules/shell.md` exists, is path-scoped to shell files, and documents the native toolchain, invocation, and coverage policy. | `.claude/rules/shell.md` exists with YAML frontmatter `paths:` scoped to shell file patterns and covers toolchain order, native invocation/environment, discovery contract, coverage expectations, and CI-vs-local version drift, per the outline in Implementation Strategy. |
| AC8 | The native wrapper is covered by bats tests under `tests/shell/`. | `tests/shell/test_shell_qc.bats` (or its split files) exercises discovery, `check`, `format`, `test`, and `test --coverage` scenarios using checked-in fixtures and stub binaries under `tests/fixtures/shell_qc/`; `bash scripts/bash/shell-qc.sh test` passes locally under WSL. |
| AC9 | A green CI run against the branch head verifies the modified workflows (`modified-workflow-needs-green-run`). | A CI run of `ci.yml` (which calls `_shell-coverage.yml`) and `_build-check.yml` against the branch head completes green after the workflow edits; evidence captured under `docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/<kind>/`. |

## Seeded Test Conditions (from potential)

- [ ] Discovery: `.sh` suffix, shebang detection (`bash`, `sh`, `env` forms), exclusion dirs.
- [ ] `check` runs shfmt diff mode and shellcheck per file; non-zero on findings.
- [ ] `format` runs shfmt write mode.
- [ ] `test` runs bats per test dir; skips cleanly when no tests/tools present.
- [ ] Coverage mode runs kcov and merges reports; missing tool yields a clear error.
- [ ] Missing-tool handling: clear message and non-zero exit when shfmt/shellcheck/bats/kcov
- [ ] are absent.

## Open Questions

- `poetry.lock` regeneration: the research indicates this is not strictly required by the
  removal of console-script entries (it changes the built wheel, not the dependency set), but
  this has not been independently re-verified against the current `pyproject.toml` state at
  implementation time; confirm during P3 (Removal) whether `poetry lock` is required by CI
  before merge.
