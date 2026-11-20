# Remediation Cycle 1 - Parity and Legacy Contracts ([P3-T7])

Timestamp: 2026-09-27T05-16

Command: sh <SCRATCHPAD>/x713-parity.sh (R-SCOPED over `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`; launcher `exec pwsh -NoProfile -File "$(dirname "$0")/x713-parity.ps1"`)

EXIT_CODE: 0

Output Summary: Pass 1. PassedCount: 45; FailedCount: 0; FailedBlocksCount: 0; FailedContainersCount: 0. The four required PASSED names are present: `keeps all four surface copies of the helpers module byte-identical by SHA256 hash`, `keeps every surface copy of the helpers module under the 500-line cap`, `parse-checks each root and bundled hook and keeps every file within 500 lines`, `keeps the canonical hooks byte-identical to their bundled copies`. Result: PASS.

## Runner output (count lines and required PASSED lines)

```text
PassedCount: 45
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
PASSED: enforce-orchestration-preimplementation-gate-helpers.ps1 surface parity (issue #671).keeps all four surface copies of the helpers module byte-identical by SHA256 hash
PASSED: enforce-orchestration-preimplementation-gate-helpers.ps1 surface parity (issue #671).keeps every surface copy of the helpers module under the 500-line cap
PASSED: Legacy Codex hooks use native lifecycle contracts.parse-checks each root and bundled hook and keeps every file within 500 lines
PASSED: Legacy Codex hooks use native lifecycle contracts.keeps the canonical hooks byte-identical to their bundled copies
```

FAILED lines: none. The remaining 41 PASSED lines (legacy-codex lifecycle and in-process behaviour tests) are held in `<SCRATCHPAD>/c1-p3-parity.txt`.
