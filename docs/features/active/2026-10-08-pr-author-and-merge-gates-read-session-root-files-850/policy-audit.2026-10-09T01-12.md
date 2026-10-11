# Policy Audit: pr-author and merge gates read session-root files (#850, bundled #788, #789, #851)

- Timestamp: 2026-10-09T01-12
- Reviewer: feature-review agent
- Branch: `bug/pr-author-and-merge-gates-read-session-root-files-exec-850` (local checkout `...-resume-850`)
- Head: `e2f42811`
- Base (epic mode): `origin/epic/enforcement-hook-precision-integration` at merge base `497cb504`
- Diff reviewed: `git diff origin/epic/enforcement-hook-precision-integration...HEAD` (167 files; 48 non-evidence files, 119 evidence files)
- Work mode: `full-bug` (AC source `spec.md`)
- Blocking findings in this artifact: 0

## Executive Summary

The branch moves the pr-author gate's artifact reads and the merge gate's per-feature checkpoint read from the session root to the resolved item worktree (#850), binds an explicit `gh pr merge <N>` to a checkpoint that records N (#788), makes UNC path comparison case-insensitive and removes a doubled deny token (#789), and adds deny diagnostics to the epic worktree-removal gate (#851). Only PowerShell production code changed. Every changed production and test PowerShell file is within the 500-line cap, every changed `.claude` file is byte-identical to its bundled mirror, no enforcement hook invokes Python, no changed suite uses a temporary-file API, and line coverage for every changed production file is at or above 85% (lowest 90.00%). Independent Pester runs by this reviewer passed 701 of 701 tests across the new and edited suites. Two pre-existing, environment- or base-specific failure sets exist outside the changed files and are classified Non-blocking.

Overall verdict: PASS (0 Blocking, 6 Non-blocking).

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller statement "Codex merge and removal gates are out of scope" restates the spec's Out-of-scope section and does not remove any changed file from review: the branch diff contains no `.codex/` file and no `codex-and-agents-customizations` mirror file. The statement "Policy files must not be edited" is a constraint, not a narrowing. The audit covered the full branch diff against the resolved base.

## Evidence Location Compliance

- Branch diff scan for files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`: zero files. All 119 evidence files are under `docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/evidence/{baseline,other,qa-gates,regression-testing}/`.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`: exit 0, no violations reported.
- Verdict: PASS.

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence and isolation | PASS | New suites mock every read seam (`Resolve-PrAuthorWorktreeTarget`, the four artifact seams, `Get-WorktreeItemCheckpointText`, `Get-WorktreeItemLiveRoot`, `Get-ChildOrchestratorCheckpointContent`). The C10 change adds `Mock Get-PrAuthorCheckpointContent { $null }` to `Context 'allowed commands'` of `enforce-pr-author-skill.Tests.ps1`, removing a dependency on a gitignored local epic checkpoint. |
| Determinism (no wall clock, no network, no process) | PASS | Fixed `[DateTime]::Parse(...)` values; no `Start-Process`, no network calls in the added rows. |
| No temporary files | PASS | `session-root-reads-850.Constraints.Tests.ps1` row "uses no temporary files and no host paths" passed in this reviewer's run; grep of every changed suite for `TestDrive`, `GetTempPath`, `New-TemporaryFile`, `$env:TEMP` returned no hit outside the constraint suite's own concatenated tokens. The removed `$script:CaptureRoot` (built from `GetPathRoot($PSScriptRoot)`) eliminated a host-derived path. |
| Arrange-Act-Assert structure | PASS | New rows carry explicit `# Arrange`, `# Act`, `# Assert` comments. |
| Test location mirrors source | PASS | Tests are under `tests/scripts/claude-hooks/` and `tests/scripts/claude-lib/worktree-resolution/`; fixtures under `tests/fixtures/worktree-resolution/`. No test file is colocated with production code. |
| Scenario completeness | PASS | Positive (allow), negative (deny), boundary (zero/negative PR number, non-integer standalone `pr_number`, empty/unparseable checkpoint, case-differing drive/UNC/POSIX paths), and error-path (import-failure deny) rows are present. |
| Coverage exclusion policy | PASS | `config/poshqc-coverage.json` lists roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts` and has no `exclude` entry; the branch adds no exclusion. |

### 1.1 Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A (no TypeScript file changed on the branch)
- TypeScript post-change coverage artifact: N/A (no TypeScript file changed on the branch)
- PowerShell baseline coverage artifact: `evidence/baseline/coverage-pra.2026-10-08T23-49.md`, `coverage-mrg.2026-10-08T23-49.md`, `coverage-erem.2026-10-08T23-49.md`, `coverage-prem.2026-10-08T23-49.md`, `coverage-lib.2026-10-08T23-50.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (canonical, repo-wide 96.48%) and `evidence/qa-gates/coverage-{pra,mrg,erem,prem,lib}.2026-10-09T00-5x.md`, `evidence/qa-gates/changed-line-coverage.2026-10-09T00-55.md`
- Per-language comparison summary: PowerShell only; every changed production file at or above 85% line coverage before and after; changed-line coverage 89.29% or higher per file; see section 1.2.1.

### 1.2 Coverage Metrics Table

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 10 production, 19 test | 701 run by reviewer (new and edited suites) | 701 passed, 0 failed | 88.89% lowest changed file (MRGR) | 90.00% lowest changed file (MRGR); 96.48% repo-wide | 89.29% lowest changed-line (MRGR); 96.55% new file PRAR |
| TypeScript | 0 | N/A | N/A | N/A | N/A | N/A |
| Python | 0 | N/A | N/A | N/A | N/A | N/A |
| C# | 0 | N/A | N/A | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 88.89% lowest changed file (MRGR), range 88.89%-100%; Post-change: 90.00% lowest changed file (MRGR), range 90.00%-100%, repo-wide 96.48% from `artifacts/pester/powershell-coverage.xml`; Change: MRGR +1.11, PRAR new file 96.55%, PRA 92.00 to 91.84 and PRAH 97.39 to 97.30 from a smaller analyzed-line denominator with 100% of their changed lines covered; New/changed-code coverage: 89.29% lowest (MRGR), 100% for PRA, PRAH, MRG, EREM, PREM, WRR; Disposition: PASS; Evidence: `evidence/qa-gates/coverage-comparison.2026-10-09T01-02.md`, `evidence/qa-gates/changed-line-coverage.2026-10-09T00-55.md`, reviewer parse of `artifacts/pester/powershell-coverage.xml`.

### 1.2.2 Per-File Line Coverage (PowerShell)

| File | Status | Baseline | Post-change | Changed lines | Verdict |
|---|---|---|---|---|---|
| `.claude/hooks/enforce-pr-author-skill.ps1` (PRA) | modified | 92.00% | 91.84% | 100% | PASS |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (PRAH) | modified | 97.39% | 97.30% | 100% | PASS |
| `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` (PRAR) | new | none | 96.55% | 96.55% | PASS |
| `.claude/hooks/enforce-epic-merge-gate.ps1` (MRG) | modified | 96.00% | 96.15% | 100% | PASS |
| `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` (MRGR) | modified | 88.89% | 90.00% | 89.29% | PASS |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` (EREM) | modified | 94.59% | 94.64% | 100% | PASS |
| `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` (EREMR) | modified | 95.65% | 96.49% | 97.06% | PASS |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (PREM) | modified | 92.66% | 92.66% | 100% | PASS |
| `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (WRR) | modified | 100% | 100% | 100% | PASS |
| `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` (WIR) | modified | 96.23% | 96.32% | 96.67% | PASS |

Reviewer cross-check against the canonical artifact `artifacts/pester/powershell-coverage.xml` (written 2026-10-09 00:49): MRGR 90.00%, MRG 96.15%, EREMR 96.49%, EREM 96.43%, PREM 94.50%, PRAH 97.30%, PRA 91.84%, WIR 98.53%, WRR 100.00%, repo-wide 96.48%. PRAR is not present in that artifact (see Gap G-3); its figure comes from the targeted Pester coverage run in `evidence/qa-gates/coverage-pra.2026-10-09T00-53.md` (`AnalyzedLines=58 CoveredLines=56 LinePercent=96.55`).

Threshold applied: the uniform rule in `.claude/rules/quality-tiers.md` (line >= 85%, no regression on changed lines; PowerShell has no branch threshold). The agent definition's step-3 figures (90% new, 80% modified/repo-wide) conflict with the authoritative rule; every file also satisfies the stricter 90% figure for the one new file (96.55%).

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| 500-line cap (production and test) | PASS | `wc -l` maxima: `WorktreeRunResolution.psm1` 497, `enforce-epic-worktree-removal-gate.Tests.ps1` 498, `WorktreeItemResolution.psm1` 484, `enforce-epic-merge-gate.ps1` 469, `enforce-parallel-worktree-removal-gate.ps1` 463. The constraint row "keeps every changed file within the line cap" passed. `WorktreeRunResolution.psm1` received only the in-place CR-4 change (zero net lines). |
| Separation of concerns / I/O isolation | PASS | New resolution logic is pure over seams; `WorktreeItemResolution.psm1`'s only filesystem read remains `Get-WorktreeItemCheckpointText`; the diagnostics builder reads no file. |
| Fail fast / fail closed | PASS | Unresolved or ambiguous targets deny; a second guarded import records `WorktreeItemResolution.psm1` failure as a deny. |
| Reuse over duplication | PASS (Non-blocking note) | Reason codes come only from accessor functions. The positive-JSON-integer rule is restated inline in `WorktreeItemResolution.psm1` rather than shared with `Test-StandalonePositiveJsonInteger` (code-review CR-03). |
| No policy document edits | PASS | No file under `.claude/rules/` or `.github/instructions/` changed. Plan decision D4 dropped the spec's one-sentence `.claude/rules/orchestrator-state.md` alignment for this reason (Gap G-4). |
| No absolute host paths in artifacts | PASS | Commit `e2f42811` removed host paths from the blocked snapshot; the constraint row scans created files for `X:\Users\`, `X:/Users/`, `/home/`. |

## 3. Language-Specific Code Change Policy Compliance

PowerShell (`.claude/rules/powershell.md`, `.github/instructions/powershell-code-change.instructions.md`):

| Requirement | Verdict | Evidence |
|---|---|---|
| Formatting (Invoke-Formatter, repo settings) | PASS | Reviewer run of `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over 10 production files and 5 new suites: no formatting difference. Executor evidence `evidence/qa-gates/powershell-format.2026-10-09T00-43.md`. |
| PSScriptAnalyzer (Error/Warning/Information) | PASS | Reviewer run: `PSSA-TOTAL=0` over the same 15 files. Executor evidence `evidence/qa-gates/powershell-analyze.2026-10-09T00-44.md` (`DiagnosticCount=0` over 28 files). |
| Rule suppressions only when strictly necessary and localized with a comment | PASS (Non-blocking note) | One new `SuppressMessageAttribute('PSUseSingularNouns')` on private `Get-EpicWorktreeGateDenyDiagnostics` with a `Justification`. It is localized and justified, but the spec does not fix the function name, so a singular name would have avoided it (code-review CR-02). |
| Comment-based help on functions | PASS | All new functions carry `.SYNOPSIS`/`.PARAMETER`/`.OUTPUTS`; the private `Test-WorktreeItemCheckpointRecordsPr` carries a leading comment in the module's private-function style. |
| Strict mode in modules | PASS | `WorktreeItemResolution.psm1` keeps `Set-StrictMode -Version Latest`; the Phase 5 corrective rewrite collects property names per property so an empty JSON object does not throw under strict mode (deviation 3, reviewed in code-review). |

Enforcement-hook-specific constraints:

| Requirement | Verdict | Evidence |
|---|---|---|
| No Python in enforcement hooks | PASS | `grep -i "python\|poetry\|\.py\b"` over all changed hooks: no match. `enforcement-hooks-no-python-invocation.Tests.ps1` passed in the reviewer run. |
| Bundled mirrors byte-identical | PASS | `cmp` of each of the 11 changed `.claude` files against `extensions/drm-copilot/resources/claude-customizations/<path>`: all identical. Python parity tests (`test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_resource_contracts.py`): 25 passed. |
| New dot-sourced sibling registered in `core.json` | PASS | `pack-manifests/core.json` line 50 lists `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1`. |
| Codex copies updated where hooks changed | PASS (not applicable by design) | No `.codex/hooks` file shares code with the changed Claude hooks: `.codex/hooks/enforce-epic-merge-gate.ps1` and `enforce-epic-worktree-removal-gate.ps1` are independent implementations (spec Out of scope), no Codex pr-author gate exists, and the only `.codex` reference to `enforce-pr-author-skill.ps1` is a comment. The Codex parity test passed. |

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Pester 5 with `#Requires` headers | PASS | New suites declare `#Requires -Version 7.0` and `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`. |
| Module-scoped mocks for library seams | PASS | `Mock ... -ModuleName WorktreeItemResolution` used; row "observes module-scoped WorktreeItemResolution mocks" proves import order. |
| Synthetic roots and committed read-only fixtures | PASS | `/synthetic-worktrees/<name>` roots; new committed fixture files under `tests/fixtures/worktree-resolution/pr-author/item-own-epic-mode/artifacts/` (tracked; confirmed with `git ls-files`). |
| Epic-state isolation guard | PASS | `enforce-gate-suites.EpicStateIsolation.Tests.ps1` lists the new `ItemArtifactRoot` suite and passed. |

## 5. Test Coverage Detail

See sections 1.2 to 1.2.2. Uncovered changed lines (from the executor's missed-command listings, verified in the evidence files):

- MRGR line 43, 49-50: import-failure assignments (the import-failure row sets the variable directly rather than failing a real import).
- MRGR line 222: `Test-ChildCheckpointPrGateBinding` returns `$false` when `pr_gate.pr_number` is present but not parseable as an integer. No row drives it (code-review CR-01).
- MRGR line 266: `Get-EpicMergeGateUnresolvedReason` early `$null` when any target is resolved.
- PRAR line 49 (`Test-PrAuthorBodyPathEqual` null normalization) and line 82 (`Get-PrAuthorEpicArtifactRoot` empty root).

## 6. Test Execution Metrics

Reviewer-run (this audit, 2026-10-09, direct `Invoke-Pester` through a scratch wrapper):

- New and CR suites (8 files: ItemArtifactRoot, merge ItemResolution, WIR PrNumber, EREM Diagnostics, Constraints, WRR Record, PREM WorktreeResolution, PREM Tests): TotalCount=140, Passed=140, Failed=0.
- Existing edited and guard suites (23 files including OrchestratorState.Tests.ps1, CleanupWorktreeManifestGateMatrix, WorktreeResolution.Manifest, enforcement-hooks-no-python-invocation): TotalCount=561, Passed=561, Failed=0.
- Python parity: 25 passed.

Executor evidence (final QA):

- `tests/scripts/claude-hooks`: 3094 total, 0 failed (`evidence/qa-gates/pester-claude-hooks.2026-10-09T00-55.md`).
- `tests/scripts/claude-lib`: 2341 total, 38 failed, all in `OrchestratorStateIssueAdoption.Tests.ps1`, identical to the Phase 0 baseline set (Gap G-2).
- `tests/scripts/claude-runtime`: 83 total, 0 failed.
- `tests/scripts/codex-hooks`: 1428 total, 1 failed, identical to the Phase 0 baseline (Gap G-1).
- MCP PoshQC test (P8-T3): returned `ok: false`; JUnit attribution 7653 tests, 1 failure, the same Codex wave-barrier row (Gap G-1).

## 7. Code Quality Checks

- Format: PASS (section 3).
- Lint: PASS, 0 diagnostics (section 3).
- Type checking: not applicable to PowerShell per the toolchain loop.
- Architecture boundaries: PASS. `WorktreeRunResolution.psm1` export set unchanged (row X1); `WorktreeItemResolution.psm1` export set is prior set plus `Resolve-WorktreeItemTargetByPrNumber` (row "exports the item-by-PR resolver").
- Contract checks: PASS. Mirror and manifest parity tests passed.

## 8. Gaps and Exceptions

| ID | Severity | Description | Disposition |
|---|---|---|---|
| G-1 | Non-blocking | P8-T3 left unchecked: the MCP PoshQC test returned exit 1 because `codex-pretooluse-integration.Tests.ps1` row "allows every registered handler for every tool name its own matcher admits" is denied by `enforce-epic-wave-barrier.ps1` reading the executing worktree's gitignored epic-mode checkpoint. The same single row is the Phase 0 baseline failure (`evidence/baseline/pester-codex-hooks.2026-10-08T23-45.md`), no file it touches is in the branch diff, and CI has no local checkpoint. | Pre-existing and environment-specific; not caused by this change. Not blocking. Recommend a follow-up to isolate that Codex test from local checkpoints, as C10 did for the pr-author row. |
| G-2 | Non-blocking | 38 failures in `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1` (`Get-OrchestratorStateIssueAdoptionResult` is not recognized). Reproduced by this reviewer. Identical to the Phase 0 baseline; the suite and its module are not in the branch diff. | Pre-existing on the epic base. Not blocking for this change. Recommend the epic orchestrator confirm whether CI reports it on the integration branch and file a follow-up. |
| G-3 | Non-blocking | The canonical artifact `artifacts/pester/powershell-coverage.xml` has no entry for the new file `enforce-pr-author-skill.artifact-root.ps1` (127 source files listed). The repo config `config/poshqc-coverage.json` includes `.claude/hooks` and has no exclusion, so this is a runner-input limitation, not a production coverage exclusion. The file is measured at 96.55% by the targeted run. | Not blocking. Recommend regenerating the canonical artifact with the self-hosted PoshQC module so the new file appears in it. |
| G-4 | Non-blocking | Spec In-scope item "`.claude/rules/orchestrator-state.md` (one sentence ...)" was not delivered. Plan D4 dropped it because the file is a policy document that agents must not modify. No acceptance criterion depends on it. | Requires an explicit user decision before any edit to that file. |
| G-5 | Non-blocking | Rule EE (exemption EE-1) applied only to Phase 0 baselines with a mechanical probe condition; the C10 mock removed the cause; final runs that include EE-1 report 0 failures. | Acceptable; the exemption expired before final QC. |
| G-6 | Non-blocking | New `PSUseSingularNouns` suppression on a private function whose name the spec does not fix. | See code-review CR-02. |

## 9. Summary of Changes

- pr-author gate: `-ContextExists` removed; artifact root resolved once before Case C in new sibling `enforce-pr-author-skill.artifact-root.ps1`; summary, body, receipt, and timestamp seams receive absolute paths beneath the resolved root; Check 1 binds relative paths to the session worktree only and absolute paths to the resolved root; `Get-PrAuthorBodyFileRoot` removed.
- Merge gate: new `Resolve-WorktreeItemTargetByPrNumber` (WIR) and seam `Resolve-EpicMergeGateItemTarget`; child checkpoint read beneath the resolved item root for an explicit PR number; `Test-ChildCheckpointPrGateBinding` fails closed for `$null` and unbound checkpoints (#788); unresolved-reason prefix includes the item target.
- `Test-WorktreeRunPathEqual`: `//` paths compared case-insensitively (CR-4).
- Both removal gates: single leading deny token (CR-5); epic removal gate deny gains a diagnostics clause and the read helper returns `Path` (#851).
- `orchestrate/SKILL.md`: absolute body path guidance for out-of-worktree pr-author calls.
- Mirrors, `core.json`, fixtures, five new suites, and fourteen edited suites.

## 10. Compliance Verdict

PASS. Blocking findings: 0. Non-blocking findings: 6 (G-1 to G-6). No remediation inputs are required.

## Appendix A: Test Inventory

New suites:

- `tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1` (341 lines)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1` (297 lines)
- `tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1` (167 lines)
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1` (193 lines)
- `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` (100 lines)

Edited suites: `enforce-pr-author-skill.Tests.ps1`, `.TargetResolution.Tests.ps1`, `.WorktreeResolution.Tests.ps1`, `.Issue824.Tests.ps1`, `hook-command-invocation.Issue824Regression.Tests.ps1`, `enforce-epic-merge-gate.Tests.ps1`, `.Authorization.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.WorktreeResolution.Tests.ps1`, `hook-command-parser.AcceptanceCases.Tests.ps1`, `enforce-epic-worktree-removal-gate.Tests.ps1`, `enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1`, `enforce-gate-suites.EpicStateIsolation.Tests.ps1`, `WorktreeRunResolution.Record.Tests.ps1`.

## Appendix B: Toolchain Commands Reference

- `git diff --stat origin/epic/enforcement-hook-precision-integration...HEAD`
- `cmp <.claude file> extensions/drm-copilot/resources/claude-customizations/<same path>` for each changed `.claude` file
- `sh <scratch>/run-ps.sh <scratch>/run-pester.ps1 -PathList <comma-separated suites>` (direct `Invoke-Pester` with `PassThru`; prints TotalCount, PassedCount, FailedCount, FAILED lines)
- `sh <scratch>/run-ps.sh <scratch>/pssa.ps1 -PathList <files>` (`Invoke-ScriptAnalyzer` and `Invoke-Formatter` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`)
- `python -I <scratch>/jacoco_cov.py artifacts/pester/powershell-coverage.xml <files>` (per-file and repo-wide LINE counters)
- `poetry run pytest -q -p no:cacheprovider tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
