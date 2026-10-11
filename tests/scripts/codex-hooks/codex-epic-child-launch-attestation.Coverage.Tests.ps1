#Requires -Version 7.0
<#
.SYNOPSIS
    Coverage tests for .codex/hooks/codex-epic-child-launch-attestation.ps1 (issue #786).

.DESCRIPTION
    Exercises the launch-environment reader (environment variables set for the test and
    restored in finally), the relative-path branch of the canonical-path helper, and the
    environment and receipt fallbacks of the launch-authority check. The receipt read goes
    through a Pester mock of Get-Content; no test creates, renames, moves, or deletes a file.
#>

Describe 'Codex epic child launch attestation coverage (issue #786)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . ([System.IO.Path]::GetFullPath((Join-Path $script:RepoRoot '.codex/hooks/hook-dependency-guard.ps1')))
        . ([System.IO.Path]::GetFullPath((Join-Path $script:RepoRoot '.codex/hooks/codex-epic-child-launch-attestation.ps1')))
        $script:RealTestLaunchAuthority = ${function:Test-CodexEpicChildRoutingLaunchAuthority}
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        if (Get-Command Test-CodexEpicChildRoutingLaunchAuthority -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Test-CodexEpicChildRoutingLaunchAuthority' -Surface 'Codex' }
        $script:LaunchVariables = @(
            'CODEX_EPIC_CHILD_LAUNCH_ID', 'CODEX_EPIC_CHILD_LAUNCH_RECEIPT', 'CODEX_EPIC_CHILD_LAUNCH_SPEC',
            'CODEX_EPIC_CHILD_EXPECTED_WORKTREE', 'CODEX_EPIC_CHILD_DELEGATION_ID', 'CODEX_EPIC_CHILD_EXECUTION_CONTEXT',
            'CODEX_EPIC_CHILD_AGENT', 'CODEX_EPIC_CHILD_MODEL', 'CODEX_EPIC_CHILD_REASONING_EFFORT', 'CODEX_EPIC_CHILD_PROFILE_SHA256')
    }

    It 'reads every launch field from its environment variable' {
        # Arrange: each variable holds its own name.
        $prior = @{}
        foreach ($name in $script:LaunchVariables) { $prior[$name] = [Environment]::GetEnvironmentVariable($name) }
        try {
            foreach ($name in $script:LaunchVariables) { [Environment]::SetEnvironmentVariable($name, $name) }
            # Act
            $environment = Get-CodexEpicChildLaunchEnvironment
        }
        finally {
            foreach ($name in $script:LaunchVariables) { [Environment]::SetEnvironmentVariable($name, $prior[$name]) }
        }
        # Assert
        $environment.launch_id | Should -Be 'CODEX_EPIC_CHILD_LAUNCH_ID'
        $environment.profile_sha256 | Should -Be 'CODEX_EPIC_CHILD_PROFILE_SHA256'
    }

    It 'joins a relative path to its base path' {
        $expected = [System.IO.Path]::GetFullPath((Join-Path $script:RepoRoot 'artifacts/x.json'))
        Get-CodexEpicChildCanonicalPath -Path 'artifacts/x.json' -BasePath $script:RepoRoot | Should -Be $expected
    }

    It 'denies an epic child when its receipt cannot be read from the environment path' {
        # Arrange: no launch environment or receipt text is supplied, so both are read; the read fails.
        Mock Test-CodexEpicChildRoutingLaunchAuthority -MockWith $script:RealTestLaunchAuthority
        Mock Get-Content { throw 'simulated receipt read failure' }
        $receipt = [pscustomobject]@{ execution_context = 'epic_execution_child' }
        $priorReceipt = $env:CODEX_EPIC_CHILD_LAUNCH_RECEIPT
        try {
            $env:CODEX_EPIC_CHILD_LAUNCH_RECEIPT = 'artifacts/orchestration/epic-child-launches/r-786.json'
            # Act
            $result = Test-CodexEpicChildRoutingLaunchAuthority -RoutingReceipt $receipt -Payload ([pscustomobject]@{ session_id = 's-786' }) -RepositoryRoot $script:RepoRoot
        }
        finally { $env:CODEX_EPIC_CHILD_LAUNCH_RECEIPT = $priorReceipt }
        # Assert
        $result | Should -BeFalse
        Should -Invoke Get-Content -Times 1 -Exactly
    }

    It 'allows a receipt outside the epic child contexts' {
        Mock Test-CodexEpicChildRoutingLaunchAuthority -MockWith $script:RealTestLaunchAuthority
        Test-CodexEpicChildRoutingLaunchAuthority -RoutingReceipt $null -Payload ([pscustomobject]@{ session_id = 's-786' }) -RepositoryRoot $script:RepoRoot | Should -BeTrue
    }
}
