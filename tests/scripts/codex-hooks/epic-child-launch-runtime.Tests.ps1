#Requires -Version 7.0

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected seam stubs mirror the production scriptblock signatures')]
param()

<#
.SYNOPSIS
    Unit tests for the epic-child launch runtime helpers (issue #1035, remediation F1).

.DESCRIPTION
    Dot-sources .codex/scripts/epic-child-launch-contract.ps1 and then the runtime file. Git
    access is replaced by mocks of Invoke-CodexChildGit, Get-CodexChildGitScalar and
    Test-CodexChildGit; file-system checks by Test-Path mocks; auth copies by MemoryStream seams.
    One row reads the committed .codex/agents/orchestrator.toml. Rows that run a default seam use
    a path that does not exist, so the default open throws and nothing is created. Environment
    variables a row changes are saved and restored around each row.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    $script:DocsModuleWasLoaded = $null -ne (Get-Module -Name DevelopmentDocsRoot)
    . (Join-Path $script:RepoRoot '.codex/scripts/epic-child-launch-contract.ps1')
    . (Join-Path $script:RepoRoot '.codex/scripts/epic-child-launch-runtime.ps1')
    $script:Synthetic = [System.IO.Path]::GetFullPath((Join-Path $script:RepoRoot 'synthetic-roots'))
    $script:ProfileRaw = "name = `"orchestrator-c3`"`nmodel = `"gpt-6-astra`"`nmodel_reasoning_effort = `"high`"`ndefault_permissions = `"orchestrator-workspace`"`ndeveloper_instructions = '''`nx`n'''`n`n[skills]`nconfig = [ `"orchestrate`" ]`n"
}

AfterAll {
    if (-not $script:DocsModuleWasLoaded) {
        Remove-Module -Name DevelopmentDocsRoot -ErrorAction SilentlyContinue
    }
}

Describe 'Git scalar, receipt state and surface helpers' {
    It 'returns the single trimmed git value' {
        Mock Invoke-CodexChildGit { @(' value ') }
        Get-CodexChildGitScalar -GitArgs @('rev-parse', 'HEAD') | Should -BeExactly 'value'
    }

    It 'throws when git returns <Name>' -ForEach @(
        @{ Name = 'no value'; Lines = @() }
        @{ Name = 'two values'; Lines = @('a', 'b') }
    ) {
        $script:ScalarLines = $Lines
        Mock Invoke-CodexChildGit { $script:ScalarLines }
        { Get-CodexChildGitScalar -GitArgs @('rev-parse', 'HEAD') } | Should -Throw '*did not return one value*'
    }

    It 'sets receipt state <State> and persists it' -ForEach @(
        @{ State = 'launching'; Field = 'resume_started_at' }
        @{ State = 'active'; Field = 'session_bound_at' }
        @{ State = 'completed'; Field = 'completed_at' }
        @{ State = 'failed'; Field = 'failed_at' }
    ) {
        Mock Write-CodexChildJsonAtomic { }
        $receipt = [pscustomobject]@{
            receipt_path = 'memory/receipt.json'; state = 'x'; resume_started_at = $null; expires_at = $null
            codex_session_id = $null; session_bound_at = $null; exit_code = $null; completed_at = $null
            failure_reason = $null; failed_at = $null
        }

        Set-CodexChildReceiptState -Receipt $receipt -State $State -SessionId 'session-1' -FailureReason 'boom'

        $receipt.state | Should -BeExactly $State
        $receipt.$Field | Should -Not -BeNullOrEmpty
        Should -Invoke Write-CodexChildJsonAtomic -Times 1 -Exactly -ParameterFilter { $Path -eq 'memory/receipt.json' }
    }

    It 'records exit codes for completed and failed receipts' {
        Mock Write-CodexChildJsonAtomic { }
        $failed = [pscustomobject]@{ receipt_path = 'r'; state = 'x'; exit_code = $null; failure_reason = $null; failed_at = $null }
        $withCode = [pscustomobject]@{ receipt_path = 'r'; state = 'x'; exit_code = $null; failure_reason = $null; failed_at = $null }

        Set-CodexChildReceiptState -Receipt $failed -State failed
        Set-CodexChildReceiptState -Receipt $withCode -State failed -ExitCode 9

        $failed.exit_code | Should -Be -1
        $withCode.exit_code | Should -Be 9
    }

    It 'requires a session id for the active state' {
        Mock Write-CodexChildJsonAtomic { }
        $receipt = [pscustomobject]@{ receipt_path = 'r'; state = 'x' }
        { Set-CodexChildReceiptState -Receipt $receipt -State active } | Should -Throw '*active receipt requires a session id*'
        Should -Invoke Write-CodexChildJsonAtomic -Times 0 -Exactly
    }

    It 'changes nothing under -WhatIf' {
        Mock Write-CodexChildJsonAtomic { }
        $receipt = [pscustomobject]@{ receipt_path = 'r'; state = 'launching' }
        Set-CodexChildReceiptState -Receipt $receipt -State completed -WhatIf
        $receipt.state | Should -BeExactly 'launching'
        Should -Invoke Write-CodexChildJsonAtomic -Times 0 -Exactly
    }

    It 'canonicalizes the git common directory against the worktree' {
        Mock Get-CodexChildGitScalar { '.git' }
        $worktree = Join-Path $script:Synthetic 'child-a'
        Get-CodexChildCommonDirectory -WorktreePath $worktree | Should -BeExactly (Join-Path $worktree '.git')
    }

    It 'maps, compares and fingerprints the trusted surfaces' {
        Mock Get-CodexChildGitScalar { param([string[]] $GitArgs) "blob:$($GitArgs[-1])" }

        $map = Get-CodexChildSurfaceObjectMap -RepositoryPath $script:Synthetic -Commit 'abc'
        $other = [ordered]@{}; foreach ($key in $map.Keys) { $other[$key] = $map[$key] }

        @($map.Keys) | Should -Be @('.codex', '.agents', 'AGENTS.md', 'config/orchestration-routing.json')
        $map['.codex'] | Should -BeExactly 'blob:abc:.codex'
        Test-CodexChildSurfaceObjectsEqual -Expected $map -Actual $other | Should -BeTrue
        $other['AGENTS.md'] = 'changed'
        Test-CodexChildSurfaceObjectsEqual -Expected $map -Actual $other | Should -BeFalse
        $expected = Get-CodexChildSha256 -Value ((@($map.Keys) | ForEach-Object { "$_=$($map[$_])" }) -join "`n")
        Get-CodexChildSurfaceFingerprint -SurfaceObjects $map | Should -BeExactly $expected
    }
}

