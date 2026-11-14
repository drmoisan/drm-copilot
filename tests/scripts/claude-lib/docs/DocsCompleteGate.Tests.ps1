#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsCompleteGate.psm1.

.DESCRIPTION
    Drives the four pure gate predicates with in-memory strings only: the profile switch, the
    receipt path, the integration-to-main target test, and every receipt reason code including
    ordinal revision equality. No file is read or written and no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsCompleteGate.psm1') -Force -ErrorAction Stop

    $script:HeadRevision = '0123456789abcdef0123456789abcdef01234567'

    function Get-TestReceiptText {
        param(
            [string] $Kind = 'docs-validation-receipt',
            [string] $Mode = 'docs-complete',
            [string] $Result = 'pass',
            [string] $Revision = $script:HeadRevision
        )
        return ([ordered]@{ artifact_kind = $Kind; mode = $Mode; revision = $Revision; validation_result = $Result } | ConvertTo-Json -Compress)
    }
}

AfterAll {
    Remove-Module -Name DocsCompleteGate, DocsReceiptRevision, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsCompleteGateEnabled' {
    It 'is disabled with no reason when the profile text is $null' {
        # Act
        $result = Get-DocsCompleteGateEnabled -ProfileText $null

        # Assert
        $result.Enabled | Should -BeFalse
        $result.Reason | Should -BeNullOrEmpty
    }

    It 'is disabled when <Case>' -ForEach @(
        @{ Case = 'the completion_gates member is absent'; Text = '{"artifact_paths":{}}' }
        @{ Case = 'the enabled member is absent'; Text = '{"completion_gates":{"integration_pr_gate":{}}}' }
        @{ Case = 'enabled is false'; Text = '{"completion_gates":{"integration_pr_gate":{"enabled":false}}}' }
        @{ Case = 'enabled is the string true'; Text = '{"completion_gates":{"integration_pr_gate":{"enabled":"true"}}}' }
    ) {
        # Act
        $result = Get-DocsCompleteGateEnabled -ProfileText $Text

        # Assert
        $result.Enabled | Should -BeFalse
        $result.Reason | Should -BeNullOrEmpty
    }

    It 'is enabled when enabled is the JSON boolean true' {
        # Act
        $result = Get-DocsCompleteGateEnabled -ProfileText '{"completion_gates":{"integration_pr_gate":{"enabled":true}}}'

        # Assert
        $result.Enabled | Should -BeTrue
        $result.Reason | Should -BeNullOrEmpty
    }

    It 'returns PROFILE_UNREADABLE for <Case>' -ForEach @(
        @{ Case = 'invalid JSON'; Text = '{"completion_gates":' }
        @{ Case = 'a duplicate key'; Text = '{"completion_gates":{"integration_pr_gate":{"enabled":true,"enabled":false}}}' }
        @{ Case = 'empty text'; Text = '' }
        @{ Case = 'a JSON array'; Text = '[]' }
    ) {
        # Act
        $result = Get-DocsCompleteGateEnabled -ProfileText $Text

        # Assert
        $result.Enabled | Should -BeFalse
        $result.Reason | Should -BeExactly 'PROFILE_UNREADABLE'
    }
}

Describe 'Get-DocsCompleteGateReceiptPath' {
    It 'returns a valid repository-relative receipt path' {
        # Act
        $result = Get-DocsCompleteGateReceiptPath -ProfileText '{"artifact_paths":{"validation_receipt":"docs/documentation-estate/docs-validation-receipt.json"}}'

        # Assert
        $result.Path | Should -BeExactly 'docs/documentation-estate/docs-validation-receipt.json'
        $result.Reason | Should -BeNullOrEmpty
    }

    It 'returns RECEIPT_PATH_INVALID for <Case>' -ForEach @(
        @{ Case = 'an absolute path'; Text = '{"artifact_paths":{"validation_receipt":"/etc/receipt.json"}}' }
        @{ Case = 'a parent traversal'; Text = '{"artifact_paths":{"validation_receipt":"../receipt.json"}}' }
        @{ Case = 'an absent member'; Text = '{"artifact_paths":{}}' }
        @{ Case = 'a non-string member'; Text = '{"artifact_paths":{"validation_receipt":7}}' }
        @{ Case = 'unreadable profile text'; Text = '{' }
    ) {
        # Act
        $result = Get-DocsCompleteGateReceiptPath -ProfileText $Text

        # Assert
        $result.Path | Should -BeNullOrEmpty
        $result.Reason | Should -BeExactly 'RECEIPT_PATH_INVALID'
    }
}

