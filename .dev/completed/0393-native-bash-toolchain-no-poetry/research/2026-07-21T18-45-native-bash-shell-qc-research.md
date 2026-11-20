# Research: Native Bash shell-qc Wrapper (No Python / No Poetry) — #393

- **Issue:** #393
- **Feature:** `docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393`
- **Date:** 2026-07-21
- **Author:** task-researcher agent
- **Sources verified:** `scripts/dev_tools/shell_qc.py` (read in full, 495 lines), `pyproject.toml`, `.github/workflows/_shell-coverage.yml`, `.github/workflows/_build-check.yml`, `.github/workflows/ci.yml`, `scripts/dev_tools/fix_all.py`, `scripts/dev_tools/fix_all_branches.py`, `tests/scripts/dev_tools/test_fix_all_branches.py`, `.vscode/tasks.json`, `README.md` (grep), `scripts/bash/coverage_lib.sh`, `scripts/bash/coverage_demo.sh`, `tests/shell/test_coverage_demo.bats`, `tests/fixtures/shell_qc/**`, `.claude/rules/python.md`, `.claude/rules/powershell.md`, `.claude/rules/ci-workflows.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, feature `spec.md`.

## 1. Current State Analysis

`scripts/dev_tools/shell_qc.py` (495 lines) is the sole driver of the bash toolchain. It is
invoked five ways, all Poetry-dependent:

| Consumer | Invocation | Location |
|---|---|---|
| Poetry console scripts | `shell-qc`, `shell-qc-check`, `shell-qc-format`, `shell-qc-test`, `dev.shell-qc` | `pyproject.toml` lines 50–53, 86 |
| CI coverage workflow | `poetry run shell-qc test --coverage` | `.github/workflows/_shell-coverage.yml` line 78 |
| CI build smoke | `shell-qc --help` (installed wheel) | `.github/workflows/_build-check.yml` line 35 |
| fix-all pipeline | `poetry run python -m scripts.dev_tools.shell_qc format\|check\|test` | `scripts/dev_tools/fix_all_branches.py` lines 181–188, 205–212, 224–232 |
| VS Code tasks | `poetry` + args `["run","shell-qc","format\|check\|test"]` | `.vscode/tasks.json` lines 434–455, 456–477, 499–519 |

Additional facts verified:

- `scripts/dev_tools/fix_all.py::shell_test_was_skipped` (lines 306–331) string-matches two
  exact skip markers emitted by `shell_qc.py`:
  `"No shell test directories found; skipping."` and
  `"bats not installed; skipping shell tests."`. The native wrapper must emit these strings
  byte-identically or `fix_all` will misreport skips as passes.
- No pytest file tests `shell_qc.py` (glob `tests/**/test_shell_qc*` returns nothing);
  historical coverage evidence records it at 0% of 222 statements.
- Orphaned fixtures already exist at `tests/fixtures/shell_qc/` (`tools/format_me.sh`,
  `scripts/with_shebang` — an extensionless file with `#!/usr/bin/env bash`,
  `scripts/ignored.txt`, `scripts/pwsh_script.ps1`, `tests/shell/README.txt`). No test
  references them today; they are reusable for the bats suite.
- `test_fix_all_branches.py` fakes key responses by step name (`"Shell: format"` etc.), not
  by command list, so changing the command in `fix_all_branches.py` does not break the
  existing fake-runner tests.
- Existing bats tests live at `tests/shell/*.bats`; `tests/bash/` does not exist.
- `scripts/bash/` uses tab indentation (shfmt default) in `coverage_lib.sh`.

## 2. Behavior-Parity Contract

The bash wrapper `scripts/bash/shell-qc.sh` must reproduce the following, derived line-by-line
from `shell_qc.py`.

### 2.1 Script discovery

- Search roots: `tools/` and `scripts/`, relative to the current working directory. A missing
  root is silently skipped (`shell_qc.py` lines 97–99).
- Directory exclusion at any depth, pruned during traversal: `.venv`, `.git`,
  `node_modules`, `dist`, `build` (line 18).
