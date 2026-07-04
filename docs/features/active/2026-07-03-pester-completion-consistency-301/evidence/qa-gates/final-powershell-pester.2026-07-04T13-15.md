# Final PowerShell Pester Run — Remediation Cycle 2 (Post-Fix, Coverage-Enabled)

Timestamp: 2026-07-04T13-15

## Correction Notice

An earlier draft of this artifact cited `.codex/hooks/enforce-completion-consistency.ps1` = 91.06% and `.codex/hooks/enforce-completion-helpers.ps1` = 93.02%. Those figures were written before the regenerated `artifacts/pester/powershell-coverage.xml` was re-inspected line-by-line and do not match the report. This is a full replacement of that draft with figures verified by direct text search against the regenerated report (re-run twice for reproducibility; both runs produced identical results).

## Tool-Routing Note (carried forward from cycle 1 and this cycle's Phase 0 baseline)

As documented in `evidence/remediation-baseline/baseline-powershell-pester.2026-07-04T13-15.md`, `mcp__drm-copilot__run_poshqc_test` resolves settings from the bundled extension copy of `pester.runsettings.psd1`, which does not include the four in-scope hook files in its `CodeCoverage.Path`. To measure coverage against the repo-root `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unmodified this cycle), the same direct-invocation substitution used in cycle 1 and this cycle's Phase 0 baseline was applied.

Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module './scripts/powershell/PoshQC' -Force; Invoke-PoshQCTest -Root '.' -ScanFolders @('tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1','tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1')"`
EXIT_CODE: 0 (run twice; both runs identical)

Output Summary: 53 tests discovered and executed (`enforce-completion-consistency-codex.Tests.ps1`: 4 tests — the original 2 plus the 2 new byte-identity assertions from P1-T3/P1-T4; `enforce-completion-consistency.Tests.ps1`: 49 tests). Tool output: `Tests Passed: 53, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`. Coverage report regenerated at `artifacts/pester/powershell-coverage.xml` using the retargeted `enforce-completion-consistency-codex.Tests.ps1` (dot-sources the canonical `.codex/hooks/enforce-completion-consistency.ps1` path, which transitively dot-sources the canonical `.codex/hooks/enforce-completion-helpers.ps1`).

## P2-T2: `<sourcefile>` Entry Verification (All Four In-Scope Files)

Command: `grep -n "<sourcefile" artifacts/pester/powershell-coverage.xml`

Matched lines for the four in-scope files (all four now present as `<sourcefile>` entries, closing the pre-fix presence gap):

```
636:    <sourcefile name="enforce-completion-consistency.ps1">    (package: .claude/hooks)
765:    <sourcefile name="enforce-completion-helpers.ps1">         (package: .claude/hooks)
1605:    <sourcefile name="enforce-completion-consistency.ps1">   (package: .codex/hooks)
1734:    <sourcefile name="enforce-completion-helpers.ps1">        (package: .codex/hooks)
```

## P2-T3: Per-File `<counter type="LINE">` Values (Post-Fix, Verified)

Values re-derived directly from the `<class>`-level aggregate `<counter type="LINE">` element immediately preceding each `</class>` close tag in the `.codex/hooks` package (lines 1574-1577 for the hook, 1600-1603 for the helper), which is identical to the corresponding `<sourcefile>`-level aggregate later in the same report (lines 1729-1730 and 1778-1779).

| File | LINE missed | LINE covered | Line % | Evidence line(s) |
|---|---|---|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` | 10 | 113 | 113/123 = 91.87% | line 761 |
| `.claude/hooks/enforce-completion-helpers.ps1` | 3 | 40 | 40/43 = 93.02% | line 810 |
| `.codex/hooks/enforce-completion-consistency.ps1` | 58 | 65 | 65/123 = 52.85% | lines 1575, 1730 |
| `.codex/hooks/enforce-completion-helpers.ps1` | 10 | 33 | 33/43 = 76.74% | lines 1601, 1779 |

**Finding: two of the four in-scope files remain below the 85% line-coverage floor.** `.codex/hooks/enforce-completion-consistency.ps1` (52.85%) and `.codex/hooks/enforce-completion-helpers.ps1` (76.74%) do not meet the >= 85% floor required by `.claude/rules/general-unit-test.md` and `.claude/rules/powershell.md`, despite the Phase 1 retargeting fix. Root cause: the Phase 1 fix retargets *which file path* is dot-sourced (bundled mirror -> canonical), which closes the *measurement-attribution* gap (both files now appear in the coverage report with real, non-zero coverage), but it does not increase the *number of test scenarios* exercised. The `enforce-completion-consistency-codex.Tests.ps1` file has only 2 behavioral `It` blocks (plus the 2 new non-behavioral byte-identity assertions added in Phase 1, which invoke `Get-FileHash` only and do not execute any `Invoke-CompletionConsistencyDecision` code path), versus 49 behavioral `It` blocks in `enforce-completion-consistency.Tests.ps1` for the `.claude/hooks` counterpart. Uncovered methods in the `.codex` hook include `Get-CheckpointFileContent` (0/3 lines), `Resolve-EditedCheckpointContent` (0/15 lines), and partial coverage of `Test-CompletionAsserted` (4/14 lines) and `Get-MissingCompletionEvidence` (27/40 lines) — code paths that the 2 existing Codex behavioral tests do not exercise.

`<counter type="BRANCH">` continues to not appear anywhere in the report (pre-existing Pester/CoverageGutters tooling limitation, out of scope for this cycle, as documented in cycle 1's final evidence).

Output Summary: Coverage-enabled Pester rerun confirms 53/53 tests passing. All four in-scope files now show real, non-zero, individually-measured line coverage (closing the prior 0.00%/0.00% measurement gap for the two `.codex/hooks/*` files), but two of the four (`.codex/hooks/enforce-completion-consistency.ps1` = 52.85%, `.codex/hooks/enforce-completion-helpers.ps1` = 76.74%) remain below the 85% line-coverage floor. The Phase 1 fix as scoped (retarget + 2 byte-identity assertions) resolves the measurement-attribution defect but does not resolve the underlying test-scenario-coverage gap for the Codex hook set. Per this plan's Do-Not-Do list ("Do not mark AC 3 or the overall feature PASS without a coverage artifact that shows all four in-scope files (not two) at or above the coverage floor"), this remains a blocking gap for AC 3, to be recorded honestly in `evidence/qa-gates/coverage-comparison.2026-07-04T13-15.md` and escalated at plan completion rather than misreported as resolved.
