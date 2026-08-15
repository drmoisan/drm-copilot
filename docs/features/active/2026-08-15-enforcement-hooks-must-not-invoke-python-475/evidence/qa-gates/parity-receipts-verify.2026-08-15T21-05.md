# QA Gate — Receipt and Optional-Key Parity Modules (P4-T6) — Issue #475

Timestamp: 2026-08-15T21-05

Command:

1. `mcp__drm-copilot__run_poshqc_format` with `scan_folders: [".claude/lib/orchestrator-state", "tests/scripts/claude-lib/orchestrator-state"]`
2. `mcp__drm-copilot__run_poshqc_analyze` with the same narrowing
3. `mcp__drm-copilot__run_poshqc_test` with `scan_folders: ["tests/scripts/claude-lib/orchestrator-state"]`
4. `Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-lib/orchestrator-state') -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'`

`scan_folders` is narrowed to the orchestrator-state test folder so the guard's
repository-scan `It`s — legitimately red from Phase 1 until Phase 11 — are not pulled
into this gate. The default scan set in `config/poshqc-scan.json` includes
`tests/scripts/claude-runtime/`, which would have included them.

EXIT_CODE: 0

Output Summary:

- **Format**: clean and idempotent on re-run (zero files changed on the second pass).
- **Analyze**: 0 findings.
- **Tests**: **160 passed, 0 failed, 0 skipped** across the six suites in the folder.
  Of these, 74 are new: 32 in `OrchestratorStateReceipts.Tests.ps1`, 24 in
  `OrchestratorStateModelReceipts.Tests.ps1`, and 18 in
  `OrchestratorStateCheckpointValue.Tests.ps1`. The three pre-existing suites
  (`OrchestratorState.Manifest.Tests.ps1`, `OrchestratorState.Tests.ps1`,
  `OrchestratorStateCompletion.Tests.ps1`) remain green and unmodified.
- **Coverage** (read from `artifacts/pester/powershell-coverage.xml`, not inferred from
  the exit code):

| File | Metric | Covered | Missed | Percent | Floor | Status |
| --- | --- | --- | --- | --- | --- | --- |
| `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` | LINE | 112 | 0 | **100.00%** | >= 85% | Met |
| `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` | INSTRUCTION | 169 | 0 | 100.00% | — | — |
| `.claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1` | LINE | 90 | 0 | **100.00%** | >= 85% | Met |
| `.claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1` | INSTRUCTION | 145 | 0 | 100.00% | — | — |
| `.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1` | LINE | 36 | 0 | **100.00%** | >= 85% | Met |
| `.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1` | INSTRUCTION | 72 | 0 | 100.00% | — | — |

Branch coverage is NOT emitted by this toolchain. Pester 5's JaCoCo exporter records no
`BRANCH` counter and leaves every `<line>` `mb`/`cb` attribute at zero; this was
established with proof in `evidence/baseline/baseline-poshqc-test.2026-08-15T19-16.md`
and restated in `evidence/qa-gates/discovery-module-verify.2026-08-15T20-15.md`. The 75%
branch floor cannot be measured from this instrument. No threshold is relaxed; the figure
is unavailable at the instrument level.

