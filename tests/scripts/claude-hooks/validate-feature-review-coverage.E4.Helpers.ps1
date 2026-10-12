#Requires -Version 7.0
<#
.SYNOPSIS
    E4 (issue #896) harness and fixtures for validate-feature-review-coverage.Coverage.Tests.ps1.

.DESCRIPTION
    Dot-sourced from the BeforeAll block of the 'E4 (issue #896)' Context in
    validate-feature-review-coverage.Coverage.Tests.ps1. Defines the in-process entry-point
    driver, the SubagentStop envelope builder, the three review-artifact paths, and the
    named fixtures that the Context's Get-ArtifactFileContent mock reads through
    $script:E4ArtifactMap.

    Writes no file. Stdin and stderr are replaced with in-memory readers and writers and
    restored in finally. The entry point is driven through the & route, so no child
    process is started.
#>

function Invoke-ClaudeReviewEntry {
    # Drives the hook entry point with the given stdin; stdin and stderr are restored in finally.
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowEmptyString()] [string] $Stdin)
    $priorIn = [System.Console]::In
    $priorError = [System.Console]::Error
    $errorWriter = [System.IO.StringWriter]::new()
    try {
        [System.Console]::SetIn([System.IO.StringReader]::new($Stdin))
        [System.Console]::SetError($errorWriter)
        $global:LASTEXITCODE = 0
        $stdout = @(& $script:HookFile)
        return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Stdout = (($stdout | ForEach-Object { [string]$_ }) -join "`n"); Stderr = $errorWriter.ToString() }
    }
    finally {
        [System.Console]::SetIn($priorIn)
        [System.Console]::SetError($priorError)
    }
}

function ConvertTo-ClaudeEnvelope {
    # Returns SubagentStop envelope JSON text carrying the given assistant text.
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowEmptyString()] [string] $AssistantText,
        [bool] $StopHookActive = $false
    )
    return ([ordered]@{ session_id = 'e4-896'; hook_event_name = 'SubagentStop'; agent_type = 'feature-review'; stop_hook_active = $StopHookActive; last_assistant_message = $AssistantText } | ConvertTo-Json -Compress)
}

function Use-E4Fixture {
    # Selects a named fixture: its artifact map backs the Context mock, and its assistant text is returned.
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [string] $Name)
    $fixture = $script:E4Fixtures[$Name]
    $script:E4ArtifactMap = $fixture.Map
    return $fixture.Text
}

$script:E4PolicyPath = 'docs/features/active/foo/policy-audit.2026-05-04T08-00.md'
$script:E4CodePath = 'docs/features/active/foo/code-review.2026-05-04T08-00.md'
$script:E4FeaturePath = 'docs/features/active/foo/feature-audit.2026-05-04T08-00.md'
$script:E4Tokens = @(
    "policy-audit-path: $script:E4PolicyPath",
    "code-review-path: $script:E4CodePath",
    "feature-audit-path: $script:E4FeaturePath"
) -join "`n"
$script:E4Fixtures = @{
    MissingToken       = @{
        Text = (@("code-review-path: $script:E4CodePath", "feature-audit-path: $script:E4FeaturePath") -join "`n")
        Map  = @{ $script:E4PolicyPath = @('Python coverage PASS'); $script:E4CodePath = @('code'); $script:E4FeaturePath = @('feature') }
    }
    AbsentArtifact     = @{
        Text = $script:E4Tokens
        Map  = @{}
    }
    NoCoverageRow      = @{
        Text = $script:E4Tokens
        Map  = @{
            $script:E4PolicyPath               = @('Python style PASS'); $script:E4CodePath = @('code'); $script:E4FeaturePath = @('feature')
            'artifacts/pr_context.summary.txt' = @('- src/foo.py (+1/-0)')
        }
    }
    LineBelowFloor     = @{
        Text = $script:E4Tokens
        Map  = @{
            $script:E4PolicyPath               = @('Python coverage PASS'); $script:E4CodePath = @('code'); $script:E4FeaturePath = @('feature')
            'artifacts/pr_context.summary.txt' = @('- src/foo.py (+1/-0)')
            'artifacts/python/lcov.info'       = @('LF:100', 'LH:80', 'BRF:100', 'BRH:80')
        }
    }
    BranchBelowFloor   = @{
        Text = $script:E4Tokens
        Map  = @{
            $script:E4PolicyPath               = @('Python coverage PASS'); $script:E4CodePath = @('code'); $script:E4FeaturePath = @('feature')
            'artifacts/pr_context.summary.txt' = @('- src/foo.py (+1/-0)')
            'artifacts/python/lcov.info'       = @('LF:100', 'LH:90', 'BRF:100', 'BRH:70')
        }
    }
    UnreadableClaudeMd = @{
        Text = $script:E4Tokens
        Map  = @{
            $script:E4PolicyPath               = @('Python coverage PASS'); $script:E4CodePath = @('code'); $script:E4FeaturePath = @('feature')
            'artifacts/pr_context.summary.txt' = @('- src/foo.py (+1/-0)')
            'CLAUDE.md'                        = 'THROW'
        }
    }
    ValidatorError     = @{
        Text = $script:E4Tokens
        Map  = @{
            $script:E4PolicyPath                       = @('PowerShell coverage PASS'); $script:E4CodePath = @('code'); $script:E4FeaturePath = @('feature')
            'artifacts/pr_context.summary.txt'         = @('- scripts/foo.ps1 (+1/-0)')
            'artifacts/pester/powershell-coverage.xml' = @('<report')
        }
    }
    Mixed              = @{
        Text = $script:E4Tokens
        Map  = @{
            $script:E4PolicyPath               = @('Python coverage PASS', 'TypeScript coverage PASS'); $script:E4CodePath = @('code'); $script:E4FeaturePath = @('feature')
            'artifacts/pr_context.summary.txt' = @('- src/a.py (+1/-0)', '- src/b.ts (+1/-0)')
            'artifacts/python/lcov.info'       = @('LF:100', 'LH:80', 'BRF:100', 'BRH:80')
            'coverage/lcov.info'               = @('LF:100', 'LH:90', 'BRF:100', 'BRH:70')
        }
    }
}