- A file is a shell script when either:
  - its suffix, lowercased, is `.sh` (line 86); or
  - its first line is a shebang whose resolved interpreter command is `bash` or `sh`
    (lines 70–89). Parsing rules (lines 40–67):
    - the first line is lowercased before parsing (line 76), so `#!/usr/bin/env BASH`
      qualifies;
    - strip `#!`, trim whitespace; empty payload → not a shell script;
    - word-split the payload; take the basename of the first token;
    - if the basename is `env`, drop it, then drop any leading tokens starting with `-`
      (covers `env -S bash` style flags); take the basename of the next token; if none
      remain → not a shell script;
    - unreadable files → not a shell script (no error).
- Result set is de-duplicated and sorted lexicographically by path string (line 104).
  In bash: `LC_ALL=C sort -u` for deterministic codepoint ordering.

Bash reproduction of shebang parsing:

```bash
# Read only the first line without loading the whole file.
IFS= read -r first_line <"$file" || true
first_line=${first_line,,}                # lowercase, parity with .lower()
[[ $first_line == '#!'* ]] || return 1
payload=${first_line#\#!}
read -ra parts <<<"$payload"              # whitespace word-split
(( ${#parts[@]} )) || return 1
cmd=${parts[0]##*/}                       # basename
if [[ $cmd == env ]]; then
    i=1
    while (( i < ${#parts[@]} )) && [[ ${parts[$i]} == -* ]]; do ((i++)); done
    (( i < ${#parts[@]} )) || return 1
    cmd=${parts[$i]##*/}
fi
[[ $cmd == bash || $cmd == sh ]]
```

Difference from the Python original: Python uses `shlex.split` (quote-aware); shebang lines
never legitimately contain quotes, so plain word-splitting is acceptable parity. Note this in
the wrapper comment.

### 2.2 `check` subcommand (lines 167–193)

1. Discover scripts. If none: print `No shell scripts found; skipping.` and exit `0`.
2. Preflight both tools before running either: missing `shfmt` → missing-tool block, exit
   `127`; then missing `shellcheck` → missing-tool block, exit `127`.
3. Run `shfmt -d <all files>` once (single invocation with the full file list).
4. Run `shellcheck <file>` once per file (per-file to keep failures attributable);
   track the maximum shellcheck exit code.
5. Final exit code: `max(shfmt_exit, max_shellcheck_exit)`.

### 2.3 `format` subcommand (lines 196–212)

1. Discover scripts. If none: print `No shell scripts found; skipping.` and exit `0`.
2. Missing `shfmt` → missing-tool block, exit `127`.
3. Run `shfmt -w <all files>`; exit with its code.

### 2.4 `test` subcommand (lines 344–435)

- Test directories: `tests/shell` and `tests/bash`, whichever exist, in that order
  (lines 20, 107–116).
- No test directory exists: print `No shell test directories found; skipping.`, exit `0`.
- `bats` missing:
  - coverage mode: print `bats not installed; cannot run shell tests with coverage.`,
    exit `127`;
  - non-coverage mode: print `bats not installed; skipping shell tests.`, exit `0`.
- Non-coverage run: `bats <dir>` once per test directory; exit code is the maximum across
  directories (all directories run even if one fails — lines 383–387).

### 2.5 `test --coverage` (lines 389–435)

1. `kcov` missing: print `kcov not installed; cannot run shell tests with coverage.` followed
   by the missing-tool block for `kcov`; exit `127`.
2. Output directory: `artifacts/pester/kcov` (resolved against the repo root when relative).
   Delete it recursively (ignore errors), recreate it, and create `artifacts/pester/kcov/.kcov_runs`.
3. Per test directory, in order, with a stable run dir `.kcov_runs/<dirname>`:

   ```
   kcov --cobertura-only \
        --include-pattern=<abs-root>/tools,<abs-root>/scripts \
        --exclude-pattern=<abs-root>/tests \
        <run_dir> <resolved-bats-path> <test_dir>
   ```

   The include pattern is a single comma-joined argument covering both search roots. The
   bats executable is passed as a resolved absolute path (`shutil.which("bats")` parity via
   `command -v bats`). Coverage runs stop at the first failing directory (line 418–419),
   unlike the non-coverage path.
4. On success with at least one run dir: `kcov --merge artifacts/pester/kcov <run_dirs...>`;
   the merged directory contains a single `cov.xml`.
