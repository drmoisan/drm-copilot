#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the worktree locator and path normaliser (issue #669).

.DESCRIPTION
    Covers the three filesystem seams, separator normalisation, the root-marker
    classifier, the upward ascent, the worktree enumerator, repo-relative
    normalisation, and the ambiguity reason code.

    Worktree topologies are modelled entirely by mocks of the module's three seams,
    registered with -ModuleName so they intercept the calls the module makes to
    itself. The seam default-body tests read existing tracked repository paths
    only. No test creates, writes, or reads a temporary file, reads a wall clock,
    spawns a process, or touches the network.
#>

BeforeAll {
    # Resolve the module four levels up (worktree-resolution -> claude-lib ->
    # scripts -> tests -> repo root). Resolve-Path normalizes separators so Pester
    # coverage breakpoints bind to the path the run settings name.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    Import-Module (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/worktree-resolution/WorktreeResolution.psm1").Path -Force

    function New-TestTopology {
        # Build an in-memory administrative layout: a main checkout at C:/repo plus
        # the supplied linked worktrees, each with its own admin directory.
        param([hashtable[]] $Linked = @(), [string[]] $Directory = @())

        $topology = @{
            Kind     = @{ 'C:/repo/.git' = 'Directory' }
            Text     = @{ 'C:/repo/.git/HEAD' = "ref: refs/heads/main`n" }
            Children = @{ 'C:/repo/.git/worktrees' = [string[]] @($Linked | ForEach-Object { $_.Name }) }
        }
        foreach ($worktree in $Linked) {
            $admin = "C:/repo/.git/worktrees/$($worktree.Name)"
            $topology.Kind["$($worktree.Root)/.git"] = 'File'
            $topology.Text["$($worktree.Root)/.git"] = "gitdir: $admin`n"
            $topology.Text["$admin/commondir"] = "../..`n"
            $topology.Text["$admin/gitdir"] = "$($worktree.Root)/.git`n"
            $topology.Text["$admin/HEAD"] = "ref: refs/heads/$($worktree.Branch)`n"
        }
        foreach ($path in $Directory) {
            $topology.Kind[$path] = 'Directory'
        }
        return $topology
    }

    function Set-TopologyMock {
        # Route the three seams to the $Topology variable of the calling test. The
        # mock bodies resolve $Topology when the seam is called, inside the test.
        Mock -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -MockWith {
            param([string] $Path)
            if ($Topology.Kind.ContainsKey($Path)) { $Topology.Kind[$Path] } else { 'None' }
        }
        Mock -CommandName Get-WorktreeResolutionGitFileText -ModuleName 'WorktreeResolution' -MockWith {
            param([string] $Path)
            $Topology.Text[$Path]
        }
        Mock -CommandName Get-WorktreeResolutionDirectoryChildName -ModuleName 'WorktreeResolution' -MockWith {
            param([string] $Path)
            if ($Topology.Children.ContainsKey($Path)) { , [string[]] $Topology.Children[$Path] } else { , [string[]] @() }
        }
    }

    $script:SessionWorktree = @{ Name = 'session'; Root = 'C:/repo-wt/session'; Branch = 'feature/session' }
    $script:ItemWorktree = @{ Name = 'item'; Root = 'C:/repo/.claude/worktrees/item'; Branch = 'feature/item-700' }
    $script:SiblingWorktree = @{ Name = 'sibling'; Root = 'C:/repo-wt/sibling'; Branch = 'feature/sibling-701' }
}

