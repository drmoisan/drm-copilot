<#
.SYNOPSIS
    Unit tests for the parallel drift halt-selection module and its shape guards.

.DESCRIPTION
    Covers .claude/lib/parallel-drift/ParallelDriftHalt.psm1 (issue #763), the
    PowerShell port of scripts/dev_tools/parallel_drift_halt.py, the shape guards
    of scripts/dev_tools/_parallel_drift_shape.py, and the halted_item_keys
    selection of scripts/dev_tools/parallel_drift_detection_cli.py. Every input is
    an inline value; no file is read, no temporary file is created, and no
    external process is started.
#>

BeforeAll {
    # Resolve the module four levels up: parallel-drift -> claude-lib -> scripts
    # -> tests -> repo root, then into .claude/lib/parallel-drift.
    $modulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/parallel-drift/ParallelDriftHalt.psm1").Path
    Import-Module $modulePath -Force -ErrorAction Stop

    # Build one start marker in the shape the selection functions read.
    function New-TestStart {
        param([long] $ItemKey, [AllowNull()][object] $WorktreeCreatedAt)
        return @{ ItemKey = $ItemKey; WorktreeCreatedAt = $WorktreeCreatedAt }
    }

    # Build one checkpoint item record carrying an optional start timestamp.
    function New-TestItem {
        param([long] $ItemKey, [AllowNull()][object] $WorktreeCreatedAt)
        $record = [hashtable]::new([System.StringComparer]::Ordinal)
        $record['issue_num'] = $ItemKey
        if ($null -ne $WorktreeCreatedAt) { $record['worktree_created_at'] = $WorktreeCreatedAt }
        return $record
    }
}

Describe 'ParallelDriftHalt.psm1' {
    It 'Assert-ParallelDriftItemKey accepts a positive integer' {
        # Act
        $key = Assert-ParallelDriftItemKey -Value ([long]446) -FieldName 'item_key'

        # Assert
        $key | Should -Be 446
    }

    It 'Assert-ParallelDriftItemKey rejects <case>' -ForEach @(
        @{ case = 'zero'; value = 0 }
        @{ case = 'negative'; value = -3 }
        @{ case = 'boolean'; value = $true }
        @{ case = 'string'; value = '446' }
    ) {
        # Act / Assert: every non-positive or non-integer value names the field.
        { Assert-ParallelDriftItemKey -Value $value -FieldName 'item_key' } |
            Should -Throw '*item_key must be a positive integer issue_num*'
    }

    It 'Assert-ParallelDriftText rejects a blank value' {
        { Assert-ParallelDriftText -Value '   ' -FieldName 'at' } | Should -Throw '*at must be a non-empty string*'
    }

    It 'Assert-ParallelDriftText returns a non-blank value unchanged' {
        Assert-ParallelDriftText -Value '2026-08-08T10-00' -FieldName 'at' | Should -BeExactly '2026-08-08T10-00'
    }

    It 'Assert-ParallelDriftPathList rejects a bare string' {
        { Assert-ParallelDriftPathList -Value 'src/app.py' -FieldName 'changed' -AllowEmpty } |
            Should -Throw '*changed must be a collection of paths, not a single string*'
    }

    It 'Assert-ParallelDriftPathList rejects a non-collection value' {
        { Assert-ParallelDriftPathList -Value $null -FieldName 'changed' -AllowEmpty } |
            Should -Throw '*changed must be a collection of paths*'
    }

    It 'Assert-ParallelDriftPathList rejects a blank entry' {
        { Assert-ParallelDriftPathList -Value @('src/app.py', ' ') -FieldName 'changed' -AllowEmpty } |
            Should -Throw '*changed entries must be non-empty strings*'
    }

    It 'Assert-ParallelDriftPathList rejects an empty collection when not allowed' {
        { Assert-ParallelDriftPathList -Value @() -FieldName 'escaped_paths' } |
            Should -Throw '*escaped_paths must not be empty*'
    }

    It 'Assert-ParallelDriftPathList accepts an empty collection when allowed' {
        # Act
        $paths = Assert-ParallelDriftPathList -Value @() -FieldName 'changed' -AllowEmpty

        # Assert: an array is returned even when it is empty.
        , $paths | Should -BeOfType [string[]]
        $paths.Count | Should -Be 0
    }

    It 'Assert-ParallelDriftPathList deduplicates and sorts ordinally' {
        # Act
        $paths = Assert-ParallelDriftPathList -Value @('b.py', 'B.py', 'a.py', 'b.py') -FieldName 'changed'

        # Assert: ordinal order places upper case before lower case.
        $paths | Should -Be @('B.py', 'a.py', 'b.py')
    }

    It 'Assert-ParallelDriftEnumMember rejects a value outside the vocabulary' {
        { Assert-ParallelDriftEnumMember -Value 'resolved' -Vocabulary @('raised_blocking_finding') -FieldName 'action' } |
            Should -Throw '*action must be one of raised_blocking_finding*'
    }

    It 'Assert-ParallelDriftEnumMember returns a member unchanged' {
        Assert-ParallelDriftEnumMember -Value 'in_flight' -Vocabulary @('in_flight', 'merged') -FieldName 'state' |
            Should -BeExactly 'in_flight'
    }

    It 'ConvertTo-ParallelDriftItemKey returns null for an unreadable value' {
        ConvertTo-ParallelDriftItemKey -Value 'a' | Should -BeNullOrEmpty
        ConvertTo-ParallelDriftItemKey -Value $true | Should -BeNullOrEmpty
        ConvertTo-ParallelDriftItemKey -Value ([long]445) | Should -Be 445
    }

    It 'Get-ParallelDriftCanonicalPair orders the lower key first' {
        # Act
        $pair = Get-ParallelDriftCanonicalPair -First 446 -Second 445

        # Assert
        $pair | Should -Be @(445, 446)
    }

    It 'Get-ParallelDriftStartRank ranks an unknown start above a timestamped start' {
        # Act
        $known = Get-ParallelDriftStartRank -Start (New-TestStart -ItemKey 445 -WorktreeCreatedAt '2026-08-08T08-00')
        $unknown = Get-ParallelDriftStartRank -Start (New-TestStart -ItemKey 446 -WorktreeCreatedAt $null)

        # Assert
        $known.Unknown | Should -Be 0
        $unknown.Unknown | Should -Be 1
        $unknown.Timestamp | Should -BeExactly ''
    }

    It 'Get-ParallelDriftStartRank rejects a non-string start timestamp' {
        { Get-ParallelDriftStartRank -Start (New-TestStart -ItemKey 445 -WorktreeCreatedAt 5) } |
            Should -Throw '*worktree_created_at must be a string or None*'
    }

    It 'Select-ParallelDriftHaltedItem halts the later timestamp' {
        # Arrange
        $earlier = New-TestStart -ItemKey 447 -WorktreeCreatedAt '2026-08-08T08-00'
        $later = New-TestStart -ItemKey 445 -WorktreeCreatedAt '2026-08-08T09-00'

        # Act / Assert: argument order does not change the verdict.
        Select-ParallelDriftHaltedItem -First $earlier -Second $later | Should -Be 445
        Select-ParallelDriftHaltedItem -First $later -Second $earlier | Should -Be 445
    }

    It 'Select-ParallelDriftHaltedItem halts the larger key on equal timestamps' {
        $first = New-TestStart -ItemKey 445 -WorktreeCreatedAt '2026-08-08T08-00'
        $second = New-TestStart -ItemKey 447 -WorktreeCreatedAt '2026-08-08T08-00'

        Select-ParallelDriftHaltedItem -First $first -Second $second | Should -Be 447
    }

    It 'Select-ParallelDriftHaltedItem halts the item whose start is unknown' {
        $known = New-TestStart -ItemKey 447 -WorktreeCreatedAt '2026-08-08T09-00'
        $unknown = New-TestStart -ItemKey 445 -WorktreeCreatedAt '  '

        Select-ParallelDriftHaltedItem -First $known -Second $unknown | Should -Be 445
    }

    It 'Select-ParallelDriftHaltedItem halts the larger key when both starts are unknown' {
        $first = New-TestStart -ItemKey 447 -WorktreeCreatedAt $null
        $second = New-TestStart -ItemKey 445 -WorktreeCreatedAt $null

        Select-ParallelDriftHaltedItem -First $first -Second $second | Should -Be 447
    }

    It 'Select-ParallelDriftHaltedItem rejects a pair that names one item twice' {
        $start = New-TestStart -ItemKey 445 -WorktreeCreatedAt $null

        { Select-ParallelDriftHaltedItem -First $start -Second $start } | Should -Throw '*names one item twice*'
    }

    It 'Get-ParallelDriftHaltedItemKey never returns the drifting key' {
        # Arrange: the drifter started later than its peer.
        $items = @((New-TestItem -ItemKey 446 -WorktreeCreatedAt '2026-08-08T09-30'), (New-TestItem -ItemKey 445 -WorktreeCreatedAt '2026-08-08T08-00'))

        # Act
        $halted = Get-ParallelDriftHaltedItemKey -Item $items -Pair @(, [long[]]@(445, 446)) -DriftingItemKey 446

        # Assert
        $halted | Should -Be @(445)
        $halted | Should -Not -Contain 446
    }

    It 'Get-ParallelDriftHaltedItemKey returns deduplicated ascending keys' {
        # Arrange: item 447 is the halted member of two pairs.
        $items = @((New-TestItem -ItemKey 446 -WorktreeCreatedAt $null), (New-TestItem -ItemKey 447 -WorktreeCreatedAt $null), (New-TestItem -ItemKey 445 -WorktreeCreatedAt $null))
        $pairs = @([long[]]@(446, 447), [long[]]@(445, 447), [long[]]@(445, 446))

        # Act
        $halted = Get-ParallelDriftHaltedItemKey -Item $items -Pair $pairs -DriftingItemKey 446

        # Assert
        , $halted | Should -BeOfType [long[]]
        $halted | Should -Be @(445, 447)
    }

    It 'Get-ParallelDriftHaltedItemKey returns an empty array for no pairs' {
        # Act
        $halted = Get-ParallelDriftHaltedItemKey -Item @() -Pair @() -DriftingItemKey 446

        # Assert
        , $halted | Should -BeOfType [long[]]
        $halted.Count | Should -Be 0
    }

    It 'Get-ParallelDriftHaltedItemKey applies the comparator when the drifting key is in neither member' {
        # Arrange
        $items = @((New-TestItem -ItemKey 445 -WorktreeCreatedAt '2026-08-08T09-00'), (New-TestItem -ItemKey 447 -WorktreeCreatedAt '2026-08-08T08-00'))

        # Act
        $halted = Get-ParallelDriftHaltedItemKey -Item $items -Pair @(, [long[]]@(445, 447)) -DriftingItemKey 446

        # Assert: 445 started later, so it is the halted item.
        $halted | Should -Be @(445)
    }
}