5. Always remove `.kcov_runs` afterwards (success or failure).
6. On overall success, parse the first `line-rate="X"` (or single-quoted) attribute from
   `cov.xml` with a regex-equivalent match and print
   `Bash coverage (lines): NN.N%` (percentage with exactly one decimal place). Missing or
   unparseable `cov.xml` → print nothing, still exit `0` (lines 324–341).

   Bash equivalents: `grep -oE 'line-rate=["'"'"'][0-9.]+["'"'"']' cov.xml | head -n1` for
   extraction; `awk 'BEGIN{printf "%.1f", r*100}'` (or `printf` with pre-scaled integer math)
   for the one-decimal percentage.

### 2.6 Missing-tool message block (lines 119–132)

Exactly five lines, package name defaults to the tool name:

```
Missing required tool: <tool>
Devcontainer install (apt-get): apt-get update && apt-get install -y <package>
macOS (Homebrew): brew install <package>
Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y <package>
On Windows, use WSL for best results.
```

Exit code for any missing required tool: `127` (also the code `_run_tool` returns when a tool
disappears between preflight and execution — the wrapper gets this behavior automatically
because a missing command in bash exits 127).

### 2.7 `pyright` subcommand — excluded from the native wrapper

`shell_qc.py` lines 221–238 define `run_pyright`, which shells out to
`poetry run pyright --project pyproject.toml`. Recommendation: do not port it.

- It is Python toolchain, not bash toolchain; porting it would reintroduce the
  Poetry dependency the feature exists to remove.
- Grep across the repository found no live consumer of `shell-qc pyright` (the only match is
  a 2026-02 archived remediation plan). `fix_all` runs pyright through its own python branch.
- Pyright remains reachable via `poetry run pyright` per `.claude/rules/python.md`.

### 2.8 New surface: `--help` / usage

The old CLI provided argparse-generated `--help`, and `_build-check.yml` uses `shell-qc --help`
as an installability smoke. The wrapper must implement a `--help`/`-h`/`help` path that prints
usage for `check|format|test [--coverage]` and exits `0`, so the CI smoke has a zero-dependency
replacement (no shfmt/shellcheck/bats install required in `_build-check.yml`). Unknown or
missing subcommand: print usage to stderr, exit `2` (argparse parity: argparse exits 2 on
usage errors).

## 3. Recommended Implementation Approach

### 3.1 Selected approach

One executable entry point plus one sourceable library:

- `scripts/bash/shell-qc.sh` — executable wrapper: argument parsing, subcommand dispatch,
  top-level `main "$@"` guarded so the file can also be sourced.
- `scripts/bash/shell_qc_lib.sh` — sourceable function library: discovery, shebang parsing,
  missing-tool printer, tool resolution, check/format/test/coverage implementations,
  Cobertura line-rate extraction.

Rationale:

- The library is unit-testable from bats by `source`-ing it, matching the existing pattern
  (`tests/shell/test_coverage_demo.bats` sources `scripts/bash/coverage_lib.sh`).
- Keeps each file comfortably under the 500-line limit (`.claude/rules/general-code-change.md`);
  the estimated combined size with mandated comments is 350–450 lines, which would be tight in
  a single file once usage text and comments are included.
- Do not fold this logic into `coverage_lib.sh` — that file is a demo fixture exercised by
  `test_coverage_demo.bats`; mixing concerns would violate the small-cohesive-modules rule.

Self-hosting note: both new files live under `scripts/`, so discovery will find them and
`check` will lint/format them. They must be shfmt-clean (shfmt default formatting, tab
indentation as in `coverage_lib.sh`) and shellcheck-clean from the first commit.

### 3.2 Bash idioms

- **`set -euo pipefail` with expected-nonzero tools.** shfmt `-d`, shellcheck, bats, and kcov
  legitimately return non-zero. Never invoke them bare under `set -e`. Capture with the
  `|| rc=$?` idiom:

  ```bash
  local rc=0
  shfmt -d "${files[@]}" || rc=$?
  ```

  Maintain a running maximum: `(( rc > exit_code )) && exit_code=$rc || true` — or clearer,
  an explicit `if`. Avoid `local x=$(cmd)` (masks the exit status); assign on a separate line.

