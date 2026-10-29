#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for scripts/ci/FileSizeBaseline.psm1 (issue #990).

.DESCRIPTION
    Covers the canonical baseline JSON text (ordinal key order, two-space indent, LF,
    trailing newline), parsing and its failure modes, and the repository-level strict
    ratchet: one row per row of the spec.md ratchet table plus the rename rows. All data
    is in memory; no file is read or written and no process is started.
#>

BeforeAll {
    $script:ModulePath = Join-Path $PSScriptRoot '../../../scripts/ci/FileSizeBaseline.psm1'
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop
}

AfterAll {
    Remove-Module -Name FileSizeBaseline -Force -ErrorAction SilentlyContinue
    Remove-Module -Name FileSizePolicy -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertTo-FileSizeBaselineJson' {
    It 'renders the exact canonical text with ordinal key order' {
        # Arrange: keys whose ordinal order differs from culture-aware order.
        $files = [ordered]@{ 'b/x.py' = 1001; 'a.py' = 900; 'B/y.py' = 850; '_z.ps1' = 999 }
        $expected = "{`n  `"schemaVersion`": 1,`n  `"hardLimit`": 800,`n  `"files`": {`n" +
        "    `"B/y.py`": 850,`n    `"_z.ps1`": 999,`n    `"a.py`": 900,`n    `"b/x.py`": 1001`n  }`n}`n"

        # Act
        $json = ConvertTo-FileSizeBaselineJson -Files $files

        # Assert
        $json | Should -BeExactly $expected
    }

    It 'renders an empty files object for an empty map' {
        ConvertTo-FileSizeBaselineJson -Files @{} | Should -BeExactly "{`n  `"schemaVersion`": 1,`n  `"hardLimit`": 800,`n  `"files`": {}`n}`n"
    }

    It 'is deterministic regardless of input order' {
        # Arrange
        $first = [ordered]@{ 'z.py' = 801; 'm.ps1' = 900; 'a.ts' = 1200 }
        $second = [ordered]@{ 'a.ts' = 1200; 'z.py' = 801; 'm.ps1' = 900 }

        # Act / Assert
        (ConvertTo-FileSizeBaselineJson -Files $first) | Should -BeExactly (ConvertTo-FileSizeBaselineJson -Files $second)
    }

    It 'contains no carriage return' {
        (ConvertTo-FileSizeBaselineJson -Files @{ 'a.py' = 900 }).Contains("`r") | Should -BeFalse
    }
}

Describe 'ConvertFrom-FileSizeBaselineJson' {
    It 'round-trips the rendered text' {
        # Arrange
        $files = [ordered]@{ 'scripts/big.ps1' = 912; 'src/huge.ts' = 1500 }
        $json = ConvertTo-FileSizeBaselineJson -Files $files

        # Act
        $parsed = ConvertFrom-FileSizeBaselineJson -Json $json

        # Assert
        $parsed.SchemaVersion | Should -Be 1
        $parsed.HardLimit | Should -Be 800
        @($parsed.Files.Keys) | Should -Be @('scripts/big.ps1', 'src/huge.ts')
        $parsed.Files['src/huge.ts'] | Should -Be 1500
        (ConvertTo-FileSizeBaselineJson -Files $parsed.Files) | Should -BeExactly $json
    }

    It 'rejects <Label>' -ForEach @(
        @{ Label = 'invalid JSON'; Json = '{not json'; Message = '*not valid JSON*' }
        @{ Label = 'a JSON array'; Json = '[1, 2]'; Message = '*must be a JSON object*' }
        @{ Label = 'a wrong schema version'; Json = '{"schemaVersion": 2, "hardLimit": 800, "files": {}}'; Message = '*schemaVersion must be 1*' }
        @{ Label = 'a missing schema version'; Json = '{"hardLimit": 800, "files": {}}'; Message = '*schemaVersion must be 1*' }
        @{ Label = 'a wrong hard limit'; Json = '{"schemaVersion": 1, "hardLimit": 500, "files": {}}'; Message = '*hardLimit must be 800*' }
        @{ Label = 'a missing files object'; Json = '{"schemaVersion": 1, "hardLimit": 800}'; Message = '*files must be a JSON object*' }
        @{ Label = 'a files array'; Json = '{"schemaVersion": 1, "hardLimit": 800, "files": []}'; Message = '*files must be a JSON object*' }
        @{ Label = 'a string size'; Json = '{"schemaVersion": 1, "hardLimit": 800, "files": {"a.py": "900"}}'; Message = "*entry 'a.py' must be a positive integer*" }
        @{ Label = 'a zero size'; Json = '{"schemaVersion": 1, "hardLimit": 800, "files": {"a.py": 0}}'; Message = '*must be a positive integer*' }
    ) {
        { ConvertFrom-FileSizeBaselineJson -Json $Json } | Should -Throw $Message
    }
}

