#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Unit tests for the documentation-role SubagentStop hook (.claude/hooks/validate-docs-role-output.ps1, issue #1037).

.DESCRIPTION
    Pure rows call Invoke-DocsRoleOutputValidation with -InputText. Script-route rows run the hook in
    process through the & route with the envelope supplied through [Console]::SetIn and stderr captured
    through [Console]::SetError; both are restored in finally, together with the dependency-failure
    state. No row starts a process, resolves an executable on PATH, waits on a timer, or creates a file.
    Test-DocsRoleOutputFile is mocked wherever a reported path must exist.
#>

BeforeDiscovery {
    # Literal role-by-token table (24 rows): the three common tokens for each role plus that role's own tokens.
    $script:TokenRows = @(
        foreach ($role in 'docs-architect', 'docs-author', 'docs-reconciler', 'docs-coverage-reviewer') {
            foreach ($token in 'docs-role', 'docs-result', 'docs-findings') { @{ Role = $role; Token = $token } }
        }
        @{ Role = 'docs-architect'; Token = 'docs-profile' }
        @{ Role = 'docs-architect'; Token = 'docs-snapshot' }
        @{ Role = 'docs-architect'; Token = 'docs-pages-planned' }
        @{ Role = 'docs-author'; Token = 'docs-pages-written' }
        @{ Role = 'docs-author'; Token = 'docs-check-exit-code' }
        @{ Role = 'docs-reconciler'; Token = 'docs-ledger-operations' }
        @{ Role = 'docs-reconciler'; Token = 'docs-update-ledger-exit-code' }
        @{ Role = 'docs-reconciler'; Token = 'docs-elements-reconciled' }
        @{ Role = 'docs-coverage-reviewer'; Token = 'docs-validate-mode' }
        @{ Role = 'docs-coverage-reviewer'; Token = 'docs-revision' }
        @{ Role = 'docs-coverage-reviewer'; Token = 'docs-validate-exit-code' }
        @{ Role = 'docs-coverage-reviewer'; Token = 'docs-receipt-id' }
    )
    $script:RoleRows = @(
        foreach ($role in 'docs-architect', 'docs-author', 'docs-reconciler', 'docs-coverage-reviewer') {
            @{ Role = $role; TableTokens = @($script:TokenRows | Where-Object { $_.Role -eq $role } | ForEach-Object { $_.Token }) }
        }
    )
}

