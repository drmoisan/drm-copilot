# Remediation Inputs — Issue 1067, cycle 1 (related findings)

Timestamp: 2026-11-04T15-31
Remediation-Mode: proportionate
Source review: code-review.2026-11-04T15-30.md (Review-Verdict: PASS, zero blocking findings)
Basis: owner instruction for this run — findings related to the item are fixed inside the item before merge; only completely unrelated findings become follow-up issues. This cycle is opened for two non-blocking related findings; it adds no acceptance criterion.

## Findings in scope for this cycle

### R1-F1 — Environment-variable leak in two related suites
- Severity: Info (non-blocking)
- Remediability: autonomous
- Files: `tests/scripts/dev-tools/link-feature-docs.Tests.ps1`, `tests/scripts/dev-tools/link-parent-child.Tests.ps1`
- Finding: both suites set `$env:POSHQC_SKIP_SCRIPT_EXECUTION` and never restore it; a probe read the value 1 after the two-tree and `tests/scripts` runs. This is the leak class the branch fixes in `sync-agents-from-instructions.Tests.ps1`.
- Required change: apply the same pattern used in `sync-agents-from-instructions.Tests.ps1` (save the prior value in `BeforeAll`; restore it, or remove it when it was absent, in `AfterAll`).
- Verification: a single-process run of each suite followed by a probe shows the variable absent and `Failed=0`; a single-process run over `tests/scripts/dev-tools` shows the probe absent at the end and `Failed=0`.

### R1-F2 — Unescaped fixture paths in script-block source
- Severity: Nit (non-blocking)
- Remediability: autonomous
- Files: `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1`, `tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1`
- Finding: fixture paths are interpolated into `[scriptblock]::Create(...)` source inside single quotes; a path containing `'` would break the block.
- Required change: escape each interpolated path with `[System.Management.Automation.Language.CodeGeneration]::EscapeSingleQuotedStringContent`; assertions unchanged.
- Verification: both suites pass with unchanged test counts.

### R1-F4 — Same unescaped script-block pattern in a sibling suite (added by the orchestrator from the planner's sibling check)
- Severity: Nit (non-blocking)
- Remediability: autonomous
- File: `tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1`
- Finding: the no-probe ParameterFilter is built with `[scriptblock]::Create("...StartsWith('$noProbeRoot', ...)")`, the same pattern as R1-F2.
- Required change: same escape as R1-F2; assertions and test count unchanged.
- Verification: the suite passes with an unchanged test count.

### R1-F5 — Leaked global function in a related suite (added by the orchestrator from the planner's sibling check)
- Severity: Info (non-blocking)
- Remediability: autonomous
- File: `tests/scripts/dev-tools/link-feature-docs.Tests.ps1`
- Finding: `function global:gh` is defined in `BeforeAll` and never removed, the leak class the branch fixes for `global:` functions in `Enter-DrmCopilotShell.Tests.ps1`.
- Required change: remove `Function:\global:gh` in `AfterAll`, restoring any prior definition that existed before `BeforeAll`; before editing, search `tests/` for a later suite that depends on the leaked `gh` and record the result.
- Verification: after a single-process run of the suite, `Get-Command gh -CommandType Function` returns nothing (or the prior definition), and `Failed=0`.

## Findings deferred within this item (not in this cycle)

### R1-F3 — Trampoline comment in PoshQC.Testing.psm1
- Severity: Info (non-blocking)
- Remediability: autonomous
- Files: `scripts/powershell/PoshQC/PoshQC.Testing.psm1` and its bundle mirror `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`
- Disposition: corrected in this item in the final code-touching commit, together with the AC2 check-off after S9, so that the final PR head runs `ci.yml` in full. The change is comment-only, keeps the mirror byte-identical, and is verified by the bundle-mirror contract tests and the CI run on that head.

## Findings not acted on
- `$PWD.ProviderPath` assumption in D2/D3 (Info): recorded as a design assumption in spec.md `## Assumptions, Constraints, Dependencies`; no change.

## Constraints
- Test-file edits only in this cycle; no production file changes; no temp files, no `-Skip`, no new Python.
- Plan must carry `## Pre-Mortem` and a final self-review task per `atomic-plan-contract`.
