# QA Gate — Routing Contract (P8-T4) — Issue #475

Timestamp: 2026-08-15T23-00

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
- **Analyze**: 0 findings, first pass.
- **Tests**: **341 passed, 0 failed, 0 skipped** across the eleven suites in the folder.
  Of these, 37 are new in this phase, all in
  `OrchestratorStateRoutingContract.Tests.ps1`. Every suite from Phases 4, 6, and 7
  remains green.
- **Coverage** (read from `artifacts/pester/powershell-coverage.xml`, not inferred from
  the exit code):

| File | Metric | Covered | Missed | Percent | Floor | Status |
| --- | --- | --- | --- | --- | --- | --- |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` | LINE | 105 | 1 | **99.06%** | >= 85% | Met |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` | INSTRUCTION | 175 | 3 | 98.31% | — | — |

Branch coverage is NOT emitted by this toolchain (Pester 5's JaCoCo exporter records no
`BRANCH` counter), established with proof in
`evidence/baseline/baseline-poshqc-test.2026-08-15T19-16.md`. No threshold is relaxed.

The numeric coverage was produced by the repository's own PoshQC entry point (command 4)
for the reason recorded at `[P2-T8]`. The registration was mirrored into the bundled
settings resource; `diff` confirms the two settings files remain byte-identical.

File sizes are within the 500-line cap: `OrchestratorStateRoutingContract.psm1` 428
lines, `OrchestratorStateRoutingContract.Tests.ps1` 311 lines. No split was required.

## Gate Hashes:

SHA-256 for every production module verified by this gate. These are the baseline
reference points P15-T10 compares against.

```
.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1 = D5A41B64112EA37CDD34D884DBBAB3D20C0585AB7114D4FD8EED973A1BF566CE
```

## Parity Coverage — 14 of 14 inventory rows in scope for this phase

| Row | Check | Failing fixture asserting the exact string |
| --- | --- | --- |
| C6.1 | routing matrix missing routes object | yes, two shapes (absent, non-mapping) |
| C6.2 | no route selected | yes, two shapes (absent, blank) |
| C6.3 | selected route has no matrix entry | yes, plus a `path_selected` resolution fixture |
| C6.4 | `required_agents` must match | yes, plus absent-list, wrong-order, and malformed-list fixtures |
| C6.5 | `required_skills` must match | yes |
| C6.6 | `required_mcp_tools` must match | yes |
| C6.7 | missing required agent receipt | yes, plus an object-namespace acceptance fixture |
| C6.8 | missing required skill receipt | yes, plus `required: false` and blank-evidence fixtures |
| C6.9 | missing successful MCP receipt | yes, plus an `ok: false` fixture |
| C6.10 | `local_execution_overrides` empty-list rules | yes, **both variants** plus the absent-key case |
| C6.11 | `delegation_bypasses` empty-list rules | yes, **both variants** |
| C6.12 | `lifecycle_operations` list shape | yes, plus absent and null non-firing fixtures |
| C6.13 | non-object lifecycle operation | yes, with index |
| C6.14 | lifecycle operation not on the MCP surface | yes, with index, plus a no-surface fixture |

No row is deferred, scoped out, or recorded as a follow-up. A fully-valid checkpoint on
the remediation route is the family passing fixture and returns zero errors.

Both message variants of C6.10 and C6.11 are asserted, as the plan requires:
`must be an empty list at completion.` for a non-list or absent key, and
`must be empty at completion.` for a present non-empty list. The absent-key case
producing the FIRST variant is the Python present-key semantics and is pinned by test;
it is deliberately stricter than the PR-creation-readiness analogue in
`OrchestratorState.psm1`, which tolerates absence. Both behaviours are preserved as-is.

## Bug-promotion tool substitution

Five fixtures cover the substitution, in both directions:

1. `promotion-type: "bug"` declaring `new_potential_entry` fails both the list-equality
   row (C6.6) and the receipt row (C6.9), and the C6.9 error names
   `new_potential_bug_entry`, not `new_potential_entry`.
2. The same checkpoint declaring `new_potential_bug_entry` passes the list-equality row.
3. `promotion-type: "feature"` is unaffected and still expects `new_potential_entry`.
4. An absent `promotion-type` is unaffected, preserving legacy checkpoints.
5. Substitution preserves matrix order and every other tool, asserted by showing that a
   satisfied non-promotion tool is not reported missing.

Row C6.1 is reachable in the portable path only through the optional `-RoutingMatrix`
override, which mirrors the Python `routing_matrix` keyword. Under PD-1 the default
matrix is a pinned constant that always carries a routes mapping, so without the override
the row could not be exercised. The override never reads from disk.

## Uncovered lines

One line in `OrchestratorStateRoutingContract.psm1` is uncovered (99.06% line coverage,
14.06 points above the 85% floor): the early return inside
`Get-CheckpointNonBlankStringList` for a non-list value, which the three call sites reach
through the combined `-not $actual.Ok` condition rather than the isolated branch. The
behavior it guards is covered by the malformed-declared-list fixture. No assertion was
weakened and no threshold was relaxed.

## Acceptance

- Suite green: yes (341/341, zero failures).
- Numeric coverage recorded from the coverage XML: yes (99.06% line).
- Floors met: line floor met with 14.06 points of headroom; branch unmeasurable by this
  instrument, recorded with proof.
- `Gate Hashes:` block present with one SHA-256 line per production module verified by
  this gate: yes (one line).
