# Deny-Token Assertion Stability (P3-T15)

Timestamp: 2026-10-08T22-36
Command: sh SCRATCH/run-ps.sh SCRATCH/removed-lines-scan.ps1 -BaseRef 497cb504ad9a4e5435dc8946333ebc28baea50c4 -Token 'ROUTING_CONTRACT_BLOCKED,MODEL_ROUTING_BLOCKED' -File .claude/hooks/validate-orchestrator-output.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1
EXIT_CODE: 0
Output Summary: REMOVED-TOKEN-SUMMARY count=0 files=4

No line carrying `ROUTING_CONTRACT_BLOCKED` or `MODEL_ROUTING_BLOCKED` was removed from HOOK or from the three existing suites relative to INTEGRATION_SHA (497cb504). The existing assertions on those tokens are unedited, and they pass in P3-T11.

Result: PASS.
