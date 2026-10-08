#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the enforce-pr-author-command-allowlist.ps1 PreToolUse hook (T-ALLOW, AL-01 to AL-37).

.DESCRIPTION
    The hook limits the pr-author subagent's Bash calls to git log, git rev-parse,
    gh pr create, gh pr edit, and, each as the whole command, sha256sum of a canonical
    body file and date -u. AL-33 to AL-35 are static checks over .claude/agents/pr-author.md
    and .claude/skills/pr-author/SKILL.md: the frontmatter registers the hook, and every
    command form the receipt procedure names is allowed by it.

    Determinism: every decision row is a pure string decision. The static rows read two
    tracked repository documents. AL-37 runs the hook script in process with stdin and the
    CLAUDE_HOOK_INPUT variable redirected to an in-memory envelope; both are restored in a
    finally block. No temporary file, no child process, and no network access.
#>

BeforeDiscovery {
    $script:AllowRows = @(
        @{ Id = 'AL-02'; Command = 'git log -1 --format=%H' }
        @{ Id = 'AL-03'; Command = 'git log --oneline -5' }
        @{ Id = 'AL-04'; Command = 'git rev-parse HEAD' }
        @{ Id = 'AL-05'; Command = 'gh pr create --head bug/x-5 --base main --body-file artifacts/pr_body_5.md' }
        @{ Id = 'AL-06'; Command = 'gh pr edit 5 --body-file artifacts/pr_body_5.md' }
        @{ Id = 'AL-07'; Command = 'sha256sum artifacts/pr_body_5.md' }
        @{ Id = 'AL-08'; Command = 'date -u +%Y-%m-%dT%H:%M:%SZ' }
        @{ Id = 'AL-09'; Command = 'date -u' }
        @{ Id = 'AL-10'; Command = 'git rev-parse HEAD && git log -1 --format=%H' }
    )
    $script:DenyRows = @(
        @{ Id = 'AL-11'; Command = 'git log -1 --format=%H && sha256sum artifacts/pr_body_5.md && date -u +%Y-%m-%dT%H:%M:%SZ' }
        @{ Id = 'AL-12'; Command = 'git -C /repo log' }
        @{ Id = 'AL-13'; Command = 'git --no-pager log' }
        @{ Id = 'AL-14'; Command = 'sha256sum artifacts/other.md' }
        @{ Id = 'AL-15'; Command = 'sha256sum -b artifacts/pr_body_5.md' }
        @{ Id = 'AL-16'; Command = 'sha256sum artifacts/pr_body_5.md artifacts/pr_body_6.md' }
        @{ Id = 'AL-17'; Command = 'date' }
        @{ Id = 'AL-18'; Command = 'date +%s' }
        @{ Id = 'AL-19'; Command = 'date -u -d yesterday' }
        @{ Id = 'AL-20'; Command = 'date -u +%s extra' }
        @{ Id = 'AL-21'; Command = 'git log > out.txt' }
        @{ Id = 'AL-22'; Command = 'bash -c "git log"' }
        @{ Id = 'AL-23'; Command = 'git log $(whoami)' }
        @{ Id = 'AL-24'; Command = 'echo "$(git log)"' }
        @{ Id = 'AL-25'; Command = 'git log "unterminated' }
        @{ Id = 'AL-26'; Command = 'git log -1; rm -rf x' }
        @{ Id = 'AL-27'; Command = 'cat artifacts/pr_body_5.md' }
        @{ Id = 'AL-28'; Command = 'git log -1 & git rev-parse HEAD' }
        @{ Id = 'AL-29'; Command = 'FOO=1 git log' }
        @{ Id = 'AL-30'; Command = 'git log $X' }
        @{ Id = 'AL-31'; Command = 'sha256sum artifacts/pr_body_5.md; date -u +%Y-%m-%dT%H:%M:%SZ' }
    )
}

