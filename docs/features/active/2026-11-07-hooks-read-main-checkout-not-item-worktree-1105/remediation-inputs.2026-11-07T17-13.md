# Remediation Inputs — Issue 1105

Timestamp: 2026-11-07T17-13
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: light
Remediation-Path: light
Source review artifacts:
- `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105/policy-audit.2026-11-07T17-13.md`
- `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105/code-review.2026-11-07T17-13.md`
- `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105/feature-audit.2026-11-07T17-13.md`
Head reviewed: `5a866484f06e940196f7fe867dce98cc86e461de` (merge base `bad886e304990d26af56d6bcabc9d543518492e9`)
Prior cycle: cycle 1 (full path, `remediation-plan.2026-11-07T15-37.md`). F1, F2, and F3 from `remediation-inputs.2026-11-07T15-37.md` are resolved.

## Findings requiring remediation

### F4 — A `-Times 0` assertion in the coverage target suite cannot fail under the gate host

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is three filter expressions in one test file that is already in the branch diff; it needs no external party, policy decision, owner input, or CI result.
Finding-Scope: contained

- File: `tests/scripts/claude-hooks/validate-feature-review-coverage.TargetWorktree.Tests.ps1`, case "reads the PR context summary, the root CLAUDE.md, and the coverage report only beneath the item root", lines 216-218.
- Problem: the line 218 `ParameterFilter` reads `$Root`. When the hook calls `Get-ArtifactFileContent` without `-Root`, the name is unbound in the filter scope, so PowerShell resolves it from an outer scope. `Invoke-PoshQCTest -Root <worktree>` defines a non-empty `$Root` there, so `[string]::IsNullOrEmpty($Root)` is false and the assertion passes for any hook behavior. Lines 216-217 read the same name; they still fail when the rooted read is missing, but they depend on the same outer lookup.
- Reviewer evidence: in a scratch copy, a mutant hook that adds an unrooted summary read fails the case under plain `Invoke-Pester` and passes it when the run starts from a function with a `$Root` parameter. With `$PesterBoundParameters['Root']` in place of `$Root` in lines 216-218, the original hook passes and the mutant fails in both hosts.
- Required change: in lines 216, 217, and 218, replace `$Root` with `$PesterBoundParameters['Root']`. Change nothing else in the assertions, the hook, or any other suite.
- Verification required: format and analyze the file; one `Invoke-PoshQCParallelTest` run with 0 failures; then check criterion 8 in `spec.md` (`- [ ]` to `- [x]`, text unchanged), which this review unchecked because of this finding.

## Light Fix Tasks

- [x] [P0-T1] `tests/scripts/claude-hooks/validate-feature-review-coverage.TargetWorktree.Tests.ps1` lines 216-218 (F4): read the bound value as `$PesterBoundParameters['Root']` instead of `$Root` in the three `ParameterFilter` expressions, run the PowerShell toolchain and one parallel gate run, and re-check spec criterion 8.

## Non-remediation items (record only)

- F5, Nit: `Register-EpicStateBaselineMock` in `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` throws when a bundle copy and a repository copy of the same module are loaded. The helper is not in the branch diff; the branch's only in-process loader of a bundle hook copy (ThresholdsGuard) removes the bundle modules in its `AfterAll`. No change is required on this branch.
- Criterion 16 (CI Required Gate green on the PR head) is pending CI and owned by the orchestrator at S9; it is not a finding.

## Constraints

- Tests run in parallel only: one `Invoke-PoshQCParallelTest` run.
- Tests create no files.
- Edit only the named test file and the criterion 8 checkbox in `spec.md`.
- Any commit makes this review stale, so a re-review follows.
