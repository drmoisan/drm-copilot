# Remediation Inputs - issue #1021 (review 2026-11-04T00-25)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

Source review artifacts (this folder):

- `policy-audit.2026-11-04T00-25.md`
- `code-review.2026-11-04T00-25.md`
- `feature-audit.2026-11-04T00-25.md`

Branch: `feature/docs-page-quality-checker-1021-r2`, head `95aa64e64`. Base: `origin/epic/documentation-estate-tooling-integration` (merge base `fd6ee4e5a`).

## Blocking Findings

### F1 - Flow-sequence item ending in an escaped backslash is reported as unsupported

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: The fix is a source and test change inside files already in the branch diff (`DocsPageFrontMatter.psm1`, its bundle copy, `DocsPageFrontMatter.Tests.ps1`); it changes no acceptance criterion, public function signature, finding code or schema.
- Spec: `spec.md` `## Front-matter subset` value-form table, line 390: a value that starts with `[` and is not JSON is a single-line flow sequence of plain, single-quoted or JSON double-quoted scalars; only nesting or an unclosed `]` is `UNSUPPORTED`.
- Location: `.claude/lib/docs/DocsPageFrontMatter.psm1`, `ConvertFrom-DocsPageFlowSequence`, line 164: `if ($char -eq $quote -and -not ($quote -eq [char]'"' -and $Text[$index - 1] -eq [char]'\')) { $quote = [char] 0 }`.
- Defect: the one-character look-back treats the closing quote of `"a\\"` as escaped, so the item never closes and the value resolves to `Construct = 'unclosed flow sequence'` (`DOCS_PAGE_FRONT_MATTER_UNSUPPORTED`). Reviewer probe through the module scope of `ConvertFrom-DocsPageYamlScalar`: `["a\\", b]` gives `Ok=False Construct=unclosed flow sequence`; `["a", b]` gives `a`, `b`.
- Required change:
  1. Track escape state while inside a double-quoted item: a backslash sets an escape flag, the next character clears it, and a `"` closes the item only when the flag is clear. Single-quoted items keep the `''` rule.
  2. Add `DocsPageFrontMatter.Tests.ps1` cases: `["a\\", b]` resolves to the items `a\` and `b` with no finding; `["a\\\"", b]` resolves to `a\"` and `b`; an unterminated `["a\", b]` still yields `DOCS_PAGE_FRONT_MATTER_UNSUPPORTED`.
  3. Copy the edited module byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPageFrontMatter.psm1`.
- Constraints: `DocsPageFrontMatter.psm1` stays at 100% line coverage and at or below 500 logical lines (now 422); `DocsPageFrontMatter.Tests.ps1` stays below 700 logical lines (now 522); no temporary files in tests.
- Verification: `Invoke-Formatter` and `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `.claude/lib/docs` and `tests/scripts/claude-lib/docs` (0 differences, 0 findings); `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib` with 0 failures and 100% for `DocsPageFrontMatter.psm1`; `Docs.Manifest.Tests.ps1` passes (bundle identity).

### F2 - CI-dependent acceptance criteria S20 and U10 unchecked

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, check `poshqc / PowerShell QC` (Pester shards on windows-latest, with coverage) for the PR head; no pull request exists yet for head `95aa64e64`. The local full-tree run on the Linux host fails 409 tests and 6 blocks, a set identical to the merge-base baseline with no failing suite under a changed path.
- Evidence: `evidence/regression-testing/isolation-single-process.2026-11-04T00-15.md`; `evidence/baseline/baseline-pester-coverage.2026-11-03T22-19.md`.
- Action: none in the remediation cycle. The item's orchestrator run checks off S20 and U10 at S9 after a green CI conclusion.

## Non-blocking Items (optional in the same cycle)

- N1 (Minor): `.claude/lib/docs/DocsPageCheck.psm1` computes `Get-DocsPageLinkMap` twice per `check` run (line 413 in `Invoke-DocsCheckCommand` and line 309 in `Get-DocsPageCheckFinding`). If addressed, pass the precomputed map through an optional parameter and keep `Get-DocsPageCheckFinding` callable without it; keep 100% coverage and re-copy the bundle module.

## Artifact Paths

- policy-audit-path: docs/features/active/2026-10-30-docs-page-quality-checker-1021/policy-audit.2026-11-04T00-25.md
- code-review-path: docs/features/active/2026-10-30-docs-page-quality-checker-1021/code-review.2026-11-04T00-25.md
- feature-audit-path: docs/features/active/2026-10-30-docs-page-quality-checker-1021/feature-audit.2026-11-04T00-25.md