- **Tool resolution.** `command -v <tool> >/dev/null 2>&1` for presence checks. For the bats
  path passed to kcov, capture `bats_path=$(command -v bats)`. Add a narrow test seam: a
  `resolve_tool` function that honors an optional `SHELL_QC_<TOOL>_BIN` environment override
  (empty or nonexistent value → treated as missing). This is the smallest seam that lets bats
  tests simulate missing tools and substitute recording stubs without PATH surgery, mirroring
  the dependency-seam guidance in `.claude/rules/python.md`/`powershell.md`.

- **Discovery without Python.** `find` with pruning, NUL-delimited for robustness:

  ```bash
  local roots=() root
  for root in tools scripts; do [[ -d $root ]] && roots+=("$root"); done
  (( ${#roots[@]} )) || return 0
  while IFS= read -r -d '' f; do
      is_shell_script "$f" && printf '%s\n' "$f"
  done < <(find "${roots[@]}" \
      -type d \( -name .venv -o -name .git -o -name node_modules \
                 -o -name dist -o -name build \) -prune \
      -o -type f -print0) | LC_ALL=C sort -u
  ```

  Callers collect with `mapfile -t files < <(discover_shell_scripts)`. `git ls-files` was
  rejected: it misses untracked scripts during development and diverges from the `os.walk`
  semantics of the original.

- **Argument parsing.** A `case "$1"` dispatch is sufficient for
  `check | format | test [--coverage] | --help|-h|help`. Reject unknown flags on `test`
  (argparse rejected them); reject extra positional arguments.

- **kcov output-dir override.** Accept `SHELL_QC_KCOV_OUT_DIR` (default
  `artifacts/pester/kcov`) so tests can redirect coverage output under
  `artifacts/` without touching the default tree. This mirrors the Python
  `kcov_out_dir` keyword that existed only for tests.

### 3.3 Rejected alternatives

- **Direct `python3 scripts/dev_tools/shell_qc.py` without Poetry:** still a Python
  dependency; contradicts the accepted decision.
- **Makefile / per-tool CI steps without a wrapper:** loses discovery parity, skip semantics,
  and the single local-plus-CI entry point; duplicates logic across workflows, tasks.json,
  and fix_all.
- **Single monolithic `shell-qc.sh`:** viable but leaves little headroom under the 500-line
  limit once the mandated usage text and intent comments are included, and it is harder to
  unit-test functions in isolation.

## 4. Testing Approach (bats)

Location: `tests/shell/test_shell_qc.bats` (split into `test_shell_qc_discovery.bats` /
`test_shell_qc_commands.bats` if the file approaches 500 lines). This directory is already
discovered by the `test` subcommand and by CI.

- **Unit tests of library functions.** `source scripts/bash/shell_qc_lib.sh` and exercise
  pure functions directly (`run extract_shebang_command ...`, `run is_shell_script <fixture>`,
  `run extract_cobertura_line_rate <fixture>`), following the pattern already used in
  `test_coverage_demo.bats`.
- **Fixtures (no temp files).** The general-unit-test policy prohibits temporary files.
  Reuse and extend the checked-in fixture tree `tests/fixtures/shell_qc/`:
  - existing: `tools/format_me.sh`, `scripts/with_shebang` (extensionless bash shebang),
    `scripts/ignored.txt`, `scripts/pwsh_script.ps1`, `tests/shell/README.txt`;
  - add: an `env -S`-flag shebang fixture, an `sh` shebang fixture, an excluded-dir fixture
    (e.g. `scripts/node_modules/skip_me.sh`), a sample `cov.xml` with a known
    `line-rate` for the summary-formatting test, and a fixture root with no `tools/`/`scripts/`
    for the skip path.
  - Discovery is cwd-relative (parity with `Path.cwd()`), so tests run the wrapper inside the
    fixture root: `run bash -c "cd '$FIXTURE_ROOT' && bash '$WRAPPER' check"`.
- **Stubbed tools (checked-in stub-bin, no PATH removal games).** Add executable stubs under
  `tests/fixtures/shell_qc/stub-bin/` (`shfmt`, `shellcheck`, `bats`, `kcov`) that echo their
  argv to stdout and exit with a code taken from an env var (default 0). Tests wire them via
  the `SHELL_QC_<TOOL>_BIN` seam; missing-tool paths set the override to a nonexistent path.
  This avoids restricting `PATH` (which would break `find`/`sort` from coreutils) and avoids
  writing any files. Assertions read the bats `$output`/`$status` variables.
