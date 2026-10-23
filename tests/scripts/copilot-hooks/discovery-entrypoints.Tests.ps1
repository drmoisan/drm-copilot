#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Process entry points and dependency-failure paths of the five GitHub Copilot discovery adapters (issue #980).
.DESCRIPTION
    Each adapter is driven through the & route with stdin, stdout and stderr redirected and restored in
    finally, so the script-level tail (payload read, decision write, exit code) executes exactly as the
    harness runs it. Dependency failures are recorded through the adapters' own Add-*DependencyFailure
    functions and cleared afterwards. The protected store and the trusted host environment are mocked
    to the in-memory fixtures, so no file is written and no process, network or clock is touched.
#>

Describe 'Copilot discovery adapter entry points' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:Hooks = @{
            Start    = Join-Path $script:RepoRoot '.github/hooks/discovery-agent-start.ps1'
            Stop     = Join-Path $script:RepoRoot '.github/hooks/discovery-agent-stop.ps1'
            Planning = Join-Path $script:RepoRoot '.github/hooks/discovery-planning.ps1'
            PreTool  = Join-Path $script:RepoRoot '.github/hooks/discovery-pre-tool.ps1'
            Probe    = Join-Path $script:RepoRoot '.github/hooks/discovery-capability-probe.ps1'
        }
        # The pre-tool adapter imports the shared helper modules the support file resolves against.
        . $script:Hooks.PreTool
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')

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

        function Get-ErrorRecordSample {
            try { throw 'simulated import failure' } catch { return $_ }
        }
    }

    Context 'start adapter' {
        BeforeAll { . $script:Hooks.Start }

        It 'exits 2 with the start prefix for an unreadable payload through the script tail' {
            $result = Invoke-ScriptEntry -Path $script:Hooks.Start -Stdin '{'
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -BeLike 'DISCOVERY_START_ATTESTATION_BLOCKED:*'
        }

        It 'records a dependency failure with and without an error record and denies naming it' {
            Add-DiscoveryStartDependencyFailure -Name 'DiscoveryAuthority.psm1'
            Add-DiscoveryStartDependencyFailure -Name 'DiscoveryStart.psm1' -ErrorRecord (Get-ErrorRecordSample)
            try {
                $script:DiscoveryStartDependencyFailures.Count | Should -Be 2
                $script:DiscoveryStartDependencyFailures[0].Message | Should -Be 'no error record'
                $script:DiscoveryStartDependencyFailures[1].Message | Should -Be 'simulated import failure'
                $outcome = Invoke-DiscoveryAgentStartDecision -PayloadRaw '{}'
                $outcome.Decision | Should -Be 'deny'
                $outcome.Code | Should -Be 'DEPENDENCY'
                $outcome.Reason | Should -BeLike "*DiscoveryAuthority.psm1*"
            } finally {
                $script:DiscoveryStartDependencyFailures.Clear()
            }
        }

        It 'reports the all-zero digest for an absent handler path' {
            Get-DiscoveryStartHandlerSha256 -HandlerPath '' | Should -Be ('0' * 64)
            Get-DiscoveryStartHandlerSha256 -HandlerPath 'C:/Users/Example/missing-handler.ps1' | Should -Be ('0' * 64)
        }
    }

    Context 'stop adapter' {
        BeforeAll { . $script:Hooks.Stop }

        It 'exits 2 with the gate prefix for an unreadable payload through the script tail' {
            $result = Invoke-ScriptEntry -Path $script:Hooks.Stop -Stdin '{'
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'
        }

        It 'records a dependency failure with and without an error record and blocks naming it' {
            Add-DiscoveryStopDependencyFailure -Name 'DiscoveryStop.psm1'
            Add-DiscoveryStopDependencyFailure -Name 'DiscoveryPayload.psm1' -ErrorRecord (Get-ErrorRecordSample)
            try {
                $script:DiscoveryStopDependencyFailures[1].Message | Should -Be 'simulated import failure'
                $outcome = Invoke-DiscoveryAgentStopDecision -PayloadRaw '{}'
                $outcome.Decision | Should -Be 'block'
                $outcome.Code | Should -Be 'DEPENDENCY'
                $outcome.Reason | Should -BeLike "*DiscoveryStop.psm1*"
            } finally {
                $script:DiscoveryStopDependencyFailures.Clear()
            }
        }

        It 'writes the continuation stop result when the decision was already continued' {
            Mock Invoke-DiscoveryAgentStopDecision { [pscustomobject]@{ Decision = 'allow'; Code = 'CONTINUED'; Reason = 'the specialist was already continued once.' } }
            $priorOut = [System.Console]::Out
            $outWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetOut($outWriter)
                $exitCode = Invoke-DiscoveryAgentStopEntryPoint -PayloadRaw '{}'
            } finally {
                [System.Console]::SetOut($priorOut)
            }
            $exitCode | Should -Be 0
            $written = $outWriter.ToString() | ConvertFrom-Json
            $written.continue | Should -BeFalse
            $written.stopReason | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*already continued*'
        }
    }

    Context 'planning adapter' {
        BeforeAll { . $script:Hooks.Planning }

        It 'writes a deny decision at exit 0 for an unreadable payload through the script tail' {
            $gateHostEnvironment = $script:GateHostEnvironment
            $planningStore = Get-GateStore -HostName 'github-copilot'
            Mock Get-DiscoveryTrustedHostEnvironment { $gateHostEnvironment }.GetNewClosure()
            Mock Get-DiscoveryStartStore { $planningStore }.GetNewClosure()
            $result = Invoke-ScriptEntry -Path $script:Hooks.Planning -Stdin '{'
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 0
            ($result.Stdout | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'records a dependency failure with and without an error record and denies naming it' {
            Add-DiscoveryPlanningDependencyFailure -Name 'DiscoveryPlanning.psm1'
            Add-DiscoveryPlanningDependencyFailure -Name 'DiscoveryManifest.psm1' -ErrorRecord (Get-ErrorRecordSample)
            try {
                $script:DiscoveryPlanningDependencyFailures[1].Message | Should -Be 'simulated import failure'
                $decision = (Invoke-DiscoveryPlanningDecision -ToolInputRaw '{}').hookSpecificOutput
                $decision.permissionDecision | Should -Be 'deny'
                $decision.permissionDecisionReason | Should -BeLike 'DISCOVERY_PLANNING_GATE_BLOCKED:*DiscoveryPlanning.psm1*'
            } finally {
                $script:DiscoveryPlanningDependencyFailures.Clear()
            }
        }
    }

    Context 'pre-tool adapter' {
        BeforeAll { . $script:Hooks.PreTool }

        It 'records a dependency failure with and without an error record' {
            Add-DiscoveryGateDependencyFailure -Name 'DiscoveryAuthorization.psm1'
            Add-DiscoveryGateDependencyFailure -Name 'DiscoveryEncoding.psm1' -ErrorRecord (Get-ErrorRecordSample)
            try {
                $script:DiscoveryGateDependencyFailures[0].Message | Should -Be 'no error record'
                $script:DiscoveryGateDependencyFailures[1].Message | Should -Be 'simulated import failure'
            } finally {
                $script:DiscoveryGateDependencyFailures.Clear()
            }
        }

        It 'reports the all-zero digest for an absent handler path' {
            Get-DiscoveryGateHandlerSha256 -HandlerPath '' | Should -Be ('0' * 64)
        }
    }

    Context 'capability probe' {
        BeforeAll { . $script:Hooks.Probe }

        It 'reads the caller runtime JSON into the five runtime keys' {
            $runtime = Get-DiscoveryProbeRuntime -RuntimeJson '{"build_sha256":"b","package_version":"2.0.0","policy_sha256":"p","policy_version":"1","schema_version":"2.0.0"}' -WorkspaceRoot $script:GateWorkspaceRoot
            @($runtime.Keys) | Should -Be @('build_sha256', 'package_version', 'policy_sha256', 'policy_version', 'schema_version')
            $runtime['package_version'] | Should -Be '2.0.0'
        }

        It 'runs the observation through the script tail against the in-memory store and exits with the verdict' {
            $gateHostEnvironment = $script:GateHostEnvironment
            $probeStore = Get-GateStore -HostName 'github-copilot'
            Mock Get-DiscoveryTrustedHostEnvironment { $gateHostEnvironment }.GetNewClosure()
            Mock Get-DiscoveryDefaultStore { $probeStore }.GetNewClosure()
            $result = Invoke-ScriptEntry -Path $script:Hooks.Probe -Arguments @{ WorkspaceRoot = $script:GateWorkspaceRoot; SessionId = 'session-alpha'; Nonce = $script:GateNonce; RuntimeJson = '{"build_sha256":"b","package_version":"2.0.0","policy_sha256":"p","policy_version":"1","schema_version":"2.0.0"}' }
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 1
            ($result.Stdout | ConvertFrom-Json).status | Should -Be 'unsupported'
        }

        It 'defaults the workspace root to the repository that hosts the probe' {
            $gateHostEnvironment = $script:GateHostEnvironment
            $probeStore = Get-GateStore -HostName 'github-copilot'
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
