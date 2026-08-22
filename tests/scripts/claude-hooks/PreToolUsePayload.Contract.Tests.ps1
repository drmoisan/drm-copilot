#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Source-scanning contract test: every PreToolUse hook acquires its payload through the
    shared reader and reads no environment-variable transport of its own (issue #501).

.DESCRIPTION
    This is the structural regression guard for AC-8. It derives the hook set by parsing
    .claude/settings.json rather than hard-coding a list, so a newly registered PreToolUse
    hook is automatically in scope and cannot be added with the old transport.

    Per hook file it asserts two things over the file text:

      (i)  an Import-Module reference to HookPayload.psm1 is present, and the reader entry
           point Read-ClaudeHookRawPayload is called;
      (ii) neither environment-variable transport literal appears anywhere in the file.
           Those literals may appear only inside the shared module's fallback.

    The pair is what makes a bypass expensive: re-introducing the defect requires
    deliberately re-implementing both the transport and the parse.

    Assertion (ii) is a textual scan, so a comment or docstring mentioning the literal is
    a violation too. That is intentional: a hook whose prose still describes the retired
    transport misleads the next reader.

    The derivation runs in the file body, and every value the tests need travels through
    -ForEach data, because Pester expands -ForEach at discovery time while BeforeAll runs
    later in a separate scope.

    Sibling of PreToolUseSchema.Contract.Tests.ps1, which asserts the deny-decision OUTPUT
    schema; this suite asserts the payload INPUT contract. Precedent for source-scanning
    contract tests: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1.

    The suite reads files and parses JSON. It starts no process, writes nothing, creates no
    temporary file, and mocks nothing.
#>

Set-StrictMode -Version Latest

# ---------------------------------------------------------------------------
# Discovery-time derivation. Resolve the repository root by walking up from this
# file's own location, never from the current working directory, so the scan
# behaves identically in the terminal and in Test Explorer.
# ---------------------------------------------------------------------------
$testsRoot = $PSScriptRoot
while ($null -ne $testsRoot -and (Split-Path -Path $testsRoot -Leaf) -ne 'tests') {
    $testsRoot = Split-Path -Path $testsRoot -Parent
}
if ($null -eq $testsRoot) {
    throw "Unable to resolve the 'tests' root by walking up from '$PSScriptRoot'."
}
$contractRepoRoot = Split-Path -Path $testsRoot -Parent
$contractSettingsPath = Join-Path -Path $contractRepoRoot -ChildPath '.claude/settings.json'
$contractSharedModule = '.claude/lib/hook-payload/HookPayload.psm1'

# The two retired transport literals, composed from fragments so this suite's own text
# does not contain either literal verbatim.
$contractForbiddenLiteral = @(
    ('$' + 'env:' + 'CLAUDE_TOOL_' + 'INPUT'),
    ('$' + 'env:' + 'CLAUDE_HOOK_' + 'INPUT')
)

# Derive the registered PreToolUse hook file paths from settings.json: every
# hooks.PreToolUse[].hooks[].command entry in the `pwsh -NoProfile -File <path>` form.
# Deriving the set rather than hard-coding it is what puts a newly registered hook
# automatically in scope.
$contractSettings = Get-Content -LiteralPath $contractSettingsPath -Raw | ConvertFrom-Json
$contractHookPath = [System.Collections.Generic.List[string]]::new()
foreach ($matcherEntry in @($contractSettings.hooks.PreToolUse)) {
    foreach ($hookEntry in @($matcherEntry.hooks)) {
        $command = [string]$hookEntry.command
        if ($command -match '-File\s+(?<path>\S+\.ps1)') {
            $candidate = ($Matches['path'] -replace '\\', '/')
            if (-not $contractHookPath.Contains($candidate)) {
                $contractHookPath.Add($candidate)
            }
        }
    }
}

$contractSuiteCase = @(
    @{
        RepoRoot         = $contractRepoRoot
        HookRelativePath = [string[]]$contractHookPath.ToArray()
        SharedModulePath = $contractSharedModule
        ForbiddenLiteral = $contractForbiddenLiteral
    }
)

$contractHookCase = @(
    $contractHookPath | ForEach-Object {
        @{
            RepoRoot         = $contractRepoRoot
            RelativePath     = $_
            ForbiddenLiteral = $contractForbiddenLiteral
        }
    }
)

Describe 'PreToolUse payload-transport contract' -ForEach $contractSuiteCase {
    Context 'hook-set derivation' {
        It 'derives a non-empty PreToolUse hook set from .claude/settings.json' {
            $HookRelativePath.Count | Should -BeGreaterThan 0
        }

        It 'derives every path under .claude/hooks/ with a .ps1 extension' {
            foreach ($relativePath in $HookRelativePath) {
                $relativePath | Should -BeLike '.claude/hooks/*.ps1' -Because "$relativePath must be a hook script path"
            }
        }

        It 'resolves every derived path to a file that exists on disk' {
            foreach ($relativePath in $HookRelativePath) {
                $full = Join-Path -Path $RepoRoot -ChildPath $relativePath
                (Test-Path -LiteralPath $full -PathType Leaf) |
                    Should -BeTrue -Because "$relativePath is registered in settings.json"
            }
        }
    }

    Context 'the shared module owns the environment fallbacks' {
        It 'reads both environment fallbacks inside the shared module' {
            $full = Join-Path -Path $RepoRoot -ChildPath $SharedModulePath
            $text = Get-Content -LiteralPath $full -Raw

            foreach ($literal in $ForbiddenLiteral) {
                $text.Contains($literal) |
                    Should -BeTrue -Because "the shared module keeps the fallback for '$literal'"
            }
        }

        It 'exports the reader entry point from the shared module' {
            $full = Join-Path -Path $RepoRoot -ChildPath $SharedModulePath
            $text = Get-Content -LiteralPath $full -Raw

            $text | Should -BeLike '*Export-ModuleMember*'
            $text | Should -BeLike '*Read-ClaudeHookRawPayload*'
        }
    }
}

Describe 'PreToolUse hook payload transport' {
    Context 'the shared payload module is the only transport' {
        It 'imports the shared payload module in <RelativePath>' -ForEach $contractHookCase {
            $full = Join-Path -Path $RepoRoot -ChildPath $RelativePath
            $text = Get-Content -LiteralPath $full -Raw

            $text | Should -BeLike '*Import-Module*' -Because "$RelativePath must import the shared payload module"
            $text | Should -BeLike '*HookPayload.psm1*' -Because "$RelativePath must reference the shared payload module"
        }

        It 'calls the shared reader entry point in <RelativePath>' -ForEach $contractHookCase {
            $full = Join-Path -Path $RepoRoot -ChildPath $RelativePath
            $text = Get-Content -LiteralPath $full -Raw

            $text | Should -BeLike '*Read-ClaudeHookRawPayload*' -Because "$RelativePath must acquire its payload stdin-first"
        }

        It 'contains neither retired environment-variable transport literal in <RelativePath>' -ForEach $contractHookCase {
            $full = Join-Path -Path $RepoRoot -ChildPath $RelativePath
            $text = Get-Content -LiteralPath $full -Raw

            foreach ($literal in $ForbiddenLiteral) {
                $text.Contains($literal) |
                    Should -BeFalse -Because "$RelativePath must not read '$literal'; only the shared module may"
            }
        }
    }
}
