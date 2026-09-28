#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Case-by-case coverage of the D2 Piece 3 structural matcher and the D12 retrieval
    surface (issue #545).

.DESCRIPTION
    Drives .codex/hooks/hook-command-invocation.ps1 directly. Every case in this file is a
    pure string case: no temporary file, no child process, no live executable, no clock, and
    no disk read beyond dot-sourcing the file under test, which in turn dot-sources
    hook-command-scanner.ps1.

    The case inventory asserted here is the one named by spec D2 Piece 3 and D12 in
    docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md:
    structural classification of the relocating git spellings, the non-classifying stop case,
    operand retrieval from the matched segment only, flag value and flag presence retrieval,
    the mention inverse, and exact membership of the transparent-wrapper set and the git, gh,
    and npx global-option tables.
#>

Describe 'hook-command-invocation, Codex copy (issue #545 D2 Piece 3 and D12)' {
    BeforeAll {
        $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks").Path
        . (Join-Path $script:HookRoot 'hook-command-invocation.ps1')
    }

    Context 'structural git classification' {
        It 'classifies a relocating git add carrying a directory global option' {
            Test-CommandLineInvocation -CommandText 'git -C /repo/main add .' -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeTrue
        }

        It 'classifies a relocating git commit carrying a git-dir global option' {
            Test-CommandLineInvocation -CommandText 'git --git-dir=../x/.git commit -m wip' -CommandWord 'git' -SubcommandPath @('commit') |
                Should -BeTrue
        }

        It 'classifies a relocating git add carrying a work-tree global option' {
            Test-CommandLineInvocation -CommandText 'git --work-tree=../x add .' -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeTrue
        }

        It 'classifies an unmodeled dash-leading token between git and its subcommand' {
            Test-CommandLineInvocation -CommandText 'git --unmodeled-option add .' -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeTrue
        }

        It 'does not classify git log --grep add, because a non-dash non-target token stops the scan' {
            Test-CommandLineInvocation -CommandText 'git log --grep add' -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeFalse
        }

        It 'classifies the plain adjacent spelling' {
            Test-CommandLineInvocation -CommandText 'git add .' -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeTrue
        }

        It 'skips VAR=value prefixes and transparent wrappers before the command word' {
            Test-CommandLineInvocation -CommandText 'FOO=bar env git add .' -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeTrue
        }
    }

    Context 'structural gh classification' {
        It 'classifies gh pr create carrying a repo global option in the equals form' {
            Test-CommandLineInvocation -CommandText 'gh --repo=o/r pr create --title x' -CommandWord 'gh' -SubcommandPath @('pr', 'create') |
                Should -BeTrue
        }

        It 'classifies gh issue create carrying a short repo global option' {
            Test-CommandLineInvocation -CommandText 'gh -R o/r issue create --title x' -CommandWord 'gh' -SubcommandPath @('issue', 'create') |
                Should -BeTrue
        }

        It 'does not classify gh issue list as gh issue create' {
            Test-CommandLineInvocation -CommandText 'gh --repo o/r issue list' -CommandWord 'gh' -SubcommandPath @('issue', 'create') |
                Should -BeFalse
        }
    }

    Context 'operand retrieval' {
        It 'returns the worktree path for the flag-before-path spelling' {
            $operands = @(Get-CommandLineOperand -CommandText 'git worktree remove --force /repo/worktrees/item-a-101' -CommandWord 'git' -SubcommandPath @('worktree', 'remove'))
            $operands.Count | Should -Be 1
            $operands[0] | Should -Be '/repo/worktrees/item-a-101'
        }

        It 'returns the worktree path for the flag-after-path spelling' {
            $operands = @(Get-CommandLineOperand -CommandText 'git worktree remove /repo/worktrees/item-a-101 --force' -CommandWord 'git' -SubcommandPath @('worktree', 'remove'))
            $operands.Count | Should -Be 1
            $operands[0] | Should -Be '/repo/worktrees/item-a-101'
        }

        It 'takes operands from the matched segment only, so a chained cd contributes nothing' {
            $text = 'cd /some/other/path && git worktree remove /repo/worktrees/item-a-101'
            $operands = @(Get-CommandLineOperand -CommandText $text -CommandWord 'git' -SubcommandPath @('worktree', 'remove'))
            $operands.Count | Should -Be 1
            $operands[0] | Should -Be '/repo/worktrees/item-a-101'
        }

        It 'consumes a modeled option-with-argument pair rather than returning its value' {
            $operands = @(Get-CommandLineOperand -CommandText 'git -C /repo/main worktree remove /repo/worktrees/item-a-101' -CommandWord 'git' -SubcommandPath @('worktree', 'remove'))
            $operands.Count | Should -Be 1
            $operands[0] | Should -Be '/repo/worktrees/item-a-101'
        }

        It 'treats a token after a bare double-dash separator as an operand' {
            $operands = @(Get-CommandLineOperand -CommandText 'git worktree remove -- --looks-like-a-flag' -CommandWord 'git' -SubcommandPath @('worktree', 'remove'))
            $operands.Count | Should -Be 1
            $operands[0] | Should -Be '--looks-like-a-flag'
        }

        It 'returns an empty array when no segment matched' {
            $operands = @(Get-CommandLineOperand -CommandText 'git log --grep remove' -CommandWord 'git' -SubcommandPath @('worktree', 'remove'))
            $operands.Count | Should -Be 0
        }

        It 'returns the pull-request number for the anchored gh pr merge spelling' {
            $operands = @(Get-CommandLineOperand -CommandText 'gh pr merge 410 --merge' -CommandWord 'gh' -SubcommandPath @('pr', 'merge'))
            $operands | Should -Contain '410'
        }
    }

    Context 'Get-CommandLineFlagValue' {
        It 'recognises the separated form' {
            Get-CommandLineFlagValue -CommandText 'gh pr merge --merge 688' -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge' |
                Should -Be '688'
        }

        It 'recognises the equals form' {
            Get-CommandLineFlagValue -CommandText 'gh pr merge --merge=688' -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge' |
                Should -Be '688'
        }

        It 'resolves the number across a chained cd, which is the issue #591 fix' {
            $text = 'cd C:\Users\DanMoisan\repos\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688'
            Get-CommandLineFlagValue -CommandText $text -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge' |
                Should -Be '688'
        }

        It 'returns null for an absent flag' {
            Get-CommandLineFlagValue -CommandText 'gh pr merge 410' -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge' |
                Should -BeNullOrEmpty
        }

        It 'returns null for a present flag with no following value' {
            Get-CommandLineFlagValue -CommandText 'gh pr merge --merge' -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge' |
                Should -BeNullOrEmpty
        }

        It 'returns null when the following token is itself dash-leading' {
            Get-CommandLineFlagValue -CommandText 'gh pr merge --merge --squash' -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge' |
                Should -BeNullOrEmpty
        }
    }

    Context 'Test-CommandLineFlag' {
        It 'distinguishes an absent flag from a valueless present flag' {
            Test-CommandLineFlag -CommandText 'gh pr merge 410' -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge' |
                Should -BeFalse
            Test-CommandLineFlag -CommandText 'gh pr merge 410 --merge' -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge' |
                Should -BeTrue
        }

        It 'distinguishes --body from --body-file' {
            $text = 'gh pr create --title x --body-file artifacts/pr_body_12.md'
            Test-CommandLineFlag -CommandText $text -CommandWord 'gh' -SubcommandPath @('pr', 'create') -FlagName '--body-file' |
                Should -BeTrue
            Test-CommandLineFlag -CommandText $text -CommandWord 'gh' -SubcommandPath @('pr', 'create') -FlagName '--body' |
                Should -BeFalse
        }

        It 'reports a flag present in the equals form' {
            Test-CommandLineFlag -CommandText 'gh pr merge --merge=688' -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge' |
                Should -BeTrue
        }
    }

    Context 'Test-CommandLineMention' {
        It 'returns true only when the invocation predicate returns false' {
            $mention = 'echo "run git add docs/x to stage the change"'
            Test-CommandLineInvocation -CommandText $mention -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeFalse
            Test-CommandLineMention -CommandText $mention -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeTrue
        }

        It 'returns false for a genuine invocation' {
            Test-CommandLineMention -CommandText 'git add .' -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeFalse
        }

        It 'returns false when the text does not contain the words at all' {
            Test-CommandLineMention -CommandText 'npm run build' -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeFalse
        }
    }

    Context 'fail-closed rules' {
        It 'classifies a wrapper-led segment whose raw text carries the words in any arrangement' {
            Test-CommandLineInvocation -CommandText "bash -c 'git add .'" -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeTrue
            Test-CommandLineInvocation -CommandText 'echo x | xargs git add' -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeTrue
        }

        It 'classifies a live-substitution segment by the same wrapper rule' {
            Test-CommandLineInvocation -CommandText 'echo "$(git add .)"' -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeTrue
        }

        It 'classifies an unbalanced segment, because its structure could not be resolved' {
            Test-CommandLineInvocation -CommandText 'echo "unterminated' -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeTrue
        }

        It 'classifies the subshell and command-substitution spellings' {
            Test-CommandLineInvocation -CommandText '(git add .)' -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeTrue
            Test-CommandLineInvocation -CommandText '$(git add .)' -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeTrue
        }

        It 'does not classify a quoted mention in a non-wrapper segment' {
            Test-CommandLineInvocation -CommandText 'echo "run git add docs/x"' -CommandWord 'git' -SubcommandPath @('add') |
                Should -BeFalse
        }
    }

    Context 'constant tables' {
        It 'exposes exactly the five transparent wrappers of D2 Piece 3 step 2' {
            $expected = @('command', 'env', 'nohup', 'time', 'timeout')
            $actual = @(Get-CommandLineTransparentWrapperName) | Sort-Object
            $actual.Count | Should -Be 5
            ($actual -join ',') | Should -Be ($expected -join ',')
        }

        It 'exposes exactly the modeled git global options' {
            $table = Get-CommandLineGlobalOption -CommandWord 'git'
            (@($table.WithArgument) | Sort-Object) -join ',' |
                Should -Be '--exec-path,--git-dir,--namespace,--work-tree,-C,-c'
            (@($table.Standalone) | Sort-Object) -join ',' |
                Should -Be '--bare,--literal-pathspecs,--no-optional-locks,--no-pager,--paginate,-p'
        }

        It 'exposes exactly the modeled gh global options' {
            $table = Get-CommandLineGlobalOption -CommandWord 'gh'
            (@($table.WithArgument) | Sort-Object) -join ',' | Should -Be '--repo,-R'
            @($table.Standalone).Count | Should -Be 0
        }

        It 'exposes exactly the modeled npx global options' {
            $table = Get-CommandLineGlobalOption -CommandWord 'npx'
            (@($table.WithArgument) | Sort-Object) -join ',' |
                Should -Be '--call,--node-arg,--package,--userconfig,-c,-p'
            (@($table.Standalone) | Sort-Object) -join ',' |
                Should -Be '--ignore-existing,--no-install,--quiet,--yes,-q,-y'
        }

        It 'returns two empty lists for an unmodeled command word, which is fail-closed' {
            $table = Get-CommandLineGlobalOption -CommandWord 'unmodeled'
            @($table.WithArgument).Count | Should -Be 0
            @($table.Standalone).Count | Should -Be 0
        }
    }
}
