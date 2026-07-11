#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Codex epic-child launcher hardening' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/scripts/launch-epic-child-wave.ps1')
        . (Join-Path $script:RepoRoot '.codex/scripts/resume-epic-child.ps1') -ReceiptPath 'unused'
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-child-worktree-binding.ps1')

        function Get-TestLaunchFeature {
            param([string] $Name, [int] $Issue, [int] $Wave, [string] $Worktree)
            $delegationId = "delegate-$Name"
            $agent = 'orchestrator-c3-elevated'
            $featureFolder = "docs/features/active/$Name"
            return [pscustomobject]@{
                issue_num = $Issue; feature_folder = $featureFolder; wave_number = $Wave
                worktree_path = $Worktree; branch_name = "feature/$Name"; merge_status = 'not_started'
                delegation_receipt    = [pscustomobject]@{
                    delegation_id = $delegationId; feature_folder = $featureFolder
                    issue_num = $Issue; agent_name = $agent
                }
                model_routing_receipt = [pscustomobject]@{
                    delegation_id = $delegationId; deployment_agent = $agent
                    model = 'gpt-5.6-sol'; model_reasoning_effort = 'high'
                    execution_context = 'epic_execution_child'
                }
            }
        }

        function Get-TestLaunchEntry {
            param([Parameter(Mandatory)] $Feature, [string] $Context = 'epic_execution_child')
            return [pscustomobject]@{
                launch_id     = "launch-$(Split-Path ([string]$Feature.feature_folder) -Leaf)"
                delegation_id = [string]$Feature.delegation_receipt.delegation_id
                feature_folder = [string]$Feature.feature_folder; issue_num = $Feature.issue_num
                deployment_agent = 'orchestrator-c3-elevated'; model = 'gpt-5.6-sol'
                model_reasoning_effort = 'high'; permissions = 'orchestrator-workspace'
                execution_context = $Context; worktree_path = [string]$Feature.worktree_path
                branch_name   = [string]$Feature.branch_name
                prompt        = $(if ($Context -eq 'epic_preparation_child') {
                        'Preparation mode: true. Prepare the feature.'
                    } else {
                        'Epic mode: true. epic_feature_folder: sample-epic. integration_branch: epic/sample-integration. PR base branch MUST be epic/sample-integration, not main; pass --base epic/sample-integration to gh pr create.'
                    })
            }
        }

        function Get-TestProfile {
            param([string] $Worktree)
            return [pscustomobject]@{
                name = 'orchestrator-c3-elevated'; model = 'gpt-5.6-sol'
                model_reasoning_effort = 'high'; default_permissions = 'orchestrator-workspace'
                developer_instructions = 'exact'; skills_config = '[]'; worktree_path = $Worktree
                profile_path   = Join-Path $Worktree '.codex/agents/orchestrator-c3-elevated.toml'
                profile_sha256 = ('a' * 64)
            }
        }

        $script:WorktreeA = Join-Path $script:RepoRoot 'worktrees/child-a'
        $script:WorktreeB = Join-Path $script:RepoRoot 'worktrees/child-b'
        $script:FeatureA = Get-TestLaunchFeature -Name child-a -Issue 101 -Wave 1 -Worktree $script:WorktreeA
        $script:FeatureB = Get-TestLaunchFeature -Name child-b -Issue 102 -Wave 1 -Worktree $script:WorktreeB
        $script:EntryA = Get-TestLaunchEntry -Feature $script:FeatureA
        $script:EntryB = Get-TestLaunchEntry -Feature $script:FeatureB
        $script:Checkpoint = [pscustomobject]@{
            integration_branch = 'epic/sample-integration'; epic_feature_folder = 'sample-epic'
            max_parallel_features = 4; features = @($script:FeatureA, $script:FeatureB)
        }
        $script:Spec = [pscustomobject]@{
            schema_version = 1; checkpoint_kind = 'epic-orchestrator'; wave_id = 'wave-1'
            wave_number = 1; max_parallel_features = 4; integration_branch = 'epic/sample-integration'
            checkpoint_path = 'artifacts/orchestration/epic-orchestrator-state.json'
            launches        = @($script:EntryA, $script:EntryB)
        }
        $script:Profiles = @{}
        foreach ($item in @(@($script:WorktreeA, (Get-TestProfile $script:WorktreeA)),
                @($script:WorktreeB, (Get-TestProfile $script:WorktreeB)))) {
            $key = Get-CodexChildProfileKey -WorktreePath $item[0] `
                -AgentName 'orchestrator-c3-elevated' -RepositoryRoot $script:RepoRoot
            $script:Profiles[$key] = $item[1]
        }
        $script:Branches = @{
            $script:WorktreeA = 'feature/child-a'; $script:WorktreeB = 'feature/child-b'
        }
    }

    It 'keys the same generated profile independently for each exact worktree' {
        $keyA = Get-CodexChildProfileKey -WorktreePath $script:WorktreeA `
            -AgentName 'orchestrator-c3-elevated' -RepositoryRoot $script:RepoRoot
        $keyB = Get-CodexChildProfileKey -WorktreePath $script:WorktreeB `
            -AgentName 'orchestrator-c3-elevated' -RepositoryRoot $script:RepoRoot

        $keyA | Should -Not -BeExactly $keyB
        $script:Profiles[$keyA].profile_path | Should -Match 'child-a'
        $script:Profiles[$keyB].profile_path | Should -Match 'child-b'
        Test-CodexChildLaunchSpec -Spec $script:Spec -Checkpoint $script:Checkpoint `
            -RepositoryRoot $script:RepoRoot -ProfilesByKey $script:Profiles `
            -LiveBranchesByWorktree $script:Branches | Should -BeNullOrEmpty
    }

    It 'requires lowercase artifact identifiers to prevent case-only filesystem collisions' {
        $entry = $script:EntryA.PSObject.Copy(); $entry.launch_id = 'Launch-child-a'
        $spec = $script:Spec.PSObject.Copy(); $spec.wave_id = 'Wave-1'; $spec.launches = @($entry)

        $errors = Test-CodexChildLaunchSpec -Spec $spec -Checkpoint $script:Checkpoint `
            -RepositoryRoot $script:RepoRoot -ProfilesByKey $script:Profiles `
            -LiveBranchesByWorktree $script:Branches
        $errors | Should -Contain 'wave_id must be a safe lowercase artifact identifier.'
        $errors | Should -Contain 'launch_id must be a safe lowercase artifact identifier.'
    }

    It 'rejects a partial execution wave but excludes terminal features' {
        $spec = $script:Spec.PSObject.Copy(); $spec.launches = @($script:EntryA)
        $errors = Test-CodexChildLaunchSpec -Spec $spec -Checkpoint $script:Checkpoint `
            -RepositoryRoot $script:RepoRoot -ProfilesByKey $script:Profiles `
            -LiveBranchesByWorktree $script:Branches
        $errors | Should -Contain 'launches must cover every eligible checkpoint feature exactly once.'

        $terminal = $script:FeatureB.PSObject.Copy(); $terminal.merge_status = 'merged'
        $checkpoint = $script:Checkpoint.PSObject.Copy(); $checkpoint.features = @($script:FeatureA, $terminal)
        Test-CodexChildLaunchSpec -Spec $spec -Checkpoint $checkpoint -RepositoryRoot $script:RepoRoot `
            -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches |
            Should -BeNullOrEmpty
    }

    It 'requires every planner feature once regardless of execution wave' {
        $featureA = $script:FeatureA.PSObject.Copy(); $featureA.wave_number = 1
        $featureB = $script:FeatureB.PSObject.Copy(); $featureB.wave_number = 4
        foreach ($feature in @($featureA, $featureB)) {
            $feature.model_routing_receipt.execution_context = 'epic_preparation_child'
        }
        $entryA = Get-TestLaunchEntry -Feature $featureA -Context epic_preparation_child
        $spec = $script:Spec.PSObject.Copy(); $spec.checkpoint_kind = 'epic-planner'
        $spec.checkpoint_path = 'artifacts/orchestration/epic-planner-state.json'; $spec.wave_number = 0
        $spec.launches = @($entryA)
        $checkpoint = $script:Checkpoint.PSObject.Copy(); $checkpoint.features = @($featureA, $featureB)

        Test-CodexChildLaunchSpec -Spec $spec -Checkpoint $checkpoint -RepositoryRoot $script:RepoRoot `
            -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches |
            Should -Contain 'launches must cover every eligible checkpoint feature exactly once.'
    }

    It 'requires conjunctive delegation and model receipt identity' {
        $feature = $script:FeatureA.PSObject.Copy()
        $feature.model_routing_receipt = $script:FeatureA.model_routing_receipt.PSObject.Copy()
        $feature.model_routing_receipt.delegation_id = 'different'
        $checkpoint = $script:Checkpoint.PSObject.Copy(); $checkpoint.features = @($feature)
        $spec = $script:Spec.PSObject.Copy(); $spec.launches = @($script:EntryA)

        Test-CodexChildLaunchSpec -Spec $spec -Checkpoint $checkpoint -RepositoryRoot $script:RepoRoot `
            -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches |
            Should -Contain "launch 'launch-child-a' has no matching model-routing receipt."
    }

    It 'rejects non-active or placeholder feature-folder identities' {
        $feature = $script:FeatureA.PSObject.Copy()
        $feature.feature_folder = 'docs/features/potential/pending'
        $feature.delegation_receipt = $script:FeatureA.delegation_receipt.PSObject.Copy()
        $feature.delegation_receipt.feature_folder = $feature.feature_folder
        $entry = $script:EntryA.PSObject.Copy(); $entry.feature_folder = $feature.feature_folder
        $checkpoint = $script:Checkpoint.PSObject.Copy(); $checkpoint.features = @($feature)
        $spec = $script:Spec.PSObject.Copy(); $spec.launches = @($entry)

        Test-CodexChildLaunchSpec -Spec $spec -Checkpoint $checkpoint -RepositoryRoot $script:RepoRoot `
            -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches |
            Should -Contain "launch 'launch-child-a' requires a final docs/features/active feature_folder without placeholders."
        foreach ($path in @(
                'docs/features/active/.', 'docs/features/active/..', 'docs/features/active/none',
                'docs/features/active/pending-child-123', 'docs/features/active/draft_feature'
            )) {
            Test-CodexChildActiveFeatureFolder -Path $path | Should -BeFalse
        }
    }

    It 'rejects duplicate checkpoint feature identities before exactly-once coverage' {
        $duplicate = $script:FeatureA.PSObject.Copy(); $duplicate.branch_name = 'feature/different'
        $checkpoint = $script:Checkpoint.PSObject.Copy(); $checkpoint.features = @($script:FeatureA, $duplicate)
        $spec = $script:Spec.PSObject.Copy(); $spec.launches = @($script:EntryA)

        Test-CodexChildLaunchSpec -Spec $spec -Checkpoint $checkpoint -RepositoryRoot $script:RepoRoot `
            -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches |
            Should -Contain 'checkpoint features must use unique issue_num and feature_folder identities.'
    }

    It 'rejects a string-shaped issue number even when every binding repeats it' {
        $feature = $script:FeatureA.PSObject.Copy(); $feature.issue_num = '101'
        $feature.delegation_receipt = $script:FeatureA.delegation_receipt.PSObject.Copy()
        $feature.delegation_receipt.issue_num = '101'
        $entry = $script:EntryA.PSObject.Copy(); $entry.issue_num = '101'
        $checkpoint = $script:Checkpoint.PSObject.Copy(); $checkpoint.features = @($feature)
        $spec = $script:Spec.PSObject.Copy(); $spec.launches = @($entry)

        Test-CodexChildLaunchSpec -Spec $spec -Checkpoint $checkpoint -RepositoryRoot $script:RepoRoot `
            -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches |
            Should -Contain "launch 'launch-child-a' requires a final positive integer issue_num."
    }

    It 'requires an active unexpired receipt bound to the exact session' {
        $receipt = [pscustomobject]@{
            schema_version = 2; state = 'active'; codex_session_id = 'session-a'
            session_bound_at = '2026-07-10T12:00:00Z'; expires_at = '2026-07-12T12:00:00Z'
            launch_id = 'launch-a'; delegation_id = 'delegate-a'; feature_folder = 'child-a'
            deployment_agent = 'orchestrator-c3'; model = 'gpt-5.6-terra'
            model_reasoning_effort = 'high'; execution_context = 'epic_execution_child'
            worktree_path = $script:WorktreeA; branch_name = 'feature/child-a'
            receipt_path = 'C:\receipt.json'; spec_path = 'C:\spec.json'
            status_path = 'C:\status.json'; codex_home_path = 'C:\isolated'
            checkpoint_kind = 'epic-orchestrator'; wave_lock_path = 'C:\wave.lock'
            profile_path = 'C:\profile.toml'; trusted_repository_root = $script:RepoRoot
        }
        $now = [datetimeoffset]'2026-07-11T12:00:00Z'

        Get-CodexChildActiveReceiptErrorList -Receipt $receipt -ExpectedSessionId session-a -Now $now |
            Should -BeNullOrEmpty
        $jsonRoundTrip = $receipt | ConvertTo-Json -Depth 10 | ConvertFrom-Json
        Get-CodexChildActiveReceiptErrorList -Receipt $jsonRoundTrip -ExpectedSessionId session-a -Now $now |
            Should -BeNullOrEmpty
        Get-CodexChildActiveReceiptErrorList -Receipt $receipt -ExpectedSessionId session-b -Now $now |
            Should -Contain 'launch receipt session id is missing or does not match the active Codex session.'
        Get-CodexChildActiveReceiptErrorList -Receipt $receipt -ExpectedSessionId SESSION-A -Now $now |
            Should -Contain 'launch receipt session id is missing or does not match the active Codex session.'
        Get-CodexChildActiveReceiptErrorList -Receipt $receipt -ExpectedSessionId session-a `
            -Now ([datetimeoffset]'2026-07-13T12:00:00Z') |
            Should -Contain 'launch receipt session timestamps are invalid or expired.'
    }

    It 'uses inline project trust, ignores user config, and denies Codex install paths' {
        $receipt = [pscustomobject]@{
            launch_id = 'launch-a'; receipt_path = 'C:\receipt.json'; spec_path = 'C:\spec.json'
            worktree_path = $script:WorktreeA; delegation_id = 'delegate-a'
            deployment_agent = 'orchestrator-c3-elevated'; model = 'gpt-5.6-sol'
            model_reasoning_effort = 'high'; execution_context = 'epic_execution_child'
            profile_sha256 = ('a' * 64); codex_command_path = 'codex.exe'
            codex_denied_paths = @('C:\Tools\codex.exe', 'C:\Tools\node_modules\@openai\codex')
            codex_home_path    = 'C:\isolated'
        }
        $info = Get-CodexChildProcessStartInfo -Entry $script:EntryA `
            -AgentProfile $script:Profiles[(Get-CodexChildProfileKey -WorktreePath $script:WorktreeA `
                -AgentName 'orchestrator-c3-elevated' -RepositoryRoot $script:RepoRoot)] `
            -Receipt $receipt -LastMessagePath 'C:\last.txt'
        $arguments = [string[]]$info.ArgumentList

        $arguments | Should -Contain '--ignore-user-config'
        $arguments | Should -Contain 'windows.sandbox="elevated"'
        ($arguments -join "`n") | Should -Match 'projects=\{.*trust_level='
        ($arguments -join "`n") | Should -Match 'permissions\.epic-child-workspace=.*deny'
        ($arguments -join "`n") | Should -Not -Match '\*\*'
        $arguments | Should -Not -Contain '--dangerously-bypass-approvals-and-sandbox'
    }

    It 'builds resume with the exact sealed session and runtime controls' {
        $context = [pscustomobject]@{
            Receipt      = [pscustomobject]@{
                worktree_path = $script:WorktreeA; model = 'gpt-5.6-sol'
                model_reasoning_effort = 'high'; codex_denied_paths = @('C:\codex.exe')
                codex_home_path = 'C:\isolated'
                codex_session_id = 'session-a'; launch_id = 'launch-a'
                receipt_path = 'C:\receipt.json'; spec_path = 'C:\spec.json'
                delegation_id = 'delegate-a'; execution_context = 'epic_execution_child'
                deployment_agent = 'orchestrator-c3-elevated'; profile_sha256 = ('a' * 64)
            }
            Profile      = Get-TestProfile $script:WorktreeA
            CodexRuntime = [pscustomobject]@{ CommandPath = 'codex.exe'; DeniedPaths = @('C:\codex.exe') }
        }
        $info = Get-CodexChildResumeStartInfo -Context $context -ResumePrompt continue -OutputPath 'C:\last.txt'
        $arguments = [string[]]$info.ArgumentList

        $arguments[0..1] | Should -Be @('exec', 'resume')
        $arguments | Should -Contain 'session-a'
        $arguments | Should -Contain '--ignore-user-config'
        @($arguments | Where-Object { $_ -ceq '-C' }) | Should -BeNullOrEmpty
        $info.WorkingDirectory | Should -BeExactly $script:WorktreeA
        $info.Environment['CODEX_EPIC_CHILD_SESSION_ID'] | Should -BeExactly 'session-a'
    }

    It 'uses CreateNew receipts, an exclusive wave lock, and the checked-in resume wrapper' {
        $launcher = Get-Content -Raw (Join-Path $script:RepoRoot '.codex/scripts/launch-epic-child-wave.ps1')
        $persistence = Get-Content -Raw (Join-Path $script:RepoRoot '.codex/scripts/epic-child-persistence-runtime.ps1')
        $manifest = Get-Content -Raw (Join-Path $script:RepoRoot `
                'extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json')

        $persistence | Should -Match 'FileMode\]::CreateNew'
        $persistence | Should -Match 'FileShare\]::None'
        $launcher | Should -Match 'resume-epic-child\.ps1'
        $launcher | Should -Not -Match 'resume_command\s*=\s*"codex exec'
        $launcher | Should -Match 'launch spec or checkpoint changed after validation'
        $launcher | Should -Match 'cleanup failures:'
        $manifest | Should -Match 'epic-child-launch-runtime\.ps1'
        $manifest | Should -Match 'epic-child-persistence-runtime\.ps1'
        $manifest | Should -Match 'epic-child-sandbox-preflight\.ps1'
        $manifest | Should -Match 'resume-epic-child\.ps1'
        $firstRoot = Join-Path $script:RepoRoot 'artifacts/orchestration/epic-child-launches/caller-wave-a'
        $secondRoot = Join-Path $script:RepoRoot 'artifacts/orchestration/epic-child-launches/caller-wave-b'
        Get-CodexChildSemanticWaveLockPath -Spec $script:Spec -ArtifactRoot $firstRoot |
            Should -BeExactly (Get-CodexChildSemanticWaveLockPath -Spec $script:Spec -ArtifactRoot $secondRoot)

        $receiptState = [pscustomobject]@{ Exists = $false }
        $openReceipt = {
            param([string] $Path)
            $null = $Path
            if ($receiptState.Exists) { throw "already exists: $Path" }
            $receiptState.Exists = $true
            return [System.IO.MemoryStream]::new()
        }.GetNewClosure()
        Write-CodexChildJsonCreateNew -Path 'memory/receipt.json' -Value @{ value = 1 } `
            -EnsureDirectory { param([string] $Path) $null = $Path } -OpenFile $openReceipt
        { Write-CodexChildJsonCreateNew -Path 'memory/receipt.json' -Value @{ value = 2 } `
                -EnsureDirectory { param([string] $Path) $null = $Path } -OpenFile $openReceipt } | Should -Throw

        $lockState = [pscustomobject]@{ Held = $false }
        $openLock = {
            param([string] $Path)
            if ($lockState.Held) { throw "held: $Path" }
            $lockState.Held = $true
            return [System.IO.MemoryStream]::new()
        }.GetNewClosure()
        $firstLock = Enter-CodexChildWaveLock -Path 'memory/wave.lock' -OpenLock $openLock
        { Enter-CodexChildWaveLock -Path 'memory/wave.lock' -OpenLock $openLock } |
            Should -Throw '*semantic wave lock is already held*'
        $firstLock.Dispose()

        $jsonBytes = [System.Text.Encoding]::UTF8.GetBytes('{"schema_version":1}')
        $openJson = {
            param([string] $Path)
            $null = $Path
            return [System.IO.MemoryStream]::new($jsonBytes, $false)
        }.GetNewClosure()
        $seal = Get-CodexChildSealedJsonFile -Path 'memory/spec.json' -Name 'test spec' -OpenFile $openJson
        $seal.Sha256 | Should -BeExactly (
            [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($jsonBytes)).ToLowerInvariant()
        )
    }

    It 'preflights the elevated Windows sandbox from an isolated CODEX_HOME' {
        $probePath = Join-Path $script:RepoRoot 'AGENTS.md'
        $info = Get-CodexChildSandboxProbeStartInfo -WorktreePath $script:WorktreeA `
            -CodexHomePath 'C:\isolated' -CommandPath 'codex.exe' `
            -DeniedPaths @($probePath, 'C:\Tools\codex.exe') -DeniedProbePath $probePath
        $arguments = [string[]]$info.ArgumentList
        $runtime = Get-Content -Raw (Join-Path $script:RepoRoot '.codex/scripts/epic-child-launch-runtime.ps1')
        $sandbox = Get-Content -Raw (Join-Path $script:RepoRoot '.codex/scripts/epic-child-sandbox-preflight.ps1')

        $arguments[0] | Should -BeExactly 'sandbox'
        $arguments | Should -Contain 'epic-child-workspace'
        $arguments | Should -Contain 'windows.sandbox="elevated"'
        $info.Environment['CODEX_HOME'] | Should -BeExactly 'C:\isolated'
        $sandbox | Should -Match 'WaitForExit\(15000\)'
        $sandbox | Should -Match 'Kill\(\$true\)'
        ($arguments -join "`n") | Should -Match 'Get-Item -LiteralPath \$args\[1\]'
        $runtime | Should -Match 'LocalApplicationData'
        $runtime | Should -Match 'creation failed and cleanup also failed'
        $runtime | Should -Match 'final active feature_folder must exist in RepositoryRoot and child HEAD'
    }

    It 'kills a sandbox probe that exceeds the bounded timeout' {
        $reader = [pscustomobject]@{}
        $reader | Add-Member -MemberType ScriptMethod -Name ReadToEndAsync -Value {
            [System.Threading.Tasks.Task]::FromResult('')
        }
        $fake = [pscustomobject]@{
            StartInfo = $null; StandardOutput = $reader; StandardError = $reader
            ExitCode = 0; WaitCount = 0; Killed = $false
        }
        $fake | Add-Member -MemberType ScriptMethod -Name Start -Value { return $true }
        $fake | Add-Member -MemberType ScriptMethod -Name WaitForExit -Value {
            param([int] $Milliseconds)
            $null = $Milliseconds
            $this.WaitCount++
            return $this.WaitCount -gt 1
        }
        $fake | Add-Member -MemberType ScriptMethod -Name Kill -Value {
            param([bool] $EntireProcessTree)
            $this.Killed = $EntireProcessTree
        }
        $factory = { return $fake }.GetNewClosure()

        { Invoke-CodexChildSandboxProbe -StartInfo ([System.Diagnostics.ProcessStartInfo]::new()) `
                -NewProcess $factory } | Should -Throw '*timed out after 15 seconds*'
        $fake.Killed | Should -BeTrue
    }

    It 'removes an owned isolated home when authentication copy fails' {
        $state = [pscustomobject]@{ Exists = $false; Deleted = $false }
        $pathExists = { param([string] $Path) $null = $Path; return $state.Exists }.GetNewClosure()
        $create = { param([string] $Path) $null = $Path; $state.Exists = $true }.GetNewClosure()
        $copy = { param([string] $Source, [string] $Destination) $null = $Source, $Destination; throw 'copy failed' }
        $delete = {
            param([string] $Path)
            $null = $Path
            $state.Exists = $false; $state.Deleted = $true
        }.GetNewClosure()

        { New-CodexChildIsolatedHome -RepositoryRoot $script:RepoRoot -WaveId wave-1 `
                -LaunchId launch-a -OriginalAuthPath 'memory/auth.json' -PathExists $pathExists `
                -CreateDirectory $create -CopyFile $copy -DeleteDirectory $delete `
                -AssertAuthority { param([string] $Authority, [string] $Repository) $null = $Authority, $Repository } -Confirm:$false } |
            Should -Throw '*copy failed*'
        $state.Deleted | Should -BeTrue

        $outside = Join-Path ([System.IO.Path]::GetTempPath()) 'codex-authority-audit'
        { Assert-CodexChildAuthorityOutsideRepository -AuthorityPath $outside `
                -RepositoryRoot $script:RepoRoot -ResolveExistingAncestor { param([string] $Path) $Path } `
                -IsInsideGit { param([string] $Path) $null = $Path; return $true } } |
            Should -Throw '*authority resolves inside a Git repository*'
    }

    It 'treats completed receipt evidence as durable while active authorization expires' {
        $terminal = [pscustomobject]@{
            schema_version = 2; state = 'completed'; codex_session_id = 'session-a'
            exit_code = 0; session_bound_at = '2026-07-10T11:59:00Z'
            completed_at = '2026-07-10T12:00:00Z'; expires_at = '2026-07-10T13:00:00Z'
        }

        Get-CodexChildTerminalReceiptErrorList -Receipt $terminal | Should -BeNullOrEmpty
        $failed = [pscustomobject]@{
            schema_version = 2; state = 'failed'; codex_session_id = 'session-a'
            exit_code = 1; session_bound_at = '2026-07-10T11:59:00Z'
            failed_at = '2026-07-10T12:00:00Z'; expires_at = '2026-07-10T13:00:00Z'
        }
        Get-CodexChildTerminalReceiptErrorList -Receipt $failed | Should -BeNullOrEmpty
    }

    It 'repeats the exact terminal receipt timestamp under the matching status key' {
        $child = [pscustomobject]@{
            Process = [pscustomobject]@{ ExitCode = 0; Id = 123 }
            Entry   = [pscustomobject]@{ worktree_path = 'C:\worktree' }
            SessionId = 'session-a'; BasePath = 'C:\artifacts\launch-a'
            Receipt = [pscustomobject]@{ completed_at = '2026-07-10T12:00:00Z'; failed_at = '' }
        }
        $completed = Get-CodexChildTerminalStatusEntry -Child $child -ReceiptPath 'C:\artifacts\receipt.json'
        $completed.completed_at | Should -BeExactly $child.Receipt.completed_at
        $completed.Contains('failed_at') | Should -BeFalse

        $child.Process.ExitCode = 7; $child.Receipt.failed_at = '2026-07-10T12:01:00Z'
        $failed = Get-CodexChildTerminalStatusEntry -Child $child -ReceiptPath 'C:\artifacts\receipt.json'
        $failed.failed_at | Should -BeExactly $child.Receipt.failed_at
        $failed.Contains('completed_at') | Should -BeFalse

        $resume = Get-Content -Raw (Join-Path $script:RepoRoot '.codex/scripts/resume-epic-child.ps1')
        $resume | Should -Match '\$processStarted\s+-and\s+-not\s+\$process\.HasExited'
        $resume | Should -Match '\$process\.Kill\(\$true\)'
    }

    It 'denies direct nested Codex execution and requires the payload session id' {
        Test-CodexChildGuardNestedCodexInvocation -Payload ([pscustomobject]@{
                tool_name = 'shell_command'; tool_input = @{ command = 'codex exec task' }
            }) | Should -BeTrue
        Test-CodexChildGuardNestedCodexInvocation -Payload ([pscustomobject]@{
                tool_name = 'shell_command'; tool_input = @{ command = 'git status' }
            }) | Should -BeFalse
    }

    It 'requires same-repository ancestry, a clean worktree, and trusted instruction surfaces' {
        $runtime = Get-Content -Raw (Join-Path $script:RepoRoot '.codex/scripts/epic-child-launch-runtime.ps1')
        $resume = Get-Content -Raw (Join-Path $script:RepoRoot '.codex/scripts/resume-epic-child.ps1')

        $runtime | Should -Match 'git-common-dir'
        $runtime | Should -Match 'merge-base.*--is-ancestor'
        $runtime | Should -Match "hash-object', '--'"
        $runtime | Should -Match 'generated profile bytes differ from child HEAD'
        $runtime | Should -Match "status', '--porcelain=v1', '--untracked-files=all'"
        $runtime | Should -Match "'\.codex'"
        $runtime | Should -Match "'\.agents'"
        $runtime | Should -Match "'AGENTS\.md'"
        $resume | Should -Match 'trusted_surface_objects'
        $resume | Should -Match 'codex_session_id'
    }
}
