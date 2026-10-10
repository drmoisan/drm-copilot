#Requires -Version 7.0
<#
.SYNOPSIS
    Entry-point coverage for .claude/hooks/validate-pr-author-output.ps1 (issue #786).

.DESCRIPTION
    Runs the hook through the & route with CLAUDE_HOOK_INPUT set for the call and restored in
    finally, so the dependency-decision tail lines and the block and allow exits execute
    in-process. No test creates, renames, moves, or deletes a file.
#>

Describe 'validate-pr-author-output entry point (issue #786)' {
    BeforeAll {
        $script:Hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-pr-author-output.ps1'))

        function Invoke-PrAuthorOutputEntry {
            # Drives the entry point with the given hook input; the environment variable and stderr are restored in finally.
            param([AllowEmptyString()] [string] $HookInput)
            $ErrorActionPreference = 'Continue'
            $priorInput = $env:CLAUDE_HOOK_INPUT
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            $thrown = $null
            try {
                $env:CLAUDE_HOOK_INPUT = $HookInput
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                try { $null = & $script:Hook 2>&1 } catch { $thrown = $_ }
                return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Thrown = $thrown }
            }
            finally {
                $env:CLAUDE_HOOK_INPUT = $priorInput
                [System.Console]::SetError($priorError)
            }
        }
    }

    It 'exits 1 when CLAUDE_HOOK_INPUT is empty' {
        # Arrange: no transcript.
        # Act
        $result = Invoke-PrAuthorOutputEntry -HookInput ''
        # Assert
        $result.ExitCode | Should -Be 1 -Because "$($result.Thrown)"
    }

    It 'exits 0 when the output reports a pull request URL' {
        # Arrange: a transcript whose output names a PR URL.
        $hookInput = '{"output":"Created https://github.com/owner/repo/pull/786"}'
        # Act
        $result = Invoke-PrAuthorOutputEntry -HookInput $hookInput
        # Assert
        $result.ExitCode | Should -Be 0 -Because "$($result.Thrown)"
    }
}
