# AC Verification Record (P5-T11) (Issue #393)

Timestamp: 2026-07-21T18-45
AC source: docs/.../issue.md (AC1–AC9), mirrored in spec.md "Acceptance Criteria Mapping".

Legend: VERIFIED = statically/behaviorally verified by the executor now; IMPLEMENTED-PENDING =
implementation complete, final verification (bats suite pass and/or CI green run) delegated to
orchestrator/CI per the executor's toolchain constraints.

| AC | Status | Evidence |
|----|--------|----------|
| AC1 | VERIFIED | `scripts/bash/shell-qc.sh` + `scripts/bash/shell_qc_lib.sh` created; dispatch of check/format/test/--help present (readable case dispatch). `grep -nE "python\|poetry"` over both files = NONE (P1-T6). Bats coverage of each subcommand written (AC8). Evidence: reference-sweep, shell-selfhost-check, shell-test-phase2. |
| AC2 | IMPLEMENTED-PENDING | `run_test_coverage` invokes `kcov --cobertura-only --include-pattern=... --exclude-pattern=... <run_dir> <bats> <test_dir>`, merges via `kcov --merge`, emits `cov.xml`, prints `Bash coverage (lines): NN.N%`. Bats asserts argv shape + merge + 75.0% summary. Real cov.xml artifact verified by `_shell-coverage.yml` (P5-T9, deferred). |
| AC3 | IMPLEMENTED-PENDING | `discover_shell_scripts`/`is_shell_script`/`extract_shebang_command` implement roots tools/scripts, .sh suffix + bash/sh shebang incl. env/env -S/uppercase, exclusions .venv/.git/node_modules/dist/build, LC_ALL=C sort -u; test dirs tests/shell then tests/bash. Discovery bats suite (11 tests) written; execution deferred to CI. |
| AC4 | VERIFIED | `scripts/dev_tools/shell_qc.py` deleted (absent from tree); `grep "shell.qc" pyproject.toml` = NONE (five entries removed). `poetry.lock` unmodified. Evidence: poetry-lock-resolution, python-postremoval, reference-sweep. |
| AC5 | VERIFIED | No shell-toolchain component invokes Python/Poetry: grep over shell-qc.sh, shell_qc_lib.sh, fix_all_branches.py, tasks.json, _shell-coverage.yml, _build-check.yml shows only `bash scripts/bash/shell-qc.sh` invocations; no `scripts.dev_tools.shell_qc`, no `poetry run` on the shell path. Evidence: reference-sweep, workflow-review, python-fixall-tests. |
| AC6 | IMPLEMENTED-PENDING | Both workflows migrated to `bash scripts/bash/shell-qc.sh ...`; no snok/install-poetry, poetry install, or poetry run on the shell path; artifact-upload contract preserved (workflow-review). Green CI run per `modified-workflow-needs-green-run` deferred to P5-T9/AC9. |
| AC7 | VERIFIED | `.claude/rules/shell.md` created with path-scoped frontmatter (`**/*.sh`, `**/*.bats`, `scripts/bash/**`, `tests/shell/**`) and all six sections (toolchain order, native invocation/environment, discovery contract, coverage expectations, CI-vs-local version drift, coding standards). Byte-identically mirrored into the extension bundle (contract test passes). |
| AC8 | IMPLEMENTED-PENDING | `tests/shell/test_shell_qc_discovery.bats` (11 tests) + `tests/shell/test_shell_qc_commands.bats` (19 tests) cover discovery, check, format, test, and test --coverage using checked-in fixtures + stub-bin; the two byte-identical fix_all skip markers are asserted (P0-T10 cross-check). Bats execution deferred to CI (P5-T9). |
| AC9 | IMPLEMENTED-PENDING | Green CI run against branch head for ci.yml (calls _shell-coverage.yml) and _build-check.yml is a pre-merge gate; the executor does not push. Deferred to orchestrator/CI (ci-green-run). |

## Skip-marker contract verification (cross-cutting)
The two fix_all-consumed markers "No shell test directories found; skipping." and
"bats not installed; skipping shell tests." are emitted byte-identically by `run_test` in
`shell_qc_lib.sh` and asserted with exact-string equality in
`tests/shell/test_shell_qc_commands.bats` (P2-T6), matching the P0-T10 baseline capture from
`shell_qc.py` and the consumer `fix_all.py::shell_test_was_skipped`.

## Summary
- Executor-VERIFIED now: AC1, AC4, AC5, AC7.
- IMPLEMENTED, verification delegated to orchestrator/CI (bats suite pass + green CI run):
  AC2, AC3, AC6, AC8, AC9. No AC is unimplemented; each pending item has a concrete
  verification path (bats execution and/or the P5-T9 CI green run).