Describe 'Get-CodexChildTrustedProfile' {
    It 'reads the committed profile when its blob matches child HEAD' {
        Mock Get-CodexChildGitScalar { 'blob-1' }
        $result = Get-CodexChildTrustedProfile -WorktreePath $script:RepoRoot -ChildHead 'HEAD' -AgentName 'orchestrator'
        $result.Path | Should -BeExactly (Join-Path $script:RepoRoot '.codex/agents/orchestrator.toml')
        $result.Raw | Should -Match '(?m)^name = "orchestrator"'
        $result.Sha256 | Should -Match '^[0-9a-f]{64}$'
    }

    It 'throws when the working profile differs from child HEAD' {
        Mock Get-CodexChildGitScalar { param([string[]] $GitArgs) if ($GitArgs -contains 'hash-object') { 'blob-2' } else { 'blob-1' } }
        { Get-CodexChildTrustedProfile -WorktreePath $script:RepoRoot -ChildHead 'HEAD' -AgentName 'orchestrator' } |
            Should -Throw '*generated profile bytes differ from child HEAD*'
    }
}

Describe 'Get-CodexChildRuntimeContext' {
    BeforeEach {
        $root = Join-Path $script:Synthetic 'runtime-root'
        $child = Join-Path $script:Synthetic 'runtime-child'
        $script:Ctx = @{
            Root = $root; Child = $child; RootTop = $root; ChildTop = $child; RootBranch = 'epic/int'; ChildBranch = 'feature/a'
            RootHead = ('1' * 40); IntegrationHead = ('1' * 40); ChildCommon = 'common'; DirtyPath = ''; Descends = $true
            ChildSurface = 'same'; Missing = @(); Resolved = $true
        }
        Mock Get-CodexChildGitScalar {
            param([string[]] $GitArgs)
            $isRoot = $GitArgs[1] -eq $script:Ctx.Root
            if ($GitArgs -contains '--show-toplevel') { if ($isRoot) { return $script:Ctx.RootTop } else { return $script:Ctx.ChildTop } }
            if ($GitArgs -contains '--show-current') { if ($isRoot) { return $script:Ctx.RootBranch } else { return $script:Ctx.ChildBranch } }
            if ($GitArgs -contains '--verify') { return $script:Ctx.IntegrationHead }
            if ($isRoot) { return $script:Ctx.RootHead } else { return ('2' * 40) }
        }
        Mock Get-CodexChildCommonDirectory { param([string] $WorktreePath) if ($WorktreePath -eq $script:Ctx.Root) { 'common' } else { $script:Ctx.ChildCommon } }
        Mock Invoke-CodexChildGit { param([string[]] $GitArgs) if ($GitArgs[1] -eq $script:Ctx.DirtyPath) { @(' M file.txt') } else { @() } }
        Mock Get-CodexChildSurfaceObjectMap { param([string] $RepositoryPath) if ($RepositoryPath -eq $script:Ctx.Root) { [ordered]@{ '.codex' = 'same' } } else { [ordered]@{ '.codex' = $script:Ctx.ChildSurface } } }
        Mock Test-CodexChildGit { $script:Ctx.Descends }
        Mock Test-Path { -not ($script:Ctx.Missing -contains "$LiteralPath") }
        Mock Resolve-DevelopmentDocsRoot { if ($script:Ctx.Resolved) { [pscustomobject]@{ Succeeded = $true; Root = 'docs/features'; Reason = $null } } else { [pscustomobject]@{ Succeeded = $false; Root = $null; Reason = 'routing failure' } } }
        Mock Get-CodexChildTrustedProfile { [pscustomobject]@{ Path = 'profile.toml'; Raw = $script:ProfileRaw; Sha256 = ('a' * 64) } }
        $script:Entry = [pscustomobject]@{ feature_folder = 'docs/features/active/feature-a'; deployment_agent = 'orchestrator-c3'; worktree_path = $child; branch_name = 'feature/a' }
        $script:Spec = [pscustomobject]@{ integration_branch = 'epic/int'; launches = @($script:Entry) }
    }

    It 'returns the profile and branch maps for a valid launch' {
        $result = Get-CodexChildRuntimeContext -Spec $script:Spec -RepositoryRoot $script:Ctx.Root

        $key = Get-CodexChildProfileKey -WorktreePath $script:Ctx.Child -AgentName 'orchestrator-c3' -RepositoryRoot $script:Ctx.Root
        $result.Profiles[$key].child_head | Should -BeExactly ('2' * 40)
        $result.Profiles[$key].integration_head | Should -BeExactly ('1' * 40)
        $result.Branches[$script:Ctx.Child] | Should -BeExactly 'feature/a'
    }

    It 'blocks when <Name>' -ForEach @(
        @{ Name = 'the root is not the worktree top'; Expected = '*must be the trusted Git worktree root*'; Change = { $script:Ctx.RootTop = $script:Ctx.Child } }
        @{ Name = 'the root is on another branch'; Expected = '*checked out on the integration branch*'; Change = { $script:Ctx.RootBranch = 'main' } }
        @{ Name = 'the root is dirty'; Expected = '*RepositoryRoot must be completely clean*'; Change = { $script:Ctx.DirtyPath = $script:Ctx.Root } }
        @{ Name = 'the root HEAD is not the integration tip'; Expected = '*must equal the integration branch tip*'; Change = { $script:Ctx.IntegrationHead = ('9' * 40) } }
        @{ Name = 'the docs root does not resolve'; Expected = '*EPIC_CHILD_LAUNCH_BLOCKED: routing failure*'; Change = { $script:Ctx.Resolved = $false } }
        @{ Name = 'the feature folder is not active'; Expected = '*not a final active feature identity*'; Change = { $script:Entry.feature_folder = 'docs/features/potential/feature-a' } }
        @{ Name = 'the agent name is unsafe'; Expected = '*not a safe generated profile name*'; Change = { $script:Entry.deployment_agent = 'Bad Agent' } }
        @{ Name = 'the child path does not exist'; Expected = '*distinct existing worktree*'; Change = { $script:Ctx.Missing = @($script:Ctx.Child) } }
        @{ Name = 'the feature folder is missing'; Expected = '*must exist in RepositoryRoot and child HEAD*'; Change = { $script:Ctx.Missing = @([System.IO.Path]::GetFullPath((Join-Path $script:Ctx.Root 'docs/features/active/feature-a'))) } }
        @{ Name = 'the child is not a worktree root'; Expected = '*not the root of its Git worktree*'; Change = { $script:Ctx.ChildTop = $script:Ctx.Root } }
        @{ Name = 'the common directory differs'; Expected = '*does not share RepositoryRoot*'; Change = { $script:Ctx.ChildCommon = 'other' } }
        @{ Name = 'the child branch differs'; Expected = '*child branch does not match*'; Change = { $script:Ctx.ChildBranch = 'feature/b' } }
        @{ Name = 'the child is dirty'; Expected = '*child worktree must be completely clean*'; Change = { $script:Ctx.DirtyPath = $script:Ctx.Child } }
        @{ Name = 'the child does not descend from the tip'; Expected = '*does not descend from the integration branch*'; Change = { $script:Ctx.Descends = $false } }
        @{ Name = 'the customizations differ'; Expected = '*customizations differ*'; Change = { $script:Ctx.ChildSurface = 'changed' } }
    ) {
        . $Change
        { Get-CodexChildRuntimeContext -Spec $script:Spec -RepositoryRoot $script:Ctx.Root } | Should -Throw $Expected
    }
}

