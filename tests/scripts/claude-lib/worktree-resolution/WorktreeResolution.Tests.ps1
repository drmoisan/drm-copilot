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
        # Arrange: tracked repository paths, plus a sibling name that does not exist.
        $directoryPath = Join-Path $script:RepoRoot '.claude/lib'
        $filePath = Join-Path $script:RepoRoot '.claude/lib/hook-payload/HookPayload.psm1'
        $absentPath = Join-Path $script:RepoRoot '.claude/lib/worktree-resolution-absent-sibling'

        # Act: probe each path through the real existence seam.
        $directoryKind = Get-WorktreeResolutionGitEntryKind -Path $directoryPath
        $fileKind = Get-WorktreeResolutionGitEntryKind -Path $filePath
        $absentKind = Get-WorktreeResolutionGitEntryKind -Path $absentPath

        # Assert: the seam distinguishes the three kinds the root marker relies on.
        $directoryKind | Should -BeExactly 'Directory'
        $fileKind | Should -BeExactly 'File'
        $absentKind | Should -BeExactly 'None'
    }

    It 'reads the raw text of a tracked file and returns null for an absent file' {
        # Arrange: this module's own source and an absent sibling path.
        $modulePath = Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeResolution.psm1'
        $absentPath = Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/absent.txt'

        # Act: read both through the real content seam.
        $text = Get-WorktreeResolutionGitFileText -Path $modulePath
        $absentText = Get-WorktreeResolutionGitFileText -Path $absentPath

        # Assert: the content is returned whole, and an absent file is not an error.
        $text | Should -BeLike '*Set-StrictMode*'
        $absentText | Should -BeNullOrEmpty
    }

    It 'lists child directory names as an array, empty for an absent directory' {
        # Arrange: the shared library root and an absent directory.
        $libraryPath = Join-Path $script:RepoRoot '.claude/lib'
        $absentPath = Join-Path $script:RepoRoot '.claude/lib/worktree-resolution-absent-sibling'

        # Act: enumerate both through the real directory seam.
        $names = Get-WorktreeResolutionDirectoryChildName -Path $libraryPath
        $absentNames = Get-WorktreeResolutionDirectoryChildName -Path $absentPath

        # Assert: both results are arrays, so a caller never branches on a scalar.
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
            # Arrange / Act: normalise the row's input.
            $actual = ConvertTo-WorktreeResolutionNormalizedPath -Path $InputPath

            # Assert: one spelling per location, so later comparisons are exact.
            $actual | Should -BeExactly $Expected
        }

        It 'returns null for <Label>' -ForEach @(
            @{ Label = 'a null input'; InputPath = $null }
            @{ Label = 'an empty input'; InputPath = '' }
            @{ Label = 'a whitespace input'; InputPath = '   ' }
            @{ Label = 'a bare ./ input'; InputPath = './' }
        ) {
            # Arrange / Act: normalise an input that names no path.
            $actual = ConvertTo-WorktreeResolutionNormalizedPath -Path $InputPath

            # Assert: no path is invented from an empty input.
            $actual | Should -BeNullOrEmpty
        }
    }

    Context 'root marker' {
        It 'treats a .git directory as a root marker' {
            # Arrange: the level's .git child is a directory.
            Mock -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -MockWith { 'Directory' }

            # Act / Assert: a main checkout is a worktree root.
            Test-WorktreeResolutionRootMarker -Path 'C:/repo' | Should -BeTrue
        }

        It 'treats a .git file with a well-formed gitdir line as a root marker' {
            # Arrange: the level's .git child is a linked-worktree pointer file.
            Mock -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -MockWith { 'File' }
            Mock -CommandName Get-WorktreeResolutionGitFileText -ModuleName 'WorktreeResolution' -MockWith { "gitdir: C:/repo/.git/worktrees/item`r`n" }

            # Act / Assert: a linked worktree is a worktree root.
            Test-WorktreeResolutionRootMarker -Path 'C:/repo/.claude/worktrees/item' | Should -BeTrue
        }

        It 'rejects a .git file whose text is <Label>' -ForEach @(
            @{ Label = 'malformed'; Text = 'this is not a pointer line' }
            @{ Label = 'empty'; Text = '' }
            @{ Label = 'unreadable'; Text = $null }
        ) {
            # Arrange: a .git file whose first line is not a gitdir: line.
            Mock -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -MockWith { 'File' }
            Mock -CommandName Get-WorktreeResolutionGitFileText -ModuleName 'WorktreeResolution' -MockWith { $Text }

            # Act / Assert: only a well-formed pointer marks a root.
            Test-WorktreeResolutionRootMarker -Path 'C:/repo/sub' | Should -BeFalse
        }

        It 'rejects a level with no .git entry and an empty level' {
            # Arrange: the default mocks report that nothing exists.
            # Act / Assert: the ascent continues past such a level.
            Test-WorktreeResolutionRootMarker -Path 'C:/repo/sub' | Should -BeFalse
            Test-WorktreeResolutionRootMarker -Path ' ' | Should -BeFalse
        }
    }

    Context 'upward ascent' {
        It 'returns the input itself when it is a root (depth 0)' {
            # Arrange: a main checkout at C:/repo.
            $Topology = New-TestTopology
            Set-TopologyMock

            # Act / Assert: the level holding the marker is returned unchanged.
            Find-WorktreeResolutionRoot -Path 'C:\repo' | Should -BeExactly 'C:/repo'
        }

        It 'ascends several levels to the nearest root (depth greater than 0)' {
            # Arrange: a linked worktree nested inside the main checkout.
            $Topology = New-TestTopology -Linked @($script:ItemWorktree)
            Set-TopologyMock

            # Act: ascend from a deep path inside the nested worktree.
            $actual = Find-WorktreeResolutionRoot -Path 'C:\repo\.claude\worktrees\item\docs\features\active'

            # Assert: the nearest marker wins, not the enclosing main checkout.
            $actual | Should -BeExactly 'C:/repo/.claude/worktrees/item'
        }

        It 'returns null after probing the drive root when no marker exists' {
            # Arrange: default mocks, so no level carries a marker.
            # Act: ascend from a path on a drive with no worktree.
            $actual = Find-WorktreeResolutionRoot -Path 'D:/elsewhere/docs'

            # Assert: the walk ends at the drive root rather than looping.
            $actual | Should -BeNullOrEmpty
            Should -Invoke -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -ParameterFilter { $Path -eq 'D:/.git' } -Times 1 -Exactly
        }

        It 'returns null after probing the filesystem root for a slash-rooted path' {
            # Arrange / Act: default mocks, slash-rooted input.
            $actual = Find-WorktreeResolutionRoot -Path '/srv/data'

            # Assert: the filesystem root is the last level tested.
            $actual | Should -BeNullOrEmpty
            Should -Invoke -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -ParameterFilter { $Path -eq '/.git' } -Times 1 -Exactly
        }

        It 'stops at the MaximumDepth guard before reaching a distant root' {
            # Arrange: a root three levels above the input.
            $Topology = New-TestTopology
            Set-TopologyMock

            # Act: allow two levels of ascent, then three.
            $tooShallow = Find-WorktreeResolutionRoot -Path 'C:/repo/a/b/c' -MaximumDepth 2
            $deepEnough = Find-WorktreeResolutionRoot -Path 'C:/repo/a/b/c' -MaximumDepth 3

            # Assert: the guard bounds the walk exactly.
            $tooShallow | Should -BeNullOrEmpty
            $deepEnough | Should -BeExactly 'C:/repo'
        }

        It 'refuses a relative input without probing the filesystem' {
            # Arrange / Act: a relative path would resolve against the current directory.
            $actual = Find-WorktreeResolutionRoot -Path 'docs/features'

            # Assert: nothing is probed and nothing is returned.
            $actual | Should -BeNullOrEmpty
            Should -Invoke -CommandName Get-WorktreeResolutionGitEntryKind -ModuleName 'WorktreeResolution' -Times 0 -Exactly
        }
    }

    Context 'worktree enumeration' {
        It 'enumerates the main checkout and its linked worktrees from the main checkout' {
            # Arrange: the session root is the main checkout with two linked worktrees.
            $Topology = New-TestTopology -Linked @($script:SessionWorktree, $script:ItemWorktree)
            Set-TopologyMock

            # Act: enumerate from the main checkout.
            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:\repo\'

            # Assert: the main checkout is first, followed by every linked worktree.
            , $actual | Should -BeOfType [string[]]
            $actual | Should -Be @('C:/repo', 'C:/repo-wt/session', 'C:/repo/.claude/worktrees/item')
        }

        It 'includes the main checkout when the session root is a linked worktree' {
            # Arrange: the session root is a linked worktree reached through commondir.
            $Topology = New-TestTopology -Linked @($script:SessionWorktree, $script:ItemWorktree)
            Set-TopologyMock

            # Act: enumerate from the linked worktree.
            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:/repo-wt/session'

            # Assert: the main checkout is a candidate, not only the linked worktrees.
            $actual | Should -Contain 'C:/repo'
            $actual.Count | Should -Be 3
        }

        It 'resolves a linked worktree that is a sibling of the main checkout without a prefix comparison' {
            # Arrange: C:/repo-wt/sibling shares the textual prefix C:/repo but is not inside it.
            $Topology = New-TestTopology -Linked @($script:SiblingWorktree)
            Set-TopologyMock

            # Act: enumerate, then locate a path inside the sibling worktree.
            $candidates = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:/repo-wt/sibling'
            $located = Find-WorktreeResolutionRoot -Path 'C:/repo-wt/sibling/docs/features/active/x'

            # Assert: the sibling is its own root, not folded into C:/repo.
            $candidates | Should -Be @('C:/repo', 'C:/repo-wt/sibling')
            $located | Should -BeExactly 'C:/repo-wt/sibling'
        }

        It 'returns a single-element array when the admin directory holds no linked worktree' {
            # Arrange: a main checkout with an empty worktrees directory.
            $Topology = New-TestTopology
            Set-TopologyMock

            # Act: enumerate from the main checkout.
            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:/repo'

            # Assert: still an array, holding only the main checkout.
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
            # Arrange: a topology in which the main .git directory cannot be reached.
            $Topology = New-TestTopology -Linked @($script:SessionWorktree)
            if ($DropCommonDir) { $Topology.Text.Remove('C:/repo/.git/worktrees/session/commondir') }
            if ($BreakPointer) { $Topology.Text['C:/repo-wt/session/.git'] = 'not a pointer' }
            Set-TopologyMock

            # Act: enumerate from the row's session root.
            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot $SessionRoot

            # Assert: an unreachable layout yields no candidate rather than a guess.
            , $actual | Should -BeOfType [string[]]
            $actual.Count | Should -Be 0
        }

        It 'follows relative pointers, skips admin entries without a gitdir file, and deduplicates roots' {
            # Arrange: relative pointer text, an orphan admin entry, and a duplicate entry.
            $Topology = New-TestTopology -Linked @($script:ItemWorktree)
            $Topology.Text['C:/repo/.claude/worktrees/item/.git'] = 'gitdir: ../../../.git/worktrees/item'
            $Topology.Text['C:/repo/.git/worktrees/item/gitdir'] = '../../../.claude/worktrees/item/.git'
            $Topology.Text['C:/repo/.git/worktrees/copy/gitdir'] = 'C:/REPO/.claude/worktrees/item/.git'
            $Topology.Children['C:/repo/.git/worktrees'] = [string[]] @('item', 'orphan', 'copy')
            Set-TopologyMock

            # Act: enumerate from the nested worktree.
            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:/repo/.claude/worktrees/item'

            # Assert: relative pointers resolve, the orphan is skipped, and case-only duplicates collapse.
            $actual | Should -Be @('C:/repo', 'C:/repo/.claude/worktrees/item')
        }

        It 'omits the main checkout when the common directory is not a .git directory' {
            # Arrange: a linked worktree whose commondir leads to a bare repository.
            $Topology = New-TestTopology -Linked @($script:SessionWorktree)
            $Topology.Text['C:/repo/.git/worktrees/session/commondir'] = 'C:/bare/repo-bare'
            $Topology.Children['C:/bare/repo-bare/worktrees'] = [string[]] @('session')
            $Topology.Text['C:/bare/repo-bare/worktrees/session/gitdir'] = 'C:/repo-wt/session/.git'
            Set-TopologyMock

            # Act: enumerate from the linked worktree.
            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:/repo-wt/session'

            # Assert: a bare repository has no checkout of its own to offer.
            $actual | Should -Be @('C:/repo-wt/session')
        }

        It 'filters candidates by branch <Branch>' -ForEach @(
            @{ Branch = 'feature/item-700'; Expected = @('C:/repo/.claude/worktrees/item') }
            @{ Branch = 'main'; Expected = @('C:/repo') }
            @{ Branch = 'feature/absent'; Expected = @() }
        ) {
            # Arrange: two linked worktrees plus a detached HEAD on the session worktree.
            $Topology = New-TestTopology -Linked @($script:SessionWorktree, $script:ItemWorktree)
            $Topology.Text['C:/repo/.git/worktrees/session/HEAD'] = '0123456789abcdef0123456789abcdef01234567'
            Set-TopologyMock

            # Act: enumerate with a branch filter.
            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:/repo' -Branch $Branch

            # Assert: only a HEAD naming exactly that branch qualifies.
            , $actual | Should -BeOfType [string[]]
            @($actual) | Should -Be $Expected
        }

        It 'filters candidates to those containing a repo-relative path' {
            # Arrange: the feature folder exists only in the item worktree.
            $Topology = New-TestTopology -Linked @($script:SessionWorktree, $script:ItemWorktree) -Directory @('C:/repo/.claude/worktrees/item/docs/features/active/item-700')
            Set-TopologyMock

            # Act: enumerate with a containment filter written with backslashes.
            $actual = Get-WorktreeResolutionWorktreeRoot -SessionRoot 'C:/repo-wt/session' -RepoRelativePath 'docs\features\active\item-700\'

            # Assert: only the containing worktree survives.
            $actual | Should -Be @('C:/repo/.claude/worktrees/item')
        }
    }

    Context 'repo-relative normalisation' {
        It 'keeps a remainder deeper than four segments intact and recovers the absolute prefix' {
            # Arrange: a sibling-of-main worktree and a six-segment remainder below it.
            $Topology = New-TestTopology -Linked @($script:SessionWorktree)
            Set-TopologyMock

            # Act: normalise an absolute Windows-style path inside that worktree.
            $actual = ConvertTo-WorktreeResolutionRepoRelativePath -Path 'C:\repo-wt\session\docs\features\active\item-700\v1\spec.md'

            # Assert: no segment is lost and the prefix becomes WorktreeRoot.
            $actual | Should -BeOfType [pscustomobject]
            $actual.IsNormalized | Should -BeTrue
            $actual.WorktreeRoot | Should -BeExactly 'C:/repo-wt/session'
            $actual.RepoRelativePath | Should -BeExactly 'docs/features/active/item-700/v1/spec.md'
            $actual.ReasonCode | Should -BeNullOrEmpty
            $actual.Detail | Should -Not -BeNullOrEmpty
        }

        It 'normalises a relative path against an explicit worktree root (Ruling A complement)' {
            # Arrange / Act: separators, a leading ./ and trailing slashes on both inputs.
            $actual = ConvertTo-WorktreeResolutionRepoRelativePath -Path '.\docs\features\active\item-700\' -WorktreeRoot 'C:\repo-wt\session\'

            # Assert: forward slashes, no leading ./, and no trailing slash on either path.
            $actual.IsNormalized | Should -BeTrue
            $actual.WorktreeRoot | Should -BeExactly 'C:/repo-wt/session'
            $actual.RepoRelativePath | Should -BeExactly 'docs/features/active/item-700'
            $actual.ReasonCode | Should -BeNullOrEmpty
            $actual.Detail | Should -Not -BeNullOrEmpty
        }

        It 'refuses a relative path with no worktree root and does not echo the input (Ruling A)' {
            # Arrange / Act: a relative path and no root to resolve it against.
            $actual = ConvertTo-WorktreeResolutionRepoRelativePath -Path 'docs/features/active/item-700'

            # Assert: the unresolved form, never the input returned as if normalised.
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
            # Arrange: default mocks, so no worktree root exists anywhere.
            # Act: normalise the row's input.
            $actual = ConvertTo-WorktreeResolutionRepoRelativePath -Path $InputPath

            # Assert: ReasonCode is set exactly because the path was not normalised.
            $actual.IsNormalized | Should -BeFalse
            $actual.ReasonCode | Should -BeExactly 'TARGET_WORKTREE_AMBIGUOUS'
            $actual.RepoRelativePath | Should -BeNullOrEmpty
            $actual.WorktreeRoot | Should -BeNullOrEmpty
            $actual.Detail | Should -Not -BeNullOrEmpty
        }

        It 'returns an empty remainder for the worktree root itself' {
            # Arrange: a main checkout at C:/repo.
            $Topology = New-TestTopology
            Set-TopologyMock

            # Act: normalise the root path.
            $actual = ConvertTo-WorktreeResolutionRepoRelativePath -Path 'C:/repo/'

            # Assert: the root is located and nothing below it is invented.
            $actual.IsNormalized | Should -BeTrue
            $actual.WorktreeRoot | Should -BeExactly 'C:/repo'
            $actual.RepoRelativePath | Should -BeExactly ''
        }
    }

    Context 'reason code' {
        It 'returns the exact ambiguity literal from the accessor' {
            # Arrange / Act: read the published literal.
            $actual = Get-WorktreeResolutionAmbiguityReasonCode

            # Assert: pinned, so a rename breaks this test rather than the gates that consume it.
            $actual | Should -BeExactly 'TARGET_WORKTREE_AMBIGUOUS'
            $actual.EndsWith('_BLOCKED') | Should -BeFalse
        }

        It 'declares the literal once as a script-scope constant' {
            # Arrange / Act: read the constant from inside the module.
            $constant = InModuleScope 'WorktreeResolution' { $script:AmbiguityReasonCode }

            # Assert: the accessor and the result objects share one declaration.
            $constant | Should -BeExactly (Get-WorktreeResolutionAmbiguityReasonCode)
        }
    }
}
