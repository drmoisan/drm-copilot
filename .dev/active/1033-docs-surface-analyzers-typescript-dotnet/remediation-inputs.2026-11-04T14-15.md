# Remediation Inputs - issue #1033 (review 2026-11-04T14-15)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

Finding classes: F1 and F2 autonomous; F3 awaiting_ci. Orchestrator scope note: the cycle also takes in two related non-blocking items (case-sensitive verb and `Map*` lookup tables in `DocsAnalyzerDotnetHttp.psm1`, and the duplicated schema URN and artifact-kind constants between `DocsExtensionShape.psm1` and `DocsAnalyzerExtensionImport.psm1`), because both sit in files already in the branch diff and change no acceptance criterion or public interface.

Source review artifacts (this folder):

- `policy-audit.2026-11-04T14-15.md`
- `code-review.2026-11-04T14-15.md`
- `feature-audit.2026-11-04T14-15.md`

Branch: `feature/docs-surface-analyzers-typescript-dotnet-1033-r2`, head `4bbba7c70`. Base: `origin/epic/documentation-estate-tooling-integration` (merge base `a94dea9a4`).

## Blocking Findings

### F1 - Two docs Pester tests fail at HEAD after the integration merge

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: The failure is reproduced locally (reviewer run 1666 of 1668) and the fix is a test-assertion change inside this branch's worktree; no external system, owner decision or CI result is needed to make it.
- File: `tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1` line 110; `tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1` line 132
- Symbol: `It 'exits 0 with a dry-run snapshot, no finding, no WriteText call, revision null and the fixed clock'`; `It 'validates against surface-inventory-snapshot through Test-DocsArtifactText with no finding and carries the header fields'`
- Rule: `.claude/rules/general-code-change.md` `## Mandatory Toolchain Loop` (unit tests must pass in a single clean pass); `spec.md` `## Decisions Later Children Must Honor` and C6 (registry-dependent suites assert membership only, never the committed table).
- Evidence: reviewer `Invoke-Pester` over `tests/scripts/claude-lib/docs` at `4bbba7c70`: Total 1668, Passed 1666, Failed 2; messages "Expected @('config-files', 'python-architecture', 'python-cli', 'python-http', 'python-public-api'), but got @('config-files', 'dotnet-config', 'dotnet-http', 'dotnet-public-api', 'extension-import', ...)" and the same for the `id:method:version` list. Executor record `evidence/regression-testing/post-integration-merge.2026-11-04T14-05.md` (untracked) shows the same two failures.
- Required change: replace each exact-list assertion with membership assertions for the five 1022 entries (for example, each expected entry is contained in the list, and the list equals its ordinal sort), leaving the element-level assertions unchanged. Commit the post-merge evidence file, re-run the docs folder and the toolchain loop, and record the passing run under `evidence/regression-testing/`.

### F2 - Specification publishes diagnostic code spellings the code does not emit

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: The adopted spelling is already decided and recorded (C7 in `evidence/other/contract-reconciliation.2026-11-03T21-46.md`, forced by the merged 1020 grammar); the change is a documentation edit to this item's own `spec.md`, following the #1022 precedent D-1022-exec-1, and needs no new owner decision.
- File: `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/spec.md` lines 613 (C7 row) and 627-630 (`## Decisions Later Children Must Honor`, code bullet); code literals in `## Recognition Rules`, `## Scanner Precision Limit` and `## Extension-Result Manifest Import`
- Symbol: not applicable (specification text)
- Rule: spec `## Decisions Later Children Must Honor` is binding on later children; `user-story.md` fourth story statement (fixed diagnostic codes agreed byte for byte); `.claude/rules/tonality.md` evidence-first wording (published contracts must match verified behavior).
- Evidence: `spec.md` line 627 reads "Diagnostic codes are lowercase words joined by `-`"; the modules and `Get-DocsScannerPrecisionLimit` emit `TS_LEXICAL_INVALID`, `HTTP_DYNAMIC_ROUTE`, `EXTENSION_FINDING_SKIPPED` and the other mapped codes; the self-review recorded the divergence as a documentation follow-up.
- Required change: update the C7 row to the adopted grammar `^[A-Z][A-Z0-9_]*$`, rewrite the code bullet of `## Decisions Later Children Must Honor` to state the uppercase underscore form and the mechanical mapping rule, and either replace the code literals in the normative sections with the emitted spellings or add one normative sentence stating that each listed code is emitted in its mapped form. Do not change the acceptance-criteria checkbox state. Record the edit in the plan.

### F3 - CI-dependent acceptance criteria S22 and U12 unchecked

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, checks `poshqc / PowerShell QC` (windows-latest shards with coverage) and `quality-checks7 / Code Quality & Tests` (3.11, 3.12, 3.13) for the PR head; no pull request exists yet for head `4bbba7c70`. The local coverage artifact reproduces the recorded per-file figures (92.43% to 100%), but only the CI run on the PR head can satisfy the criteria as written.
- File: `spec.md` line 754 (S22); `user-story.md` line 122 (U12)
- Symbol: not applicable (CI criterion)
- Rule: `.claude/skills/acceptance-criteria-tracking/SKILL.md` `### CI-Dependent Criteria`.
- Evidence: `artifacts/pr_context.summary.txt` ("no PR exists yet for this branch"); reviewer parse of `artifacts/pester/powershell-coverage.xml`.
- Required change: none in a remediation cycle beyond F1. After F1 and F2 are fixed, open the PR into the epic integration branch (dispatch `ci.yml` manually if no checks start, since it triggers only on PRs into `main` or `development`). At S9 the item's own orchestrator run checks off S22 and U12 after green conclusions and re-runs the CI gate on the new head.

## Non-blocking Items

- Minor: plan `[P7-T11]` acceptance names `quality-checks7 / Code Quality & Tests (3.10)`, which `_quality-checks.yml` does not carry (matrix 3.11, 3.12, 3.13); record the absence in the S9 CI evidence.
- Info: `DocsAnalyzerDotnetHttp.psm1` verb and `Map*` tables are case-insensitive default hashtables.
- Info: the spec's import form names `-Force`; the modules follow the 1020 convention without it.
- Info: schema URN and artifact-kind constants are duplicated in `DocsExtensionShape.psm1` and `DocsAnalyzerExtensionImport.psm1`.
- No file-size Warning applies (largest covered file 525 logical lines).

## Artifact Paths

- policy-audit-path: docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/policy-audit.2026-11-04T14-15.md
- code-review-path: docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/code-review.2026-11-04T14-15.md
- feature-audit-path: docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/feature-audit.2026-11-04T14-15.md
