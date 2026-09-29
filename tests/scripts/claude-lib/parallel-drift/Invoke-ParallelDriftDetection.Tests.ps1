<#
.SYNOPSIS
    Behavioral tests for the parallel drift-detection entry script (issue #763).

.DESCRIPTION
    Covers .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1, the
    destination-runtime port of scripts/dev_tools/parallel_drift_detection_cli.py.
    The script is dot-sourced, so its guarded entry-point body does not run and
    Invoke-ParallelDriftCli is called in-process. The file-read seam
    Read-ParallelDriftJsonText and the clock seam Get-ParallelDriftUtcNow are
    mocked where a test needs them; one context reads the committed fixtures under
    tests/fixtures/parallel_drift_cli for real and asserts they are not written.
    No temporary file is created and no external process is started.
#>

BeforeAll {
    # Resolve the repository root four levels up: parallel-drift -> claude-lib ->
    # scripts -> tests -> repo root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:EntryScriptPath = (Resolve-Path (Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1')).Path

    # The guarded entry-point body does not run under dot-sourcing, so this loads
    # the functions without executing detection.
    . $script:EntryScriptPath

    $script:UsagePrefix = 'parallel drift detection usage error: '
    $script:FailurePrefix = 'parallel drift detection failed: '

    # One in-flight drifter (446) and one in-flight peer (445) whose radius holds
    # src/app.py, with the C1 base truth table.
    $script:CheckpointText = @'
{"items": [
  {"issue_num": 446, "state": "in_flight", "blast_radius": {"paths": ["scripts/dev_tools/**"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-08-08T09-00"}},
  {"issue_num": 445, "state": "in_flight", "blast_radius": {"paths": ["src/app.py"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-08-08T09-00"}}
], "conflict_edges": []}
'@
    $script:ConfigText = '{"shared_surfaces": [".claude/settings.json"], "shared_surface_globs": [], "modules": {"python-dev-tools": ["scripts/dev_tools/**"], "mcp-server": ["packages/mcp-server/**"]}}'

    # Parse an emitted JSON document for assertions.
    function ConvertFrom-EmittedJson {
        param([string] $Text)
        return [System.Text.Json.JsonDocument]::Parse($Text).RootElement
    }
}

Describe 'Invoke-ParallelDriftDetection.ps1' {
    Context 'Parameter surface' {
        It 'declares no Mandatory parameter' {
            # Arrange: every Parameter attribute in the script and in every function it defines.
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:EntryScriptPath, [ref] $null, [ref] $null)
            $parameterAttribute = @($ast.FindAll({
                        param($node)
                        $node -is [System.Management.Automation.Language.AttributeAst] -and $node.TypeName.Name -eq 'Parameter'
                    }, $true))

            # Act
            $mandatory = @($parameterAttribute | Where-Object { @($_.NamedArguments | Where-Object { $_.ArgumentName -eq 'Mandatory' }).Count -gt 0 })

            # Assert: a Mandatory parameter would prompt under pwsh -File instead of exiting 2.
            $parameterAttribute.Count | Should -BeGreaterThan 0
            $mandatory | Should -BeNullOrEmpty
        }

        It 'binds positional arguments only to ChangedPath' {
            # Arrange
            $command = Get-Command -Name $script:EntryScriptPath

            # Act / Assert: every named parameter is non-positional.
            foreach ($name in @('ItemKey', 'CheckpointPath', 'ConfigPath', 'At', 'ComputedAt')) {
                $command.Parameters[$name].ParameterSets.Values.Position | Should -Be ([int]::MinValue)
            }
            $command.Parameters['ChangedPath'].ParameterSets.Values.ValueFromRemainingArguments | Should -BeTrue
        }
    }

    Context 'With mocked file and clock seams' {
        BeforeEach {
            # Route by file name: the truth table is config/blast-radius.json by
            # default (or a *config.json placeholder); every other path, including
            # the default checkpoint path, receives the checkpoint text.
            Mock Read-ParallelDriftJsonText {
                if ($Path.EndsWith('config.json') -or $Path.EndsWith('blast-radius.json')) { return $script:ConfigText }
                return $script:CheckpointText
            }
            Mock Get-ParallelDriftUtcNow { [datetime]::new(2026, 8, 8, 10, 0, 0, [System.DateTimeKind]::Utc) }
        }

        It 'exits 2 when -ItemKey is missing' {
            $outcome = Invoke-ParallelDriftCli -ChangedPath @('src/app.py')

            $outcome.ExitCode | Should -Be 2
            $outcome.Stderr.StartsWith($script:UsagePrefix) | Should -BeTrue
            $outcome.Stdout | Should -BeNullOrEmpty
        }

        It 'exits 2 when -ItemKey is not an integer' {
            $outcome = Invoke-ParallelDriftCli -ItemKey 'abc' -ChangedPath @('src/app.py')

            $outcome.ExitCode | Should -Be 2
            $outcome.Stderr.StartsWith($script:UsagePrefix) | Should -BeTrue
        }

        It 'exits 2 when an unrecognized parameter reaches the remaining arguments' {
            $outcome = Invoke-ParallelDriftCli -ItemKey '446' -ChangedPath @('-Bogus', 'value')

            $outcome.ExitCode | Should -Be 2
            $outcome.Stderr | Should -BeLike "$($script:UsagePrefix)*-Bogus*"
        }

        It 'exits 1 with the failure prefix when the checkpoint cannot be read' {
            Mock Read-ParallelDriftJsonText { throw "Could not find file '$Path'." }

            $outcome = Invoke-ParallelDriftCli -ItemKey '446' -CheckpointPath 'absent.json' -ChangedPath @('src/app.py')

            $outcome.ExitCode | Should -Be 1
            $outcome.Stderr.StartsWith($script:FailurePrefix) | Should -BeTrue
            $outcome.Stdout | Should -BeNullOrEmpty
        }

        It 'exits 1 with the failure prefix when the checkpoint root is not an object' {
            Mock Read-ParallelDriftJsonText { if ($Path.EndsWith('blast-radius.json')) { return $script:ConfigText }; return '[]' }

            $outcome = Invoke-ParallelDriftCli -ItemKey '446' -ChangedPath @('src/app.py')

            $outcome.ExitCode | Should -Be 1
            $outcome.Stderr | Should -BeLike "$($script:FailurePrefix)*must be a JSON object*"
        }

        It 'exits 0 and writes one JSON object to stdout' {
            $outcome = Invoke-ParallelDriftCli -ItemKey '446' -At '2026-08-08T10-00' -ComputedAt '2026-08-08T10-05' -ChangedPath @('src/app.py')

            $outcome.ExitCode | Should -Be 0
            $outcome.Stderr | Should -BeNullOrEmpty
            $root = ConvertFrom-EmittedJson -Text $outcome.Stdout
            $root.ValueKind | Should -Be ([System.Text.Json.JsonValueKind]::Object)
            $root.GetProperty('result').GetString() | Should -BeExactly 'halt_required'
        }

        It 'emits a one-element escaped_paths as a JSON array' {
            $outcome = Invoke-ParallelDriftCli -ItemKey '446' -At '2026-08-08T10-00' -ChangedPath @('src/app.py')

            $escaped = (ConvertFrom-EmittedJson -Text $outcome.Stdout).GetProperty('escaped_paths')
            $escaped.ValueKind | Should -Be ([System.Text.Json.JsonValueKind]::Array)
            $escaped.GetArrayLength() | Should -Be 1
        }

        It 'emits a one-element halted_item_keys as a JSON array' {
            $outcome = Invoke-ParallelDriftCli -ItemKey '446' -At '2026-08-08T10-00' -ChangedPath @('src/app.py')

            $halted = (ConvertFrom-EmittedJson -Text $outcome.Stdout).GetProperty('halted_item_keys')
            $halted.ValueKind | Should -Be ([System.Text.Json.JsonValueKind]::Array)
            $halted.GetArrayLength() | Should -Be 1
            $halted[0].GetInt64() | Should -Be 445
        }

        It 'returns timestamp-shaped strings unchanged' {
            # Arrange: the peer radius carries an ISO-8601 computed_at that
            # ConvertFrom-Json would have turned into a DateTime.
            $script:CheckpointText = $script:CheckpointText.Replace('"paths": ["src/app.py"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-08-08T09-00"',
                '"paths": ["src/other.py"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-08-08T09:00:00Z"')
            try {
                # Act
                $converted = ConvertFrom-ParallelDriftJson -Text '{"computed_at": "2026-08-08T09:00:00Z"}'
                $outcome = Invoke-ParallelDriftCli -ItemKey '446' -At '2026-08-08T10-00' -ChangedPath @('docs/notes.md')

                # Assert: the string round-trips and the peer is evaluated, not failed closed.
                $converted['computed_at'] | Should -BeOfType [string]
                $converted['computed_at'] | Should -BeExactly '2026-08-08T09:00:00Z'
                $outcome.ExitCode | Should -Be 0
                (ConvertFrom-EmittedJson -Text $outcome.Stdout).GetProperty('result').GetString() | Should -BeExactly 'no_new_conflict'
            } finally {
                $script:CheckpointText = $script:CheckpointText.Replace('"paths": ["src/other.py"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-08-08T09:00:00Z"',
                    '"paths": ["src/app.py"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-08-08T09-00"')
            }
        }

        It 'treats an omitted ChangedPath as an empty changed-path list' {
            # Act: once with no ChangedPath and once with an explicit null, as the guard passes it.
            $omitted = Invoke-ParallelDriftCli -ItemKey 446 -CheckpointPath 'placeholder-checkpoint.json' -ConfigPath 'placeholder-config.json' -At '2026-08-08T10-00'
            $explicitNull = Invoke-ParallelDriftCli -ItemKey 446 -CheckpointPath 'placeholder-checkpoint.json' -ConfigPath 'placeholder-config.json' -At '2026-08-08T10-00' -ChangedPath $null

            # Assert
            foreach ($outcome in @($omitted, $explicitNull)) {
                $outcome.ExitCode | Should -Be 0
                $root = ConvertFrom-EmittedJson -Text $outcome.Stdout
                $root.GetProperty('result').GetString() | Should -BeExactly 'no_escape'
                $root.GetProperty('escaped_paths').GetArrayLength() | Should -Be 0
            }
        }

        It 'defaults -At to the mocked UTC clock formatted yyyy-MM-ddTHH-mm' {
            $outcome = Invoke-ParallelDriftCli -ItemKey '446' -ChangedPath @('src/app.py')

            $root = ConvertFrom-EmittedJson -Text $outcome.Stdout
            $root.GetProperty('at').GetString() | Should -BeExactly '2026-08-08T10-00'
            Should -Invoke Get-ParallelDriftUtcNow -Times 1 -Exactly
        }

        It 'defaults -ComputedAt to the resolved -At' {
            $outcome = Invoke-ParallelDriftCli -ItemKey '446' -At '2026-08-08T11-11' -ChangedPath @('src/app.py')

            $root = ConvertFrom-EmittedJson -Text $outcome.Stdout
            $root.GetProperty('computed_at').GetString() | Should -BeExactly '2026-08-08T11-11'
            $root.GetProperty('observed_radius').GetProperty('computed_at').GetString() | Should -BeExactly '2026-08-08T11-11'
            Should -Invoke Get-ParallelDriftUtcNow -Times 0 -Exactly
        }
    }

    Context 'JSON conversion' {
        It 'sorts object keys ordinally in the emitted JSON' {
            # Arrange: an ordinal table whose keys differ only by case and order.
            $inner = [hashtable]::new([System.StringComparer]::Ordinal)
            $inner['z'] = 1
            $inner['Y'] = 2
            $table = [hashtable]::new([System.StringComparer]::Ordinal)
            $table['b'] = $inner
            $table['A'] = 2
            $table['a'] = @('x')

            # Act
            $root = ConvertFrom-EmittedJson -Text (ConvertTo-ParallelDriftJson -Value $table)

            # Assert
            @($root.EnumerateObject() | ForEach-Object { $_.Name }) | Should -Be @('A', 'a', 'b')
            @($root.GetProperty('b').EnumerateObject() | ForEach-Object { $_.Name }) | Should -Be @('Y', 'z')
            $root.GetProperty('a').ValueKind | Should -Be ([System.Text.Json.JsonValueKind]::Array)
        }

        It 'converts integers, floats, booleans, null, arrays, and objects from JSON' {
            # Act
            $value = ConvertFrom-ParallelDriftJson -Text '{"i": 5, "f": 1.5, "t": true, "u": false, "n": null, "a": [1, "x", [2]], "o": {"k": "v"}}'

            # Assert
            $value | Should -BeOfType [hashtable]
            $value['i'] | Should -BeOfType [long]
            $value['f'] | Should -BeOfType [double]
            $value['t'] | Should -BeTrue
            $value['u'] | Should -BeOfType [bool]
            $value.ContainsKey('n') | Should -BeTrue
            $value['n'] | Should -BeNullOrEmpty
            , $value['a'] | Should -BeOfType [object[]]
            $value['a'].Count | Should -Be 3
            , $value['a'][2] | Should -BeOfType [object[]]
            $value['o']['k'] | Should -BeExactly 'v'
        }

        It 'keeps JSON object keys case-sensitive' {
            $value = ConvertFrom-ParallelDriftJson -Text '{"Key": 1, "key": 2}'

            $value.Count | Should -Be 2
            $value['Key'] | Should -Be 1
            $value['key'] | Should -Be 2
        }

        It 'emits floats, booleans, and nulls as JSON values' {
            $table = [hashtable]::new([System.StringComparer]::Ordinal)
            $table['f'] = 1.5
            $table['t'] = $true
            $table['n'] = $null

            $root = ConvertFrom-EmittedJson -Text (ConvertTo-ParallelDriftJson -Value $table)

            $root.GetProperty('f').GetDouble() | Should -Be 1.5
            $root.GetProperty('t').GetBoolean() | Should -BeTrue
            $root.GetProperty('n').ValueKind | Should -Be ([System.Text.Json.JsonValueKind]::Null)
        }

        It 'rejects a value it cannot serialize' {
            { ConvertTo-ParallelDriftJson -Value ([pscustomobject]@{ a = 1 }) } | Should -Throw '*cannot serialize*'
        }
    }

    Context 'With the real file seam' {
        It 'reads the committed checkpoint and config fixtures and leaves both files unchanged' {
            # Arrange
            $checkpointPath = Join-Path -Path $script:RepoRoot -ChildPath 'tests/fixtures/parallel_drift_cli/checkpoint.json'
            $configPath = Join-Path -Path $script:RepoRoot -ChildPath 'tests/fixtures/parallel_drift_cli/config.json'
            $before = @((Get-FileHash -LiteralPath $checkpointPath).Hash, (Get-FileHash -LiteralPath $configPath).Hash)

            # Act
            $outcome = Invoke-ParallelDriftCli -ItemKey '446' -CheckpointPath $checkpointPath -ConfigPath $configPath `
                -At '2026-08-08T10-00' -ComputedAt '2026-08-08T10-05' -ChangedPath @('src/app.py')
            $after = @((Get-FileHash -LiteralPath $checkpointPath).Hash, (Get-FileHash -LiteralPath $configPath).Hash)

            # Assert
            $outcome.ExitCode | Should -Be 0
            $root = ConvertFrom-EmittedJson -Text $outcome.Stdout
            $root.GetProperty('result').GetString() | Should -BeExactly 'halt_required'
            $root.GetProperty('halted_item_keys')[0].GetInt64() | Should -Be 445
            $after | Should -Be $before
        }

        It 'resolves relative paths against the current location' {
            Push-Location -LiteralPath $script:RepoRoot
            try {
                # Act
                $resolved = Resolve-ParallelDriftPath -Path 'tests/fixtures/parallel_drift_cli/config.json'
                $rooted = Resolve-ParallelDriftPath -Path $script:EntryScriptPath
                $outcome = Invoke-ParallelDriftCli -ItemKey '446' -CheckpointPath 'tests/fixtures/parallel_drift_cli/checkpoint.json' `
                    -ConfigPath 'tests/fixtures/parallel_drift_cli/config.json' -At '2026-08-08T10-00' -ChangedPath @('src/app.py')

                # Assert
                $resolved | Should -Be (Join-Path -Path $script:RepoRoot -ChildPath 'tests/fixtures/parallel_drift_cli/config.json')
                $rooted | Should -Be $script:EntryScriptPath
                $outcome.ExitCode | Should -Be 0
            } finally {
                Pop-Location
            }
        }
    }
}
