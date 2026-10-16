#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #937 - path-not-local rows U27 to U31 of the preimplementation gate targets module, moved
# unchanged from enforce-orchestration-preimplementation-gate-targets.Tests.ps1 (remediation RI-8)
# so that each suite stays within the 500-line cap. Each row runs once against the Claude copy and
# once against the Codex copy. The Describe name equals the source suite's, so testcase names are
# unchanged. The session root is a synthetic literal. The file creates no file and starts no process.

Describe 'preimplementation gate targets (<Surface>)' -ForEach @(
    @{ Surface = '.claude/hooks' }
    @{ Surface = '.codex/hooks' }
) {
    BeforeAll {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        $surfaceRoot = Join-Path $repoRoot $Surface
        . (Join-Path $surfaceRoot 'hook-command-scanner.ps1')
        . (Join-Path $surfaceRoot 'hook-command-invocation.ps1')
        . (Join-Path $surfaceRoot 'enforce-orchestration-preimplementation-gate-targets.ps1')
        $script:Root = '/synthetic-worktrees/session'
    }

    It 'U27 gives path-not-local for <Label>' -ForEach @(
        @{ Label = 'unc-backslash'; Spelling = '\\server\share\wt\a.ps1' }
        @{ Label = 'unc-forward'; Spelling = '//server/share/wt/a.ps1' }
        @{ Label = 'unc-mixed-backslash-first'; Spelling = '\/server/share/a.ps1' }
        @{ Label = 'unc-mixed-forward-first'; Spelling = '/\server\share\a.ps1' }
        @{ Label = 'bare-double-backslash'; Spelling = '\\' }
        @{ Label = 'bare-double-forward'; Spelling = '//' }
        @{ Label = 'extended-length-backslash'; Spelling = '\\?\C:\wt\a.ps1' }
        @{ Label = 'extended-length-forward'; Spelling = '//?/C:/wt/a.ps1' }
        @{ Label = 'extended-length-unc'; Spelling = '\\?\UNC\server\share\a.ps1' }
        @{ Label = 'device-backslash'; Spelling = '\\.\C:\wt\a.ps1' }
        @{ Label = 'device-forward'; Spelling = '//./C:/wt/a.ps1' }
        @{ Label = 'nt-object-backslash'; Spelling = '\??\C:\wt\a.ps1' }
        @{ Label = 'nt-object-forward'; Spelling = '/??/C:/wt/a.ps1' }
        @{ Label = 'drive-relative'; Spelling = 'C:wt\a.ps1' }
        @{ Label = 'bare-drive-letter'; Spelling = 'C:' }
        @{ Label = 'leading-space-unc'; Spelling = ' \\server\share\a.ps1' }
        @{ Label = 'leading-space-absolute'; Spelling = ' /synthetic-worktrees/other/a.ps1' }
        @{ Label = 'trailing-space-absolute'; Spelling = '/synthetic-worktrees/other/a.ps1 ' }
        @{ Label = 'file-uri-drive'; Spelling = 'file:///C:/wt/a.ps1' }
        @{ Label = 'file-uri-unc'; Spelling = 'file://server/share/a.ps1' }
        @{ Label = 'tilde-forward'; Spelling = '~/wt/a.ps1' }
        @{ Label = 'tilde-backslash'; Spelling = '~\wt\a.ps1' }
        @{ Label = 'root-relative-backslash'; Spelling = '\wt\a.ps1' }
        @{ Label = 'http-uri'; Spelling = 'http://server/share/a.ps1' }
        @{ Label = 'smb-uri'; Spelling = 'smb://server/share/a.ps1' }
        @{ Label = 'vscode-remote-uri'; Spelling = 'vscode-remote://wsl/wt/a.ps1' }
        @{ Label = 'scheme-plus-uri'; Spelling = 'git+ssh://server/repo/a.ps1' }
    ) {
        # Arrange (issue #937): the raw path-leg spelling comes from the data row.

        # Act
        $result = Get-OrchestrationCommandTarget -FilePath @($Spelling) -SessionRoot $script:Root

        # Assert
        $resolvedBecause = "$Label is not a local path and must not resolve to the session root"
        $result.Resolved | Should -BeFalse -Because $resolvedBecause
        @($result.Targets).Count | Should -Be 0 -Because 'an unresolved result carries no targets'
        $result.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $detailBecause = 'the detail names the rule and the raw input'
        $result.Detail | Should -BeExactly ('path-not-local: ' + $Spelling) -Because $detailBecause
    }

    It 'U28 keeps a bare drive root path-leg input as its own target (<Label>)' -ForEach @(
        @{ Label = 'drive-root-backslash'; Spelling = 'C:\' }
        @{ Label = 'drive-root-forward'; Spelling = 'C:/' }
    ) {
        # Arrange (issue #937): a separator after the colon makes the spelling a drive root.

        # Act
        $result = Get-OrchestrationCommandTarget -FilePath @($Spelling) -SessionRoot $script:Root

        # Assert
        $result.Resolved | Should -BeTrue -Because "$Label is an absolute local drive root"
        $result.Targets | Should -Be @('C:/') -Because 'a bare drive root is contributed as its own target'
    }

    It 'U29 denies a non-local path-leg input even when a sibling path is valid' {
        # Arrange (issue #937)
        $paths = @('/synthetic-worktrees/other/a.ps1', '\\server\share\b.ps1')

        # Act
        $result = Get-OrchestrationCommandTarget -FilePath $paths -SessionRoot $script:Root

        # Assert
        $result.Resolved | Should -BeFalse -Because 'one non-local path makes the whole call unresolvable'
        @($result.Targets).Count | Should -Be 0 -Because 'an unresolved result carries no targets'
        $detailBecause = 'the first failing rule names the non-local path'
        $result.Detail | Should -BeExactly 'path-not-local: \\server\share\b.ps1' -Because $detailBecause
    }

    It 'U30 reports path-not-local before path-dot-segment for a UNC dot-dot path' {
        # Arrange (issue #937)
        $paths = @('\\server\share\..\x')

        # Act
        $result = Get-OrchestrationCommandTarget -FilePath $paths -SessionRoot $script:Root

        # Assert
        $result.Resolved | Should -BeFalse -Because 'a UNC path is not a local path'
        @($result.Targets).Count | Should -Be 0 -Because 'an unresolved result carries no targets'
        $result.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $detailBecause = 'the non-local check precedes the dot-segment check'
        $result.Detail | Should -BeExactly 'path-not-local: \\server\share\..\x' -Because $detailBecause
    }

    It 'U31 gives path-not-local for a non-local apply_patch marker path' {
        # Arrange (issue #937)
        $patch = "*** Begin Patch`n*** Update File: \\?\C:\wt\a.ps1`n@@`n-old`n+new`n*** End Patch"
        $paths = @(Get-OrchestrationPatchMarkerPath -PatchText $patch)

        # Act
        $result = Get-OrchestrationCommandTarget -FilePath $paths -SessionRoot $script:Root

        # Assert
        $paths | Should -Be @('\\?\C:\wt\a.ps1') -Because 'the marker path is extracted unchanged'
        $result.Resolved | Should -BeFalse -Because 'an extended-length marker path is not a local path'
        $detailBecause = 'the detail names the rule and the raw marker path'
        $result.Detail | Should -BeExactly 'path-not-local: \\?\C:\wt\a.ps1' -Because $detailBecause
    }

    It 'U32 keeps a relative path-leg input with a later colon on the session root' {
        # Arrange (issue #937 RI-7): a colon after a separator does not form a URI scheme.

        # Act
        $result = Get-OrchestrationCommandTarget -FilePath @('scripts/a:b.ps1') -SessionRoot $script:Root

        # Assert
        $result.Resolved | Should -BeTrue -Because 'a relative path with a later colon is not a URI scheme'
        $result.Targets | Should -Be @($script:Root) -Because 'a relative path is resolved against the session root'
    }
}