- **Scenario matrix** (maps to the spec's seeded test conditions):
  - discovery: `.sh` suffix, extensionless shebang, `env` form, `env -S` flags form,
    uppercase shebang, excluded dirs pruned, non-shell files ignored, sorted output;
  - `check`: skip message + exit 0 when no scripts; 127 + exact 5-line block when shfmt or
    shellcheck missing; max-exit-code semantics (shfmt fails / shellcheck fails / both);
    single shfmt invocation with full list, per-file shellcheck invocations;
  - `format`: `-w` argument passed; skip and missing-tool paths;
  - `test`: no-test-dir skip message (exact string), bats-missing skip (exit 0, exact
    string), bats-missing under `--coverage` (exit 127, exact string), per-dir max exit;
  - coverage: kcov-missing (127, message + block), kcov argv shape (`--cobertura-only`,
    include/exclude patterns, run dir, bats path, test dir), merge invocation, summary line
    format `Bash coverage (lines): 75.0%` from the fixture `cov.xml`;
  - `--help` exits 0; unknown subcommand exits 2.
- **fix_all contract test (pytest, existing suite).** After `fix_all_branches.py` is updated,
  no new pytest is strictly required (fakes key by step name), but the exact skip-marker
  strings should be asserted in the bats suite since `fix_all.shell_test_was_skipped` depends
  on them.
- The real kcov success path is exercised end-to-end by the `_shell-coverage.yml` run on CI
  (integration coverage); bats unit tests do not need a real kcov binary.

## 5. CI Migration

### 5.1 `.github/workflows/_shell-coverage.yml`

Remove steps (lines 16–40): `Set up Python 3.13`, `Install Poetry` (`snok/install-poetry@v1`),
`Load cached venv` (`actions/cache@v6` on `.venv`), `Install dependencies`
(`poetry install --no-interaction --no-root`), `Install project` (`poetry install --no-interaction`).

Keep unchanged: checkout, `Install shell tooling (shellcheck, shfmt, bats)` (apt shellcheck +
bats, pinned shfmt 3.8.0 binary), kcov cache/build/install (v43 from source), and the
`upload-artifact` step (`artifacts/pester/kcov/**`, `if-no-files-found: error`).

Replace the run step:

```yaml
      - name: Run shell-qc test with coverage
        run: bash scripts/bash/shell-qc.sh test --coverage
```

Exit-code propagation: the default `run:` shell on ubuntu-latest is `bash -e`; a single
command's non-zero exit fails the step directly. The wrapper contains no
deliberately-failing nested command, so the `.claude/rules/ci-workflows.md` pattern (which
targets `pwsh` steps and `$LASTEXITCODE` leakage) imposes no extra requirement here. The one
behavior to preserve deliberately: the wrapper's final `exit "$exit_code"` must be the last
statement so intermediate `|| rc=$?` captures cannot mask a failure.

### 5.2 `.github/workflows/_build-check.yml`

The wheel will no longer ship `shell-qc` entry points, so line 35 (`shell-qc --help`) must be
removed from the venv-install verification (keep `atomic-executor --help`). Add a native
smoke step that needs no tool installs:

```yaml
      - name: Shell QC smoke (native)
        run: bash scripts/bash/shell-qc.sh --help
```

`poetry build` and the Python setup in this workflow are unrelated to the shell path and
stay as-is.

### 5.3 Green-run requirement

Both workflows are modified, so the `modified-workflow-needs-green-run` feature-review rule
applies: a green run of the affected workflows against the branch head is required before
merge. `ci.yml` calls `_shell-coverage.yml`, and both reusable workflows also expose
`workflow_dispatch`. Pushing the branch and observing the Actions runs satisfies this;
no manual portal steps are involved.

## 6. `.claude/rules/shell.md`

Match the structure of `.claude/rules/python.md` / `powershell.md`: YAML frontmatter with
`paths:` and `description:`, then `# Shell (Bash) Code Standards` with a numbered Toolchain
section and coding/testing standards.

Recommended frontmatter:

```yaml
---
paths:
  - "**/*.sh"
  - "**/*.bats"
  - "scripts/bash/**"
  - "tests/shell/**"
description: Shell (bash) toolchain and coding standards.
---
```

Required content:

1. **Toolchain order** — 1. Formatting: shfmt (`bash scripts/bash/shell-qc.sh format`;
   diff mode inside `check`). 2. Linting: shellcheck (`bash scripts/bash/shell-qc.sh check`).
   3. Type checking: not applicable (optionally note `bash -n` syntax check, which
   `.vscode/tasks.json` already provides as "Shell QC: 3 bash: type-check"). 4. Testing: bats
   (`bash scripts/bash/shell-qc.sh test`), coverage via kcov
   (`bash scripts/bash/shell-qc.sh test --coverage`). Loop rule: rerun from formatting when
   any stage fails or rewrites files, consistent with the general toolchain loop.
2. **Native invocation and environment** — the toolchain is native bash with no Python or
   Poetry dependency; on Windows it runs under WSL; on CI it runs on `ubuntu-latest`.
3. **Discovery contract** — search roots `tools/` and `scripts/`; `.sh` suffix or bash/sh
   shebang (including `env` forms); excluded dirs `.venv`, `.git`, `node_modules`, `dist`,
   `build`; bats test dirs `tests/shell` and `tests/bash`.
4. **Coverage expectations** — kcov emits Cobertura `cov.xml` under `artifacts/pester/kcov`;
   the run prints `Bash coverage (lines): NN.N%`. State plainly that kcov reports line
   coverage only; the uniform >= 85% line threshold applies, and branch coverage is not
   measurable by kcov for bash (do not claim a bash branch-coverage gate exists).
5. **CI-vs-local version drift caveat** — CI pins shfmt 3.8.0 (binary), apt-packaged
   shellcheck/bats, kcov v43 built from source; local WSL installs (winget/apt) may drift.
   CI versions are canonical; when local and CI results disagree, defer to CI.
6. **Coding standards** — `set -euo pipefail`; shellcheck-clean without suppressions unless
   justified inline (`# shellcheck disable=SCxxxx` with reason); shfmt default formatting;
   500-line file limit; tests in `tests/shell/*.bats` mirroring `scripts/bash/`; no temp
   files in tests (fixtures under `tests/fixtures/`).

## 7. pyproject.toml and Module Removal — Reference Inventory

### 7.1 Removals

- `pyproject.toml` line 50: `shell-qc = "scripts.dev_tools.shell_qc:main"`
- `pyproject.toml` line 51: `shell-qc-check = "scripts.dev_tools.shell_qc:main_check"`
- `pyproject.toml` line 52: `shell-qc-format = "scripts.dev_tools.shell_qc:main_format"`
- `pyproject.toml` line 53: `shell-qc-test = "scripts.dev_tools.shell_qc:main_test"`
- `pyproject.toml` line 86: `"dev.shell-qc" = "scripts.dev_tools.shell_qc:main"`
- Delete `scripts/dev_tools/shell_qc.py`.
- Regenerate `poetry.lock` only if required by the workflow (script-entry removal changes the
  built wheel, not dependencies; `poetry lock` is not strictly needed but `poetry build`
  output changes).

### 7.2 Live references that must be updated in the same change

| File | Lines | Edit |
|---|---|---|
| `scripts/dev_tools/fix_all_branches.py` | 181–188, 205–212, 224–232 | Replace the three command lists `["poetry","run","python","-m","scripts.dev_tools.shell_qc","<cmd>"]` with `["bash","scripts/bash/shell-qc.sh","<cmd>"]`. Fake-runner tests key by step name and are unaffected; verify with pytest. |
| `scripts/dev_tools/fix_all.py` | 306–331 | No code change; the wrapper must emit the two skip-marker strings verbatim (contract, not an edit). |
| `.vscode/tasks.json` | 434–455, 456–477, 499–519 | Three tasks: `command` `poetry` → `bash`, `args` `["run","shell-qc","<cmd>"]` → `["scripts/bash/shell-qc.sh","<cmd>"]`. Task 3 (`bash -n`) unchanged. |
| `.github/workflows/_shell-coverage.yml` | 16–40, 77–78 | Per section 5.1. |
| `.github/workflows/_build-check.yml` | 35 | Per section 5.2. |
| `README.md` | 16, 68, 366–370 | Replace Poetry `shell-qc` command documentation with `bash scripts/bash/shell-qc.sh format|check|test [--coverage]`; remove the console-script name list entry; repoint the file link from `scripts/dev_tools/shell_qc.py` to `scripts/bash/shell-qc.sh`. |
| `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` | 278–280 | Replace `poetry run shell-qc <cmd>` with the native invocation. |
| `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` | 278–280 | Same replacement (mirrored template). |

Historical artifacts under `docs/features/completed/**` and `docs/features/archive/**`
reference `shell-qc`/`shell_qc` extensively; these are frozen evidence and must not be edited.

### 7.3 Python coverage denominator effect

`[tool.coverage.run] source = ["src", "scripts/dev_tools"]` includes `shell_qc.py`, which is
untested (0% of 222 statements) and repeatedly documented in past evidence as the dominant
repo-wide coverage gap. Deleting it removes 222 uncovered statements from the denominator and
raises the aggregate Python coverage total. No coverage configuration change is needed. No
pytest imports the module (verified by grep of `tests/`), so deletion breaks no Python test;
`fix_all_branches.py` is the only production importer-by-name (as a subprocess module path)
and is updated per 7.2.

## 8. Automation Feasibility

The full change is automatable with no human-interaction requirement. Every task is a code,
test, configuration, or documentation edit inside this repository: a new bash wrapper and
library, bats tests plus checked-in fixtures/stubs, edits to two workflow files, pyproject
line removals, a module deletion, a new rule file, and reference updates in
`fix_all_branches.py`, `tasks.json`, `README.md`, and two templates. No third-party UI,
portal, account, or credential interaction is involved.

Verification of the modified workflows requires a green CI run per the
`modified-workflow-needs-green-run` policy. This is achieved by pushing the branch and
observing the GitHub Actions runs (`ci.yml` → `_shell-coverage.yml`; `workflow_dispatch` is
also available on both reusable workflows). This is an observation step performed through
normal git push and the existing CI, not a manual portal step.

## 9. Ordered Implementation Recommendation

1. **P1 — Library.** Add `scripts/bash/shell_qc_lib.sh`: discovery (`find` + prune +
   `LC_ALL=C sort -u`), shebang parsing, `resolve_tool` with `SHELL_QC_<TOOL>_BIN` seam,
   missing-tool printer (exact 5-line block), Cobertura `line-rate` extraction and one-decimal
   summary formatting.
2. **P1 — Wrapper.** Add `scripts/bash/shell-qc.sh`: `set -euo pipefail`, usage/`--help`
   (exit 0) and usage-error (exit 2) paths, `case` dispatch to `run_check`, `run_format`,
   `run_test [--coverage]` implementing the exact contract in section 2, including the two
   skip-marker strings and `SHELL_QC_KCOV_OUT_DIR` override. Both files shfmt- and
   shellcheck-clean (self-hosted by `check`).
3. **P2 — Tests.** Extend `tests/fixtures/shell_qc/` (new shebang fixtures, excluded-dir
   fixture, `cov.xml` fixture, `stub-bin/` recording stubs); add `tests/shell/test_shell_qc.bats`
   covering the scenario matrix in section 4. Run `bash scripts/bash/shell-qc.sh check` and
   `... test` locally (WSL) as the toolchain gate.
4. **P3 — Consumers.** Update `fix_all_branches.py` (three command lists), `.vscode/tasks.json`
   (three tasks); run pytest to confirm `fix_all` suites still pass.
5. **P3 — Removal.** Remove the five `pyproject.toml` entries; delete
   `scripts/dev_tools/shell_qc.py`; run the Python toolchain (black/ruff/pyright/pytest) to
   confirm no breakage and record the coverage-total improvement.
6. **P4 — CI.** Edit `_shell-coverage.yml` and `_build-check.yml` per section 5.
7. **P4 — Docs and rules.** Add `.claude/rules/shell.md` per section 6; update `README.md`
   and the two policy-audit templates.
8. **P5 — Verification.** Push the branch; confirm green runs for the modified workflows
   (`modified-workflow-needs-green-run`); capture evidence under
   `docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/<kind>/`.
