#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/hooks/enforce-docs-complete-gate-target.ps1 (issue #1034).

.DESCRIPTION
    Dot-sources the hook, which loads the helper and the shared functions it calls, and tests the
    six helper functions directly with in-memory strings. No row starts a process, runs gh or
    git, or writes a file.
#>

Describe 'enforce-docs-complete-gate-target (issue #1034)' {
    BeforeAll {
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-docs-complete-gate.ps1").Path
    }

    AfterAll {
        Remove-Module -Name HookPayload, DocsCompleteGate, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
    }

    Context 'Read-DocsCompleteGatePlainCommand' {
        It 'reads <Case> as plain' -ForEach @(
            @{ Case = 'concatenated quoting'; Text = "gh pr merge 1'2'`"3`""; Words = 'gh|pr|merge|123' }
            @{ Case = 'a single-quoted body holding operators'; Text = "gh pr merge --subject 'a;`$b&c' 12"; Words = 'gh|pr|merge|--subject|a;$b&c|12' }
            @{ Case = 'a double-quoted body with no expansion'; Text = 'gh pr merge --subject "a b" 12'; Words = 'gh|pr|merge|--subject|a b|12' }
            @{ Case = 'a backslash-newline continuation'; Text = "gh pr merge \`n 12"; Words = 'gh|pr|merge|12' }
            @{ Case = 'surrounding whitespace'; Text = "  gh pr merge 12`n"; Words = 'gh|pr|merge|12' }
            @{ Case = 'an output redirection'; Text = 'gh pr merge 12 >log'; Words = 'gh|pr|merge|12' }
            @{ Case = 'a spaced output redirection'; Text = 'gh pr merge 12 > log'; Words = 'gh|pr|merge|12' }
            @{ Case = 'an appending redirection'; Text = 'gh pr merge 12 >>log'; Words = 'gh|pr|merge|12' }
            @{ Case = 'an input redirection'; Text = 'gh pr merge 12 <in'; Words = 'gh|pr|merge|12' }
            @{ Case = 'a descriptor redirection'; Text = 'gh pr merge 12 2>log'; Words = 'gh|pr|merge|12' }
            @{ Case = 'a descriptor appending redirection'; Text = 'gh pr merge 12 2>>log'; Words = 'gh|pr|merge|12' }
            @{ Case = 'a combined redirection'; Text = 'gh pr merge 12 &>log'; Words = 'gh|pr|merge|12' }
            @{ Case = 'a combined appending redirection'; Text = 'gh pr merge 12 &>>log'; Words = 'gh|pr|merge|12' }
            @{ Case = 'a combined redirection joined to a word'; Text = 'gh pr merge 1a&>log'; Words = 'gh|pr|merge|1a' }
            @{ Case = 'a redirection joined to a word'; Text = 'gh pr merge 1a>log'; Words = 'gh|pr|merge|1a' }
            @{ Case = 'a descriptor duplication'; Text = 'gh pr merge 12 2>&1'; Words = 'gh|pr|merge|12' }
            @{ Case = 'a bare duplication'; Text = 'gh pr merge 12 >&2'; Words = 'gh|pr|merge|12' }
            @{ Case = 'a descriptor close'; Text = 'gh pr merge 12 2>&-'; Words = 'gh|pr|merge|12' }
            @{ Case = 'two redirections'; Text = 'gh pr merge 12 >log 2>&1'; Words = 'gh|pr|merge|12' }
            @{ Case = 'digits directly before the operator'; Text = 'gh pr merge 12>x'; Words = 'gh|pr|merge' }
            @{ Case = 'a redirection followed by a comment'; Text = 'gh pr merge 12 2>&1 # note'; Words = 'gh|pr|merge|12' }
            @{ Case = 'a comment holding operators'; Text = 'gh pr merge 12 # note; echo done'; Words = 'gh|pr|merge|12' }
            @{ Case = '# inside a word'; Text = 'gh pr merge a#b'; Words = 'gh|pr|merge|a#b' }
            @{ Case = '# inside quotes'; Text = 'gh pr merge "#12"'; Words = 'gh|pr|merge|#12' }
            @{ Case = 'a continuation with a blank before it, before the subcommand'; Text = "gh pr \`nmerge 12"; Words = 'gh|pr|merge|12' }
            @{ Case = 'a continuation with a blank after it'; Text = "gh pr merge\`n 12"; Words = 'gh|pr|merge|12' }
        ) {
            # Act
            $result = Read-DocsCompleteGatePlainCommand -CommandText $Text

            # Assert
            $result.IsPlain | Should -BeTrue
            ($result.Words -join '|') | Should -BeExactly $Words
        }

        It 'reads <Case> as not plain' -ForEach @(
            @{ Case = 'a semicolon'; Text = 'gh pr merge 12;' }
            @{ Case = 'a pipe'; Text = 'gh pr merge 12 | cat' }
            @{ Case = 'an ampersand'; Text = 'gh pr merge 12 &' }
            @{ Case = 'an ampersand joined to a word'; Text = 'gh pr merge 12&' }
            @{ Case = 'an opening parenthesis'; Text = '(gh pr merge 12' }
            @{ Case = 'a closing parenthesis'; Text = 'gh pr merge 12)' }
            @{ Case = 'an opening brace'; Text = 'gh pr merge {12..12}' }
            @{ Case = 'a closing brace'; Text = 'gh pr merge 12}' }
            @{ Case = 'an asterisk'; Text = 'gh pr merge *' }
            @{ Case = 'a question mark'; Text = 'gh pr merge 1?' }
            @{ Case = 'a tilde'; Text = 'gh pr merge ~' }
            @{ Case = 'a dollar sign'; Text = 'gh pr merge $PR' }
            @{ Case = 'a backtick'; Text = 'gh pr merge `x`' }
            @{ Case = 'a backslash'; Text = 'gh pr merge 1\2' }
            @{ Case = 'an unquoted newline'; Text = "gh pr view 1`ngh pr merge 12" }
            @{ Case = 'a double-quoted dollar sign'; Text = 'gh pr merge "$PR"' }
            @{ Case = 'a double-quoted backtick'; Text = 'gh pr merge "`x`"' }
            @{ Case = 'a double-quoted backslash'; Text = 'gh pr merge "1\2"' }
            @{ Case = 'a word after a redirection'; Text = 'gh pr merge 2>&1 12' }
            @{ Case = 'a word after a file redirection'; Text = 'gh pr merge >log 12' }
            @{ Case = 'a duplication to a file name'; Text = 'gh pr merge >&log' }
            @{ Case = 'a heredoc operator'; Text = 'gh pr merge 12 <<EOF' }
            @{ Case = 'a redirection with no target'; Text = 'gh pr merge 12 >' }
            @{ Case = 'a redirection whose target is a comment'; Text = 'gh pr merge 12 > #x' }
            @{ Case = 'a comment followed by a newline'; Text = "gh pr merge 12 # note`ngh pr merge 99" }
            @{ Case = 'an unbalanced single quote'; Text = "gh pr merge 'unbalanced" }
            @{ Case = 'an unbalanced double quote'; Text = 'gh pr merge "unbalanced' }
            @{ Case = 'a comment ending in a backslash-newline'; Text = "gh pr merge 34 # x\`ngh pr merge 12" }
            @{ Case = 'a backslash-newline before a comment'; Text = "gh pr merge \`n12 # note" }
            @{ Case = 'a comment with a CRLF continuation'; Text = "gh pr merge 34 # x\`r`ngh pr merge 12" }
            @{ Case = 'a word split by a backslash-newline'; Text = "gh pr mer\`nge 12" }
            @{ Case = 'a word split by a CRLF continuation'; Text = "gh pr mer\`r`nge 12" }
        ) {
            # Act
            $result = Read-DocsCompleteGatePlainCommand -CommandText $Text

            # Assert
            $result.IsPlain | Should -BeFalse
            @($result.Words).Count | Should -Be 0
        }

        It 'returns the empty result for blank text (<Case>)' -ForEach @(
            @{ Case = 'empty'; Text = '' }
            @{ Case = 'spaces'; Text = '   ' }
        ) {
            # Act
            $result = Read-DocsCompleteGatePlainCommand -CommandText $Text

            # Assert
            $result.IsPlain | Should -BeTrue
            @($result.Words).Count | Should -Be 0
        }
    }

    Context 'Get-DocsCompleteGateUnquotedView' {
        It 'blanks a quoted span' {
            # Act
            $view = Get-DocsCompleteGateUnquotedView -CommandText "echo 'gh pr merge 12' `"gh pr merge 13`""

            # Assert
            $view | Should -Match 'echo'
            $view | Should -Not -Match 'merge'
        }

        It 'blanks a heredoc body' {
            # Act
            $view = Get-DocsCompleteGateUnquotedView -CommandText "cat <<EOF`ngh pr merge 12`nEOF"

            # Assert
            $view | Should -Match 'cat'
            $view | Should -Not -Match 'merge'
        }

        It 'keeps an unquoted merge across 2>&1' {
            # Act
            $view = Get-DocsCompleteGateUnquotedView -CommandText 'gh pr merge 2>&1 12'

            # Assert
            $view | Should -Match 'gh pr merge'
            $view | Should -Match '12'
        }

        It 'removes a backslash from an unquoted word' {
            # Act
            $view = Get-DocsCompleteGateUnquotedView -CommandText 'g\h pr merge 12'

            # Assert
            $view | Should -Match 'gh pr merge 12'
        }
    }

    Context 'Test-DocsCompleteGateMergeText' {
        It 'returns <Expected> for <Case>' -ForEach @(
            @{ Case = 'the gh pr merge words'; Text = 'gh pr merge 12'; MutationText = ''; Expected = $true }
            @{ Case = 'gh api with a mutation'; Text = 'gh api x'; MutationText = 'gh api -X PUT repos/o/r/pulls/12/merge'; Expected = $true }
            @{ Case = 'gh api with no mutation'; Text = 'gh api x'; MutationText = 'gh api user'; Expected = $false }
            @{ Case = 'no words'; Text = 'git status'; MutationText = 'git status'; Expected = $false }
        ) {
            # Act
            $result = Test-DocsCompleteGateMergeText -Text $Text -MutationText $MutationText

            # Assert
            $result | Should -Be $Expected
        }
    }

    Context 'Test-DocsCompleteGateMergeCandidate' {
        It 'returns <Expected> for <Case>' -ForEach @(
            @{ Case = 'step 1, a plain merge'; Text = 'gh pr merge 12'; Expected = $true }
            @{ Case = 'step 1, --disable-auto only'; Text = 'gh pr merge 12 --disable-auto'; Expected = $false }
            @{ Case = 'step 1, --disable-auto with an action flag'; Text = 'gh pr merge 12 --disable-auto --merge'; Expected = $true }
            @{ Case = 'step 1, unreadable operands'; Text = 'gh pr merge 12 13 --disable-auto'; Expected = $true }
            @{ Case = 'step 1, a plain command the walk does not match'; Text = 'gh pr view 12'; Expected = $false }
            @{ Case = 'step 1, a gh api merge the shared predicate admits'; Text = 'gh api -X PUT repos/o/r/pulls/12/merge'; Expected = $true }
            @{ Case = 'step 1, a terminal option'; Text = 'gh --help pr merge'; Expected = $false }
            @{ Case = 'step 1, an unmodeled option'; Text = 'gh --help=false pr merge 12'; Expected = $true }
            @{ Case = 'step 2, a merge in a list'; Text = 'gh pr merge 12; echo done'; Expected = $true }
            @{ Case = 'step 2, a merge under a wrapper'; Text = 'timeout 30 gh pr merge 12'; Expected = $true }
            @{ Case = 'step 3, a merge after a keyword'; Text = 'if true; then exec gh pr merge 12; fi'; Expected = $true }
            @{ Case = 'step 3, case-insensitive words'; Text = 'echo GH PR MERGE'; Expected = $true }
            @{ Case = 'step 3, an unquoted api word with a quoted endpoint'; Text = "echo gh api 'repos/o/r/pulls/12/merge'"; Expected = $true }
            @{ Case = 'step 3, an unquoted api word with no endpoint'; Text = 'echo gh api status'; Expected = $false }
            @{ Case = 'step 3, a quoted mention'; Text = "echo 'gh pr merge 12'"; Expected = $false }
            @{ Case = 'step 3, words out of order'; Text = 'echo merge pr gh'; Expected = $false }
            @{ Case = 'step 3, a word that only contains gh'; Text = 'echo through pr merge'; Expected = $false }
            @{ Case = 'step 3, an unrelated command'; Text = 'git status'; Expected = $false }
            @{ Case = 'step 3, blank text'; Text = ''; Expected = $false }
            @{ Case = 'step 3, a backslash in a word'; Text = 'g\h pr merge 12'; Expected = $true }
            @{ Case = 'step 3, a word split by a backslash-newline'; Text = "gh pr mer\`nge 12"; Expected = $true }
            @{ Case = 'step 3, a quoted merge beside an evaluator word'; Text = "if true; then sh -c 'gh pr merge 12'; fi"; Expected = $true }
            @{ Case = 'step 3, a quoted gh api merge beside an evaluator word'; Text = "if true; then sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'; fi"; Expected = $true }
            @{ Case = 'step 3, a quoted merge with no evaluator word'; Text = "git commit -m 'gh pr merge 12'"; Expected = $false }
            @{ Case = 'step 3, an evaluator word with no merge words'; Text = "if true; then sh -c 'echo hi'; fi"; Expected = $false }
            @{ Case = 'step 3, an evaluator word with words out of order'; Text = "if true; then sh -c 'merge pr gh'; fi"; Expected = $false }
        ) {
            # Act
            $result = Test-DocsCompleteGateMergeCandidate -CommandText $Text

            # Assert
            $result | Should -Be $Expected
        }
    }

    Context 'Read-DocsCompleteGateMergeOperand' {
        It 'reports DisableAutoOnly <Expected> for <Case>' -ForEach @(
            @{ Case = '--disable-auto'; Token = @('12', '--disable-auto'); Expected = $true }
            @{ Case = '--disable-auto --merge'; Token = @('12', '--disable-auto', '--merge'); Expected = $false }
            @{ Case = '-s --disable-auto'; Token = @('12', '-s', '--disable-auto'); Expected = $false }
            @{ Case = 'a flag value equal to --disable-auto'; Token = @('12', '--subject', '--disable-auto'); Expected = $false }
            @{ Case = 'a flag value skipped before --disable-auto'; Token = @('12', '--subject', '--merge', '--disable-auto'); Expected = $true }
            @{ Case = '--disable-auto=false'; Token = @('12', '--disable-auto=false'); Expected = $false }
            @{ Case = '--disable-auto=true'; Token = @('12', '--disable-auto=true'); Expected = $false }
            @{ Case = '--disable-auto --disable-auto=false'; Token = @('12', '--disable-auto', '--disable-auto=false'); Expected = $false }
            @{ Case = '--disable-auto --auto=false'; Token = @('12', '--disable-auto', '--auto=false'); Expected = $false }
        ) {
            # Act
            $result = Read-DocsCompleteGateMergeOperand -Token $Token -StartIndex 0

            # Assert
            $result.Readable | Should -BeTrue
            $result.DisableAutoOnly | Should -Be $Expected
        }

        It 'reads selector <Expected> for <Case>' -ForEach @(
            @{ Case = '--merge=1'; Token = @('--merge=1'); Expected = $null }
            @{ Case = '--merge=0'; Token = @('--merge=0'); Expected = $null }
            @{ Case = '--merge=12'; Token = @('--merge=12'); Expected = '12' }
            @{ Case = '--merge=true'; Token = @('--merge=true'); Expected = $null }
            @{ Case = 'a positional after --merge=1'; Token = @('--merge=1', '12'); Expected = '12' }
            @{ Case = 'a selector after the separator'; Token = @('--merge', '--', 'epic/x-integration'); Expected = 'epic/x-integration' }
            @{ Case = 'a short cluster'; Token = @('-sd', '12'); Expected = '12' }
            @{ Case = 'a value letter ending a cluster'; Token = @('-sb', '99', '12'); Expected = '12' }
        ) {
            # Act
            $result = Read-DocsCompleteGateMergeOperand -Token $Token -StartIndex 0

            # Assert
            $result.Readable | Should -BeTrue
            $result.Selector | Should -Be $Expected
        }

        It 'reads the repository values and the head pin' {
            # Act
            $result = Read-DocsCompleteGateMergeOperand -Token @('pr', 'merge', '12', '-Ra/b', '--repo=c/d', '--match-head-commit', 'abc') -StartIndex 2

            # Assert
            $result.Selector | Should -BeExactly '12'
            ($result.Repository -join '|') | Should -BeExactly 'a/b|c/d'
            $result.MatchHeadCommit | Should -BeExactly 'abc'
        }

        It 'reads <Case> as unreadable' -ForEach @(
            @{ Case = 'an unknown long flag'; Token = @('12', '--unknown') }
            @{ Case = 'an unknown long flag with a following word'; Token = @('12', '--unknown', 'x') }
            @{ Case = 'an unknown short letter'; Token = @('12', '-z') }
            @{ Case = 'an equals sign after a standalone letter'; Token = @('12', '-s=false') }
            @{ Case = 'a value flag with no value'; Token = @('12', '--repo') }
            @{ Case = 'two selectors'; Token = @('12', '13') }
            @{ Case = 'an empty selector'; Token = @('') }
            @{ Case = 'a dash selector'; Token = @('-') }
            @{ Case = 'a dash-led selector after the separator'; Token = @('--', '-x') }
            @{ Case = 'a non-literal selector'; Token = @('$PR') }
        ) {
            # Act
            $result = Read-DocsCompleteGateMergeOperand -Token $Token -StartIndex 0

            # Assert
            $result.Readable | Should -BeFalse
            $result.DisableAutoOnly | Should -BeFalse
        }
    }

    Context 'Get-DocsCompleteGateMergeTarget' {
        It 'returns the selector, repository and pin of a plain form' {
            # Act
            $target = Get-DocsCompleteGateMergeTarget -CommandText 'gh --repo a/b pr merge 12 --match-head-commit abc 2>&1'

            # Assert
            $target.Reason | Should -BeNullOrEmpty
            $target.Selector | Should -BeExactly '12'
            $target.Repository | Should -BeExactly 'a/b'
            $target.MatchHeadCommit | Should -BeExactly 'abc'
        }

        It 'returns no selector and no repository for a bare merge' {
            # Act
            $target = Get-DocsCompleteGateMergeTarget -CommandText 'gh pr merge --squash'

            # Assert
            $target.Reason | Should -BeNullOrEmpty
            $target.Selector | Should -BeNullOrEmpty
            $target.Repository | Should -BeNullOrEmpty
        }

        It 'keeps the selector of <Case>' -ForEach @(
            @{ Case = 'a comment holding operators'; Text = 'gh pr merge 12 # note; echo done' }
            @{ Case = 'a comment with a number'; Text = 'gh pr merge 12 #99' }
            @{ Case = 'a continuation before the selector'; Text = "gh pr merge \`n12" }
            @{ Case = 'a continuation before the subcommand'; Text = "gh pr \`nmerge 12" }
        ) {
            # Act
            $target = Get-DocsCompleteGateMergeTarget -CommandText $Text

            # Assert
            $target.Reason | Should -BeNullOrEmpty
            $target.Selector | Should -BeExactly '12'
        }

        It 'returns PR_UNRESOLVED for <Case>' -ForEach @(
            @{ Case = 'a first word in another case'; Text = 'GH pr merge 12' }
            @{ Case = 'a first word with a path'; Text = '/usr/bin/gh pr merge 12' }
            @{ Case = 'a first word with an extension'; Text = 'gh.exe pr merge 12' }
            @{ Case = 'an assignment prefix'; Text = 'GH_REPO=a/b gh pr merge 12' }
            @{ Case = 'a command that is not plain'; Text = 'gh pr merge 12;' }
            @{ Case = 'a comment only'; Text = '# note' }
            @{ Case = 'a plain gh command that is not a merge'; Text = 'gh api -X PUT repos/o/r/pulls/12/merge' }
            @{ Case = 'unreadable operands'; Text = 'gh pr merge 12 13' }
            @{ Case = 'a repository of the wrong shape'; Text = 'gh pr merge 12 --repo bad' }
            @{ Case = 'two repository values'; Text = 'gh --repo a/b pr merge 12 -R c/d' }
        ) {
            # Act
            $target = Get-DocsCompleteGateMergeTarget -CommandText $Text

            # Assert
            $target.Reason | Should -BeExactly 'PR_UNRESOLVED'
            $target.Message | Should -Match 'does not name one pull request'
            $target.Message | Should -Match 'one plain gh pr merge'
            $target.Selector | Should -BeNullOrEmpty
        }
    }
}
