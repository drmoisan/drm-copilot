#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Matcher, path-equality, main-checkout-root, and export tests for WorktreeRunRecordPath.psm1 (issue #995).

.DESCRIPTION
    Covers Test-WorktreeRunRecordedPathMatchesTarget (relative joins to each base root,
    rooted pass-through, separator and trailing-slash tolerance, the case rule, and every
    unsafe relative record), Test-WorktreeRunPathEqual (moved from
    WorktreeRunResolution.psm1), Get-WorktreeRunMainCheckoutRoot over mocked seams, and the
    module's export list.

    The two comparison functions are pure, so they run on literal strings. The main-root
    function's seams, Get-WorktreeItemLiveRoot and Get-WorktreeResolutionGitEntryKind, are
    mocked with -ModuleName 'WorktreeRunRecordPath'. This suite runs only in the Windows
    shards, so drive-letter and UNC literals are permitted here. No test creates or writes a
    file, reads a wall clock, starts a process, or touches the network.
#>

BeforeAll {
    $script:LibRoot = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/worktree-resolution").Path
    Import-Module (Join-Path $script:LibRoot 'WorktreeRunRecordPath.psm1')
    $script:Main = '/synthetic-worktrees/main'
    $script:Planning = '/synthetic-worktrees/planning'
    $script:Relative = '.claude/worktrees/agent-x'
    $script:Target = '/synthetic-worktrees/main/.claude/worktrees/agent-x'

    # Issue #1163 (D9) argument builder: -RecordedBranch, -LiveWorktreeRoot, and -BranchWorktreeResolver
    # are passed only when Get-Command reports that the matcher declares them, so the M12 to M16 rows
    # run unchanged against the unmodified module (fail-before) and the changed module.
    function Get-RecordPathFallbackArgument {
        param([string] $RecordedPath, [string] $TargetPath, [string] $Branch, [string[]] $Live, [scriptblock] $Resolver)
        $arguments = @{ RecordedPath = $RecordedPath; TargetPath = $TargetPath }
        $parameters = (Get-Command -Name Test-WorktreeRunRecordedPathMatchesTarget).Parameters
        if ($parameters.ContainsKey('RecordedBranch')) { $arguments['RecordedBranch'] = $Branch }
        if ($parameters.ContainsKey('LiveWorktreeRoot')) { $arguments['LiveWorktreeRoot'] = $Live }
        if ($parameters.ContainsKey('BranchWorktreeResolver')) { $arguments['BranchWorktreeResolver'] = $Resolver }
        return $arguments
    }

    # The D9 resolver seam: a mapped branch gives its root and no reason code, an unmapped branch gives
    # a null root and ReasonCode, and every invocation is appended to the row's Calls list.
    function Get-BranchResolverSeam {
        param([hashtable] $Map = @{}, [string] $ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE', [System.Collections.Generic.List[string]] $Calls)
        $branchMap = $Map; $code = $ReasonCode; $callList = $Calls
        return {
            param($Branch)
            $callList.Add([string] $Branch)
            if ($branchMap.ContainsKey([string] $Branch)) { return [pscustomobject]@{ WorktreeRoot = $branchMap[[string] $Branch]; ReasonCode = $null } }
            return [pscustomobject]@{ WorktreeRoot = $null; ReasonCode = $code }
        }.GetNewClosure()
    }
}

Describe 'Test-WorktreeRunRecordedPathMatchesTarget' {
    It 'M1 matches a relative record joined to the main checkout root' {
        # Arrange / Act
        $result = Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath $script:Relative -TargetPath $script:Target -BaseRoot @($script:Main, $script:Planning)

        # Assert
        $result | Should -BeTrue -Because 'the record joined to the main root is the target'
    }

    It 'M2 matches a relative record through the second base root only' {
        # Arrange
        $target = '/synthetic-worktrees/planning/.claude/worktrees/agent-x'

        # Act
        $result = Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath $script:Relative -TargetPath $target -BaseRoot @($script:Main, $script:Planning)

        # Assert
        $result | Should -BeTrue -Because 'the join to the checkpoint root is the target'
    }

    It 'M3 matches with backslash separators and a trailing separator on <Label>' -ForEach @(
        @{ Label = 'the record'; Recorded = '.claude\worktrees\agent-x\'; Target = '/synthetic-worktrees/main/.claude/worktrees/agent-x'; Root = '/synthetic-worktrees/main' }
        @{ Label = 'the target'; Recorded = '.claude/worktrees/agent-x'; Target = 'C:\repo\.claude\worktrees\agent-x\'; Root = 'C:/repo' }
        @{ Label = 'the base root'; Recorded = '.claude/worktrees/agent-x'; Target = 'C:/repo/.claude/worktrees/agent-x'; Root = 'C:\repo\' }
    ) {
        # Arrange / Act
        $result = Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath $Recorded -TargetPath $Target -BaseRoot @($Root)

        # Assert
        $result | Should -BeTrue
    }

    It 'M4 matches a rooted POSIX record exactly and without base roots' {
        # Arrange / Act
        $result = Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath '/wt/item-a/' -TargetPath '/wt/item-a'

        # Assert
        $result | Should -BeTrue
    }

    It 'M5 does not match a rooted POSIX record against a case variant' {
        # Arrange / Act
        $result = Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath '/wt/item-a' -TargetPath '/wt/Item-A' -BaseRoot @($script:Main)

        # Assert
        $result | Should -BeFalse -Because 'a single-slash root compares ordinally'
    }

    It 'M6 matches a <Label> record against a case variant' -ForEach @(
        @{ Label = 'drive-letter'; Recorded = 'c:\wt\a\'; Target = 'C:/Wt/A' }
        @{ Label = 'UNC'; Recorded = '//Server/Share/x'; Target = '\\server\share\X' }
    ) {
        # Arrange / Act
        $result = Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath $Recorded -TargetPath $Target

        # Assert
        $result | Should -BeTrue
    }

    It 'M7 matches no target for the unsafe relative record <Label>' -ForEach @(
        @{ Label = 'blank'; Recorded = '' }
        @{ Label = 'whitespace'; Recorded = '   ' }
        @{ Label = '.'; Recorded = '.' }
        @{ Label = '..'; Recorded = '..' }
        @{ Label = 'a/../b'; Recorded = 'a/../b' }
        @{ Label = './a'; Recorded = './a' }
        @{ Label = 'a/./b'; Recorded = 'a/./b' }
        @{ Label = 'c:x'; Recorded = 'c:x' }
    ) {
        # Arrange: the candidate targets include the main root itself and each plausible join.
        $targets = @($script:Main, '/synthetic-worktrees', '/synthetic-worktrees/main/b', '/synthetic-worktrees/main/a', '/synthetic-worktrees/main/a/b', '/synthetic-worktrees/main/c:x')

        # Act
        $matched = @($targets | Where-Object { Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath $Recorded -TargetPath $_ -BaseRoot @($script:Main, $script:Planning) })

        # Assert
        $matched.Count | Should -Be 0 -Because "the record '$Recorded' is unsafe and must match nothing"
    }

    It 'M8 matches nothing for a relative record with an empty base-root list' {
        # Arrange / Act
        $result = Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath $script:Relative -TargetPath $script:Target -BaseRoot @()

        # Assert
        $result | Should -BeFalse
    }

    It 'M9 skips blank base roots' {
        # Arrange / Act
        $result = Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath $script:Relative -TargetPath $script:Target -BaseRoot @('', '  ', $null, $script:Main)

        # Assert
        $result | Should -BeTrue
    }

    It 'M10 matches nothing for a blank target' {
        # Arrange / Act
        $result = Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath $script:Relative -TargetPath '' -BaseRoot @($script:Main)

        # Assert
        $result | Should -BeFalse
    }

    It 'M11 does not match a relative record for a different agent directory' {
        # Arrange / Act
        $result = Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath '.claude/worktrees/agent-y' -TargetPath $script:Target -BaseRoot @($script:Main)

        # Assert
        $result | Should -BeFalse
    }

    Context 'recorded branch fallback (issue #1163)' {
        BeforeAll {
            $script:FallbackTarget = '/repo/.claude/worktrees/item'
            $script:FallbackLive = @('/repo', '/repo/.claude/worktrees/item', '/sibling/item-b')
        }

        It 'M12 matches a rooted record that names no live root through a branch that resolves to the target' {
            # Arrange (fails before: a host-moved absolute record never matches)
            $calls = [System.Collections.Generic.List[string]]::new()
            $resolver = Get-BranchResolverSeam -Map @{ 'feature/issue-1163-item' = $script:FallbackTarget } -Calls $calls
            $arguments = Get-RecordPathFallbackArgument -RecordedPath '/host-a/repo/.claude/worktrees/item' -TargetPath $script:FallbackTarget -Branch 'feature/issue-1163-item' -Live $script:FallbackLive -Resolver $resolver

            # Act
            $result = Test-WorktreeRunRecordedPathMatchesTarget @arguments

            # Assert
            $result | Should -BeTrue
            $calls.Count | Should -Be 1
        }

        It 'M13 does not match when the branch resolves to <ReasonCode>' -ForEach @(
            @{ ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE' }
            @{ ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS' }
        ) {
            # Arrange
            $calls = [System.Collections.Generic.List[string]]::new()
            $resolver = Get-BranchResolverSeam -ReasonCode $ReasonCode -Calls $calls
            $arguments = Get-RecordPathFallbackArgument -RecordedPath '/host-a/repo/.claude/worktrees/item' -TargetPath $script:FallbackTarget -Branch 'feature/issue-1163-item' -Live $script:FallbackLive -Resolver $resolver

            # Act
            $result = Test-WorktreeRunRecordedPathMatchesTarget @arguments

            # Assert
            $result | Should -BeFalse
        }

        It 'M14 does not match when the branch resolves to a different worktree' {
            # Arrange
            $calls = [System.Collections.Generic.List[string]]::new()
            $resolver = Get-BranchResolverSeam -Map @{ 'feature/issue-1163-item' = '/sibling/item-b' } -Calls $calls
            $arguments = Get-RecordPathFallbackArgument -RecordedPath '/host-a/repo/.claude/worktrees/item' -TargetPath $script:FallbackTarget -Branch 'feature/issue-1163-item' -Live $script:FallbackLive -Resolver $resolver

            # Act
            $result = Test-WorktreeRunRecordedPathMatchesTarget @arguments

            # Assert
            $result | Should -BeFalse
        }

        It "M15 returns today's result without calling the resolver for a rooted record that names a live root" {
            # Arrange
            $calls = [System.Collections.Generic.List[string]]::new()
            $resolver = Get-BranchResolverSeam -Map @{ 'feature/issue-1163-item' = $script:FallbackTarget } -Calls $calls
            $arguments = Get-RecordPathFallbackArgument -RecordedPath '/sibling/item-b' -TargetPath $script:FallbackTarget -Branch 'feature/issue-1163-item' -Live $script:FallbackLive -Resolver $resolver

            # Act
            $result = Test-WorktreeRunRecordedPathMatchesTarget @arguments

            # Assert
            $result | Should -BeFalse
            $calls.Count | Should -Be 0
        }

        It "M16 returns today's result for a relative record with a branch" {
            # Arrange
            $calls = [System.Collections.Generic.List[string]]::new()
            $resolver = Get-BranchResolverSeam -Map @{ 'feature/issue-1163-item' = $script:FallbackTarget } -Calls $calls
            $arguments = Get-RecordPathFallbackArgument -RecordedPath '.claude/worktrees/other' -TargetPath $script:FallbackTarget -Branch 'feature/issue-1163-item' -Live $script:FallbackLive -Resolver $resolver
            $arguments['BaseRoot'] = @('/repo')

            # Act
            $result = Test-WorktreeRunRecordedPathMatchesTarget @arguments

            # Assert
            $result | Should -BeFalse
            $calls.Count | Should -Be 0
        }
    }
}

Describe 'Test-WorktreeRunPathEqual' {
    It 'P1 compares across separator style and trailing slash' {
        # Arrange / Act / Assert
        Test-WorktreeRunPathEqual -Left 'C:\wt\child\' -Right 'C:/wt/child' | Should -BeTrue
    }

    It 'P2 compares single-slash POSIX paths case-sensitively' {
        # Arrange / Act / Assert
        Test-WorktreeRunPathEqual -Left '/wt/a' -Right '/wt/A' | Should -BeFalse
    }

    It 'P3 compares drive-letter paths case-insensitively' {
        # Arrange / Act / Assert
        Test-WorktreeRunPathEqual -Left 'c:\wt\a\' -Right 'C:/Wt/A' | Should -BeTrue
    }

    It 'P4 compares UNC paths case-insensitively' {
        # Arrange / Act / Assert
        Test-WorktreeRunPathEqual -Left '//Server/Share/x' -Right '//server/share/X' | Should -BeTrue
    }

    It 'P5 never matches a blank side' {
        # Arrange / Act / Assert
        Test-WorktreeRunPathEqual -Left '' -Right '/wt/a' | Should -BeFalse
        Test-WorktreeRunPathEqual -Left '/wt/a' -Right ' ' | Should -BeFalse
    }
}

Describe 'Get-WorktreeRunMainCheckoutRoot' {
    It 'R1 returns the first live root whose .git entry is a directory' {
        # Arrange
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeRunRecordPath -MockWith {
            , [string[]] @('/synthetic-worktrees/linked', '/synthetic-worktrees/main', '/synthetic-worktrees/other-main')
        }
        Mock -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName WorktreeRunRecordPath -MockWith {
            param([string] $Path)
            if ($Path -eq '/synthetic-worktrees/linked/.git') { return 'File' }
            return 'Directory'
        }

        # Act
        $root = Get-WorktreeRunMainCheckoutRoot -SessionRoot '/synthetic-worktrees/linked'

        # Assert
        $root | Should -Be '/synthetic-worktrees/main'
        Should -Invoke Get-WorktreeResolutionGitEntryKind -ModuleName WorktreeRunRecordPath -Times 2 -Exactly
    }

    It 'R2 returns $null when every live root has a .git file or no .git entry' {
        # Arrange
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeRunRecordPath -MockWith {
            , [string[]] @('/synthetic-worktrees/a', '/synthetic-worktrees/b')
        }
        Mock -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName WorktreeRunRecordPath -MockWith {
            param([string] $Path)
            if ($Path -eq '/synthetic-worktrees/a/.git') { return 'File' }
            return 'None'
        }

        # Act
        $root = Get-WorktreeRunMainCheckoutRoot -SessionRoot '/synthetic-worktrees/a'

        # Assert
        $root | Should -BeNullOrEmpty
    }

    It 'R3 returns $null for an empty live-root list without probing any entry' {
        # Arrange
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeRunRecordPath -MockWith { , [string[]] @() }
        Mock -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName WorktreeRunRecordPath -MockWith { 'Directory' }

        # Act
        $root = Get-WorktreeRunMainCheckoutRoot -SessionRoot '/synthetic-worktrees/none'

        # Assert
        $root | Should -BeNullOrEmpty
        Should -Invoke Get-WorktreeResolutionGitEntryKind -ModuleName WorktreeRunRecordPath -Times 0 -Exactly
    }

    It 'R4 skips a blank live root and probes the entry beneath a backslash root with forward slashes' {
        # Arrange
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeRunRecordPath -MockWith { , [string[]] @('', 'C:\repo\') }
        Mock -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName WorktreeRunRecordPath -MockWith { 'Directory' }

        # Act
        $root = Get-WorktreeRunMainCheckoutRoot -SessionRoot 'C:/repo'

        # Assert
        $root | Should -Be 'C:\repo\'
        Should -Invoke Get-WorktreeResolutionGitEntryKind -ModuleName WorktreeRunRecordPath -Times 1 -Exactly -ParameterFilter { $Path -eq 'C:/repo/.git' }
    }
}

Describe 'Get-WorktreeRunRecordBaseRoot' {
    It 'B1 returns the main root and the read root when both are present' {
        # Arrange
        $read = [pscustomobject]@{ Target = [pscustomobject]@{ WorktreeRoot = '/synthetic-worktrees/planning' } }

        # Act
        $roots = Get-WorktreeRunRecordBaseRoot -MainRoot $script:Main -Read $read

        # Assert
        $roots | Should -Be @('/synthetic-worktrees/main', '/synthetic-worktrees/planning')
    }

    It 'B2 returns only the main root when no read is supplied' {
        # Arrange / Act
        $roots = Get-WorktreeRunRecordBaseRoot -MainRoot $script:Main -Read $null

        # Assert
        @($roots).Count | Should -Be 1
        $roots[0] | Should -Be '/synthetic-worktrees/main'
    }

    It 'B3 returns only the read root for <Label> main root' -ForEach @(
        @{ Label = 'a null'; Main = $null }
        @{ Label = 'a blank'; Main = '  ' }
    ) {
        # Arrange
        $read = [pscustomobject]@{ Target = [pscustomobject]@{ WorktreeRoot = '/synthetic-worktrees/planning' } }

        # Act
        $roots = Get-WorktreeRunRecordBaseRoot -MainRoot $Main -Read $read

        # Assert
        @($roots).Count | Should -Be 1
        $roots[0] | Should -Be '/synthetic-worktrees/planning'
    }

    It 'B3b ignores a read whose <Label>' -ForEach @(
        @{ Label = 'Target is absent'; Read = [pscustomobject]@{ Other = 1 } }
        @{ Label = 'Target is null'; Read = [pscustomobject]@{ Target = $null } }
        @{ Label = 'Target has no WorktreeRoot'; Read = [pscustomobject]@{ Target = [pscustomobject]@{ Status = 'Unresolved' } } }
    ) {
        # Arrange / Act
        $roots = Get-WorktreeRunRecordBaseRoot -MainRoot $script:Main -Read $Read

        # Assert
        @($roots).Count | Should -Be 1
        $roots[0] | Should -Be '/synthetic-worktrees/main'
    }

    It 'B4 returns an empty string array, not null, when neither root is present' {
        # Arrange / Act
        $roots = Get-WorktreeRunRecordBaseRoot -MainRoot $null -Read $null

        # Assert
        $null -ne $roots | Should -BeTrue -Because 'the comma operator preserves the empty array'
        $roots -is [string[]] | Should -BeTrue
        $roots.Count | Should -Be 0
    }
}

Describe 'WorktreeRunRecordPath module exports' {
    It 'X1 exports exactly the four record-path functions' {
        # Arrange
        $expected = @('Get-WorktreeRunMainCheckoutRoot', 'Get-WorktreeRunRecordBaseRoot', 'Test-WorktreeRunPathEqual', 'Test-WorktreeRunRecordedPathMatchesTarget')

        # Act
        $exported = @((Get-Module -Name WorktreeRunRecordPath | Select-Object -First 1).ExportedFunctions.Keys | Sort-Object)

        # Assert
        $exported | Should -Be ($expected | Sort-Object)
    }
}
