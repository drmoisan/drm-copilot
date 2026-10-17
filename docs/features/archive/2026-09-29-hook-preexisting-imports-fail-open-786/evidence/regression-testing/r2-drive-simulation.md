# Remediation Cycle 2 Drive Simulation, Fail-Before for Rows 1 to 5 and 7 to 18 ([P1-T2], expect-fail)

Timestamp: 2026-10-10T20-42
Command: sh <SCRATCHPAD>/r.sh r2-drivesim -Label pre (R-DRIVESIM: drive letter C rewritten to an absent drive in shadow copies of the five E-FRC, E-CSR, E-CMR, E-ERI, E-EWB files, R-SHADOW applied, R-SCOPED over the five shadows in the same fresh PowerShell 7 process)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: expected failure observed. SIM-REPLACED counts 9, 7, 8, 4, 6; 17 SIM-FAILED rows; per-suite counts equal the [P0-T5] CI counts and every ExpandedName is the final segment of a CI testcase name of the same suite (SIM-MATCH: yes); classes: drive 8, raw 2, file 2, exit2 5, other 0. Mechanism A is confirmed on the host.

## Derived lines

```text
SIM-FAILED-BY-SUITE: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | 10
SIM-FAILED-BY-SUITE: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | 2
SIM-FAILED-BY-SUITE: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | 1
SIM-FAILED-BY-SUITE: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | 1
SIM-FAILED-BY-SUITE: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | 3
SIM-CLASS: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | returns no audit when the active folder is absent | drive
SIM-CLASS: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | returns the most recently written audit | drive
SIM-CLASS: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | returns no language when the PR summary is absent | drive
SIM-CLASS: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | maps changed files to their languages | drive
SIM-CLASS: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | routes TypeScript to its report | drive
SIM-CLASS: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | routes Python to its report | drive
SIM-CLASS: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | routes PowerShell to its report | drive
SIM-CLASS: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | routes CSharp to its report | drive
SIM-CLASS: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | exits 0 when the branch changes no tracked language | exit2
SIM-CLASS: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | requests a continuation when a changed language lacks a verdict | exit2
SIM-CLASS: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | returns the attestation whose agent id matches and skips unreadable files | file
SIM-CLASS: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | returns nothing when no attestation matches | file
SIM-CLASS: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | falls back to the agent-id attestation scan | exit2
SIM-CLASS: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | falls back to the agent-id attestation scan and denies missing provenance | exit2
SIM-CLASS: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | exits 0 for a non-mutating tool with no local or launcher state | exit2
SIM-CLASS: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | exits 0 without a deny for a ready execution child | raw
SIM-CLASS: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | writes the deny for an unready execution child | raw
SIM-MATCH: yes
```

## Full output

