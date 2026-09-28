#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
    Issue #697: enforce-epic-planning-only.ps1 must load the semantic MCP registry
    lazily. A destination without config/orchestration-handoff-registry.json must
    still allow every non-MCP decision, and must fail closed only for registry-
    dependent MCP tools in preparation mode.
#>

Describe 'enforce-epic-planning-only.ps1 loads the semantic MCP registry lazily (issue #697)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:PlanningHookPath = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-planning-only.ps1'
        $script:MissingRegistryPath = Join-Path $script:RepoRoot 'tests/fixtures/codex-hooks/absent-orchestration-handoff-registry.json'
        $script:CommittedRegistryPath = Join-Path $script:RepoRoot 'config/orchestration-handoff-registry.json'
        $script:InvalidRegistryPath = Join-Path $script:RepoRoot 'tests/fixtures/codex-hooks/invalid-orchestration-handoff-registry.json'
        $script:PreparationCheckpoint = '{"route_id":"preparation"}'

        if (Test-Path -LiteralPath $script:MissingRegistryPath) {
            throw "The missing-registry path must not exist: $script:MissingRegistryPath"
        }

        . $script:PlanningHookPath

        function ConvertTo-PlanningPayload {
            <#
                Builds a compressed PreToolUse payload for one tool call.
            #>
            param(
                [Parameter(Mandatory)][string] $ToolName,
                [Parameter(Mandatory)][hashtable] $ToolInput,
                [AllowEmptyString()][string] $Cwd = ''
            )

            $payload = [ordered]@{ tool_name = $ToolName; tool_input = $ToolInput }
            if ($Cwd) {
                $payload['cwd'] = $Cwd
            }
            return ($payload | ConvertTo-Json -Compress -Depth 5)
        }

        function ConvertTo-DecisionText {
            <#
                Renders a decision as comparable JSON text; an allow decision is $null.
            #>
            param([AllowNull()] $Decision)

            if ($null -eq $Decision) {
                return '<allow>'
            }
            return ($Decision | ConvertTo-Json -Compress -Depth 5)
        }

        function Invoke-PlanningOnlyEntrypoint {
            <#
                Drives the hook's own entrypoint in-process. Stdin is supplied by a
                StringReader rather than a temporary file; the console readers and the
                attestation environment variable are restored in finally.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw)

            $originalIn = [System.Console]::In
            $originalError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            $savedContext = [System.Environment]::GetEnvironmentVariable('CODEX_EPIC_CHILD_EXECUTION_CONTEXT')
            try {
                [System.Environment]::SetEnvironmentVariable('CODEX_EPIC_CHILD_EXECUTION_CONTEXT', $null)
                [System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
                [System.Console]::SetError($errorWriter)
                $stdout = & $script:PlanningHookPath
                return [pscustomobject]@{
                    ExitCode = $LASTEXITCODE
                    Stdout   = ($stdout -join "`n")
                    Stderr   = $errorWriter.ToString()
                }
            } finally {
                [System.Console]::SetIn($originalIn)
                [System.Console]::SetError($originalError)
                [System.Environment]::SetEnvironmentVariable('CODEX_EPIC_CHILD_EXECUTION_CONTEXT', $savedContext)
            }
        }
    }

    It 'invokes Get-EpicPlanningRegisteredMcpTool from no top-level statement' {
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile(
            $script:PlanningHookPath, [ref] $tokens, [ref] $parseErrors)
        $parseErrors | Should -BeNullOrEmpty

        $calls = @($ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst] -and
                    $node.GetCommandName() -eq 'Get-EpicPlanningRegisteredMcpTool'
                }, $true))
        $topLevelCalls = @($calls | Where-Object {
                $parent = $_.Parent
                while ($null -ne $parent -and
                    $parent -isnot [System.Management.Automation.Language.FunctionDefinitionAst]) {
                    $parent = $parent.Parent
                }
                $null -eq $parent
            })

        $topLevelCalls.Count | Should -Be 0 -Because 'the registry must be read lazily inside a function'
    }

    It 'allows any tool with a missing registry when no checkpoint or attestation is present' {
        $payloads = @(
            (ConvertTo-PlanningPayload -ToolName 'mcp__drm-copilot__validate_orchestration_artifacts' -ToolInput @{ artifact_type = 'plan' })
            (ConvertTo-PlanningPayload -ToolName 'mcp__drm-copilot__unregistered_tool' -ToolInput @{})
            (ConvertTo-PlanningPayload -ToolName 'Bash' -ToolInput @{ command = 'git reset --hard' })
            (ConvertTo-PlanningPayload -ToolName 'Edit' -ToolInput @{ file_path = 'src/service.py' })
        )

        foreach ($payload in $payloads) {
            Invoke-EpicPlanningOnlyDecision -PayloadRaw $payload -CheckpointRaw '' -RegistryPath $script:MissingRegistryPath |
                Should -BeNullOrEmpty
        }
    }

    It 'allows an mcp__ tool with a missing registry on a non-preparation route' {
        $payload = ConvertTo-PlanningPayload -ToolName 'mcp__drm-copilot__validate_orchestration_artifacts' -ToolInput @{ artifact_type = 'plan' }

        Invoke-EpicPlanningOnlyDecision `
            -PayloadRaw $payload `
            -CheckpointRaw '{"route_id":"full-bug"}' `
            -RegistryPath $script:MissingRegistryPath |
            Should -BeNullOrEmpty
    }

    It 'returns the committed-registry decision for apply_patch <Label> with a missing registry' -ForEach @(
        @{ Label = 'planning document edit (allow)'; Patch = "*** Begin Patch`n*** Update File: docs/features/active/sample/spec.md`n*** End Patch"; ExpectAllow = $true }
        @{ Label = 'production edit (deny)'; Patch = "*** Begin Patch`n*** Update File: src/service.py`n*** End Patch"; ExpectAllow = $false }
        @{ Label = 'checkpoint delete (deny)'; Patch = "*** Begin Patch`n*** Delete File: artifacts/orchestration/orchestrator-state.json`n*** End Patch"; ExpectAllow = $false }
    ) {
        $payload = ConvertTo-PlanningPayload -ToolName 'apply_patch' -ToolInput @{ command = $Patch }

        $missing = Invoke-EpicPlanningOnlyDecision -PayloadRaw $payload -CheckpointRaw $script:PreparationCheckpoint -RegistryPath $script:MissingRegistryPath
        $committed = Invoke-EpicPlanningOnlyDecision -PayloadRaw $payload -CheckpointRaw $script:PreparationCheckpoint -RegistryPath $script:CommittedRegistryPath

        (ConvertTo-DecisionText $missing) | Should -Be (ConvertTo-DecisionText $committed)
        ($null -eq $missing) | Should -Be $ExpectAllow
    }

    It 'returns the committed-registry decision for Bash <Label> with a missing registry' -ForEach @(
        @{ Label = 'git status (allow)'; Command = 'git status'; ExpectAllow = $true }
        @{ Label = 'git reset --hard (deny)'; Command = 'git reset --hard'; ExpectAllow = $false }
    ) {
        $payload = ConvertTo-PlanningPayload -ToolName 'Bash' -ToolInput @{ command = $Command }

        $missing = Invoke-EpicPlanningOnlyDecision -PayloadRaw $payload -CheckpointRaw $script:PreparationCheckpoint -RegistryPath $script:MissingRegistryPath
        $committed = Invoke-EpicPlanningOnlyDecision -PayloadRaw $payload -CheckpointRaw $script:PreparationCheckpoint -RegistryPath $script:CommittedRegistryPath

        (ConvertTo-DecisionText $missing) | Should -Be (ConvertTo-DecisionText $committed)
        ($null -eq $missing) | Should -Be $ExpectAllow
    }

    It 'allows lifecycle tool <Tool> with a missing registry in preparation mode' -ForEach @(
        @{ Tool = 'mcp__drm-copilot__new_potential_entry' }
        @{ Tool = 'mcp__drm-copilot__new_potential_bug_entry' }
        @{ Tool = 'mcp__drm-copilot__potential_to_issue' }
        @{ Tool = 'mcp__drm-copilot__new_active_feature_folder' }
        @{ Tool = 'mcp__drm-copilot__resolve_atomic_plan_prompt' }
        @{ Tool = 'mcp__drm-copilot__resolve_execute_hard_lock_prompt' }
    ) {
        $payload = ConvertTo-PlanningPayload -ToolName $Tool -ToolInput @{ workspace_root = $script:RepoRoot } -Cwd $script:RepoRoot

        Invoke-EpicPlanningOnlyDecision `
            -PayloadRaw $payload `
            -CheckpointRaw $script:PreparationCheckpoint `
            -EpicExecutionContext 'epic_preparation_child' `
            -RegistryPath $script:MissingRegistryPath |
            Should -BeNullOrEmpty
    }

    It 'denies a lifecycle tool whose workspace_root differs from the attested cwd with a missing registry' {
        $otherRoot = Join-Path $script:RepoRoot 'tests'
        $payload = ConvertTo-PlanningPayload -ToolName 'mcp__drm-copilot__new_potential_entry' -ToolInput @{ workspace_root = $otherRoot } -Cwd $script:RepoRoot

        $decision = Invoke-EpicPlanningOnlyDecision `
            -PayloadRaw $payload `
            -CheckpointRaw $script:PreparationCheckpoint `
            -EpicExecutionContext 'epic_preparation_child' `
            -RegistryPath $script:MissingRegistryPath

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'workspace_root equal to the attested session cwd'
    }

    It 'denies <Tool> with a reason naming the missing registry in preparation mode' -ForEach @(
        @{ Tool = 'mcp__drm-copilot__validate_orchestration_artifacts' }
        @{ Tool = 'mcp__drm_copilot__validate_orchestration_artifacts' }
        @{ Tool = 'mcp__drm-copilot__resolve_orchestration_topology' }
        @{ Tool = 'mcp__drm_copilot__resolve_orchestration_topology' }
        @{ Tool = 'mcp__drm-copilot__resolve_provider_routing' }
        @{ Tool = 'mcp__drm_copilot__resolve_provider_routing' }
        @{ Tool = 'mcp__drm-copilot__transition_prepared_orchestration' }
        @{ Tool = 'mcp__drm_copilot__transition_prepared_orchestration' }
        @{ Tool = 'mcp__drm-copilot__unregistered_tool' }
    ) {
        $payload = ConvertTo-PlanningPayload -ToolName $Tool -ToolInput @{ workspace_root = $script:RepoRoot }

        $decision = Invoke-EpicPlanningOnlyDecision `
            -PayloadRaw $payload `
            -CheckpointRaw $script:PreparationCheckpoint `
            -RegistryPath $script:MissingRegistryPath

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
        $reason.Contains($script:MissingRegistryPath) | Should -BeTrue -Because "the reason '$reason' must name the registry path"
        $reason | Should -BeLike '*does not exist*'
    }

    It 'allows semantic tool <Tool> with the committed registry in preparation mode' -ForEach @(
        @{ Tool = 'mcp__drm-copilot__validate_orchestration_artifacts' }
        @{ Tool = 'mcp__drm_copilot__validate_orchestration_artifacts' }
        @{ Tool = 'mcp__drm-copilot__resolve_orchestration_topology' }
        @{ Tool = 'mcp__drm_copilot__resolve_orchestration_topology' }
        @{ Tool = 'mcp__drm-copilot__resolve_provider_routing' }
        @{ Tool = 'mcp__drm_copilot__resolve_provider_routing' }
        @{ Tool = 'mcp__drm-copilot__transition_prepared_orchestration' }
        @{ Tool = 'mcp__drm_copilot__transition_prepared_orchestration' }
    ) {
        $payload = ConvertTo-PlanningPayload -ToolName $Tool -ToolInput @{ workspace_root = $script:RepoRoot }

        Invoke-EpicPlanningOnlyDecision `
            -PayloadRaw $payload `
            -CheckpointRaw $script:PreparationCheckpoint `
            -RegistryPath $script:CommittedRegistryPath |
            Should -BeNullOrEmpty
    }

    It 'throws for a semantic tool when the registry fixture is invalid' {
        $payload = ConvertTo-PlanningPayload -ToolName 'mcp__drm-copilot__validate_orchestration_artifacts' -ToolInput @{ workspace_root = $script:RepoRoot }

        {
            Invoke-EpicPlanningOnlyDecision `
                -PayloadRaw $payload `
                -CheckpointRaw $script:PreparationCheckpoint `
                -RegistryPath $script:InvalidRegistryPath
        } | Should -Throw -ExpectedMessage '*is not registered*'
    }

    It 'exits 0 through the entrypoint for a benign Edit payload' {
        $payload = ConvertTo-PlanningPayload -ToolName 'Edit' -ToolInput @{ file_path = 'docs/features/active/sample/spec.md' } -Cwd $script:RepoRoot

        $result = Invoke-PlanningOnlyEntrypoint -PayloadRaw $payload

        $result.ExitCode | Should -Be 0 -Because "stderr was '$($result.Stderr)'"
        $result.Stderr | Should -BeNullOrEmpty
    }

    It 'exits 2 through the entrypoint for malformed stdin' {
        $result = Invoke-PlanningOnlyEntrypoint -PayloadRaw '{not json'

        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'malformed JSON'
    }
}
