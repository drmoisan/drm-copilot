# Remediation Inputs — Issue 1157

Timestamp: 2026-11-13T14-04
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: proportionate
Head: `621a6b83df30184693f563b9577a0c4f0a5753d5`
Base: `main`, merge base `1d62aa292161035aec8058e6c370f133e10a04db`
Source review artifacts:
- `docs/features/active/owner-directive-pass-down-1157/policy-audit.2026-11-13T14-04.md`
- `docs/features/active/owner-directive-pass-down-1157/code-review.2026-11-13T14-04.md`
- `docs/features/active/owner-directive-pass-down-1157/feature-audit.2026-11-13T14-04.md`
Remediation plan target: `docs/features/active/owner-directive-pass-down-1157/remediation-plan.2026-11-13T14-04.md`

Path note: three findings, all autonomous. F1 changes production logic in the stop-hook sibling beyond a single named line and touches its test suites, so it is design scope and the cycle takes the full path. The mode is proportionate because the preferred F1 remedy, F2, and F3 change only files already in the branch diff plus their tests, bundle copies, and evidence, and no spec acceptance criterion or public interface. If the planner instead amends AC-29, the cycle becomes `Remediation-Mode: design`.

## Findings requiring remediation

### F1 — AC-29 PARTIAL: an existing suite the spec requires unchanged carries an added mock line

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The seam that forces the mock is new code on this branch, and an existing already-mocked seam can carry the same reads; the fix lies in branch files and their tests and needs no external system, CI result, or owner decision.
Finding-Scope: design

- Location: `.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1` (`Read-OrchestratorOutputOwnerPassDownText` and its three call sites) and its bundle copy; `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectives.Tests.ps1` (`BeforeAll`); `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1`.
- Observed: spec AC-29 requires `validate-orchestrator-output.OwnerDirectives.Tests.ps1` to pass without edits. The branch adds `Mock Read-OrchestratorOutputOwnerPassDownText { $null }` to it, because `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` requires a baseline null mock for every closure seam of the stop hook. The suite's assertions are unchanged and it passes 22/0. The executor left AC-29 unchecked and recorded the gap in `evidence/other/task-check.P6-T9.2026-11-13T13-50.md`.
- Required change (preferred): have the sibling read the ledger and the parent and child checkpoints through the existing stop-hook seam `Get-CheckpointFileContent` (already null-mocked in the AC-29 suite), handling its `$null` and `Exists = $false` results as an absent source; remove `Read-OrchestratorOutputOwnerPassDownText`; revert the added mock line in `validate-orchestrator-output.OwnerDirectives.Tests.ps1` so the file equals the merge base; move the sibling suite's seam mocks to `Get-CheckpointFileContent`; optionally revert the same now-unneeded mock line in the other 13 `validate-orchestrator-output*` suites and the two `hook-dependency-failure` suites. Re-copy the bundle file.
- Alternative (design mode): a planner revision of AC-29 that admits a baseline isolation mock with no assertion change, with the reason recorded in the spec and the PR body.
- Tests: the discovery guard, the AC-29 suites, the sibling suite, and the key-gate counting rows pass; `git diff 1d62aa292..HEAD -- tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectives.Tests.ps1` is empty. Coverage of the sibling stays at or above 90%.
- Then check off AC-29 in `spec.md` with the evidence.

### F2 — Python post-change coverage artifact absent

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: One local pytest gate run with coverage enabled writes the artifact; no external system or decision is involved.
Finding-Scope: contained

- Location: Python evidence for `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.
- Observed: the branch changes one Python file, and `artifacts/python/lcov.info` does not exist in the item worktree. The P6-T7 gate ran `pytest -n auto` without `--cov`, so the `addopts` reporter wrote nothing.
- Required change: after the F1 and F3 edits, run one `pytest -n auto --cov --cov-branch` gate in the item worktree and record a new `evidence/qa-gates/pytest-final.<timestamp>.md` with pass and fail counts and the repo-wide line and branch figures read from `artifacts/python/lcov.info`, compared with the merge-base CI TOTAL (35355 statements, 1035 missed; 13424 branches, 554 partial; run 43170341553). No production Python file changes, so the figures should equal the merge-base figures.

### F3 — Ledger guard path test is case-sensitive

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The comparison and a test row are in a branch file; the fix widens a deny only and needs no external system or decision.
Finding-Scope: contained

- Location: `.claude/hooks/enforce-owner-directive-pass-down.ps1`, `Get-OwnerDirectivePassDownDecision`, the ledger branch (`$path -eq ...` and `$path.EndsWith(..., [System.StringComparison]::Ordinal)`), and its bundle copy; `tests/scripts/claude-hooks/enforce-owner-directive-pass-down.Tests.ps1` ledger rows.
- Observed: the suffix test is ordinal and case-sensitive. On a case-insensitive file system a subagent `Write` to `.../Artifacts/Orchestration/Owner-Directives.jsonl` reaches the ledger, and the hook emits nothing for a caller outside the acknowledgement set or with no pending entry. Spec D5 and AC-27 state that only the main session writes the ledger.
- Required change: compare both operands with `[System.StringComparison]::OrdinalIgnoreCase`; re-copy the bundle file; add a row asserting a subagent `Write` to a case-variant ledger path is denied with `OWNER_DIRECTIVE_LEDGER_WRITE_DENIED`, and confirm the row fails against the current comparison.

## Non-blocking items (no remediation required in this PR)

- CR1: per-call resolution cost for acknowledgement-set agents (disclosed in the spec; for #1159).
- CR2: the main implementation commit carries a pause subject; describe the content in the PR body or squash.
- CR3: the Phase 0 Pester baseline overlapped a module write of this item; keep as recorded.
- The two CI-dependent Definition of Done items are pending CI and are not findings.

## Verification required

- Task checks per the cadence; the full final QA loop with one `Invoke-PoshQCParallelTest` run (zero failures; per-file coverage of the five new files at or above 90%, the two modified files at or above 85% and not below the Phase 0 baseline, repo-wide at or above 85%) and one `pytest -n auto --cov --cov-branch` run (F2).
- PowerShell static checks over the changed files: formatter drift 0, analyzer findings 0, leak scan 0 failures.
- Byte parity of every edited `.claude` file with its bundle copy.
- A new self-review file with no FAIL row; then re-review.

## Constraints

- Tests run in parallel only: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. No serial, single-process, shuffled, or reversed gate runs. Test-order dependence is a violation.
- Evidence is append-only, stamped from clock reads; existing evidence is not edited, back-dated, or deleted. No artifact records an absolute path.
- No new Python file. No change to `.claude/agents/epic-orchestrator.md`, `orchestrator.md`, or `parallel-orchestrator.md`, to Codex or Copilot hooks, or to the Python and TypeScript validators.
- No baseline task, baseline evidence, or baseline comparison is reduced; no gate is weakened.
