# QA Gate — Codex Resolver Ports (P5-T6) — Issue #475

Timestamp: 2026-08-15T21-40

Command:

1. `mcp__drm-copilot__run_poshqc_format` with `scan_folders: [".claude/lib/codex-routing", "tests/scripts/claude-lib/codex-routing"]`
2. `mcp__drm-copilot__run_poshqc_analyze` with the same narrowing
3. `mcp__drm-copilot__run_poshqc_test` with `scan_folders: ["tests/scripts/claude-lib/codex-routing"]`
4. `Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-lib/codex-routing') -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'`

`scan_folders` is narrowed to the codex-routing test folder so the guard's
repository-scan `It`s — legitimately red from Phase 1 until Phase 11 — are not pulled
into this gate.

EXIT_CODE: 0

Output Summary:

- **Format**: clean and idempotent on re-run (zero files changed on the second pass).
- **Analyze**: **0 findings**. Five findings raised during authoring were corrected, not
  suppressed: two `PSAvoidAssignmentToAutomaticVariable` on `$profile` in
  `CodexDeployment.psm1` (renamed to `$deploymentProfile`); one
  `PSUseShouldProcessForStateChangingFunctions` on the pure receipt builder in
  `CodexTopology.psm1` (renamed `New-CodexOrchestratorReceipt` to
  `Get-CodexEscalationReceipt`); and two `PSUseOutputTypeCorrectly` (declared the
  additional `[object[]]` return shape produced by the unary-comma emit form, and
  removed the unnecessary comma from `Get-CodexForcedRootPersona`).
- **Tests**: **63 passed, 0 failed, 0 skipped** across the two new parity suites
  (`CodexDeployment.Parity.Tests.ps1`, `CodexTopology.Parity.Tests.ps1`).
- **Coverage** (read from `artifacts/pester/powershell-coverage.xml`, not inferred from
  the exit code):

| File | Metric | Covered | Missed | Percent | Floor | Status |
| --- | --- | --- | --- | --- | --- | --- |
| `.claude/lib/codex-routing/CodexDeployment.psm1` | LINE | 67 | 0 | **100.00%** | >= 85% | Met |
| `.claude/lib/codex-routing/CodexDeployment.psm1` | INSTRUCTION | 100 | 0 | 100.00% | — | — |
| `.claude/lib/codex-routing/CodexTopology.psm1` | LINE | 108 | 0 | **100.00%** | >= 85% | Met |
| `.claude/lib/codex-routing/CodexTopology.psm1` | INSTRUCTION | 146 | 0 | 100.00% | — | — |

Branch coverage is NOT emitted by this toolchain (Pester 5's JaCoCo exporter records no
`BRANCH` counter), established with proof in
`evidence/baseline/baseline-poshqc-test.2026-08-15T19-16.md`. No threshold is relaxed.

The numeric coverage was produced by the repository's own PoshQC entry point (command 4)
for the reason recorded at `[P2-T8]`: the MCP tool resolves its Pester settings from
bundled extension resources, so newly registered coverage targets do not appear in its
report. The registration was mirrored into
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`;
`diff` confirms the two settings files remain byte-identical.

File sizes are within the 500-line cap: `CodexDeployment.psm1` 312 lines,
`CodexTopology.psm1` 392 lines. No production split was required in this phase.

## Gate Hashes:

SHA-256 for every production module verified by this gate. These are the baseline
reference points P15-T10 compares against.

```
.claude/lib/codex-routing/CodexDeployment.psm1 = BDDEACA7C27C947F8F8A09CE5A6666A5E7BBFADA1475AE9B5613F3B1CAF4DAA2
.claude/lib/codex-routing/CodexTopology.psm1 = 3DAC4066A75AF1788D6812483B41D89C9EB39B02B672DE2190DDA3DE0158B520
```

## Parity Coverage — the two resolver ports

These modules are ports of Python functions, not inventory check rows; the rows they
enable (U6.X and U6.T) are Phase 6's scope. Behavioral surface covered:

| Surface | `resolve_codex_deployment.py` | `resolve_codex_topology.py` |
| --- | --- | --- |
| Full profile / budget table | 4 bands plus the elevated profile | 4 languages plus the no-budget case |
| Branch coverage of the routing rule | all 4 C3-overlay branches, both forced personas, alias and non-alias families | all 7 escalation reasons plus 3 precedence-ordering assertions, the small route, and the epic route |
| Invalid-input throws | 4 distinct `ValueError`-equivalent messages, exact text, plus type assertion | 6 distinct `ValueError`-equivalent messages, exact text, plus type assertion |
| Non-ValueError surface | `ModelUnavailableError` equivalent asserted to be a distinct exception type so U6.X5 does not catch it | n/a |
| Resolved-key contract | exactly the 9 keys U6.X11 compares | exactly the 12 keys U6.T11 compares |

Exception-message text is asserted character-for-character, including the Python tuple
rendering `('C1', 'C2', 'C3', 'C4')` and `('epic_execution_child',
'epic_preparation_child', 'standalone')` and the `repr()` quoting of the offending value,
because rows U6.X5 and U6.T10 interpolate that text verbatim into a checkpoint error
string.

## Declared Divergence (documented in the CodexTopology module header)

Python raises `TypeError` — which the receipt validator does not catch — when `languages`
is not iterable. This port treats a null `Language` argument as an empty collection,
routing to the `unsupported_language` escalation. The difference is unreachable from the
U6.T checks, which reject a non-list `languages` before the resolver is called. No check
is weakened by this.

## Acceptance

- Suites green: yes (63/63, zero failures).
- Numeric coverage recorded from the coverage XML: yes (100.00% line on both modules).
- Floors met: line floor met with 15.00 points of headroom on both modules; branch
  unmeasurable by this instrument, recorded with proof.
- `Gate Hashes:` block present with one SHA-256 line per production module verified by
  this gate: yes (two lines).
