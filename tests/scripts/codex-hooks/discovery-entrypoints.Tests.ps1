#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Process entry points of the four Codex discovery adapters (issue #980).
.DESCRIPTION
    Each adapter is driven through the & route with stdin, stdout and stderr redirected and restored in
    finally, so the script-level tail (dependency decision, payload read, decision write, exit code)
    executes exactly as the harness runs it. The protected store and the trusted host environment are
    mocked to the in-memory fixtures, so no file is written and no process, network or clock is touched.
#>

Describe 'Codex discovery adapter entry points' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:Hooks = @{
            Gate     = Join-Path $script:RepoRoot '.codex/hooks/enforce-discovery-artifact-gate.ps1'
            Planning = Join-Path $script:RepoRoot '.codex/hooks/enforce-discovery-planning-gate.ps1'
            Output   = Join-Path $script:RepoRoot '.codex/hooks/validate-discovery-agent-output.ps1'
            Probe    = Join-Path $script:RepoRoot '.codex/hooks/discovery-capability-probe.ps1'
        }
        # The artifact gate imports the shared helper modules the support file resolves against.
        . $script:Hooks.Gate
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
    }

    It 'exits 2 with the <Prefix> prefix for an unreadable payload through the <Name> script tail' -ForEach @(
        @{ Name = 'artifact gate'; Key = 'Gate'; Prefix = 'DISCOVERY_ARTIFACT_GATE_BLOCKED:' }
        @{ Name = 'planning gate'; Key = 'Planning'; Prefix = 'DISCOVERY_PLANNING_GATE_BLOCKED:' }
        @{ Name = 'output validator'; Key = 'Output'; Prefix = 'DISCOVERY_ARTIFACT_GATE_BLOCKED:' }
    ) {
        $result = Invoke-ScriptEntry -Path $script:Hooks[$Key] -Stdin '{'
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -BeLike "$Prefix*"
    }

    Context 'published destination layout' {
        # The published destination keeps the helpers beside .codex/hooks under ../lib. The presence
        # check is mocked so the adapters take that import branch inside this repository, where the
        # files are absent, and every import failure must become a dependency denial.
        BeforeEach {
            Mock Test-Path { $true } -ParameterFilter { $LiteralPath -like '*DiscoveryEncoding.psm1' }
        }
        AfterEach {
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
        }

        It 'denies naming the first absent published helper after loading the <Name> adapter' -ForEach @(
            @{ Name = 'artifact gate'; Key = 'Gate'; Decision = 'Invoke-DiscoveryArtifactGateDecision'; Prefix = 'DISCOVERY_ARTIFACT_GATE_BLOCKED:' }
            @{ Name = 'planning gate'; Key = 'Planning'; Decision = 'Invoke-DiscoveryPlanningGateDecision'; Prefix = 'DISCOVERY_PLANNING_GATE_BLOCKED:' }
        ) {
            . $script:Hooks[$Key]
            $script:HookDependencyFailures.Count | Should -BeGreaterThan 0
            $outcome = & $Decision -ToolInputRaw '{}'
            $outcome.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $outcome.hookSpecificOutput.permissionDecisionReason | Should -BeLike "$Prefix*DiscoveryEncoding.psm1*"
        }

        It 'blocks naming the first absent published helper after loading the output validator' {
            . $script:Hooks.Output
            $script:HookDependencyFailures.Count | Should -BeGreaterThan 0
            $outcome = Invoke-DiscoveryAgentOutputDecision -PayloadRaw '{}'
            [int]$outcome.ExitCode | Should -Be 2
            [string]$outcome.Reason | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*DiscoveryEncoding.psm1*'
        }
    }

    Context 'artifact gate helpers' {
        BeforeAll { . $script:Hooks.Gate }

        It 'reports the all-zero digest for an absent handler path' {
            Get-DiscoveryGateHandlerSha256 -HandlerPath '' | Should -Be ('0' * 64)
            Get-DiscoveryGateHandlerSha256 -HandlerPath 'C:/Users/Example/missing-handler.ps1' | Should -Be ('0' * 64)
        }
    }

    Context 'capability probe' {
        BeforeAll { . $script:Hooks.Probe }

        It 'reads the caller runtime JSON into the five runtime keys' {
            $runtime = Get-DiscoveryProbeRuntime -RuntimeJson '{"build_sha256":"b","package_version":"2.0.0","policy_sha256":"p","policy_version":"1","schema_version":"2.0.0"}' -WorkspaceRoot $script:GateWorkspaceRoot
            @($runtime.Keys) | Should -Be @('build_sha256', 'package_version', 'policy_sha256', 'policy_version', 'schema_version')
            $runtime['policy_version'] | Should -Be '1'
        }

        It 'runs the observation through the script tail against the in-memory store and exits with the verdict' {
            $gateHostEnvironment = $script:GateHostEnvironment
            $probeStore = Get-GateStore -HostName 'codex'
            Mock Get-DiscoveryTrustedHostEnvironment { $gateHostEnvironment }.GetNewClosure()
            Mock Get-DiscoveryDefaultStore { $probeStore }.GetNewClosure()
            $result = Invoke-ScriptEntry -Path $script:Hooks.Probe -Arguments @{ WorkspaceRoot = $script:GateWorkspaceRoot; SessionId = 'session-alpha'; Nonce = $script:GateNonce; RuntimeJson = '{"build_sha256":"b","package_version":"2.0.0","policy_sha256":"p","policy_version":"1","schema_version":"2.0.0"}' }
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 1
            ($result.Stdout | ConvertFrom-Json).status | Should -Be 'unsupported'
        }

        It 'defaults the workspace root to the repository that hosts the probe' {
            $gateHostEnvironment = $script:GateHostEnvironment
            $probeStore = Get-GateStore -HostName 'codex'
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
