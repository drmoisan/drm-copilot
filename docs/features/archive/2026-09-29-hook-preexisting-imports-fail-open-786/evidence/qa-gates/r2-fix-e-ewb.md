# Remediation Cycle 2 Fix E-EWB ([P2-T5])

Timestamp: 2026-10-10T21-04
Command: Edit (section 3 E-EWB substring replacements on tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1); sh <SCRATCHPAD>/r.sh r2-fixobs -File tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 (R-DRIVE-LITERALS, R-LINES, git diff --numstat f72a63752fc43c8d78fe3d952bd68c68a2b62547 -- tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1, git status --porcelain -- tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1); sh <SCRATCHPAD>/r.sh rscoped -Path tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 (R-SCOPED)
EXIT_CODE: 0
Output Summary: DRIVE-LITERALS 0; numstat 6 added and 6 removed; LINES 181 (equal to [P0-T10]); porcelain lists the file as modified; R-SCOPED EXIT_CODE 0, FailedCount 0, passed=21 (equal to [P0-T12]).

## Observations

```text
DRIVE-LITERALS: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | 0
LINES: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | 181
NUMSTAT: 6	6	tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
PORCELAIN:  M tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
REMOVE-MODULE-LINES: 0
DIFF:
  diff --git a/tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 b/tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
  index 109f804ac..a591b0beb 100644
  --- a/tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
  +++ b/tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
  @@ -46 +46 @@ Describe 'Codex enforce-epic-wave-barrier coverage (issue #786)' {
  -            $launchReceiptText = '{"issue_num":"' + $IssueNum + '","feature_folder":"' + $Folder + '","checkpoint_path":"C:/epic-786.json"}'
  +            $launchReceiptText = '{"issue_num":"' + $IssueNum + '","feature_folder":"' + $Folder + '","checkpoint_path":"/synthetic-root/epic-786.json"}'
  @@ -50 +50 @@ Describe 'Codex enforce-epic-wave-barrier coverage (issue #786)' {
  -                $env:CODEX_EPIC_CHILD_LAUNCH_RECEIPT = 'C:/receipts/r-786.json'
  +                $env:CODEX_EPIC_CHILD_LAUNCH_RECEIPT = '/synthetic-root/receipts/r-786.json'
  @@ -125 +125 @@ Describe 'Codex enforce-epic-wave-barrier coverage (issue #786)' {
  -            (Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '' -EpicCheckpointRaw '' -LauncherEnvironment ([pscustomobject]@{ launch_id = 'l'; execution_context = 'epic_execution_child' }) -RepositoryRoot 'C:\repo').hookSpecificOutput.permissionDecisionReason | Should -Match 'no valid session-bound launcher receipt'
  +            (Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '' -EpicCheckpointRaw '' -LauncherEnvironment ([pscustomobject]@{ launch_id = 'l'; execution_context = 'epic_execution_child' }) -RepositoryRoot '/synthetic-root/repo').hookSpecificOutput.permissionDecisionReason | Should -Match 'no valid session-bound launcher receipt'
  @@ -131,2 +131,2 @@ Describe 'Codex enforce-epic-wave-barrier coverage (issue #786)' {
  -            Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '' -EpicCheckpointRaw $script:Epic -LauncherReceiptRaw '{"issue_num":"2","feature_folder":"docs/features/active/two"}' -LauncherEnvironment $environment -RepositoryRoot 'C:\repo' | Should -BeNullOrEmpty
  -            (Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '' -EpicCheckpointRaw $script:Epic -LauncherReceiptRaw '{"issue_num":"3","feature_folder":"docs/features/active/three"}' -LauncherEnvironment $environment -RepositoryRoot 'C:\repo').hookSpecificOutput.permissionDecisionReason | Should -Match 'receipt-bound epic checkpoint'
  +            Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '' -EpicCheckpointRaw $script:Epic -LauncherReceiptRaw '{"issue_num":"2","feature_folder":"docs/features/active/two"}' -LauncherEnvironment $environment -RepositoryRoot '/synthetic-root/repo' | Should -BeNullOrEmpty
  +            (Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '' -EpicCheckpointRaw $script:Epic -LauncherReceiptRaw '{"issue_num":"3","feature_folder":"docs/features/active/three"}' -LauncherEnvironment $environment -RepositoryRoot '/synthetic-root/repo').hookSpecificOutput.permissionDecisionReason | Should -Match 'receipt-bound epic checkpoint'
  @@ -145 +145 @@ Describe 'Codex enforce-epic-wave-barrier coverage (issue #786)' {
  -            Mock Get-CodexPrimaryWorktreeRoot { 'C:/primary' }
  +            Mock Get-CodexPrimaryWorktreeRoot { '/synthetic-root/primary' }
```

## R-SCOPED

```text

Starting discovery in 1 files.
Discovery found 21 tests in 124ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 1.14s (741ms|291ms)
Tests completed in 1.15s
Tests Passed: 21, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 21
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | result=Passed | passed=21 | failed=0
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
PASSED: exits 0 for a non-mutating tool with no local or launcher state
PASSED: reads the local checkpoint and exits 2 for an empty payload
PASSED: exits 0 without a deny for a ready execution child
PASSED: writes the deny for an unready execution child
```