Describe 'enforce-pr-author-command-allowlist.ps1 (issue #824)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookPath = Join-Path $script:RepoRoot '.claude/hooks/enforce-pr-author-command-allowlist.ps1'
        . $script:HookPath
        $script:AgentPath = Join-Path $script:RepoRoot '.claude/agents/pr-author.md'
        $script:SkillPath = Join-Path $script:RepoRoot '.claude/skills/pr-author/SKILL.md'
        $script:Chain = 'git log -1 --format=%H && sha256sum artifacts/pr_body_5.md && date -u +%Y-%m-%dT%H:%M:%SZ'
        $script:ChainEnvelope = @{ tool_name = 'Bash'; tool_input = @{ command = $script:Chain } } | ConvertTo-Json -Compress -Depth 5

        function Get-ProcedureCodeSpan {
            <# Return the inline code spans of a document outside fenced blocks. #>
            param([Parameter(Mandatory)][string] $Path)
            $text = (Get-Content -Raw -LiteralPath $Path) -replace '(?ms)^\s*```.*?^\s*```\s*$', ''
            return @([regex]::Matches($text, '`([^`\r\n]+)`') | ForEach-Object { $_.Groups[1].Value })
        }
    }

    It 'AL-01 exposes the decision function with a CommandText parameter and an ordered result' -Tag 'Issue824' {
        $command = Get-Command -Name Invoke-PrAuthorCommandAllowlistDecision -CommandType Function
        $common = @([System.Management.Automation.PSCmdlet]::CommonParameters) + @([System.Management.Automation.PSCmdlet]::OptionalCommonParameters)

        @($command.Parameters.Keys | Where-Object { $common -notcontains $_ }) -join ',' | Should -Be 'CommandText'
        $command.OutputType.Type | Should -Contain ([System.Collections.Specialized.OrderedDictionary])
    }

    It '<Id> allows <Command>' -Tag 'Issue824' -ForEach $script:AllowRows {
        (Invoke-PrAuthorCommandAllowlistDecision -CommandText $Command).hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It '<Id> denies <Command>' -Tag 'Issue824' -ForEach $script:DenyRows {
        $decision = Invoke-PrAuthorCommandAllowlistDecision -CommandText $Command
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PR_AUTHOR_COMMAND_NOT_ALLOWED: *'
    }

    It 'AL-32 allows an empty command' -Tag 'Issue824' {
        (Invoke-PrAuthorCommandAllowlistDecision -CommandText '').hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'AL-33 registers the hook in the pr-author frontmatter and keeps the SubagentStop entry' -Tag 'Issue824' {
        $lines = @(Get-Content -LiteralPath $script:AgentPath)
        $end = [Array]::IndexOf($lines, '---', 1)
        $frontmatter = @($lines[1..($end - 1)])
        $start = [Array]::IndexOf($frontmatter, 'hooks:')
        $expectedHooks = @(
            'hooks:'
            '  PreToolUse:'
            '    - matcher: "Bash"'
            '      hooks:'
            '        - type: command'
            '          command: pwsh -NoProfile -File .claude/hooks/enforce-pr-author-command-allowlist.ps1'
        )
        $expectedSubagentStop = @(
            '  SubagentStop:'
            '    - matcher: "pr-author"'
            '      hooks:'
            '        - type: command'
            '          command: pwsh -NoProfile -File .claude/hooks/validate-pr-author-output.ps1'
        )

        $start | Should -BeGreaterThan 0
        ($frontmatter[$start..($start + 5)] -join "`n") | Should -BeExactly ($expectedHooks -join "`n")
        ($frontmatter[($start + 6)..($start + 10)] -join "`n") | Should -BeExactly ($expectedSubagentStop -join "`n")
    }

    It 'AL-34 allows every command form the receipt procedure names' -Tag 'Issue824' {
        $spans = foreach ($path in @($script:AgentPath, $script:SkillPath)) {
            Get-ProcedureCodeSpan -Path $path | Where-Object { $_ -match '^(git|gh|sha256sum|date) ' } |
                ForEach-Object { $_.Replace('<N>', '5').Replace('<branch>', 'bug/example-5') }
        }
        $spans = @($spans | Sort-Object -Unique)

        @($spans | Where-Object { $_.Contains('<') -or $_.Contains('>') }) | Should -BeNullOrEmpty
        $spans | Should -Contain 'sha256sum artifacts/pr_body_5.md'
        $spans | Should -Contain 'date -u +%Y-%m-%dT%H:%M:%SZ'
        foreach ($span in $spans) {
            Get-PrAuthorCommandAllowlistReason -CommandText $span | Should -BeNullOrEmpty -Because "the procedure names '$span'"
        }
    }

    It 'AL-35 names both receipt commands in the agent and the skill' -Tag 'Issue824' {
        foreach ($path in @($script:AgentPath, $script:SkillPath)) {
            $text = Get-Content -Raw -LiteralPath $path
            $text.Contains('sha256sum artifacts/pr_body_<N>.md') | Should -BeTrue -Because $path
            $text.Contains('date -u +%Y-%m-%dT%H:%M:%SZ') | Should -BeTrue -Because $path
        }
    }

    It 'AL-36 returns 0 from the entry point and denies a payload anomaly' -Tag 'Issue824' {
        $chainResult = @(Invoke-PrAuthorCommandAllowlistEntryPoint -ToolInputRaw $script:ChainEnvelope)
        $anomalyResult = @(Invoke-PrAuthorCommandAllowlistEntryPoint -ToolInputRaw '{not-json')

        $chainResult[-1] | Should -Be 0
        ($chainResult[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $anomalyResult[-1] | Should -Be 0
        ($anomalyResult[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
            Should -BeLike 'PR_AUTHOR_COMMAND_NOT_ALLOWED: payload anomaly*'
    }

    It 'AL-37 writes a deny decision and exits 0 when the script runs in process' -Tag 'Issue824' {
        $originalIn = [System.Console]::In
        $originalHookInput = $env:CLAUDE_HOOK_INPUT
        try {
            [System.Console]::SetIn([System.IO.StringReader]::new($script:ChainEnvelope))
            $env:CLAUDE_HOOK_INPUT = $script:ChainEnvelope
            $stdout = & $script:HookPath
            $exitCode = $LASTEXITCODE
        } finally {
            [System.Console]::SetIn($originalIn)
            $env:CLAUDE_HOOK_INPUT = $originalHookInput
        }

        $exitCode | Should -Be 0
        $decision = (@($stdout) -join "`n") | ConvertFrom-Json
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PR_AUTHOR_COMMAND_NOT_ALLOWED: *'
    }

    It 'AL-38 matches no allowed form for a record with no tokens' -Tag 'Issue824' {
        $whole = Test-PrAuthorAllowlistForm -Token ([string[]]@()) -IsWholeCommand $true
        $partial = Test-PrAuthorAllowlistForm -Token ([string[]]@()) -IsWholeCommand $false

        $whole | Should -BeFalse
        $partial | Should -BeFalse
    }
}
