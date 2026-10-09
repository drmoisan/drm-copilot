#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #738 - per-segment target resolution of the preimplementation gate. Each row calls the
# pure functions of enforce-orchestration-preimplementation-gate-targets.ps1 directly, once
# against the Claude copy and once against the Codex copy, with the C1a scanner and matcher
# dot-sourced from the same surface. The session root is the synthetic literal
# /synthetic-worktrees/session. The file creates no file and starts no child process.

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

        function Get-CommandTargetResult {
            # Single act step for the command-leg rows.
            param([Parameter(Mandatory)][string] $Command)
            return Get-OrchestrationCommandTarget -Command $Command -SessionRoot $script:Root
        }
    }

    It 'U01 resolves an absolute path-leg input to itself' {
        # Act
        $result = Get-OrchestrationCommandTarget -FilePath @('/synthetic-worktrees/other/a.ps1') -SessionRoot $script:Root

        # Assert
        $result.Resolved | Should -BeTrue -Because 'an absolute path without a dot segment is a target'
        $result.Targets | Should -Be @('/synthetic-worktrees/other/a.ps1') -Because 'the path itself is the target'
    }

    It 'U02 resolves a relative path-leg input to the session root' {
        # Act
        $result = Get-OrchestrationCommandTarget -FilePath @('scripts/a.ps1') -SessionRoot $script:Root

        # Assert
        $result.Targets | Should -Be @($script:Root) -Because 'a relative path is resolved against the session root'
    }

    It 'U03 denies an absolute path-leg input with a dot segment' {
        # Act
        $result = Get-OrchestrationCommandTarget -FilePath @('/synthetic-worktrees/other/../a.ps1') -SessionRoot $script:Root

        # Assert
        $result.Resolved | Should -BeFalse -Because 'a dot segment makes the absolute target undecidable'
        $result.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $result.Detail.StartsWith('path-dot-segment') | Should -BeTrue -Because 'the detail names rule R1'
    }

    It 'U04 normalizes a backslash path-leg input' {
        # Act
        $result = Get-OrchestrationCommandTarget -FilePath @('C:\wt\a.ps1') -SessionRoot $script:Root

        # Assert
        $result.Targets | Should -Be @('C:/wt/a.ps1') -Because 'path-leg separators normalize to forward slashes'
    }

    It 'U05 resolves two patch-marker paths in order' {
        # Arrange
        $patch = "*** Begin Patch`n*** Update File: /synthetic-worktrees/other/a.ps1`n@@`n*** Add File: scripts/b.ps1`n+x`n*** End Patch"
        $paths = @(Get-OrchestrationPatchMarkerPath -PatchText $patch)

        # Act
        $result = Get-OrchestrationCommandTarget -FilePath $paths -SessionRoot $script:Root

        # Assert
        $result.Targets | Should -Be @('/synthetic-worktrees/other/a.ps1', $script:Root) -Because 'each marker contributes its target in order'
    }

    It 'U06 denies an unbalanced segment' {
        # Act
        $result = Get-CommandTargetResult -Command 'git add "x'

        # Assert
        $result.Resolved | Should -BeFalse -Because 'an unbalanced quote hides the segment boundaries'
        $result.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $result.Detail.StartsWith('segment-unbalanced') | Should -BeTrue -Because 'the detail names rule R2'
    }

    It 'U07 gives directory-change for <Word>' -ForEach @(
        @{ Word = 'cd'; Command = 'cd /x && git add a.ps1' }
        @{ Word = 'pushd'; Command = 'pushd /x && git add a.ps1' }
        @{ Word = 'popd'; Command = 'popd /x && git add a.ps1' }
        @{ Word = 'chdir'; Command = 'chdir /x && git add a.ps1' }
        @{ Word = ('Set' + '-Location'); Command = (('Set' + '-Location') + ' /x && git add a.ps1') }
        @{ Word = 'sl'; Command = 'sl /x && git add a.ps1' }
        @{ Word = 'Push-Location'; Command = 'Push-Location /x && git add a.ps1' }
        @{ Word = 'Pop-Location'; Command = 'Pop-Location /x && git add a.ps1' }
    ) {
        # Act
        $result = Get-CommandTargetResult -Command $Command

        # Assert
        $result.Resolved | Should -BeFalse -Because "$Word changes the directory of later segments"
        $result.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $result.Detail.StartsWith('directory-change') | Should -BeTrue -Because 'the detail names rule R3'
    }

    It 'U08 denies a wrapper-led git segment without reading its -C value' {
        # Act
        $result = Get-CommandTargetResult -Command 'nohup git -C /x add a.ps1'

        # Assert
        $result.Resolved | Should -BeFalse -Because 'a wrapper-led git add segment is not resolved structurally'
        $result.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $result.Detail.StartsWith('wrapper-git') | Should -BeTrue -Because 'the detail names rule R4'
        $result.Targets | Should -Not -Contain '/x' -Because 'R4 decides before R6 reads the -C value'
    }

    It 'U09 denies a substitution-bearing git segment' {
        # Act
        $result = Get-CommandTargetResult -Command 'git add "$(echo a.ps1)"'

        # Assert
        $result.Resolved | Should -BeFalse -Because 'a live substitution makes the operand list undecidable'
        $result.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $result.Detail.StartsWith('wrapper-git') | Should -BeTrue -Because 'the detail names rule R4'
    }

    It 'U10 resolves a wrapper-led non-git segment to the session root' {
        # Act
        $result = Get-CommandTargetResult -Command 'timeout 60 pytest'

        # Assert
        $result.Resolved | Should -BeTrue -Because 'the matcher finds no git add or git commit'
        $result.Targets | Should -Be @($script:Root) -Because 'the segment runs in the session root'
    }

    It 'U11 gives git-relocation for <Command>' -ForEach @(
        @{ Command = 'GIT_DIR=/x git add a.ps1' }
        @{ Command = 'GIT_WORK_TREE=/x git add a.ps1' }
        @{ Command = 'GIT_COMMON_DIR=/x git add a.ps1' }
        @{ Command = 'GIT_INDEX_FILE=/x git add a.ps1' }
        @{ Command = 'export GIT_DIR=/x && git add a.ps1' }
    ) {
        # Act
        $result = Get-CommandTargetResult -Command $Command

        # Assert
        $result.Resolved | Should -BeFalse -Because 'a relocation variable moves the git directory'
        $result.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $result.Detail.StartsWith('git-relocation') | Should -BeTrue -Because 'the detail names rule R5'
    }

    It 'U12 gives git-relocation for <Command>' -ForEach @(
        @{ Command = 'git --git-dir=/x add a.ps1' }
        @{ Command = 'git --git-dir /x add a.ps1' }
        @{ Command = 'git --work-tree /x add a.ps1' }
        @{ Command = 'git -c core.worktree=/x add a.ps1' }
    ) {
        # Act
        $result = Get-CommandTargetResult -Command $Command

        # Assert
        $result.Resolved | Should -BeFalse -Because 'a relocation option moves the git directory or work tree'
        $result.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $result.Detail.StartsWith('git-relocation') | Should -BeTrue -Because 'the detail names rule R5'
    }

    It 'U13 collects every value of a repeated -C selector' {
        # Act
        $result = Get-CommandTargetResult -Command 'git -C /a -C /b add a.ps1'

        # Assert
        $result.Targets | Should -Be @('/a', '/b') -Because 'every -C value is a target'
    }

    It 'U14 gives selector-not-absolute for a relative and a UNC selector' {
        # Act
        $relative = Get-CommandTargetResult -Command 'git -C sub add a.ps1'
        $unc = Get-CommandTargetResult -Command 'git -C //server/share add a.ps1'

        # Assert
        $relative.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $relative.Detail.StartsWith('selector-not-absolute') | Should -BeTrue -Because 'a relative selector is not absolute'
        $unc.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $unc.Detail.StartsWith('selector-not-absolute') | Should -BeTrue -Because 'a UNC selector is not a rooted local path'
    }

    It 'U15 gives selector-dot-segment for a dot and a dot-dot selector' {
        # Act
        $dot = Get-CommandTargetResult -Command 'git -C /a/./b add a.ps1'
        $dotDot = Get-CommandTargetResult -Command 'git -C /a/../b add a.ps1'

        # Assert
        $dot.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $dot.Detail.StartsWith('selector-dot-segment') | Should -BeTrue -Because 'a dot segment is not canonical'
        $dotDot.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $dotDot.Detail.StartsWith('selector-dot-segment') | Should -BeTrue -Because 'a dot-dot segment is not canonical'
    }

    It 'U16 gives selector-backslash for a backslash selector' {
        # Act
        $result = Get-CommandTargetResult -Command 'git -C C:\wt add a.ps1'

        # Assert
        $result.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $result.Detail.StartsWith('selector-backslash') | Should -BeTrue -Because 'a backslash selector is shell-divergent'
    }

    It 'U17 gives selector-missing-value for a trailing -C' {
        # Act
        $result = Get-CommandTargetResult -Command 'git -C'

        # Assert
        $result.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $result.Detail.StartsWith('selector-missing-value') | Should -BeTrue -Because 'the selector has no value'
    }

    It 'U18 gives git-option-unmodeled for an unknown global option' {
        # Act
        $result = Get-CommandTargetResult -Command 'git --bogus add a.ps1'

        # Assert
        $result.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $result.Detail.StartsWith('git-option-unmodeled') | Should -BeTrue -Because 'an unmodeled option may relocate'
    }

    It 'U19 resolves a chained command to the session root and the selector' {
        # Act
        $result = Get-CommandTargetResult -Command 'git add a.ps1 && git -C /a add b.ps1'

        # Assert
        $result.Targets | Should -Be @($script:Root, '/a') -Because 'each segment contributes its own target'
    }

    It 'U20 rejects a relative session root and normalizes a backslash session root' {
        # Act
        $relative = Get-OrchestrationCommandTarget -Command 'git add a.ps1' -SessionRoot 'relative/root'
        $windows = Get-OrchestrationCommandTarget -Command 'git add a.ps1' -SessionRoot 'C:\wt'

        # Assert
        $relative.ReasonCode | Should -Be 'target-unresolvable' -Because 'every unresolved result carries the same code'
        $relative.Detail.StartsWith('session-root-not-absolute') | Should -BeTrue -Because 'rule R0 requires an absolute session root'
        $windows.Targets | Should -Be @('C:/wt') -Because 'the session root normalizes to forward slashes'
    }

    It 'U21 returns the four patch-marker paths and nothing for a plain command' {
        # Arrange
        $patch = "*** Begin Patch`n*** Add File: a.ps1`n+x`n*** Update File: b.ps1`n*** Move to: c.ps1`n*** Delete File: d.ps1`n*** End Patch"

        # Act
        $paths = @(Get-OrchestrationPatchMarkerPath -PatchText $patch)
        $none = @(Get-OrchestrationPatchMarkerPath -PatchText 'git add a.ps1')

        # Assert
        $paths | Should -Be @('a.ps1', 'b.ps1', 'c.ps1', 'd.ps1') -Because 'every marker contributes its path in order'
        $none.Count | Should -Be 0 -Because 'text that is not a patch names no path'
    }

    It 'U22 gives <Expected> for <Label>' -ForEach @(
        @{ Label = 'no epic scope'; Resolved = $true; Targets = @('/synthetic-worktrees/session', '/a'); Detail = ''; Epic = @(); Reasons = @{}; Expected = 'none'; Code = ''; ExpectedDetail = '' }
        @{ Label = 'an unresolved target result'; Resolved = $false; Targets = @(); Detail = 'directory-change: cd /x'; Epic = @(''); Reasons = @{}; Expected = 'deny'; Code = 'target-unresolvable'; ExpectedDetail = 'directory-change: cd /x' }
        @{ Label = 'an ambiguous target'; Resolved = $true; Targets = @('/a'); Detail = ''; Epic = @(''); Reasons = @{ '/a' = 'target-worktree-ambiguous' }; Expected = 'deny'; Code = 'target-ambiguous'; ExpectedDetail = '/a' }
        @{ Label = 'an unresolved selector target'; Resolved = $true; Targets = @('/a'); Detail = ''; Epic = @(''); Reasons = @{ '/a' = 'selector-unresolved' }; Expected = 'deny'; Code = 'target-unresolvable'; ExpectedDetail = 'selector-unresolved: /a' }
        @{ Label = 'a non-epic target'; Resolved = $true; Targets = @('/a'); Detail = ''; Epic = @(''); Reasons = @{ '/a' = 'branch-mismatch' }; Expected = 'deny'; Code = 'target-mixed'; ExpectedDetail = '/a' }
        @{ Label = 'all-epic targets'; Resolved = $true; Targets = @('/synthetic-worktrees/session', '/a'); Detail = ''; Epic = @('', '/a'); Reasons = @{}; Expected = 'evaluate'; Code = ''; ExpectedDetail = '' }
    ) {
        # Arrange
        $epic = $Epic
        $reasons = $Reasons
        $resolver = {
            param([string] $Selector)
            $isEpic = $epic -contains $Selector
            $reason = if ($reasons.ContainsKey($Selector)) { $reasons[$Selector] } elseif ($isEpic) { 'epic-scope' } else { 'branch-mismatch' }
            [pscustomobject]@{ IsEpicScope = $isEpic; Reason = $reason; Checkpoint = $null; CheckpointPath = ''; MergeInProgress = $true }
        }.GetNewClosure()
        $targetResult = [pscustomobject]@{ Resolved = $Resolved; Targets = [string[]]$Targets; ReasonCode = $(if ($Resolved) { '' } else { 'target-unresolvable' }); Detail = $Detail }

        # Act
        $verdict = Resolve-OrchestrationEpicTargetVerdict -SessionRoot $script:Root -TargetResult $targetResult -ScopeResolver $resolver

        # Assert
        $verdict.Verdict | Should -Be $Expected -Because "$Label decides the verdict"
        $verdict.ReasonCode | Should -Be $Code -Because "$Label carries its reason code"
        $verdict.Detail | Should -Be $ExpectedDetail -Because "$Label carries its detail"
        if ($Expected -eq 'evaluate') {
            @($verdict.Evaluations).Count | Should -Be 2 -Because 'one evaluation per target'
            @($verdict.Evaluations | Where-Object { $_.IsSessionRoot }).Target | Should -Be $script:Root -Because 'only the session-root key is flagged'
        }
    }

    It 'U23 resolves a target equal to the session root once' {
        # Arrange
        $calls = [System.Collections.Generic.List[string]]::new()
        $resolver = {
            param([string] $Selector)
            $calls.Add($Selector)
            [pscustomobject]@{ IsEpicScope = $true; Reason = 'epic-scope'; Checkpoint = $null; CheckpointPath = ''; MergeInProgress = $true }
        }.GetNewClosure()
        $targetResult = [pscustomobject]@{ Resolved = $true; Targets = [string[]]@($script:Root); ReasonCode = ''; Detail = '' }

        # Act
        $verdict = Resolve-OrchestrationEpicTargetVerdict -SessionRoot $script:Root -TargetResult $targetResult -ScopeResolver $resolver

        # Assert
        $calls.Count | Should -Be 1 -Because 'the session-root scope is reused for an equal target'
        $verdict.Verdict | Should -Be 'evaluate' -Because 'the only target is epic scope'
    }
}
