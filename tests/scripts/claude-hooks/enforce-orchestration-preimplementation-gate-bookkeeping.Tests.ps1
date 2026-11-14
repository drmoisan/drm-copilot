#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Unit suite for enforce-orchestration-preimplementation-gate-bookkeeping.ps1 (issue #1160).

.DESCRIPTION
    Runs against the .claude/hooks and .codex/hooks copies of the bookkeeping sibling through
    Describe -ForEach. Each copy is loaded with the helpers file and hook-epic-fan-in.ps1 of its
    own surface, so the real Test-ExemptOrchestrationSelector, Get-EpicFanInAllowance, and
    Test-EpicMergedFeaturePath run. The item checkpoint suffix that the gate file supplies in
    production is set here, and Get-OrchestrationGateStagedIndex, which the cleanup sibling
    supplies in production, is a local stub that every leg case mocks.

    Cases: the configuration seam (spec AC-10), every invalid configuration (spec AC-12), the
    root helper, the declared-root anchor and the -C selector check (decision D14), and the
    leg's allow and deny shapes. Both seams are mocked in every leg case, so no case reads a
    real configuration file or a real git index, and no temporary file is created.
#>

Describe 'enforce-orchestration-preimplementation-gate-bookkeeping.ps1 (<Surface> copy)' -ForEach @(
    @{ Surface = 'Claude'; Directory = '.claude/hooks' }
    @{ Surface = 'Codex'; Directory = '.codex/hooks' }
) {
    BeforeAll {
        $script:BookkeepingRepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $hookDirectory = Join-Path $script:BookkeepingRepoRoot $Directory
        . (Join-Path $hookDirectory 'enforce-orchestration-preimplementation-gate-helpers.ps1')
        . (Join-Path $hookDirectory 'hook-epic-fan-in.ps1')
        . (Join-Path $hookDirectory 'enforce-orchestration-preimplementation-gate-bookkeeping.ps1')
        $script:CheckpointPaths = @('artifacts/orchestration/orchestrator-state.json')
        $script:SyntheticCheckpointPath = '/synthetic-worktrees/item/artifacts/orchestration/orchestrator-state.json'

        function Get-OrchestrationGateStagedIndex {
            # Stub of the cleanup sibling's staged-index seam; every leg case mocks it.
            param([Parameter(Mandatory)][string] $WorktreeRoot)
            throw "unmocked staged-index read of $WorktreeRoot"
        }
    }

    Context 'configuration seam (spec AC-10)' {
        It 'returns null when the configuration file does not exist' {
            Mock Test-Path { $false }

            Get-OrchestrationGateBookkeepingConfigText | Should -BeNullOrEmpty
        }

        It 'resolves config/preimplementation-gate.json two levels above its own directory' {
            Mock Test-Path { $false }
            $expected = ((Join-Path (Join-Path $script:BookkeepingRepoRoot 'config') 'preimplementation-gate.json') -replace '\\', '/')

            $null = Get-OrchestrationGateBookkeepingConfigText

            Should -Invoke Test-Path -Times 1 -Exactly -ParameterFilter { ($LiteralPath -replace '\\', '/') -eq $expected }
        }

        It 'returns the file text when the file exists' {
            Mock Test-Path { $true }
            Mock Get-Content { '{"schema_version": 1, "bookkeeping_roots": []}' }

            Get-OrchestrationGateBookkeepingConfigText | Should -BeExactly '{"schema_version": 1, "bookkeeping_roots": []}'
        }
    }

    Context 'configuration parser' {
        It 'accepts a valid list' {
            $result = ConvertFrom-OrchestrationGateBookkeepingConfig -Text '{"schema_version": 1, "bookkeeping_roots": [".claude/agent-memory/", "notes/"]}'

            $result.Valid | Should -BeTrue
            $result.Roots | Should -Be @('.claude/agent-memory/', 'notes/')
            $result.Detail | Should -BeExactly ''
        }

        It 'accepts an empty list' {
            $result = ConvertFrom-OrchestrationGateBookkeepingConfig -Text '{"schema_version": 1, "bookkeeping_roots": []}'

            $result.Valid | Should -BeTrue
            @($result.Roots).Count | Should -Be 0
        }

        It 'rejects <Label> (spec AC-12)' -ForEach @(
            @{ Label = 'malformed JSON'; Text = '{"schema_version": 1,'; Detail = 'the file is not valid JSON' }
            @{ Label = 'empty text'; Text = ''; Detail = 'the document is not a JSON object' }
            @{ Label = 'a non-object'; Text = '[".claude/agent-memory/"]'; Detail = 'the document is not a JSON object' }
            @{ Label = 'schema_version 2'; Text = '{"schema_version": 2, "bookkeeping_roots": []}'; Detail = 'schema_version is not the integer 1' }
            @{ Label = 'a string schema_version'; Text = '{"schema_version": "1", "bookkeeping_roots": []}'; Detail = 'schema_version is not the integer 1' }
            @{ Label = 'a fractional schema_version'; Text = '{"schema_version": 1.5, "bookkeeping_roots": []}'; Detail = 'schema_version is not the integer 1' }
            @{ Label = 'a boolean schema_version'; Text = '{"schema_version": true, "bookkeeping_roots": []}'; Detail = 'schema_version is not the integer 1' }
            @{ Label = 'a non-array bookkeeping_roots'; Text = '{"schema_version": 1, "bookkeeping_roots": ".claude/agent-memory/"}'; Detail = 'bookkeeping_roots is not an array' }
            @{ Label = 'a non-string entry'; Text = '{"schema_version": 1, "bookkeeping_roots": [1]}'; Detail = 'bookkeeping_roots entry 0 is not a string' }
            @{ Label = 'an entry with a space'; Text = '{"schema_version": 1, "bookkeeping_roots": ["agent memory/"]}'; Detail = 'bookkeeping_roots entry 0 must use only A-Z a-z 0-9 . _ / - and end with /' }
            @{ Label = 'an entry without a trailing slash'; Text = '{"schema_version": 1, "bookkeeping_roots": ["notes"]}'; Detail = 'bookkeeping_roots entry 0 must use only A-Z a-z 0-9 . _ / - and end with /' }
            @{ Label = 'an entry starting with a slash'; Text = '{"schema_version": 1, "bookkeeping_roots": ["/notes/"]}'; Detail = 'bookkeeping_roots entry 0 starts with /' }
            @{ Label = 'an entry containing //'; Text = '{"schema_version": 1, "bookkeeping_roots": ["a//b/"]}'; Detail = 'bookkeeping_roots entry 0 contains //' }
            @{ Label = 'an entry with a . segment'; Text = '{"schema_version": 1, "bookkeeping_roots": ["a/./b/"]}'; Detail = 'bookkeeping_roots entry 0 has a . or .. segment' }
            @{ Label = 'an entry with a .. segment'; Text = '{"schema_version": 1, "bookkeeping_roots": ["notes/", "a/../b/"]}'; Detail = 'bookkeeping_roots entry 1 has a . or .. segment' }
            @{ Label = 'a duplicate entry'; Text = '{"schema_version": 1, "bookkeeping_roots": ["notes/", "notes/"]}'; Detail = 'bookkeeping_roots entry 1 duplicates an earlier entry' }
            @{ Label = 'an unknown top-level key'; Text = '{"schema_version": 1, "bookkeeping_roots": [], "extra": true}'; Detail = "unknown top-level key 'extra'" }
            @{ Label = 'a missing key'; Text = '{"schema_version": 1}'; Detail = "missing top-level key 'bookkeeping_roots'" }
        ) {
            $result = ConvertFrom-OrchestrationGateBookkeepingConfig -Text $Text

            $result.Valid | Should -BeFalse
            @($result.Roots).Count | Should -Be 0
            $result.Detail | Should -BeExactly $Detail
        }
    }

    Context 'root helper' {
        It 'strips the item checkpoint suffix from <Label>' -ForEach @(
            @{ Label = 'a forward-slash path'; Path = '/synthetic-worktrees/item/artifacts/orchestration/orchestrator-state.json'; Root = '/synthetic-worktrees/item' }
            @{ Label = 'a backslash path'; Path = '\synthetic-worktrees\item\artifacts\orchestration\orchestrator-state.json'; Root = '/synthetic-worktrees/item' }
            @{ Label = 'a path in another case'; Path = '/synthetic-worktrees/item/Artifacts/Orchestration/Orchestrator-State.json'; Root = '/synthetic-worktrees/item' }
        ) {
            Get-OrchestrationGateBookkeepingWorktreeRoot -CheckpointPath $Path -CheckpointSuffix 'artifacts/orchestration/orchestrator-state.json' | Should -BeExactly $Root
        }

        It 'returns null for <Label>' -ForEach @(
            @{ Label = 'an empty path'; Path = ''; Suffix = 'artifacts/orchestration/orchestrator-state.json' }
            @{ Label = 'an empty suffix'; Path = '/synthetic-worktrees/item/artifacts/orchestration/orchestrator-state.json'; Suffix = '' }
            @{ Label = 'another checkpoint name'; Path = '/synthetic-worktrees/item/artifacts/orchestration/epic-orchestrator-state.json'; Suffix = 'artifacts/orchestration/orchestrator-state.json' }
            @{ Label = 'a path that is only the suffix'; Path = '/artifacts/orchestration/orchestrator-state.json'; Suffix = 'artifacts/orchestration/orchestrator-state.json' }
        ) {
            Get-OrchestrationGateBookkeepingWorktreeRoot -CheckpointPath $Path -CheckpointSuffix $Suffix | Should -BeNullOrEmpty
        }
    }

    Context 'declared-root anchor (decision D14)' {
        It 'anchors on a named declared-root path' {
            Test-OrchestrationGateBookkeepingAnchor -Path @('docs/features/active/x/plan.md', '.claude/agent-memory/r/a.md') -Root @('.claude/agent-memory/') | Should -BeTrue
        }

        It 'anchors on a staged declared-root path' {
            Test-OrchestrationGateBookkeepingAnchor -Path @('.claude/agent-memory/r/notes.md') -Root @('.claude/agent-memory/') | Should -BeTrue
        }

        It 'does not anchor on issue #539 tree paths only' {
            Test-OrchestrationGateBookkeepingAnchor -Path @('docs/features/active/x/plan.md', 'docs/features/epics/e/epic.md') -Root @('.claude/agent-memory/') | Should -BeFalse
        }

        It 'does not anchor on a path equal to the root or on no path' {
            Test-OrchestrationGateBookkeepingAnchor -Path @('.claude/agent-memory/') -Root @('.claude/agent-memory/') | Should -BeFalse
            Test-OrchestrationGateBookkeepingAnchor -Path @() -Root @('.claude/agent-memory/') | Should -BeFalse
        }
    }

    Context '-C selector check (decision D14)' {
        It 'accepts an absolute selector' {
            Test-OrchestrationGateBookkeepingSelector -Command 'git -C /synthetic-worktrees/item add .claude/agent-memory/r/a.md' | Should -BeTrue
        }

        It 'rejects a UNC selector' {
            Test-OrchestrationGateBookkeepingSelector -Command 'git -C //server/share add .claude/agent-memory/r/a.md' | Should -BeFalse
        }

        It 'accepts a command without a selector' {
            Test-OrchestrationGateBookkeepingSelector -Command 'git add .claude/agent-memory/r/a.md' | Should -BeTrue
        }

        It 'rejects unbalanced text' {
            Test-OrchestrationGateBookkeepingSelector -Command 'git add ".claude/agent-memory/r/a.md' | Should -BeFalse
        }
    }

    Context 'bookkeeping leg' {
        BeforeEach {
            Mock Get-OrchestrationGateBookkeepingConfigText { $null }
            Mock Get-OrchestrationGateStagedIndex { [pscustomobject]@{ ExitCode = 0; Output = ".claude/agent-memory/r/notes.md`0" } }
        }

        It 'allows <Label> under the default configuration' -ForEach @(
            @{ Label = 'git add of an agent-memory file'; Command = 'git add .claude/agent-memory/r/notes.md' }
            @{ Label = 'git add -- of an agent-memory file'; Command = 'git add -- .claude/agent-memory/r/notes.md' }
            @{ Label = 'a mixed git add --'; Command = 'git add -- .claude/agent-memory/r/a.md docs/features/active/x/plan.md' }
            @{ Label = 'git commit -m with a pathspec'; Command = 'git commit -m m -- .claude/agent-memory/r/a.md' }
            @{ Label = 'git commit -F with a pathspec'; Command = 'git commit -F msg.txt -- .claude/agent-memory/r/a.md' }
        ) {
            $result = Get-OrchestrationBookkeepingStagingResult -Command $Command -CheckpointPath ''

            $result.Allowed | Should -BeTrue
            $result.DenySuffix | Should -BeExactly ''
            Should -Invoke Get-OrchestrationGateStagedIndex -Times 0 -Exactly
        }

        It 'allows a pathless commit whose staged index names agent-memory paths' {
            $result = Get-OrchestrationBookkeepingStagingResult -Command 'git commit -m m' -CheckpointPath $script:SyntheticCheckpointPath

            $result.Allowed | Should -BeTrue
            Should -Invoke Get-OrchestrationGateStagedIndex -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -ceq '/synthetic-worktrees/item' }
        }

        It 'denies a pathless commit without a root and does not read the staged index' {
            $result = Get-OrchestrationBookkeepingStagingResult -Command 'git commit -m m' -CheckpointPath ''

            $result.Allowed | Should -BeFalse
            $result.DenySuffix | Should -BeExactly ''
            Should -Invoke Get-OrchestrationGateStagedIndex -Times 0 -Exactly
        }

        It 'denies a pathless commit whose staged index holds only issue #539 tree paths' {
            Mock Get-OrchestrationGateStagedIndex { [pscustomobject]@{ ExitCode = 0; Output = "docs/features/active/x/plan.md`0" } }

            (Get-OrchestrationBookkeepingStagingResult -Command 'git commit -m m' -CheckpointPath $script:SyntheticCheckpointPath).Detail | Should -BeExactly 'no path lies under a declared root'
        }

        It 'denies a pathless commit whose staged index is <Label>' -ForEach @(
            @{ Label = 'empty'; ExitCode = 0; Output = '' }
            @{ Label = 'mixed'; ExitCode = 0; Output = ".claude/agent-memory/r/a.md`0src/app.ps1`0" }
            @{ Label = 'unreadable'; ExitCode = 128; Output = '' }
        ) {
            $staged = [pscustomobject]@{ ExitCode = $ExitCode; Output = $Output }
            Mock Get-OrchestrationGateStagedIndex { $staged }.GetNewClosure()

            (Get-OrchestrationBookkeepingStagingResult -Command 'git commit -m m' -CheckpointPath $script:SyntheticCheckpointPath).Allowed | Should -BeFalse
        }

        It 'denies a named commit of issue #539 tree paths only' {
            (Get-OrchestrationBookkeepingStagingResult -Command 'git commit -F msg.txt -- docs/features/active/x/plan.md' -CheckpointPath '').Detail | Should -BeExactly 'no path lies under a declared root'
        }

        It 'denies <Label>' -ForEach @(
            @{ Label = 'git add .'; Command = 'git add .' }
            @{ Label = 'the root itself'; Command = 'git add .claude/agent-memory/' }
            @{ Label = 'a .. segment'; Command = 'git add .claude/agent-memory/../src/x.ps1' }
            @{ Label = 'a non-bookkeeping operand'; Command = 'git add .claude/agent-memory/r/a.md src/x.ps1' }
            @{ Label = 'a chained runner'; Command = 'git add .claude/agent-memory/r/a.md && pytest' }
            @{ Label = 'git commit -a'; Command = 'git commit -am m' }
        ) {
            (Get-OrchestrationBookkeepingStagingResult -Command $Command -CheckpointPath '').Allowed | Should -BeFalse
        }

        It 'denies a bookkeeping command whose -C selector is rejected' {
            (Get-OrchestrationBookkeepingStagingResult -Command 'git -C //server/share add .claude/agent-memory/r/a.md' -CheckpointPath '').Detail | Should -BeExactly 'a -C selector is not accepted'
        }

        It 'is disabled by an empty declared list' {
            Mock Get-OrchestrationGateBookkeepingConfigText { '{"schema_version": 1, "bookkeeping_roots": []}' }

            $result = Get-OrchestrationBookkeepingStagingResult -Command 'git add .claude/agent-memory/r/notes.md' -CheckpointPath ''

            $result.Allowed | Should -BeFalse
            $result.DenySuffix | Should -BeExactly ''
        }

        It 'uses a declared list that replaces the default' {
            Mock Get-OrchestrationGateBookkeepingConfigText { '{"schema_version": 1, "bookkeeping_roots": ["notes/"]}' }

            (Get-OrchestrationBookkeepingStagingResult -Command 'git add notes/a.md' -CheckpointPath '').Allowed | Should -BeTrue
            (Get-OrchestrationBookkeepingStagingResult -Command 'git add .claude/agent-memory/r/notes.md' -CheckpointPath '').Allowed | Should -BeFalse
        }

        It 'returns the invalid-configuration suffix' {
            Mock Get-OrchestrationGateBookkeepingConfigText { '{"schema_version": 2, "bookkeeping_roots": []}' }

            $result = Get-OrchestrationBookkeepingStagingResult -Command 'git add .claude/agent-memory/r/notes.md' -CheckpointPath ''

            $result.Allowed | Should -BeFalse
            $result.DenySuffix | Should -BeExactly ' Bookkeeping leg not applied: BOOKKEEPING_CONFIG_INVALID: schema_version is not the integer 1.'
        }

        It 'returns the invalid-configuration suffix when the file cannot be read' {
            Mock Get-OrchestrationGateBookkeepingConfigText { throw 'read failure' }

            (Get-OrchestrationBookkeepingStagingResult -Command 'git add .claude/agent-memory/r/notes.md' -CheckpointPath '').DenySuffix | Should -BeExactly ' Bookkeeping leg not applied: BOOKKEEPING_CONFIG_INVALID: the file could not be read.'
        }

        It 'does not read the configuration for <Label>' -ForEach @(
            @{ Label = 'an empty command'; Command = '' }
            @{ Label = 'apply_patch text'; Command = "*** Begin Patch`n*** Update File: src/app.ps1`n*** End Patch" }
        ) {
            $result = Get-OrchestrationBookkeepingStagingResult -Command $Command -CheckpointPath ''

            $result.Allowed | Should -BeFalse
            $result.DenySuffix | Should -BeExactly ''
            Should -Invoke Get-OrchestrationGateBookkeepingConfigText -Times 0 -Exactly
        }
    }
}
