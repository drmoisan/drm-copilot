# Remediation Inputs - issue #1024 (review 2026-11-04T14-03)

Review-Verdict: AWAITING_CI
Remediation-Mode: none (no autonomous finding)

Source review artifacts (this folder):

- `policy-audit.2026-11-04T14-03.md`
- `code-review.2026-11-04T14-03.md`
- `feature-audit.2026-11-04T14-03.md`

Branch: `feature/docs-reference-generator-1024-r2`, head `5eda92c12`. Base: `origin/epic/documentation-estate-tooling-integration` (merge base `06012704f`).

## Blocking Findings

### F1 - Local PowerShell coverage artifact does not describe the recorded full run

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, check `poshqc / PowerShell QC` (Pester shards on windows-latest with merged coverage) for the PR head, whose per-file report supplies the figures. The local file was rewritten at 04:36Z by the 182-test AC-verification run after the full run recorded at 04:00Z; the recorded denominators match the current file exactly for all seven changed production files and no production file changed after the recorded run, so the gap is in local evidence retention, not in the code.
- File: `artifacts/pester/powershell-coverage.xml` (gitignored; not in the branch diff)
- Rule: feature-review Coverage Verification (figures read from the existing coverage artifact); `.claude/rules/general-unit-test.md` coverage requirements; spec AC-24, user-story US-17.
- Evidence: reviewer parse shows `DocsReferencePlan.psm1` 91.67%, `DocsReferenceRender.psm1` 100%, `DocsReferenceMarkers.psm1` 92.31%, `DocsReferenceReport.psm1` 100% (confirmed at or above 85%), and partial-run lower bounds `DocsReferenceFrontMatter.psm1` 81.82%, `DocsReferenceWriter.psm1` 48.88%, `Invoke-DocsCommand.ps1` 0%; root LINE 1202 of 26444; `artifacts/pester/pester-junit.xml` lists six suites and 182 tests. Executor-recorded figures: 100% for each new module, `Invoke-DocsCommand.ps1` 87.74% (`evidence/qa-gates/coverage-final.2026-11-04T04-00.md`, `evidence/qa-gates/coverage-delta.2026-11-04T04-00.md`).
- Required change: no code change. At S9, read the per-file LINE figures for the six new `.claude/lib/docs/DocsReference*.psm1` modules and `Invoke-DocsCommand.ps1` from the CI coverage report for the PR head; confirm each new module is at or above 85% and `Invoke-DocsCommand.ps1` is not below its 87.42% baseline; then check off AC-24 (`spec.md` line 825) and US-17 (`user-story.md` line 105). If local proof is wanted before the PR instead, re-run `Invoke-PoshQCTest` with coverage over the P9-T3 scan set and run nothing afterwards that rewrites `artifacts/pester/`.

### F2 - CI-dependent acceptance criterion AC-27 unchecked

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, checks `poshqc / PowerShell QC`, `poshqc / PowerShell QC static` and `quality-checks7 / Code Quality & Tests (3.11)`, `(3.12)`, `(3.13)` for the PR head; no pull request exists for head `5eda92c12` (`gh pr list` returns none). The reviewer Pester run reports 1373 of 1373 and the push-down pytest 34 of 34; only CI on the PR head can satisfy the criterion.
- Criteria: `spec.md` line 828 (AC-27).
- Evidence: `evidence/qa-gates/ci-pending.2026-11-04T04-33.md`; `evidence/qa-gates/pester-final.2026-11-04T04-00.md`.
- Required change: no code change. Open the PR into the epic integration branch (dispatch `ci.yml` manually if no checks start, since it triggers only on PRs into `main` or `development`). The item's own orchestrator run checks off AC-27 at S9 after a green conclusion, together with AC-24 and US-17 from F1, then re-runs the CI gate on the new head.

## Non-blocking Items

- Minor: `.claude/lib/docs/DocsReferenceFrontMatter.psm1` lines 238-242 - the canonical-JSON fallback catches every exception; narrow it to the documented non-integral-number case (optional, in this item if a cycle runs for another reason).
- Info: `tests/scripts/claude-lib/docs/DocsWriteBoundary.Tests.ps1` (1023-owned) now admits the second write boundary `Invoke-DocsReferencePageWrite`; record it in the epic notes.
- Info: Linux-host single-process `tests/scripts` failures (409) are outside the diff (#1066, #1067).
- No file-size Warning: no covered file reaches 700 logical lines.

## Artifact Paths

- policy-audit-path: docs/features/active/2026-10-30-docs-reference-generator-1024/policy-audit.2026-11-04T14-03.md
- code-review-path: docs/features/active/2026-10-30-docs-reference-generator-1024/code-review.2026-11-04T14-03.md
- feature-audit-path: docs/features/active/2026-10-30-docs-reference-generator-1024/feature-audit.2026-11-04T14-03.md
