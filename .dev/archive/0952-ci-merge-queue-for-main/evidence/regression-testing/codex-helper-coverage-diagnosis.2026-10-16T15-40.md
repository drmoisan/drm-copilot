# Codex helper coverage observation record (remediation cycle 1, R1, Phase 1)

Timestamp: 2026-10-16T15-40
Task: [P1-T6]
Command: P1-T1 `git grep -n -e "enforce-epic-merge-gate.ps1" -e "enforce-epic-merge-gate-command.ps1" -- tests/scripts`; P1-T2 `git grep -n -e "function Get-EpicMergeGateSelectorPrNumber" -e "function ConvertFrom-EpicMergeGateSelector" -e "function Test-EpicMergeGateCommandInScope" -e "function Get-CodexMergeCommandPrNumber" -- .claude .codex extensions tests scripts`; P1-T3 `git grep -n -e "UseBreakpoints" -- scripts/powershell/PoshQC config`; P1-T4 and P1-T5 reads as recorded in uncovered-line-map.2026-10-16T15-40.md and mergequeue-setup-compare.2026-10-16T15-40.md
EXIT_CODE: 0
Gating: NONE
Output Summary:
STATIC_CAUSE=NOT-DETERMINED-STATICALLY
Inputs: MQ_SUITE_LOAD=IN_PROCESS (codex-helper-loads.2026-10-16T15-38.md); TEST_TREE_DEFINITIONS=0 and DEFINITION_SET_MATCHES=true (helper-definitions.2026-10-16T15-39.md)
NOT_DRIVEN=68, 160, 161, 166
DRIVEN_BUT_REPORTED_UNCOVERED=63, 64, 173, 176, 177, 178, 179, 180, 183

## Decision rule (first match wins)

1. `CONFIRMED:child-process-load` when MQ_SUITE_LOAD=CHILD_PROCESS: not matched (IN_PROCESS).
2. `CONFIRMED:test-tree-definition` when TEST_TREE_DEFINITIONS > 0: not matched (0).
3. `CONFIRMED:extra-definition` when DEFINITION_SET_MATCHES=false with TEST_TREE_DEFINITIONS=0: not matched (true).
4. Otherwise `NOT-DETERMINED-STATICALLY`: matched.

## Hypotheses carried to CI

- H1 (unresolved path form): every Codex in-process load of the gate passes an unresolved `Join-Path` result (CODEX_GATE_RESOLVED_LOADS=0), whereas the Claude suites pass a `Resolve-Path` result. The Claude load form applied by P2-T1 (new suite) and P2-T3 (merge-queue suite line 34) removes this difference.
- H2 (helper functions resolved from another file): tested by the provenance case added by P2-T2 (`resolves the selector helper functions from the Codex helper file`), evaluated in CI by ORCH-R1 (job `poshqc / PowerShell QC`) and ORCH-R2 (job `poshqc / PowerShell hook suites (Linux)`).

## Lines

- NOT_DRIVEN (no Codex case reached them before this cycle): 68, 160, 161, 166.
- DRIVEN_BUT_REPORTED_UNCOVERED (reached by Codex in-process cases, reported uncovered on R_final 38899600487): 63, 64, 173, 176, 177, 178, 179, 180, 183.
- All thirteen lines are reached in-process by the suite P2-T1 creates (Appendix R.2(a)).

## Statements

- The STATIC_CAUSE value changes no later task.
- The scoped coverage run and the `(Get-Command Get-EpicMergeGateSelectorPrNumber).ScriptBlock.File` observation of remediation-inputs R1 step 1 are not performed locally (the executor cannot run Pester or PowerShell directly, and no coverage value is taken from a local MCP run); they are replaced by the provenance case of P2-T2 and the CI per-line data of ORCH-R3.
- No coverage exclusion, no threshold change, and no edit to `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` or `config/poshqc-coverage.json` is made.
