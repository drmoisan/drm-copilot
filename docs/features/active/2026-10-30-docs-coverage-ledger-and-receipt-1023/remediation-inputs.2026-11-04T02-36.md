# Remediation Inputs - issue #1023 (review 2026-11-04T02-36)

Review-Verdict: AWAITING_CI
Remediation-Mode: none (no autonomous finding)

Source review artifacts (this folder):

- `policy-audit.2026-11-04T02-36.md`
- `code-review.2026-11-04T02-36.md`
- `feature-audit.2026-11-04T02-36.md`

Branch: `feature/docs-coverage-ledger-and-receipt-1023-r2`, head `1b160781a`. Base: `origin/epic/documentation-estate-tooling-integration` (merge base `d24071738`).

## Blocking Findings

### F1 - Local PowerShell coverage artifact does not describe the recorded run

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, check `poshqc / PowerShell QC` (Pester shards on windows-latest, with coverage) for the PR head, whose per-file report is the source the spec names for these figures (S32). The local file was rewritten at 02:06Z by the five-test file-size gate run after the full run recorded at 01:51Z; the recorded denominators match the current file exactly and no production file changed since, so the defect is in local evidence retention, not in the code.
- File: `artifacts/pester/powershell-coverage.xml` (gitignored; not in the branch diff)
- Rule: feature-review Coverage Verification (figures read from the existing coverage artifact); `.claude/rules/general-unit-test.md` coverage requirements.
- Evidence: reviewer parse shows root LINE 61 of 24977 and 0 covered lines in every `.claude/lib/docs/` file; `artifacts/pester/pester-junit.xml` lists only `FileSizePolicy.RepoGate.Tests.ps1`; recorded figures in `evidence/qa-gates/qa-pester-coverage.2026-11-04T01-51.md` (96.84% to 100% per new file, 92.99% total).
- Required change: none in a remediation cycle. At S9, read the per-file LINE figures for the ten new `.claude/lib/docs/` modules and `Invoke-DocsCommand.ps1` from the CI coverage report for the PR head and confirm each new module is at or above 85%. If local proof is wanted before the PR instead, re-run `Invoke-PoshQCTest` with coverage over `tests/scripts/claude-lib/docs` and run nothing afterwards that rewrites `artifacts/pester/`.

### F2 - CI-dependent acceptance criteria S32 and U23 unchecked

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, check `poshqc / PowerShell QC` (windows-latest, with coverage) for the PR head; no pull request exists yet for head `1b160781a`. The reviewer docs-folder Pester run reports 990 of 990 and the 25 new suites 215 of 215; only CI on the PR head can satisfy the two criteria.
- Criteria: `spec.md` line 632 (S32) and `user-story.md` line 154 (U23).
- Evidence: `evidence/qa-gates/qa-pester-coverage.2026-11-04T01-51.md`; `evidence/qa-gates/coverage-delta.2026-11-04T01-51.md`; `evidence/qa-gates/ac-status.2026-11-04T02-07.md`.
- Required change: none in a remediation cycle. Open the PR into the epic integration branch (dispatch `ci.yml` manually if no checks start, since it triggers only on PRs into `main` or `development`). The item's own orchestrator run checks off S32 and U23 at S9 after a green conclusion with per-file figures at or above 85%, then re-runs the CI gate on the new head.

## Non-blocking Items

- Warning: `.claude/lib/docs/DocsLedgerCommands.psm1` at 785 logical lines (advisory tier).
- Warning: `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsLedgerCommands.psm1` at 785 logical lines (bundle copy).
- Info: `Get-DocsPinFinding` in `.claude/lib/docs/DocsEvidencePins.psm1` (lines 217-221) drops the exception message of the element-id rebuild when it reports `DOCS_PIN_INCONSISTENT`; optional improvement.

## Artifact Paths

- policy-audit-path: docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/policy-audit.2026-11-04T02-36.md
- code-review-path: docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/code-review.2026-11-04T02-36.md
- feature-audit-path: docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/feature-audit.2026-11-04T02-36.md
