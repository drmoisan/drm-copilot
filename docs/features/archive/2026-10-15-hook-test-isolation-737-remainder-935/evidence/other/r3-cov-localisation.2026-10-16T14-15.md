# R3 COV-1 Localisation (P1-T16)

Timestamp: 2026-10-16T14-15
Terminal (P1-T15): T-U4-NO-LONGER -> terminal files: all nine U4 paths
Command: D-LOCALISE (the plan's inline awk program, unchanged) on each worktree path as `awk ... <path>`, and on the REF version of each edited path as `git show 5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea:<path> | awk ...` (one git command per call). P_HRH and P_HRS are absent at REF and have no REF run.
EXIT_CODE: 0
Output Summary: per-file summary lines below; the full outputs follow.

## Summary lines
LOCALISATION: tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1 | head-runtime-load-lines=3 | ref-runtime-load-lines=absent | fixture-lines=0 | runtime-blocks=0
LOCALISATION: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1 | head-runtime-load-lines=14 | ref-runtime-load-lines=absent | fixture-lines=155 | runtime-blocks=19
LOCALISATION: tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 | head-runtime-load-lines=11 | ref-runtime-load-lines=10 | fixture-lines=0 | runtime-blocks=0
LOCALISATION: tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 | head-runtime-load-lines=2 | ref-runtime-load-lines=2 | fixture-lines=0 | runtime-blocks=0
LOCALISATION: tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1 | head-runtime-load-lines=0 | ref-runtime-load-lines=0 | fixture-lines=0 | runtime-blocks=0
LOCALISATION: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | head-runtime-load-lines=10 | ref-runtime-load-lines=10 | fixture-lines=12 | runtime-blocks=25
LOCALISATION: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | head-runtime-load-lines=10 | ref-runtime-load-lines=10 | fixture-lines=122 | runtime-blocks=9
LOCALISATION: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | head-runtime-load-lines=3 | ref-runtime-load-lines=3 | fixture-lines=148 | runtime-blocks=8
LOCALISATION: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | head-runtime-load-lines=3 | ref-runtime-load-lines=3 | fixture-lines=119 | runtime-blocks=11

(fixture-lines and runtime-blocks are the HEAD values.)

RUNTIME-LOAD-DELTA:
- tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 (HEAD only): `RUNTIME: . (Join-Path $PSScriptRoot 'EpicStateIsolation.HookReference.Helpers.ps1')`
- tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1 (HEAD only; file absent at REF): all three HEAD `RUNTIME:` lines (listed in the full output below)
- tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1 (HEAD only; file absent at REF): all fourteen HEAD `RUNTIME:` lines (listed in the full output below)
- The six other edited paths: no delta (identical `RUNTIME:` line sets at HEAD and REF).

COMPILED-FILE-DELTA: +2 (P_HRH +1, P_HRS +1; 0 for the seven edited files)

## Full outputs (HEAD worktree)

=== HEAD tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1
```
RUNTIME:         Load positions: the argument of a . or & invocation; Import-Module path arguments; ProcessStartInfo
RUNTIME:         used in one of those positions. A Join-Path read only by Get-FileHash, Get-Content or ParseFile is
RUNTIME:         if ($command.GetCommandName() -eq 'Import-Module') { $pathParameter = @('Name', 'Path') }
fixture-lines=0 runtime-blocks=0 runtime-load-lines=3
```

=== HEAD tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1
```
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Discovery.Helpers.ps1')
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Compliance.Helpers.ps1')
RUNTIME:         return [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)
RUNTIME:         $text | Should -BeLike '*hook dot-source, Import-Module, Mock order violated*' -Because 'the anchor is the last helper dot-source'
RUNTIME:         $reader = { param([string] $RelativePath) if ($table.ContainsKey($RelativePath)) { $table[$RelativePath] } else { $null } }.GetNewClosure()
RUNTIME:         @{ Case = 'value parameter as the last element'; Source = 'Import-Module ./Fixture.psm1 -Prefix'; Index = 2; Expected = $false }
RUNTIME:         @{ Case = 'value parameter followed by another parameter'; Source = 'Import-Module -Prefix -Force ./Fixture.psm1'; Index = 1; Expected = $false }
RUNTIME:         @{ Case = 'value parameter with an attached argument'; Source = 'Import-Module -Prefix:Pre ./Fixture.psm1'; Index = 1; Expected = $false }
RUNTIME:         @{ Case = 'abbreviated parameter name'; Source = 'Import-Module -Pref Pre ./Fixture.psm1'; Index = 1; Expected = $false }
RUNTIME:         @{ Case = 'element that is not a parameter'; Source = 'Import-Module ./Fixture.psm1 -Force'; Index = 1; Expected = $false }
RUNTIME:         @{ Case = 'value parameter followed by its value'; Source = 'Import-Module -Prefix Pre ./Fixture.psm1'; Index = 1; Expected = $true }
RUNTIME:         @{ Case = 'common parameter -ErrorAction followed by its value'; Source = 'Import-Module -ErrorAction Stop ./Fixture.psm1'; Index = 1; Expected = $true }
RUNTIME:         @{ Case = 'common parameter -OutVariable followed by its value'; Source = 'Import-Module -OutVariable loaded ./Fixture.psm1'; Index = 1; Expected = $true }
fixture-lines=155 runtime-blocks=19 runtime-load-lines=14
```

=== HEAD tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1
```
RUNTIME:     reads: after the hook dot-source, an Import-Module of EpicScopeResolution.psm1 without
RUNTIME:     EpicScopeResolution, and an Import-Module of WorktreeRunResolution.psm1 without -Force
RUNTIME: . (Join-Path $PSScriptRoot 'EpicStateIsolation.HookReference.Helpers.ps1')
RUNTIME:     # a function body, so a Mock or Import-Module that never runs does not count as isolation.
RUNTIME:     # Pure: true when an Import-Module command names the module file in a positional or -Name/-Path
RUNTIME:         Import-Module of ModuleFile without -Force, both after the hook dot-source. A $null
RUNTIME:             $_.GetCommandName() -eq 'Import-Module' -and (Test-EpicStateIsolationModuleImport -Command $_ -ModuleFile $ModuleFile)
RUNTIME:             $findings.Add("Import-Module of $ModuleFile missing from outermost BeforeAll")
RUNTIME:             $findings.Add("Import-Module of $ModuleFile uses -Force")
RUNTIME:         if (-not $ordered) { $findings.Add('hook dot-source, Import-Module, Mock order violated') }
RUNTIME:     $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref] $tokens, [ref] $errors)
fixture-lines=0 runtime-blocks=0 runtime-load-lines=11
```

=== HEAD tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1
```
RUNTIME:     }.GetNewClosure()
RUNTIME:     $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref] $tokens, [ref] $errors)
fixture-lines=0 runtime-blocks=0 runtime-load-lines=2
```

=== HEAD tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1
```
fixture-lines=0 runtime-blocks=0 runtime-load-lines=0
```

=== HEAD tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
```
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Discovery.Helpers.ps1')
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Compliance.Helpers.ps1')
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Discovery.Helpers.ps1')
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Compliance.Helpers.ps1')
RUNTIME:         }.GetNewClosure()
RUNTIME:         $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref] $tokens, [ref] $errors)
RUNTIME:         $hook = "`$modulePath = Join-Path `$PSScriptRoot '../lib/fixture/b.psm1'`nImport-Module `$modulePath`n"
RUNTIME:         # Arrange: a direct null Mock of the script-scope seam after the dot-source, with no Import-Module.
fixture-lines=12 runtime-blocks=25 runtime-load-lines=10
```

=== HEAD tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
```
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
RUNTIME:             $ast = [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)
RUNTIME:                 Name     = 'an Import-Module with -Force'
RUNTIME:                 Expected = 'Import-Module of WorktreeRunResolution.psm1 missing from outermost BeforeAll'
RUNTIME:                 Expected = 'Import-Module of WorktreeRunResolution.psm1 uses -Force'
RUNTIME:             $ast = [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)
RUNTIME:         Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/EpicScopeResolution.psm1') -Force
RUNTIME:         Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')
RUNTIME:             Mock Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution { $hostileText }.GetNewClosure()
RUNTIME:             Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $hostileText }.GetNewClosure()
fixture-lines=122 runtime-blocks=9 runtime-load-lines=10
```

=== HEAD tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1
```
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
RUNTIME:         return [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)
RUNTIME:             Expected = 'Import-Module of EpicScopeResolution.psm1 missing'
fixture-lines=148 runtime-blocks=8 runtime-load-lines=3
```

=== HEAD tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1
```
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
RUNTIME:         return [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)
RUNTIME:         ($findings -join '; ') | Should -BeLike '*Import-Module of EpicScopeResolution.psm1 missing*'
fixture-lines=119 runtime-blocks=11 runtime-load-lines=3
```

## Full outputs (REF `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`)

=== REF tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1
```
RUNTIME:     reads: after the hook dot-source, an Import-Module of EpicScopeResolution.psm1 without
RUNTIME:     EpicScopeResolution, and an Import-Module of WorktreeRunResolution.psm1 without -Force
RUNTIME:     # a function body, so a Mock or Import-Module that never runs does not count as isolation.
RUNTIME:     # Pure: true when an Import-Module command names the module file in a positional or -Name/-Path
RUNTIME:         Import-Module of ModuleFile without -Force, both after the hook dot-source. A $null
RUNTIME:             $_.GetCommandName() -eq 'Import-Module' -and (Test-EpicStateIsolationModuleImport -Command $_ -ModuleFile $ModuleFile)
RUNTIME:             $findings.Add("Import-Module of $ModuleFile missing from outermost BeforeAll")
RUNTIME:             $findings.Add("Import-Module of $ModuleFile uses -Force")
RUNTIME:         if (-not $ordered) { $findings.Add('hook dot-source, Import-Module, Mock order violated') }
RUNTIME:     $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref] $tokens, [ref] $errors)
fixture-lines=0 runtime-blocks=0 runtime-load-lines=10
```

=== REF tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1
```
RUNTIME:     }.GetNewClosure()
RUNTIME:     $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref] $tokens, [ref] $errors)
fixture-lines=0 runtime-blocks=0 runtime-load-lines=2
```

=== REF tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1
```
fixture-lines=0 runtime-blocks=0 runtime-load-lines=0
```

=== REF tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
```
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Discovery.Helpers.ps1')
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Compliance.Helpers.ps1')
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Discovery.Helpers.ps1')
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Compliance.Helpers.ps1')
RUNTIME:         }.GetNewClosure()
RUNTIME:         $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref] $tokens, [ref] $errors)
RUNTIME:         $hook = "`$modulePath = Join-Path `$PSScriptRoot '../lib/fixture/b.psm1'`nImport-Module `$modulePath`n"
RUNTIME:         # Arrange: a direct null Mock of the script-scope seam after the dot-source, with no Import-Module.
fixture-lines=12 runtime-blocks=23 runtime-load-lines=10
```

=== REF tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
```
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
RUNTIME:             $ast = [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)
RUNTIME:                 Name     = 'an Import-Module with -Force'
RUNTIME:                 Expected = 'Import-Module of WorktreeRunResolution.psm1 missing from outermost BeforeAll'
RUNTIME:                 Expected = 'Import-Module of WorktreeRunResolution.psm1 uses -Force'
RUNTIME:             $ast = [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)
RUNTIME:         Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/EpicScopeResolution.psm1') -Force
RUNTIME:         Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')
RUNTIME:             Mock Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution { $hostileText }.GetNewClosure()
RUNTIME:             Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $hostileText }.GetNewClosure()
fixture-lines=110 runtime-blocks=9 runtime-load-lines=10
```

=== REF tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1
```
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
RUNTIME:         return [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)
RUNTIME:             Expected = 'Import-Module of EpicScopeResolution.psm1 missing'
fixture-lines=74 runtime-blocks=4 runtime-load-lines=3
```

=== REF tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1
```
RUNTIME:     . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')
RUNTIME:         return [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)
RUNTIME:         ($findings -join '; ') | Should -BeLike '*Import-Module of EpicScopeResolution.psm1 missing*'
fixture-lines=111 runtime-blocks=11 runtime-load-lines=3
```

After the task: `git status --porcelain -- tests` empty.