As established at `[P2-T8]`, the MCP `run_poshqc_test` tool resolves its Pester settings
from bundled extension resources rather than the repository working tree, so newly
registered coverage targets do not appear in the report that tool produces. The numeric
coverage above was therefore produced by invoking the repository's own PoshQC entry point
with the repository's settings file (command 4), exactly as `[P2-T8]` did. The
coverage-target registration was mirrored into
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` so
`tests/scripts/dev_tools/test_poshqc_bundled_parity.py` stays green; `diff` confirms the
two files are byte-identical.

## Gate Hashes:

SHA-256 for every production module verified by this gate. These are the baseline
reference points P15-T10 compares against.

```
.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 = E8E3411553CA290E181B4A31A2029EBFCE9B529C184857CA8630196065E6CFF2
.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1 = 59D0C4801DF269D074CE673F51B947BBDCCA291B90902B29FD06AE3C9A7F9D5D
.claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1 = 798B6761BFB9F7F1E8C8CF17F483919694478AA4D0422EFF45F2C3F7C0E3FBEA
```

## Parity Coverage — 30 of 30 inventory rows in scope for this phase

| Family | Rows | Module | Failing fixture per row | Passing fixture |
| --- | --- | --- | --- | --- |
| U5 (delegation_receipts) | U5.1-U5.8 (8) | `OrchestratorStateReceipts.psm1` | yes, exact string | yes (list form and object form) |
| U6.R (remediation_loop) | U6.R1-U6.R4 (4) | `OrchestratorStateReceipts.psm1` | yes, exact string | yes |
| U6.H (human_interaction) | U6.H1-U6.H5 (5) | `OrchestratorStateReceipts.psm1` | yes, exact string | yes |
| U6.C (complexity_assessments) | U6.C1-U6.C7 (7) | `OrchestratorStateModelReceipts.psm1` | yes, exact string | yes |
| U6.M (model_routing_receipts) | U6.M1-U6.M6 (6) | `OrchestratorStateModelReceipts.psm1` | yes, exact string | yes |

No row is deferred, scoped out, or recorded as a follow-up.

Formula reuse (U6.C5 / U6.M4) is asserted, not assumed: the suite mocks
`Get-ComplexityFloor` and `Resolve-DelegationModel` inside the
`OrchestratorStateModelReceipts` module scope and proves the mocked result reaches the
error text, plus a `Should -Invoke ... -Times 1 -Exactly` on each. An inline
re-implementation would ignore the mock and fail both assertions. Neither formula is
duplicated; both are called from `.claude/lib/model-routing/ModelRouting.psm1`.

## Declared Deviation — pre-authorized production split (three modules, not two)

`[P4-T2]` as first drafted produced a single 649-line module, over the repository's hard
500-line file cap. The plan's Module Decomposition section pre-authorizes exactly one
remedy: "a sibling helper `.psm1` in the same folder with its own sibling test file".
That remedy was applied. The seven shared checkpoint-value primitives (JSON shape
predicates, the absent-versus-null member accessor, ordinal key sorting, Python
zero-equivalence, and the `str()`/`repr()` renderers) were extracted into
`.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1` (273 lines) with
its own sibling suite. `OrchestratorStateReceipts.psm1` is now 408 lines. An eighth
primitive, `Get-CheckpointObjectMemberName`, was added during verification because
enumerating `$Owner.PSObject.Properties.Name` throws under `Set-StrictMode` when a JSON
object carries zero properties.

Consequence for the change budget: Phase 4 touches three production `.psm1` files plus the
settings `.psd1`, rather than the two-plus-settings the Change-Budget Accounting
anticipated. The phase was therefore executed as two internal batches, following the
precedent the plan sets for Phase 12 ("this same deletion is repeated at each internal
batch boundary within the phase"): batch A wrote `OrchestratorStateCheckpointValue.psm1`
and `OrchestratorStateReceipts.psm1` with their two suites; batch B wrote
`OrchestratorStateModelReceipts.psm1`, the settings registration, and the third suite.
Each batch is within the 3-production / 3-test cap. No `CLAUDE_POWERSHELL_BUDGET_*` cap
override was used. `.claude/state/` does not exist in this worktree, so no budget state
file was present at any boundary.

## Acceptance

- Suites green: yes (160/160, zero failures).
- Numeric coverage recorded from the coverage XML: yes (100.00% line on all three modules).
- Floors met: line floor met with 15.00 points of headroom on every module; branch
  unmeasurable by this instrument, recorded with proof.
- `Gate Hashes:` block present with one SHA-256 line per production module verified by
  this gate: yes (three lines).
