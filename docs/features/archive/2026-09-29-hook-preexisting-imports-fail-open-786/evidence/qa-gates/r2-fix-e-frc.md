# Remediation Cycle 2 Fix E-FRC ([P2-T1])

Timestamp: 2026-10-10T21-00
Command: Edit (section 3 E-FRC substring replacements on tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1); sh <SCRATCHPAD>/r.sh r2-fixobs -File tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 (R-DRIVE-LITERALS, R-LINES, git diff --numstat f72a63752fc43c8d78fe3d952bd68c68a2b62547 -- tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1, git status --porcelain -- tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1); sh <SCRATCHPAD>/r.sh rscoped -Path tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 (R-SCOPED)
EXIT_CODE: 0
Output Summary: DRIVE-LITERALS 0; numstat 9 added and 9 removed; LINES 199 (equal to [P0-T10]); porcelain lists the file as modified; R-SCOPED EXIT_CODE 0, FailedCount 0, passed=29 (equal to [P0-T12]).

## Observations

```text
DRIVE-LITERALS: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | 0
LINES: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | 199
NUMSTAT: 9	9	tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
PORCELAIN:  M tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
REMOVE-MODULE-LINES: 0
DIFF:
  diff --git a/tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 b/tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
  index e1c9f1f93..3938f50ef 100644
  --- a/tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
  +++ b/tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
  @@ -63 +63 @@ Describe 'Codex validate-feature-review-coverage coverage (issue #786)' {
  -            Get-LatestPolicyAudit -RepoRoot 'C:\repo' | Should -BeNullOrEmpty
  +            Get-LatestPolicyAudit -RepoRoot '/synthetic-root/repo' | Should -BeNullOrEmpty
  @@ -69 +69 @@ Describe 'Codex validate-feature-review-coverage coverage (issue #786)' {
  -            (Get-LatestPolicyAudit -RepoRoot 'C:\repo').Name | Should -Be 'new'
  +            (Get-LatestPolicyAudit -RepoRoot '/synthetic-root/repo').Name | Should -Be 'new'
  @@ -74 +74 @@ Describe 'Codex validate-feature-review-coverage coverage (issue #786)' {
  -            (Get-ChangedLanguageSet -RepoRoot 'C:\repo').Count | Should -Be 0
  +            (Get-ChangedLanguageSet -RepoRoot '/synthetic-root/repo').Count | Should -Be 0
  @@ -80 +80 @@ Describe 'Codex validate-feature-review-coverage coverage (issue #786)' {
  -            @((Get-ChangedLanguageSet -RepoRoot 'C:\repo').Keys) | Should -Be @('TypeScript', 'Python', 'PowerShell', 'CSharp')
  +            @((Get-ChangedLanguageSet -RepoRoot '/synthetic-root/repo').Keys) | Should -Be @('TypeScript', 'Python', 'PowerShell', 'CSharp')
  @@ -121 +121 @@ Describe 'Codex validate-feature-review-coverage coverage (issue #786)' {
  -            Get-LanguageRepoCoverage -RepoRoot 'C:\repo' -Language $Language | Should -Be $Leaf
  +            Get-LanguageRepoCoverage -RepoRoot '/synthetic-root/repo' -Language $Language | Should -Be $Leaf
  @@ -125 +125 @@ Describe 'Codex validate-feature-review-coverage coverage (issue #786)' {
  -            Get-LanguageRepoCoverage -RepoRoot 'C:\repo' -Language 'Rust' | Should -BeNullOrEmpty
  +            Get-LanguageRepoCoverage -RepoRoot '/synthetic-root/repo' -Language 'Rust' | Should -BeNullOrEmpty
  @@ -176 +176 @@ Describe 'Codex validate-feature-review-coverage coverage (issue #786)' {
  -            Mock Get-ChildItem { [pscustomobject]@{ FullName = 'C:\repo\docs\features\active\f\policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }
  +            Mock Get-ChildItem { [pscustomobject]@{ FullName = '/synthetic-root/repo/docs/features/active/f/policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }
  @@ -183 +183 @@ Describe 'Codex validate-feature-review-coverage coverage (issue #786)' {
  -            Mock Get-ChildItem { [pscustomobject]@{ FullName = 'C:\repo\docs\features\active\f\policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }
  +            Mock Get-ChildItem { [pscustomobject]@{ FullName = '/synthetic-root/repo/docs/features/active/f/policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }
  @@ -192 +192 @@ Describe 'Codex validate-feature-review-coverage coverage (issue #786)' {
  -            Mock Get-ChildItem { [pscustomobject]@{ FullName = 'C:\repo\docs\features\active\f\policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }
  +            Mock Get-ChildItem { [pscustomobject]@{ FullName = '/synthetic-root/repo/docs/features/active/f/policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }
```

## R-SCOPED

```text

Starting discovery in 1 files.
Discovery found 29 tests in 135ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 1.08s (670ms|291ms)
Tests completed in 1.09s
Tests Passed: 29, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 29
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | result=Passed | passed=29 | failed=0
PASSED: resolves the repository root two levels above the hooks folder
PASSED: returns no audit when the active folder is absent
PASSED: returns the most recently written audit
PASSED: returns no language when the PR summary is absent
PASSED: maps changed files to their languages
PASSED: parses LCOV line counters
PASSED: returns null LCOV coverage when absent or empty
PASSED: parses JaCoCo LINE counters
PASSED: returns null JaCoCo coverage when absent, counter-free, or zero
PASSED: routes TypeScript to its report
PASSED: routes Python to its report
PASSED: routes PowerShell to its report
PASSED: routes CSharp to its report
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
PASSED: exits 0 when the branch changes no tracked language
PASSED: requests a continuation when a changed language lacks a verdict
PASSED: stops the continuation loop when a validator error occurs with the stop hook active
```
