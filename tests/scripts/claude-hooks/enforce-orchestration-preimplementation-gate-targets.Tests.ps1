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

    It 'U11b resolves <Command> to the session root (identifier-embedded name)' -ForEach @(
        @{ Command = 'git add docs/legit_dir-notes.md' }
        @{ Command = 'MY_GIT_DIR=1 git add a.ps1' }
    ) {
        # Act
        $result = Get-CommandTargetResult -Command $Command

        # Assert
        $result.Resolved | Should -BeTrue -Because 'a relocation name embedded in a longer identifier is not a relocation (issue #903, #732 CR-2)'
        $result.Targets | Should -Be @($script:Root) -Because 'the segment runs in the session root'
    }

    It 'U11c gives git-relocation for an env-drive assignment' {
        # Act
        $result = Get-CommandTargetResult -Command '$env:GIT_DIR=''/x''; git add a.ps1'

        # Assert
        $result.Resolved | Should -BeFalse -Because 'a PowerShell env-drive assignment moves the git directory'
        $result.Detail.StartsWith('git-relocation') | Should -BeTrue -Because 'the detail names rule R5'
    }

    It 'U11d still denies a standalone-word mention of a relocation name (recorded fail-closed residual)' {
        # Act
        $result = Get-CommandTargetResult -Command 'git commit -m ''mention GIT_DIR here'' -- a.ps1'

        # Assert
        $result.Resolved | Should -BeFalse -Because 'a standalone relocation word fails closed (issue #903, #732 CR-2 residual)'
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

    It 'U24 gives git-command-word-missing for a token array without git' {
        # Act
        $result = Get-OrchestrationGitSelectorTarget -Token @('status')

        # Assert
        $result.Rule | Should -Be 'git-command-word-missing' -Because 'a token array without git has no command word (issue #903, #732 CR-6)'
    }

    It 'U25 gives outcome <Expected> for <Label>' -ForEach @(
        @{ Label = 'a none verdict'; Case = 'none'; Expected = 'none' }
        @{ Label = 'a deny verdict'; Case = 'deny'; Expected = 'deny' }
        @{ Label = 'a failing session-root scope'; Case = 'session-root'; Expected = 'deny' }
        @{ Label = 'a failing non-session-root target'; Case = 'target'; Expected = 'deny' }
        @{ Label = 'an evaluation with no failure'; Case = 'ready'; Expected = 'allow' }
    ) {
        # Arrange (issue #903, #732 CR-3): in-memory verdicts; the readiness predicate reads Scope.Failure.
        $checkpointPath = '/synthetic-worktrees/session/artifacts/orchestration/epic-orchestrator-state.json'
        $failing = [pscustomobject]@{ CheckpointPath = $checkpointPath; Failure = 'merge-in-progress' }
        $ready = [pscustomobject]@{ CheckpointPath = $checkpointPath; Failure = '' }
        $verdict = switch ($Case) {
            'none' { [pscustomobject]@{ Verdict = 'none'; ReasonCode = ''; Detail = ''; Evaluations = @() } }
            'deny' { [pscustomobject]@{ Verdict = 'deny'; ReasonCode = 'target-mixed'; Detail = '/a'; Evaluations = @() } }
            'session-root' {
                $evaluation = [pscustomobject]@{ Target = $script:Root; IsSessionRoot = $true; Scope = $failing }
                [pscustomobject]@{ Verdict = 'evaluate'; ReasonCode = ''; Detail = ''; Evaluations = @($evaluation) }
            }
            'target' {
                $evaluation = [pscustomobject]@{ Target = '/a'; IsSessionRoot = $false; Scope = $failing }
                [pscustomobject]@{ Verdict = 'evaluate'; ReasonCode = ''; Detail = ''; Evaluations = @($evaluation) }
            }
            default {
                $evaluation = [pscustomobject]@{ Target = $script:Root; IsSessionRoot = $true; Scope = $ready }
                [pscustomobject]@{ Verdict = 'evaluate'; ReasonCode = ''; Detail = ''; Evaluations = @($evaluation) }
            }
        }
        $expectedReason = switch ($Case) {
            'deny' { Get-OrchestrationEpicTargetDenyReason -ReasonCode 'target-mixed' -Detail '/a' }
            'session-root' { "PREIMPLEMENTATION_GATE_BLOCKED: this epic-scope operation was evaluated against /synthetic-worktrees/session/artifacts/orchestration/epic-orchestrator-state.json, and the failed readiness predicate is 'merge-in-progress'. Implementation operations in epic scope require that checkpoint to satisfy every readiness predicate, and a production path may be staged or edited only while a merge is in progress." }
            'target' { Get-OrchestrationEpicTargetDenyReason -ReasonCode 'target-not-ready' -Detail '/a' -CheckpointPath $checkpointPath -Failure 'merge-in-progress' }
            default { '' }
        }

        # Act
        $outcome = Resolve-OrchestrationEpicTargetOutcome -Verdict $verdict -ReadinessFailure { param($Scope) $Scope.Failure }

        # Assert
        $outcome.Outcome | Should -Be $Expected -Because "$Label decides the outcome"
        $outcome.Reason | Should -BeExactly $expectedReason -Because "$Label carries the unchanged reason text"
    }

    It 'U26 gives the exact deny reason for <Label>' -ForEach @(
        @{ Label = 'target-ambiguous'; Code = 'target-ambiguous'; Detail = '/a'; Expected = 'PREIMPLEMENTATION_GATE_BLOCKED: target-ambiguous: more than one worktree claims the epic integration branch for target /a. Implementation operations in epic scope require an unambiguous target worktree.' }
        @{ Label = 'target-unresolvable (fall-through)'; Code = 'target-unresolvable'; Detail = 'directory-change: cd /x'; Expected = 'PREIMPLEMENTATION_GATE_BLOCKED: target-unresolvable: the target worktree of this epic-scope operation cannot be resolved (directory-change: cd /x). Implementation operations in epic scope require every command segment and path to name an absolute, resolvable target.' }
    ) {
        # Arrange (issue #903 remediation RI-1): the reason code and detail come from the data row.

        # Act
        $reason = Get-OrchestrationEpicTargetDenyReason -ReasonCode $Code -Detail $Detail

        # Assert
        $reason | Should -BeExactly $Expected -Because "$Label keeps its unchanged reason text"
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
}
