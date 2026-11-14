#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Property tests for the pure functions of .claude/lib/docs/DocsLedgerCommands.psm1 and
    .claude/lib/docs/DocsCoverageReport.psm1.

.DESCRIPTION
    Exhaustive enumeration of every operation and option for Test-DocsUpdateLedgerArgument and
    of modes, revisions and the WriteReceipt switch for Test-DocsValidateArgument. No file is
    written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsSchema', 'DocsProfile', 'DocsLedger', 'DocsLedgerRules', 'DocsParity', 'DocsEvidencePins', 'DocsStaleness', 'DocsReceipt', 'DocsValidation', 'DocsLedgerMutation', 'DocsLedgerCommands', 'DocsValidateCommands') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:ElementId = 'cli-command-' + ('a' * 64)
    $script:Revision = '0123456789abcdef0123456789abcdef01234567'
    # Valid values per option, and the option set each operation accepts beyond the common options.
    $script:OptionValue = [ordered]@{
        Profile = 'p.json'; Element = $script:ElementId; Limit = 'diagnostic-' + ('b' * 64); Disposition = 'documented'
        Page = [string[]]@('docs/reference/Cli.md'); Rationale = 'Reason.'; Owner = 'docs-team'; Target = 'Next release'
        Dimension = 'exists'; State = 'pass'; Claim = 'Claim.'; Write = $true
    }
    $script:Permitted = @{
        'set-disposition' = @('Profile', 'Write', 'Element', 'Limit', 'Disposition', 'Page', 'Rationale', 'Owner', 'Target')
        'remove-entry'    = @('Profile', 'Write', 'Element', 'Limit')
        'pin'             = @('Profile', 'Write', 'Element', 'Page', 'Claim')
        'unpin'           = @('Profile', 'Write', 'Element', 'Page')
        'set-dimension'   = @('Profile', 'Write', 'Element', 'Page', 'Dimension', 'State', 'Rationale')
        'sync-refs'       = @('Profile', 'Write')
    }
    $script:Base = @{
        'set-disposition' = @('Element', 'Disposition')
        'remove-entry'    = @('Element')
        'pin'             = @('Element', 'Page')
        'unpin'           = @('Element', 'Page')
        'set-dimension'   = @('Element', 'Page', 'Dimension', 'State')
        'sync-refs'       = @()
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'DocsLedgerCommands argument properties' {
    It 'property Test-DocsUpdateLedgerArgument: one finding exactly when an option is outside the operation set (every operation and option)' {
        $checked = 0
        foreach ($operation in $script:Permitted.Keys) {
            foreach ($option in $script:OptionValue.Keys) {
                # Arrange: the minimal valid argument map plus one option.
                $argument = [ordered]@{ Operation = $operation; ActorKind = 'tool'; ActorId = 'fixture-tool' }
                foreach ($name in $script:Base[$operation]) { $argument[$name] = $script:OptionValue[$name] }
                $argument[$option] = $script:OptionValue[$option]
                $outside = $script:Permitted[$operation] -cnotcontains $option
                # Limit beside the base Element is the exclusive-target rule, a finding even though Limit is in the set.
                $exclusive = $option -ceq 'Limit' -and $script:Base[$operation] -ccontains 'Element'

                # Act
                $finding = Test-DocsUpdateLedgerArgument -Argument $argument

                # Assert
                if ($outside -or $exclusive) {
                    $null -eq $finding | Should -BeFalse -Because "$operation with -$option (outside=$outside exclusive=$exclusive)"
                    $finding['code'] | Should -BeExactly 'DOCS_CLI_ARGUMENTS' -Because "$operation with -$option"
                } else {
                    $null -eq $finding | Should -BeTrue -Because "$operation accepts -$option"
                }
                $checked++
            }
        }
        $checked | Should -Be 72
    }

    It 'property Test-DocsValidateArgument: accepts exactly the four modes with a full revision, or no revision under docs-complete WriteReceipt; WriteReceipt only with docs-complete' {
        $modes = @('profile', 'ledger', 'matrix', 'docs-complete', 'all', '')
        $revisions = @($script:Revision, ('f' * 64), ('F' * 40), 'abc', '')
        $checked = 0
        foreach ($mode in $modes) {
            foreach ($revision in $revisions) {
                foreach ($write in $false, $true) {
                    # Arrange
                    $argument = [ordered]@{}
                    if ($mode.Length -gt 0) { $argument['Mode'] = $mode }
                    if ($revision.Length -gt 0) { $argument['Revision'] = $revision }
                    if ($write) { $argument['WriteReceipt'] = $true }
                    $validMode = (Get-DocsValidationMode) -ccontains $mode
                    $validRevision = Test-DocsFullRevision -Revision $revision
                    # Issue #1169: the docs-complete plus WriteReceipt row with an empty revision is valid,
                    # because the command defaults -Revision to the inventory snapshot revision.
                    $defaultedRevision = $revision.Length -eq 0 -and $write -and $mode -ceq 'docs-complete'
                    $expectNull = $validMode -and ($validRevision -or $defaultedRevision) -and (-not $write -or $mode -ceq 'docs-complete')

                    # Act
                    $finding = Test-DocsValidateArgument -Argument $argument

                    # Assert
                    ($null -eq $finding) | Should -Be $expectNull -Because "mode='$mode' revision='$revision' write=$write"
                    if (-not $expectNull) { $finding['code'] | Should -BeExactly 'DOCS_CLI_ARGUMENTS' -Because "mode='$mode' revision='$revision' write=$write" }
                    $checked++
                }
            }
        }
        $checked | Should -Be 60
    }
}
