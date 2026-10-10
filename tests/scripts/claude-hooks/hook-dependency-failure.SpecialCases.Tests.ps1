#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Special dependency-failure cases of the Claude hooks (issue #786).

.DESCRIPTION
    C1 and C2 prove a nested module or nested dot-source failure is reported as the enclosing
    top-level edge (FR-2.4). C3 proves the merge gate denies when its authorization sibling fails
    to load (the FR-6.3 ordering hazard). C4 proves a hook-level pre-load satisfies the lazy-load
    check of the module that imports it at run time (FR-7.3). C5 and C6 cover the D2 mermaid
    exemption, C7 the validate-bash token (D4), and C8 a SubagentStop validator that sets
    $ErrorActionPreference = 'Stop' when both the helper and a dependency fail (FR-3.3). Hooks run
    through the & route or are dot-sourced inside the It; no test creates, renames, moves, or
    deletes a file.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot '../claude-runtime/HookDependencyGraph.Helpers.ps1')
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path -replace '\\', '/'
    $registrations = @(Get-HookRegistration -ClaudeRoot $repoRoot -CodexRoot $repoRoot | Where-Object { $_.Surface -eq 'claude' -and $_.Hook -ne 'INLINE' })
    $script:LazyRows = foreach ($r in $registrations) {
        foreach ($edge in @(Get-HookDependencyClosure -Registration $r | Where-Object { $_.Runtime -and $_.Kind -eq 'Module' -and $_.LazyFunction -ne 'NONE' })) {
            @{ Hook = $r.Hook; Via = $edge.Via; Module = [IO.Path]::GetFileNameWithoutExtension($edge.Leaf); LazyFunction = $edge.LazyFunction }
        }
    }
    $script:StopRows = foreach ($r in $registrations) {
        $text = Get-Content -LiteralPath (Join-HookGraphPath -Left $repoRoot -Right $r.Hook) -Raw
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($text, [ref]$null, [ref]$null)
        $stop = @($ast.EndBlock.Statements | Where-Object { $_ -is [System.Management.Automation.Language.AssignmentStatementAst] -and $_.Left.Extent.Text -eq '$ErrorActionPreference' -and $_.Right.Extent.Text -eq "'Stop'" }).Count -gt 0
        $edges = @(Get-HookScriptEdge -ScriptText $text -SourcePath $r.Hook | Where-Object { -not $_.Runtime -and -not $_.Conditional -and $_.Leaf -ne 'hook-dependency-guard.ps1' } | Sort-Object Line)
        if ($stop -and $edges.Count -gt 0) { @{ Hook = $r.Hook; Event = $r.Event; Dependency = $edges[0].Leaf; Kind = $edges[0].Kind } }
    }
}

