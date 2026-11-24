# Remediation Inputs (Issue #1228), feature re-audit 2026-11-24T15-38

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: light
Remediation-Mode: light

**Entry timestamp:** 2026-11-24T15-38
**Feature folder:** `.dev/active/1228-targeted-test-cadence`
**Base branch:** `main` (merge base `23458fade99f40e81b95ce86ed90805258479782`)
**Head reviewed:** `c8a4d99cf3f41b02170caeaf0da398764370c638` on `feature/targeted-test-cadence-1228`
**Work mode:** `full-feature`; AC sources are `spec.md` and `user-story.md` (30 of 30 met as written)
**Finding count:** 1 (autonomous: 1)
**Supersedes:** `remediation-inputs.2026-11-24T10-50.md` (F3 resolved by commit `c8a4d99cf`)
**Audit artifacts:**
- `.dev/active/1228-targeted-test-cadence/policy-audit.2026-11-24T15-38.md`
- `.dev/active/1228-targeted-test-cadence/code-review.2026-11-24T15-38.md`
- `.dev/active/1228-targeted-test-cadence/feature-audit.2026-11-24T15-38.md`

## Findings

### F4 - Run-scope record writer does not implement ShouldProcess

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is a local edit to one PowerShell function on this branch plus its generated copy, its bundle copies, one test row, and the ledger stored patch; no external system, CI result, or owner decision is needed.
Finding-Scope: contained

Files: `.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` (`Write-TestSuiteRunScopeRecord`, line 164), the generated `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`, the bundle copies `extensions/drm-copilot/resources/claude-customizations/.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`, the test `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.RunScope.Tests.ps1`, and `.dev/engineering/process-reductions/patches/0014-targeted-test-cadence.patch`.

Current state: `Write-TestSuiteRunScopeRecord` runs `New-Item -ItemType Directory` and `Set-Content` under `[CmdletBinding()]` only. `.claude/rules/powershell.md` `## Coding Standards` requires ShouldProcess for state-changing actions; the sibling `Write-TestExecutionHolderRecord` in `.claude/hooks/test-execution-lock.ps1` uses `[CmdletBinding(SupportsShouldProcess)]` with a `$PSCmdlet.ShouldProcess` guard. PSScriptAnalyzer does not report it because its ShouldProcess rule ignores the `Write` verb.

Fix:
1. In the `.agents` source, change the attribute to `[CmdletBinding(SupportsShouldProcess)]` and wrap the folder creation and the `Set-Content` call in `if ($PSCmdlet.ShouldProcess($Path, 'Write the test-suite run-scope record')) { ... }`. Keep the error behavior (exceptions still propagate to the launcher's catch).
2. Regenerate the `.claude` copy with `scripts/harness-generation/Invoke-HarnessGeneration.ps1` and copy the source and the generated file to their bundles byte-identically.
3. Add one row to `Invoke-TestSuite.RunScope.Tests.ps1` that calls `Write-TestSuiteRunScopeRecord -WhatIf` with `New-Item` and `Set-Content` mocked and asserts neither is invoked.
4. Regenerate the stored patch of ledger entry `0014` as its `## Stored Patch` section describes, in the same commit, with the commit subject token `reduction: 0014`.

Verification: the new row passes; `Invoke-TestSuite.RunScope.Tests.ps1`, `Invoke-TestSuite.Tests.ps1`, `ProcessReductionChain.Ledger.Tests.ps1`, and `HarnessGeneration.RepoGate.Tests.ps1` pass in one launcher `pester -TestPath` run; `Invoke-HarnessGeneration.ps1 -Check` reports no drift; the launcher keeps line coverage at or above 93.85%.

## Light Fix Tasks

- [x] [P0-T1] F4: add `SupportsShouldProcess` and a `$PSCmdlet.ShouldProcess` guard to `Write-TestSuiteRunScopeRecord` in `.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`, regenerate the `.claude` copy, copy both bundles, add a `-WhatIf` row to `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.RunScope.Tests.ps1`, and regenerate `.dev/engineering/process-reductions/patches/0014-targeted-test-cadence.patch`.

## Non-blocking note for the same cycle

`user-story.md` `## Non-Goals` still lists "Adding or changing hooks, validators, or configuration", which spec D11 contradicts. Amending that bullet to name the D11 exception is recommended in the same commit; it is not a finding and does not change any acceptance criterion.

## Do not do

- Do not change any acceptance criterion text, the hook scripts, the reader functions, or the run-scope record format.
- Do not lower any coverage threshold or add a coverage exclusion.
- Do not change CI workflows, the frozen epic surfaces (D5), the D10 standalone Copilot agents and prompts, or the docs estate owned by epic #1217.
- Do not hand-edit a generated file; do not add Python.
- Do not use serial, single-process, shuffled, or reversed test runs.
- Write evidence only under `.dev/active/1228-targeted-test-cadence/evidence/<kind>/`, append-only, with clock-read timestamps.