Describe 'Get-FileSizeRatchetViolation' {
    It 'evaluates the ratchet row: <Name>' -ForEach @(
        @{ Name = 'S <= 800 with no entry passes'; Current = @{ 'a.py' = 700 }; Baseline = @{}; Rules = @() }
        @{ Name = 'S <= 800 with an entry fails as stale'; Current = @{ 'a.py' = 700 }; Baseline = @{ 'a.py' = 900 }; Rules = @('a.py:stale-entry') }
        @{ Name = 'S > 800 with no entry fails as new'; Current = @{ 'a.py' = 801 }; Baseline = @{}; Rules = @('a.py:new-over-limit') }
        @{ Name = 'S > B fails as growth'; Current = @{ 'a.py' = 950 }; Baseline = @{ 'a.py' = 900 }; Rules = @('a.py:grew') }
        @{ Name = 'S == B passes'; Current = @{ 'a.py' = 900 }; Baseline = @{ 'a.py' = 900 }; Rules = @() }
        @{ Name = 'S < B fails until the entry is tightened'; Current = @{ 'a.py' = 850 }; Baseline = @{ 'a.py' = 900 }; Rules = @('a.py:tighten') }
        @{ Name = 'an entry with no file on disk fails as stale'; Current = @{}; Baseline = @{ 'gone.py' = 900 }; Rules = @('gone.py:missing-file') }
        @{ Name = 'a rename without moving the entry fails twice'; Current = @{ 'new.py' = 900 }; Baseline = @{ 'old.py' = 900 }; Rules = @('new.py:new-over-limit', 'old.py:missing-file') }
        @{ Name = 'a rename with the entry moved at the same size passes'; Current = @{ 'new.py' = 900 }; Baseline = @{ 'new.py' = 900 }; Rules = @() }
        @{ Name = 'a rename that raises the recorded size still fails as growth against the moved entry'; Current = @{ 'new.py' = 950 }; Baseline = @{ 'new.py' = 900 }; Rules = @('new.py:grew') }
    ) {
        # Act
        $violations = @(Get-FileSizeRatchetViolation -CurrentSize $Current -Baseline $Baseline)

        # Assert: one violation per failing row, each carrying its path in the message.
        @($violations | ForEach-Object { "$($_.Path):$($_.Rule)" }) | Should -Be $Rules
        foreach ($violation in $violations) {
            $violation.Message | Should -Match ([regex]::Escape($violation.Path))
        }
    }

    It 'reports violations in ordinal path order' {
        # Arrange: an ordinal dictionary, because hashtable literal keys are case-insensitive.
        $current = [System.Collections.Generic.Dictionary[string, int]]::new([System.StringComparer]::Ordinal)
        $current['b.py'] = 801
        $current['B.py'] = 802
        $current['a.py'] = 803

        # Act
        $violations = @(Get-FileSizeRatchetViolation -CurrentSize $current -Baseline @{})

        # Assert
        @($violations.Path) | Should -Be @('B.py', 'a.py', 'b.py')
    }

    It 'returns an empty array for empty inputs' {
        @(Get-FileSizeRatchetViolation -CurrentSize @{} -Baseline @{}).Count | Should -Be 0
    }
}
