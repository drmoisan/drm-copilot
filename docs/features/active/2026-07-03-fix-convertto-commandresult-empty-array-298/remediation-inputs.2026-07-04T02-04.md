# Remediation Inputs: fix-convertto-commandresult-empty-array (#298)

**Timestamp:** 2026-07-04T02-04
**Authored by:** feature-review agent (Claude Sonnet 5), following the initial (non-remediation-triggered) review pass
**Pointer to audit artifacts that produced these findings:**
- `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/policy-audit.2026-07-04T02-04.md`
- `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/code-review.2026-07-04T02-04.md`
- `docs/features/active/2026-07-03-fix-convertto-commandresult-empty-array-298/feature-audit.2026-07-04T02-04.md`

**Trigger:** The policy audit contains two Blocking findings under `## 2.3 Module & File Structure` and `## Coverage Verification`. All five acceptance criteria in `issue.md` are independently verified PASS (see `feature-audit.2026-07-04T02-04.md`); these findings are policy-audit-level, not AC-level.

Per `remediation-handoff-atomic-planner`, this document is the orchestrator-facing remediation-inputs artifact. Plan authoring is delegated to `atomic-planner`; this feature-review agent does not author the remediation plan itself.

---

## Enumerated Fix List

### Fix 1 — Bring `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` back under the 500-line cap

- **File:** `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`
- **Current state:** 507 lines (verified: `wc -l tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`).
- **Baseline state (main @ 97514a6):** 500 lines (verified: `git show 97514a6f0c51cfb92d79db9544b33c2adec2b7af:tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | wc -l`).
- **Expected behavior:** File is at or under 500 lines, per `general-code-change.instructions.md` / `.claude/rules/general-code-change.md` ("No production code, test code, or reusable script file may exceed 500 lines").
- **Acceptable approaches (choose one):**
  - Split one or more `Context` blocks (e.g., the `"additional failure paths"` block, which uses `-ForEach` parametrization and is likely to be large, or the `"helpers"` block) into a sibling test file, following the repo's mirrored test-file-location convention (e.g., a second `*.Tests.ps1` file for the same production script, if the repo's conventions permit multiple test files per script — confirm against `.claude/rules/powershell.md` before choosing a filename).
  - Obtain an explicit, documented policy exception if maintainers judge the single-file structure should be preserved (not currently an authorized exception category under `general-code-change.instructions.md`; would require an explicit approval to be usable).
- **Verification command:** `wc -l tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` must report `<= 500`.
- **Constraint:** Do not remove, weaken, or alter any existing assertion while splitting; all 26 currently-passing tests (including the new "accepts an empty array as Output without throwing" case) must continue to pass unchanged after the split.

### Fix 2 — Add the modified production file to the canonical PowerShell coverage allowlist

- **File:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- **Current state:** `CodeCoverage.Path` does not include `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (verified: `grep -c "Invoke-FullReleaseFlow.ps1" scripts/powershell/PoshQC/settings/pester.runsettings.psd1` = 0; and the canonical coverage artifact `artifacts/pester/powershell-coverage.xml` never mentions the file).
- **Expected behavior:** `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` is added as a new entry in `CodeCoverage.Path`, with a comment following the file's existing comment style (see the Issue #214/#272/#275 precedent comments already in the file), so the canonical artifact measures real per-file coverage for this production file going forward.
- **Verification command:** After the change, re-run `Invoke-PoshQCTest -Root . -ScanFolders @('tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1') -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and confirm `artifacts/pester/powershell-coverage.xml` now reports a non-zero, per-file line-coverage number for `Invoke-FullReleaseFlow.ps1`, and that this number is `>= 85%` (an independent diagnostic re-run during this review measured 93.75% line coverage for this file under the same test scope, so a value at or above that is expected; a materially lower canonical number would itself be a new finding requiring investigation).
- **Separately track (do not block this remediation on):** branch coverage (`mb`/`cb`) is not populated by the repo's Pester `CoverageGutters`/JaCoCo exporter for **any** PowerShell file, confirmed both in the canonical artifact and in this review's diagnostic re-run. This is a repo-wide tooling gap, not unique to this file or this PR. Recommend opening a separate, dedicated investigation (not scoped to issue #298) into why the exporter never populates branch data, since it blocks affirmative branch-coverage verification (`>= 75%` per `.claude/rules/quality-tiers.md`) for every PowerShell change reviewed under this policy, not only this one.

---

## Do Not Do

- Do not modify `ConvertTo-CommandResult`'s parameter type, mandatory-ness, or any other function signature in `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` beyond what is already merged (the `[AllowEmptyCollection()]` fix is correct and complete; do not re-touch it).
- Do not weaken, remove, or skip any of the 26 currently-passing tests (including the new empty-array test) while splitting the test file.
- Do not lower the coverage threshold, add a suppression, or otherwise weaken `pester.runsettings.psd1`'s `CoveragePercentTarget` or thresholds to work around the gap; the fix is to correctly measure the file, not to relax the gate.
- Do not silently narrow remediation scope to "AC-only" — the two Blocking findings are policy-audit findings independent of the AC wording (all 5 AC items already PASS) and must still be addressed for merge readiness.
- Do not attempt to fix the repo-wide branch-coverage exporter gap as part of this remediation cycle unless explicitly directed to do so; track it as a separate item per Fix 2 above, since it is out of proportion to this narrow two-file bugfix and affects the whole repository, not just this PR.
- Do not modify `.github/instructions/*.md`, `.claude/rules/*.md`, or any other policy document.

---

## Verification Commands Summary (for `atomic-executor` preflight and post-execution QA loop)

```powershell
# File size check (Fix 1)
(Get-Content tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | Measure-Object -Line).Lines

# Full toolchain re-run after both fixes (format -> analyze -> test)
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCFormat -Root (Get-Location).Path -ScanFolders @('scripts/dev-tools/Invoke-FullReleaseFlow.ps1','tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1')
Invoke-PoshQCAnalyze -Root (Get-Location).Path -ScanFolders @('scripts/dev-tools/Invoke-FullReleaseFlow.ps1','tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1') -SettingsPath (Join-Path (Get-Location).Path 'scripts/powershell/PoshQC/settings/pssa.settings.psd1')
Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1') -SettingsPath (Join-Path (Get-Location).Path 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1')

# Coverage check (Fix 2) — after adding the file to CodeCoverage.Path
Select-String -Path artifacts/pester/powershell-coverage.xml -Pattern "Invoke-FullReleaseFlow"
```

Expected post-remediation outcome: both `wc -l`/line-count check passes (`<= 500` for the test file), and `artifacts/pester/powershell-coverage.xml` reports non-zero, `>= 85%` line coverage for `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, with all 26 (or more, if the split adds no new tests) existing tests still passing.
