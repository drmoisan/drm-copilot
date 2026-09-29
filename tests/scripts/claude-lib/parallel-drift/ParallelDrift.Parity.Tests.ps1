<#
.SYNOPSIS
    PowerShell lane of the shared parallel drift parity corpus (issue #763).

.DESCRIPTION
    Iterates every tests/fixtures/parallel_drift/*.json fixture and asserts that
    .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 reproduces the
    fixture's expected payload or expected error. The same corpus is asserted by
    the Python lane tests/scripts/dev_tools/test_parallel_drift_parity.py against
    the reference scripts/dev_tools/parallel_drift_detection_cli.py, so the
    fixtures are the single artifact that pins the two implementations together.

    Invocation (DV5): the entry script is dot-sourced, so its guard does not run,
    and Invoke-ParallelDriftCli is called in-process. Its returned Stdout, Stderr,
    and ExitCode are exactly what the guard writes and exits with. The file-read
    seam Read-ParallelDriftJsonText is mocked to return the raw text of the
    fixture's inline state or config, so no temporary file is created.

    Declared divergence classes:
      - JSON byte formatting: parsed JSON values are compared (ordinal key sets,
        value kinds, numbers by raw text, arrays in order), not bytes.
      - Error-message text after the "parallel drift detection failed: " prefix:
        the Python reference embeds repr() text, so only the prefix is compared.
      - DV7, remaining arguments: a remaining argument that begins with - is a
        usage error (exit 2), so a changed path that begins with - is not
        supported.
      - DV7, binder rejections: a named parameter given with no value (for
        example a trailing -ItemKey or -At) is rejected by the PowerShell
        parameter binder before the script body runs, so the process exits 1 with
        the binder's message instead of exiting 2 with the usage prefix.
#>

BeforeDiscovery {
    # Enumerate the committed corpus at discovery time so each fixture becomes one test.
    $corpusDirectory = (Resolve-Path "$PSScriptRoot/../../../fixtures/parallel_drift").Path
    $fixtureCase = @(Get-ChildItem -Path $corpusDirectory -Filter '*.json' -File | Sort-Object -Property Name |
            ForEach-Object { @{ name = $_.BaseName; path = $_.FullName } })
}

BeforeAll {
    # Resolve the repository root four levels up: parallel-drift -> claude-lib ->
    # scripts -> tests -> repo root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:CorpusDirectory = Join-Path -Path $script:RepoRoot -ChildPath 'tests/fixtures/parallel_drift'
    . (Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1')

    $script:MinimumFixtureCount = 18
    $script:CheckpointName = 'fixture-checkpoint.json'
    $script:ConfigName = 'fixture-config.json'
    $script:RequiredCase = @('no-escape-inside-radius', 'no-escape-empty-changed-paths', 'escape-without-conflict',
        'halt-one-pair', 'halt-several-pairs', 'halt-drifter-started-later', 'halt-equal-start-timestamps',
        'halt-one-start-absent', 'halt-both-starts-absent', 'reversed-existing-edge-not-new', 'non-object-edge-ignored',
        'malformed-peer-radius-fails-closed', 'tolerated-overlap-under-conflict-tolerance', 'peer-not-in-flight-ignored',
        'peer-radius-iso-timestamp-evaluated', 'error-items-not-a-list', 'error-item-key-missing', 'error-non-object-root')

    # Deep JSON-value equality: kinds match, object key sets match ordinally with
    # equal values, arrays match in order, numbers match by raw text, and strings
    # match ordinally.
    function Test-JsonValueEqual {
        param([System.Text.Json.JsonElement] $Left, [System.Text.Json.JsonElement] $Right)

        if ($Left.ValueKind -ne $Right.ValueKind) { return $false }
        switch ($Left.ValueKind) {
            ([System.Text.Json.JsonValueKind]::Object) {
                $leftProperty = @($Left.EnumerateObject())
                $rightName = @($Right.EnumerateObject() | ForEach-Object { $_.Name })
                if ($leftProperty.Count -ne $rightName.Count) { return $false }
                # Every left key must exist on the right with an equal value.
                foreach ($property in $leftProperty) {
                    if ($rightName -cnotcontains $property.Name) { return $false }
                    if (-not (Test-JsonValueEqual -Left $property.Value -Right $Right.GetProperty($property.Name))) { return $false }
                }
                return $true
            }
            ([System.Text.Json.JsonValueKind]::Array) {
                if ($Left.GetArrayLength() -ne $Right.GetArrayLength()) { return $false }
                # Compare the arrays position by position.
                for ($index = 0; $index -lt $Left.GetArrayLength(); $index++) {
                    if (-not (Test-JsonValueEqual -Left $Left[$index] -Right $Right[$index])) { return $false }
                }
                return $true
            }
            ([System.Text.Json.JsonValueKind]::Number) { return $Left.GetRawText() -ceq $Right.GetRawText() }
            ([System.Text.Json.JsonValueKind]::String) { return $Left.GetString() -ceq $Right.GetString() }
            default { return $true }
        }
    }
}

Describe 'Parallel drift parity corpus' {
    It 'the drift corpus meets the floor of 18 fixtures' {
        # Arrange / Act
        $count = @(Get-ChildItem -Path $script:CorpusDirectory -Filter '*.json' -File).Count

        # Assert: an empty or broken glob must fail rather than pass vacuously.
        $count | Should -BeGreaterOrEqual $script:MinimumFixtureCount
    }

    It 'the drift corpus names every required case' {
        # Arrange / Act
        $name = @(Get-ChildItem -Path $script:CorpusDirectory -Filter '*.json' -File | ForEach-Object { $_.BaseName })

        # Assert
        @($script:RequiredCase | Where-Object { $name -cnotcontains $_ }) | Should -BeNullOrEmpty
    }

    It 'reproduces drift fixture <name>' -ForEach $fixtureCase {
        # Arrange: split the fixture into the inline documents the mocked seam returns.
        $document = [System.Text.Json.JsonDocument]::Parse((Get-Content -LiteralPath $path -Raw))
        try {
            $root = $document.RootElement
            $script:StateText = $root.GetProperty('state').GetRawText()
            $script:ConfigText = $root.GetProperty('config').GetRawText()
            Mock Read-ParallelDriftJsonText {
                if ($Path.EndsWith($script:CheckpointName)) { return $script:StateText }
                return $script:ConfigText
            }
            $changed = @($root.GetProperty('changed_paths').EnumerateArray() | ForEach-Object { $_.GetString() })
            $fieldName = @($root.EnumerateObject() | ForEach-Object { $_.Name })

            # Act
            $outcome = Invoke-ParallelDriftCli -ItemKey ([string]$root.GetProperty('item_key').GetInt64()) `
                -CheckpointPath $script:CheckpointName -ConfigPath $script:ConfigName `
                -At $root.GetProperty('at').GetString() -ComputedAt $root.GetProperty('computed_at').GetString() `
                -ChangedPath $changed

            # Assert: a payload fixture compares parsed JSON values; an error fixture
            # compares the exit code and the stderr prefix.
            if ($fieldName -ccontains 'expected') {
                $outcome.ExitCode | Should -Be 0 -Because $outcome.Stderr
                $actual = [System.Text.Json.JsonDocument]::Parse($outcome.Stdout)
                try {
                    Test-JsonValueEqual -Left $actual.RootElement -Right $root.GetProperty('expected') |
                        Should -BeTrue -Because $outcome.Stdout
                } finally {
                    $actual.Dispose()
                }
            } else {
                $expectedError = $root.GetProperty('expected_error')
                $outcome.ExitCode | Should -Be $expectedError.GetProperty('exit_code').GetInt32()
                $outcome.Stderr.StartsWith($expectedError.GetProperty('stderr_prefix').GetString()) | Should -BeTrue -Because $outcome.Stderr
                $outcome.Stdout | Should -BeNullOrEmpty
            }
        } finally {
            $document.Dispose()
        }
    }
}
