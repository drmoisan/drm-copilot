# Test Long-Line Baseline, Remediation Cycle 1 (issue #937)

Timestamp: 2026-10-16T05-32
Task: P0-T9 (remediation-plan.2026-10-16T03-39.md)
Command: git diff -U0 origin/main...HEAD -- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | awk 'substr($0,1,1)=="+" && substr($0,1,3)!="+++" && length($0) > 121' | cut -c2- > SCRATCH/long-lines-before.txt; wc -l < SCRATCH/long-lines-before.txt; wc -l < <each test file>
EXIT_CODE: 0
Output Summary: 11 added test lines exceed 120 characters (CR-6): U27 Resolved and Detail, U29, U30, U31 Detail in the targets test file; three cycle 0 `(issue #937)` rows in the Claude suite; three in the Codex suite. Test file line counts 481, 152, 157.

`wc -l < SCRATCH/long-lines-before.txt`: 11

Lines (verbatim, as written to `SCRATCH/long-lines-before.txt`):

```text
        $result.Resolved | Should -BeFalse -Because "$Label is not a local path and must not resolve to the session root"
        $result.Detail | Should -BeExactly ('path-not-local: ' + $Spelling) -Because 'the detail names the rule and the raw input'
        $result.Detail | Should -BeExactly 'path-not-local: \\server\share\b.ps1' -Because 'the first failing rule names the non-local path'
        $result.Detail.StartsWith('path-not-local') | Should -BeTrue -Because 'the non-local check precedes the dot-segment check'
        $result.Detail | Should -BeExactly 'path-not-local: \\?\C:\wt\a.ps1' -Because 'the detail names the rule and the raw marker path'
        @{ Name = 'denies a Write to a UNC path in epic scope (issue #937)'; Command = ''; FilePath = '\\server\share\wt\scripts\powershell\Sample.ps1'; Code = 'target-unresolvable' }
        @{ Name = 'denies a Write to an extended-length path in epic scope (issue #937)'; Command = ''; FilePath = '\\?\C:\wt\scripts\powershell\Sample.ps1'; Code = 'target-unresolvable' }
        @{ Name = 'denies a Write to a drive-relative path in epic scope (issue #937)'; Command = ''; FilePath = 'C:wt\scripts\powershell\Sample.ps1'; Code = 'target-unresolvable' }
        @{ Name = 'denies an apply_patch UNC file marker in epic scope (issue #937)'; Command = "*** Begin Patch`n*** Update File: \\server\share\wt\scripts\powershell\Sample.ps1`n@@`n-old`n+new`n*** End Patch"; Code = 'target-unresolvable' }
        @{ Name = 'denies an apply_patch extended-length file marker in epic scope (issue #937)'; Command = "*** Begin Patch`n*** Update File: \\?\C:\wt\scripts\powershell\Sample.ps1`n@@`n-old`n+new`n*** End Patch"; Code = 'target-unresolvable' }
        @{ Name = 'denies an apply_patch drive-relative file marker in epic scope (issue #937)'; Command = "*** Begin Patch`n*** Update File: C:wt\scripts\powershell\Sample.ps1`n@@`n-old`n+new`n*** End Patch"; Code = 'target-unresolvable' }
```

Test file line counts:

| File | wc -l |
|---|---|
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` | 481 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1` | 152 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1` | 157 |
