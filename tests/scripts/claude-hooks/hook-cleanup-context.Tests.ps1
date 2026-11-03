#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Pure-function rows for hook-cleanup-context.ps1 (issue #1026).

.DESCRIPTION
    Every row runs over both repository copies of the file, .claude/hooks and .codex/hooks, so
    each copy is measured as its own production file. The functions are pure, so every input is
    an in-memory string or record: no row reads or writes a file, starts a process, reads a
    clock (the current time is a fixed value passed through -UtcNow), or reads the environment.
    Paths are POSIX-rooted synthetic values, so the rows behave the same on Windows and Linux.
#>

Describe 'hook-cleanup-context.ps1 (<Copy>)' -ForEach @(@{ Copy = '.claude' }, @{ Copy = '.codex' }) {
    BeforeAll {
        . (Resolve-Path "$PSScriptRoot/../../../$Copy/hooks/hook-cleanup-context.ps1").Path

        $script:Now = [datetime]::new(2026, 11, 3, 12, 0, 0, [System.DateTimeKind]::Utc)
        $script:Fresh = '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":"run-1026","removals":[]}'
        $script:LongTemp = '/synthetic-users/LongUserName/AppData/Local/Temp/'
        $script:ShortTemp = '/synthetic-users/LONGUS~1/AppData/Local/Temp'
        $script:Session = '/synthetic-worktrees/main'
        $script:Roots = @('/synthetic-worktrees/main', '/synthetic-worktrees/documentationandmemories')

        function New-CleanupRecord {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture builder; it changes no system state.')]
            param([string] $Root, [AllowNull()][string] $Branch, [switch] $Prunable)
            return [pscustomobject]@{ Root = $Root; Branch = $Branch; Bare = $false; Prunable = [bool]$Prunable }
        }
    }

    Context 'Test-CleanupManifestText' {
        It 'accepts a manifest header with tool cleanup-merged-worktrees and integer schema_version 1' {
            # Act / Assert
            Test-CleanupManifestText -Raw '{"tool":"cleanup-merged-worktrees","schema_version":1}' | Should -BeTrue
        }

        It 'accepts a fresh manifest with a run_id when -UtcNow is supplied' {
            # Act / Assert
            Test-CleanupManifestText -Raw $script:Fresh -UtcNow $script:Now | Should -BeTrue
            Test-CleanupManifestText -Raw '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-02T12:00:00Z","run_id":"r"}' -UtcNow $script:Now | Should -BeTrue -Because 'exactly 24 hours old is within the bound'
        }

        It 'rejects a manifest with a wrong tool, a non-integer or wrong schema_version, an unparseable, future, or stale generated_at, or an empty run_id' {
            # Arrange
            $cases = @(
                '{"tool":"cleanup-merged-worktreesX","schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":"r"}'
                '{"tool":"Cleanup-Merged-Worktrees","schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":"r"}'
                '{"tool":5,"schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":"r"}'
                '{"tool":"cleanup-merged-worktrees","schema_version":"1","generated_at":"2026-11-03T11:00:00Z","run_id":"r"}'
                '{"tool":"cleanup-merged-worktrees","schema_version":1.5,"generated_at":"2026-11-03T11:00:00Z","run_id":"r"}'
                '{"tool":"cleanup-merged-worktrees","schema_version":2,"generated_at":"2026-11-03T11:00:00Z","run_id":"r"}'
                '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"not a time","run_id":"r"}'
                '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-03T12:30:00Z","run_id":"r"}'
                '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-02T11:59:00Z","run_id":"r"}'
                '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":""}'
                '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":"   "}'
                '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-03T11:00:00Z","run_id":7}'
                '{"tool":"cleanup-merged-worktrees","schema_version":1,"generated_at":"2026-11-03T11:00:00Z"}'
                '{"tool":"cleanup-merged-worktrees","schema_version":1,"run_id":"r"}'
            )

            # Act / Assert
            foreach ($raw in $cases) {
                Test-CleanupManifestText -Raw $raw -UtcNow $script:Now | Should -BeFalse -Because "the manifest '$raw' is not valid"
            }
            Test-CleanupManifestText -Raw $cases[0] | Should -BeFalse -Because 'the header check applies without -UtcNow'
            Test-CleanupManifestText -Raw $cases[5] | Should -BeFalse -Because 'the header check applies without -UtcNow'
        }

        It 'rejects blank, unparseable, non-object, and header-incomplete text' {
            # Arrange
            $cases = @($null, '', '   ', '{not json', '[1,2]', '5', '"text"', '{"schema_version":1}', '{"tool":"cleanup-merged-worktrees"}')

            # Act / Assert
            foreach ($raw in $cases) {
                Test-CleanupManifestText -Raw $raw | Should -BeFalse -Because "the text '$raw' is not a manifest header"
            }
        }
    }

    Context 'Test-CleanupConsolidationRelativePath' {
        It 'accepts paths under docs/ and .claude/agent-memory/' {
            # Act / Assert
            foreach ($path in @('docs/research/y.md', 'docs/features/active/x-1/spec.md', '.claude/agent-memory/atomic-executor/MEMORY.md', 'docs/a_b-c.txt')) {
                Test-CleanupConsolidationRelativePath -RelativePath $path | Should -BeTrue -Because "'$path' is allowlisted"
            }
        }

        It 'rejects **/*.md paths outside docs/ and .claude/agent-memory/' {
            # Act / Assert
            foreach ($path in @('CLAUDE.md', '.claude/rules/x.md', '.github/copilot-instructions.md', '.claude/skills/x/SKILL.md', 'scripts/a.ps1', 'README.md')) {
                Test-CleanupConsolidationRelativePath -RelativePath $path | Should -BeFalse -Because "'$path' is outside the allowlist"
            }
        }

        It 'compares the allowlist prefixes case-sensitively' {
            # Act / Assert
            foreach ($path in @('Docs/research/y.md', 'DOCS/y.md', '.Claude/agent-memory/x/y.md', '.claude/Agent-Memory/x/y.md')) {
                Test-CleanupConsolidationRelativePath -RelativePath $path | Should -BeFalse -Because "'$path' differs from the prefix only by case"
            }
        }

        It 'rejects operands with a .. segment or a character outside the plain set' {
            # Act / Assert
            foreach ($path in @('docs/../scripts/a.ps1', 'docs/x/../../CLAUDE.md', '.claude/agent-memory/../rules/x.md', 'docs/a b.md', 'docs\research\y.md', 'docs/*.md', ':(top)docs/y.md', 'docs/y.md;rm', ('docs/caf' + [char]0x00E9 + '.md'))) {
                Test-CleanupConsolidationRelativePath -RelativePath $path | Should -BeFalse -Because "'$path' is not a plain relative operand"
            }
        }

        It 'rejects a rooted path, a bare prefix, and blank input' {
            # Act / Assert
            foreach ($path in @('/docs/y.md', 'docs/', '.claude/agent-memory/', '', $null)) {
                Test-CleanupConsolidationRelativePath -RelativePath $path | Should -BeFalse -Because "'$path' names no allowlisted file"
            }
        }

        It 'admits the pr-author receipt only with -AllowReceipt' {
            # Act / Assert
            Test-CleanupConsolidationRelativePath -RelativePath 'artifacts/pr_body_7.receipt.json' -AllowReceipt | Should -BeTrue
            Test-CleanupConsolidationRelativePath -RelativePath 'artifacts/pr_body_7.receipt.json' | Should -BeFalse
            foreach ($path in @('artifacts/pr_body_.receipt.json', 'artifacts/pr_body_7.md', 'artifacts/pr_body_x.receipt.json', 'artifacts/orchestration/orchestrator-state.json', 'Artifacts/pr_body_7.receipt.json')) {
                Test-CleanupConsolidationRelativePath -RelativePath $path -AllowReceipt | Should -BeFalse -Because "'$path' is not the receipt path"
            }
        }
    }

    Context 'Find-CleanupConsolidationRecord' {
        It 'returns the single linked record on branch documentationandmemories' {
            # Arrange
            $records = @(
                (New-CleanupRecord -Root '/synthetic-worktrees/main' -Branch 'main'),
                (New-CleanupRecord -Root '/synthetic-worktrees/feature' -Branch 'bug/example'),
                (New-CleanupRecord -Root '/synthetic-worktrees/any-path' -Branch 'documentationandmemories')
            )

            # Act
            $found = Find-CleanupConsolidationRecord -Record $records

            # Assert
            $found.Root | Should -Be '/synthetic-worktrees/any-path'
        }

        It 'skips prunable, detached, and main-stanza records' {
            # Arrange
            $mainStanza = @((New-CleanupRecord -Root '/synthetic-worktrees/main' -Branch 'documentationandmemories'), (New-CleanupRecord -Root '/synthetic-worktrees/f' -Branch 'bug/example'))
            $prunable = @((New-CleanupRecord -Root '/synthetic-worktrees/main' -Branch 'main'), (New-CleanupRecord -Root '/synthetic-worktrees/c' -Branch 'documentationandmemories' -Prunable))
            $detached = @((New-CleanupRecord -Root '/synthetic-worktrees/main' -Branch 'main'), (New-CleanupRecord -Root '/synthetic-worktrees/documentationandmemories' -Branch $null))

            # Act / Assert
            Find-CleanupConsolidationRecord -Record $mainStanza | Should -BeNullOrEmpty
            Find-CleanupConsolidationRecord -Record $prunable | Should -BeNullOrEmpty
            Find-CleanupConsolidationRecord -Record $detached | Should -BeNullOrEmpty -Because 'the path is never consulted'
        }

        It 'returns no record for a duplicate, a case variant, an absent branch, or empty input' {
            # Arrange
            $main = New-CleanupRecord -Root '/synthetic-worktrees/main' -Branch 'main'
            $duplicate = @($main, (New-CleanupRecord -Root '/synthetic-worktrees/a' -Branch 'documentationandmemories'), (New-CleanupRecord -Root '/synthetic-worktrees/b' -Branch 'documentationandmemories'))
            $caseVariant = @($main, (New-CleanupRecord -Root '/synthetic-worktrees/a' -Branch 'DocumentationAndMemories'))
            $absent = @($main, (New-CleanupRecord -Root '/synthetic-worktrees/documentationandmemories' -Branch 'bug/example'))

            # Act / Assert
            Find-CleanupConsolidationRecord -Record $duplicate | Should -BeNullOrEmpty
            Find-CleanupConsolidationRecord -Record $caseVariant | Should -BeNullOrEmpty
            Find-CleanupConsolidationRecord -Record $absent | Should -BeNullOrEmpty
            Find-CleanupConsolidationRecord -Record @() | Should -BeNullOrEmpty
            Find-CleanupConsolidationRecord -Record $null | Should -BeNullOrEmpty
        }
    }

    Context 'Test-CleanupScratchPath' {
        It 'accepts both temporary-root spellings and rejects a path inside a registered worktree or the session root' {
            # Arrange
            $temporary = @($script:LongTemp, $script:ShortTemp)

            # Act / Assert
            Test-CleanupScratchPath -Path '/synthetic-users/LongUserName/AppData/Local/Temp/claude/s/issue-1026/a.ps1' -RegisteredRoot $script:Roots -SessionRoot $script:Session -TemporaryRoot $temporary | Should -BeTrue
            Test-CleanupScratchPath -Path '/synthetic-users/longus~1/appdata/local/temp/claude/s/issue-1026/a.ps1' -RegisteredRoot $script:Roots -SessionRoot $script:Session -TemporaryRoot $temporary | Should -BeTrue -Because 'the comparison ignores case'
            Test-CleanupScratchPath -Path '/synthetic-worktrees/documentationandmemories/scripts/a.ps1' -RegisteredRoot $script:Roots -SessionRoot $script:Session -TemporaryRoot $temporary | Should -BeFalse
            Test-CleanupScratchPath -Path '/synthetic-users/LongUserName/AppData/Local/Temp/session/a.ps1' -RegisteredRoot $script:Roots -SessionRoot '/synthetic-users/LongUserName/AppData/Local/Temp/session' -TemporaryRoot $temporary | Should -BeFalse -Because 'the path is inside the session root'
            Test-CleanupScratchPath -Path '/synthetic-elsewhere/a.ps1' -RegisteredRoot $script:Roots -SessionRoot $script:Session -TemporaryRoot $temporary | Should -BeFalse -Because 'the path is not under a temporary root'
        }

        It 'rejects a scratch path when a registered worktree lies under the temporary root' {
            # Arrange
            $roots = @('/synthetic-worktrees/main', '/synthetic-users/LONGUS~1/AppData/Local/Temp/wt/item')

            # Act / Assert
            Test-CleanupScratchPath -Path '/synthetic-users/LONGUS~1/AppData/Local/Temp/claude/a.ps1' -RegisteredRoot $roots -SessionRoot $script:Session -TemporaryRoot @($script:ShortTemp) | Should -BeFalse
        }

        It 'rejects relative, UNC, dot-segment, padded, blank, and temporary-root-itself paths and missing roots' {
            # Arrange
            $temporary = @($script:LongTemp)

            # Act / Assert
            foreach ($path in @('claude/a.ps1', '//server/share/Temp/a.ps1', '/synthetic-users/LongUserName/AppData/Local/Temp/../a.ps1', '/synthetic-users/LongUserName/AppData/Local/Temp/./a.ps1', ' /synthetic-users/LongUserName/AppData/Local/Temp/a.ps1', '', $null, '/synthetic-users/LongUserName/AppData/Local/Temp')) {
                Test-CleanupScratchPath -Path $path -RegisteredRoot $script:Roots -SessionRoot $script:Session -TemporaryRoot $temporary | Should -BeFalse -Because "'$path' is not a scratch path"
            }
            $scratch = '/synthetic-users/LongUserName/AppData/Local/Temp/a.ps1'
            Test-CleanupScratchPath -Path $scratch -RegisteredRoot @() -SessionRoot $script:Session -TemporaryRoot $temporary | Should -BeFalse
            Test-CleanupScratchPath -Path $scratch -RegisteredRoot $script:Roots -SessionRoot $script:Session -TemporaryRoot @() | Should -BeFalse
            Test-CleanupScratchPath -Path $scratch -RegisteredRoot $script:Roots -SessionRoot '' -TemporaryRoot $temporary | Should -BeFalse
        }

        It 'accepts a drive-rooted spelling with either separator' {
            # Act / Assert
            Test-CleanupScratchPath -Path 'X:\Temp\claude\a.ps1' -RegisteredRoot @('X:/repos/main') -SessionRoot 'X:/repos/main' -TemporaryRoot @('X:\Temp\') | Should -BeTrue
            Test-CleanupScratchPath -Path 'X:\Other\a.ps1' -RegisteredRoot @('X:/repos/main') -SessionRoot 'X:/repos/main' -TemporaryRoot @('X:\Temp\') | Should -BeFalse -Because 'the path is not under the temporary root'
        }
    }

    Context 'Test-CleanupConsolidationBranchLabel' {
        It 'accepts exactly one own-line branch: documentationandmemories label' {
            # Act / Assert
            Test-CleanupConsolidationBranchLabel -PromptText "Open the consolidation pull request.`nbranch: documentationandmemories`nUse the absolute body path." | Should -BeTrue
            Test-CleanupConsolidationBranchLabel -PromptText "branch:documentationandmemories`r`n" | Should -BeTrue
        }

        It 'rejects a different branch, a repeated label, a head or branch flag, a capitalized label, trailing text, and blank input' {
            # Arrange
            $cases = @(
                'branch: bug/example'
                'branch: DocumentationAndMemories'
                "branch: documentationandmemories`nbranch: documentationandmemories"
                "branch: documentationandmemories`nUse --head bug/example."
                "branch: documentationandmemories`nUse --branch=bug/example."
                'Branch: documentationandmemories'
                'branch: documentationandmemories.'
                'Delegate with branch: documentationandmemories'
                ''
                $null
            )

            # Act / Assert
            foreach ($prompt in $cases) {
                Test-CleanupConsolidationBranchLabel -PromptText $prompt | Should -BeFalse -Because "the prompt '$prompt' must not qualify"
            }
        }
    }

    Context 'restated literals' {
        It 'restates the branch, manifest path, tool, schema version, and freshness bound' {
            # Assert
            $script:CleanupContextBranch | Should -BeExactly 'documentationandmemories'
            $script:CleanupContextManifestRelativePath | Should -BeExactly 'artifacts/orchestration/cleanup-worktrees-manifest.json'
            $script:CleanupContextManifestTool | Should -BeExactly 'cleanup-merged-worktrees'
            $script:CleanupContextManifestSchemaVersion | Should -Be 1
            $script:CleanupContextFreshnessHours | Should -Be 24
        }
    }
}
