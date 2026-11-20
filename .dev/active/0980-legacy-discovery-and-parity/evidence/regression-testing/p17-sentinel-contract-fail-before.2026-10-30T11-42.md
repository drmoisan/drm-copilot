# P17-T3 Sentinel consumption contract: fail-before run on the unchanged production tree

Timestamp: 2026-10-30T11-42
Task: [P17-T3] Prove the consumer defect with the fixture before the fix [expect-fail].
Command: Invoke-Pester over tests/scripts/claude-lib/discovery-validation/DiscoverySentinelConsumption.Contract.Tests.ps1 in one PowerShell 7 process with Output.Verbosity Detailed and TestResult JUnitXml written to SCRATCH/issue-980-p17t3-fail-before-junit.xml, exiting with the failed count (launcher SCRATCH/issue-980-p17-pester.ps1 through the SCRATCH sh launcher)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Run at 2026-10-30T11-41 UTC on the production tree as committed at the P17-T2 head (CL/DiscoveryCapability.psm1 unchanged; `git status --porcelain` listed only the new suite as untracked). Read from the JUnit file: tests="3" failures="1" errors="0" disabled="0". Case (a) 'builds the fixture records from the fixture envelopes' passed: both fixture records are rebuilt key for key, in the gate's key order, from the fixture envelopes through ConvertFrom-DiscoveryHostPayloadText, Get-DiscoveryTrustedPrincipal, Resolve-DiscoveryToolName and ConvertTo-DiscoveryHostObservationRecord with gate_now, nonce, handler_sha256 and ttl_seconds, and each record path from Get-DiscoveryObservationDirectory equals the authority directory plus the fixture relative path. Case (c) 'reports the pair without the latch as not consumed' passed: TrustedAttribution false with a deficiency containing `was not consumed`. Case (b) 'proves attribution from the fixture records beside the consumer latch' failed, which is the defect R5 describes.
Result: EXPECTED FAIL (the failing case is the consumer-contract defect; the fix lands in P17-T4)

## Failing assertion (case b, verbatim from the Pester output)

```
Expected $true, because sentinel observation observation-9d1e601211b5b2e4eebc was not consumed by the sentinel tool (state issued); no SHELL deny observation from the attributed sentinel agent was recorded, but got $false.
```

The probe rejected the gate-written tool record (state `issued`) although the exact `.consumed` latch the TypeScript consumer writes sat beside it; because no sentinel observation was accepted, the SHELL deny observation of the same agent was not matched either.

## Toolchain gates on the new suite

- Format: PoshQC formatter over tests/scripts/claude-lib/discovery-validation through the MCP tool after the last edit of the suite; a second pass left the file's SHA-256 unchanged (recorded in the task report).
- Analyze: direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the suite; the finding count is recorded in the task report.
- Expect-fail scope: only the Pester result of case (b) is the expected failure; format and analyzer gates remain pass/fail.
