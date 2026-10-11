# Remediation Cycle 2 Fix E-ERI ([P2-T4])

Timestamp: 2026-10-10T21-03
Command: Edit (section 3 E-ERI substring replacements on tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1); sh <SCRATCHPAD>/r.sh r2-fixobs -File tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 (R-DRIVE-LITERALS, R-LINES, git diff --numstat f72a63752fc43c8d78fe3d952bd68c68a2b62547 -- tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1, git status --porcelain -- tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1); sh <SCRATCHPAD>/r.sh rscoped -Path tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 (R-SCOPED)
EXIT_CODE: 0
Output Summary: DRIVE-LITERALS 0; numstat 3 added and 3 removed; LINES 94 (equal to [P0-T10]); porcelain lists the file as modified; R-SCOPED EXIT_CODE 0, FailedCount 0, passed=11 (equal to [P0-T12]).

## Observations

```text
DRIVE-LITERALS: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | 0
LINES: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | 94
NUMSTAT: 3	3	tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
PORCELAIN:  M tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
REMOVE-MODULE-LINES: 0
DIFF:
  diff --git a/tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 b/tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
  index 13033d7ab..54f7f44bc 100644
  --- a/tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
  +++ b/tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
  @@ -44 +44 @@ Describe 'Codex enforce-epic-root-invocation coverage (issue #786)' {
  -            Get-EpicRootGateAttestationKey -TranscriptPath 'C:\t.jsonl' | Should -Match '^[0-9a-f]{64}$'
  +            Get-EpicRootGateAttestationKey -TranscriptPath '/synthetic-root/t.jsonl' | Should -Match '^[0-9a-f]{64}$'
  @@ -81 +81 @@ Describe 'Codex enforce-epic-root-invocation coverage (issue #786)' {
  -            $result = Invoke-RootInvocationEntry -Stdin '{"session_id":"s-786","transcript_path":"C:\\t.jsonl","agent_type":"epic-planner"}'
  +            $result = Invoke-RootInvocationEntry -Stdin '{"session_id":"s-786","transcript_path":"/synthetic-root/t.jsonl","agent_type":"epic-planner"}'
  @@ -87 +87 @@ Describe 'Codex enforce-epic-root-invocation coverage (issue #786)' {
  -            Mock Get-ChildItem { @([pscustomobject]@{ FullName = 'C:\state\bad.json' }, [pscustomobject]@{ FullName = 'C:\state\good.json' }) }
  +            Mock Get-ChildItem { @([pscustomobject]@{ FullName = '/synthetic-root/state/bad.json' }, [pscustomobject]@{ FullName = '/synthetic-root/state/good.json' }) }
```

## R-SCOPED

```text

Starting discovery in 1 files.
Discovery found 11 tests in 121ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 828ms (435ms|291ms)
Tests completed in 838ms
Tests Passed: 11, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 11
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | result=Passed | passed=11 | failed=0
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
PASSED: falls back to the agent-id attestation scan and denies missing provenance
```