Describe 'Claude hook dependency-failure special cases (issue #786)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path -replace '\\', '/'
        . (Join-Path $PSScriptRoot '../claude-runtime/HookDependencyGraph.Helpers.ps1')
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        if (Get-Command Get-ArtifactFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ArtifactFileContent' -Surface 'Codex' }
        if (Get-Command Get-ChangedLanguageSet -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ChangedLanguageSet' -Surface 'Codex' }
        if (Get-Command Get-CheckpointFileContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-CheckpointFileContent' -Surface 'Codex' }
        if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ChildOrchestratorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicOrchestratorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-JacocoRepoCoverage -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-JacocoRepoCoverage' -Surface 'Codex' }
        if (Get-Command Get-LcovRepoCoverage -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-LcovRepoCoverage' -Surface 'Codex' }
        if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelOrchestratorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorCheckpointContent' -Surface 'Codex' }
        if (Get-Command Get-PrAuthorReceiptContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorReceiptContent' -Surface 'Codex' }
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/hook-payload/HookPayload.psm1') -ErrorAction Stop
        $script:StopPrefix = @{
            '.claude/hooks/validate-feature-review-coverage.ps1' = 'validate-feature-review-coverage:'
            '.claude/hooks/validate-orchestrator-output.ps1'     = 'ORCHESTRATOR_CHECKPOINT_UNRESOLVED:'
            '.claude/hooks/validate-planner-output.ps1'          = 'validate-planner-output:'
            '.claude/hooks/validate-prd-feature-output.ps1'      = 'validate-prd-feature-output:'
        }

        function Invoke-HookProcess {
            # Drives one hook through the & route with stdin and stderr redirected; both restored in finally. A hook exception propagates to the It.
            param([string] $Hook, [string] $HookEvent = 'PreToolUse')
            $stdin = if ($HookEvent -eq 'SubagentStop') { '{"session_id":"c-786","hook_event_name":"SubagentStop"}' } else { '{"session_id":"c-786","hook_event_name":"PreToolUse","tool_name":"Read","tool_input":{"file_path":"README.md"}}' }
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            $stdout = @()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($stdin))
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                $stdout = @(& (Get-HookInvocationPath -Left $script:RepoRoot -Right $Hook))
                $exitCode = $LASTEXITCODE
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
            }
            return [pscustomobject]@{ Stdout = (@($stdout | ForEach-Object { [string]$_ }) -join "`n"); Stderr = $errorWriter.ToString(); ExitCode = $exitCode }
        }

        function Invoke-HookInFreshRunspace {
            # Drives one SubagentStop hook in a new runspace with no enclosing try, as its own pwsh -File process has none: a
            # statement-terminating error inside a catch then ends only that statement. In-process, the It's try would catch it.
            # The helper bootstrap and the named dependency fail through runspace-local Join-Path and Import-Module functions.
            param([string] $Hook, [string] $Dependency, [string] $Kind)
            $failDot = if ($Kind -eq 'Module') { '' } else { $Dependency }
            $failModule = if ($Kind -eq 'Module') { $Dependency } else { '<none>' }
            $driver = @"
param(`$HookPath)
function Join-Path { [CmdletBinding()] param([Parameter(Position = 0)] [string] `$Path, [Parameter(Position = 1)] [string] `$ChildPath)
    if (`$ChildPath -eq 'hook-dependency-guard.ps1' -or (`$ChildPath -eq '$failDot')) { throw "simulated load failure: `$ChildPath" }
    Microsoft.PowerShell.Management\Join-Path -Path `$Path -ChildPath `$ChildPath }
function Import-Module { if ([string]`$args[0] -like '*$failModule') { throw 'simulated load failure: $failModule' } }
`$global:LASTEXITCODE = 0
& `$HookPath
`$LASTEXITCODE
"@
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            $shell = [powershell]::Create()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new('{"session_id":"c-786","hook_event_name":"SubagentStop"}'))
                [System.Console]::SetError($errorWriter)
                $output = @($shell.AddScript($driver).AddArgument((Get-HookInvocationPath -Left $script:RepoRoot -Right $Hook)).Invoke())
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
                $shell.Dispose()
            }
            return [pscustomobject]@{ Stderr = $errorWriter.ToString(); ExitCode = [int]$output[-1] }
        }

        function Get-DenyReason {
            # The permissionDecisionReason of a PreToolUse deny emitted at exit 0.
            param($Result)
            $Result.ExitCode | Should -Be 0
            $output = ($Result.Stdout | ConvertFrom-Json).hookSpecificOutput
            $output.permissionDecision | Should -Be 'deny'
            return [string]$output.permissionDecisionReason
        }

        function Reset-HookDependencyState {
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            $script:HookDependencyGuardLoadFailed = $false
        }
    }

    BeforeEach {
        Mock Read-ClaudeHookRawPayload { '' }
        Mock Resolve-ClaudeHookToolInput { [pscustomobject]@{ IsValid = $false; Anomaly = 'Empty'; Value = $null } }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeRunCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }

    It 'C1: reports a nested EpicScopeReadiness.psm1 failure under enforce-pr-author-skill-helpers.ps1 as that top-level dependency' {
        # Arrange: the module the helpers file imports fails; every other import is a no-op.
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated load failure: EpicScopeReadiness.psm1' } -ParameterFilter { $Name -like '*EpicScopeReadiness.psm1' }
        # Act
        try { $result = Invoke-HookProcess -Hook '.claude/hooks/enforce-pr-author-skill.ps1' }
        finally { Reset-HookDependencyState }
        # Assert
        $reason = Get-DenyReason -Result $result
        $reason.StartsWith('PR_AUTHOR_SKILL_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
        $reason.Contains("'enforce-pr-author-skill-helpers.ps1'") | Should -BeTrue -Because $reason
    }

    It 'C2: reports a nested hook-command-scanner.ps1 load failure under enforce-pr-author-skill.epic-base-branch.ps1 as that top-level dependency' {
        # Arrange: the nested scanner path resolves to a file that does not exist.
        Mock Import-Module { }
        Mock Join-Path { 'synthetic-missing/hook-command-scanner.ps1' } -ParameterFilter { $ChildPath -eq 'hook-command-scanner.ps1' }
        try { $result = Invoke-HookProcess -Hook '.claude/hooks/enforce-pr-author-skill.ps1' }
        finally { Reset-HookDependencyState }
        $reason = Get-DenyReason -Result $result
        $reason.StartsWith('PR_AUTHOR_SKILL_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
        $reason.Contains("'enforce-pr-author-skill.epic-base-branch.ps1'") | Should -BeTrue -Because $reason
    }

    It 'C3: denies through the merge gate when enforce-epic-merge-gate-authorization.ps1 fails to load' {
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: enforce-epic-merge-gate-authorization.ps1' } -ParameterFilter { $ChildPath -eq 'enforce-epic-merge-gate-authorization.ps1' }
        try { $result = Invoke-HookProcess -Hook '.claude/hooks/enforce-epic-merge-gate.ps1' }
        finally { Reset-HookDependencyState }
        $reason = Get-DenyReason -Result $result
        $reason.StartsWith('EPIC_MERGE_GATE_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
        $reason.Contains('enforce-epic-merge-gate-authorization.ps1') | Should -BeTrue -Because $reason
    }

    It 'C4: makes the pre-loaded <Module> visible to the lazy-load check in <Via>' -ForEach $script:LazyRows {
        # Arrange: drop any instance an earlier container loaded, then load the hook.
        Get-Module -Name $Module | Remove-Module -Force
        try {
            . (Get-HookInvocationPath -Left $script:RepoRoot -Right $Hook)
            # Act: evaluate the lazy-load condition where the importing code evaluates it.
            if ($Via -like '*.psm1') {
                $owner = Get-Module -Name ([IO.Path]::GetFileNameWithoutExtension($Via)) | Select-Object -Last 1
                $command = & $owner { param($Name) Get-Command -Name $Name -ErrorAction SilentlyContinue } $LazyFunction
            }
            else {
                $command = Get-Command -Name $LazyFunction -ErrorAction SilentlyContinue
            }
        }
        finally {
            Reset-HookDependencyState
            # The real imports above leave duplicate module instances that a later container's -ModuleName mocks would bind to.
            Get-Module | Where-Object { $_.Path -like '*worktree-resolution*' -or $_.Path -like '*orchestrator-state*' } | Remove-Module -Force
        }
        # Assert
        $command | Should -Not -BeNullOrEmpty -Because "the pre-loaded $Module must satisfy the Get-Command check for $LazyFunction"
    }

    It 'C5: enforce-mermaid-validation.ps1 returns no deny when MermaidValidation is unavailable' {
        # Arrange: the validation module cannot be imported.
        . (Get-HookInvocationPath -Left $script:RepoRoot -Right '.claude/hooks/enforce-mermaid-validation.ps1')
        Mock Import-Module { throw 'simulated load failure: MermaidValidation.psm1' } -ParameterFilter { $Name -like '*MermaidValidation.psm1' }
        Mock Resolve-ClaudeHookToolInput { [pscustomobject]@{ IsValid = $true; Anomaly = $null; Value = [pscustomobject]@{ file_path = 'docs/sample.md'; content = "``````mermaid`nflowchart TD`n  A -->`n``````" } } }
        # Act
        try { $decision = Invoke-MermaidValidationDecision -ToolInputRaw '{"tool_input":{"file_path":"docs/sample.md"}}' }
        finally { Reset-HookDependencyState }
        # Assert: the designed fail-open (D2) is unchanged.
        if ($null -ne $decision) { $decision.hookSpecificOutput.permissionDecision | Should -Not -Be 'deny' }
        Should -Invoke Import-Module -ParameterFilter { $Name -like '*MermaidValidation.psm1' } -Times 1
    }

    It 'C6: enforce-mermaid-validation.ps1 denies naming HookPayload.psm1 when that import fails' {
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated load failure: HookPayload.psm1' } -ParameterFilter { $Name -like '*HookPayload.psm1' }
        try { $result = Invoke-HookProcess -Hook '.claude/hooks/enforce-mermaid-validation.ps1' }
        finally { Reset-HookDependencyState }
        $reason = Get-DenyReason -Result $result
        $reason.StartsWith('MERMAID_VALIDATION_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
        $reason.Contains('HookPayload.psm1') | Should -BeTrue -Because $reason
    }

    It 'C7: validate-bash denies a dependency failure with HOOK_DEPENDENCY_LOAD_FAILED:' {
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated load failure: HookPayload.psm1' } -ParameterFilter { $Name -like '*HookPayload.psm1' }
        try { $result = Invoke-HookProcess -Hook '.claude/hooks/validate-bash.ps1' }
        finally { Reset-HookDependencyState }
        $reason = Get-DenyReason -Result $result
        $reason.StartsWith('HOOK_DEPENDENCY_LOAD_FAILED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
        $reason.Contains('HookPayload.psm1') | Should -BeTrue -Because $reason
    }

    It 'C8: <Hook> reaches the tail check without a script-terminating error when the helper and a dependency both fail' -ForEach $script:StopRows {
        # Arrange: the helper bootstrap fails, so the dependency's catch calls an undefined function (failures set in the runspace).
        # Act
        $result = Invoke-HookInFreshRunspace -Hook $Hook -Dependency $Dependency -Kind $Kind
        # Assert
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith("$($script:StopPrefix[$Hook]) hook-dependency-guard.ps1 failed to load", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
    }
}
