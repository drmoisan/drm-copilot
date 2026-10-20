#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Validation-module import-failure proofs for enforce-discovery-artifact-gate.ps1 (issue #984).

.DESCRIPTION
    The gate validates only Write calls of recognized discovery artifact types. When its
    evaluation-only module DiscoveryValidation.psm1 fails to load, a Write outside those types and
    any Edit are allowed, and a Write of a discovery artifact is still denied naming the module
    (handler H10). A HookPayload.psm1 load failure still denies. Each row runs against the
    repository copy and the bundle mirror.

    The module failure is an Import-Module mock filtered on its leaf over a no-op Import-Module
    mock. The in-process failure rows other than DV4 re-dot-source the hook inside the It, assert
    the handler variable names the leaf (-Because 'E-CONSTRUCTION'), and reset that variable and
    the dependency-failure state in finally. DV5 drives the hook through the & route with stdin and
    stderr redirected and restored. No test creates, renames, moves, or deletes a file.
#>

BeforeDiscovery {
    $script:RootRows = @(
        @{ Root = 'repository'; HookRelative = '.claude/hooks/enforce-discovery-artifact-gate.ps1' }
        @{ Root = 'mirror'; HookRelative = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1' }
    )
}

Describe 'enforce-discovery-artifact-gate.ps1 validation module import failure on the <Root> root (#984)' -ForEach $script:RootRows {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $hookPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $HookRelative))
        . $hookPath
        $script:Dv984ModuleLeaf = 'DiscoveryValidation.psm1'
        $script:Dv984PresentDeclaration = { @{ Present = $true; Declaration = @{ required = @('profile') } } }

        function Initialize-Dv984State {
            # Clears the handler variable and the shared dependency-failure state after a re-dot-source.
            $script:DiscoveryValidationImportFailure = $null
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            $script:HookDependencyGuardLoadFailed = $false
        }

        function ConvertTo-Dv984Envelope {
            # Builds an in-memory PreToolUse envelope; a Write carries content, an Edit carries a patch.
            param([string] $ToolName, [string] $FilePath)
            $toolInput = [ordered]@{ file_path = $FilePath }
            if ($ToolName -eq 'Write') { $toolInput['content'] = '{"schema_version":"1"}' }
            else { $toolInput['old_string'] = 'a'; $toolInput['new_string'] = 'b' }
            return (@{ session_id = 'dv-984'; hook_event_name = 'PreToolUse'; tool_name = $ToolName; tool_input = $toolInput } | ConvertTo-Json -Compress -Depth 5)
        }

        function Invoke-Dv984HookProcess {
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

        Initialize-Dv984State
    }

    AfterAll {
        . $hookPath
        Initialize-Dv984State
    }

    It 'DV0 allows a Write outside the discovery artifact types when DiscoveryValidation.psm1 loads (#984)' {
        $script:DiscoveryValidationImportFailure | Should -BeNullOrEmpty -Because 'E-CONSTRUCTION'

        $decision = (Invoke-DiscoveryArtifactGateDecision -ToolInputRaw (ConvertTo-Dv984Envelope -ToolName 'Write' -FilePath 'README.md')).hookSpecificOutput

        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'DV1 allows a Write of <Path> outside the discovery artifact types when DiscoveryValidation.psm1 fails to load (#984)' -ForEach @(
        @{ Path = 'README.md' }
        @{ Path = 'src/app.ts' }
    ) {
        # Arrange: re-dot-source the hook with the validation module import forced to fail.
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated load failure: DiscoveryValidation.psm1' } -ParameterFilter { $Name -like '*DiscoveryValidation.psm1' }
        try {
            . $hookPath
            $script:DiscoveryValidationImportFailure | Should -Be $script:Dv984ModuleLeaf -Because 'E-CONSTRUCTION'

            # Act
            $decision = (Invoke-DiscoveryArtifactGateDecision -ToolInputRaw (ConvertTo-Dv984Envelope -ToolName 'Write' -FilePath $Path)).hookSpecificOutput
        }
        finally { Initialize-Dv984State }

        # Assert
        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'DV2 allows an Edit of a discovery artifact path when DiscoveryValidation.psm1 fails to load (#984)' {
        # Arrange
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated load failure: DiscoveryValidation.psm1' } -ParameterFilter { $Name -like '*DiscoveryValidation.psm1' }
        try {
            . $hookPath
            $script:DiscoveryValidationImportFailure | Should -Be $script:Dv984ModuleLeaf -Because 'E-CONSTRUCTION'

            # Act
            $decision = (Invoke-DiscoveryArtifactGateDecision -ToolInputRaw (ConvertTo-Dv984Envelope -ToolName 'Edit' -FilePath 'discovery/profile/domain-profile.json')).hookSpecificOutput
        }
        finally { Initialize-Dv984State }

        # Assert
        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'DV3 denies a Write of a discovery profile artifact naming DiscoveryValidation.psm1 when that module fails to load (#984)' {
        # Arrange: a required-artifact declaration is present, so only the handler stands between the Write and the validator.
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated load failure: DiscoveryValidation.psm1' } -ParameterFilter { $Name -like '*DiscoveryValidation.psm1' }
        try {
            . $hookPath
            $script:DiscoveryValidationImportFailure | Should -Be $script:Dv984ModuleLeaf -Because 'E-CONSTRUCTION'
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            # Act
            $decision = (Invoke-DiscoveryArtifactGateDecision -ToolInputRaw (ConvertTo-Dv984Envelope -ToolName 'Write' -FilePath 'discovery/profile/domain-profile.json') -RequiredArtifactReader $script:Dv984PresentDeclaration).hookSpecificOutput
        }
        finally { Initialize-Dv984State }

        # Assert
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason.StartsWith('DISCOVERY_ARTIFACT_GATE_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.permissionDecisionReason
        $decision.permissionDecisionReason.Contains($script:Dv984ModuleLeaf) | Should -BeTrue -Because $decision.permissionDecisionReason
        Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
    }

    It 'DV4 denies a Write through Invoke-DiscoveryArtifactGateDecision naming HookPayload.psm1 when that module fails to load (#984)' {
        # Arrange: the payload module import fails; every other import is a no-op.
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated load failure: HookPayload.psm1' } -ParameterFilter { $Name -like '*HookPayload.psm1' }
        try {
            . $hookPath

            # Act
            $decision = (Invoke-DiscoveryArtifactGateDecision -ToolInputRaw (ConvertTo-Dv984Envelope -ToolName 'Write' -FilePath 'README.md')).hookSpecificOutput
        }
        finally { Initialize-Dv984State }

        # Assert
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason.StartsWith('DISCOVERY_ARTIFACT_GATE_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.permissionDecisionReason
        $decision.permissionDecisionReason.Contains('HookPayload.psm1') | Should -BeTrue -Because $decision.permissionDecisionReason
    }

    It 'DV5 returns exit 0 and an allow for a Write of README.md through the & route when DiscoveryValidation.psm1 fails to load (#984)' {
        # Arrange: the payload reader returns the in-memory envelope so the row does not depend on the host console.
        $envelope = ConvertTo-Dv984Envelope -ToolName 'Write' -FilePath 'README.md'
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated load failure: DiscoveryValidation.psm1' } -ParameterFilter { $Name -like '*DiscoveryValidation.psm1' }
        Mock Read-ClaudeHookRawPayload { $envelope }

        # Act
        try { $result = Invoke-Dv984HookProcess -Stdin $envelope }
        finally { Initialize-Dv984State }

        # Assert
        $result.ExitCode | Should -Be 0
        ($result.Stdout | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because $result.Stdout
    }
}
