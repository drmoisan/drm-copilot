# P8-T7 Replacement decision for the hard-coded family copy

Timestamp: 2026-10-09T05-46
DECISION: KEEP
Reason: the file `tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1` holds a hard-coded copy of the generated-agent family list. All `AC-19` rows of the new parity test pass (P8-T9), including `AC-19 module set equals the Python authority set` (P8-T4), so the hard-coded copy is redundant but not wrong. It is kept unchanged, and the file is not added to the Phase 8 commit pathspec.
