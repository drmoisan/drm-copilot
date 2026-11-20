# Fail-Before Exception Dossier (issue 1105)

Timestamp: 2026-11-07T15-07
Task: [P3-T1]
Command: sh SCRATCH/issue-1105-mergebase.sh (read-only `git ls-tree`, `git grep`, and `git show` against the merge base; no test run, no file staged under SCRATCH)
EXIT_CODE: 0
Output Summary: no fail-before test run exists by design; alternative proof below cites the merge-base hook code for each of the eight new suites.

WhyFailingRunImpossible: The owner permits parallel gate runs only and prohibits comparison runs, so none of the eight new suites is run against merge-base hook copies. In addition, `subagentstop-target-worktree.ps1` and `validate-feature-review-coverage-freshness.ps1` do not exist at the merge base, so the suites that dot-source them cannot load there.

Merge-base derivation: `git merge-base origin/main HEAD`, evaluated in the item worktree on branch `bug/hooks-read-main-checkout-1105`. Every citation below was read with `git show <merge base>:<path>`; no commit identifier is recorded.

## Absence Proof

- `git ls-tree <merge base> -- .claude/hooks/subagentstop-target-worktree.ps1 .claude/hooks/validate-feature-review-coverage-freshness.ps1` lists 0 entries. EXIT_CODE: 0.
- `git grep -c -F Resolve-HookTargetWorktree <merge base> --` over the eight edited hook files (`validate-task-researcher-output.ps1`, `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, `validate-planner-output.ps1`, `validate-executor-output.ps1`, `validate-feature-review-coverage.ps1`, `validate-feature-review-coverage-metrics.ps1`, `validate-feature-review-coverage-rules.ps1`) returns zero matches. EXIT_CODE: 1 (git grep exits 1 when nothing matches).

## Alternative Proof

### subagentstop-target-worktree.Tests.ps1

`.claude/hooks/subagentstop-target-worktree.ps1` is absent at the merge base (Absence Proof), so `Resolve-SubagentStopTargetWorktree` and `Resolve-SubagentStopArtifactPath` do not exist and the suite cannot load. The transcript readers `Get-TranscriptPathFromEnvelope`, `Read-TranscriptHead`, and `Get-TranscriptFirstUserText` exist only in `validate-executor-output.ps1`, and no hook calls a resolver for SubagentStop artifact paths.

### validate-feature-review-coverage-freshness.Tests.ps1

`.claude/hooks/validate-feature-review-coverage-freshness.ps1` is absent at the merge base (Absence Proof). In `validate-feature-review-coverage-metrics.ps1`, `Get-ArtifactFileContent` checks existence only, and `Get-LanguageRepoCoverage` and `Get-LanguageBranchCoverage` read fixed process-relative report paths such as `artifacts/pester/powershell-coverage.xml`, so no report freshness check exists.

### validate-task-researcher-output.TargetWorktree.Tests.ps1

In `validate-task-researcher-output.ps1`, `Test-ResearchFile` and `Get-ResearchFileContent` probe the advertised value as given, relative to the process directory, so the item copy is never probed. `Test-IsUnderResearchRoot` rejects a value that does not start with `docs/features/` or `docs/research/`, so an absolute path inside the item worktree is rejected.

### validate-prd-feature-output.TargetWorktree.Tests.ps1

In `validate-prd-feature-output.ps1`, `Invoke-PrdFeatureOutputValidation` probes and reads `spec-path` and `research-path` as given (inline `Test-Path -LiteralPath $specPath` and the matching read), so a relative value resolves against the process directory and the item copy is never read.

### validate-required-artifact-output.TargetWorktree.Tests.ps1

In `validate-required-artifact-output.ps1`, `Test-ArtifactFile` probes the value as given, and `Get-RequiredArtifactOutputBlockDecision` applies the registered pattern (for `prd-feature`, `^docs/features/active/.+/spec\.md$`) to the raw value, so an absolute path inside the item worktree is rejected.

### validate-planner-output.TargetWorktree.Tests.ps1

In `validate-planner-output.ps1`, `Get-PlanFileContent` probes `plan-path` as given, so the plan-structure, Pre-Mortem, and planner-internal-review checks never read an item-only plan.

### validate-executor-output.TargetWorktree.Tests.ps1

In `validate-executor-output.ps1`, `Get-PlanFileContent` probes `plan-path` as given. `Get-PreflightRunBlockDecision` requires a `docs/features/` prefix and calls `Test-PreflightFixRecord` on the relative value, so an absolute path is rejected and a fix record present only on the item branch is not found (#1034). The transcript readers `Get-TranscriptPathFromEnvelope`, `Read-TranscriptHead`, and `Get-TranscriptFirstUserText` live in this file, and no resolver exists.

### validate-feature-review-coverage.TargetWorktree.Tests.ps1

In `validate-feature-review-coverage.ps1`, `Invoke-FeatureReviewCoverageValidation` reads `artifacts/pr_context.summary.txt` through `Get-ArtifactFileContent` relative to the process directory. In `validate-feature-review-coverage-rules.ps1`, `Get-ReviewArtifactInfo` anchors on `docs/features/active/`, so an absolute path is rejected (#1031). In `validate-feature-review-coverage-metrics.ps1`, `Get-FeatureReviewClaudeMdText` reads `CLAUDE.md` and `Get-LanguageRepoCoverage` and `Get-LanguageBranchCoverage` read fixed process-relative report paths such as `artifacts/pester/powershell-coverage.xml`; `Get-ArtifactFileContent` checks existence only, so a stale main-checkout report is read and no unresolved-target block exists (#1097).
