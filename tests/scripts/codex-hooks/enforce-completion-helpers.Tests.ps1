#Requires -Version 7.0

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected FolderExistsCheck stubs mirror the production scriptblock signature')]
param()

<#
.SYNOPSIS
    Branch tests for the Codex completion-consistency helper file (issue #1035, remediation F1).

.DESCRIPTION
    Dot-sources .codex/hooks/enforce-completion-helpers.ps1 after importing the development-docs
    module it depends on, and drives each branch of Test-IsValidIssueNum, Test-IsValidFeatureFolder,
    Test-RouteRequiresPrGate, Get-EditReplaceAllFlag and Invoke-SingleOccurrenceEdit. The folder
    check and the routing-matrix read go through the injected scriptblock seams, except one row per
    seam that runs the default against a path that does not exist or a route that is not defined.
    No row creates a file.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
    # Import the development-docs module only when it is not already loaded, and remove it in
    # AfterAll in that case, so the suite leaves the session's module table as it found it.
    $script:DocsModuleWasLoaded = $null -ne (Get-Module -Name DevelopmentDocsRoot)
    if (-not $script:DocsModuleWasLoaded) {
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/development-docs/DevelopmentDocsRoot.psm1') -ErrorAction Stop
    }
    . (Join-Path $script:HookRoot 'enforce-completion-helpers.ps1')
}

AfterAll {
    if (-not $script:DocsModuleWasLoaded) {
        Remove-Module -Name DevelopmentDocsRoot -ErrorAction SilentlyContinue
    }
}

Describe 'Test-IsValidIssueNum (Codex helpers)' {
    It 'rejects a blank value' {
        Test-IsValidIssueNum -Value '   ' | Should -BeFalse
    }

    It 'rejects a sentinel value in any case' {
        Test-IsValidIssueNum -Value ' TBD ' | Should -BeFalse
    }

    It 'accepts a digits-only value after trimming' {
        Test-IsValidIssueNum -Value ' 1035 ' | Should -BeTrue
    }

    It 'rejects a value that contains a non-digit' {
        Test-IsValidIssueNum -Value '#1035' | Should -BeFalse
    }
}

Describe 'Test-IsValidFeatureFolder (Codex helpers)' {
    BeforeAll {
        $script:Exists = { param($p) $true }
        $script:Missing = { param($p) $false }
    }

    It 'rejects a sentinel value' {
        Test-IsValidFeatureFolder -Value 'n/a' -FolderExistsCheck $script:Exists | Should -BeFalse
    }

    It 'rejects a blank value' {
        Test-IsValidFeatureFolder -Value '' -FolderExistsCheck $script:Exists | Should -BeFalse
    }

    It 'rejects a folder outside every known active area' {
        Test-IsValidFeatureFolder -Value 'docs/features/completed/x-1' -FolderExistsCheck $script:Exists | Should -BeFalse
    }

    It 'rejects the bare active prefix' {
        Test-IsValidFeatureFolder -Value 'docs/features/active/' -FolderExistsCheck $script:Exists | Should -BeFalse
    }

    It 'accepts an existing folder and passes the normalized path to the check' {
        $seen = [System.Collections.Generic.List[string]]::new()
        $check = { param($p) $seen.Add($p); $true }.GetNewClosure()

        Test-IsValidFeatureFolder -Value 'docs\features\active\feature-1035' -FolderExistsCheck $check | Should -BeTrue
        $seen | Should -Be @('docs/features/active/feature-1035')
    }

    It 'rejects a folder that the check reports missing' {
        Test-IsValidFeatureFolder -Value 'docs/features/active/feature-1035' -FolderExistsCheck $script:Missing | Should -BeFalse
    }

    It 'accepts the .dev active area form' {
        Test-IsValidFeatureFolder -Value '.dev/active/feature-1035' -FolderExistsCheck $script:Exists | Should -BeTrue
    }

    It 'uses the default container check, which reports a missing folder' {
        Test-IsValidFeatureFolder -Value 'docs/features/active/no-such-feature-folder-1035-remediation' | Should -BeFalse
    }
}