Describe 'Command context and TOML builders' {
    BeforeEach {
        # Save, then clear, each variable the command context reads; AfterEach restores each by name.
        $script:SavedEnv = @{}
        foreach ($name in @('OPENAI_API_KEY', 'AZURE_OPENAI_API_KEY', 'CODEX_API_KEY', 'OPENAI_ACCESS_TOKEN', 'CODEX_HOME')) {
            $script:SavedEnv[$name] = [Environment]::GetEnvironmentVariable($name)
        }
        [Environment]::SetEnvironmentVariable('OPENAI_API_KEY', $null)
        [Environment]::SetEnvironmentVariable('AZURE_OPENAI_API_KEY', $null)
        [Environment]::SetEnvironmentVariable('CODEX_API_KEY', $null)
        [Environment]::SetEnvironmentVariable('OPENAI_ACCESS_TOKEN', $null)
        [Environment]::SetEnvironmentVariable('CODEX_HOME', $null)
        $script:CodexHome = Join-Path $script:Synthetic 'codex-home'
        $script:CommandPath = Join-Path $script:Synthetic 'bin/codex'
        Mock Get-Command { @([pscustomobject]@{ Source = $script:CommandPath }, [pscustomobject]@{ Source = '' }) } -ParameterFilter { $Name -eq 'codex' }
        Mock Test-Path { $true }
    }

    AfterEach {
        # Each variable is restored by its literal name so the leak scan pairs every write above.
        [Environment]::SetEnvironmentVariable('OPENAI_API_KEY', $script:SavedEnv['OPENAI_API_KEY'])
        [Environment]::SetEnvironmentVariable('AZURE_OPENAI_API_KEY', $script:SavedEnv['AZURE_OPENAI_API_KEY'])
        [Environment]::SetEnvironmentVariable('CODEX_API_KEY', $script:SavedEnv['CODEX_API_KEY'])
        [Environment]::SetEnvironmentVariable('OPENAI_ACCESS_TOKEN', $script:SavedEnv['OPENAI_ACCESS_TOKEN'])
        [Environment]::SetEnvironmentVariable('CODEX_HOME', $script:SavedEnv['CODEX_HOME'])
    }

    It 'collects the command path and the denied credential paths' {
        [Environment]::SetEnvironmentVariable('CODEX_HOME', $script:CodexHome)

        $result = Get-CodexChildCommandContext

        $result.CommandPath | Should -BeExactly $script:CommandPath
        $result.CredentialRoot | Should -BeExactly ([System.IO.Path]::GetFullPath($script:CodexHome))
        $result.OriginalAuthPath | Should -BeExactly ([System.IO.Path]::GetFullPath((Join-Path $script:CodexHome 'auth.json')))
        $result.DeniedPaths | Should -Contain ([System.IO.Path]::GetFullPath((Join-Path $script:CodexHome 'app-server-daemon')))
        $result.DeniedPaths | Should -Contain ([System.IO.Path]::GetFullPath((Join-Path $script:Synthetic 'bin/node_modules/@openai/codex')))
    }

    It 'defaults CODEX_HOME to the profile .codex folder' {
        $result = Get-CodexChildCommandContext
        $result.CredentialRoot | Should -BeExactly ([System.IO.Path]::GetFullPath((Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)) '.codex')))
    }

    It 'refuses environment-based authentication' {
        [Environment]::SetEnvironmentVariable('CODEX_API_KEY', 'synthetic-value')
        { Get-CodexChildCommandContext } | Should -Throw '*environment-based Codex authentication is not supported*CODEX_API_KEY*'
    }

    It 'requires file-based authentication under CODEX_HOME' {
        [Environment]::SetEnvironmentVariable('CODEX_HOME', $script:CodexHome)
        Mock Test-Path { $false } -ParameterFilter { "$LiteralPath" -like '*auth.json' }
        { Get-CodexChildCommandContext } | Should -Throw '*require file-based Codex authentication*'
    }

    It 'escapes TOML strings and builds the permission, projects and shell overrides' {
        ConvertTo-CodexChildTomlString -Value "a\b`"c`td`ne" | Should -BeExactly '"a\\b\"c\td\ne"'
        Get-CodexChildPermissionOverride -DeniedPaths @('x') | Should -BeExactly "permissions.epic-child-workspace={ extends='orchestrator-workspace', filesystem={ `"x`" = 'deny' } }"
        Get-CodexChildProjectsOverride -WorktreePath 'w' | Should -BeExactly "projects={ `"w`" = { trust_level='trusted' } }"
        $shell = @(Get-CodexChildShellEnvironmentOverrideList -WorktreePath 'w')
        $shell.Count | Should -Be 2
        $shell[1] | Should -Match 'epic-child-no-auth'
        Get-CodexChildAuthorityRoot | Should -Match 'CodexEpicChildren$'
    }
}