BeforeAll {
    $script:Hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-docs-role-output.ps1'))
    . $script:Hook
    # Issue #1163: the hook dot-sources subagentstop-target-worktree.ps1, which brings
    # WorktreeItemResolution.psm1 into its closure, so its read seams carry baseline mocks.
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' -Surface 'Claude'
    $script:AddedFunctions = @(
        'Add-HookDependencyFailure', 'Test-HookDependencyFailure', 'Get-HookDependencyFailureReason', 'Get-HookDependencyFailureDecision',
        'Get-SubagentStopEnvelopeAnomalyReason', 'Read-SubagentStopEnvelope', 'Exit-SubagentStopBlock',
        'Get-DocsRoleName', 'Get-DocsRoleRequiredToken', 'ConvertFrom-DocsRoleOutput', 'Test-DocsRoleRelativePath',
        'Get-DocsRoleIntegerFinding', 'Get-DocsRolePathFinding', 'Get-DocsRoleSpecificFinding', 'Test-DocsRoleOutput',
        'Test-DocsRoleOutputFile', 'Invoke-DocsRoleOutputValidation', 'ConvertTo-DocsRoleEnvelope', 'Get-DocsRoleOutputWithoutToken', 'Invoke-DocsRoleHookTail'
    )
    $script:ValidOutput = @{
        'docs-architect'         = "docs-role: docs-architect`ndocs-result: PASS`ndocs-findings: 0`ndocs-profile: docs/documentation-estate/docs-profile.json`ndocs-snapshot: docs/documentation-estate/inventory.json`ndocs-pages-planned: 3`n`n## Information Architecture`n`n- docs/guide/index.md"
        'docs-author'            = "docs-role: docs-author`ndocs-result: PASS`ndocs-findings: 0`ndocs-pages-written: docs/guide/index.md`ndocs-check-exit-code: 0"
        'docs-reconciler'        = "docs-role: docs-reconciler`ndocs-result: PASS`ndocs-findings: 1`ndocs-ledger-operations: 1`ndocs-update-ledger-exit-code: 0`ndocs-elements-reconciled: none"
        'docs-coverage-reviewer' = "docs-role: docs-coverage-reviewer`ndocs-result: PASS`ndocs-findings: 0`ndocs-validate-mode: docs-complete`ndocs-revision: $('c' * 40)`ndocs-validate-exit-code: 0`ndocs-receipt-id: none"
    }

    function ConvertTo-DocsRoleEnvelope {
        # Builds a compressed SubagentStop envelope for one agent type and message.
        param([AllowEmptyString()] [string] $AgentType, [AllowEmptyString()] [string] $Text, [switch] $StopHookActive)
        $envelope = [ordered]@{ hook_event_name = 'SubagentStop'; last_assistant_message = $Text; stop_hook_active = [bool]$StopHookActive }
        if ($AgentType) { $envelope['agent_type'] = $AgentType }
        return ($envelope | ConvertTo-Json -Compress)
    }

    function Get-DocsRoleOutputWithoutToken {
        # Returns the valid output of a role without the line that carries the given token.
        param([string] $Role, [string] $Token)
        return ((@($script:ValidOutput[$Role] -split "`n") | Where-Object { -not $_.StartsWith("${Token}:") }) -join "`n")
    }

    function Invoke-DocsRoleHookTail {
        # Runs the hook entry tail with stdin and stderr replaced for one call; both are restored in finally.
        param([AllowEmptyString()] [string] $StdinText)
        $priorIn = [System.Console]::In
        $priorError = [System.Console]::Error
        $errorWriter = [System.IO.StringWriter]::new()
        $thrown = $null
        $exitCode = $null
        try {
            [System.Console]::SetIn([System.IO.StringReader]::new($StdinText))
            [System.Console]::SetError($errorWriter)
            $global:LASTEXITCODE = 0
            try { $null = & $script:Hook } catch { $thrown = $_ }
            $exitCode = $LASTEXITCODE
        }
        finally {
            [System.Console]::SetIn($priorIn)
            [System.Console]::SetError($priorError)
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            $script:HookDependencyGuardLoadFailed = $false
            $global:LASTEXITCODE = 0
        }
        return [pscustomobject]@{ Thrown = $thrown; ExitCode = $exitCode; Stderr = $errorWriter.ToString() }
    }
}

AfterAll {
    foreach ($name in $script:AddedFunctions) { Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue }
    foreach ($name in 'HookDependencyFailures', 'HookDependencyGuardLoadFailed', 'DocsRoleOutputReportAndHaltLine', 'Hook', 'AddedFunctions', 'ValidOutput') { Remove-Variable -Name $name -Scope Script -ErrorAction SilentlyContinue }
}

Describe 'epic-state baseline isolation (issue #1163)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }
}

