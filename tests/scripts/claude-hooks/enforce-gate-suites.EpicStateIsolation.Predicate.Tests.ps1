#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Predicate rows for the false-pass paths of the epic-state isolation guard (issue #737, CR-2).

.DESCRIPTION
    Each row parses an in-memory fixture and passes it to Get-EpicStateIsolationFinding, so the
    predicate is shown to reject every false-pass shape and to accept the matching compliant
    shape. Every fixture carries both default pairs (EpicScopeResolution and
    WorktreeRunResolution) except for the property its row targets, so a non-compliant fixture
    fails only for its own reason and a compliant fixture yields zero findings. Row names carry
    the prefixes AC-8 through AC-12.

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

Describe 'CR-2 false-pass paths' {
    It 'AC-8 non-compliant ordering against a helper dot-source' {
        # Arrange: a helper dot-source precedes the import and mock, and the hook dot-source
        # follows them, so the pair binds to the wrong module instance.
        $source = @'
Describe 'fixture' {
    BeforeAll {
        $script:UnderTest = Join-Path $PSScriptRoot 'hooks/enforce-x.ps1'
        . (Join-Path $PSScriptRoot 'Helper.ps1')
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        . $script:UnderTest
    }
}
'@
        $ast = ConvertTo-EpicStateFixtureAst -Source $source

        # Act
        $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

        # Assert
        @($findings).Count | Should -BeGreaterThan 0 -Because 'the import and mock precede the hook dot-source'
        ($findings -join '; ') | Should -BeLike '*order violated*'
    }

    It 'AC-8 compliant hook dot-source first' {
        # Arrange: the hook dot-source comes first and the import and mock follow it.
        $source = @'
Describe 'fixture' {
    BeforeAll {
        $script:UnderTest = Join-Path $PSScriptRoot 'hooks/enforce-x.ps1'
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
        $ast = ConvertTo-EpicStateFixtureAst -Source $source

        # Act
        $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

        # Assert
        @($findings).Count | Should -Be 0 -Because ($findings -join '; ')
    }

    It 'AC-9 non-compliant mock and import only inside a function body' {
        # Arrange: both pairs sit inside a function that the BeforeAll never calls.
        $source = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        function Initialize-Isolation {
            Import-Module ./EpicScopeResolution.psm1
            Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
            Import-Module ./WorktreeRunResolution.psm1
            Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        }
    }
}
'@
        $ast = ConvertTo-EpicStateFixtureAst -Source $source

        # Act
        $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

        # Assert
        @($findings).Count | Should -BeGreaterThan 0 -Because 'a function body that is never invoked does not isolate the suite'
    }

    It 'AC-9 compliant direct statements' {
        # Arrange: both pairs are direct statements of the outermost BeforeAll.
        $source = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        function Write-FixtureNote { Write-Output 'unrelated helper' }
    }
}
'@
        $ast = ConvertTo-EpicStateFixtureAst -Source $source

        # Act
        $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

        # Assert
        @($findings).Count | Should -Be 0 -Because ($findings -join '; ')
    }

    It 'AC-10 non-compliant second top-level Describe lacks isolation' {
        # Arrange: two top-level Describe blocks and no file-level BeforeAll. Only the first
        # isolates; the second dot-sources the hook and declares no mock.
        $source = @'
Describe 'first block' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
Describe 'second block' {
    BeforeAll {
        . $script:UnderTest
    }
}
'@
        $ast = ConvertTo-EpicStateFixtureAst -Source $source

        # Act
        $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

        # Assert
        @($findings).Count | Should -BeGreaterThan 0 -Because 'every top-level BeforeAll must isolate, not only the first'
    }

    It 'AC-10 compliant every top-level Describe isolates' {
        # Arrange: both top-level Describe blocks carry both pairs.
        $source = @'
Describe 'first block' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
Describe 'second block' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
        $ast = ConvertTo-EpicStateFixtureAst -Source $source

        # Act
        $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

        # Assert
        @($findings).Count | Should -Be 0 -Because ($findings -join '; ')
    }

    It 'AC-11 non-compliant later non-null Mock of the same seam' {
        # Arrange: a null Mock of Get-EpicScopeCheckpointText is followed by a later Mock of the
        # same seam with a non-null body in the same block.
        $source = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module ./EpicScopeResolution.psm1
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { 'payload' }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
        $ast = ConvertTo-EpicStateFixtureAst -Source $source

        # Act
        $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

        # Assert
        @($findings).Count | Should -BeGreaterThan 0 -Because 'a later non-null Mock of the same seam overrides the null Mock'
        ($findings -join '; ') | Should -BeLike '*not exactly*'
    }

    It 'AC-11 compliant single null Mock' {
        # Arrange: one null Mock per seam.
        $source = @'
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
        $ast = ConvertTo-EpicStateFixtureAst -Source $source

        # Act
        $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

        # Assert
        @($findings).Count | Should -Be 0 -Because ($findings -join '; ')
    }

    It 'AC-12 non-compliant module file name only in a non-import argument' {
        # Arrange: the EpicScopeResolution file name appears only inside a string that is not a
        # module path, and there is no real import of that module.
        $source = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module -Name 'note-EpicScopeResolution.psm1-text'
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
        $ast = ConvertTo-EpicStateFixtureAst -Source $source

        # Act
        $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

        # Assert
        @($findings).Count | Should -BeGreaterThan 0 -Because 'a string that merely contains the file name is not an import path'
        ($findings -join '; ') | Should -BeLike '*Import-Module of EpicScopeResolution.psm1 missing*'
    }

    It 'AC-12 compliant genuine import argument' {
        # Arrange: a Join-Path expression whose string ends with the module file name.
        $source = @'
Describe 'fixture' {
    BeforeAll {
        . $script:UnderTest
        Import-Module (Join-Path $PSScriptRoot 'EpicScopeResolution.psm1')
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Import-Module ./WorktreeRunResolution.psm1
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    }
}
'@
        $ast = ConvertTo-EpicStateFixtureAst -Source $source

        # Act
        $findings = @(Get-EpicStateIsolationFinding -Ast $ast)

        # Assert
        @($findings).Count | Should -Be 0 -Because ($findings -join '; ')
    }
}
