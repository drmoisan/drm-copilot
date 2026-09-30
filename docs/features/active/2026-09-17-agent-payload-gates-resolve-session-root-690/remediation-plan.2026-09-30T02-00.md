# agent-payload-gates-resolve-session-root — Remediation Plan R1, pass 1 (Issue #690)

- **Issue:** #690
- **Owner:** drmoisan
- **Last Updated:** 2026-09-30T02-00
- **Status:** Draft (pending plan validator and executor preflight)
- **Version:** 1.0
- **Work Mode:** full-bug (acceptance-criteria source `spec.md`; remediation source `remediation-inputs.2026-09-30T01-45.md`)
- **Branch:** `bug/agent-payload-gates-resolve-session-root-690` (audit head `c47504ae`; audit artifacts committed at `c127db6d`)
- **Inputs:** `remediation-inputs.2026-09-30T01-45.md` (primary), `policy-audit.2026-09-30T01-45.md`, `code-review.2026-09-30T01-45.md`, `feature-audit.2026-09-30T01-45.md`, all in the feature folder.

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Scope (orchestrator decisions)

| ID | Source | Severity | Disposition in this plan |
| --- | --- | --- | --- |
| RF-1 | policy audit G-1 | Blocking | Phase 1. Produce `artifacts/python/lcov.info` with `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing` at the branch head (repository `addopts` writes the lcov file). Record repo-wide line and branch figures and the changed-file disposition. No test is written: the one changed Python file is test code outside the coverage measurement. The KL-510 node (#510) failure is recorded as pre-existing. |
| CR-1 | code review, RF-4 | Minor | Phase 2. Guard the `pr_number` conversion in `Resolve-WorktreeRunTargetByRecord` with `[long]::TryParse`; add test row B13. |
| CR-2 | code review, RF-4 | Minor | Phase 3. Replace the silent catch in `Get-WorktreeRunCheckpointText` with a catch that writes a stderr diagnostic and returns `$null` (fail-closed kept); add test row T4. |
| RF-3 | policy audit G-2, code review CR-3 | Non-blocking, in scope | Phase 4. Regenerate `artifacts/pester/powershell-coverage.xml` through the repository PoshQC module with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, after the code changes, and record the figures for `WorktreeRunResolution.psm1`, `enforce-epic-merge-gate-resolution.ps1`, and `enforce-epic-worktree-removal-gate-resolution.ps1`. |
| CR-4, CR-5 | code review Nits, RF-4 | Nit | Phase 5. Recorded as one follow-up potential entry; not fixed. |
| RF-2 / AC-44 | feature audit | Pending CI | Not a remediation item. AC-44 stays unchecked until the pull request's CI run is recorded. No task here touches it. |

Out of scope, unchanged from the inputs' "Do Not Do" list: `.codex/**`, `WorktreeResolution.psm1`, `enforce-orchestration-preimplementation-gate-helpers.ps1`, `validate-orchestrator-output.ps1`, `Find-EpicWaveBarrierFeatureFolderFromPrompt`, `.claude/state/**`, runsettings or coverage `exclude` entries, thresholds, and any production or test edit for RF-1.

### Current-tree facts this plan relies on (re-derived 2026-09-30 by reading the files)

- `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (WRR) is 493 lines. `Get-WorktreeRunCheckpointText` is lines 99-117; its read is line 116, `try { return [System.IO.File]::ReadAllText($Path) } catch { return $null }`; its synopsis is line 102. `Test-WorktreeRunCheckpointRecord` casts `([long] $Value)` at line 396. `Resolve-WorktreeRunTargetByRecord` is lines 403-444; its description sentence on non-digit values is line 411; `$isBlank` is line 431 and the digit-only guard is line 432 (`$Value.Trim() -notmatch '^\d+$'`).
- WRR is live: the converted hooks import it. Its bundle mirror is `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, and `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` asserts the pair's SHA-256 equality.
- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1` (T-REC) is 428 lines with 27 rows; B12 is the last row of `Describe 'Resolve-WorktreeRunTargetByRecord'` (lines 228-238); its purity allow-list of built-in cmdlets is line 92 (`Set-StrictMode`, `Import-Module`, `Join-Path`, `Test-Path`, `ConvertFrom-Json`, `Where-Object`, `Export-ModuleMember`), consumed by rows U2 and U3.
- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1` (T-SIG) is 162 lines with 16 rows; `Describe 'Get-WorktreeRunCheckpointText'` holds T1-T3 (lines 107-131). It imports WRR without `-Force` (line 19).
- `evidence/qa-gates/coverage-lib.2026-09-30T01-17.md` records `TotalCount=252` for the `tests/scripts/claude-lib/worktree-resolution` coverage run and WRR at `AnalyzedLines=146 CoveredLines=146 LinePercent=100`.
- `pyproject.toml` line 115: `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`. `/artifacts` is gitignored (`.gitignore` line 6), so neither coverage artifact is committed.
- `scripts/powershell/PoshQC/PoshQC.psd1` exports `Invoke-PoshQCTest` (line 19), whose `-SettingsPath` parameter selects the runsettings file (`PoshQC.Testing.psm1` line 156). The repository runsettings set `Run.Exit = $true` (line 4), `TestResult.OutputPath = 'artifacts/pester/pester-junit.xml'` (line 15), and `CodeCoverage.OutputPath = 'artifacts/pester/powershell-coverage.xml'` with `OutputFormat = 'CoverageGutters'` (lines 21-22), and list WRR and both new `-resolution.ps1` hooks in `CodeCoverage.Path`.

## Execution Conventions

- FEATURE means `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690`; RPLAN means `FEATURE/remediation-plan.2026-09-30T02-00.md` (this file); MPLAN means `FEATURE/plan.2026-09-29T22-17.md`.
- WRR, T-REC, T-SIG as above; WRRB means the WRR bundle mirror path above.
- TS is the task time in `yyyy-MM-ddTHH-mm`. SCRATCH is the session scratchpad outside the repository, recorded as the token SCRATCH. R_HEAD is the commit recorded by P0-T6.
- Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and `ExpectedExitCode:` when the expected exit code is not 0. Evidence goes under `FEATURE/evidence/remediation-baseline/` (baselines) and `FEATURE/evidence/qa-gates/` (results). No caller-supplied evidence path was non-canonical.
- Scratch scripts: A1 run-ps.sh, A2 pester-counts, A3 pester-coverage, A4 line-counts, A5 file-hashes, A6 ps-format-check, A7 pssa-count, A11 changed-line-coverage, A13 pair-hashes, and A15 stage-check are reproduced verbatim from MPLAN Appendix H; R1 through R4 are defined in Appendix A below. Every PowerShell script runs as `sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>` (CMD-PS-SCRIPT); no command text names pwsh, bash, or wsl.
- Live-file rule (MPLAN LH-2): WRR is changed only by a single complete Write of the whole file from a staged copy that passes A15 (`STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0`), followed in the same task by the mirror `cp` and a hash check, and in the next task by its Pester suite. No Edit tool call touches WRR.
- Stop rule: if a hook denies any call, stop and report the denial text verbatim. Do not modify `.claude/state/**` or `artifacts/orchestration/**`.
- CMD-GIT-ADD is `git add -- <named paths>`; CMD-GIT-COMMIT is `git commit -m "<message>" --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"`; CMD-GIT-PUSH is `git push origin bug/agent-payload-gates-resolve-session-root-690`. Every phase-ending CMD-GIT-ADD includes RPLAN and the FEATURE evidence directory.
- KL-510 has the meaning defined in MPLAN Execution Conventions (case (a) `KL-510: PASSED`, case (b) `KL-510: STATE-ONLY` with `ExpectedExitCode: 1`).
- Search literal register (quoted so each is an explicit instruction): "WORKTREE_RUN_CHECKPOINT_UNREADABLE", "TryParse", "B13 ", "T4 ", "#690".

### Observed outputs relied on

- A2, A3, A4, A5, A6, A7, A11, A13, and A15 print the lines documented in MPLAN "Observed success outputs", observed in that plan's executed runs (for example `evidence/qa-gates/coverage-lib.2026-09-30T01-17.md` line 12 `COVERAGE file=... LinePercent=100`).
- The PoshQC MCP tools return no test output; counts come from the scratch scripts.
- `pytest` with the repository `addopts` writes `artifacts/python/lcov.info`; `--cov-report=term-missing` also prints a terminal table. R1 reads totals from the lcov file.

---

### Phase 0 — Policy Reads and Remediation Baseline

- [x] [P0-T1] Read `CLAUDE.md` and `.github/copilot-instructions.md`. Acceptance: both read; recorded in P0-T4.
- [x] [P0-T2] Read, in order, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `.claude/rules/plan-acceptance-gates.md`, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`. Acceptance: all eight read; recorded in P0-T4.
- [x] [P0-T3] Read FEATURE/remediation-inputs.2026-09-30T01-45.md, FEATURE/policy-audit.2026-09-30T01-45.md, FEATURE/code-review.2026-09-30T01-45.md, FEATURE/feature-audit.2026-09-30T01-45.md, and FEATURE/spec.md. Acceptance: all five read; recorded in P0-T4.
- [x] [P0-T4] Write FEATURE/evidence/remediation-baseline/phase0-instructions-read.TS.md. Acceptance: contains `Timestamp:`, `Policy Order:`, and the 15 files of P0-T1 through P0-T3 in reading order.
- [x] [P0-T5] Create the scratch scripts (A1-A7, A11, A13, A15 verbatim from MPLAN Appendix H; R1-R4 verbatim from Appendix A below) under SCRATCH; smoke-test with A4 over `CLAUDE.md`. Write FEATURE/evidence/remediation-baseline/scratch-smoke.TS.md. Acceptance: exit 0, one line beginning `CLAUDE.md LineCount=`, and the artifact lists the 14 script names.
- [x] [P0-T6] Branch state. Commands: `git rev-parse --abbrev-ref HEAD`, `git rev-parse HEAD`, `git status --porcelain`. Write FEATURE/evidence/remediation-baseline/branch-state.TS.md. Acceptance: branch is `bug/agent-payload-gates-resolve-session-root-690`; the HEAD SHA is recorded as R_HEAD; the status prints nothing or only the untracked RPLAN line.
- [x] [P0-T7] WRR test-and-coverage baseline. Command: CMD-PS-SCRIPT with A3, `-TestPath tests/scripts/claude-lib/worktree-resolution -CoveragePath .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 -CoverageOutputPath SCRATCH/cov-wrr-r0.xml -ReportPath SCRATCH/cov-wrr-r0.txt`. Write FEATURE/evidence/remediation-baseline/coverage-wrr.TS.md. Acceptance: `FailedCount=0`; `TotalCount=` recorded as BASE_TOTAL (252 expected per `coverage-lib.2026-09-30T01-17.md`); the WRR `LinePercent=` recorded as BASE_WRR_PCT (100 expected).
- [x] [P0-T8] Line-count baseline. Command: A4 over WRR, T-REC, T-SIG. Write FEATURE/evidence/remediation-baseline/line-counts.TS.md. Acceptance: `LineCount=493` for WRR, `428` for T-REC, `162` for T-SIG.
- [x] [P0-T9] Format and analyzer baseline. Commands: A6 then A7 over WRR, T-REC, T-SIG. Write FEATURE/evidence/remediation-baseline/powershell-format-analyze.TS.md. Acceptance: `FORMAT-SUMMARY ChangedCount=0` and `PSSA-SUMMARY DiagnosticCount=0`.
- [x] [P0-T10] Mirror baseline. Command: A13 over WRR and WRRB. Write FEATURE/evidence/remediation-baseline/mirror-wrr.TS.md. Acceptance: `PAIR-SUMMARY pairs=1 unequal=0`.
- [x] [P0-T11] Commit and push Phase 0. Commands: CMD-GIT-ADD with RPLAN and `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence`; CMD-GIT-COMMIT with message "docs(690): add remediation plan R1 and baseline evidence"; CMD-GIT-PUSH. Acceptance: `git status --porcelain` prints nothing and the push exits 0.

### Phase 1 — RF-1: Python Coverage Artifact (Evidence Only)

- [x] [P1-T1] Run the repository Python suite with coverage at the branch head (R_HEAD plus the Phase 0 commit, which changes no Python file). Command: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing`. Write FEATURE/evidence/qa-gates/python-coverage-run.TS.md recording the summary line and every FAILED node verbatim. Acceptance: `artifacts/python/lcov.info` exists after the run; the only FAILED node is `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` and it satisfies KL-510 (case (b) artifact carries `KL-510: STATE-ONLY` and `ExpectedExitCode: 1`; case (a) carries `KL-510: PASSED` and exit 0). Any other FAILED node is recorded as a new finding and stops the plan. A FAILED node outside `tests/scripts/dev_tools`, which has no recorded baseline, halts the run fail-closed as a new finding to route to the orchestrator.
- [x] [P1-T2] Read the lcov totals and the changed-file disposition. Commands: `git log -1 --format=%cI HEAD`; CMD-PS-SCRIPT with R1, `-LcovPath artifacts/python/lcov.info -ChangedFile tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`. Write FEATURE/evidence/qa-gates/python-coverage.TS.md with `Command:`, `EXIT_CODE:`, the `LCOV-LINES`, `LCOV-BRANCHES`, `LCOV-MTIME-UTC`, and `CHANGED-FILE-IN-LCOV` lines, the P1-T1 failing-node list, and a `Disposition:` line. Acceptance: `LCOV-MTIME-UTC` is later than the HEAD commit time; `LinePercent=` and `BranchPercent=` are numeric; `CHANGED-FILE-IN-LCOV=False` is recorded with the statement "the changed Python file is test code outside the coverage measurement; no per-file threshold applies". `Disposition:` is `PASS` when `LinePercent` is at least 85 and `BranchPercent` at least 75; otherwise `PRE-EXISTING-BELOW-THRESHOLD`, with both figures recorded and the finding routed to the orchestrator as a separate pre-existing item (no test is written in this plan).
- [x] [P1-T3] Commit and push Phase 1. Commands: CMD-GIT-ADD with RPLAN and the FEATURE evidence directory; CMD-GIT-COMMIT with message "docs(690): record repository Python coverage evidence (RF-1)"; CMD-GIT-PUSH. Acceptance: `git status --porcelain` prints nothing and the push exits 0.

### Phase 2 — CR-1: Guard the Pull-Request Number Conversion

- [x] [P2-T1] Edit T-REC: insert row B13 (Appendix B, B13) immediately after row B12 inside `Describe 'Resolve-WorktreeRunTargetByRecord'`. Acceptance: `git grep -c -F -e "B13 " -- tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1` prints a count of 1.
- [x] [P2-T2] [expect-fail] Run T-REC against the unfixed WRR. Command: CMD-PS-SCRIPT with A2, `-Path tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1`. Write FEATURE/evidence/regression-testing/cr1-before-fix.TS.md with `ExpectedExitCode: 0`. Acceptance: `TotalCount=28`, `FailedCount=1`, and the single `FAILED:` line names B13.
- [x] [P2-T3] Stage WRR with the CR-1 change of Appendix B (B-CR1) to `SCRATCH/stage/WorktreeRunResolution.psm1` and check it. Command: A15 with `-Path SCRATCH/stage/WorktreeRunResolution.psm1`; A4 over the staged copy. Acceptance: `STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0`; `LineCount=495`.
- [x] [P2-T4] Write WRR from the staged copy in one complete Write, then copy the mirror and verify both. Commands: Write; `cp .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`; A5 over the staged copy and WRR; A13 over WRR and WRRB. Write FEATURE/evidence/qa-gates/cr1-write.TS.md. Acceptance: the Write succeeds without a hook denial; the staged and repository `Hash=` values are equal; `PAIR-SUMMARY pairs=1 unequal=0`.
- [x] [P2-T5] Run T-REC immediately after the write. Command: A2 with `-Path tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1`. Write FEATURE/evidence/regression-testing/cr1-after-fix.TS.md. Acceptance: `TotalCount=28`, `PassedCount=28`, `FailedCount=0`.
- [x] [P2-T6] Commit and push Phase 2. Commands: CMD-GIT-ADD with WRR, WRRB, T-REC, RPLAN, and the FEATURE evidence directory; CMD-GIT-COMMIT with message "fix(690): return NoTarget for an out-of-range pull request number (CR-1)"; CMD-GIT-PUSH. Acceptance: `git status --porcelain` prints nothing and the push exits 0.

### Phase 3 — CR-2: Record an Unreadable Checkpoint Instead of Swallowing It

- [x] [P3-T1] Edit T-SIG: insert row T4 (Appendix B, T4) immediately after row T3. Acceptance: `git grep -c -F -e "T4 " -- tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1` prints a count of 1.
- [x] [P3-T2] [expect-fail] Run T-SIG against WRR without the CR-2 change. Command: A2 with `-Path tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1`. Write FEATURE/evidence/regression-testing/cr2-before-fix.TS.md with `ExpectedExitCode: 0`. Acceptance: `TotalCount=17`, `FailedCount=1`, and the single `FAILED:` line names T4.
- [x] [P3-T3] Stage WRR with the CR-2 change of Appendix B (B-CR2) applied on top of the committed CR-1 state, and check it. Commands: A15 and A4 over `SCRATCH/stage/WorktreeRunResolution.psm1`. Acceptance: `STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0`; `LineCount=497`.
- [x] [P3-T4] Write WRR from the staged copy in one complete Write, then copy the mirror and verify both (commands as P2-T4). Write FEATURE/evidence/qa-gates/cr2-write.TS.md. Acceptance: as P2-T4.
- [x] [P3-T5] Run T-SIG and T-REC immediately after the write. Command: A2 with `-Path tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1,tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1`. Write FEATURE/evidence/regression-testing/cr2-after-fix.TS.md. Acceptance: `TotalCount=45`, `PassedCount=45`, `FailedCount=0`.
- [x] [P3-T6] Commit and push Phase 3. Commands: CMD-GIT-ADD with WRR, WRRB, T-SIG, RPLAN, and the FEATURE evidence directory; CMD-GIT-COMMIT with message "fix(690): report an unreadable run checkpoint on stderr (CR-2)"; CMD-GIT-PUSH. Acceptance: `git status --porcelain` prints nothing and the push exits 0.

### Phase 4 — RF-3: Canonical PowerShell Coverage Artifact from the Repository Runsettings

- [ ] [P4-T1] Regenerate the canonical artifact through the repository PoshQC module (not the MCP runner, which reads the installed extension's runsettings). Command: CMD-PS-SCRIPT with R2 (no arguments). Run R2 as a background command (`run_in_background`) and wait for its completion notification; record the exit code from the completed run. Write FEATURE/evidence/qa-gates/powershell-coverage-artifact-run.TS.md recording the exit code. Acceptance: the run completes; `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` exist. The runsettings set `Run.Exit = $true`, so the exit code equals the Pester failed-test count; the artifact records `ExpectedExitCode:` equal to the P4-T2 `FailedCount` value.
- [ ] [P4-T2] Read the regenerated artifacts. Commands: CMD-PS-SCRIPT with R3, `-CoverageXml artifacts/pester/powershell-coverage.xml -FileName WorktreeRunResolution.psm1,enforce-epic-merge-gate-resolution.ps1,enforce-epic-worktree-removal-gate-resolution.ps1`; CMD-PS-SCRIPT with R4, `-JUnitXml artifacts/pester/pester-junit.xml`. Write FEATURE/evidence/qa-gates/powershell-coverage-artifact.TS.md. Acceptance: `COVERAGE-XML-MTIME-UTC` is later than the P3-T6 commit time; three `XML-COVERAGE file=` lines, none `MISSING`, each with `LinePercent=` of at least 85; the `JUNIT TotalCount=` and `FailedCount=` values and every `JUNIT-FAILED:` name are recorded. Each `JUNIT-FAILED:` test that lives under `tests/scripts/claude-hooks`, `tests/scripts/claude-lib`, `tests/scripts/claude-runtime`, or `tests/scripts/codex-hooks` must appear in the matching baseline artifact `FEATURE/evidence/baseline/pester-<folder>.2026-09-29T23-11.md`; any other failure there stops the plan as a new finding. Failures in other folders are recorded as outside this feature's changed surface.
- [ ] [P4-T3] Commit and push Phase 4. Commands: CMD-GIT-ADD with RPLAN and the FEATURE evidence directory; CMD-GIT-COMMIT with message "docs(690): record the canonical PowerShell coverage artifact (RF-3)"; CMD-GIT-PUSH. Acceptance: `git status --porcelain` prints nothing and the push exits 0.

### Phase 5 — PowerShell Toolchain Loop, Coverage Comparison, and Follow-Up Entry

If P5-T1 through P5-T5 fails or changes a tracked file, fix the cause (a live-file fix follows the live-file rule) and restart from P5-T1.

- [ ] [P5-T1] Format. Commands: A5 over WRR, T-REC, T-SIG (before); MCP-PS-FORMAT (`mcp__drm-copilot__run_poshqc_format`, workspace_root the worktree root, scan_folders `.claude/lib/worktree-resolution` and `tests/scripts/claude-lib/worktree-resolution`); A5 over the same files (after); `git status --porcelain`; A6 over the three files. Write FEATURE/evidence/qa-gates/remediation-format.TS.md. Acceptance: the MCP call returns without raising; before and after hashes are equal; the status names no path outside the FEATURE evidence directory and RPLAN; `FORMAT-SUMMARY ChangedCount=0`.
- [ ] [P5-T2] Analyze. Commands: MCP-PS-ANALYZE (`mcp__drm-copilot__run_poshqc_analyze`, same arguments); A7 over WRR, T-REC, T-SIG. Write FEATURE/evidence/qa-gates/remediation-analyze.TS.md. Acceptance: the MCP call returns and `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P5-T3] Test with coverage for WRR. Command: A3 with `-TestPath tests/scripts/claude-lib/worktree-resolution -CoveragePath .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 -CoverageOutputPath SCRATCH/cov-wrr-r1.xml -ReportPath SCRATCH/cov-wrr-r1.txt`. Write FEATURE/evidence/qa-gates/remediation-coverage-wrr.TS.md. Acceptance: `FailedCount=0`; `TotalCount=` equals BASE_TOTAL plus 2; the WRR `LinePercent=` is at least BASE_WRR_PCT.
- [ ] [P5-T4] Changed-line coverage for WRR against R_HEAD. Command: A11 with `-CoverageReportPath SCRATCH/cov-wrr-r1.txt -BaseRef R_HEAD -File .claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (R_HEAD replaced by the recorded commit). Write FEATURE/evidence/qa-gates/remediation-changed-line-coverage.TS.md. Acceptance: one `CHANGED-COVERAGE` line, not `MISSING`, with `ChangedPercent=` of at least 85.
- [ ] [P5-T5] Size, mirror, and manifest checks. Commands: A4 over WRR, T-REC, T-SIG; A13 over WRR and WRRB; A2 with `-Path tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`. Write FEATURE/evidence/qa-gates/remediation-size-mirror.TS.md. Acceptance: `LineCount=497` for WRR, `LineCount=` at most 500 for T-REC and T-SIG; `PAIR-SUMMARY pairs=1 unequal=0`; the manifest suite reports `FailedCount=0`.
- [ ] [P5-T6] Python parity for the bundle. Command: `poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py`. Write FEATURE/evidence/qa-gates/remediation-python-parity.TS.md. Acceptance: every node other than the KL-510 node is PASSED and that node satisfies KL-510.
- [ ] [P5-T7] Coverage comparison. Write FEATURE/evidence/qa-gates/remediation-coverage-comparison.TS.md from P0-T7, P5-T3, P5-T4, P1-T2, and P4-T2. Acceptance: the artifact carries `Baseline Coverage:` (BASE_WRR_PCT), `Post-Change Coverage:` (the P5-T3 WRR value and the three P4-T2 values), `New/Changed-code Coverage:` (the P5-T4 value), the Python line and branch figures from P1-T2, and `Disposition:`, which is `PASS` only when WRR is at least BASE_WRR_PCT, the changed-line value is at least 85, the three P4-T2 values are each at least 85, and the P1-T2 disposition is `PASS`; otherwise `BLOCKED` (or `PASS-WITH-PRE-EXISTING-PYTHON-FINDING` when the only shortfall is a P1-T2 `PRE-EXISTING-BELOW-THRESHOLD`).
- [ ] [P5-T8] Write the follow-up potential entry `docs/features/potential/2026-09-30-worktree-run-resolution-review-nits.md` per Appendix C. Acceptance: the Write succeeds without a hook denial; content is verified by P6-T1.
- [ ] [P5-T9] Commit and push Phase 5. Commands: `git status --porcelain`; CMD-GIT-ADD with `docs/features/potential/2026-09-30-worktree-run-resolution-review-nits.md`, every Phase 5 restart fix the status listed (including WRRB when WRR changed), RPLAN, and the FEATURE evidence directory; CMD-GIT-COMMIT with message "docs(690): record remediation QA loop and review-nit follow-up"; CMD-GIT-PUSH. Acceptance: `git status --porcelain` prints nothing after the commit and the push exits 0.

### Phase 6 — Final Commit, Push, and Clean-Tree Check

- [ ] [P6-T1] Verify the follow-up entry and push. Commands: `git grep -c -F -e "#690" -- docs/features/potential/2026-09-30-worktree-run-resolution-review-nits.md`; `git status --porcelain`; only when that status is non-empty, CMD-GIT-ADD with RPLAN, the FEATURE evidence directory, and every path the status listed, then CMD-GIT-COMMIT with message "docs(690): record remediation R1 check-off state"; CMD-GIT-PUSH. Acceptance: the count prints a count of at least 1; the push exits 0.
- [ ] [P6-T2] Clean-tree check. Commands: `git status --porcelain`; `git rev-parse HEAD`; `git rev-parse origin/bug/agent-payload-gates-resolve-session-root-690`. Write nothing (the result is reported to the orchestrator, because writing an artifact would dirty the tree). Acceptance: the status prints nothing and the two SHAs are equal.

---

## Remediation Traceability

| ID | Implementation tasks | Verifying tasks | Evidence |
| --- | --- | --- | --- |
| RF-1 | (evidence only) | P1-T1, P1-T2, P5-T7 | qa-gates/python-coverage |
| CR-1 | P2-T3, P2-T4 | P2-T2 (fail-before), P2-T5, P5-T3, P5-T4 | regression-testing/cr1-after-fix |
| CR-2 | P3-T3, P3-T4 | P3-T2 (fail-before), P3-T5, P5-T3, P5-T4 | regression-testing/cr2-after-fix |
| RF-3 | (evidence only) | P4-T1, P4-T2, P5-T7 | qa-gates/powershell-coverage-artifact |
| CR-4, CR-5 | P5-T8 | P6-T1 | docs/features/potential/2026-09-30-worktree-run-resolution-review-nits.md |

## Appendix A — Remediation Scratch Scripts (written verbatim under SCRATCH by P0-T5; read-only except where R2 regenerates artifacts under `artifacts/`)

R1 lcov-totals.ps1:

```powershell
param([Parameter(Mandatory)][string] $LcovPath, [Parameter(Mandatory)][string] $ChangedFile)
$ErrorActionPreference = 'Stop'
$lf = 0; $lh = 0; $brf = 0; $brh = 0; $changedPresent = $false
foreach ($line in [System.IO.File]::ReadLines((Resolve-Path -LiteralPath $LcovPath).Path)) {
    if ($line.StartsWith('SF:')) { if (($line.Substring(3) -replace '\\', '/').EndsWith($ChangedFile)) { $changedPresent = $true } }
    elseif ($line.StartsWith('LF:')) { $lf += [int] $line.Substring(3) }
    elseif ($line.StartsWith('LH:')) { $lh += [int] $line.Substring(3) }
    elseif ($line.StartsWith('BRF:')) { $brf += [int] $line.Substring(4) }
    elseif ($line.StartsWith('BRH:')) { $brh += [int] $line.Substring(4) }
}
$linePercent = if ($lf -eq 0) { 'NA' } else { [math]::Round(100 * $lh / $lf, 2) }
$branchPercent = if ($brf -eq 0) { 'NA' } else { [math]::Round(100 * $brh / $brf, 2) }
Write-Output "LCOV-MTIME-UTC=$((Get-Item -LiteralPath $LcovPath).LastWriteTimeUtc.ToString('yyyy-MM-ddTHH:mm:ssZ'))"
Write-Output "LCOV-LINES LF=$lf LH=$lh LinePercent=$linePercent"
Write-Output "LCOV-BRANCHES BRF=$brf BRH=$brh BranchPercent=$branchPercent"
Write-Output "CHANGED-FILE-IN-LCOV=$changedPresent"
```

R2 poshqc-repo-test.ps1 (regenerates `artifacts/pester/*` through the repository module and runsettings):

```powershell
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
Import-Module (Join-Path $root 'scripts/powershell/PoshQC/PoshQC.psd1') -Force
Invoke-PoshQCTest -Root $root -SettingsPath (Join-Path $root 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1')
```

R3 coverage-xml-files.ps1:

```powershell
param([Parameter(Mandatory)][string] $CoverageXml, [Parameter(Mandatory)][string[]] $FileName)
$ErrorActionPreference = 'Stop'
$FileName = @($FileName | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
[xml] $document = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $CoverageXml).Path)
Write-Output "COVERAGE-XML-MTIME-UTC=$((Get-Item -LiteralPath $CoverageXml).LastWriteTimeUtc.ToString('yyyy-MM-ddTHH:mm:ssZ'))"
foreach ($name in $FileName) {
    $nodes = @($document.SelectNodes("//sourcefile[@name='$name']"))
    if ($nodes.Count -eq 0) { Write-Output "XML-COVERAGE file=$name MISSING"; continue }
    $counter = $nodes[0].SelectSingleNode("counter[@type='LINE']")
    $covered = [int] $counter.covered
    $missed = [int] $counter.missed
    $percent = if (($covered + $missed) -eq 0) { 'NA' } else { [math]::Round(100 * $covered / ($covered + $missed), 2) }
    Write-Output "XML-COVERAGE file=$name Covered=$covered Missed=$missed LinePercent=$percent"
}
```

R4 junit-summary.ps1:

```powershell
param([Parameter(Mandatory)][string] $JUnitXml)
$ErrorActionPreference = 'Stop'
[xml] $document = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $JUnitXml).Path)
$cases = @($document.SelectNodes('//testcase'))
$failed = @($cases | Where-Object { $_.SelectSingleNode('failure') -or $_.SelectSingleNode('error') })
Write-Output "JUNIT TotalCount=$($cases.Count) FailedCount=$($failed.Count)"
foreach ($case in $failed) { Write-Output "JUNIT-FAILED: $($case.classname) :: $($case.name)" }
```

## Appendix B — Code and Test Changes

**B-CR1 (WRR, `Resolve-WorktreeRunTargetByRecord`).** Replace line 432's guard with a parse-based guard, adding two lines after line 431:

```powershell
    $parsedNumber = [long] 0
    $isNumber = -not $isBlank -and $Value.Trim() -match '^\d+$' -and [long]::TryParse($Value.Trim(), [ref] $parsedNumber)
    if ($isBlank -or ($RecordField -eq 'pr_number' -and -not $isNumber)) {
```

and change the description sentence on line 411 to "A blank value, or a pr_number that is not all digits or does not fit a 64-bit integer, is NoTarget." No other line changes; the `[long] $Value` cast at line 396 is now reached only with a parsed value. Resulting length: 495 lines.

**B-CR2 (WRR, `Get-WorktreeRunCheckpointText`).** Replace line 116 with these three lines:

```powershell
    # An unreadable file is reported on stderr and treated as absent, so resolution stays fail-closed and the hook's stdout stays JSON-only.
    try { return [System.IO.File]::ReadAllText($Path) }
    catch { [Console]::Error.WriteLine(("WORKTREE_RUN_CHECKPOINT_UNREADABLE: '{0}': {1}" -f $Path, $_.Exception.Message)); return $null }
```

and change the synopsis on line 102 to "Return the raw text of a file, or $null when it is absent or unreadable; an unreadable file also writes a diagnostic to stderr." The catch still returns `$null` for every exception type, so a failure can never select a worktree and no exception escapes to a hook entry point (which would exit non-zero and fail open); the stderr diagnostic makes the failure visible without writing to the hook's stdout, which carries only the decision JSON (`Write-Warning` is not used, because under `pwsh -File` it writes to stdout ahead of that JSON). Resulting length: 497 lines.

**B13 (T-REC, after B12).**

```powershell
    It 'B13 resolves NoTarget for a pull request value too large for a 64-bit integer without enumerating live roots' {
        # Arrange: a recorded checkpoint would make an unguarded conversion throw.
        Set-RecordTopology -Live @('/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = '{"route_id":"epic","features":[{"pr_number":812}]}' }

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind epic -RecordField pr_number -Value '12345678901234567890' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
        $target.ReasonCode | Should -Be $script:NoTargetCode
        Should -Invoke Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -Times 0 -Exactly
    }
```

**T4 (T-SIG, after T3).**

```powershell
    It 'T4 returns null and writes a diagnostic to stderr when the file cannot be read' {
        # Arrange: a directory passes the mocked leaf test and makes ReadAllText throw; no file is created.
        Mock -CommandName Test-Path -ModuleName WorktreeRunResolution -MockWith { $true }

        # Act: capture the process error stream in memory and restore it afterwards.
        $captured = [System.IO.StringWriter]::new(); $original = [Console]::Error; [Console]::SetError($captured); try { $text = Get-WorktreeRunCheckpointText -Path $PSScriptRoot } finally { [Console]::SetError($original) }

        # Assert
        $text | Should -BeNullOrEmpty
        $captured.ToString() | Should -Match 'WORKTREE_RUN_CHECKPOINT_UNREADABLE'
    }
```

Row names are unique within each suite when compared case-insensitively. Neither row creates, writes, or deletes a file or uses `TestDrive:`.

## Appendix C — Follow-Up Potential Entry

`docs/features/potential/2026-09-30-worktree-run-resolution-review-nits.md`, in the layout of `docs/features/potential/2026-09-29-csharp-budget-text-per-batch-cap.md` (title with "(Potential Bug)", Date captured 2026-09-30, Author, `Status: Draft`, `Related: #690`, Summary, Scope, `## Acceptance Criteria (early draft)`, Constraints & Risks, Next Step). Summary: the #690 code review (`code-review.2026-09-30T01-45.md`) recorded two Nits left unfixed by remediation R1. CR-4: `Test-WorktreeRunPathEqual` in `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` compares case-insensitively only when a side starts with a drive letter, so a UNC root recorded with different casing compares case-sensitively. CR-5: the final deny of `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` repeats the `PARALLEL_WORKTREE_REMOVAL_BLOCKED:` token when both run kinds resolve `NoTarget`. Early criteria: a UNC row in the record suite and a documented or corrected comparison; a single leading token in that deny text, with the existing exact-text rows updated; bundle mirrors kept byte-identical and each file at or below 500 lines.
