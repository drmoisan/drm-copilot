# Must-Not-Regress Roll-Up (issue #671)

Timestamp: 2026-09-17T08-30
Task: [P6-T6]
Command: node and suite selections over `artifacts/pester/pester-junit.xml` from the [P6-T3] full run (LastWriteTime 2026-09-17T08:27:34), scoped to `classname` / `name` values ending with each suite's forward-slash-normalized repository-relative path, read by a scratchpad parser under pwsh 7.6.6
EXIT_CODE: 0

Output Summary:
- All asserted nodes: match count 1, status `Passed`.
- All three mode suites are present, each with failures=0 and errors=0.

## Asserted nodes

| Suite | It label | Matches | status |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | `blocks implementation writes when route metadata and lifecycle readiness are absent (generalized message)` | 1 | Passed |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | `blocks an implementation write when the checkpoint omits the feature folder` | 1 | Passed |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | `allows staging an epic document under the epics tree` | 1 | Passed |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | `allows a chained two-segment line whose every segment is independently exempt` | 1 | Passed |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | `allows staging an epic document under the epics tree` | 1 | Passed |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | `allows a chained two-segment line whose every segment is independently exempt` | 1 | Passed |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | `keeps the canonical hooks byte-identical to their bundled copies` | 1 | Passed |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | `parse-checks each root and bundled hook and keeps every file within 500 lines` | 1 | Passed |

## Mode suites

| Suite | testsuite matches | tests | failures | errors | skipped | disabled |
| --- | --- | --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | 1 | 87 | 0 | 0 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | 1 | 55 | 0 | 0 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1` | 1 | 11 | 0 | 0 | 0 | 0 |

Additional context from the same run: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` tests=43 failures=0; `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` tests=35 failures=0.
