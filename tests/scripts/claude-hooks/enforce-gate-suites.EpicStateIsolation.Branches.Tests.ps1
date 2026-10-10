#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Branch rows for the epic-state isolation guard predicate (issue #737, CR-3).

.DESCRIPTION
    One non-compliant row for each branch of the predicate that had no test row, and compliant
    rows for the shapes that must stay accepted: no outermost BeforeAll; a parse error returned
    as a finding; the EpicScopeResolution import absent while its mock is present; no
    dot-source at all in the BeforeAll; the colon-bound -ModuleName form with a wrong module
    name; a MockWith body that holds a param block; and a non-string module-name element. Every
    fixture carries both default pairs (EpicScopeResolution and WorktreeRunResolution) except
    for the property its row targets, so a non-compliant fixture fails only for its own reason
    and a compliant fixture yields zero findings. Row names carry the prefixes
    AC-13 non-compliant and AC-13 compliant.

    This file loads no hook, creates no file, reads no gitignored state, and runs no git
    command. It builds every input in memory.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Helpers.ps1')

    function ConvertTo-EpicStateFixtureAst {
        # Parse one in-memory fixture into a script block AST.
        param([Parameter(Mandatory)] [string] $Source)
        $tokens = $null
        $errors = $null
        return [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)
    }
}

Describe 'CR-3 predicate branches' {
    It 'AC-13 non-compliant <Branch>' -ForEach @(
        @{
            Branch   = 'no outermost BeforeAll'
            Expected = 'no outermost BeforeAll'
            Source   = @'
Describe 'fixture' {
    It 'has no setup block' { $true | Should -BeTrue }
}
'@
        }
        @{
            Branch   = 'ESR-side import absent with mock present'
            Expected = 'Import-Module of EpicScopeResolution.psm1 missing'
            Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
        }
        @{
            Branch   = 'no dot-source at all in the BeforeAll'
            Expected = 'order violated'
            Source   = @'
Describe 'fixture' {
    BeforeAll {
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
        }
        @{
            Branch   = 'colon-bound -ModuleName form with a wrong module name'
            Expected = 'Mock lacks -ModuleName EpicScopeResolution'
            Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName:WrongModule { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
        }
        @{
            Branch   = 'MockWith body containing a param block'
            Expected = 'not exactly'
            Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { param($Path) $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
        }
        @{
            Branch   = 'non-string module-name element'
            Expected = 'Mock lacks -ModuleName EpicScopeResolution'
            Source   = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName $moduleName { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
        }
    ) {
        # Arrange
        $ast = ConvertTo-EpicStateFixtureAst -Source $Source

        # Act
        $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

        # Assert
        @($findings).Count | Should -BeGreaterThan 0 -Because "the $Branch fixture must be rejected"
        ($findings -join '; ') | Should -BeLike "*$Expected*"
    }

    It 'AC-13 non-compliant parse error returned as a finding' {
        # Arrange: malformed in-memory text.
        $text = 'Describe ( {'

        # Act
        $findings = @(Get-EpicStateIsolationTextFinding -Text $text -RelativePath 'tests/scripts/fixture/Broken.Tests.ps1')

        # Assert: the parse error is returned as a finding that names the path.
        @($findings).Count | Should -Be 1
        $findings[0] | Should -BeLike '*Broken.Tests.ps1: parse error:*'
    }

    It 'AC-13 compliant <Branch>' -ForEach @(
        @{
            Branch = 'colon-bound form with the correct module name'
            Source = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName:EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
        }
        @{
            Branch = 'ESR pair with both import and mock'
            Source = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
        }
        @{
            Branch = 'BeforeAll with the hook dot-source present'
            Source = @'
Describe 'fixture' {
    BeforeAll {
        $hookPath = Join-Path $PSScriptRoot 'hooks/enforce-x.ps1'
        . $hookPath
        Import-Module (Join-Path $PSScriptRoot 'EpicScopeResolution.psm1')
        Mock -CommandName Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -MockWith { $null }
        Import-Module (Join-Path $PSScriptRoot 'WorktreeRunResolution.psm1')
        Mock -CommandName Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -MockWith { $null }
    }
}
'@
        }
    ) {
        # Arrange
        $ast = ConvertTo-EpicStateFixtureAst -Source $Source

        # Act
        $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

        # Assert
        @($findings).Count | Should -Be 0 -Because ($findings -join '; ')
    }
}
