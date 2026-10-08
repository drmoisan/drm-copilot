# PowerShell Task Classification (Operator Decision 2026-10-01, Option A)

Timestamp: 2026-10-07T16-15
Plan: docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/plan.2026-09-29T20-45.md
Classifier: orchestrator (execution resume, parallel run bug-burndown-2026-09-29, cohort 3)

## Binding rule

The plan's `Route: sh-wrapper` convention (plan Conventions, "PowerShell route") is withdrawn. The worktree isolation guard refuses command text containing `bash`, `pwsh`, or `wsl`; no `sh` wrapper or other route around the guard is used. PowerShell gates are satisfied by the PoshQC MCP tools, by the CI `poshqc` job on a pushed head, or are reported as operator-run blockers.

## Observed tool capabilities (pre-classification probes)

- `mcp__drm-copilot__run_poshqc_test` and `mcp__drm-copilot__run_poshqc_analyze` with `scan_folders: ["tests/scripts/workflows"]` returned `{"ok": true, ...}` with a summary line only: no counts line, no `[+]`/`[-]` lines, no coverage headline, no analyzer finding text.
- CI `poshqc / PowerShell QC` job (`.github/workflows/_poshqc.yml`) runs `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, and `Invoke-PoshQCTest` over the whole repository; `config/poshqc-scan.json` test scan folders are `scripts`, `tests/powershell`, `tests/scripts`, so `tests/scripts/workflows`, `tests/scripts/claude-runtime`, and `tests/scripts/codex-hooks` are all inside the CI run. The job log prints per-file `Already formatted:` lines, `PSScriptAnalyzer passed: no findings under <root>`, per-file `[+]`/`[-]` lines, the `Tests Passed: ...` counts line, and the `Covered <pct>% / 0%. ...` headline (verified on main run 37645267440, job 112874273719, head 08ee030d9584bf15882fbb3654c8e38f34c7c359).
- `ci.yml` triggers on `push` to `main`/`development` and `pull_request` into `main`/`development` only, so CI for an intermediate item-branch commit is obtained with `gh workflow run ci.yml --ref bug/epic-child-prs-trigger-no-ci-658` (the `workflow_dispatch` trigger).
- `scripts/dev-tools/run-actionlint.ps1` resolves `actionlint` from PATH first (lines 142-143), passes all script arguments through unchanged (line 159), discards the binary's output (line 128), and exits non-zero exactly when the binary exits non-zero (lines 129-135). The `actionlint` binary is present on PATH in this environment.

## Classification

| Task | Classification | Evidence route |
|---|---|---|
| P0-T16 | MCP-satisfiable | `run_poshqc_format` on `tests/scripts/workflows`; `PreStatus:`/`PostStatus:` porcelain capture is the observation. Per-file `Already formatted:` lines cited from CI main run 37645267440 job 112874273719 (DEV-CI-BASELINE). |
| P0-T17 | MCP-satisfiable (ok flag) plus CI-evidence deviation | `run_poshqc_analyze` ok flag; the `PSScriptAnalyzer passed: no findings under ...` literal cited from CI main run 37645267440 job 112874273719. |
| P0-T18 | CI-evidence deviation | Counts line and coverage headline from CI main run 37645267440 job 112874273719 (full-repository scan, not `tests/scripts/workflows` alone). Item branch differs from 08ee030d by documentation files only. |
| P0-T19 | Operator-run blocker (wrapper literal); substance by deviation | Direct `actionlint .github/workflows/ci.yml` (same binary and arguments the wrapper uses) recorded as DEV-ACTIONLINT-DIRECT. Operator command: `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/ci.yml`. |
| P0-T22 | CI-evidence deviation | Sibling suites are inside the CI full-repository Pester run; main run 37645267440 reports `Failed: 0`. |
| P1-T2 | MCP-satisfiable | File authoring; format and analyze verified by `run_poshqc_format` / `run_poshqc_analyze` and by the CI `poshqc` job. |
| P1-T4 | CI-evidence deviation | Fail-before: CI dispatched on the item-branch commit that adds `CiWorkflow.Tests.ps1` with `ci.yml` unmodified; `[-]` line and counts line read from the `poshqc / PowerShell QC` job log. |
| P1-T5 | CI-evidence deviation | Same dispatched run as P1-T4 (`Invoke-PoshQCTest` is the CI test step). |
| P1-T8 | CI-evidence deviation | CI run on the pushed fix head; `[+]` line for the suite and counts line. |
| P1-T9 | CI-evidence deviation | Same run as P1-T8. |
| P1-T14 | CI-evidence deviation | Byte copy performed with a non-PowerShell copy command (`cp`); identity verified by P1-T15 and by the bundle-parity pytest (AC-6) locally and in CI. |
| P1-T15 | CI-evidence deviation | Hash comparison with `sha256sum`/`cmp` (non-PowerShell) plus the bundle-parity pytest. |
| P2-T1 | MCP-satisfiable | `run_poshqc_format` with `PrePassStatus:`/`PostPassStatus:` porcelain capture; `Already formatted: ...CiWorkflow.Tests.ps1` literal cited from the CI `poshqc` job on the fix head. |
| P2-T2 | MCP-satisfiable (ok flag) plus CI-evidence deviation | `run_poshqc_analyze` ok flag; analyzer literal from the CI `poshqc` job on the fix head. |
| P2-T3 | CI-evidence deviation | Counts line and coverage headline from the CI `poshqc` job on the fix head. |
| P2-T4 | Operator-run blocker (wrapper literal); substance by deviation | Direct `actionlint .github/workflows/ci.yml` recorded as DEV-ACTIONLINT-DIRECT. Operator command: `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/ci.yml`. |
| P2-T7 | CI-evidence deviation | Sibling suites inside the CI full-repository Pester run on the fix head. |

## Named deviations introduced by this classification

- DEV-PWSH-ROUTE: plan "PowerShell route" (sh-wrapper) replaced by MCP tools and CI evidence per the operator rule.
- DEV-CI-BASELINE: Phase 0 Pester/analyze/format baselines read from CI main run 37645267440 (full-repository scope) instead of a local `tests/scripts/workflows` run. Arithmetic in P1-T5, P1-T9, P2-T3 (`BaselinePassed + n`) is applied to the full-repository counts.
- DEV-CI-FAILBEFORE: fail-before evidence (P1-T4, P1-T5) is a `workflow_dispatch` CI run on the pushed test-only commit.
- DEV-ACTIONLINT-DIRECT: AC-5 / P0-T19 / P2-T4 use the PATH `actionlint` binary directly; the wrapper literal `Running actionlint...` is not observed.
- DEV-NONPS-COPY: P1-T14/P1-T15 use `cp` and `sha256sum`/`cmp` instead of `Copy-Item`/`Get-FileHash`.
