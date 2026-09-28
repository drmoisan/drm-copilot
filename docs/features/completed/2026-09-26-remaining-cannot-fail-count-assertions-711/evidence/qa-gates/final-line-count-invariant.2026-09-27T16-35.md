Timestamp: 2026-09-27T16-35
Command: sh <scratchpad>/run-ps.sh <scratchpad>/line-counts.ps1 tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
EXIT_CODE: 0

Output:
tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 LineCount=391
tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 LineCount=500
tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1 LineCount=476
tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 LineCount=210

Checks:
- All four values are <= 500. PASS.
- BlastRadius.TruthTable.Tests.ps1: 391 equals P0-T14 baseline (391) exactly — net zero. PASS.
- enforcement-hooks-no-python-invocation.Tests.ps1: 500 equals P0-T17 baseline (500) exactly — net zero, zero-headroom constraint satisfied. PASS.
- DiscoveryValidation.Tests.ps1: 476 equals P0-T20 baseline (476) exactly — net zero, 23-line headroom preserved. PASS.
- codex-pretooluse-integration.Tests.ps1: 210 equals P0-T23 baseline (203) plus 7 exactly. PASS.

Output Summary: AC-7 satisfied. All four files are at or under 500 lines, and each file's post-edit line count matches its expected delta from the Phase 0 baseline exactly.
