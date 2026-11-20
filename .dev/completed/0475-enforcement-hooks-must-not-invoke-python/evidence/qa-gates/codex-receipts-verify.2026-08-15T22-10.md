# QA Gate — Codex Receipt Validators (P6-T6) — Issue #475

Timestamp: 2026-08-15T22-10

Command:

1. `mcp__drm-copilot__run_poshqc_format` with `scan_folders: [".claude/lib/orchestrator-state", "tests/scripts/claude-lib/orchestrator-state"]`
2. `mcp__drm-copilot__run_poshqc_analyze` with the same narrowing
3. `mcp__drm-copilot__run_poshqc_test` with `scan_folders: ["tests/scripts/claude-lib/orchestrator-state"]`
4. `Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-lib/orchestrator-state') -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'`

`scan_folders` is narrowed to the orchestrator-state test folder so the guard's
repository-scan `It`s — legitimately red from Phase 1 until Phase 11 — are not pulled
into this gate.

EXIT_CODE: 0

Output Summary:

- **Format**: clean and idempotent on re-run (zero files changed on the second pass).
- **Analyze**: **0 findings**. One finding raised during authoring was corrected, not
  suppressed: `PSAvoidAssignmentToAutomaticVariable` (Error severity) on
  `$executionContext` in `OrchestratorStateCodexTopologyReceipts.psm1`, a readonly
  PowerShell automatic variable; the local was renamed to `$receiptExecutionContext`.
- **Tests**: **232 passed, 0 failed, 0 skipped** across the eight suites in the folder.
  Of these, 72 are new in this phase: 26 in `OrchestratorStateCodexModelReceipts.Tests.ps1`,
  32 in `OrchestratorStateCodexTopologyReceipts.Tests.ps1`, and 14 added to
  `OrchestratorStateCheckpointValue.Tests.ps1` for the new equality primitive. Every
  suite from Phases 4 and 5 remains green.
- **Coverage** (read from `artifacts/pester/powershell-coverage.xml`, not inferred from
  the exit code):

| File | Metric | Covered | Missed | Percent | Floor | Status |
| --- | --- | --- | --- | --- | --- | --- |
| `.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1` | LINE | 80 | 0 | **100.00%** | >= 85% | Met |
| `.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1` | INSTRUCTION | 118 | 0 | 100.00% | — | — |
| `.claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1` | LINE | 80 | 0 | **100.00%** | >= 85% | Met |
| `.claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1` | INSTRUCTION | 121 | 0 | 100.00% | — | — |
| `.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1` (extended) | LINE | 65 | 0 | **100.00%** | >= 85% | Met |
| `.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1` (extended) | INSTRUCTION | 136 | 2 | 98.55% | — | — |

Branch coverage is NOT emitted by this toolchain (Pester 5's JaCoCo exporter records no
`BRANCH` counter), established with proof in
`evidence/baseline/baseline-poshqc-test.2026-08-15T19-16.md`. No threshold is relaxed.

The numeric coverage was produced by the repository's own PoshQC entry point (command 4)
for the reason recorded at `[P2-T8]`. The registration was mirrored into the bundled
settings resource; `diff` confirms the two settings files remain byte-identical.

File sizes are within the 500-line cap: `OrchestratorStateCodexModelReceipts.psm1` 297
lines, `OrchestratorStateCodexTopologyReceipts.psm1` 298 lines, and the extended
`OrchestratorStateCheckpointValue.psm1` 383 lines.

## Gate Hashes:

SHA-256 for every production module verified by this gate. These are the baseline
reference points P15-T10 compares against.

```
.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1 = EB4B21F22BEAD7189BB12611EABAE23B6EF395308FAD5381BC4BA76217A9BE72
.claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1 = B4695143119153421AC7FAD36B059356D8C6105ECA269F79CDB3AE61DDC675AF
.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 = F23A9E296A17C86CEDF22B34AE8B8D3133E76E02B6BDDD5E7053A598631269AF
```

The third hash supersedes the value recorded for the same file in
`evidence/qa-gates/parity-receipts-verify.2026-08-15T21-05.md`: this phase extended that
module with the shared `Test-PythonValueEqual` primitive, so its content changed. P15-T10
must compare against this later value.

## Parity Coverage — 22 of 22 inventory rows in scope for this phase

| Family | Rows | Module | Failing fixture per row | Passing fixture |
| --- | --- | --- | --- | --- |
| U6.X (codex_model_routing_receipts) | U6.X1-U6.X11 (11) | `OrchestratorStateCodexModelReceipts.psm1` | yes, exact string | yes (single receipt, unchanged-ceiling sequence, evidenced rise) |
| U6.T (codex_topology_receipts) | U6.T1-U6.T11 (11) | `OrchestratorStateCodexTopologyReceipts.psm1` | yes, exact string | yes (small route, escalation with null budgets, forced root persona) |

No row is deferred, scoped out, or recorded as a follow-up.

Row-level notes on the harder rows:

- **U6.X6 through U6.X10** are ordering-dependent: the checks carry the previous
  resolved ceiling across receipts. Fixtures cover a drop (monotonicity violation and
  the proof that it suppresses the transition check for that receipt), transition
  evidence present with no rise, transition evidence present with an unchanged ceiling,
  a rise with no transition, a rise with a non-object transition, a wrong from/to pair,
  and three distinct `affected_delegation_ids` failures (empty, duplicated, non-string).
- **U6.T6** has five fixtures proving the integer-not-boolean rule: a boolean rejected
  for each of the two count keys, a string rejected, a null rejected, and zero accepted.
  This rule exists because Python's `bool` subclasses `int`, so a naive port would accept
  `true` as a file count.
- **U6.X11 and U6.T11** assert Python `repr()` rendering on both sides of a mismatch,
  covering the string, boolean, null, integer, and list value shapes. The list case
  asserts `['powershell']`, the Python list-literal form.

Resolver reuse (U6.X and U6.T) is asserted, not assumed: each suite mocks the resolver
inside the module under test, proves the mocked result reaches the error text, and adds a
`Should -Invoke ... -Times 1 -Exactly`. The topology suite additionally mocks
`Get-CodexForcedRootPersona` to prove the permitted-persona set is read from the resolver
module rather than restated locally. Neither resolver is duplicated.

## Declared Deviation — shared equality primitive added to the Phase 4 helper

Both U6.X11 and U6.T11 compare a checkpoint value against a resolver output using Python
`==` semantics: null equals only null, a boolean never equals its string rendering,
strings compare case-sensitively (PowerShell's default `-eq` does not), and lists compare
element-wise. Implementing that comparison twice would violate the repository's
no-copy-paste rule, so `Test-PythonValueEqual` was added to the shared
`OrchestratorStateCheckpointValue.psm1` helper alongside the other Python-semantics
primitives, and both modules consume it.

Consequence for the change budget: Phase 6 touches three production `.psm1` files (two
new, one extended) plus the settings `.psd1`. As in Phase 4, the phase was executed as two
internal batches so each stays within the 3-production / 3-test cap, following the
precedent the plan sets for Phase 12. No `CLAUDE_POWERSHELL_BUDGET_*` cap override was
used. `.claude/state/` does not exist in this worktree, so no budget state file was
present at any boundary.

## Acceptance

- Suites green: yes (232/232, zero failures).
- Numeric coverage recorded from the coverage XML: yes (100.00% line on all three files).
- Floors met: line floor met with 15.00 points of headroom on every file; branch
  unmeasurable by this instrument, recorded with proof.
- `Gate Hashes:` block present with one SHA-256 line per production module verified by
  this gate: yes (three lines).
