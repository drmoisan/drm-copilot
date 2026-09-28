# Remediation Must-Not-Regress Roll-Up (issue #671, R1)

Timestamp: 2026-09-17T10-09
Task: [P6-T6]
Command: `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/p6-parse.ps1` — reads (D2) the `artifacts/pester/pester-junit.xml` written by the [P6-T3] run (LastWriteTimeUtc 2026-09-17T14:08:49.7997201Z).
EXIT_CODE: 0

Output Summary:

Named nodes (D2 selection; each must match exactly one Passed testcase):

| Suite | Node | Matches | Status |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | `blocks implementation writes when route metadata and lifecycle readiness are absent (generalized message)` | 1 | Passed |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | `blocks an implementation write when the checkpoint omits the feature folder` | 1 | Passed |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | `allows staging an epic document under the epics tree` | 1 | Passed |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | `allows a chained two-segment line whose every segment is independently exempt` | 1 | Passed |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | `allows staging an epic document under the epics tree` | 1 | Passed |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | `allows a chained two-segment line whose every segment is independently exempt` | 1 | Passed |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | `keeps the canonical hooks byte-identical to their bundled copies` | 1 | Passed |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | `parse-checks each root and bundled hook and keeps every file within 500 lines` | 1 | Passed |

Suite totals (each `testsuite` element present exactly once):

| Suite | tests | failures | errors |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | 35 | 0 | 0 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 43 | 0 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | 87 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | 55 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1` | 11 | 0 | 0 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | 56 | 0 | 0 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 12 | 0 | 0 |

Acceptance: all eight named nodes match exactly one Passed testcase; each of the five required suites has a `testsuite` element with `failures` 0 and a numeric `tests` > 0; no required `testsuite` element is absent. PASS.
