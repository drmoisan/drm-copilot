#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Envelope rows for the validate-required-artifact-output.ps1 SubagentStop hook (issue #903, epic #904).

.DESCRIPTION
    Entry-tail rows drive the hook through the & route with the SubagentStop envelope supplied on
    stdin through [Console]::SetIn and stderr captured through [Console]::SetError; both are restored
    in finally, together with CLAUDE_HOOK_INPUT and the dependency-failure state. Pure-entry rows call
    Invoke-RequiredArtifactOutputValidation with -InputText. E-RA-10 parses the hook file as text.
    No row creates, renames, moves, or deletes a file, reads a clock, or sleeps.
#>

BeforeAll {
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-required-artifact-output.ps1'
    . $hookPath
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/subagentstop-envelope.ps1')
}

Describe 'validate-required-artifact-output.ps1 SubagentStop envelope' {
    BeforeAll {
        $script:Hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-required-artifact-output.ps1'))
        $script:Spec = 'spec-path|^docs/features/active/.+/spec\.md$|feature spec artifact'
        $script:Arguments = @{ AgentName = 'prd-feature'; RequiredArtifact = @($script:Spec) }
        $script:MissingText = 'No artifact path reported.'
        $script:PresentText = 'spec-path: docs/features/active/foo/spec.md'

        function Invoke-HookTail {
            # Runs the hook entry tail with stdin, stderr, and CLAUDE_HOOK_INPUT replaced for one call; all are restored in finally.
            param(
                [AllowEmptyString()] [string] $StdinText,
                [AllowNull()] [string] $LegacyInput,
                [hashtable] $HookParameter = @{}
            )
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $priorLegacy = $env:CLAUDE_HOOK_INPUT
            $errorWriter = [System.IO.StringWriter]::new()
            $thrown = $null
            $exitCode = $null
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($StdinText))
                [System.Console]::SetError($errorWriter)
                $env:CLAUDE_HOOK_INPUT = $LegacyInput
                $global:LASTEXITCODE = 0
                try { $null = & $script:Hook @HookParameter } catch { $thrown = $_ }
                $exitCode = $LASTEXITCODE
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
                $env:CLAUDE_HOOK_INPUT = $priorLegacy
                $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
                $script:HookDependencyGuardLoadFailed = $false
            }
            return [pscustomobject]@{ Thrown = $thrown; ExitCode = $exitCode; Stderr = $errorWriter.ToString() }
        }

        function ConvertTo-EnvelopeText {
            # Builds a compressed SubagentStop envelope with the given key and text.
            param([string] $Key = 'last_assistant_message', [AllowEmptyString()] [string] $Text)
            return ([ordered]@{ $Key = $Text } | ConvertTo-Json -Compress)
        }
    }

    It 'E-RA-1 blocks with exit 2 when the required artifact is missing' {
        # Arrange
        Mock Import-Module { }

        # Act
        $result = Invoke-HookTail -StdinText (ConvertTo-EnvelopeText -Text $script:MissingText) -HookParameter $script:Arguments

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.Contains('missing spec-path') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-RA-2 blocks with exit 2 when -AgentName is missing' {
        # Arrange
        Mock Import-Module { }

        # Act
        $result = Invoke-HookTail -StdinText '{"last_assistant_message":"x"}' -HookParameter @{ RequiredArtifact = @($script:Spec) }

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.Contains('AgentName and at least one RequiredArtifact spec are required') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-RA-3 blocks with exit 2 when -RequiredArtifact is missing' {
        # Arrange
        Mock Import-Module { }

        # Act
        $result = Invoke-HookTail -StdinText '{"last_assistant_message":"x"}' -HookParameter @{ AgentName = 'prd-feature' }

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.Contains('AgentName and at least one RequiredArtifact spec are required') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-RA-4 exits 0 when the artifact is present' {
        # Arrange
        Mock Import-Module { }
        Mock Test-ArtifactFile { $true }

        # Act
        $result = Invoke-HookTail -StdinText (ConvertTo-EnvelopeText -Text $script:PresentText) -HookParameter $script:Arguments

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -BeNullOrEmpty
    }

    It 'E-RA-5 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails' {
        # Arrange
        Mock Import-Module { }
        Mock Test-ArtifactFile { $true }

        # Act
        $result = Invoke-HookTail -StdinText (ConvertTo-EnvelopeText -Text $script:MissingText) -LegacyInput (ConvertTo-EnvelopeText -Key 'output' -Text $script:PresentText) -HookParameter $script:Arguments

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.Contains('missing spec-path') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-RA-6 blocks with exit 2 when the envelope carries only an output key' {
        # Arrange
        Mock Import-Module { }
        Mock Test-ArtifactFile { $true }
        $clause = Get-SubagentStopEnvelopeAnomalyReason -Anomaly 'MissingAssistantMessage'

        # Act
        $result = Invoke-HookTail -StdinText (ConvertTo-EnvelopeText -Key 'output' -Text $script:PresentText) -HookParameter $script:Arguments

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('prd-feature hook: payload anomaly - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
        $result.Stderr.Contains($clause) | Should -BeTrue -Because $result.Stderr
    }

    It 'E-RA-7 exits 2 naming subagentstop-envelope.ps1 when the helper fails to load, with stop_hook_active true' {
        # Arrange
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: subagentstop-envelope.ps1' } -ParameterFilter { $ChildPath -eq 'subagentstop-envelope.ps1' }

        # Act
        $result = Invoke-HookTail -StdinText '{"last_assistant_message":"x","stop_hook_active":true}' -HookParameter $script:Arguments

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('validate-required-artifact-output:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
        $result.Stderr.Contains('subagentstop-envelope.ps1') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-RA-8 exits 2 when hook-dependency-guard.ps1 fails to load' {
        # Arrange
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: hook-dependency-guard.ps1' } -ParameterFilter { $ChildPath -eq 'hook-dependency-guard.ps1' }

        # Act
        $result = Invoke-HookTail -StdinText '{"last_assistant_message":"x"}' -HookParameter $script:Arguments

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('validate-required-artifact-output: hook-dependency-guard.ps1 failed to load', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
    }

    It 'E-RA-9 blocks <Anomaly> with the required-artifact payload anomaly clause' -ForEach @(
        @{ Anomaly = 'EmptyPayload'; InputText = '' }
        @{ Anomaly = 'UnparseableJson'; InputText = '{ not json' }
        @{ Anomaly = 'NonObjectEnvelope'; InputText = '[]' }
        @{ Anomaly = 'MissingAssistantMessage'; InputText = '{"output":"Final summary."}' }
        @{ Anomaly = 'NullAssistantMessage'; InputText = '{"last_assistant_message":null}' }
        @{ Anomaly = 'NonStringAssistantMessage'; InputText = '{"last_assistant_message":42}' }
    ) {
        # Arrange
        $expected = 'prd-feature hook: payload anomaly - ' + (Get-SubagentStopEnvelopeAnomalyReason -Anomaly $Anomaly)

        # Act
        $result = Invoke-RequiredArtifactOutputValidation -InputText $InputText -AgentName 'prd-feature' -RequiredArtifact $script:Spec

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message.StartsWith($expected, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
    }

    It 'E-RA-10 calls Exit-SubagentStopBlock exactly twice, neither inside the missing-argument if block' {
        # Arrange
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:Hook, [ref]$null, [ref]$null)

        # Act
        $calls = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'Exit-SubagentStopBlock' }, $true))
        $insideArgumentBlock = $false
        foreach ($call in $calls) {
            $parent = $call.Parent
            while ($null -ne $parent) {
                if ($parent -is [System.Management.Automation.Language.IfStatementAst] -and $parent.Clauses[0].Item1.Extent.Text.Contains('IsNullOrWhiteSpace($AgentName)')) { $insideArgumentBlock = $true }
                $parent = $parent.Parent
            }
        }

        # Assert
        $calls.Count | Should -Be 2 -Because 'the unhandled-error catch and the final validation-failure exit are the only Exit-SubagentStopBlock calls (issue #928)'
        $insideArgumentBlock | Should -BeFalse -Because 'the missing-argument path exits inline'
    }
}
