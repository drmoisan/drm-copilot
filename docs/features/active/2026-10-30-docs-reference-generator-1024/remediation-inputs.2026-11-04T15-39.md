# Remediation Inputs - issue #1024 (review 2026-11-04T15-39)

Review-Verdict: AWAITING_CI
Remediation-Mode: none (no autonomous finding)

Source review artifacts (this folder):

- `policy-audit.2026-11-04T15-39.md`
- `code-review.2026-11-04T15-39.md`
- `feature-audit.2026-11-04T15-39.md`

Branch: `feature/docs-reference-generator-1024-r2`, head `e273e2adb`. Base: `origin/epic/documentation-estate-tooling-integration` (merge base `a94dea9a4`). Re-review at the exit of remediation cycle 1 (`remediation-inputs.2026-11-04T14-13.md`).

## Closed Since the Previous Review

- F1 (per-file PowerShell coverage): closed. The current `artifacts/pester/powershell-coverage.xml` was written by the 1666-test docs-folder `Invoke-PoshQCTest` run after the last production commit; it shows 100% for each of the six new modules and 87.82% for `Invoke-DocsCommand.ps1` (baseline 87.42%). AC-24 and US-17 were checked off by this review.
- Minor broad-catch finding in `ConvertTo-DocsReferenceFrontMatterText`: resolved by the pre-check `Test-DocsReferenceCanonicalNumberRejected`; seven test cases pin routing and propagation. No new finding introduced.

## Blocking Findings

### F2 - CI-dependent acceptance criterion AC-27 unchecked

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, checks `poshqc / PowerShell QC`, `poshqc / PowerShell QC static` and `quality-checks7 / Code Quality & Tests (3.11)`, `(3.12)`, `(3.13)` for the PR head; no pull request exists for head `e273e2adb` (`gh pr list` returns none). The reviewer Pester run reports 1705 of 1705 and the push-down pytest 34 of 34; only CI on the PR head can satisfy the criterion.
- Criteria: `spec.md` line 828 (AC-27).
- Evidence: `evidence/qa-gates/ci-pending.2026-11-04T04-33.md`; `evidence/qa-gates/pester-docs.2026-11-04T15-25.md`.
- Required change: no code change. Open the PR into the epic integration branch (dispatch `ci.yml` manually if no checks start, since it triggers only on PRs into `main` or `development`). The item's own orchestrator run checks off AC-27 at S9 after a green conclusion, then re-runs the CI gate on the new head.

### F3 - Repo-wide PowerShell line coverage not determinable from the local artifact

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, check `poshqc / PowerShell QC` (three Pester shards on windows-latest with a merged coverage report) for the PR head. The local artifact is docs-scoped: its root LINE counter (6196 of 28894, 21.44%) keeps the full configured denominator but counts only the docs suites. The branch adds 723 lines, all covered, so it cannot lower the repo-wide ratio. Carried forward from the repo-wide row of the previous F1; not introduced by cycle 1.
- File: `artifacts/pester/powershell-coverage.xml` (gitignored; not in the branch diff)
- Rule: feature-review Coverage Verification (repo-wide figure per language); `.claude/rules/general-unit-test.md` coverage requirements.
- Required change: no code change. At S9, read the root LINE figure of the merged PowerShell coverage report for the PR head and confirm it is at or above 85%. If it is below 85%, record whether the shortfall lies outside the files of this diff before deciding the next step.

## Non-blocking Items

- Info: `DocsReferenceFrontMatter.psm1` `Test-DocsReferenceCanonicalNumberRejected` restates the canonical number rule of `ConvertTo-DiscoveryCanonicalFragment`; the routing tests pin it.
- Info: `tests/scripts/claude-lib/docs/DocsWriteBoundary.Tests.ps1` (1023-owned) admits the second write boundary `Invoke-DocsReferencePageWrite`; record it in the epic notes.
- Info: Linux-host single-process `tests/scripts` failures (409) are outside the diff (#1066, #1067).
- No file-size Warning: no covered file reaches 700 logical lines.

## Artifact Paths

- policy-audit-path: docs/features/active/2026-10-30-docs-reference-generator-1024/policy-audit.2026-11-04T15-39.md
- code-review-path: docs/features/active/2026-10-30-docs-reference-generator-1024/code-review.2026-11-04T15-39.md
- feature-audit-path: docs/features/active/2026-10-30-docs-reference-generator-1024/feature-audit.2026-11-04T15-39.md
