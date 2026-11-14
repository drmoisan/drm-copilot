#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for Get-DocsReceiptRevisionDecision in .claude/lib/docs/DocsReceiptRevision.psm1
    (issue #1169).

.DESCRIPTION
    Covers every allow and deny step of the receipt revision rule, the segment-anchored source
    root match, the bounded drift list, the fetch remediation of RECEIPT_REVISION_UNRESOLVED, and
    the refresh section named by every deny message. The function is pure, so no row writes a file
    or starts a process.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsReceiptRevision.psm1') -Force -ErrorAction Stop
    $script:Receipt = '1111111111111111111111111111111111111111'
    $script:Head = '2222222222222222222222222222222222222222'
    $script:Other = '3333333333333333333333333333333333333333'
    $script:Roots = @('src', 'scripts/tools')
    $script:Limit = & (Get-Module -Name DocsReceiptRevision) { $script:DocsReceiptRevisionDriftLimit }
}

AfterAll {
    Remove-Module -Name DocsReceiptRevision -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsReceiptRevisionDecision allows' {
    It 'allows an ancestor receipt revision with no changed path under a source root' {
        # Act
        $result = Get-DocsReceiptRevisionDecision -ReceiptRevision $script:Receipt -SnapshotRevision $script:Receipt -HeadRevision $script:Head -IsAncestor $true -ChangedPath @('docs/a.md', 'srcx/b.ps1') -SourceRoot $script:Roots

        # Assert
        $result.Allow | Should -BeTrue -Because $result.Message
        $result.Reason | Should -BeNullOrEmpty
    }

    It 'allows a head equal to the receipt revision without ancestry or changed-path input' {
        # Act
        $result = Get-DocsReceiptRevisionDecision -ReceiptRevision $script:Receipt -SnapshotRevision $script:Receipt -HeadRevision $script:Receipt -IsAncestor $null -ChangedPath $null -SourceRoot $script:Roots

        # Assert
        $result.Allow | Should -BeTrue -Because $result.Message
        $result.Reason | Should -BeNullOrEmpty
    }

    It 'allows an ancestor receipt revision with an empty changed-path list' {
        # Act
        $result = Get-DocsReceiptRevisionDecision -ReceiptRevision $script:Receipt -SnapshotRevision $script:Receipt -HeadRevision $script:Head -IsAncestor $true -ChangedPath @() -SourceRoot $script:Roots

        # Assert
        $result.Allow | Should -BeTrue -Because $result.Message
    }

    It 'allows a path that shares a source root prefix without a segment boundary' {
        # Act
        $result = Get-DocsReceiptRevisionDecision -ReceiptRevision $script:Receipt -SnapshotRevision $script:Receipt -HeadRevision $script:Head -IsAncestor $true -ChangedPath @('srcfoo/a.ps1', 'scripts/toolsx/b.ps1', 'Src/c.ps1') -SourceRoot $script:Roots

        # Assert
        $result.Allow | Should -BeTrue -Because 'the match is ordinal and segment-anchored'
    }
}

