#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Decision D17 suite for enforce-orchestration-preimplementation-gate-commands.ps1 (issue #1160).

.DESCRIPTION
    Runs against the .claude/hooks and .codex/hooks copies of the commands sibling through
    Context -ForEach. Each copy is loaded with the shared command-line parser of its own
    surface (hook-command-scanner.ps1 and hook-command-invocation.ps1), as in the existing
    commands suite. Every case calls Test-OrchestrationGateInvocationConfirmed at pattern
    index 1 (the Python-tools pattern, governed word pytest).

    Decision D17 drops a stage-1 hit only for a command built entirely from constructs that
    stage 2 positively models. The first Context holds 36 cases that must stay classified:
    one per construct-class row ED-67 to ED-85 of the classification corpus, the F2 shapes
    ED-51, ED-52, ED-56, ED-61, and ED-63, and twelve named cases, each of which fails when
    its own D17 clause is removed (ANSI-C quoting, a $_ expansion across records and inside a
    wrapper payload, the long-option abbreviation, a PowerShell assignment and & operator,
    and a command substitution inside double quotes). The second Context holds three guards
    that must stay unclassified: quoted and escaped structural characters, the xargs {}
    placeholder, and the &&, ||, and newline separators.

    Pure string inputs only: no file, process, clock, or environment access, and no mocks.
#>

