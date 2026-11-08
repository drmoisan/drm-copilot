# Remediation Inputs - issue #1033 (re-audit 2026-11-04T15-41, after remediation cycle 1)

Review-Verdict: AWAITING_CI
Remediation-Mode: none (no autonomous finding remains)

Finding classes: F3 awaiting_ci. The prior autonomous findings F1 and F2 of review `2026-11-04T14-15` are resolved, as are the two related Info items taken into cycle 1; no new finding was raised. No remediation cycle is required. The next step is to open the pull request and wait for CI.

Source review artifacts (this folder):

- `policy-audit.2026-11-04T15-41.md`
- `code-review.2026-11-04T15-41.md`
- `feature-audit.2026-11-04T15-41.md`

Branch: `feature/docs-surface-analyzers-typescript-dotnet-1033-r2`, head `f06a626b4`. Base: `origin/epic/documentation-estate-tooling-integration` (merge base `a94dea9a4`).

## Resolved Since The Prior Review

- F1 (two sibling 1022 tests failed after the integration merge): resolved by membership assertions in `DocsInventory.Tests.ps1` and `DocsInventorySnapshot.Tests.ps1`; the reviewer docs-folder run at HEAD has no failure.
- F2 (spec published lowercase hyphenated code spellings): resolved by `spec.md` `### Diagnostic code spelling (C7)`, the rewritten C7 row and the rewritten `## Decisions Later Children Must Honor` code bullet; 21 of 21 precision-limit rows match `Get-DocsScannerPrecisionLimit` under the mapping.

## Blocking Findings

### F3 - CI-dependent acceptance criteria S22 and U12 unchecked

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, checks `poshqc / PowerShell QC` (windows-latest shards with coverage) and `quality-checks7 / Code Quality & Tests` (3.11, 3.12, 3.13) for the PR head; no pull request exists yet for head `f06a626b4`. The local coverage artifact from the cycle's final docs-folder run reproduces the recorded per-file figures (92.43% to 100%), but only the CI run on the PR head can satisfy the criteria as written.
- File: `spec.md` line 770 (S22); `user-story.md` line 122 (U12)
- Symbol: not applicable (CI criterion)
- Rule: `.claude/skills/acceptance-criteria-tracking/SKILL.md` `### CI-Dependent Criteria`.
- Evidence: no PR for the branch; plan `[P7-T11]` unchecked; reviewer parse of `artifacts/pester/powershell-coverage.xml`.
- Required change: none in a remediation cycle. Open the PR into `epic/documentation-estate-tooling-integration` (dispatch `ci.yml` manually if no checks start, since it triggers only on PRs into `main` or `development`). At S9 the item's own orchestrator run checks off S22 and U12 after green conclusions, completes `[P7-T11]`, and re-runs the CI gate on the new head.

## Non-blocking Items

- Minor: plan `[P7-T11]` acceptance names `quality-checks7 / Code Quality & Tests (3.10)`, which `_quality-checks.yml` does not carry (matrix 3.11, 3.12, 3.13); record the absence in the S9 CI evidence.
- Info: the spec's import form names `-Force`; the modules follow the 1020 convention without it.
- No file-size Warning applies (largest covered file 525 logical lines).

## Artifact Paths

- policy-audit-path: docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/policy-audit.2026-11-04T15-41.md
- code-review-path: docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/code-review.2026-11-04T15-41.md
- feature-audit-path: docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/feature-audit.2026-11-04T15-41.md
