#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Helper-module import-failure proofs for enforce-discovery-artifact-gate.ps1 (issue #980).

.DESCRIPTION
    The native authorization adapter guards every helper import (HookPayload.psm1 and the five
    discovery-validation modules) through the shared dependency guard, so a load failure denies
    every request with DISCOVERY_ARTIFACT_GATE_BLOCKED: naming the dependency, before the payload
    is read. Each row runs against the repository copy and the bundle mirror.

    The module failure is an Import-Module mock filtered on its leaf over a no-op Import-Module
    mock. The in-process rows re-dot-source the hook inside the It and reset the dependency-failure
    state in finally. HF5 drives the hook through the & route with stdin and stderr redirected and
    restored. No test creates, renames, moves, or deletes a file.
#>

BeforeDiscovery {
    $script:RootRows = @(
        @{ Root = 'repository'; HookRelative = '.claude/hooks/enforce-discovery-artifact-gate.ps1' }
        @{ Root = 'mirror'; HookRelative = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1' }
    )
    $script:LeafRows = @(
        @{ Leaf = 'HookPayload.psm1' }
        @{ Leaf = 'DiscoveryEncoding.psm1' }
        @{ Leaf = 'DiscoveryAuthority.psm1' }
        @{ Leaf = 'DiscoveryPayload.psm1' }
        @{ Leaf = 'DiscoveryToolRouting.psm1' }
        @{ Leaf = 'DiscoveryAuthorization.psm1' }
    )
}

Describe 'enforce-discovery-artifact-gate.ps1 helper import failure on the <Root> root (#980)' -ForEach $script:RootRows {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $hookPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $HookRelative))
        . $hookPath
        $script:Hf980Envelope = '{"session_id":"hf-980","hook_event_name":"PreToolUse","tool_name":"Write","tool_input":{"file_path":"README.md","content":"x"}}'

        function Initialize-Hf980State {
            # Clears the shared dependency-failure state after a re-dot-source.
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            $script:HookDependencyGuardLoadFailed = $false
        }

        function Invoke-Hf980HookProcess {
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

        Initialize-Hf980State
    }

    AfterAll {
        . $hookPath
        Initialize-Hf980State
    }

    It 'HF0 records no dependency failure when every helper loads (#980)' {
        Test-HookDependencyFailure | Should -BeFalse -Because 'E-CONSTRUCTION'
    }

    It 'HF1 denies a Write naming <Leaf> when that helper fails to load (#980)' -ForEach $script:LeafRows {
        # Arrange: re-dot-source the hook with one helper import forced to fail.
        Mock Import-Module { }
        $failedLeaf = $Leaf
        Mock Import-Module { throw "simulated load failure: $failedLeaf" } -ParameterFilter { $Name -like "*$failedLeaf" }
        Mock Read-ClaudeHookRawPayload { $script:Hf980Envelope }
        try {
            . $hookPath
            Test-HookDependencyFailure | Should -BeTrue -Because 'E-CONSTRUCTION'

            # Act
            $decision = (Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $script:Hf980Envelope).hookSpecificOutput
        }
        finally { Initialize-Hf980State }

        # Assert
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason.StartsWith('DISCOVERY_ARTIFACT_GATE_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.permissionDecisionReason
        $decision.permissionDecisionReason.Contains($Leaf) | Should -BeTrue -Because $decision.permissionDecisionReason
        Should -Invoke Read-ClaudeHookRawPayload -Times 0 -Exactly
    }

    It 'HF5 returns exit 0 and a deny naming DiscoveryAuthorization.psm1 through the & route when that helper fails to load (#980)' {
        # Arrange
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated load failure: DiscoveryAuthorization.psm1' } -ParameterFilter { $Name -like '*DiscoveryAuthorization.psm1' }

        # Act
        try { $result = Invoke-Hf980HookProcess -Stdin $script:Hf980Envelope }
        finally { Initialize-Hf980State }

        # Assert
        $result.ExitCode | Should -Be 0
        $decision = ($result.Stdout | ConvertFrom-Json).hookSpecificOutput
        $decision.permissionDecision | Should -Be 'deny' -Because $result.Stdout
        $decision.permissionDecisionReason.Contains('DiscoveryAuthorization.psm1') | Should -BeTrue -Because $result.Stdout
    }
}
