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

        function New-SubagentStopEnvelopeJson {
            # Builds a SubagentStop stdin envelope; -OmitAssistantMessage drops last_assistant_message and -OutputField adds an output key.
            param([AllowEmptyString()] [string] $AssistantMessage = '', [switch] $OmitAssistantMessage, [string] $OutputField, [switch] $StopHookActive)
            $envelope = [ordered]@{ session_id = 'e3-905'; hook_event_name = 'SubagentStop'; agent_type = 'pr-author'; stop_hook_active = [bool]$StopHookActive }
            if (-not $OmitAssistantMessage) { $envelope['last_assistant_message'] = $AssistantMessage }
            if ($PSBoundParameters.ContainsKey('OutputField')) { $envelope['output'] = $OutputField }
            return ($envelope | ConvertTo-Json -Compress)
        }
    }

    Context 'Get-PrAuthorOutputDecision - allow scenarios' {
        It 'allows when output contains a GitHub PR URL' {
            $inputText = New-SubagentStopEnvelopeJson -AssistantMessage 'Opened the PR at https://github.com/drmoisan/drm-copilot/pull/231 successfully.'
            $decision = Get-PrAuthorOutputDecision -InputText $inputText
            $decision['allowed'] | Should -BeTrue
        }

        It 'allows when output contains a PR #<n> reference' {
            $inputText = New-SubagentStopEnvelopeJson -AssistantMessage 'Created PR #231 for the feature branch.'
            $decision = Get-PrAuthorOutputDecision -InputText $inputText
            $decision['allowed'] | Should -BeTrue
        }

        It 'allows when output contains a gh pr create confirmation with a PR number' {
            $inputText = New-SubagentStopEnvelopeJson -AssistantMessage 'Ran gh pr create and the result was #231.'
            $decision = Get-PrAuthorOutputDecision -InputText $inputText
            $decision['allowed'] | Should -BeTrue
        }

        It 'allows when output contains a gh pr edit confirmation with a PR number' {
            $inputText = New-SubagentStopEnvelopeJson -AssistantMessage 'Ran gh pr edit on #231 to update the body.'
            $decision = Get-PrAuthorOutputDecision -InputText $inputText
            $decision['allowed'] | Should -BeTrue
        }
    }

    Context 'Get-PrAuthorOutputDecision - block scenarios' {
        It 'blocks with PR_AUTHOR_OUTPUT_EMPTY when the assistant message is blank' {
            $inputText = New-SubagentStopEnvelopeJson -AssistantMessage ''
            $decision = Get-PrAuthorOutputDecision -InputText $inputText
            $decision['allowed'] | Should -BeFalse
            $decision['reason'] | Should -Match 'PR_AUTHOR_OUTPUT_EMPTY'
        }

        It 'blocks when output has no PR URL or number' {
            $inputText = New-SubagentStopEnvelopeJson -AssistantMessage 'I generated a PR body but did not open a pull request.'
            $decision = Get-PrAuthorOutputDecision -InputText $inputText
            $decision['allowed'] | Should -BeFalse
            $decision['reason'] | Should -Match 'PR_AUTHOR_OUTPUT_NO_PR'
        }

        It 'blocks with a payload anomaly when the input text is empty' {
            $decision = Get-PrAuthorOutputDecision -InputText ''
            $decision['allowed'] | Should -BeFalse
            $decision['reason'] | Should -Match 'PR_AUTHOR_OUTPUT_MALFORMED: payload anomaly'
        }

        It 'blocks with a payload anomaly when the input text is malformed JSON' {
            $decision = Get-PrAuthorOutputDecision -InputText '{not-json'
            $decision['allowed'] | Should -BeFalse
            $decision['reason'] | Should -Match 'PR_AUTHOR_OUTPUT_MALFORMED: payload anomaly'
        }

        It 'blocks when the output mentions gh pr create but has no PR number' {
            $inputText = New-SubagentStopEnvelopeJson -AssistantMessage 'I intend to run gh pr create later.'
            $decision = Get-PrAuthorOutputDecision -InputText $inputText
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
        It 'exits 2 in a separate process when the stdin envelope lacks a PR reference' -Tag 'E3-Entry' {
            # Arrange: a valid envelope whose last assistant message reports no pull request.
            $stdinText = New-SubagentStopEnvelopeJson -AssistantMessage 'I generated a PR body but did not open a pull request.'
            # Act
            $global:LASTEXITCODE = 0
            $null = $stdinText | & $script:PwshExe -NoProfile -File $script:HookPath 2>&1
            # Assert
            $LASTEXITCODE | Should -Be 2
        }
    }
}
