#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Process entry point and default probe seam of scripts/dev-tools/Test-DiscoveryHostCapability.ps1 (issue #980).
.DESCRIPTION
    The operator script is run through the & route with the console streams redirected, so its default
    RunProbe seam dot-sources the real host probe and the script tail writes the document and exits with
    the verdict. The protected store and the trusted host environment are mocked to the in-memory
    fixtures, which hold no host observation for the probed session, so every host reports unsupported
    naming trusted_attribution and forbidden_tools_denied. No file is written and no process, network
    or clock is touched.
#>

Describe 'Test-DiscoveryHostCapability.ps1 entry point' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot 'scripts/dev-tools/Test-DiscoveryHostCapability.ps1'
        # The Copilot pre-tool adapter imports the shared helper modules the support file resolves against.
        . (Join-Path $script:RepoRoot '.github/hooks/discovery-pre-tool.ps1')
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')

        function Invoke-ScriptEntry {
            # Runs the operator script through the & route with the console streams redirected.
            param([Parameter(Mandatory = $true)][hashtable]$Arguments)
            $priorOut = [System.Console]::Out
            $priorError = [System.Console]::Error
            $outWriter = [System.IO.StringWriter]::new()
            $errorWriter = [System.IO.StringWriter]::new()
            $thrown = $null
            try {
                [System.Console]::SetOut($outWriter)
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                $pipeline = @()
                try { $pipeline = @(& $script:UnderTest @Arguments) } catch { $thrown = $_ }
                $exitCode = $LASTEXITCODE
            } finally {
                [System.Console]::SetOut($priorOut)
                [System.Console]::SetError($priorError)
            }
            $pipelineText = (@($pipeline | ForEach-Object { [string]$_ }) -join "`n")
            return [pscustomobject]@{ ExitCode = $exitCode; Stdout = ($outWriter.ToString() + $pipelineText); Stderr = $errorWriter.ToString(); Thrown = $thrown }
        }
    }

    It 'exits 2 and writes the unsupported document when the workspace has no installed probe' {
        $result = Invoke-ScriptEntry -Arguments @{ HostName = 'codex'; WorkspaceRoot = $script:GateWorkspaceRoot; SessionId = 'session-alpha' }
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        ($result.Stdout | ConvertFrom-Json).status | Should -Be 'unsupported'
    }

    It 'dot-sources the <HostName> probe through the default seam and reports a session without observations unsupported' -ForEach @(
        @{ HostName = 'claude-code' }
        @{ HostName = 'codex' }
        @{ HostName = 'github-copilot' }
    ) {
        $gateHostEnvironment = $script:GateHostEnvironment
        $probeStore = Get-GateStore -HostName $HostName
        Mock Get-DiscoveryTrustedHostEnvironment { $gateHostEnvironment }.GetNewClosure()
        Mock Get-DiscoveryDefaultStore { $probeStore }.GetNewClosure()
        $result = Invoke-ScriptEntry -Arguments @{ HostName = $HostName; SessionId = 'session-alpha'; RuntimeJson = '{"build_sha256":"b","package_version":"2.0.0","policy_sha256":"p","policy_version":"1","schema_version":"2.0.0"}' }
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 1
        $document = $result.Stdout | ConvertFrom-Json
        $document.status | Should -Be 'unsupported'
        # No in-process sentinel decision stands in for the host: without recorded observations both controls are unproved.
        $messages = @($document.findings | ForEach-Object { [string]$_.message }) -join ' | '
        $messages | Should -BeLike '*Native control trusted_attribution is not proved:*'
        $messages | Should -BeLike '*Native control forbidden_tools_denied is not proved:*'
        $document.controls.trusted_attribution | Should -BeFalse
        ([string]$document.workspace.workspace_root -replace '\\', '/') | Should -Be ($script:RepoRoot -replace '\\', '/')
    }
}