Describe 'Get-DocsReceiptRevisionDecision denies' {
    It 'denies RECEIPT_REVISION_SNAPSHOT_MISMATCH when the receipt revision differs from the snapshot revision' {
        # Act
        $result = Get-DocsReceiptRevisionDecision -ReceiptRevision $script:Receipt -SnapshotRevision $script:Other -HeadRevision $script:Receipt -IsAncestor $true -ChangedPath @() -SourceRoot $script:Roots

        # Assert
        $result.Allow | Should -BeFalse
        $result.Reason | Should -BeExactly 'RECEIPT_REVISION_SNAPSHOT_MISMATCH'
        $result.Message.Contains($script:Other) | Should -BeTrue -Because 'the message names the snapshot revision'
    }

    It 'denies RECEIPT_REVISION_NOT_ANCESTOR when the receipt revision is not an ancestor of the head' {
        # Act
        $result = Get-DocsReceiptRevisionDecision -ReceiptRevision $script:Receipt -SnapshotRevision $script:Receipt -HeadRevision $script:Head -IsAncestor $false -ChangedPath @() -SourceRoot $script:Roots

        # Assert
        $result.Allow | Should -BeFalse
        $result.Reason | Should -BeExactly 'RECEIPT_REVISION_NOT_ANCESTOR'
    }

    It 'denies RECEIPT_REVISION_UNRESOLVED with a fetch remediation for <Label>' -ForEach @(
        @{ Label = 'a null ancestry answer'; IsAncestor = $null; Changed = @(); Receipt = '1111111111111111111111111111111111111111'; Head = '2222222222222222222222222222222222222222' }
        @{ Label = 'a null changed-path list'; IsAncestor = $true; Changed = $null; Receipt = '1111111111111111111111111111111111111111'; Head = '2222222222222222222222222222222222222222' }
        @{ Label = 'a blank head revision'; IsAncestor = $true; Changed = @(); Receipt = '1111111111111111111111111111111111111111'; Head = '' }
        @{ Label = 'a blank receipt revision'; IsAncestor = $true; Changed = @(); Receipt = ''; Head = '2222222222222222222222222222222222222222' }
    ) {
        # Act
        $result = Get-DocsReceiptRevisionDecision -ReceiptRevision $Receipt -SnapshotRevision $Receipt -HeadRevision $Head -IsAncestor $IsAncestor -ChangedPath $Changed -SourceRoot $script:Roots

        # Assert
        $result.Allow | Should -BeFalse
        $result.Reason | Should -BeExactly 'RECEIPT_REVISION_UNRESOLVED'
        $result.Message | Should -BeLike '*git fetch*' -Because 'an unresolved revision names the fetch remediation'
    }

    It 'denies RECEIPT_SOURCE_DRIFT naming a path under a source root reached at a segment boundary' {
        # Act
        $result = Get-DocsReceiptRevisionDecision -ReceiptRevision $script:Receipt -SnapshotRevision $script:Receipt -HeadRevision $script:Head -IsAncestor $true -ChangedPath @('docs/a.md', 'srcfoo/x.ps1', 'scripts/tools/y.ps1', 'src') -SourceRoot $script:Roots

        # Assert
        $result.Allow | Should -BeFalse
        $result.Reason | Should -BeExactly 'RECEIPT_SOURCE_DRIFT'
        $result.Message.Contains("'scripts/tools/y.ps1'") | Should -BeTrue
        $result.Message.Contains("'src'") | Should -BeTrue -Because 'a path equal to a root is under it'
        $result.Message.Contains('srcfoo/x.ps1') | Should -BeFalse -Because 'a shared prefix without a segment boundary is not drift'
        $result.Message.Contains('docs/a.md') | Should -BeFalse
    }

    It 'treats a trailing slash on a source root and the root . as the same segment rule' {
        # Act
        $slash = Get-DocsReceiptRevisionDecision -ReceiptRevision $script:Receipt -SnapshotRevision $script:Receipt -HeadRevision $script:Head -IsAncestor $true -ChangedPath @('lib/a.ps1') -SourceRoot @('lib/')
        $dot = Get-DocsReceiptRevisionDecision -ReceiptRevision $script:Receipt -SnapshotRevision $script:Receipt -HeadRevision $script:Head -IsAncestor $true -ChangedPath @('any/a.ps1') -SourceRoot @('.')
        $blank = Get-DocsReceiptRevisionDecision -ReceiptRevision $script:Receipt -SnapshotRevision $script:Receipt -HeadRevision $script:Head -IsAncestor $true -ChangedPath @('any/a.ps1') -SourceRoot @('', ' ', '/')

        # Assert
        $slash.Reason | Should -BeExactly 'RECEIPT_SOURCE_DRIFT'
        $dot.Reason | Should -BeExactly 'RECEIPT_SOURCE_DRIFT'
        $blank.Allow | Should -BeTrue -Because 'a blank root covers no path'
    }

    It 'names exactly the bound of drifted paths and the count of the rest' {
        # Arrange: one drifted path more than the bound.
        $changed = @(1..($script:Limit + 1) | ForEach-Object { "src/file$_.ps1" })

        # Act
        $result = Get-DocsReceiptRevisionDecision -ReceiptRevision $script:Receipt -SnapshotRevision $script:Receipt -HeadRevision $script:Head -IsAncestor $true -ChangedPath $changed -SourceRoot $script:Roots
        $named = [regex]::Matches($result.Message, "'src/file[0-9]+\.ps1'").Count

        # Assert
        $result.Reason | Should -BeExactly 'RECEIPT_SOURCE_DRIFT'
        $named | Should -Be $script:Limit
        $result.Message | Should -BeLike '* and 1 more.*'
        $result.Message.Contains("src/file$($script:Limit + 1).ps1") | Should -BeFalse
    }

    It 'names every drifted path and no remainder when the set is within the bound' {
        # Arrange
        $changed = @(1..$script:Limit | ForEach-Object { "src/file$_.ps1" })

        # Act
        $result = Get-DocsReceiptRevisionDecision -ReceiptRevision $script:Receipt -SnapshotRevision $script:Receipt -HeadRevision $script:Head -IsAncestor $true -ChangedPath $changed -SourceRoot $script:Roots

        # Assert
        [regex]::Matches($result.Message, "'src/file[0-9]+\.ps1'").Count | Should -Be $script:Limit
        $result.Message | Should -Not -BeLike '* more.*'
    }

    It 'names the refresh section in every deny message (<Reason>)' -ForEach @(
        @{ Reason = 'RECEIPT_REVISION_SNAPSHOT_MISMATCH'; Snapshot = '3333333333333333333333333333333333333333'; IsAncestor = $true; Changed = @() }
        @{ Reason = 'RECEIPT_REVISION_NOT_ANCESTOR'; Snapshot = '1111111111111111111111111111111111111111'; IsAncestor = $false; Changed = @() }
        @{ Reason = 'RECEIPT_REVISION_UNRESOLVED'; Snapshot = '1111111111111111111111111111111111111111'; IsAncestor = $null; Changed = @() }
        @{ Reason = 'RECEIPT_SOURCE_DRIFT'; Snapshot = '1111111111111111111111111111111111111111'; IsAncestor = $true; Changed = @('src/a.ps1') }
    ) {
        # Act
        $result = Get-DocsReceiptRevisionDecision -ReceiptRevision $script:Receipt -SnapshotRevision $Snapshot -HeadRevision $script:Head -IsAncestor $IsAncestor -ChangedPath $Changed -SourceRoot $script:Roots

        # Assert
        $result.Reason | Should -BeExactly $Reason
        $result.Message | Should -BeLike '*Refresh After Rebase or Source Change*'
    }
}
