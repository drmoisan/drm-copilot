#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Process entry points and dependency-failure paths of the three Claude Code discovery adapters (issue #980).
.DESCRIPTION
    Each adapter is driven through the & route with stdin, stdout and stderr redirected and restored in
    finally, so the script-level tail (dependency decision, payload read, decision write, exit code)
    executes exactly as the harness runs it. The protected store and the trusted host environment are
    mocked to the in-memory fixtures, so no file is written and no process, network or clock is touched.
#>

Describe 'Claude Code discovery adapter entry points' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:Hooks = @{
            Start    = Join-Path $script:RepoRoot '.claude/hooks/record-discovery-agent-start.ps1'
            Planning = Join-Path $script:RepoRoot '.claude/hooks/enforce-discovery-planning-gate.ps1'
            Probe    = Join-Path $script:RepoRoot '.claude/hooks/discovery-capability-probe.ps1'
        }
        # The start adapter imports the shared helper modules the support files resolve against.
        . $script:Hooks.Start
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryStart.TestSupport.ps1')

        function Invoke-ScriptEntry {
            # Runs a hook script through the & route with the console streams redirected.
            param(
                [Parameter(Mandatory = $true)][string]$Path,
                [Parameter(Mandatory = $false)][AllowEmptyString()][string]$Stdin = '',
                [Parameter(Mandatory = $false)][hashtable]$Arguments = @{}
            )
            $priorIn = [System.Console]::In
            $priorOut = [System.Console]::Out
            $priorError = [System.Console]::Error
            $outWriter = [System.IO.StringWriter]::new()
            $errorWriter = [System.IO.StringWriter]::new()
            $thrown = $null
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($Stdin))
                [System.Console]::SetOut($outWriter)
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                $pipeline = @()
                try { $pipeline = @(& $Path @Arguments) } catch { $thrown = $_ }
                $exitCode = $LASTEXITCODE
            } finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetOut($priorOut)
                [System.Console]::SetError($priorError)
            }
            $pipelineText = (@($pipeline | ForEach-Object { [string]$_ }) -join "`n")
            return [pscustomobject]@{ ExitCode = $exitCode; Stdout = ($outWriter.ToString() + $pipelineText); Stderr = $errorWriter.ToString(); Thrown = $thrown }
        }
    }

    Context 'start attestation adapter' {
        BeforeAll { . $script:Hooks.Start }

        It 'exits 2 with the start prefix for an unreadable payload through the script tail' {
            $result = Invoke-ScriptEntry -Path $script:Hooks.Start -Stdin '{'
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -BeLike 'DISCOVERY_START_ATTESTATION_BLOCKED:*'
        }

        It 'denies naming the dependency when a helper failed to load' {
            Add-HookDependencyFailure -Name 'DiscoveryStartRecord.psm1'
            try {
                $outcome = Invoke-DiscoveryAgentStartDecision -PayloadRaw (Get-StartEnvelope)
                $outcome.Decision | Should -Be 'deny'
                $outcome.Code | Should -Be 'DEPENDENCY'
                $outcome.Reason | Should -BeLike '*DiscoveryStartRecord.psm1*'
                $outcome.Reason | Should -Not -BeLike 'DISCOVERY_START_ATTESTATION_BLOCKED:*'
            } finally {
                $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            }
        }

        It 'reports the all-zero digest for an absent handler path' {
            Get-DiscoveryStartHandlerSha256 -HandlerPath '' | Should -Be ('0' * 64)
            Get-DiscoveryStartHandlerSha256 -HandlerPath 'C:/Users/Example/missing-handler.ps1' | Should -Be ('0' * 64)
        }
    }

    Context 'artifact gate adapter helpers' {
        BeforeAll { . (Join-Path $script:RepoRoot '.claude/hooks/enforce-discovery-artifact-gate.ps1') }

        It 'reports the all-zero digest for an absent handler path' {
            Get-DiscoveryGateHandlerSha256 -HandlerPath '' | Should -Be ('0' * 64)
            Get-DiscoveryGateHandlerSha256 -HandlerPath 'C:/Users/Example/missing-handler.ps1' | Should -Be ('0' * 64)
        }
    }

    Context 'planning gate adapter' {
        BeforeAll { . $script:Hooks.Planning }

        It 'writes a deny decision at exit 0 for an unreadable payload through the script tail' {
            $gateHostEnvironment = $script:GateHostEnvironment
            $planningStore = Get-GateStore
            Mock Get-DiscoveryTrustedHostEnvironment { $gateHostEnvironment }.GetNewClosure()
            Mock Get-DiscoveryStartStore { $planningStore }.GetNewClosure()
            $result = Invoke-ScriptEntry -Path $script:Hooks.Planning -Stdin '{'
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 0
            ($result.Stdout | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'capability probe' {
        BeforeAll { . $script:Hooks.Probe }

        It 'runs the observation through the script tail against the in-memory store and exits with the verdict' {
            $gateHostEnvironment = $script:GateHostEnvironment
            $probeStore = Get-GateStore
            Mock Get-DiscoveryTrustedHostEnvironment { $gateHostEnvironment }.GetNewClosure()
            Mock Get-DiscoveryDefaultStore { $probeStore }.GetNewClosure()
            $result = Invoke-ScriptEntry -Path $script:Hooks.Probe -Arguments @{ WorkspaceRoot = $script:GateWorkspaceRoot; SessionId = 'session-alpha'; Nonce = $script:GateNonce }
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 1
            ($result.Stdout | ConvertFrom-Json).status | Should -Be 'unsupported'
        }

        It 'defaults the workspace root to the repository that hosts the probe' {
            # The default root is the real checkout, so the host environment must model the running platform.
            $gateHostEnvironment = $script:GateRunningHostEnvironment
            $probeStore = Get-GateStore
            Mock Get-DiscoveryTrustedHostEnvironment { $gateHostEnvironment }.GetNewClosure()
            Mock Get-DiscoveryDefaultStore { $probeStore }.GetNewClosure()
            $result = Invoke-ScriptEntry -Path $script:Hooks.Probe -Arguments @{ SessionId = 'session-alpha'; Nonce = $script:GateNonce }
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -BeIn @(0, 1)
            $document = $result.Stdout | ConvertFrom-Json
            $document.status | Should -BeIn @('supported', 'unsupported')
            ([string]$document.workspace.workspace_root -replace '\\', '/') | Should -Be ($script:RepoRoot -replace '\\', '/')
        }
    }
}
