#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    The review/verdict commands pass the Bash hooks unchanged (issue #1097, decision D16).

.DESCRIPTION
    Drives Invoke-PrAuthorSkillDecision, Invoke-ValidateBashDecision, Invoke-PromotionMcpOnlyDecision,
    and Invoke-DocsCompleteGateDecision with the two command texts the orchestrator runs for the
    review/verdict status: the statuses POST and the entry-point invocation. Each hook's disk and
    process seams are mocked as its own suite mocks them, with the PR context absent, so a command
    the hook classified would deny; one control row per hook shows that deny. No row starts a
    process, reads or writes a file, or posts a status.
#>

BeforeAll {
    $script:HookRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../.claude/hooks'
    $script:StatusPost = "gh api --method POST repos/{owner}/{repo}/statuses/abcdef0123456789abcdef0123456789abcdef01 -f state=success -f context=review/verdict -f description='feature-review PASS: policy-audit.2026-01-01T00-00.md'"
    $script:EntryPoint = 'pwsh -NoProfile -File .claude/lib/review-verdict/Invoke-ReviewVerdictStatus.ps1 -Mode Review -PrNumber 42 -ReviewArtifact docs/features/active/item-42/policy-audit.2026-01-01T00-00.md'

    # Return the statuses POST or the entry-point invocation by key.
    function Get-ReviewVerdictCommand {
        param([Parameter(Mandatory)][ValidateSet('StatusPost', 'EntryPoint')][string] $Key)
        if ($Key -ceq 'StatusPost') { return $script:StatusPost }
        return $script:EntryPoint
    }

    # Return a Bash PreToolUse payload carrying one command string.
    function ConvertTo-ReviewVerdictPayload {
        param([Parameter(Mandatory)][string] $Command)
        return (@{ session_id = 'session-1097'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
    }
}

Describe 'enforce-pr-author-skill.ps1 with the review/verdict commands' {
    BeforeAll {
        . (Resolve-Path (Join-Path -Path $script:HookRoot -ChildPath 'enforce-pr-author-skill.ps1')).Path
        Mock Resolve-PrAuthorWorktreeTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/review-verdict-1097'; ReasonCode = $null; Detail = 'synthetic root' } }
        Mock Get-PrContextArtifactExistence { $false }
        Mock Invoke-PrAuthorDocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
    }

    It 'does not deny the <Name>' -TestCases @(
        @{ Name = 'statuses POST'; Key = 'StatusPost' }
        @{ Name = 'entry-point invocation'; Key = 'EntryPoint' }
    ) {
        param($Key)
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-ReviewVerdictPayload -Command (Get-ReviewVerdictCommand -Key $Key))
        $decision.hookSpecificOutput.permissionDecision | Should -Not -Be 'deny'
        Should -Invoke Get-PrContextArtifactExistence -Times 0 -Exactly
    }

    It 'denies a classified gh pr create (control)' {
        $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw (ConvertTo-ReviewVerdictPayload -Command 'gh pr create --title "Add gate" --body-file artifacts/pr_body_42.md')
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }
}

Describe 'validate-bash.ps1 with the review/verdict commands' {
    BeforeAll {
        . (Resolve-Path (Join-Path -Path $script:HookRoot -ChildPath 'validate-bash.ps1')).Path
    }

    It 'does not deny the <Name>' -TestCases @(
        @{ Name = 'statuses POST'; Key = 'StatusPost' }
        @{ Name = 'entry-point invocation'; Key = 'EntryPoint' }
    ) {
        param($Key)
        $decision = Invoke-ValidateBashDecision -ToolInputRaw (ConvertTo-ReviewVerdictPayload -Command (Get-ReviewVerdictCommand -Key $Key))
        $decision.hookSpecificOutput.permissionDecision | Should -Not -Be 'deny'
    }

    It 'denies a destructive command (control)' {
        $decision = Invoke-ValidateBashDecision -ToolInputRaw (ConvertTo-ReviewVerdictPayload -Command 'git reset --hard origin/main')
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }
}

Describe 'enforce-promotion-mcp-only.ps1 with the review/verdict commands' {
    BeforeAll {
        . (Resolve-Path (Join-Path -Path $script:HookRoot -ChildPath 'enforce-promotion-mcp-only.ps1')).Path
    }

    It 'does not deny the <Name>' -TestCases @(
        @{ Name = 'statuses POST'; Key = 'StatusPost' }
        @{ Name = 'entry-point invocation'; Key = 'EntryPoint' }
    ) {
        param($Key)
        $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw (ConvertTo-ReviewVerdictPayload -Command (Get-ReviewVerdictCommand -Key $Key))
        $decision.hookSpecificOutput.permissionDecision | Should -Not -Be 'deny'
    }

    It 'denies an issues POST (control)' {
        $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw (ConvertTo-ReviewVerdictPayload -Command 'gh api --method POST repos/drmoisan/drm-copilot/issues -f title=x')
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }
}

Describe 'enforce-docs-complete-gate.ps1 with the review/verdict commands' {
    BeforeAll {
        . (Resolve-Path (Join-Path -Path $script:HookRoot -ChildPath 'enforce-docs-complete-gate.ps1')).Path
        Mock Get-DocsCompleteGateRepositoryRoot { 'repo-root' }
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Get-DocsCompleteGateFileText { '{"artifact_paths":{"validation_receipt":"docs/documentation-estate/docs-validation-receipt.json"},"completion_gates":{"integration_pr_gate":{"enabled":true}}}' }
    }

    It 'does not deny the <Name>' -TestCases @(
        @{ Name = 'statuses POST'; Key = 'StatusPost' }
        @{ Name = 'entry-point invocation'; Key = 'EntryPoint' }
    ) {
        param($Key)
        $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-ReviewVerdictPayload -Command (Get-ReviewVerdictCommand -Key $Key))
        $decision.hookSpecificOutput.permissionDecision | Should -Not -Be 'deny'
        Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
    }

    It 'denies a merge it cannot resolve (control)' {
        $decision = Invoke-DocsCompleteGateDecision -ToolInputRaw (ConvertTo-ReviewVerdictPayload -Command 'gh pr merge 12 --merge')
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }
}
