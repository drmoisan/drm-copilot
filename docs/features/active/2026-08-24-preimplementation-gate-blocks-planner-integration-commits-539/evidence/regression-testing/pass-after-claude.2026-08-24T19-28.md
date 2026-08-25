# Pass-After Run — Claude side — issue #539 [P2-T5]

Timestamp: 2026-08-24T19-28

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adcd2df193c6616e5` and `scan_folders = ["tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1", "tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1"]`

Coverage extraction command: `python <scratchpad>/cov_extract.py artifacts/pester/powershell-coverage.xml preimplementation`

EXIT_CODE: 0

Raw result:

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-adcd2df193c6616e5","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-adcd2df193c6616e5' with 2 selected scan folder(s)."}
```

## Test result

JUnit summary element from `artifacts/pester/pester-junit.xml` (report `Pester (08/24/2026 19:28:17)`):

```
<testsuites name="Pester" tests="93" errors="0" failures="0" disabled="0" time="2.008">
```

Per-suite:

| Suite | Tests | Failures | Errors | Skipped |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 58 | 0 | 0 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | 35 | 0 | 0 | 0 |

- All **58** cases of the new #539 suite pass, including all eight allow cases of [P1-T1](a),
  the four mixed-pathspec deny cases, the D4 row-by-row deny table, and the here-string deny
  case. These are the same 58 cases that failed their allow half against the unfixed hook in
  the [P1-T2] fail-before evidence.
- All **35** cases of the pre-existing Claude suite pass with no modification to any of its
  assertions.
- Failing-testcase enumeration over the JUnit document returned 0.

### D4 row 14 carried constraint — satisfied

The row-14 re-selected exemplars (an env-style prefix, plus three chained lines pairing a
relocating spelling with a trigger-matching exempt segment) pass. They are satisfied by the
all-segments reading implemented in `Test-ExemptOrchestrationStagingCommand`: once the
exemption is consulted, the predicate denies unless EVERY segment of the chained line parses
as a fully recognized, all-operands-exempt invocation, not only the segments the trigger regex
itself matched. No test assertion was weakened.

## Coverage (numeric, per-file line coverage, keyed on package element)

Extracted from `artifacts/pester/powershell-coverage.xml` by the enclosing `package` element
plus the `class` element, never by bare filename.

| Package element | Source file | LINE covered | LINE total | Line coverage |
| --- | --- | --- | --- | --- |
| `<worktree>/.claude/hooks` | `enforce-orchestration-preimplementation-gate.ps1` | 101 | 112 | **90.2%** |
| `<worktree>/.codex/hooks` | `enforce-orchestration-preimplementation-gate.ps1` | 0 | 122 | 0.0% (scoping artifact — no Codex suite in this scan set) |
| `<worktree>/.claude/hooks` | `enforce-orchestration-preimplementation-gate-helpers.ps1` | — | — | **NOT INSTRUMENTED IN THIS RUN** (see below) |

**Canonical Claude hook: 90.2% (101/112), above the uniform 85% line threshold and above its
[P0-T8] baseline of 90.0% (99/110). No coverage regression on the changed file.**

## Deviation — the new helper is not yet in the effective coverage allow-list

Only one of the two numeric coverage values required by [P2-T5]'s acceptance is obtainable at
this point in the plan. The cause is a defect in the plan preamble's coverage mechanism, not in
the batch-1 implementation.

Evidence, in the order it was established:

1. The #539 helper is absent from the JaCoCo report. The only `gate-helpers` occurrences in
   `artifacts/pester/powershell-coverage.xml` are `enforce-parallel-drift-gate-helpers.ps1`,
   an unrelated file.
2. [P2-T3]'s entry is present in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
   and is the ONLY difference between the two runsettings copies (`diff` of the self-hosted
   copy against `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
   reports exactly the four added lines 199-202 and nothing else).
3. The MCP test tool runs the BUNDLED PoshQC module, and that module resolves its settings from
   its own module root:
   `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1` line 3 reads
   `$script:PesterSettings = Join-Path $ModuleRoot 'settings/pester.runsettings.psd1'`.
   The effective allow-list for every MCP-invoked run is therefore the BUNDLED copy, which does
   not yet carry the helper entry.
4. The precedent entry `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` sits at line 175
   of BOTH copies and does appear in the report, which corroborates that a helper sibling is
   measured once, and only once, the bundled copy lists it.

Consequence and remedy, both already inside the approved plan: [P4-T3] applies the identical
coverage-entry hunks from [P2-T3] and [P3-T3] to the bundled mirror. From that task onward both
helpers are instrumented, so [P7-T3] can record all four numeric per-file values and [P7-T4]
can perform the threshold comparison. No plan change is required; the plan self-heals at its
final coverage gate. This deviation is carried forward to the completion report.

The helper is fully exercised by this run despite not being measured: all 58 cases of the new
suite drive `Test-ExemptOrchestrationStagingCommand`, which lives in the helper, and the hook
dot-sources it at load.

Output Summary: PASS. Exit code 0. 93 tests, 0 failures, 0 errors across 2 suites; all 58 #539
cases green on the Claude side and the entire 35-case pre-existing suite green with unmodified
assertions. Numeric per-file line coverage for `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
is 90.2% (101/112), above the 85% threshold and above the 90.0% baseline. The second required
numeric value, for `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, is
UNAVAILABLE at this phase because the MCP runner reads the bundled runsettings copy, which the
in-plan task [P4-T3] updates; recorded above as a deviation with its evidence and its in-plan
remedy.