Describe 'Test-DocsCompleteGateIntegrationTarget' {
    It 'is true for main and an epic integration head' {
        # Act and Assert
        Test-DocsCompleteGateIntegrationTarget -BaseRefName 'main' -HeadRefName 'epic/documentation-estate-tooling-integration' | Should -BeTrue
    }

    It 'is false when <Case>' -ForEach @(
        @{ Case = 'the base is not main'; Base = 'development'; Head = 'epic/docs-integration' }
        @{ Case = 'the base differs from main in case'; Base = 'Main'; Head = 'epic/docs-integration' }
        @{ Case = 'the head has no -integration suffix'; Base = 'main'; Head = 'epic/docs' }
        @{ Case = 'the head slug starts with a separator'; Base = 'main'; Head = 'epic/-docs-integration' }
        @{ Case = 'the head is not under epic/'; Base = 'main'; Head = 'feature/docs-integration' }
        @{ Case = 'the head carries a trailing newline'; Base = 'main'; Head = "epic/docs-integration`n" }
        @{ Case = 'the head is $null'; Base = 'main'; Head = $null }
    ) {
        # Act and Assert
        Test-DocsCompleteGateIntegrationTarget -BaseRefName $Base -HeadRefName $Head | Should -BeFalse
    }
}

Describe 'Test-DocsCompleteGateReceipt' {
    It 'returns RECEIPT_ABSENT when no receipt text exists' {
        # Act
        $result = Test-DocsCompleteGateReceipt -ReceiptText $null -HeadRevision $script:HeadRevision

        # Assert
        $result.Allow | Should -BeFalse
        $result.Reason | Should -BeExactly 'RECEIPT_ABSENT'
        $result.Message | Should -BeLikeExactly '*-WriteReceipt*'
        $result.Message | Should -BeLikeExactly '*snapshot revision*'
        $result.Message | Should -BeLikeExactly '*Refresh After Rebase or Source Change*'
        $result.Message | Should -Not -BeLikeExactly '*for the pull request head*'
    }

    It 'returns RECEIPT_UNREADABLE for <Case>' -ForEach @(
        @{ Case = 'malformed JSON'; Text = '{"artifact_kind":' }
        @{ Case = 'a JSON array'; Text = '[1]' }
        @{ Case = 'another artifact kind'; Text = '{"artifact_kind":"docs-inventory-snapshot","mode":"docs-complete","validation_result":"pass"}' }
    ) {
        # Act
        $result = Test-DocsCompleteGateReceipt -ReceiptText $Text -HeadRevision $script:HeadRevision

        # Assert
        $result.Allow | Should -BeFalse
        $result.Reason | Should -BeExactly 'RECEIPT_UNREADABLE'
    }

    It 'returns RECEIPT_MODE when the mode is not docs-complete' {
        # Act
        $result = Test-DocsCompleteGateReceipt -ReceiptText (Get-TestReceiptText -Mode 'matrix') -HeadRevision $script:HeadRevision

        # Assert
        $result.Reason | Should -BeExactly 'RECEIPT_MODE'
    }

    It 'returns RECEIPT_FAILING when the validation result is fail' {
        # Act
        $result = Test-DocsCompleteGateReceipt -ReceiptText (Get-TestReceiptText -Result 'fail') -HeadRevision $script:HeadRevision

        # Assert
        $result.Reason | Should -BeExactly 'RECEIPT_FAILING'
    }

    It 'reports the mode before the result when both fail' {
        # Act
        $result = Test-DocsCompleteGateReceipt -ReceiptText (Get-TestReceiptText -Mode 'ledger' -Result 'fail') -HeadRevision $script:HeadRevision

        # Assert
        $result.Reason | Should -BeExactly 'RECEIPT_MODE'
    }

    It 'returns RECEIPT_REVISION_SNAPSHOT_MISMATCH when the receipt revision differs from the snapshot revision (<Case>)' -ForEach @(
        @{ Case = 'different-revision'; Snapshot = 'fedcba9876543210fedcba9876543210fedcba98' }
        @{ Case = 'case'; Snapshot = '0123456789ABCDEF0123456789abcdef01234567' }
        @{ Case = 'absent snapshot'; Snapshot = $null }
    ) {
        # Act
        $result = Test-DocsCompleteGateReceipt -ReceiptText (Get-TestReceiptText) -HeadRevision $script:HeadRevision -SnapshotRevision $Snapshot

        # Assert
        $result.Allow | Should -BeFalse
        $result.Reason | Should -BeExactly 'RECEIPT_REVISION_SNAPSHOT_MISMATCH'
        $result.Message | Should -Match ([regex]::Escape($script:HeadRevision))
    }

    It 'allows a passing docs-complete receipt for the head revision without ancestry or diff input' {
        # Act
        $result = Test-DocsCompleteGateReceipt -ReceiptText (Get-TestReceiptText) -HeadRevision $script:HeadRevision -SnapshotRevision $script:HeadRevision

        # Assert
        $result.Allow | Should -BeTrue
        $result.Reason | Should -BeExactly 'pass'
    }

    It 'allows a receipt whose revision is an ancestor of the head with no source drift (issue #1169)' {
        # Arrange
        $head = 'fedcba9876543210fedcba9876543210fedcba98'

        # Act
        $result = Test-DocsCompleteGateReceipt -ReceiptText (Get-TestReceiptText) -HeadRevision $head -SnapshotRevision $script:HeadRevision -IsAncestor $true -ChangedPath @('docs/a.md') -SourceRoot @('src')

        # Assert
        $result.Allow | Should -BeTrue
        $result.Reason | Should -BeExactly 'pass'
    }

    It 'denies <Reason> for an ancestor receipt with <Case> (issue #1169)' -ForEach @(
        @{ Reason = 'RECEIPT_SOURCE_DRIFT'; Case = 'a changed source path'; IsAncestor = $true; Changed = @('src/a.py') }
        @{ Reason = 'RECEIPT_REVISION_NOT_ANCESTOR'; Case = 'a rebased head'; IsAncestor = $false; Changed = @() }
        @{ Reason = 'RECEIPT_REVISION_UNRESOLVED'; Case = 'an undecided ancestry'; IsAncestor = $null; Changed = @() }
        @{ Reason = 'RECEIPT_REVISION_UNRESOLVED'; Case = 'an unread diff'; IsAncestor = $true; Changed = $null }
    ) {
        # Arrange
        $head = 'fedcba9876543210fedcba9876543210fedcba98'

        # Act
        $result = Test-DocsCompleteGateReceipt -ReceiptText (Get-TestReceiptText) -HeadRevision $head -SnapshotRevision $script:HeadRevision -IsAncestor $IsAncestor -ChangedPath $Changed -SourceRoot @('src')

        # Assert
        $result.Allow | Should -BeFalse
        $result.Reason | Should -BeExactly $Reason
        $result.Message | Should -BeLike '*Refresh After Rebase or Source Change*'
    }

    It 'checks the mode and result before the revision rule' {
        # Act
        $result = Test-DocsCompleteGateReceipt -ReceiptText (Get-TestReceiptText -Result 'fail') -HeadRevision ('f' * 40) -SnapshotRevision $null

        # Assert
        $result.Reason | Should -BeExactly 'RECEIPT_FAILING'
    }
}
