#Requires -Version 7.0
<#
.SYNOPSIS
    Entry-point coverage for .claude/hooks/validate-planner-output.ps1 (issue #786).

.DESCRIPTION
    Runs the hook through the & route with CLAUDE_HOOK_INPUT set for the call and restored in
    finally, so the dependency-decision tail lines and the block exit execute in-process. No
    test creates, renames, moves, or deletes a file.
#>

Describe 'validate-planner-output entry point (issue #786)' {
    BeforeAll {
        $script:Hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-planner-output.ps1'))

        function Invoke-PlannerOutputEntry {
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

    It 'blocks when CLAUDE_HOOK_INPUT is empty' {
        # Arrange: no transcript.
        # Act
        $result = Invoke-PlannerOutputEntry -HookInput ''
        # Assert: the hook sets $ErrorActionPreference = 'Stop', so the Write-Error that precedes exit 1 terminates the script.
        $result.Thrown | Should -Not -BeNullOrEmpty
        [string]$result.Thrown | Should -Match 'CLAUDE_HOOK_INPUT is empty'
    }
}