Describe 'Invoke-DocsRoleOutputValidation' {
    It 'allows a complete valid output from <Role>' -ForEach $script:RoleRows {
        # Arrange
        Mock Test-DocsRoleOutputFile { $true }

        # Act
        $result = Invoke-DocsRoleOutputValidation -InputText (ConvertTo-DocsRoleEnvelope -AgentType $Role -Text $script:ValidOutput[$Role])

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
    }

    It 'blocks one invalid value from <Role> with the prefix and the token name' -ForEach $script:RoleRows {
        # Arrange
        Mock Test-DocsRoleOutputFile { $true }
        $text = $script:ValidOutput[$Role].Replace('docs-findings: ', 'docs-findings: x')

        # Act
        $result = Invoke-DocsRoleOutputValidation -InputText (ConvertTo-DocsRoleEnvelope -AgentType $Role -Text $text)

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message.StartsWith('DOCS_ROLE_OUTPUT_BLOCKED: ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
        $result.Message.Contains('docs-findings must be a non-negative integer') | Should -BeTrue -Because $result.Message
    }

    It 'allows a non-docs agent type without checking its output' {
        # Act
        $result = Invoke-DocsRoleOutputValidation -InputText (ConvertTo-DocsRoleEnvelope -AgentType 'atomic-executor' -Text 'done')

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'allows a valid envelope that carries no agent type' {
        # Act
        $result = Invoke-DocsRoleOutputValidation -InputText (ConvertTo-DocsRoleEnvelope -AgentType '' -Text 'done')

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'allows a non-docs agent type even when its envelope is anomalous' {
        # Act
        $result = Invoke-DocsRoleOutputValidation -InputText '{"agent_type":"atomic-executor","last_assistant_message":null}'

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'blocks the <Anomaly> anomaly as not repairable' -ForEach @(
        @{ Anomaly = 'EmptyPayload'; InputText = '' }
        @{ Anomaly = 'UnparseableJson'; InputText = '{ not json' }
        @{ Anomaly = 'NonObjectEnvelope'; InputText = '[]' }
        @{ Anomaly = 'MissingAssistantMessage'; InputText = '{"agent_type":"docs-author"}' }
        @{ Anomaly = 'NullAssistantMessage'; InputText = '{"agent_type":"docs-author","last_assistant_message":null}' }
        @{ Anomaly = 'NonStringAssistantMessage'; InputText = '{"agent_type":"docs-author","last_assistant_message":42}' }
    ) {
        # Arrange
        $expected = 'DOCS_ROLE_OUTPUT_BLOCKED: payload anomaly - ' + (Get-SubagentStopEnvelopeAnomalyReason -Anomaly $Anomaly)

        # Act
        $result = Invoke-DocsRoleOutputValidation -InputText $InputText

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message.StartsWith($expected, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
        $result.Message.Contains('Report it to the operator and halt.') | Should -BeTrue -Because $result.Message
    }

    It 'allows the <Anomaly> anomaly when stop_hook_active is set' -ForEach @(
        @{ Anomaly = 'MissingAssistantMessage'; InputText = '{"agent_type":"docs-author","stop_hook_active":true}' }
        @{ Anomaly = 'NullAssistantMessage'; InputText = '{"agent_type":"docs-author","last_assistant_message":null,"stop_hook_active":true}' }
        @{ Anomaly = 'NonStringAssistantMessage'; InputText = '{"agent_type":"docs-author","last_assistant_message":42,"stop_hook_active":true}' }
    ) {
        # Act
        $result = Invoke-DocsRoleOutputValidation -InputText $InputText

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'still blocks a missing token when stop_hook_active is set' {
        # Arrange
        Mock Test-DocsRoleOutputFile { $true }
        $text = Get-DocsRoleOutputWithoutToken -Role 'docs-author' -Token 'docs-check-exit-code'

        # Act
        $result = Invoke-DocsRoleOutputValidation -InputText (ConvertTo-DocsRoleEnvelope -AgentType 'docs-author' -Text $text -StopHookActive)

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message.Contains('missing docs-check-exit-code') | Should -BeTrue -Because $result.Message
        $result.Message.Contains('Report it to the operator and halt.') | Should -BeFalse
    }

    It 'blocks a page that the file seam reports as absent' {
        # Arrange
        Mock Test-DocsRoleOutputFile { $false }

        # Act
        $result = Invoke-DocsRoleOutputValidation -InputText (ConvertTo-DocsRoleEnvelope -AgentType 'docs-author' -Text $script:ValidOutput['docs-author'])

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message.Contains("docs-pages-written path 'docs/guide/index.md' does not exist") | Should -BeTrue -Because $result.Message
        Should -Invoke Test-DocsRoleOutputFile -Times 1 -Exactly -ParameterFilter { $Path -eq 'docs/guide/index.md' }
    }

    It 'allows a first-run architect PASS whose relative snapshot path does not exist yet and probes only the profile (issue #1173)' {
        # Arrange
        Mock Test-DocsRoleOutputFile { param([string] $Path) $Path -ne 'docs/documentation-estate/inventory.json' }

        # Act
        $result = Invoke-DocsRoleOutputValidation -InputText (ConvertTo-DocsRoleEnvelope -AgentType 'docs-architect' -Text $script:ValidOutput['docs-architect'])

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
        Should -Invoke Test-DocsRoleOutputFile -Times 1 -Exactly -ParameterFilter { $Path -eq 'docs/documentation-estate/docs-profile.json' }
        Should -Invoke Test-DocsRoleOutputFile -Times 0 -Exactly -ParameterFilter { $Path -eq 'docs/documentation-estate/inventory.json' }
    }

    It 'returns the dependency decision when a dependency failure is recorded' {
        # Arrange
        Add-HookDependencyFailure -Name 'docs-role-contract.ps1'

        # Act
        try { $result = Invoke-DocsRoleOutputValidation -InputText (ConvertTo-DocsRoleEnvelope -AgentType 'docs-author' -Text 'x') }
        finally { $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new() }

        # Assert
        $result.ExitCode | Should -Be 2
        $result.Reason.StartsWith('DOCS_ROLE_OUTPUT_BLOCKED: ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
        $result.Reason.Contains('docs-role-contract.ps1') | Should -BeTrue -Because $result.Reason
    }

    It 'reports a real file through the default file seam' {
        # Act / Assert
        Test-DocsRoleOutputFile -Path $script:Hook | Should -BeTrue
        Test-DocsRoleOutputFile -Path (Split-Path -Parent $script:Hook) | Should -BeFalse
    }
}

Describe 'validate-docs-role-output.ps1 entry tail' {
    It 'exits 0 for a complete valid output from <Role>' -ForEach $script:RoleRows {
        # Arrange
        Mock Test-DocsRoleOutputFile { $true }

        # Act
        $result = Invoke-DocsRoleHookTail -StdinText (ConvertTo-DocsRoleEnvelope -AgentType $Role -Text $script:ValidOutput[$Role])

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -BeNullOrEmpty
    }

    It 'blocks with exit 2 naming the removed token <Token> for <Role>' -ForEach $script:TokenRows {
        # Arrange
        Mock Test-DocsRoleOutputFile { $true }

        # Act
        $result = Invoke-DocsRoleHookTail -StdinText (ConvertTo-DocsRoleEnvelope -AgentType $Role -Text (Get-DocsRoleOutputWithoutToken -Role $Role -Token $Token))

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('DOCS_ROLE_OUTPUT_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
        $result.Stderr.Contains($Token) | Should -BeTrue -Because $result.Stderr
    }

    It 'keeps the token table for <Role> equal to Get-DocsRoleRequiredToken' -ForEach $script:RoleRows {
        # Act
        $contract = @(Get-DocsRoleRequiredToken -Role $Role)

        # Assert
        $TableTokens | Should -Be $contract
    }

    It 'blocks with exit 2 and the prefix when Read-SubagentStopEnvelope throws' {
        # Arrange
        Mock Read-SubagentStopEnvelope { throw 'simulated envelope failure' }

        # Act
        $result = Invoke-DocsRoleHookTail -StdinText (ConvertTo-DocsRoleEnvelope -AgentType 'docs-author' -Text 'x')

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('DOCS_ROLE_OUTPUT_BLOCKED: validator error: simulated envelope failure', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
    }

    It 'exits 0 for a non-docs agent type' {
        # Act
        $result = Invoke-DocsRoleHookTail -StdinText (ConvertTo-DocsRoleEnvelope -AgentType 'task-researcher' -Text 'research-path: none')

        # Assert
        $result.ExitCode | Should -Be 0
    }

    It 'exits 2 naming docs-role-contract.ps1 when that dependency fails to load' {
        # Arrange
        $originalJoinPath = Get-Command Join-Path -CommandType Cmdlet
        Mock Join-Path {
            # Only the selected dependency fails; other path joins retain native semantics.
            if ($ChildPath -eq 'docs-role-contract.ps1') { throw 'simulated load failure: docs-role-contract.ps1'; return }
            & $originalJoinPath @PesterBoundParameters
        }

        # Act
        $result = Invoke-DocsRoleHookTail -StdinText (ConvertTo-DocsRoleEnvelope -AgentType 'docs-author' -Text 'x' -StopHookActive)

        # Assert
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('DOCS_ROLE_OUTPUT_BLOCKED: ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
        $result.Stderr.Contains('docs-role-contract.ps1') | Should -BeTrue -Because $result.Stderr
    }

    It 'exits 2 when hook-dependency-guard.ps1 fails to load' {
        # Arrange
        $originalJoinPath = Get-Command Join-Path -CommandType Cmdlet
        Mock Join-Path {
            # Only the selected dependency fails; other path joins retain native semantics.
            if ($ChildPath -eq 'hook-dependency-guard.ps1') { throw 'simulated load failure: hook-dependency-guard.ps1'; return }
            & $originalJoinPath @PesterBoundParameters
        }

        # Act
        $result = Invoke-DocsRoleHookTail -StdinText (ConvertTo-DocsRoleEnvelope -AgentType 'docs-author' -Text 'x')

        # Assert
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('DOCS_ROLE_OUTPUT_BLOCKED: hook-dependency-guard.ps1 failed to load', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
    }
}