Describe 'WorktreeResolution seam default bodies' {
    It 'classifies an existing directory, an existing file, and an absent path' {
        # Purpose: the seam distinguishes the three kinds the root marker relies on.
        $directoryPath = Join-Path $script:RepoRoot '.claude/lib'
        $filePath = Join-Path $script:RepoRoot '.claude/lib/hook-payload/HookPayload.psm1'
        $absentPath = Join-Path $script:RepoRoot '.claude/lib/worktree-resolution-absent-sibling'

        $directoryKind = Get-WorktreeResolutionGitEntryKind -Path $directoryPath
        $fileKind = Get-WorktreeResolutionGitEntryKind -Path $filePath
        $absentKind = Get-WorktreeResolutionGitEntryKind -Path $absentPath

        $directoryKind | Should -BeExactly 'Directory'
        $fileKind | Should -BeExactly 'File'
        $absentKind | Should -BeExactly 'None'
    }

    It 'reads the raw text of a tracked file and returns null for an absent file' {
        # Purpose: the content is returned whole, and an absent file is not an error.
        $modulePath = Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeResolution.psm1'
        $absentPath = Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/absent.txt'

        $text = Get-WorktreeResolutionGitFileText -Path $modulePath
        $absentText = Get-WorktreeResolutionGitFileText -Path $absentPath

        $text | Should -BeLike '*Set-StrictMode*'
        $absentText | Should -BeNullOrEmpty
    }

    It 'lists child directory names as an array, empty for an absent directory' {
        # Purpose: both results are arrays, so a caller never branches on a scalar.
        $libraryPath = Join-Path $script:RepoRoot '.claude/lib'
        $absentPath = Join-Path $script:RepoRoot '.claude/lib/worktree-resolution-absent-sibling'

        $names = Get-WorktreeResolutionDirectoryChildName -Path $libraryPath
        $absentNames = Get-WorktreeResolutionDirectoryChildName -Path $absentPath

        , $names | Should -BeOfType [string[]]
        $names | Should -Contain 'worktree-resolution'
        , $absentNames | Should -BeOfType [string[]]
        $absentNames.Count | Should -Be 0
    }
}

