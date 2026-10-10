#Requires -Version 7.0
<#
.SYNOPSIS
    Coverage tests for .codex/hooks/enforce-epic-wave-barrier.ps1 (issue #786).

.DESCRIPTION
    Exercises the JSON reader, the feature-key and feature lookups, the dependency and mutation
    rules, every decision branch (local and launcher-bound), and the entry point (stdin redirected
    and restored in finally). File reads, the primary-worktree lookup, and the launch-authority
    check go through Pester mocks; no test creates, renames, moves, or deletes a file.
#>

Describe 'Codex enforce-epic-wave-barrier coverage (issue #786)' {
    BeforeAll {
        $script:HookFile = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.codex/hooks/enforce-epic-wave-barrier.ps1'))
        . $script:HookFile
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-EpicWaveBarrierCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWaveBarrierCheckpointContent' -Surface 'Codex' }
        if (Get-Command Test-CodexEpicChildRoutingLaunchAuthority -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Test-CodexEpicChildRoutingLaunchAuthority' -Surface 'Codex' }

        function Invoke-WaveEntry {
            # Drives the entry point with the given stdin; stdin and stderr are restored in finally.
            param([AllowEmptyString()] [string] $Stdin)
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($Stdin))
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                $stdout = @(& $script:HookFile)
                return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Stdout = (($stdout | ForEach-Object { [string]$_ }) -join "`n"); Stderr = $errorWriter.ToString() }
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
            }
        }

        function Invoke-LaunchedWaveEntry {
            # Drives the entry point as an execution child whose receipt names the given issue and folder.
            param([string] $IssueNum, [string] $Folder)
            $prior = @{ R = $env:CODEX_EPIC_CHILD_LAUNCH_RECEIPT; C = $env:CODEX_EPIC_CHILD_EXECUTION_CONTEXT; L = $env:CODEX_EPIC_CHILD_LAUNCH_ID }
            # Locals, not script variables: the mocks run inside the hook, whose script scope hides this file's.
            $launchReceiptText = '{"issue_num":"' + $IssueNum + '","feature_folder":"' + $Folder + '","checkpoint_path":"C:/epic-786.json"}'
            $epicText = $script:Epic
            try {
                $env:CODEX_EPIC_CHILD_LAUNCH_RECEIPT = 'C:/receipts/r-786.json'
                $env:CODEX_EPIC_CHILD_EXECUTION_CONTEXT = 'epic_execution_child'
                $env:CODEX_EPIC_CHILD_LAUNCH_ID = 'l-786'
                return Invoke-WaveEntry -Stdin '{"tool_name":"Write","tool_input":{"file_path":"a.txt"}}'
            }
            finally {
                $env:CODEX_EPIC_CHILD_LAUNCH_RECEIPT = $prior.R
                $env:CODEX_EPIC_CHILD_EXECUTION_CONTEXT = $prior.C
                $env:CODEX_EPIC_CHILD_LAUNCH_ID = $prior.L
            }
        }

        $script:Write = '{"tool_name":"Write","tool_input":{"file_path":"a.txt"}}'
        $script:Epic = '{"features":[null,{"issue_num":"1","feature_folder":"docs/features/active/one","merge_status":"merged"},{"issue_num":"2","feature_folder":"docs/features/active/two","depends_on":["1"]},{"issue_num":"3","feature_folder":"docs/features/active/three","depends_on":["9"]}]}'
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeRunCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }

    Context 'helpers' {
        It 'reads optional, empty, and malformed JSON' {
            ConvertFrom-CodexWaveJson -Raw '' -Name 'x' -Optional | Should -BeNullOrEmpty
            { ConvertFrom-CodexWaveJson -Raw '' -Name 'x' } | Should -Throw '*x is empty*'
            { ConvertFrom-CodexWaveJson -Raw '{bad' -Name 'x' } | Should -Throw '*malformed JSON*'
        }

        It 'derives the feature key from the epic context or returns empty' {
            Get-CodexWaveFeatureKey -LocalCheckpoint ([pscustomobject]@{ epic_context = [pscustomobject]@{ feature_folder = 'docs/features/active/two/' } }) | Should -Be 'two'
            Get-CodexWaveFeatureKey -LocalCheckpoint ([pscustomobject]@{ other = 1 }) | Should -Be ''
        }

        It 'finds no feature without a checkpoint or a match' {
            Find-CodexWaveFeature -Checkpoint $null -Key '1' | Should -BeNullOrEmpty
            Find-CodexWaveFeature -Checkpoint ($script:Epic | ConvertFrom-Json) -Key 'missing' | Should -BeNullOrEmpty
            (Find-CodexWaveFeature -Checkpoint ($script:Epic | ConvertFrom-Json) -Key 'two').issue_num | Should -Be '2'
        }

        It 'finds the launch feature by issue and folder' {
            $epic = $script:Epic | ConvertFrom-Json
            Find-CodexWaveLaunchFeature -Checkpoint $null -Receipt ([pscustomobject]@{}) | Should -BeNullOrEmpty
            (Find-CodexWaveLaunchFeature -Checkpoint $epic -Receipt ([pscustomobject]@{ issue_num = '2'; feature_folder = 'docs/features/active/two' })).issue_num | Should -Be '2'
            Find-CodexWaveLaunchFeature -Checkpoint $epic -Receipt ([pscustomobject]@{ issue_num = '7'; feature_folder = 'x' }) | Should -BeNullOrEmpty
        }

        It 'judges dependency readiness' {
            $epic = $script:Epic | ConvertFrom-Json
            Test-CodexWaveDependenciesReady -EpicCheckpoint $null -Feature $null | Should -BeFalse
            Test-CodexWaveDependenciesReady -EpicCheckpoint $epic -Feature ([pscustomobject]@{ issue_num = '1' }) | Should -BeTrue
            Test-CodexWaveDependenciesReady -EpicCheckpoint $epic -Feature ([pscustomobject]@{ depends_on = @('1') }) | Should -BeTrue
            Test-CodexWaveDependenciesReady -EpicCheckpoint $epic -Feature ([pscustomobject]@{ depends_on = @('9') }) | Should -BeFalse
        }

        It 'classifies <Tool> as mutation <Expected>' -ForEach @(
            @{ Tool = 'Write'; Expected = $true },
            @{ Tool = 'mcp__other__write'; Expected = $true },
            @{ Tool = 'mcp__drm-copilot__validate_plan'; Expected = $false },
            @{ Tool = 'mcp__drm-copilot__promote'; Expected = $true },
            @{ Tool = 'shell_command'; Expected = $true },
            @{ Tool = 'Read'; Expected = $false }
        ) {
            Test-CodexWaveMutation -Payload ([pscustomobject]@{ tool_name = $Tool }) | Should -Be $Expected
        }
    }

    Context 'Invoke-CodexEpicWaveDecision' {
        It 'allows a non-mutating tool' {
            Invoke-CodexEpicWaveDecision -PayloadRaw '{"tool_name":"Read"}' -LocalCheckpointRaw '' -EpicCheckpointRaw '' | Should -BeNullOrEmpty
        }

        It 'allows a preparation child and denies an unknown launcher context' {
            Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '' -EpicCheckpointRaw '' -LauncherEnvironment ([pscustomobject]@{ launch_id = 'l'; execution_context = 'epic_preparation_child' }) | Should -BeNullOrEmpty
            (Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '' -EpicCheckpointRaw '' -LauncherEnvironment ([pscustomobject]@{ launch_id = 'l'; execution_context = 'other' })).hookSpecificOutput.permissionDecisionReason | Should -Match 'invalid launcher execution context'
        }

        It 'denies an execution child without launch authority' {
            Mock Test-CodexEpicChildRoutingLaunchAuthority { $false }
            (Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '' -EpicCheckpointRaw '' -LauncherEnvironment ([pscustomobject]@{ launch_id = 'l'; execution_context = 'epic_execution_child' }) -RepositoryRoot 'C:\repo').hookSpecificOutput.permissionDecisionReason | Should -Match 'no valid session-bound launcher receipt'
        }

        It 'allows a ready launch feature and denies an unready one' {
            Mock Test-CodexEpicChildRoutingLaunchAuthority { $true }
            $environment = [pscustomobject]@{ launch_id = 'l'; execution_context = 'epic_execution_child' }
            Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '' -EpicCheckpointRaw $script:Epic -LauncherReceiptRaw '{"issue_num":"2","feature_folder":"docs/features/active/two"}' -LauncherEnvironment $environment -RepositoryRoot 'C:\repo' | Should -BeNullOrEmpty
            (Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '' -EpicCheckpointRaw $script:Epic -LauncherReceiptRaw '{"issue_num":"3","feature_folder":"docs/features/active/three"}' -LauncherEnvironment $environment -RepositoryRoot 'C:\repo').hookSpecificOutput.permissionDecisionReason | Should -Match 'receipt-bound epic checkpoint'
        }

        It 'judges a local child by its checkpoint and its epic dependencies' {
            Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '' -EpicCheckpointRaw $script:Epic | Should -BeNullOrEmpty
            Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '{"epic_mode":false}' -EpicCheckpointRaw $script:Epic | Should -BeNullOrEmpty
            Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '{"epic_mode":true,"issue-num":"2"}' -EpicCheckpointRaw $script:Epic | Should -BeNullOrEmpty
            (Invoke-CodexEpicWaveDecision -PayloadRaw $script:Write -LocalCheckpointRaw '{"epic_mode":true,"issue-num":"3"}' -EpicCheckpointRaw $script:Epic).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'entry point' {
        BeforeEach {
            Mock Get-CodexPrimaryWorktreeRoot { 'C:/primary' }
        }

        It 'exits 0 for a non-mutating tool with no local or launcher state' {
            Mock Test-Path { $false }
            $result = Invoke-WaveEntry -Stdin '{"tool_name":"Read"}'
            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }

        It 'reads the local checkpoint and exits 2 for an empty payload' {
            Mock Test-Path { $true } -ParameterFilter { ([string]$LiteralPath).EndsWith('orchestrator-state.json') }
            Mock Get-Content { '{"epic_mode":false}' }
            $result = Invoke-WaveEntry -Stdin ''
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Not -BeNullOrEmpty
        }

        It 'exits 0 without a deny for a ready execution child' {
            Mock Test-Path { ([string]$LiteralPath) -like '*r-786.json' -or ([string]$LiteralPath) -like '*epic-786.json' }
            Mock Get-Content { if (([string]$LiteralPath) -like '*r-786.json') { $launchReceiptText } else { $epicText } }
            Mock Test-CodexEpicChildRoutingLaunchAuthority { $true }
            $result = Invoke-LaunchedWaveEntry -IssueNum '2' -Folder 'docs/features/active/two'
            $result.ExitCode | Should -Be 0 -Because $result.Stderr
            $result.Stdout | Should -BeNullOrEmpty
        }

        It 'writes the deny for an unready execution child' {
            Mock Test-Path { ([string]$LiteralPath) -like '*r-786.json' -or ([string]$LiteralPath) -like '*epic-786.json' }
            Mock Get-Content { if (([string]$LiteralPath) -like '*r-786.json') { $launchReceiptText } else { $epicText } }
            Mock Test-CodexEpicChildRoutingLaunchAuthority { $true }
            $result = Invoke-LaunchedWaveEntry -IssueNum '3' -Folder 'docs/features/active/three'
            $result.ExitCode | Should -Be 0 -Because $result.Stderr
            ($result.Stdout | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }
}
