#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Promotion-hook decisions over the issue #824 corpus (T-PROMO, rows PM-01 to PM-32).

.DESCRIPTION
    Drives Invoke-PromotionMcpOnlyDecision in the Claude and the Codex copy of
    enforce-promotion-mcp-only.ps1. The Claude copy receives a PreToolUse envelope; the
    Codex copy receives the mapped tool_input JSON. A deny must carry the gh-issue reason
    returned by Get-PromotionMcpOnlyGhIssueBlockedReason.

    PM-29 is the negative control: it reinstates substring presence through a mock of
    Test-CommandLineWordPresent and shows that the R-824-MAIN command would then deny.

    Determinism: every row is a pure string decision. No temporary file, no child process,
    and no live executable. Fixture command names that the test-purity hook rejects as
    literals are assembled from fragments at run time.
#>

BeforeDiscovery {
    $script:Runtimes = @(
        @{ Runtime = 'claude'; HookRoot = '.claude/hooks' }
        @{ Runtime = 'codex'; HookRoot = '.codex/hooks' }
    )
    $lineFeed = "`n"
    $startProcess = 'Start' + '-Process'
    $script:GhIssueRows = @(
        @{ Id = 'PM-02'; Command = 'gh issue create --title x' }
        @{ Id = 'PM-03'; Command = 'gh issue new --title x' }
        @{ Id = 'PM-04'; Command = 'pwsh -Command ''gh issue create --title x''' }
        @{ Id = 'PM-05'; Command = 'pwsh -Command ''gh issue new --title x''' }
        @{ Id = 'PM-06'; Command = 'bash -c "gh issue create --title x"' }
        @{ Id = 'PM-07'; Command = 'bash -c "gh issue new --title x"' }
        @{ Id = 'PM-08'; Command = '/usr/bin/gh issue create' }
        @{ Id = 'PM-09'; Command = '/usr/bin/gh issue new' }
        @{ Id = 'PM-10'; Command = 'gh.exe issue create' }
        @{ Id = 'PM-11'; Command = 'gh.exe issue new' }
        @{ Id = 'PM-12'; Command = "gh issue \${lineFeed}create" }
        @{ Id = 'PM-13'; Command = "gh issue \${lineFeed}new" }
    )
    $script:DenyRows = @(
        @{ Id = 'PM-16'; Command = 'pwsh -c ''iex "gh issue create"''' }
        @{ Id = 'PM-17'; Command = "pwsh -c '$startProcess gh issue create'" }
        @{ Id = 'PM-18'; Command = 'c=gh; $c issue create' }
        @{ Id = 'PM-19'; Command = 'echo "gh issue create' }
        @{ Id = 'PM-20'; Command = 'bash -c ''cmd="issue create"; gh $cmd''' }
        @{ Id = 'PM-21'; Command = 'pwsh -c ''$a = "issue","create"; gh @a''' }
        @{ Id = 'PM-22'; Command = 'bash -c ''args=(issue create); gh "${args[@]}"''' }
        @{ Id = 'PM-23'; Command = "bash -c `"gh issue \${lineFeed}create`"" }
        @{ Id = 'PM-24'; Command = 'bash -c ''gh "$@"'' _ issue create' }
        @{ Id = 'PM-25'; Command = 'bash -c ''gh $*'' _ issue create' }
        @{ Id = 'PM-26'; Command = 'bash -c ''echo issue create | xargs gh''' }
        @{ Id = 'PM-27'; Command = 'bash -c ''gh $1 $2'' _ issue create' }
        @{ Id = 'PM-32'; Command = 'bash -c "gh -R o/r issue create"' }
        @{ Id = 'PM-32'; Command = 'bash -c ''x=create; gh issue $x''' }
        @{ Id = 'PM-32'; Command = 'bash -c ''c=gh; $c issue create''' }
    )
    $script:AllowRows = @(
        @{ Id = 'PM-14'; Command = 'pwsh -c ''Write-Output "gh issue create"''' }
        @{ Id = 'PM-15'; Command = 'pwsh -c ''Write-Output "$prefix issue create"''' }
        @{ Id = 'PM-28'; Command = 'pwsh -NoProfile -Command ''Write-Output "through"; "issue"; New-Object Text.StringBuilder''' }
        @{ Id = 'PM-31'; Command = 'gh --repo o/r issue list' }
    )
}

Describe 'enforce-promotion-mcp-only issue #824 decisions, <Runtime> copy' -ForEach $script:Runtimes {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookPath = Join-Path $script:RepoRoot "$HookRoot/enforce-promotion-mcp-only.ps1"
        . $script:HookPath
        $script:CurrentRuntime = $Runtime
        $script:R824Main = 'pwsh -NoProfile -Command ''$parts = New-Object System.Collections.Generic.List[string]; foreach ($t in @("a phrase that runs through the text", "The call is guarded (issue #1)")) { Write-Output $t }'''

        function Invoke-PromotionRow {
            <# Run the runtime's decision function for one command and return the decision. #>
            param([Parameter(Mandatory)][string] $Command)
            $raw = if ($script:CurrentRuntime -eq 'claude') {
                @{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5
            } else {
                @{ command = $Command } | ConvertTo-Json -Compress -Depth 5
            }
            return Invoke-PromotionMcpOnlyDecision -ToolInputRaw $raw
        }
    }

    It 'PM-01 allows R-824-MAIN' -Tag 'Issue824', 'R-824-MAIN' {
        $decision = Invoke-PromotionRow -Command $script:R824Main
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It '<Id> denies <Command> with the gh-issue reason' -Tag 'Issue824' -ForEach $script:GhIssueRows {
        $decision = Invoke-PromotionRow -Command $Command
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Be (Get-PromotionMcpOnlyGhIssueBlockedReason)
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PROMOTION_MCP_ONLY_BLOCKED:*'
    }

    It '<Id> denies <Command>' -Tag 'Issue824' -ForEach $script:DenyRows {
        $decision = Invoke-PromotionRow -Command $Command
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PROMOTION_MCP_ONLY_BLOCKED:*'
    }

    It '<Id> allows <Command>' -Tag 'Issue824' -ForEach $script:AllowRows {
        $decision = Invoke-PromotionRow -Command $Command
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'PM-29 denies the PM-01 command when substring presence is reinstated' -Tag 'Issue824', 'NegativeControl' {
        $delivered = (Invoke-PromotionRow -Command $script:R824Main).hookSpecificOutput.permissionDecision
        Mock Test-CommandLineWordPresent { $RawText.IndexOf($Word, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 }

        $mocked = (Invoke-PromotionRow -Command $script:R824Main).hookSpecificOutput.permissionDecision

        $delivered | Should -Be 'allow'
        $mocked | Should -Be 'deny' -Because 'substring presence finds new inside New-Object and issue inside the quoted text'
    }

    It 'PM-30 keeps the adjacency regex literal once and reads MaskedText on its line' -Tag 'Issue824' {
        $literal = '(?i)\bgh\s+issue\s+(?:create|new)\b'
        $text = Get-Content -Raw -LiteralPath $script:HookPath

        $count = [regex]::Matches($text, [regex]::Escape($literal)).Count
        $line = @(Select-String -LiteralPath $script:HookPath -SimpleMatch -Pattern $literal)

        $count | Should -Be 1
        $line.Count | Should -Be 1
        $line[0].Line | Should -Match 'MaskedText'
    }
}
