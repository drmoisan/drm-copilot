#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #713 - attribution-trailer commit forms in the preimplementation gate staging
# exemption. Every case runs once against the Claude gate and once against the Codex gate,
# each dot-sourced from a path resolved relative to this file, so the changed lines execute
# in both canonical helpers copies. Admit rows assert the exemption predicate first and only
# then drive the pure decision seam with an explicitly not-ready checkpoint; an allow
# decision returns before any epic-scope read. Deny rows assert at predicate level only and
# never call the decision seam. The cases read the gate files only: no temporary file, no
# child process, and no network access.

Describe 'preimplementation gate attribution trailers (<Runtime>)' -ForEach @(
    @{ Runtime = 'claude'; GateRelativePath = '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1'; PayloadKind = 'envelope'; Surface = 'Claude'; Seam = @('Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText', 'Get-EpicScopeCheckpointText'); ExtraSeam = @('Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent') }
    @{ Runtime = 'codex'; GateRelativePath = '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'; PayloadKind = 'mapped'; Surface = 'Codex'; Seam = @('Get-EpicScopeCheckpointText'); ExtraSeam = @('Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText') }
) {
    BeforeAll {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        . (Join-Path $repoRoot $GateRelativePath)
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam $Seam -Surface $Surface
        Register-EpicStateBaselineMock -Seam $ExtraSeam -Surface $Surface

        function Get-AttributionTrailerDecision {
            <#
                Classifies one command text against an explicitly not-ready checkpoint
                through the decision seam, in the payload shape of the runtime under test.
            #>
            param(
                [Parameter(Mandatory)][string] $Command,
                [Parameter(Mandatory)][string] $Kind
            )

            $toolInput = @{ command = $Command }
            if ($Kind -eq 'envelope') {
                $toolInput = @{ tool_name = 'Bash'; tool_input = @{ command = $Command } }
            }
            $checkpoint = @{ 'issue-num' = ''; 'feature-folder' = ''; route_id = ''; lifecycle_ready = $false }
            return Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw ($toolInput | ConvertTo-Json -Compress -Depth 5) `
                -CheckpointRaw ($checkpoint | ConvertTo-Json -Compress)
        }
        if ($Runtime -eq 'claude') { Mock Resolve-OrchestrationGateTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } } }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface $Surface -Seam $Seam }

    It 'admits <Label>' -ForEach @(
        @{ Label = 'a separate-value trailer option'; Command = 'git commit -m ''docs: plan'' --trailer ''Co-Authored-By: C <n@a.com>'' -- docs/features/active/x/plan.md' }
        @{ Label = 'an equals-form trailer option'; Command = 'git commit -m ''docs: plan'' --trailer=''Co-Authored-By: C <n@a.com>'' -- docs/features/active/x/plan.md' }
        @{ Label = 'two trailer options'; Command = 'git commit -m ''docs: plan'' --trailer ''Co-Authored-By: C <n@a.com>'' --trailer ''Claude-Session: session_x'' -- docs/features/active/x/plan.md' }
        @{ Label = 'a multi-message form with both trailers in one single-quoted paragraph'; Command = ('git commit -m ''docs: plan'' -m ''Co-Authored-By: C <n@a.com>' + [char]10 + 'Claude-Session: session_x'' -- docs/features/active/x/plan.md') }
        @{ Label = 'a single-quoted subject containing a backtick'; Command = 'git commit -m ''docs: fix `Foo` handling'' -- docs/features/active/x/plan.md' }
        @{ Label = 'a single-quoted subject containing a dollar sign and a command substitution'; Command = 'git commit -m ''docs: costs $5 and $(x)'' -- docs/features/active/x/plan.md' }
        @{ Label = 'a chained add and trailer-bearing commit'; Command = 'git add docs/features/active/x/a.md && git commit -m ''docs: plan'' --trailer ''Co-Authored-By: C <n@a.com>'' -- docs/features/active/x/a.md' }
        @{ Label = 'a POSIX-rooted selector with a trailer option'; Command = 'git -C /repo/wt commit -m ''docs: plan'' --trailer ''Co-Authored-By: C <n@a.com>'' -- docs/features/active/x/plan.md' }
        @{ Label = 'a hash inside a single-quoted message'; Command = 'git commit -m ''docs: step #2'' -- docs/features/active/x/plan.md' }
        @{ Label = 'a hash inside a double-quoted message'; Command = 'git commit -m "docs: step #2" -- docs/features/active/x/plan.md' }
        @{ Label = 'an inline angle-bracket attribution in a double-quoted subject'; Command = 'git commit -m "docs: plan Co-Authored-By: C <n@a.com>" -- docs/features/active/x/plan.md' }
        @{ Label = 'an empty single-quoted trailer value'; Command = 'git commit -m ''docs: plan'' --trailer '''' -- docs/features/active/x/plan.md' }
        @{ Label = 'a trailer option taking the double-dash separator as its value (CR-4)'; Command = 'git commit -m x --trailer -- docs/features/active/x/a.md' }
    ) {
        # Arrange: the command text is supplied by the data row.

        # Act and Assert: the predicate is asserted first, so a row the exemption rejects
        # never reaches the decision seam or its epic-scope read.
        Test-ExemptOrchestrationStagingCommand -CommandText $Command |
            Should -BeTrue -Because 'every operand is exempt and every character is resolvable'
        $decision = Get-AttributionTrailerDecision -Command $Command -Kind $PayloadKind
        $decision.hookSpecificOutput.permissionDecision |
            Should -Be 'allow' -Because 'an exempt staging command needs no ready checkpoint'
    }

    It 'denies <Label>' -ForEach @(
        @{ Label = 'an unquoted redirection after a single-quoted dollar message'; Command = 'git commit -m ''costs $5'' -- docs/features/active/x/plan.md > out.txt' }
        @{ Label = 'a command substitution in an operand'; Command = 'git add docs/features/active/$(echo x)/a.md' }
        @{ Label = 'a variable expansion in an operand'; Command = 'git add docs/features/active/$FEATURE/a.md' }
        @{ Label = 'a dollar sign inside double quotes'; Command = 'git commit -m "costs $5" -- docs/features/active/x/plan.md' }
        @{ Label = 'a command substitution inside double quotes'; Command = 'git commit -m "$(date)" -- docs/features/active/x/plan.md' }
        @{ Label = 'a backtick inside double quotes'; Command = 'git commit -m "fix `Foo`" -- docs/features/active/x/plan.md' }
        @{ Label = 'the heredoc command-substitution commit recipe'; Command = ('git commit -m "$(cat <<''EOF''' + [char]10 + 'docs: plan' + [char]10 + [char]10 + 'Co-Authored-By: C <n@a.com>' + [char]10 + 'EOF' + [char]10 + ')" -- docs/features/active/x/plan.md') }
        @{ Label = 'ANSI-C dollar-single-quote quoting'; Command = 'git commit -m $''docs\nplan'' -- docs/features/active/x/plan.md' }
        @{ Label = 'an and-chain to a non-exempt add'; Command = 'git commit -m ''docs: plan'' --trailer ''Co-Authored-By: C <n@a.com>'' -- docs/features/active/x/plan.md && git add src/x.ts' }
        @{ Label = 'a semicolon chain to a non-git command'; Command = 'git commit -m ''docs: plan'' -- docs/features/active/x/plan.md; touch src/x.ts' }
        @{ Label = 'a non-exempt pathspec with a trailer option'; Command = 'git commit -m ''fix'' --trailer ''Co-Authored-By: C <n@a.com>'' -- src/x.ts' }
        @{ Label = 'a pathless commit carrying a message and a trailer'; Command = 'git commit -m ''docs: plan'' --trailer ''Co-Authored-By: C <n@a.com>''' }
        @{ Label = 'a trailer option on the add subcommand'; Command = 'git add --trailer ''x'' -- docs/features/active/x/a.md' }
        @{ Label = 'a dangling trailer option with no value'; Command = 'git commit -m ''docs: plan'' docs/features/active/x/plan.md --trailer' }
        @{ Label = 'a message-file option'; Command = 'git commit -F docs/features/active/x/msg.txt -- docs/features/active/x/plan.md' }
        @{ Label = 'an equals-form file option'; Command = 'git commit --file=docs/features/active/x/msg.txt -- docs/features/active/x/plan.md' }
        @{ Label = 'a stdin message file fed by a heredoc'; Command = ('git commit -F - <<''EOF'' -- docs/features/active/x/plan.md' + [char]10 + 'docs: plan' + [char]10 + 'EOF') }
        @{ Label = 'the hash-quote comment desynchronization line'; Command = ('git commit -m #''' + [char]10 + 'git add src/prod.ts && git commit -m x' + [char]10 + ''' -- docs/features/active/x/a.md') }
        @{ Label = 'an unquoted trailing comment'; Command = 'git add docs/features/active/x/a.md # note' }
        @{ Label = 'a mid-word hash in an exempt operand'; Command = 'git add docs/features/active/x#y/a.md' }
        @{ Label = 'an unbalanced single quote around a dollar sign'; Command = 'git commit -m ''costs $5 -- docs/features/active/x/plan.md' }
        @{ Label = 'an escaped single quote near a dollar sign'; Command = 'git commit -m ''it\''s $5'' -- docs/features/active/x/plan.md' }
        @{ Label = 'a typographic single-quoted command substitution'; Command = ('git commit -m ''a' + [char]0x2019 + ' $(x) ' + [char]0x2018 + 'b'' -- docs/features/active/x/plan.md') }
        @{ Label = 'a typographic double-quoted command substitution'; Command = ('git commit -m ''a' + [char]0x2019 + ' ' + [char]0x201C + '$(x)' + [char]0x201D + ' ' + [char]0x2018 + 'b'' -- docs/features/active/x/plan.md') }
        @{ Label = 'a typographic single quote around a non-exempt pathspec'; Command = ('git commit -m ''a' + [char]0x2019 + ' src/prod.ts ' + [char]0x2018 + 'b'' -- docs/features/active/x/plan.md') }
        @{ Label = 'a trailer option taking the double-dash separator before a non-exempt operand (CR-4)'; Command = 'git commit -m x --trailer -- src/x.ts' }
        @{ Label = 'a single low-9 quotation mark (U+201A)'; Command = ('git commit -m ''a' + [char]0x201A + 'b'' -- docs/features/active/x/plan.md') }
        @{ Label = 'a single high-reversed-9 quotation mark (U+201B)'; Command = ('git commit -m ''a' + [char]0x201B + 'b'' -- docs/features/active/x/plan.md') }
        @{ Label = 'a double low-9 quotation mark (U+201E)'; Command = ('git commit -m ''a' + [char]0x201E + 'b'' -- docs/features/active/x/plan.md') }
    ) {
        # Act
        $isExempt = Test-ExemptOrchestrationStagingCommand -CommandText $Command
        $isImplementation = Test-ImplementationCommand -Command $Command

        # Assert
        $isExempt | Should -BeFalse -Because 'the exemption must not admit this form'
        $isImplementation | Should -BeTrue -Because 'the staging trigger must still classify this form as implementation'
    }
}
