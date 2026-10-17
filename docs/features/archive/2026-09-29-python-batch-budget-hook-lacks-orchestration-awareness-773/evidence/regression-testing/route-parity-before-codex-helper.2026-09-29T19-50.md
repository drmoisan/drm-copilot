# Route Parity Suite Before the Codex Helper Exists (P4-T2, expect-fail)

Timestamp: 2026-09-29T19-50
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary:
TotalCount=55
PassedCount=27
FailedCount=28
- Exactly one FAILED line contains `byte-identical`: `batch-budget route helper parity.keeps the Claude and Codex route helpers byte-identical`.
- The other 27 FAILED lines contain the unexpanded template `<Runtime>` (Pester 5.6.1 reports tests under the failed Codex block BeforeAll with the block template; PD6): `the <Runtime> route helper.loads the route functions from its own file`, `...defines exactly the three neutral route functions`, 21 x `...<Name>`, 4 x `...selects <Expected> from <Text>`.
- No FAILED line contains `the Claude route helper`; all 27 Claude-copy cases passed.
PARTEST LineCount=87 (P4-T1, at most 500).
