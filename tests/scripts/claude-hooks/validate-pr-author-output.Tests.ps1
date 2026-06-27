#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'validate-pr-author-output.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-pr-author-output.ps1").Path
        . $script:UnderTest
        $script:HookPath = $script:UnderTest
        $script:PwshExe = if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSEdition -eq 'Core') {
            (Get-Process -Id $PID).Path
        } else {
            (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source
        }
    }

    Context 'Get-PrAuthorOutputDecision - allow scenarios' {
        It 'allows when output contains a GitHub PR URL' {
            $json = '{"output":"Opened the PR at https://github.com/drmoisan/drm-copilot/pull/231 successfully."}'
            $decision = Get-PrAuthorOutputDecision -HookInputRaw $json
            $decision['allowed'] | Should -BeTrue
        }

        It 'allows when output contains a PR #<n> reference' {
            $json = '{"output":"Created PR #231 for the feature branch."}'
            $decision = Get-PrAuthorOutputDecision -HookInputRaw $json
            $decision['allowed'] | Should -BeTrue
        }

        It 'allows when output contains a gh pr create confirmation with a PR number' {
            $json = '{"output":"Ran gh pr create and the result was #231."}'
            $decision = Get-PrAuthorOutputDecision -HookInputRaw $json
            $decision['allowed'] | Should -BeTrue
        }

        It 'allows when output contains a gh pr edit confirmation with a PR number' {
            $json = '{"output":"Ran gh pr edit on #231 to update the body."}'
            $decision = Get-PrAuthorOutputDecision -HookInputRaw $json
            $decision['allowed'] | Should -BeTrue
        }
    }

    Context 'Get-PrAuthorOutputDecision - block scenarios' {
        It 'blocks when output is empty' {
            $json = '{"output":""}'
            $decision = Get-PrAuthorOutputDecision -HookInputRaw $json
            $decision['allowed'] | Should -BeFalse
            $decision['reason'] | Should -Match 'PR_AUTHOR_OUTPUT_EMPTY'
        }

        It 'blocks when output has no PR URL or number' {
            $json = '{"output":"I generated a PR body but did not open a pull request."}'
            $decision = Get-PrAuthorOutputDecision -HookInputRaw $json
            $decision['allowed'] | Should -BeFalse
            $decision['reason'] | Should -Match 'PR_AUTHOR_OUTPUT_NO_PR'
        }

        It 'blocks when CLAUDE_HOOK_INPUT content is empty' {
            $decision = Get-PrAuthorOutputDecision -HookInputRaw ''
            $decision['allowed'] | Should -BeFalse
            $decision['reason'] | Should -Match 'PR_AUTHOR_OUTPUT_MISSING'
        }

        It 'blocks when CLAUDE_HOOK_INPUT is malformed JSON' {
            $decision = Get-PrAuthorOutputDecision -HookInputRaw '{not-json'
            $decision['allowed'] | Should -BeFalse
            $decision['reason'] | Should -Match 'PR_AUTHOR_OUTPUT_MALFORMED'
        }

        It 'blocks when the output mentions gh pr create but has no PR number' {
            $json = '{"output":"I intend to run gh pr create later."}'
            $decision = Get-PrAuthorOutputDecision -HookInputRaw $json
            $decision['allowed'] | Should -BeFalse
            $decision['reason'] | Should -Match 'PR_AUTHOR_OUTPUT_NO_PR'
        }
    }

    Context 'Test-PrAuthorOutputReportsPr detection helper' {
        It 'returns false for null/empty/whitespace output' {
            Test-PrAuthorOutputReportsPr -OutputText $null | Should -BeFalse
            Test-PrAuthorOutputReportsPr -OutputText '' | Should -BeFalse
            Test-PrAuthorOutputReportsPr -OutputText '   ' | Should -BeFalse
        }

        It 'returns true for a PR URL' {
            Test-PrAuthorOutputReportsPr -OutputText 'see github.com/o/r/pull/42' | Should -BeTrue
        }

        It 'returns false for prose with no PR reference' {
            Test-PrAuthorOutputReportsPr -OutputText 'No pull request was opened.' | Should -BeFalse
        }
    }

    Context 'script entrypoint (end-to-end)' {
        It 'exits 0 when CLAUDE_HOOK_INPUT reports a PR URL' {
            $prev = $env:CLAUDE_HOOK_INPUT
            try {
                $env:CLAUDE_HOOK_INPUT = '{"output":"Opened https://github.com/o/r/pull/231"}'
                $null = & $script:PwshExe -NoProfile -File $script:HookPath 2>&1
                $LASTEXITCODE | Should -Be 0
            } finally {
                $env:CLAUDE_HOOK_INPUT = $prev
            }
        }

        It 'exits 1 when CLAUDE_HOOK_INPUT is empty' {
            $prev = $env:CLAUDE_HOOK_INPUT
            try {
                $env:CLAUDE_HOOK_INPUT = ''
                $null = & $script:PwshExe -NoProfile -File $script:HookPath 2>&1
                $LASTEXITCODE | Should -Be 1
            } finally {
                $env:CLAUDE_HOOK_INPUT = $prev
            }
        }

        It 'exits 1 when CLAUDE_HOOK_INPUT is malformed JSON' {
            $prev = $env:CLAUDE_HOOK_INPUT
            try {
                $env:CLAUDE_HOOK_INPUT = '{not-json'
                $null = & $script:PwshExe -NoProfile -File $script:HookPath 2>&1
                $LASTEXITCODE | Should -Be 1
            } finally {
                $env:CLAUDE_HOOK_INPUT = $prev
            }
        }
    }
}
