# Remediation Cycle 2 Fix E-CMR ([P2-T3])

Timestamp: 2026-10-10T21-02
Command: Edit (section 3 E-CMR substring replacements on tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1); sh <SCRATCHPAD>/r.sh r2-fixobs -File tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 (R-DRIVE-LITERALS, R-LINES, git diff --numstat f72a63752fc43c8d78fe3d952bd68c68a2b62547 -- tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1, git status --porcelain -- tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1); sh <SCRATCHPAD>/r.sh rscoped -Path tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 (R-SCOPED)
EXIT_CODE: 0
Output Summary: DRIVE-LITERALS 0; numstat 7 added and 7 removed; LINES 128 (equal to [P0-T10]); porcelain lists the file as modified; R-SCOPED EXIT_CODE 0, FailedCount 0, passed=14 (equal to [P0-T12]).

## Observations

```text
DRIVE-LITERALS: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | 0
LINES: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | 128
NUMSTAT: 7	7	tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
PORCELAIN:  M tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
REMOVE-MODULE-LINES: 0
DIFF:
  diff --git a/tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 b/tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
  index 13745c8e0..851e01a22 100644
  --- a/tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
  +++ b/tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
  @@ -58 +58 @@ Describe 'Codex enforce-codex-model-routing coverage (issue #786)' {
  -            Get-CodexModelGateAttestationKey -TranscriptPath 'C:\t.jsonl' | Should -Match '^[0-9a-f]{64}$'
  +            Get-CodexModelGateAttestationKey -TranscriptPath '/synthetic-root/t.jsonl' | Should -Match '^[0-9a-f]{64}$'
  @@ -65 +65 @@ Describe 'Codex enforce-codex-model-routing coverage (issue #786)' {
  -            Test-CodexModelGateProfileAttestation -Payload ([pscustomobject]@{ model = 'm' }) -Attestation (Get-SampleAttestation -Override $Override) -RepositoryRoot 'C:\repo' | Should -BeFalse
  +            Test-CodexModelGateProfileAttestation -Payload ([pscustomobject]@{ model = 'm' }) -Attestation (Get-SampleAttestation -Override $Override) -RepositoryRoot '/synthetic-root/repo' | Should -BeFalse
  @@ -70 +70 @@ Describe 'Codex enforce-codex-model-routing coverage (issue #786)' {
  -            Test-CodexModelGateProfileAttestation -Payload ([pscustomobject]@{ model = 'm' }) -Attestation (Get-SampleAttestation) -RepositoryRoot 'C:\repo' | Should -BeFalse
  +            Test-CodexModelGateProfileAttestation -Payload ([pscustomobject]@{ model = 'm' }) -Attestation (Get-SampleAttestation) -RepositoryRoot '/synthetic-root/repo' | Should -BeFalse
  @@ -76 +76 @@ Describe 'Codex enforce-codex-model-routing coverage (issue #786)' {
  -            Test-CodexModelGateProfileAttestation -Payload ([pscustomobject]@{ model = 'm' }) -Attestation (Get-SampleAttestation) -RepositoryRoot 'C:\repo' | Should -BeFalse
  +            Test-CodexModelGateProfileAttestation -Payload ([pscustomobject]@{ model = 'm' }) -Attestation (Get-SampleAttestation) -RepositoryRoot '/synthetic-root/repo' | Should -BeFalse
  @@ -82 +82 @@ Describe 'Codex enforce-codex-model-routing coverage (issue #786)' {
  -            Test-CodexModelGateProfileAttestation -Payload ([pscustomobject]@{ model = 'm' }) -Attestation (Get-SampleAttestation) -RepositoryRoot 'C:\repo' | Should -BeTrue
  +            Test-CodexModelGateProfileAttestation -Payload ([pscustomobject]@{ model = 'm' }) -Attestation (Get-SampleAttestation) -RepositoryRoot '/synthetic-root/repo' | Should -BeTrue
  @@ -109 +109 @@ Describe 'Codex enforce-codex-model-routing coverage (issue #786)' {
  -            $result = Invoke-ModelRoutingEntry -Stdin '{"session_id":"s-786","transcript_path":"C:\\t.jsonl","agent_type":"atomic-executor","model":"m"}'
  +            $result = Invoke-ModelRoutingEntry -Stdin '{"session_id":"s-786","transcript_path":"/synthetic-root/t.jsonl","agent_type":"atomic-executor","model":"m"}'
  @@ -115 +115 @@ Describe 'Codex enforce-codex-model-routing coverage (issue #786)' {
  -            Mock Get-ChildItem { @([pscustomobject]@{ FullName = 'C:\state\bad.json' }, [pscustomobject]@{ FullName = 'C:\state\good.json' }) }
  +            Mock Get-ChildItem { @([pscustomobject]@{ FullName = '/synthetic-root/state/bad.json' }, [pscustomobject]@{ FullName = '/synthetic-root/state/good.json' }) }
```

## R-SCOPED

```text

Starting discovery in 1 files.
Discovery found 14 tests in 119ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 935ms (534ms|299ms)
Tests completed in 945ms
Tests Passed: 14, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 14
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | result=Passed | passed=14 | failed=0
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
PASSED: falls back to the agent-id attestation scan
PASSED: allows an unrouted agent with no attestation
```