Describe 'Isolated home and auth lifecycle' {
    BeforeEach {
        $script:Calls = [System.Collections.Generic.List[string]]::new()
        $script:Seams = @{
            PathExists      = { param([string] $Path) $script:Calls.Add("exists:$Path"); $false }
            CreateDirectory = { param([string] $Path) $script:Calls.Add('create') }
            CopyFile        = { param([string] $Source, [string] $Destination) $script:Calls.Add('copy') }
            DeleteDirectory = { param([string] $Path) $script:Calls.Add('delete') }
            AssertAuthority = { param([string] $Authority, [string] $Repository) $script:Calls.Add('assert') }
        }
    }

    It 'creates an isolated home under the authority root' {
        $seams = $script:Seams
        $isolatedHome = New-CodexChildIsolatedHome -RepositoryRoot $script:RepoRoot -WaveId 'w' -LaunchId 'l' -OriginalAuthPath 'auth.json' @seams
        $isolatedHome | Should -BeLike "$(Get-CodexChildAuthorityRoot)*"
        @($script:Calls | Where-Object { $_ -in 'assert', 'create', 'copy' }) | Should -Be @('assert', 'create', 'copy')
    }

    It 'refuses an isolated home that already exists' {
        $seams = $script:Seams.Clone(); $seams.PathExists = { param([string] $Path) $true }
        { New-CodexChildIsolatedHome -RepositoryRoot $script:RepoRoot -WaveId 'w' -LaunchId 'l' -OriginalAuthPath 'auth.json' @seams } |
            Should -Throw '*isolated CODEX_HOME already exists*'
    }

    It 'removes a partly created home after a copy failure, and reports a failed cleanup' {
        $seams = $script:Seams.Clone()
        $seams.CopyFile = { param([string] $Source, [string] $Destination) throw 'copy failed' }
        $seams.PathExists = { param([string] $Path) $script:Calls.Add('exists'); ($script:Calls | Where-Object { $_ -eq 'exists' }).Count -gt 1 }
        { New-CodexChildIsolatedHome -RepositoryRoot $script:RepoRoot -WaveId 'w' -LaunchId 'l' -OriginalAuthPath 'auth.json' @seams } | Should -Throw '*copy failed*'
        $script:Calls | Should -Contain 'delete'

        $script:Calls.Clear()
        $seams.DeleteDirectory = { param([string] $Path) throw 'delete failed' }
        { New-CodexChildIsolatedHome -RepositoryRoot $script:RepoRoot -WaveId 'w' -LaunchId 'l' -OriginalAuthPath 'auth.json' @seams } |
            Should -Throw '*creation failed and cleanup also failed*'
    }

    It 'refuses to restore over an existing auth copy' {
        Mock Test-Path { $true }
        { Restore-CodexChildIsolatedAuth -HomePath 'home' -OriginalAuthPath 'auth.json' } | Should -Throw '*isolated auth copy already exists before resume*'
    }

    It 'copies the auth bytes through the stream seams' {
        Mock Test-Path { $false }
        $state = [pscustomobject]@{ Destination = $null }
        $openSource = { param([string] $Path) [System.IO.MemoryStream]::new([byte[]](1, 2, 3)) }
        $openDestination = { param([string] $Path) $state.Destination = [System.IO.MemoryStream]::new(); $state.Destination }.GetNewClosure()

        Restore-CodexChildIsolatedAuth -HomePath 'home' -OriginalAuthPath 'auth.json' -OpenSource $openSource -OpenDestination $openDestination

        $state.Destination.ToArray() | Should -Be @(1, 2, 3)
    }

    It 'deletes the partial copy when the copy fails' {
        $script:TestPathCalls = 0
        Mock Test-Path { $script:TestPathCalls++; $script:TestPathCalls -gt 1 }
        $openSource = { param([string] $Path) [System.IO.MemoryStream]::new([byte[]](1, 2, 3)) }
        $openReadOnly = { param([string] $Path) [System.IO.MemoryStream]::new([byte[]]@(), $false) }
        $deleted = [System.Collections.Generic.List[string]]::new()
        $delete = { param([string] $Path) $deleted.Add($Path) }.GetNewClosure()

        { Restore-CodexChildIsolatedAuth -HomePath 'home' -OriginalAuthPath 'auth.json' -OpenSource $openSource -OpenDestination $openReadOnly -DeleteFile $delete } |
            Should -Throw
        @($deleted) | Should -Be @((Join-Path 'home' 'auth.json'))
    }

    It 'runs the default seams without creating a file' {
        # The source is missing, the destination folder is missing, and the deleted file is absent.
        Mock Test-Path { $false }
        $missingHome = Join-Path $script:Synthetic 'missing-home'
        { Restore-CodexChildIsolatedAuth -HomePath $missingHome -OriginalAuthPath (Join-Path $missingHome 'source.json') } | Should -Throw
        $openSource = { param([string] $Path) [System.IO.MemoryStream]::new([byte[]](1)) }
        { Restore-CodexChildIsolatedAuth -HomePath $missingHome -OriginalAuthPath 'auth.json' -OpenSource $openSource } | Should -Throw

        $script:TestPathCalls = 0
        Mock Test-Path { $script:TestPathCalls++; $script:TestPathCalls -gt 1 }
        $openReadOnly = { param([string] $Path) [System.IO.MemoryStream]::new([byte[]]@(), $false) }
        { Restore-CodexChildIsolatedAuth -HomePath $PSScriptRoot -OriginalAuthPath 'auth.json' -OpenSource $openSource -OpenDestination $openReadOnly } | Should -Throw
        $script:TestPathCalls | Should -Be 2 -Because 'the default delete ran only after the partial-copy check'
    }

    It 'leaves auth and home in place when nothing exists or under -WhatIf' {
        Mock Test-Path { $false }
        { Remove-CodexChildIsolatedAuth -HomePath 'home' } | Should -Not -Throw
        Mock Test-Path { $true }
        { Remove-CodexChildIsolatedAuth -HomePath 'home' -WhatIf } | Should -Not -Throw
        { Remove-CodexChildIsolatedHome -HomePath (Join-Path (Get-CodexChildAuthorityRoot) 'key/wave/launch') -WhatIf } | Should -Not -Throw
    }

    It 'refuses to remove a home outside the launcher authority' {
        { Remove-CodexChildIsolatedHome -HomePath (Join-Path $script:Synthetic 'elsewhere') } | Should -Throw '*outside launcher authority*'
    }
}
