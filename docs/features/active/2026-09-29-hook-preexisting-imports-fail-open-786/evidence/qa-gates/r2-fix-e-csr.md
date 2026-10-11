# Remediation Cycle 2 Fix E-CSR ([P2-T2])

Timestamp: 2026-10-10T21-01
Command: Edit (section 3 E-CSR substring replacements on tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1); sh <SCRATCHPAD>/r.sh r2-fixobs -File tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 (R-DRIVE-LITERALS, R-LINES, git diff --numstat f72a63752fc43c8d78fe3d952bd68c68a2b62547 -- tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1, git status --porcelain -- tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1); sh <SCRATCHPAD>/r.sh rscoped -Path tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 (R-SCOPED)
EXIT_CODE: 0
Output Summary: DRIVE-LITERALS 0; numstat 5 added and 5 removed; LINES 113 (equal to [P0-T10]); porcelain lists the file as modified; R-SCOPED EXIT_CODE 0, FailedCount 0, passed=17 (equal to [P0-T12]).

## Observations

```text
DRIVE-LITERALS: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | 0
LINES: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | 113
NUMSTAT: 5	5	tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
PORCELAIN:  M tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
REMOVE-MODULE-LINES: 0
DIFF:
  diff --git a/tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 b/tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
  index b896aedc7..4c1b4e38f 100644
  --- a/tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
  +++ b/tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
  @@ -78 +78 @@ Describe 'Codex validate-codex-subagent-routing coverage (issue #786)' {
  -            Find-CodexStopAttestationRaw -StateRoot 'C:\state' -AgentId 'a' | Should -Be ''
  +            Find-CodexStopAttestationRaw -StateRoot '/synthetic-root/state' -AgentId 'a' | Should -Be ''
  @@ -83 +83 @@ Describe 'Codex validate-codex-subagent-routing coverage (issue #786)' {
  -            Mock Get-ChildItem { @([pscustomobject]@{ FullName = 'C:\state\bad.json' }, [pscustomobject]@{ FullName = 'C:\state\other.json' }, [pscustomobject]@{ FullName = 'C:\state\good.json' }) }
  +            Mock Get-ChildItem { @([pscustomobject]@{ FullName = '/synthetic-root/state/bad.json' }, [pscustomobject]@{ FullName = '/synthetic-root/state/other.json' }, [pscustomobject]@{ FullName = '/synthetic-root/state/good.json' }) }
  @@ -85 +85 @@ Describe 'Codex validate-codex-subagent-routing coverage (issue #786)' {
  -            Find-CodexStopAttestationRaw -StateRoot 'C:\state' -AgentId 'a' | Should -Be '{"agent_id":"a"}'
  +            Find-CodexStopAttestationRaw -StateRoot '/synthetic-root/state' -AgentId 'a' | Should -Be '{"agent_id":"a"}'
  @@ -90 +90 @@ Describe 'Codex validate-codex-subagent-routing coverage (issue #786)' {
  -            Mock Get-ChildItem { @([pscustomobject]@{ FullName = 'C:\state\other.json' }) }
  +            Mock Get-ChildItem { @([pscustomobject]@{ FullName = '/synthetic-root/state/other.json' }) }
  @@ -92 +92 @@ Describe 'Codex validate-codex-subagent-routing coverage (issue #786)' {
  -            Find-CodexStopAttestationRaw -StateRoot 'C:\state' -AgentId 'a' | Should -Be ''
  +            Find-CodexStopAttestationRaw -StateRoot '/synthetic-root/state' -AgentId 'a' | Should -Be ''
```

## R-SCOPED

```text

Starting discovery in 1 files.
Discovery found 17 tests in 131ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-codex-subagent-routing.Coverage.Tests.ps1 826ms (444ms|281ms)
Tests completed in 837ms
Tests Passed: 17, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 17
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | result=Passed | passed=17 | failed=0
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
PASSED: returns the attestation whose agent id matches and skips unreadable files
PASSED: returns nothing when no attestation matches
PASSED: exits 2 for blank stdin
PASSED: exits 2 for a missing session id
PASSED: requests a continuation for a routed agent without an attestation
```