Describe 'enforce-orchestration-preimplementation-gate-commands.ps1 modelled-command rule (decision D17, issue #1160)' {
    Context '<Surface> copy of the sibling' -ForEach @(
        @{ Surface = 'Claude'; Directory = '.claude/hooks' }
        @{ Surface = 'Codex'; Directory = '.codex/hooks' }
    ) {
        BeforeAll {
            $hookDirectory = Join-Path (Resolve-Path "$PSScriptRoot/../../..").Path $Directory
            . (Join-Path $hookDirectory 'hook-command-scanner.ps1')
            . (Join-Path $hookDirectory 'hook-command-invocation.ps1')
            . (Join-Path $hookDirectory 'enforce-orchestration-preimplementation-gate-commands.ps1')
        }

        Context 'unmodelled constructs keep the hit classified (decision D17)' {
            It 'confirms <Name>' -ForEach @(
                @{ Name = 'ED-51 (subshell)'; Command = '(echo pytest) | xargs env' }
                @{ Name = 'ED-52 (brace group)'; Command = '{ echo pytest; } | xargs env' }
                @{ Name = 'ED-56 (input process substitution)'; Command = 'xargs env < <(echo pytest)' }
                @{ Name = 'ED-61 (preceding consumer)'; Command = 'env < <(echo pytest) xargs env' }
                @{ Name = 'ED-63 (output process substitution)'; Command = 'echo pytest > >(xargs env)' }
                @{ Name = 'ED-67 (here-string)'; Command = 'xargs env <<< $(grep -o pytest x)' }
                @{ Name = 'ED-68 (here-document)'; Command = "grep pytest x <<'EOF'`nhello`nEOF" }
                @{ Name = 'ED-69 (command substitution)'; Command = 'env $(grep -o pytest x)' }
                @{ Name = 'ED-70 (backtick substitution)'; Command = 'env `grep -o pytest x`' }
                @{ Name = 'ED-71 (eval)'; Command = 'eval grep pytest x' }
                @{ Name = 'ED-72 (PowerShell function)'; Command = 'pwsh -c "function Select-String { & $args[0] }; Select-String pytest"' }
                @{ Name = 'ED-73 (PowerShell array)'; Command = 'pwsh -c "@(''pytest'') | Select-String pytest"' }
                @{ Name = 'ED-74 (PowerShell redirection)'; Command = 'pwsh -c "Get-Command pytest > out.txt"' }
                @{ Name = 'ED-75 (redirection)'; Command = 'grep pytest x > out.txt' }
                @{ Name = 'ED-76 (background job)'; Command = 'grep pytest x & xargs env' }
                @{ Name = 'ED-77 (word after payload)'; Command = 'sh -c ''grep pytest x; "$0"'' pytest' }
                @{ Name = 'ED-78 (function definition)'; Command = 'f() { grep pytest x; }' }
                @{ Name = 'ED-79 (array assignment)'; Command = 'a=(x) && grep pytest x' }
                @{ Name = 'ED-80 (comment)'; Command = 'grep pytest x # note' }
                @{ Name = 'ED-81 (compound command)'; Command = 'grep pytest x; if true; then echo y; fi' }
                @{ Name = 'ED-82 (PowerShell method call)'; Command = 'pwsh -c "(Get-Command pytest).ToString()"' }
                @{ Name = 'ED-83 (stage before carrier)'; Command = 'make test | grep pytest' }
                @{ Name = 'ED-84 (assignment word)'; Command = 'PATH=./bin grep pytest x' }
                @{ Name = 'ED-85 (shell-state builtin)'; Command = 'alias grep=xargs; grep pytest x' }
            ) {
                Test-OrchestrationGateInvocationConfirmed -CommandText $Command -PatternIndex 1 | Should -BeTrue -Because "decision D17 keeps $Name classified"
            }

            It '<Name>' -ForEach @(
                @{ Name = 'keeps a mention-host consumer through a process substitution classified'; Command = 'ps aux > >(grep pytest)' }
                @{ Name = 'keeps a group inside a wrapper payload classified'; Command = 'sh -c "(echo pytest) | xargs env"' }
                @{ Name = 'keeps a PowerShell expression carrying the word outside a host scriptblock classified'; Command = 'pwsh -c "''pytest''"' }
                @{ Name = 'keeps a PowerShell stage before the carrying record classified'; Command = 'pwsh -c "Invoke-Build | Select-String pytest"' }
                @{ Name = 'keeps PowerShell -CommandWithArgs arguments after the payload classified'; Command = 'pwsh -CommandWithArgs "Get-Command pytest" pytest' }
                @{ Name = 'keeps an ANSI-C quoted pipe in a wrapper payload classified'; Command = 'sh -c ''echo pytest''$''\x7c''''xargs env''' }
                @{ Name = 'keeps a $_ expansion after && classified'; Command = 'echo pytest && env $_' }
                @{ Name = 'keeps a $_ expansion inside a wrapper payload classified'; Command = 'sh -c ''echo pytest && env $_''' }
                @{ Name = 'confirms an abbreviated sort --compress-program option'; Command = 'sort --compress pytest big.txt' }
                @{ Name = 'keeps a PowerShell assignment statement classified'; Command = 'pwsh -c ''Get-Command pytest; $x = 1''' }
                @{ Name = 'keeps a PowerShell & operator classified'; Command = 'pwsh -c "& Get-Command pytest"' }
                @{ Name = 'keeps a command substitution inside double quotes classified'; Command = 'echo "$(grep -o pytest x)"' }
            ) {
                Test-OrchestrationGateInvocationConfirmed -CommandText $Command -PatternIndex 1 | Should -BeTrue -Because "decision D17: $Name"
            }
        }

        Context 'modelled constructs keep a mention unclassified (decision D17)' {
            It '<Name>' -ForEach @(
                @{ Name = 'keeps quoted and escaped structural characters modelled'; Command = 'grep "(pytest)" ''a<b>'' x\(y' }
                @{ Name = 'keeps an xargs placeholder modelled'; Command = 'xargs -I {} grep pytest {}' }
                @{ Name = 'keeps &&, ||, and newline separators modelled'; Command = "grep -q pytest x && echo y || echo z`nps aux" }
            ) {
                Test-OrchestrationGateInvocationConfirmed -CommandText $Command -PatternIndex 1 | Should -BeFalse -Because "decision D17: $Name"
            }
        }
    }
}
