# native-bash-toolchain-no-poetry (Issue #393)

- Date captured: 2026-07-21
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/native-bash-toolchain-no-poetry/ (Issue #393)

- Issue: #393
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/393
- Last Updated: 2026-07-21
- Work Mode: full-feature

## Problem / Why

The repository's shell (bash) quality-control toolchain is driven by a Python module,
`scripts/dev_tools/shell_qc.py`, invoked through Poetry console scripts
(`poetry run shell-qc check|format|test`, plus `shell-qc-check|format|test`). This couples
the bash toolchain to a Python interpreter and a Poetry-managed virtual environment. The
toolchain is intended to run under WSL and must not depend on Python or Poetry. The
toolchain is also undocumented in `.claude/rules/`, which lists `python.md`, `powershell.md`,
`typescript.md`, and `csharp.md` but no bash/shell rule, so skills and agents have no
authoritative shell toolchain reference.

## Proposed Behavior

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

## Acceptance Criteria (early draft)

- [x] AC1: A native bash wrapper `scripts/bash/shell-qc.sh` provides `check`, `format`, and
      `test` subcommands that invoke `shfmt`, `shellcheck`, and `bats` directly, with no
      Python and no Poetry involved.
- [x] AC2: The `test` subcommand supports a coverage mode that runs `bats` under `kcov` and
      emits a Cobertura `cov.xml`, preserving the prior behavior.
- [x] AC3: The wrapper reproduces the prior discovery rules: searches `tools/` and
      `scripts/`; recognizes `.sh` suffix or bash/sh shebang; excludes `.venv`, `.git`,
      `node_modules`, `dist`, `build`; runs bats against `tests/shell` and `tests/bash` when
      present.
- [x] AC4: `scripts/dev_tools/shell_qc.py` is removed and all five Poetry console-script
      entries referencing it are removed from `pyproject.toml`.
- [x] AC5: No component of the shell toolchain (local or CI) invokes Python or Poetry.
- [x] AC6: `.github/workflows/_shell-coverage.yml` and `.github/workflows/_build-check.yml`
      invoke the native bash wrapper with no Poetry install or `poetry run`.
- [x] AC7: `.claude/rules/shell.md` exists, is path-scoped to shell files, and documents the
      native toolchain, invocation, and coverage policy.
- [x] AC8: The native wrapper is covered by bats tests under `tests/shell/`.
- [x] AC9: A green CI run against the branch head verifies the modified workflows
      (`modified-workflow-needs-green-run`).

## Constraints & Risks

- Behavior parity: the native wrapper must preserve the discovery, per-file linting, diff vs.
  write format modes, and coverage-merge semantics of the removed Python module.
- CI parity: shellcheck/shfmt/bats/kcov versions are pinned/installed on `ubuntu-latest`;
  local WSL versions may drift (WinGet-installed on the host). The rule doc must call this out.
- File-size limit: the bash wrapper and its bats tests must each stay under 500 lines.
- Coverage: `scripts/dev_tools` is in the Python coverage denominator; removing `shell_qc.py`
  removes an untested Python file from that denominator.

## Test Conditions to Consider

- [ ] Discovery: `.sh` suffix, shebang detection (`bash`, `sh`, `env` forms), exclusion dirs.
- [ ] `check` runs shfmt diff mode and shellcheck per file; non-zero on findings.
- [ ] `format` runs shfmt write mode.
- [ ] `test` runs bats per test dir; skips cleanly when no tests/tools present.
- [ ] Coverage mode runs kcov and merges reports; missing tool yields a clear error.
- [ ] Missing-tool handling: clear message and non-zero exit when shfmt/shellcheck/bats/kcov
      are absent.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/native-bash-toolchain-no-poetry/` folder from the template