Describe 'Test-RouteRequiresPrGate (Codex helpers)' {
    BeforeAll {
        $matrix = [pscustomobject]@{
            routes = [pscustomobject]@{
                gated  = [pscustomobject]@{ requires_pr_gate = $true }
                plain  = [pscustomobject]@{ requires_pr_gate = $false }
                noflag = [pscustomobject]@{ name = 'noflag' }
            }
        }
        $script:Reader = { $matrix }.GetNewClosure()
    }

    It 'returns false for a null payload' {
        Test-RouteRequiresPrGate -Payload $null -RoutingMatrixReader $script:Reader | Should -BeFalse
    }

    It 'falls back to path_selected when route_id is absent' {
        $payload = [pscustomobject]@{ path_selected = 'gated' }
        Test-RouteRequiresPrGate -Payload $payload -RoutingMatrixReader $script:Reader | Should -BeTrue
    }

    It 'returns false when neither route_id nor path_selected names a route' {
        $payload = [pscustomobject]@{ route_id = '  ' }
        Test-RouteRequiresPrGate -Payload $payload -RoutingMatrixReader $script:Reader | Should -BeFalse
    }

    It 'returns false when the matrix has no routes' {
        $payload = [pscustomobject]@{ route_id = 'gated' }
        Test-RouteRequiresPrGate -Payload $payload -RoutingMatrixReader { [pscustomobject]@{ version = 1 } } | Should -BeFalse
    }

    It 'returns false for a route the matrix does not define' {
        $payload = [pscustomobject]@{ route_id = 'unknown' }
        Test-RouteRequiresPrGate -Payload $payload -RoutingMatrixReader $script:Reader | Should -BeFalse
    }

    It 'returns false for a route without requires_pr_gate' {
        $payload = [pscustomobject]@{ route_id = 'noflag' }
        Test-RouteRequiresPrGate -Payload $payload -RoutingMatrixReader $script:Reader | Should -BeFalse
    }

    It 'returns false for a route whose flag is false' {
        $payload = [pscustomobject]@{ route_id = 'plain' }
        Test-RouteRequiresPrGate -Payload $payload -RoutingMatrixReader $script:Reader | Should -BeFalse
    }

    It 'returns true for a route whose flag is true, preferring route_id over path_selected' {
        $payload = [pscustomobject]@{ route_id = 'gated'; path_selected = 'plain' }
        Test-RouteRequiresPrGate -Payload $payload -RoutingMatrixReader $script:Reader | Should -BeTrue
    }

    It 'reads the committed routing matrix through the default reader' {
        $payload = [pscustomobject]@{ route_id = 'route-not-defined-1035-remediation' }
        Test-RouteRequiresPrGate -Payload $payload | Should -BeFalse
    }
}

Describe 'Get-EditReplaceAllFlag (Codex helpers)' {
    It 'returns false for a null tool input' {
        Get-EditReplaceAllFlag -ToolInput $null | Should -BeFalse
    }

    It 'returns a boolean value unchanged' {
        Get-EditReplaceAllFlag -ToolInput ([pscustomobject]@{ replace_all = $true }) | Should -BeTrue
    }

    It 'honours the string TRUE in any case' {
        Get-EditReplaceAllFlag -ToolInput ([pscustomobject]@{ replace_all = ' TRUE ' }) | Should -BeTrue
    }

    It 'does not honour the string false' {
        Get-EditReplaceAllFlag -ToolInput ([pscustomobject]@{ replace_all = 'false' }) | Should -BeFalse
    }

    It 'returns false for an integer value' {
        Get-EditReplaceAllFlag -ToolInput ([pscustomobject]@{ replace_all = 1 }) | Should -BeFalse
    }
}

Describe 'Invoke-SingleOccurrenceEdit (Codex helpers)' {
    It 'reports no-old_string for an empty old string' {
        $result = Invoke-SingleOccurrenceEdit -Text 'abc' -OldString '' -NewString 'x'
        $result.Failure | Should -Be 'no-old_string'
        $result.Content | Should -BeNullOrEmpty
    }

    It 'reports old_string-not-found when the old string is absent' {
        (Invoke-SingleOccurrenceEdit -Text 'abc' -OldString 'zz' -NewString 'x').Failure | Should -Be 'old_string-not-found'
    }

    It 'replaces every occurrence when ReplaceAll is set' {
        $result = Invoke-SingleOccurrenceEdit -Text 'a-b-a' -OldString 'a' -NewString 'c' -ReplaceAll $true
        $result.Content | Should -Be 'c-b-c'
        $result.Failure | Should -BeNullOrEmpty
    }

    It 'reports old_string-ambiguous for a second occurrence' {
        (Invoke-SingleOccurrenceEdit -Text 'a-b-a' -OldString 'a' -NewString 'c').Failure | Should -Be 'old_string-ambiguous'
    }

    It 'splices one CRLF occurrence and keeps a dollar sign literal' {
        $result = Invoke-SingleOccurrenceEdit -Text "line1`r`nold`r`nline3" -OldString "`r`nold`r`n" -NewString "`n`$1 new`n"
        $result.Content | Should -Be "line1`n`$1 new`nline3"
        $result.Failure | Should -BeNullOrEmpty
    }
}
