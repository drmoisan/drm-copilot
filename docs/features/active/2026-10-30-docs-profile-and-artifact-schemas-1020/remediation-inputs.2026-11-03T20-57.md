# Remediation Inputs - issue #1020 (re-audit 2026-11-03T20-57, after remediation cycle 1)

Review-Verdict: AWAITING_CI

Source review artifacts (this folder):

- `policy-audit.2026-11-03T20-57.md`
- `code-review.2026-11-03T20-57.md`
- `feature-audit.2026-11-03T20-57.md`

Branch: `feature/docs-profile-and-artifact-schemas-1020-r2`, head `a3ae4c51d`. Base: `origin/epic/documentation-estate-tooling-integration` (tip `5e535f7a6`).

Resolved in cycle 1 (verified by the reviewer): F1 (ShouldProcess on `Write-DocsFileText` and `Write-DocsContextText`; mirror byte-identical; `Invoke-DocsCommand.ps1` 87.33% line coverage) and N2 (silent `Test-Json` mock). No autonomous finding remains, so no further remediation cycle is required.

## Blocking Findings

### F2 - Plan task P6-T6 full `tests/scripts` single-process run unmet on this host

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, check `poshqc / PowerShell QC` on windows-latest for the PR head. The 409 local results recorded at 71217a14e are host-dependent and reproduce on the unchanged merge base on the same host; cycle 1 changed only docs files, and the 385 docs tests and the 3786-test claude-lib run pass.
- Evidence: `evidence/regression-testing/isolation-single-process.2026-11-03T20-06.md`; `evidence/remediation-baseline/same-host-mergebase-pester.2026-11-03T20-06.md`.
- Action: none in a remediation cycle. Open the PR and read the CI conclusion at S9.

### F3 - CI-dependent acceptance criteria S26 and U14 unchecked

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, checks `poshqc / PowerShell QC` on windows-latest and `quality-checks7 / Code Quality & Tests` for the PR head; no PR exists yet for head a3ae4c51d.
- Action: none in a remediation cycle. The item's orchestrator run checks them off at S9 after a green CI conclusion.

## Non-blocking Items

- N1 (Minor, carried forward, not adopted): the seven `examples/docs/v1/*.example.json` files report `would reformat` under `format_json --check`; no gate enforces it.
- N3 (Nit, new): the `-WhatIf` tests in `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` target `<repository root>/artifacts/docs-whatif-never-created`; after a gate regression, a leftover directory would keep the test failing until removed. Optional.

## Artifact Paths

- policy-audit-path: docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/policy-audit.2026-11-03T20-57.md
- code-review-path: docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/code-review.2026-11-03T20-57.md
- feature-audit-path: docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/feature-audit.2026-11-03T20-57.md