```text
SIM-DRIVE: Z
SIM-REPLACED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | 9
SIM-REPLACED: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | 7
SIM-REPLACED: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | 8
SIM-REPLACED: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | 4
SIM-REPLACED: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | 6

Starting discovery in 5 files.
Discovery found 92 tests in 413ms.
Running tests.
[-] Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.returns no audit when the active folder is absent 18ms (17ms|1ms)
 at Get-LatestPolicyAudit, <WORKSPACE_ROOT>\.codex\hooks\validate-feature-review-coverage.ps1:55
 at <ScriptBlock>, <SCRATCHPAD>\r2-shadow-pre\validate-feature-review-coverage.Coverage.Tests.ps1:63
 DriveNotFoundException: Cannot find drive. A drive with the name 'Z' does not exist.
[-] Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.returns the most recently written audit 10ms (9ms|1ms)
 at Get-LatestPolicyAudit, <WORKSPACE_ROOT>\.codex\hooks\validate-feature-review-coverage.ps1:55
 at <ScriptBlock>, <SCRATCHPAD>\r2-shadow-pre\validate-feature-review-coverage.Coverage.Tests.ps1:69
 DriveNotFoundException: Cannot find drive. A drive with the name 'Z' does not exist.
[-] Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.returns no language when the PR summary is absent 39ms (38ms|0ms)
 at Get-ChangedLanguageSet, <WORKSPACE_ROOT>\.codex\hooks\validate-feature-review-coverage.ps1:67
 DriveNotFoundException: Cannot find drive. A drive with the name 'Z' does not exist.
[-] Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.maps changed files to their languages 10ms (10ms|0ms)
 at Get-ChangedLanguageSet, <WORKSPACE_ROOT>\.codex\hooks\validate-feature-review-coverage.ps1:67
 DriveNotFoundException: Cannot find drive. A drive with the name 'Z' does not exist.
[-] Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.routes TypeScript to its report 6ms (5ms|1ms)
 at Get-LanguageRepoCoverage, <WORKSPACE_ROOT>\.codex\hooks\validate-feature-review-coverage.ps1:134
 at <ScriptBlock>, <SCRATCHPAD>\r2-shadow-pre\validate-feature-review-coverage.Coverage.Tests.ps1:121
 DriveNotFoundException: Cannot find drive. A drive with the name 'Z' does not exist.
[-] Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.routes Python to its report 2ms (2ms|0ms)
 at Get-LanguageRepoCoverage, <WORKSPACE_ROOT>\.codex\hooks\validate-feature-review-coverage.ps1:135
 at <ScriptBlock>, <SCRATCHPAD>\r2-shadow-pre\validate-feature-review-coverage.Coverage.Tests.ps1:121
 DriveNotFoundException: Cannot find drive. A drive with the name 'Z' does not exist.
[-] Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.routes PowerShell to its report 2ms (2ms|0ms)
 at Get-LanguageRepoCoverage, <WORKSPACE_ROOT>\.codex\hooks\validate-feature-review-coverage.ps1:136
 at <ScriptBlock>, <SCRATCHPAD>\r2-shadow-pre\validate-feature-review-coverage.Coverage.Tests.ps1:121
 DriveNotFoundException: Cannot find drive. A drive with the name 'Z' does not exist.
[-] Codex validate-feature-review-coverage coverage (issue #786).readers and parsers.routes CSharp to its report 2ms (2ms|0ms)
 at Get-LanguageRepoCoverage, <WORKSPACE_ROOT>\.codex\hooks\validate-feature-review-coverage.ps1:137
 at <ScriptBlock>, <SCRATCHPAD>\r2-shadow-pre\validate-feature-review-coverage.Coverage.Tests.ps1:121
 DriveNotFoundException: Cannot find drive. A drive with the name 'Z' does not exist.
[-] Codex validate-feature-review-coverage coverage (issue #786).entry point.exits 0 when the branch changes no tracked language 75ms (74ms|0ms)
 at (Invoke-CodexReviewEntry -Stdin $script:ReviewStop).ExitCode | Should -Be 0, <SCRATCHPAD>\r2-shadow-pre\validate-feature-review-coverage.Coverage.Tests.ps1:178
 at <ScriptBlock>, <SCRATCHPAD>\r2-shadow-pre\validate-feature-review-coverage.Coverage.Tests.ps1:178
 Expected 0, but got 2.
[-] Codex validate-feature-review-coverage coverage (issue #786).entry point.requests a continuation when a changed language lacks a verdict 25ms (24ms|0ms)
 at $result.ExitCode | Should -Be 0, <SCRATCHPAD>\r2-shadow-pre\validate-feature-review-coverage.Coverage.Tests.ps1:186
 at <ScriptBlock>, <SCRATCHPAD>\r2-shadow-pre\validate-feature-review-coverage.Coverage.Tests.ps1:186
 Expected 0, but got 2.
[-] Codex validate-codex-subagent-routing coverage (issue #786).Find-CodexStopAttestationRaw.returns the attestation whose agent id matches and skips unreadable files 14ms (14ms|0ms)
 at Find-CodexStopAttestationRaw, <WORKSPACE_ROOT>\.codex\hooks\validate-codex-subagent-routing.ps1:119
 at <ScriptBlock>, <SCRATCHPAD>\r2-shadow-pre\validate-codex-subagent-routing.Coverage.Tests.ps1:85
 ParameterBindingException: A parameter cannot be found that matches parameter name 'File'.
[-] Codex validate-codex-subagent-routing coverage (issue #786).Find-CodexStopAttestationRaw.returns nothing when no attestation matches 15ms (14ms|0ms)
 at Find-CodexStopAttestationRaw, <WORKSPACE_ROOT>\.codex\hooks\validate-codex-subagent-routing.ps1:119
 at <ScriptBlock>, <SCRATCHPAD>\r2-shadow-pre\validate-codex-subagent-routing.Coverage.Tests.ps1:92
 ParameterBindingException: A parameter cannot be found that matches parameter name 'File'.
[-] Codex enforce-codex-model-routing coverage (issue #786).entry point.falls back to the agent-id attestation scan 33ms (33ms|0ms)
 at $result.ExitCode | Should -Be 0, <SCRATCHPAD>\r2-shadow-pre\enforce-codex-model-routing.Coverage.Tests.ps1:118
 at <ScriptBlock>, <SCRATCHPAD>\r2-shadow-pre\enforce-codex-model-routing.Coverage.Tests.ps1:118
 Expected 0, but got 2.
[-] Codex enforce-epic-root-invocation coverage (issue #786).entry point.falls back to the agent-id attestation scan and denies missing provenance 30ms (30ms|0ms)
 at $result.ExitCode | Should -Be 0, <SCRATCHPAD>\r2-shadow-pre\enforce-epic-root-invocation.Coverage.Tests.ps1:90
 at <ScriptBlock>, <SCRATCHPAD>\r2-shadow-pre\enforce-epic-root-invocation.Coverage.Tests.ps1:90
 Expected 0, but got 2.
[-] Codex enforce-epic-wave-barrier coverage (issue #786).entry point.exits 0 for a non-mutating tool with no local or launcher state 42ms (41ms|1ms)
 at $result.ExitCode | Should -Be 0, <SCRATCHPAD>\r2-shadow-pre\enforce-epic-wave-barrier.Coverage.Tests.ps1:151
 at <ScriptBlock>, <SCRATCHPAD>\r2-shadow-pre\enforce-epic-wave-barrier.Coverage.Tests.ps1:151
 Expected 0, but got 2.
[-] Codex enforce-epic-wave-barrier coverage (issue #786).entry point.exits 0 without a deny for a ready execution child 46ms (45ms|1ms)
 at $result.ExitCode | Should -Be 0 -Because $result.Stderr, <SCRATCHPAD>\r2-shadow-pre\enforce-epic-wave-barrier.Coverage.Tests.ps1:168
 at <ScriptBlock>, <SCRATCHPAD>\r2-shadow-pre\enforce-epic-wave-barrier.Coverage.Tests.ps1:168
 Expected 0, because A parameter cannot be found that matches parameter name 'Raw'., but got 2.
[-] Codex enforce-epic-wave-barrier coverage (issue #786).entry point.writes the deny for an unready execution child 38ms (37ms|1ms)
 at $result.ExitCode | Should -Be 0 -Because $result.Stderr, <SCRATCHPAD>\r2-shadow-pre\enforce-epic-wave-barrier.Coverage.Tests.ps1:177
 at <ScriptBlock>, <SCRATCHPAD>\r2-shadow-pre\enforce-epic-wave-barrier.Coverage.Tests.ps1:177
 Expected 0, because A parameter cannot be found that matches parameter name 'Raw'., but got 2.
Tests completed in 2.82s
Tests Passed: 75, Failed: 17, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 75
FailedCount: 17
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | result=Failed | passed=19 | failed=10
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | result=Failed | passed=15 | failed=2
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | result=Failed | passed=13 | failed=1
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | result=Failed | passed=10 | failed=1
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | result=Failed | passed=18 | failed=3
FAILED: returns no audit when the active folder is absent | Cannot find drive. A drive with the name 'Z' does not exist.
FAILED: returns the most recently written audit | Cannot find drive. A drive with the name 'Z' does not exist.
FAILED: returns no language when the PR summary is absent | Cannot find drive. A drive with the name 'Z' does not exist.
FAILED: maps changed files to their languages | Cannot find drive. A drive with the name 'Z' does not exist.
FAILED: routes TypeScript to its report | Cannot find drive. A drive with the name 'Z' does not exist.
FAILED: routes Python to its report | Cannot find drive. A drive with the name 'Z' does not exist.
FAILED: routes PowerShell to its report | Cannot find drive. A drive with the name 'Z' does not exist.
FAILED: routes CSharp to its report | Cannot find drive. A drive with the name 'Z' does not exist.
FAILED: exits 0 when the branch changes no tracked language | Expected 0, but got 2.
FAILED: requests a continuation when a changed language lacks a verdict | Expected 0, but got 2.
FAILED: returns the attestation whose agent id matches and skips unreadable files | A parameter cannot be found that matches parameter name 'File'.
FAILED: returns nothing when no attestation matches | A parameter cannot be found that matches parameter name 'File'.
FAILED: falls back to the agent-id attestation scan | Expected 0, but got 2.
FAILED: falls back to the agent-id attestation scan and denies missing provenance | Expected 0, but got 2.
FAILED: exits 0 for a non-mutating tool with no local or launcher state | Expected 0, but got 2.
FAILED: exits 0 without a deny for a ready execution child | Expected 0, because A parameter cannot be found that matches parameter name 'Raw'., but got 2.
FAILED: writes the deny for an unready execution child | Expected 0, because A parameter cannot be found that matches parameter name 'Raw'., but got 2.
PASSED: resolves the repository root two levels above the hooks folder
PASSED: parses LCOV line counters
PASSED: returns null LCOV coverage when absent or empty
PASSED: parses JaCoCo LINE counters
PASSED: returns null JaCoCo coverage when absent, counter-free, or zero
PASSED: returns null for an unknown language
PASSED: reports an unmentioned language
PASSED: reports no coverage row
PASSED: reports a narrowing row
PASSED: reports a row without a verdict
PASSED: reports low coverage without FAIL
PASSED: accepts a FAIL verdict for low coverage
PASSED: requests one continuation, then stops when the stop hook is already active
PASSED: exits 2 for empty stdin
PASSED: exits 2 for malformed stdin
PASSED: exits 2 for a missing stop_hook_active
PASSED: exits 2 for a non-review payload
PASSED: exits 0 when no policy audit exists
PASSED: stops the continuation loop when a validator error occurs with the stop hook active
PASSED: throws on a blank or malformed payload
PASSED: gates a tiered agent name
PASSED: stops the loop when a continuation was already requested
PASSED: allows an ungated agent
PASSED: reports a missing epic attestation
PASSED: reports a missing routed attestation
PASSED: reports an identity mismatch
PASSED: reports missing epic provenance
PASSED: reports invalid routing
PASSED: reports a model change
PASSED: allows a matching attestation
PASSED: returns nothing when the state root is absent
PASSED: exits 2 for blank stdin
PASSED: exits 2 for a missing session id
PASSED: requests a continuation for a routed agent without an attestation
PASSED: throws on an empty or malformed payload
PASSED: derives a 64-character lowercase attestation key
PASSED: rejects an attestation missing a required field
PASSED: rejects an attestation missing a well-formed profile hash
PASSED: rejects an attestation whose agent profile cannot be read
PASSED: rejects an attestation whose profile binding does not hold
PASSED: accepts an attestation whose profile and payload agree
PASSED: allows a valid attestation and denies a routed agent without one
PASSED: allows an unrouted agent without an attestation
PASSED: exits 2 for whitespace stdin
PASSED: exits 2 for malformed stdin
PASSED: reads the transcript-keyed attestation and denies profile drift
PASSED: allows an unrouted agent with no attestation
PASSED: throws on an empty or malformed payload
PASSED: derives a 64-character lowercase attestation key
PASSED: allows a non-epic agent without an attestation
PASSED: denies an epic agent without an attestation
PASSED: allows an attestation for a non-epic agent
PASSED: allows an epic agent with valid provenance
PASSED: denies an epic agent whose provenance is not valid
PASSED: exits 2 for whitespace stdin
PASSED: exits 2 for malformed stdin
PASSED: reads the transcript-keyed attestation and allows valid provenance
PASSED: baseline mock interception probe
PASSED: reads optional, empty, and malformed JSON
PASSED: derives the feature key from the epic context or returns empty
PASSED: finds no feature without a checkpoint or a match
PASSED: finds the launch feature by issue and folder
PASSED: judges dependency readiness
PASSED: classifies Write as mutation True
PASSED: classifies mcp__other__write as mutation True
PASSED: classifies mcp__drm-copilot__validate_plan as mutation False
PASSED: classifies mcp__drm-copilot__promote as mutation True
PASSED: classifies shell_command as mutation True
PASSED: classifies Read as mutation False
PASSED: allows a non-mutating tool
PASSED: allows a preparation child and denies an unknown launcher context
PASSED: denies an execution child without launch authority
PASSED: allows a ready launch feature and denies an unready one
PASSED: judges a local child by its checkpoint and its epic dependencies
PASSED: reads the local checkpoint and exits 2 for an empty payload
SIM-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | returns no audit when the active folder is absent | Cannot find drive. A drive with the name 'Z' does not exist.
SIM-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | returns the most recently written audit | Cannot find drive. A drive with the name 'Z' does not exist.
SIM-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | returns no language when the PR summary is absent | Cannot find drive. A drive with the name 'Z' does not exist.
SIM-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | maps changed files to their languages | Cannot find drive. A drive with the name 'Z' does not exist.
SIM-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | routes TypeScript to its report | Cannot find drive. A drive with the name 'Z' does not exist.
SIM-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | routes Python to its report | Cannot find drive. A drive with the name 'Z' does not exist.
SIM-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | routes PowerShell to its report | Cannot find drive. A drive with the name 'Z' does not exist.
SIM-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | routes CSharp to its report | Cannot find drive. A drive with the name 'Z' does not exist.
SIM-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | exits 0 when the branch changes no tracked language | Expected 0, but got 2.
SIM-FAILED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | requests a continuation when a changed language lacks a verdict | Expected 0, but got 2.
SIM-FAILED: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | returns the attestation whose agent id matches and skips unreadable files | A parameter cannot be found that matches parameter name 'File'.
SIM-FAILED: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | returns nothing when no attestation matches | A parameter cannot be found that matches parameter name 'File'.
SIM-FAILED: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | falls back to the agent-id attestation scan | Expected 0, but got 2.
SIM-FAILED: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | falls back to the agent-id attestation scan and denies missing provenance | Expected 0, but got 2.
SIM-FAILED: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | exits 0 for a non-mutating tool with no local or launcher state | Expected 0, but got 2.
SIM-FAILED: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | exits 0 without a deny for a ready execution child | Expected 0, because A parameter cannot be found that matches parameter name 'Raw'., but got 2.
SIM-FAILED: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | writes the deny for an unready execution child | Expected 0, because A parameter cannot be found that matches parameter name 'Raw'., but got 2.
```
