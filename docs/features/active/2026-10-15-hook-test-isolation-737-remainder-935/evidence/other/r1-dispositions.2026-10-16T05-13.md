# R1 Dispositions for CR-N4, CR-N6 and CR-N7 (P1-T4)

Timestamp: 2026-10-16T05-13
Command: git diff --quiet HEAD -- tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1
EXIT_CODE: 0
Output Summary: exit code 0; the CR-N4 and CR-N7 files are not edited in this cycle.

CR-N4: NO-CHANGE. The `AC-5b variable-built hook-load report <Surface>` and `F-3 non-vacuity <Surface> reports at least one variable-built hook load` rows (Discovery suite lines 164-185) keep separate collection. Removing the duplicate read requires either state shared across It blocks (a `BeforeAll` or script-scope collection, which main-plan P5-T2 excluded by requiring the non-vacuity row to share no state with the `AC-5b` row), or moving the collection into `BeforeDiscovery` -ForEach data, where a throw fails discovery of the whole file instead of the `{ ... } | Should -Not -Throw` assertion of the `AC-5b` row, contradicting spec line 178 (`AC-5b` never fails). Repeated parses are already avoided by the `$script:EpicStateParseCache` memo; only file reads repeat.

CR-N6: CHANGED. The 26 column-0 lines `$script:UnderTest = Join-Path $PSScriptRoot 'hooks/enforce-x.ps1'` (Branches lines 52, 81, 97, 113, 153, 168; Predicate lines 87, 112, 137, 165, 198, 223, 247, 271; legacy guard lines 42, 57, 87, 103, 119, 135, 155, 171, 187, 202, 218, 233) each sit directly below `    BeforeAll {` and directly above a line indented by eight spaces, inside here-string fixtures. The guard reads fixtures through the parsed AST; no helper reads line indentation (`Extent.Text` is read only for single elements, `EpicStateIsolation.Helpers.ps1` lines 51 and 106 and `EpicStateIsolation.Compliance.Helpers.ps1` lines 49 and 70), no row asserts a column, and none of the three suites applies a text replacement to these fixtures. Prefixing eight spaces therefore leaves fixture semantics unchanged; the change is applied (P1-T3).

CR-N7: NO-CHANGE. The split suites keep the original Describe titles (`enforce-prd-feature-before-planner.CallTarget.Tests.ps1` line 22, `enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1` line 16) because spec AC-14, AC-15 and AC-16 require unchanged test names and Pester full names include the Describe title. The code review states no change is required.

Executor observation: the column-0 line numbers observed before the P1-T3 edit were Branches 52 81 97 113 153 168; Predicate 87 112 137 165 198 223 247 271; legacy guard 42 57 87 103 119 135 155 171 187 202 218 233, matching the cited numbers.
