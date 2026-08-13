#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'PowerShell attribution batch 6' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:CoverageSettingsPath = Join-Path $script:RepoRoot `
            'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
        $script:RuntimePaths = @(
            '.codex/scripts/codex-child-launch-persistence.ps1'
            '.codex/scripts/codex-child-launch-runtime.ps1'
            '.codex/scripts/epic-child-launch-contract.ps1'
        )
        foreach ($runtimePath in $script:RuntimePaths) {
            . (Join-Path $script:RepoRoot $runtimePath)
        }

        function Get-Batch6Receipt {
            return [pscustomobject]@{
                receipt_path = 'receipt.json'; state = ''; resume_started_at = ''
                expires_at = ''; codex_session_id = ''; session_bound_at = ''
                exit_code = $null; completed_at = ''; failure_reason = ''; failed_at = ''
            }
        }

        function Get-Batch6FakeProcess {
            param(
                [string] $OutputLine = '{"thread_id":"session-1"}',
                [bool] $StartResult = $true,
                [int] $ExitCode = 0
            )
            $standardInput = [pscustomobject]@{ Written = ''; Closed = $false }
            $standardInput | Add-Member -MemberType ScriptMethod -Name Write -Value {
                param([string] $Value)
                $this.Written += $Value
            }
            $standardInput | Add-Member -MemberType ScriptMethod -Name Close -Value {
                $this.Closed = $true
            }

            $standardOutput = [pscustomobject]@{
                FirstLine = $OutputLine
                ReadCount = 0
                Tail      = 'tail-output'
            }
            $standardOutput | Add-Member -MemberType ScriptMethod -Name ReadLineAsync -Value {
                $this.ReadCount++
                return [System.Threading.Tasks.Task]::FromResult([string]$this.FirstLine)
            }
            $standardOutput | Add-Member -MemberType ScriptMethod -Name ReadToEndAsync -Value {
                return [System.Threading.Tasks.Task]::FromResult([string]$this.Tail)
            }

            $standardError = [pscustomobject]@{ Value = 'error-output' }
            $standardError | Add-Member -MemberType ScriptMethod -Name ReadToEndAsync -Value {
                return [System.Threading.Tasks.Task]::FromResult([string]$this.Value)
            }

            $process = [pscustomobject]@{
                StartInfo      = $null
                HasExited      = $false
                StartResult    = $StartResult
                Killed         = $false
                StandardInput  = $standardInput
                StandardOutput = $standardOutput
                StandardError  = $standardError
                ExitCode       = $ExitCode
                Id             = 42
            }
            $process | Add-Member -MemberType ScriptMethod -Name Start -Value {
                return [bool]$this.StartResult
            }
            $process | Add-Member -MemberType ScriptMethod -Name Kill -Value {
                param([bool] $EntireTree)
                $this.Killed = $EntireTree
                $this.HasExited = $true
            }
            $process | Add-Member -MemberType ScriptMethod -Name WaitForExitAsync -Value {
                return [System.Threading.Tasks.Task]::CompletedTask
            }
            $process | Add-Member -MemberType ScriptMethod -Name WaitForExit -Value { }
            return $process
        }
    }

    It 'registers <RuntimePath> for attributable coverage' -ForEach @(
        @{ RuntimePath = '.codex/scripts/codex-child-launch-persistence.ps1' }
        @{ RuntimePath = '.codex/scripts/codex-child-launch-runtime.ps1' }
        @{ RuntimePath = '.codex/scripts/epic-child-launch-contract.ps1' }
    ) {
        $settings = Get-Content -LiteralPath $script:CoverageSettingsPath -Raw

        $settings | Should -Match ([regex]::Escape("'$RuntimePath'"))
    }

    It 'serializes schedule identity through the injected persistence seam' {
        $captured = $null
        Write-CodexChildScheduleStatusCore `
            -Path 'status.json' `
            -ScheduleKind 'wave' `
            -ScheduleId 'wave-1' `
            -State 'active' `
            -Statuses @('one') `
            -WriteStatus { param($Path, $Value) $script:captured = @($Path, $Value) }

        $script:captured[0] | Should -BeExactly 'status.json'
        $script:captured[1].wave_id | Should -BeExactly 'wave-1'
        $script:captured[1].launches | Should -Contain 'one'
    }

    It 'bounds available launch capacity at zero and queued work' {
        Get-CodexChildAvailableLaunchCount -Maximum 4 -RunningCount 4 -QueuedCount 3 |
            Should -Be 0
        Get-CodexChildAvailableLaunchCount -Maximum 4 -RunningCount 1 -QueuedCount 2 |
            Should -Be 2
    }

    It 'derives stable epic feature keys and finds exact checkpoint entries' {
        $feature = [pscustomobject]@{ issue_num = 467; feature_folder = 'feature-467' }
        Get-CodexChildFeatureKey -Feature $feature | Should -Be "467`nfeature-467"
        $checkpoint = [pscustomobject]@{ features = @($feature) }
        $entry = [pscustomobject]@{ issue_num = 467; feature_folder = 'feature-467' }

        Find-CodexChildFeature -Checkpoint $checkpoint -Entry $entry | Should -Be $feature
        $entry.feature_folder = 'other'
        Find-CodexChildFeature -Checkpoint $checkpoint -Entry $entry | Should -BeNullOrEmpty
    }

    It 'writes create-new JSON through injected in-memory boundaries' {
        $script:Batch6Directory = ''
        $script:Batch6Memory = [System.IO.MemoryStream]::new()
        Write-CodexChildJsonCreateNewCore `
            -Path 'memory/receipt.json' `
            -Value ([ordered]@{ value = 1 }) `
            -EnsureDirectory { param($path) $script:Batch6Directory = $path } `
            -OpenFile { $script:Batch6Memory }
        $script:Batch6Directory | Should -Be 'memory'
        [System.Text.Encoding]::UTF8.GetString($script:Batch6Memory.ToArray()) |
            Should -Match '"value"'
    }

    It 'performs atomic persistence and cleanup through injected boundaries' {
        $script:Batch6Created = ''
        $script:Batch6Moved = @()
        $script:Batch6Deleted = ''
        Write-CodexChildJsonAtomicCore `
            -Path (Join-Path $script:RepoRoot 'artifacts/status.json') `
            -Value ([ordered]@{ state = 'active' }) `
            -CreateNew {
            param($path, $value)
            $value.state | Should -Be 'active'
            $script:Batch6Created = $path
        } `
            -MoveFile {
            param($source, $destination)
            $script:Batch6Moved = @($source, $destination)
        } `
            -PathExists { $true } `
            -DeleteFile { param($path) $script:Batch6Deleted = $path }
        $script:Batch6Created | Should -Match '\.tmp\.'
        $script:Batch6Moved[0] | Should -Be $script:Batch6Created
        $script:Batch6Deleted | Should -Be $script:Batch6Created
    }

    It 'initializes semantic locks and reports lock acquisition failures' {
        $memory = [System.IO.MemoryStream]::new()
        $lock = Enter-CodexChildScheduleLockCore `
            -Path 'lock' -ScheduleKind 'batch' -ErrorPrefix 'BATCH6' `
            -OpenLock { $memory }
        [System.Text.Encoding]::UTF8.GetString($memory.ToArray()) | Should -Match 'pid='
        $lock.Dispose()
        { Enter-CodexChildScheduleLockCore `
                -Path 'lock' -ScheduleKind 'batch' -ErrorPrefix 'BATCH6' `
                -OpenLock { throw 'held' } } | Should -Throw '*lock is already held*'
    }

    It 'rejects authority paths inside repository or another Git repository' {
        $outside = Join-Path (Split-Path $script:RepoRoot -Parent) 'authority-root'
        { Assert-CodexChildAuthorityOutsideRepositoryCore `
                -AuthorityPath $script:RepoRoot `
                -RepositoryRoot $script:RepoRoot `
                -ErrorPrefix 'BATCH6' `
                -ResolveExistingAncestor { throw 'not expected' } `
                -IsInsideGit { $false } } | Should -Throw '*inside RepositoryRoot*'
        { Assert-CodexChildAuthorityOutsideRepositoryCore `
                -AuthorityPath $outside `
                -RepositoryRoot $script:RepoRoot `
                -ErrorPrefix 'BATCH6' `
                -ResolveExistingAncestor { $outside } `
                -IsInsideGit { $true } } | Should -Throw '*inside a Git repository*'
        { Assert-CodexChildAuthorityOutsideRepositoryCore `
                -AuthorityPath $outside `
                -RepositoryRoot $script:RepoRoot `
                -ErrorPrefix 'BATCH6' `
                -ResolveExistingAncestor { $outside } `
                -IsInsideGit { $false } } | Should -Not -Throw
    }

    It 'persists every receipt state through the injected writer' {
        $now = [datetimeoffset]'2026-08-12T12:00:00Z'
        foreach ($case in @(
                @{ State = 'launching'; Session = ''; Exit = $null; Failure = '' }
                @{ State = 'active'; Session = 'session-1'; Exit = $null; Failure = '' }
                @{ State = 'completed'; Session = ''; Exit = 0; Failure = '' }
                @{ State = 'failed'; Session = ''; Exit = 3; Failure = 'failure' }
            )) {
            $receipt = Get-Batch6Receipt
            $script:Batch6WrittenReceipt = $null
            Set-CodexChildReceiptStateCore `
                -Receipt $receipt `
                -State $case.State `
                -SessionId $case.Session `
                -ExitCode $case.Exit `
                -FailureReason $case.Failure `
                -ErrorPrefix 'BATCH6' `
                -Now $now `
                -WriteReceipt {
                param($path, $value)
                $path | Should -Be 'receipt.json'
                $script:Batch6WrittenReceipt = $value
            } `
                -Confirm:$false
            $script:Batch6WrittenReceipt.state | Should -Be $case.State
        }
        { Set-CodexChildReceiptStateCore `
                -Receipt (Get-Batch6Receipt) `
                -State active `
                -ErrorPrefix 'BATCH6' `
                -WriteReceipt { } `
                -Confirm:$false } | Should -Throw '*requires a session id*'
    }

    It 'creates completed and failed terminal status entries' {
        foreach ($exitCode in @(0, 2)) {
            $receipt = [pscustomobject]@{
                completed_at = 'completed'; failed_at = 'failed'
            }
            $child = [pscustomobject]@{
                Process = [pscustomobject]@{ ExitCode = $exitCode; Id = 42 }
                SessionId = 'session-1'; BasePath = 'artifacts/launch-1'
                Receipt = $receipt
            }
            $status = Get-CodexChildTerminalStatusEntryCore `
                -Child $child `
                -ReceiptPath "receipt'path.json" `
                -ResumeScriptPath "resume'script.ps1"
            $status.state | Should -Be $(if ($exitCode -eq 0) { 'completed' } else { 'failed' })
            $status.resume_command | Should -Match "''"
        }
    }

    It 'extracts session identifiers and rejects malformed event JSON' {
        Get-CodexChildSessionIdCore `
            -JsonLines @(' ', '{"payload":{"session_id":"session-1"}}') `
            -ErrorPrefix 'BATCH6' | Should -Be 'session-1'
        Get-CodexChildSessionIdCore `
            -JsonLines @('{"value":1}') `
            -ErrorPrefix 'BATCH6' | Should -Be ''
        { Get-CodexChildSessionIdCore -JsonLines @('{') -ErrorPrefix 'BATCH6' } |
            Should -Throw '*malformed JSON*'
    }

    It 'reads sealed JSON from BOM and rejects invalid byte sequences' {
        $jsonBytes = [System.Text.Encoding]::UTF8.GetBytes('{"value":1}')
        $bomBytes = [byte[]](@(0xEF, 0xBB, 0xBF) + @($jsonBytes))
        $sealed = Get-CodexChildSealedJsonFileCore `
            -Path 'memory/spec.json' `
            -Name 'spec' `
            -ErrorPrefix 'BATCH6' `
            -HoldOpen `
            -OpenFile { [System.IO.MemoryStream]::new($bomBytes) }
        $sealed.Value.value | Should -Be 1
        $sealed.Stream | Should -Not -BeNullOrEmpty
        $sealed.Stream.Dispose()
        { Get-CodexChildSealedJsonFileCore `
                -Path 'memory/spec.json' `
                -Name 'spec' `
                -ErrorPrefix 'BATCH6' `
                -OpenFile { [System.IO.MemoryStream]::new([byte[]](0xC3, 0x28)) } } |
            Should -Throw '*not valid UTF-8*'
        { Get-CodexChildSealedJsonFileCore `
                -Path 'memory/spec.json' `
                -Name 'spec' `
                -ErrorPrefix 'BATCH6' `
                -OpenFile {
                [System.IO.MemoryStream]::new([System.Text.Encoding]::UTF8.GetBytes('{'))
            } } | Should -Throw '*malformed JSON*'
    }

    It 'builds deterministic process start information for PowerShell shims' {
        $entry = [pscustomobject]@{ worktree_path = $script:RepoRoot }
        $agentProfile = [pscustomobject]@{
            model = 'gpt-5.6-terra'; model_reasoning_effort = 'high'
            developer_instructions = 'instructions'; skills_config = '[]'
        }
        $receipt = [pscustomobject]@{
            codex_command_path = 'codex.ps1'; launch_id = 'launch-1'
            receipt_path = 'receipt.json'; spec_path = 'spec.json'
            worktree_path = $script:RepoRoot; delegation_id = 'delegation-1'
            execution_context = 'child'; deployment_agent = 'worker'
            model = 'gpt-5.6-terra'; model_reasoning_effort = 'high'
            profile_sha256 = ('a' * 64); codex_home_path = 'C:\codex-home'
        }
        $info = Get-CodexChildProcessStartInfoCore `
            -Entry $entry -AgentProfile $agentProfile -Receipt $receipt `
            -LastMessagePath 'last.txt' -RuntimePermissions 'workspace-write' `
            -EnvironmentPrefix 'CODEX_TEST' -PermissionOverride 'permissions=x' `
            -ProjectsOverride 'projects=x' -ShellOverrides @('shell=a', 'shell=b')
        $info.FileName | Should -Be 'pwsh'
        $info.ArgumentList | Should -Contain '-File'
        $info.Environment['CODEX_TEST_LAUNCH_ID'] | Should -Be 'launch-1'
        $info.Environment['CODEX_HOME'] | Should -Be 'C:\codex-home'
    }

    It 'starts and completes a child process through the injected process factory' {
        $script:Batch6FakeProcess = Get-Batch6FakeProcess
        $script:Batch6ReceiptStates = @()
        $entry = [pscustomobject]@{
            launch_id = 'launch-1'; worktree_path = $script:RepoRoot; prompt = 'prompt'
        }
        $receipt = Get-Batch6Receipt
        $startInfo = [System.Diagnostics.ProcessStartInfo]::new('pwsh')
        $child = Start-CodexChildProcessCore `
            -Entry $entry -Receipt $receipt -ArtifactRoot 'artifacts' `
            -StartInfo $startInfo -SurfaceLabel 'test' -ErrorPrefix 'BATCH6' `
            -SetReceiptState {
            param($value, $state, $session, $exitCode, $failure)
            $null = $value, $exitCode, $failure
            $script:Batch6ReceiptStates += "${state}:$session"
        } `
            -ProcessFactory { $script:Batch6FakeProcess } `
            -Confirm:$false
        $child.SessionId | Should -Be 'session-1'
        $script:Batch6ReceiptStates | Should -Contain 'active:session-1'
        $result = Complete-CodexChildProcessCore -Child $child
        $result.exit_code | Should -Be 0
        $result.output | Should -Match 'tail-output'
        $result.error | Should -Be 'error-output'
    }

    It 'records startup failure through the injected process factory' {
        $script:Batch6FakeProcess = Get-Batch6FakeProcess -StartResult $false
        $script:Batch6FailedState = ''
        { Start-CodexChildProcessCore `
                -Entry ([pscustomobject]@{
                    launch_id = 'launch-1'; worktree_path = $script:RepoRoot; prompt = 'prompt'
                }) `
                -Receipt (Get-Batch6Receipt) `
                -ArtifactRoot 'artifacts' `
                -StartInfo ([System.Diagnostics.ProcessStartInfo]::new('pwsh')) `
                -SurfaceLabel 'test' `
                -ErrorPrefix 'BATCH6' `
                -SetReceiptState {
                param($value, $state, $session, $exitCode, $failure)
                $null = $value, $session, $exitCode, $failure
                $script:Batch6FailedState = $state
            } `
                -ProcessFactory { $script:Batch6FakeProcess } `
                -Confirm:$false } | Should -Throw '*failed during startup*'
        $script:Batch6FailedState | Should -Be 'failed'
    }

    It 'uses default safe persistence boundaries without creating a file' {
        $memory = [System.IO.MemoryStream]::new()
        Write-CodexChildJsonCreateNewCore `
            -Path (Join-Path $script:RepoRoot 'artifacts/in-memory.json') `
            -Value ([ordered]@{ value = 1 }) `
            -OpenFile { $memory }
        [System.Text.Encoding]::UTF8.GetString($memory.ToArray()) |
            Should -Match '"value"'

        Mock Write-CodexChildJsonCreateNewCore { }
        Mock Test-Path { $true }
        Write-CodexChildJsonAtomicCore `
            -Path (Join-Path $script:RepoRoot 'artifacts/nonexistent-status.json') `
            -Value ([ordered]@{ state = 'active' }) `
            -MoveFile { }
        Should -Invoke Write-CodexChildJsonCreateNewCore -Times 1
        Should -Invoke Test-Path -Times 1
    }

    It 'disposes a partially initialized semantic lock stream on failure' {
        $memory = [System.IO.MemoryStream]::new()
        $memory.Dispose()
        { Enter-CodexChildScheduleLockCore `
                -Path 'lock' -ScheduleKind 'batch' -ErrorPrefix 'BATCH6' `
                -OpenLock { $memory } } | Should -Throw '*lock initialization failed*'
    }

    It 'resolves the nearest existing authority ancestor without filesystem writes' {
        $authority = Join-Path (
            Split-Path $script:RepoRoot -Parent
        ) 'nonexistent-authority/child'
        { Assert-CodexChildAuthorityOutsideRepositoryCore `
                -AuthorityPath $authority `
                -RepositoryRoot $script:RepoRoot `
                -ErrorPrefix 'BATCH6' `
                -IsInsideGit { $false } } | Should -Not -Throw
    }
}