Describe 'WorktreeResolution' {
    BeforeAll {
        # Default seam behavior: nothing exists. Tests that need a topology register
        # their own mocks; the innermost registration wins for that test only.
        Mock -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -MockWith { 'None' }
        Mock -CommandName Get-WorktreeResolutionGitFileText -ModuleName 'WorktreeResolution' -MockWith { $null }
        Mock -CommandName Get-WorktreeResolutionDirectoryChildName -ModuleName 'WorktreeResolution' -MockWith { , [string[]] @() }
    }

    Context 'path normalisation' {
        It 'normalises <Label> to <Expected>' -ForEach @(
            @{ Label = 'a backslash path'; InputPath = 'C:\repo\docs\features'; Expected = 'C:/repo/docs/features' }
            @{ Label = 'a forward-slash path'; InputPath = 'C:/repo/docs/features'; Expected = 'C:/repo/docs/features' }
            @{ Label = 'mixed and repeated separators'; InputPath = 'C:\repo//docs\\features'; Expected = 'C:/repo/docs/features' }
            @{ Label = 'a trailing slash'; InputPath = 'C:/repo/docs/'; Expected = 'C:/repo/docs' }
            @{ Label = 'a leading ./ segment'; InputPath = '././docs/features'; Expected = 'docs/features' }
            @{ Label = 'the filesystem root'; InputPath = '/'; Expected = '/' }
            @{ Label = 'a UNC share'; InputPath = '\\server\share\repo'; Expected = '//server/share/repo' }
        ) {
            # Purpose: one spelling per location, so later comparisons are exact.
            $actual = ConvertTo-WorktreeResolutionNormalizedPath -Path $InputPath

            $actual | Should -BeExactly $Expected
        }

        It 'returns null for <Label>' -ForEach @(
            @{ Label = 'a null input'; InputPath = $null }
            @{ Label = 'an empty input'; InputPath = '' }
            @{ Label = 'a whitespace input'; InputPath = '   ' }
            @{ Label = 'a bare ./ input'; InputPath = './' }
        ) {
            # Purpose: no path is invented from an empty input.
            $actual = ConvertTo-WorktreeResolutionNormalizedPath -Path $InputPath

            $actual | Should -BeNullOrEmpty
        }
    }

    Context 'root marker' {
        It 'treats a .git directory as a root marker' {
            # Purpose: a main checkout is a worktree root.
            Mock -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -MockWith { 'Directory' }

            Test-WorktreeResolutionRootMarker -Path 'C:/repo' | Should -BeTrue
        }

        It 'treats a .git file with a well-formed gitdir line as a root marker' {
            # Purpose: a linked worktree is a worktree root.
            Mock -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -MockWith { 'File' }
            Mock -CommandName Get-WorktreeResolutionGitFileText -ModuleName 'WorktreeResolution' -MockWith { "gitdir: C:/repo/.git/worktrees/item`r`n" }

            Test-WorktreeResolutionRootMarker -Path 'C:/repo/.claude/worktrees/item' | Should -BeTrue
        }

        It 'rejects a .git file whose text is <Label>' -ForEach @(
            @{ Label = 'malformed'; Text = 'this is not a pointer line' }
            @{ Label = 'empty'; Text = '' }
            @{ Label = 'unreadable'; Text = $null }
        ) {
            # Purpose: only a well-formed pointer marks a root.
            Mock -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -MockWith { 'File' }
            Mock -CommandName Get-WorktreeResolutionGitFileText -ModuleName 'WorktreeResolution' -MockWith { $Text }

            Test-WorktreeResolutionRootMarker -Path 'C:/repo/sub' | Should -BeFalse
        }

        It 'rejects a level with no .git entry and an empty level' {
            # Purpose: the ascent continues past such a level.
            Test-WorktreeResolutionRootMarker -Path 'C:/repo/sub' | Should -BeFalse
            Test-WorktreeResolutionRootMarker -Path ' ' | Should -BeFalse
        }
    }

    Context 'upward ascent' {
        It 'returns the input itself when it is a root (depth 0)' {
            # Purpose: the level holding the marker is returned unchanged.
            $Topology = New-TestTopology
            Set-TopologyMock

            Find-WorktreeResolutionRoot -Path 'C:\repo' | Should -BeExactly 'C:/repo'
        }

        It 'ascends several levels to the nearest root (depth greater than 0)' {
            # Purpose: the nearest marker wins, not the enclosing main checkout.
            $Topology = New-TestTopology -Linked @($script:ItemWorktree)
            Set-TopologyMock

            $actual = Find-WorktreeResolutionRoot -Path 'C:\repo\.claude\worktrees\item\docs\features\active'

            $actual | Should -BeExactly 'C:/repo/.claude/worktrees/item'
        }

        It 'returns null after probing the drive root when no marker exists' {
            # Purpose: the walk ends at the drive root rather than looping.
            $actual = Find-WorktreeResolutionRoot -Path 'D:/elsewhere/docs'

            $actual | Should -BeNullOrEmpty
            Should -Invoke -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -ParameterFilter { $Path -eq 'D:/.git' } -Times 1 -Exactly
        }

        It 'returns null after probing the filesystem root for a slash-rooted path' {
            # Purpose: the filesystem root is the last level tested.
            $actual = Find-WorktreeResolutionRoot -Path '/srv/data'

            $actual | Should -BeNullOrEmpty
            Should -Invoke -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -ParameterFilter { $Path -eq '/.git' } -Times 1 -Exactly
        }

        It 'stops at the MaximumDepth guard before reaching a distant root' {
            # Purpose: the guard bounds the walk exactly.
            $Topology = New-TestTopology
            Set-TopologyMock

            $tooShallow = Find-WorktreeResolutionRoot -Path 'C:/repo/a/b/c' -MaximumDepth 2
            $deepEnough = Find-WorktreeResolutionRoot -Path 'C:/repo/a/b/c' -MaximumDepth 3

            $tooShallow | Should -BeNullOrEmpty
            $deepEnough | Should -BeExactly 'C:/repo'
        }

        It 'refuses a relative input without probing the filesystem' {
            # Purpose: nothing is probed and nothing is returned.
            $actual = Find-WorktreeResolutionRoot -Path 'docs/features'

            $actual | Should -BeNullOrEmpty
            Should -Invoke -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -Times 0 -Exactly
        }
    }

    Context 'worktree enumeration' {
        It 'enumerates the main checkout and its linked worktrees from the main checkout' {
            # Purpose: the main checkout is first, followed by every linked worktree.
            $Topology = New-TestTopology -Linked @($script:SessionWorktree, $script:ItemWorktree)
            Set-TopologyMock

            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:\repo\'

            , $actual | Should -BeOfType [string[]]
            $actual | Should -Be @('C:/repo', 'C:/repo-wt/session', 'C:/repo/.claude/worktrees/item')
        }

        It 'includes the main checkout when the session root is a linked worktree' {
            # Purpose: the main checkout is a candidate, not only the linked worktrees.
            $Topology = New-TestTopology -Linked @($script:SessionWorktree, $script:ItemWorktree)
            Set-TopologyMock

            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:/repo-wt/session'

            $actual | Should -Contain 'C:/repo'
            $actual.Count | Should -Be 3
        }

        It 'resolves a linked worktree that is a sibling of the main checkout without a prefix comparison' {
            # Purpose: the sibling is its own root, not folded into C:/repo.
            $Topology = New-TestTopology -Linked @($script:SiblingWorktree)
            Set-TopologyMock

            $candidates = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:/repo-wt/sibling'
            $located = Find-WorktreeResolutionRoot -Path 'C:/repo-wt/sibling/docs/features/active/x'

            $candidates | Should -Be @('C:/repo', 'C:/repo-wt/sibling')
            $located | Should -BeExactly 'C:/repo-wt/sibling'
        }

        It 'returns a single-element array when the admin directory holds no linked worktree' {
            # Purpose: still an array, holding only the main checkout.
            $Topology = New-TestTopology
            Set-TopologyMock

            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:/repo'

            , $actual | Should -BeOfType [string[]]
            $actual.Count | Should -Be 1
            $actual[0] | Should -BeExactly 'C:/repo'
        }

        It 'returns an empty array for <Label>' -ForEach @(
            @{ Label = 'a session root with no .git entry'; SessionRoot = 'D:/nowhere' }
            @{ Label = 'an empty session root'; SessionRoot = '' }
            @{ Label = 'a linked worktree whose admin directory has no commondir'; SessionRoot = 'C:/repo-wt/session'; DropCommonDir = $true }
            @{ Label = 'a .git file with no gitdir line'; SessionRoot = 'C:/repo-wt/session'; BreakPointer = $true }
        ) {
            # Purpose: an unreachable layout yields no candidate rather than a guess.
            $Topology = New-TestTopology -Linked @($script:SessionWorktree)
            if ($DropCommonDir) { $Topology.Text.Remove('C:/repo/.git/worktrees/session/commondir') }
            if ($BreakPointer) { $Topology.Text['C:/repo-wt/session/.git'] = 'not a pointer' }
            Set-TopologyMock

            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot $SessionRoot

            , $actual | Should -BeOfType [string[]]
            $actual.Count | Should -Be 0
        }

        It 'follows relative pointers, skips admin entries without a gitdir file, and deduplicates roots' {
            # Purpose: relative pointers resolve, the orphan is skipped, and case-only duplicates collapse.
            $Topology = New-TestTopology -Linked @($script:ItemWorktree)
            $Topology.Text['C:/repo/.claude/worktrees/item/.git'] = 'gitdir: ../../../.git/worktrees/item'
            $Topology.Text['C:/repo/.git/worktrees/item/gitdir'] = '../../../.claude/worktrees/item/.git'
            $Topology.Text['C:/repo/.git/worktrees/copy/gitdir'] = 'C:/REPO/.claude/worktrees/item/.git'
            $Topology.Children['C:/repo/.git/worktrees'] = [string[]] @('item', 'orphan', 'copy')
            Set-TopologyMock

            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:/repo/.claude/worktrees/item'

            $actual | Should -Be @('C:/repo', 'C:/repo/.claude/worktrees/item')
        }

        It 'omits the main checkout when the common directory is not a .git directory' {
            # Purpose: a bare repository has no checkout of its own to offer.
            $Topology = New-TestTopology -Linked @($script:SessionWorktree)
            $Topology.Text['C:/repo/.git/worktrees/session/commondir'] = 'C:/bare/repo-bare'
            $Topology.Children['C:/bare/repo-bare/worktrees'] = [string[]] @('session')
            $Topology.Text['C:/bare/repo-bare/worktrees/session/gitdir'] = 'C:/repo-wt/session/.git'
            Set-TopologyMock

            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:/repo-wt/session'

            $actual | Should -Be @('C:/repo-wt/session')
        }

        It 'filters candidates by branch <Branch>' -ForEach @(
            @{ Branch = 'feature/item-700'; Expected = @('C:/repo/.claude/worktrees/item') }
            @{ Branch = 'main'; Expected = @('C:/repo') }
            @{ Branch = 'feature/absent'; Expected = @() }
        ) {
            # Purpose: only a HEAD naming exactly that branch qualifies.
            $Topology = New-TestTopology -Linked @($script:SessionWorktree, $script:ItemWorktree)
            $Topology.Text['C:/repo/.git/worktrees/session/HEAD'] = '0123456789abcdef0123456789abcdef01234567'
            Set-TopologyMock

            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:/repo' -Branch $Branch

            , $actual | Should -BeOfType [string[]]
            @($actual) | Should -Be $Expected
        }

        It 'filters candidates to those containing a repo-relative path' {
            # Purpose: only the containing worktree survives.
            $Topology = New-TestTopology -Linked @($script:SessionWorktree, $script:ItemWorktree) -Directory @('C:/repo/.claude/worktrees/item/docs/features/active/item-700')
            Set-TopologyMock

            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:/repo-wt/session' -RepoRelativePath 'docs\features\active\item-700\'

            $actual | Should -Be @('C:/repo/.claude/worktrees/item')
        }
    }

    Context 'repo-relative normalisation' {
        It 'keeps a remainder deeper than four segments intact and recovers the absolute prefix' {
            # Purpose: no segment is lost and the prefix becomes WorktreeRoot.
            $Topology = New-TestTopology -Linked @($script:SessionWorktree)
            Set-TopologyMock

            $actual = ConvertTo-WorktreeResolutionRepoRelativePath -Path 'C:\repo-wt\session\docs\features\active\item-700\v1\spec.md'

            $actual | Should -BeOfType [pscustomobject]
            $actual.IsNormalized | Should -BeTrue
            $actual.WorktreeRoot | Should -BeExactly 'C:/repo-wt/session'
            $actual.RepoRelativePath | Should -BeExactly 'docs/features/active/item-700/v1/spec.md'
            $actual.ReasonCode | Should -BeNullOrEmpty
            $actual.Detail | Should -Not -BeNullOrEmpty
        }

        It 'normalises a relative path against an explicit worktree root (Ruling A complement)' {
            # Purpose: forward slashes, no leading ./, and no trailing slash on either path.
            $actual = ConvertTo-WorktreeResolutionRepoRelativePath -Path '.\docs\features\active\item-700\' -WorktreeRoot 'C:\repo-wt\session\'

            $actual.IsNormalized | Should -BeTrue
            $actual.WorktreeRoot | Should -BeExactly 'C:/repo-wt/session'
            $actual.RepoRelativePath | Should -BeExactly 'docs/features/active/item-700'
            $actual.ReasonCode | Should -BeNullOrEmpty
            $actual.Detail | Should -Not -BeNullOrEmpty
        }

        It 'refuses a relative path with no worktree root and does not echo the input (Ruling A)' {
            # Purpose: the unresolved form, never the input returned as if normalised.
            $actual = ConvertTo-WorktreeResolutionRepoRelativePath -Path 'docs/features/active/item-700'

            $actual.IsNormalized | Should -BeFalse
            $actual.RepoRelativePath | Should -BeNullOrEmpty
            $actual.WorktreeRoot | Should -BeNullOrEmpty
            $actual.ReasonCode | Should -BeExactly 'TARGET_WORKTREE_AMBIGUOUS'
            $actual.Detail | Should -BeLike '*docs/features/active/item-700*'
        }

        It 'marks <Label> as not normalised with the ambiguity reason code' -ForEach @(
            @{ Label = 'an absolute path with no .git entry on the ascent'; InputPath = 'D:\elsewhere\docs\features\active\item-700' }
            @{ Label = 'an empty path'; InputPath = '' }
        ) {
            # Purpose: ReasonCode is set exactly because the path was not normalised.
            $actual = ConvertTo-WorktreeResolutionRepoRelativePath -Path $InputPath

            $actual.IsNormalized | Should -BeFalse
            $actual.ReasonCode | Should -BeExactly 'TARGET_WORKTREE_AMBIGUOUS'
            $actual.RepoRelativePath | Should -BeNullOrEmpty
            $actual.WorktreeRoot | Should -BeNullOrEmpty
            $actual.Detail | Should -Not -BeNullOrEmpty
        }

        It 'returns an empty remainder for the worktree root itself' {
            # Purpose: the root is located and nothing below it is invented.
            $Topology = New-TestTopology
            Set-TopologyMock

            $actual = ConvertTo-WorktreeResolutionRepoRelativePath -Path 'C:/repo/'

            $actual.IsNormalized | Should -BeTrue
            $actual.WorktreeRoot | Should -BeExactly 'C:/repo'
            $actual.RepoRelativePath | Should -BeExactly ''
        }
    }

    Context 'reason code' {
        It 'returns the exact ambiguity literal from the accessor' {
            # Purpose: pinned, so a rename breaks this test rather than the gates that consume it.
            $actual = Get-WorktreeResolutionAmbiguityReasonCode

            $actual | Should -BeExactly 'TARGET_WORKTREE_AMBIGUOUS'
            $actual.EndsWith('_BLOCKED') | Should -BeFalse
        }

        It 'declares the literal once as a script-scope constant' {
            # Purpose: the accessor and the result objects share one declaration.
            $constant = InModuleScope 'WorktreeResolution' { $script:AmbiguityReasonCode }

            $constant | Should -BeExactly (Get-WorktreeResolutionAmbiguityReasonCode)
        }
    }
}
