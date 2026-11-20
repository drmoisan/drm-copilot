# PowerShell task classification (issue #543)

Timestamp: 2026-10-02T05-00
Authority: operator decision 2026-10-01, Option A (binding), relayed in the parallel-mode kickoff for cohort 2.
Plan: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md`

## Rule

The worktree isolation guard refuses command text containing `bash`, `pwsh`, or `wsl`. The plan's "sh-pwsh route" (an `sh` wrapper that runs `pwsh -File`) is a route around that guard and is prohibited for this run. No `sh` wrapper and no other route around the guard is used.

## Probe performed before classification

- Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = this worktree and `scan_folders: ["tests/scripts/codex-hooks"]`
- EXIT_CODE: 0 (call disposition; the MCP result carries a fixed summary string and no test output)
- Output Summary: the run wrote `artifacts/pester/pester-junit.xml` in this worktree (gitignored intermediate). Root `testsuites` element: `tests="1231" errors="0" failures="0" disabled="0"`. The `testsuite` element for `tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1` reads `tests="10" errors="0" failures="0" skipped="0"`, and the `testcase` named `Codex epic runtime configuration and distribution contracts.keeps root and tracked bundle runtime copies byte-identical` carries `status="Passed"`.
- Consequence: per-file Pester pass and fail counts, and per-testcase status, are readable from the JUnit file the MCP run writes. `PassedCount` is derived as `tests - failures - errors - skipped` of the matching `testsuite` element; `FailedCount` is `failures + errors`. Zero matching `testsuite` or `testcase` elements counts as a FAILURE, not as clean.

## Derivation for the Pester major version (P0-T4)

`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` is a Pester 5 configuration hashtable (`Run`, `CodeCoverage`, `TestResult` sections), and the `JUnitXml` result format written above is a Pester 5 output format. A successful MCP run that produces `pester-junit.xml` therefore establishes a Pester 5 runtime. The CI `poshqc` job on the pushed head is cited as corroborating evidence.

## Substitution for non-Pester PowerShell observations

Several tasks use PowerShell only to observe repository state. Each is replaced with a native observation that reads the same fact; this is a named plan deviation (D3), not a route around the guard:

| PowerShell form in plan | Native replacement |
|---|---|
| `Test-Path -LiteralPath <p>` | Glob tool or `ls <p>` |
| `@(Get-Content -LiteralPath <p>).Count` | `awk 'END{print NR}' <p>` (counts physical lines, including a final line without a newline) |
| `Select-String -LiteralPath <p> -Pattern <x> [-SimpleMatch]` | Grep tool, or `grep -n [-F] -- <x> <p>` / `grep -c` for counts |
| `Copy-Item -LiteralPath <a> -Destination <b> -Force` | `cp <a> <b>` |
| `Get-FileHash -Algorithm SHA256` equality | `sha256sum <a> <b>` (both hashes recorded) |
| `Get-ChildItem .claude/state -Filter 'python-batch-budget.*.json' \| Remove-Item` | `ls .claude/state/python-batch-budget.*.json` then `rm` of each listed file |
| `git diff (git merge-base origin/main HEAD) ...` | `git diff ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd ...` (literal merge-base SHA; see D2) |

Artifacts record the command actually run in `Command:` and, in place of `Route: sh-pwsh`, record `Route: native (D3)` or `Route: poshqc-mcp (D3)`.

## Classification of the sixteen PowerShell-bearing tasks

| Task | PowerShell use in plan | Classification | Evidence route |
|---|---|---|---|
| P0-T4 | `Test-Path` x2, `Get-Module Pester` version | MCP-satisfiable (version derived) plus native substitution | Glob/`ls` for `node_modules/jest/package.json` and `node_modules/prettier/package.json`; Pester 5 established by the probe above; CI `poshqc` job cited |
| P0-T15 | `Select-String pyproject.toml importlinter` | Native substitution (D3) | `grep -n -F importlinter pyproject.toml` |
| P0-T17 | `Invoke-Pester codex-epic-runtime-contracts.Tests.ps1 -PassThru` | MCP-satisfiable | `run_poshqc_test` over `tests/scripts/codex-hooks`, counts read from the matching `testsuite` element in `artifacts/pester/pester-junit.xml` |
| P0-T18 | `Select-String` checkbox counts on `spec.md` | Native substitution (D3) | `grep -c '^- \[ \] '` and `grep -c '^- \[x\] '` |
| P2-T4 | `Get-ChildItem \| Remove-Item` batch-budget reset | Native substitution (D3) | `ls` then `rm` per file; recount with `ls` |
| P4-T11 | `Get-Content` line count | Native substitution (D3) | `awk 'END{print NR}'` |
| P6-T4 | `Copy-Item` and `Get-FileHash` | Native substitution (D3) | `cp` and `sha256sum` |
| P6-T9 | `Invoke-Pester` pass-after | MCP-satisfiable | as P0-T17; PassedCount compared with the P0-T17 value |
| P7-T3 | `Select-String` x2 | Native substitution (D3) | Grep tool / `grep -n -F` with line numbers |
| P8-T7 | anchored `git diff` | Native substitution (D2, D3) | `git diff <merge-base SHA> --stat -- ...` |
| P9-T6 | anchored `git diff` | Native substitution (D2, D3) | as P8-T7 |
| P9-T7 | `Invoke-Pester` integration | MCP-satisfiable | as P0-T17; PassedCount compared with the P0-T17 value |
| P10-T1 | anchored `git diff -U0` | Native substitution (D2, D3) | `git diff -U0 <merge-base SHA> -- ...` |
| P10-T3 | anchored `git diff` | Native substitution (D2, D3) | `git diff <merge-base SHA> -- ...` |
| P10-T4 | anchored `git diff --name-only` | Native substitution (D2, D3) | `git diff <merge-base SHA> --name-only` plus `git status --porcelain` |
| P10-T5 | `Get-Content` line counts | Native substitution (D3) | `awk 'END{print NR}'` per path |

The same substitutions apply to the other plan tasks that name the sh-pwsh route for state observation only (P0-T6, P2-T1, P3-T2, P3-T4, P4-T10, P6-T1, P6-T3, P6-T5 through P6-T8, P10-T6).

CI-evidence deviations: none required at classification time. If an MCP Pester run cannot produce a readable `testsuite` element for a task, that task falls back to the CI `poshqc` job on the pushed head, cited by run URL and job, recorded as a named deviation.

Operator-run blockers: none identified at classification time.
