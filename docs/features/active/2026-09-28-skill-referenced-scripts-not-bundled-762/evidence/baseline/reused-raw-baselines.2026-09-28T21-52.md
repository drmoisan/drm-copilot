# Reused Raw Baselines (P0-T8)

Record timestamp: 2026-09-28T21-52. Each section below describes one raw log captured at 2026-09-28T19-10
under `FEATURE/evidence/baseline/`. Commands are quoted from `plan.2026-09-28T23-50.md`'s predecessor
`plan.2026-09-28T19-03.md` tasks P1-T1 through P1-T3.

## Section 1: shell-qc.2026-09-28T19-10.txt and shell-qc-full.2026-09-28T19-10.txt

Timestamp: 2026-09-28T19-10
Command: wsl -d Ubuntu -e bash -lc "bash scripts/bash/shell-qc.sh check; bash scripts/bash/shell-qc.sh test --coverage"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `CHECK_EXIT=0` (shfmt diff and shellcheck clean).
- TAP plan `1..477` (shell-qc-full line 60); `TEST_EXIT=1` (final line 7075).
- Exactly two `not ok` lines, both members of KL-SHELL-2, quoted verbatim:
  - line 4538: `not ok 282 dirt_typechange_delta: mutating [MARCTU] to [MARCU] changes the verdict away from UNIQUE (negative control)`
  - line 5182: `not ok 304 dirt_staged_tree_is_commit: injecting a git add call into run_report makes the widened non-mutation assertion fail (negative control)`
- No `Bash coverage (lines):` line is printed because a test failed; numeric bash coverage comes from CI (P0-T19).
- `shell-qc.2026-09-28T19-10.txt` is the 42-line tail of the same run (starts `CHECK_EXIT=0`, ends `TEST_EXIT=1`).

## Section 2: pytest-dev-tools.2026-09-28T19-10.txt

Timestamp: 2026-09-28T19-10
Command: poetry run pytest tests/scripts/dev_tools -q
EXIT_CODE: 0
Output Summary:
- Final line: `5210 passed, 6 skipped in 17.33s`.
- No failures. No coverage numbers (coverage baseline is captured separately in P0-T14).

## Section 3: pester-ci-gate.2026-09-28T19-10.txt

Timestamp: 2026-09-28T19-10
Command: Pester for `tests/scripts/orchestration` (Invoke-Pester over tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1)
EXIT_CODE: 0
Output Summary:
- `Discovery found 15 tests`.
- `Tests Passed: 15, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`.
- No coverage numbers (coverage baseline is captured separately in P0-T17).
