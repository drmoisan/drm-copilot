# Remediation Inputs - issue #1020 (review 2026-11-03T20-22)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

Cycle scope (orchestrator): F1 and N2. F2 and F3 are `awaiting_ci` and are resolved at S9. N1 is not adopted: the header-first key order of the examples is a deliberate convention, and no gate enforces `format_json`.

Source review artifacts (this folder):

- `policy-audit.2026-11-03T20-22.md`
- `code-review.2026-11-03T20-22.md`
- `feature-audit.2026-11-03T20-22.md`

Branch: `feature/docs-profile-and-artifact-schemas-1020-r2`, head `71217a14e`. Base: `origin/epic/documentation-estate-tooling-integration`.

## Blocking Findings

### F1 - ShouldProcess not implemented on the state-changing write functions

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: The fix is a source and test change inside files already in the branch diff (`Invoke-DocsCommand.ps1`, its bundle mirror, `Invoke-DocsCommand.Tests.ps1`); it changes no acceptance criterion, public interface, or the `init` dry-run contract.
- Policy: `.claude/rules/powershell.md` line 30; `.github/instructions/powershell-code-change.instructions.md` line 52.
- Location: `.claude/lib/docs/Invoke-DocsCommand.ps1` `Write-DocsFileText` (lines 226-245) and `Write-DocsContextText` (lines 316-326).
- Required change:
  1. `Write-DocsFileText`: `[CmdletBinding(SupportsShouldProcess = $true)]`; wrap the directory creation and stream write in `if ($PSCmdlet.ShouldProcess($FullPath, "Write file ($Mode)")) { ... }`.
  2. `Write-DocsContextText`: declare `SupportsShouldProcess = $true` so `-WhatIf`/`-Confirm` propagate, and replace or remove the inert `PSUseShouldProcessForStateChangingFunctions` suppression at line 321.
  3. Keep the `init` behavior (dry run by default, `-Write`, `-Force`, planned-path listing) unchanged.
  4. Add a Pester test that calls `Write-DocsFileText -WhatIf` (and the context member path if practical) and asserts that no write happens. The test must not create a temporary file; with `-WhatIf` the body returns before any I/O. Do not mock the function under test in that case.
  5. Copy the edited `Invoke-DocsCommand.ps1` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/Invoke-DocsCommand.ps1`.
- Constraint: `Invoke-DocsCommand.ps1` line coverage is 85.91% (128 of 149). The new lines must be covered, for example by the `-WhatIf` test, so that the file stays at or above 85%. If the plan's P4-T4 attribution budget (at most 6 missed lines in `Write-DocsFileText`) is affected, record the new attribution.
- Verification: Invoke-Formatter and PSScriptAnalyzer over `.claude/lib/docs` and `tests/scripts/claude-lib/docs` (0 findings); `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib` with 0 failures and per-file coverage at or above 85%; `Docs.Manifest.Tests.ps1` passes; `enforcement-hooks-no-python-invocation.Tests.ps1` passes.

### F2 - Plan task P6-T6 full `tests/scripts` single-process run unmet on this host

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, check `poshqc / PowerShell QC` on windows-latest for the PR head. The 409 local failures are host-dependent and reproduced on the unchanged merge base on the same host; the 383 docs tests pass alone and inside the 3784-test claude-lib run, and no failing file is in the change set.
- Evidence: `evidence/regression-testing/isolation-single-process.2026-11-03T20-06.md`; `evidence/remediation-baseline/same-host-mergebase-pester.2026-11-03T20-06.md`.
- Action: none in the remediation cycle. Read the CI conclusion at S9.

### F3 - CI-dependent acceptance criteria S26 and U14 unchecked

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, checks `poshqc / PowerShell QC` on windows-latest and `quality-checks7 / Code Quality & Tests` for the PR head; no PR exists yet.
- Action: none in the remediation cycle. The item's orchestrator run checks them off at S9 after a green CI conclusion.

## Non-blocking Items (optional in the same cycle)

- N1 (Minor): the seven `examples/docs/v1/*.example.json` files report `would reformat` under `poetry run python -m scripts.dev_tools.format_json --check`. No CI workflow, test, or rule enforces it; the local `fix_all` JSON branch would rewrite them on its next run. If addressed, run `poetry run python -m scripts.dev_tools.format_json examples/docs/v1` and re-run `DocsSchemaContract.Tests.ps1` and `DocsNeutrality.Tests.ps1`.
- N2 (Nit): `tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1` line 310 mock prints a `Write-Error` line to the console in a passing run.

## Artifact Paths

- policy-audit-path: docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/policy-audit.2026-11-03T20-22.md
- code-review-path: docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/code-review.2026-11-03T20-22.md
- feature-audit-path: docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/feature-audit.2026-11-03T20-22.md
