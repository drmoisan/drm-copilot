<#
.SYNOPSIS
    Pester v5.x unit tests for the validate-bash.ps1 Claude Code pre-tool-use hook.

.DESCRIPTION
    Exercises all 6 blocked command patterns, safe-command pass-through,
    empty-input handling, malformed-JSON fallback, and valid-JSON command
    extraction for the validate-bash.ps1 pre-tool-use hook.

    The production script is invoked directly via its resolved path.
    Environment variable state (CLAUDE_TOOL_INPUT) is saved and restored
    around each test that modifies it.
#>

Set-StrictMode -Version Latest

Describe "validate-bash.ps1" {
    BeforeAll {
        # Resolve the production script path relative to the repo root.
        $script:ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.claude', 'hooks', 'validate-bash.ps1'
        $script:ScriptPath = (Resolve-Path $script:ScriptPath).Path
    }

    Context "Blocked patterns" {
        It "blocks 'rm -rf' commands with exit code 1" {
            # Override ErrorActionPreference so Write-Error in the production
            # script does not become a terminating error under PoshQC's Stop preference.
            $ErrorActionPreference = 'Continue'
            & $script:ScriptPath 'rm -rf /some/path' 2>$null
            $LASTEXITCODE | Should -Be 1
        }

        It "blocks 'git push --force' commands with exit code 1" {
            $ErrorActionPreference = 'Continue'
            & $script:ScriptPath 'git push --force' 2>$null
            $LASTEXITCODE | Should -Be 1
        }

        It "blocks 'git push origin --force' commands with exit code 1" {
            $ErrorActionPreference = 'Continue'
            & $script:ScriptPath 'git push origin --force' 2>$null
            $LASTEXITCODE | Should -Be 1
        }

        It "blocks 'Remove-Item -Recurse -Force' commands with exit code 1" {
            $ErrorActionPreference = 'Continue'
            & $script:ScriptPath 'Remove-Item -Recurse -Force C:\temp' 2>$null
            $LASTEXITCODE | Should -Be 1
        }

        It "blocks 'git reset --hard' commands with exit code 1" {
            $ErrorActionPreference = 'Continue'
            & $script:ScriptPath 'git reset --hard' 2>$null
            $LASTEXITCODE | Should -Be 1
        }

        It "blocks 'git push -f' commands with exit code 1" {
            $ErrorActionPreference = 'Continue'
            & $script:ScriptPath 'git push -f' 2>$null
            $LASTEXITCODE | Should -Be 1
        }
    }

    Context "Safe commands" {
        It "allows 'ls -la' with exit code 0" {
            & $script:ScriptPath 'ls -la'
            $LASTEXITCODE | Should -Be 0
        }

        It "allows 'git status' with exit code 0" {
            & $script:ScriptPath 'git status'
            $LASTEXITCODE | Should -Be 0
        }

        It "allows 'echo hello' with exit code 0" {
            & $script:ScriptPath 'echo hello'
            $LASTEXITCODE | Should -Be 0
        }
    }

    Context "Empty input" {
        It "exits with code 0 when no command is provided" {
            # Save and clear the environment variable to ensure empty-input path.
            $savedEnv = $env:CLAUDE_TOOL_INPUT
            $env:CLAUDE_TOOL_INPUT = $null
            try {
                & $script:ScriptPath
                $LASTEXITCODE | Should -Be 0
            }
            finally {
                $env:CLAUDE_TOOL_INPUT = $savedEnv
            }
        }
    }

    Context "Malformed JSON in CLAUDE_TOOL_INPUT" {
        AfterEach {
            # Restore the environment variable after each test.
            $env:CLAUDE_TOOL_INPUT = $null
        }

        It "falls back to raw environment variable value when JSON is malformed" {
            # Set malformed JSON containing a blocked pattern so the
            # fallback text itself triggers the block.
            $ErrorActionPreference = 'Continue'
            $env:CLAUDE_TOOL_INPUT = 'not-valid-json rm -rf /danger'
            & $script:ScriptPath 2>$null
            $LASTEXITCODE | Should -Be 1
        }

        It "falls back to raw environment variable value when JSON is malformed and value is safe" {
            $env:CLAUDE_TOOL_INPUT = 'not-json-but-safe'
            & $script:ScriptPath
            $LASTEXITCODE | Should -Be 0
        }
    }

    Context "CLAUDE_TOOL_INPUT with valid JSON" {
        AfterEach {
            $env:CLAUDE_TOOL_INPUT = $null
        }

        It "reads command from JSON 'command' field" {
            # Valid JSON with a blocked command in the 'command' field.
            $ErrorActionPreference = 'Continue'
            $env:CLAUDE_TOOL_INPUT = '{"command":"rm -rf /tmp"}'
            & $script:ScriptPath 2>$null
            $LASTEXITCODE | Should -Be 1
        }

        It "reads safe command from JSON 'command' field and exits 0" {
            $env:CLAUDE_TOOL_INPUT = '{"command":"git status"}'
            & $script:ScriptPath
            $LASTEXITCODE | Should -Be 0
        }
    }
}
