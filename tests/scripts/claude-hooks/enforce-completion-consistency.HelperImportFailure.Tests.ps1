#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Helper import-failure proofs for enforce-completion-consistency.ps1 (issue #984).

.DESCRIPTION
    The hook governs only artifacts/orchestration/orchestrator-state.json. When its evaluation-only
    helper enforce-completion-helpers.ps1 fails to load, an edit of any other path is allowed and a
    checkpoint edit is still denied naming the helper (handler H9). A HookPayload.psm1 load failure
    still denies every call. Each row runs against the repository copy and the bundle mirror.

    Helper-failure rows mock Import-Module as a no-op and Join-Path throwing for the helper leaf.
    The in-process rows re-dot-source the hook inside the It, assert the handler variable names the
    leaf (-Because 'E-CONSTRUCTION'), and reset that variable and the dependency-failure state in
    finally. The process rows (CH4, CH5) drive the hook through the & route with stdin and stderr
    redirected and restored. No test creates, renames, moves, or deletes a file.
#>

BeforeDiscovery {
    # The data key HookPath matches the dot-sourced variable name, so the epic-state isolation guard
    # binds the dot-source to the hook literal (issue #935 binding rule).
    $script:RootRows = @(
        @{ Root = 'repository'; HookPath = '.claude/hooks/enforce-completion-consistency.ps1' }
        @{ Root = 'mirror'; HookPath = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1' }
    )
}

Describe 'enforce-completion-consistency.ps1 helper import failure on the <Root> root (#984)' -ForEach $script:RootRows {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $hookPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $HookPath))
        . $hookPath
        # The hook's checkpoint read seam is isolated so no row reads the working tree.
        Mock Get-CheckpointFileContent { $null }
        $script:Ch984HelperLeaf = 'enforce-completion-helpers.ps1'
        $script:Ch984CheckpointRelative = 'artifacts/orchestration/orchestrator-state.json'

        function Initialize-Ch984State {
            # Clears the handler variable and the shared dependency-failure state after a re-dot-source.
            $script:CompletionHelpersImportFailure = $null
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            $script:HookDependencyGuardLoadFailed = $false
        }

        function ConvertTo-Ch984Envelope {
            # Builds an in-memory PreToolUse envelope; FilePath is omitted when empty.
            param([string] $ToolName, [string] $FilePath)
            $toolInput = [ordered]@{}
            if ($FilePath) { $toolInput['file_path'] = $FilePath }
            if ($ToolName -eq 'Write') { $toolInput['content'] = '{"next_step":"complete"}' }
            else { $toolInput['old_string'] = 'a'; $toolInput['new_string'] = 'b' }
            return (@{ session_id = 'ch-984'; hook_event_name = 'PreToolUse'; tool_name = $ToolName; tool_input = $toolInput } | ConvertTo-Json -Compress -Depth 5)
        }

        function Invoke-Ch984HookProcess {
            # Drives the hook through the & route with stdin and stderr redirected; both restored in finally.
            param([string] $Stdin)
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($Stdin))
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                $stdout = @(& $hookPath)
                $exitCode = $LASTEXITCODE
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
            }
            return [pscustomobject]@{ Stdout = (@($stdout | ForEach-Object { [string]$_ }) -join "`n"); Stderr = $errorWriter.ToString(); ExitCode = $exitCode }
        }

        Initialize-Ch984State
    }

    AfterAll {
        . $hookPath
        Initialize-Ch984State
    }

    It 'CH0 allows a non-checkpoint Edit when the helpers load (#984)' {
        $script:CompletionHelpersImportFailure | Should -BeNullOrEmpty -Because 'E-CONSTRUCTION'

        $decision = (Invoke-CompletionConsistencyDecision -ToolInputRaw (ConvertTo-Ch984Envelope -ToolName 'Edit' -FilePath 'src/App/App.csproj')).hookSpecificOutput

        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'CH1 allows a non-checkpoint Edit of <Path> when enforce-completion-helpers.ps1 fails to load (#984)' -ForEach @(
        @{ Path = 'src/App/App.csproj' }
        @{ Path = 'README.md' }
    ) {
        # Arrange: re-dot-source the hook with the helper dot-source forced to fail.
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: enforce-completion-helpers.ps1' } -ParameterFilter { $ChildPath -eq 'enforce-completion-helpers.ps1' }
        try {
            . $hookPath
            $script:CompletionHelpersImportFailure | Should -Be $script:Ch984HelperLeaf -Because 'E-CONSTRUCTION'

            # Act
            $decision = (Invoke-CompletionConsistencyDecision -ToolInputRaw (ConvertTo-Ch984Envelope -ToolName 'Edit' -FilePath $Path)).hookSpecificOutput
        }
        finally { Initialize-Ch984State }

        # Assert
        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'CH2 denies a <Tool> of the <Form> checkpoint path naming enforce-completion-helpers.ps1 when the helpers fail to load (#984)' -ForEach @(
        @{ Tool = 'Write'; Form = 'relative'; Target = 'artifacts/orchestration/orchestrator-state.json' }
        @{ Tool = 'Edit'; Form = 'relative'; Target = 'artifacts/orchestration/orchestrator-state.json' }
        @{ Tool = 'Write'; Form = 'absolute'; Target = '/work/repo/artifacts/orchestration/orchestrator-state.json' }
        @{ Tool = 'Edit'; Form = 'absolute'; Target = '/work/repo/artifacts/orchestration/orchestrator-state.json' }
        @{ Tool = 'Write'; Form = 'backslash'; Target = $null }
        @{ Tool = 'Edit'; Form = 'backslash'; Target = $null }
    ) {
        # Arrange: the backslash form is built from [char]92 so no backslash literal is written.
        $filePath = if ($Target) { $Target } else { $script:Ch984CheckpointRelative.Replace('/', [string][char]92) }
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: enforce-completion-helpers.ps1' } -ParameterFilter { $ChildPath -eq 'enforce-completion-helpers.ps1' }
        try {
            . $hookPath
            $script:CompletionHelpersImportFailure | Should -Be $script:Ch984HelperLeaf -Because 'E-CONSTRUCTION'
            Mock Resolve-EditedCheckpointContent { throw 'must not be called' }
            Mock Test-IsValidIssueNum { $true }
            Mock Test-IsValidFeatureFolder { $true }
            Mock Test-RouteRequiresPrGate { $false }
            Mock Get-EditReplaceAllFlag { $false }
            Mock Invoke-SingleOccurrenceEdit { throw 'must not be called' }

            # Act
            $decision = (Invoke-CompletionConsistencyDecision -ToolInputRaw (ConvertTo-Ch984Envelope -ToolName $Tool -FilePath $filePath)).hookSpecificOutput
        }
        finally { Initialize-Ch984State }

        # Assert
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason.StartsWith('COMPLETION_CONSISTENCY_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.permissionDecisionReason
        $decision.permissionDecisionReason.Contains($script:Ch984HelperLeaf) | Should -BeTrue -Because $decision.permissionDecisionReason
        Should -Invoke Resolve-EditedCheckpointContent -Times 0 -Exactly
        Should -Invoke Test-IsValidIssueNum -Times 0 -Exactly
        Should -Invoke Test-IsValidFeatureFolder -Times 0 -Exactly
        Should -Invoke Test-RouteRequiresPrGate -Times 0 -Exactly
        Should -Invoke Get-EditReplaceAllFlag -Times 0 -Exactly
        Should -Invoke Invoke-SingleOccurrenceEdit -Times 0 -Exactly
    }

    It 'CH3 denies a non-checkpoint Edit naming HookPayload.psm1 when that module fails to load (#984)' {
        # Arrange: the payload module import fails; every other import is a no-op.
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated load failure: HookPayload.psm1' } -ParameterFilter { $Name -like '*HookPayload.psm1' }
        try {
            . $hookPath

            # Act
            $decision = (Invoke-CompletionConsistencyDecision -ToolInputRaw (ConvertTo-Ch984Envelope -ToolName 'Edit' -FilePath 'src/App/App.csproj')).hookSpecificOutput
        }
        finally { Initialize-Ch984State }

        # Assert
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason.StartsWith('COMPLETION_CONSISTENCY_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.permissionDecisionReason
        $decision.permissionDecisionReason.Contains('HookPayload.psm1') | Should -BeTrue -Because $decision.permissionDecisionReason
    }

    It 'CH4 returns exit 0 and an allow for a non-checkpoint Edit through the & route when the helpers fail to load (#984)' {
        # Arrange: the payload reader returns the in-memory envelope so the row does not depend on the host console.
        $envelope = ConvertTo-Ch984Envelope -ToolName 'Edit' -FilePath 'src/App/App.csproj'
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: enforce-completion-helpers.ps1' } -ParameterFilter { $ChildPath -eq 'enforce-completion-helpers.ps1' }
        Mock Read-ClaudeHookRawPayload { $envelope }

        # Act
        try { $result = Invoke-Ch984HookProcess -Stdin $envelope }
        finally { Initialize-Ch984State }

        # Assert
        $result.ExitCode | Should -Be 0
        ($result.Stdout | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because $result.Stdout
    }

    It 'CH5 returns exit 0 and a deny naming enforce-completion-helpers.ps1 for a checkpoint Edit through the & route when the helpers fail to load (#984)' {
        # Arrange: the payload reader returns the in-memory envelope so the row does not depend on the host console.
        $envelope = ConvertTo-Ch984Envelope -ToolName 'Edit' -FilePath $script:Ch984CheckpointRelative
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: enforce-completion-helpers.ps1' } -ParameterFilter { $ChildPath -eq 'enforce-completion-helpers.ps1' }
        Mock Read-ClaudeHookRawPayload { $envelope }

        # Act
        try { $result = Invoke-Ch984HookProcess -Stdin $envelope }
        finally { Initialize-Ch984State }

        # Assert
        $result.ExitCode | Should -Be 0
        $decision = ($result.Stdout | ConvertFrom-Json).hookSpecificOutput
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason.StartsWith('COMPLETION_CONSISTENCY_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.permissionDecisionReason
        $decision.permissionDecisionReason.Contains($script:Ch984HelperLeaf) | Should -BeTrue -Because $decision.permissionDecisionReason
    }

    It 'CH6 denies an envelope anomaly and allows a payload without file_path when the helpers fail to load (#984)' {
        # Arrange
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: enforce-completion-helpers.ps1' } -ParameterFilter { $ChildPath -eq 'enforce-completion-helpers.ps1' }
        try {
            . $hookPath
            $script:CompletionHelpersImportFailure | Should -Be $script:Ch984HelperLeaf -Because 'E-CONSTRUCTION'

            # Act
            $anomaly = (Invoke-CompletionConsistencyDecision -ToolInputRaw '').hookSpecificOutput
            $noPath = (Invoke-CompletionConsistencyDecision -ToolInputRaw (ConvertTo-Ch984Envelope -ToolName 'Edit' -FilePath '')).hookSpecificOutput
        }
        finally { Initialize-Ch984State }

        # Assert
        $anomaly.permissionDecision | Should -Be 'deny'
        $anomaly.permissionDecisionReason.StartsWith('COMPLETION_CONSISTENCY_BLOCKED: payload anomaly', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $anomaly.permissionDecisionReason
        $noPath.permissionDecision | Should -Be 'allow'
    }
}
