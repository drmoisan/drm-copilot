<#
.SYNOPSIS
    Behavioral tests for write-intent extraction (issue #722).

.DESCRIPTION
    Mirrors tests/scripts/dev_tools/test_blast_radius_write_intent.py against
    .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 and the facade flag
    branches: rules W1 through W6, the strict readers of write_intent_extraction
    and path_roots, the token-level filter applied in normalization, the
    extractor selector shared by derivation and validation, the flag-absent
    identity with current extraction, and the eight committed write-intent
    fixtures. The vocabulary parity case reads the committed Python module source
    and compares its three constants with the PowerShell constants. Each It
    follows Arrange-Act-Assert. The tests read only committed files, create no
    temporary file, and start no external process.
#>

# Discovery-time corpus enumeration. Pester runs the file body during discovery,
# so every generated It needs its case data here.
$fixtureDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/blast_radius/write-intent").Path
$writeIntentCase = @(
    'write-intent-glob-mention',
    'write-intent-command-span',
    'write-intent-read-task',
    'write-intent-root-anchoring',
    'write-intent-spec-contracts-only',
    'write-intent-placeholder-stem',
    'write-intent-shared-surface-read-citation',
    'write-intent-flag-absent-matches-current'
) | ForEach-Object { @{ FixtureName = $_; FixturePath = (Join-Path $fixtureDirectory "$_.json") } }
$readerCase = @(
    @{ Case = 'flag-string'; Key = 'write_intent_extraction'; Value = 'true' },
    @{ Case = 'flag-int'; Key = 'write_intent_extraction'; Value = 1 },
    @{ Case = 'path-roots-string'; Key = 'path_roots'; Value = 'src' },
    @{ Case = 'path-roots-non-string-entry'; Key = 'path_roots'; Value = @('src', 3) }
)

BeforeAll {
    $libraryDirectory = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius").Path
    Import-Module (Join-Path $libraryDirectory 'BlastRadius.psm1') -Force
    # The relation is passed explicitly to every scheduling call, so no call
    # depends on command resolution inside the scheduling module.
    $script:ConflictRelation = ${function:Test-BlastRadiusConflict}
    # A second, direct import exposes the module scope that holds the constants.
    $script:WriteIntentModule = Import-Module (Join-Path $libraryDirectory 'BlastRadiusWriteIntent.psm1') -Force -PassThru
    $script:PythonModulePath = (Resolve-Path "$PSScriptRoot/../../../../scripts/dev_tools/_blast_radius_write_intent.py").Path
    $script:FixtureDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/blast_radius/write-intent").Path
    $script:FolderGlob = 'docs/features/active/demo-feature-1/**'

    # The B31 shared write-intent truth table with optional top-level overrides.
    function Get-TestConfig {
        param([hashtable] $Override = @{})
        $config = @{
            version                 = 1
            shared_surfaces         = @('poetry.lock', 'config/blast-radius.json')
            shared_surface_globs    = @()
            mandate_reads           = @('.claude/rules/**', '.github/copilot-instructions.md')
            mergeable_paths         = @()
            write_intent_extraction = $true
            path_roots              = @('src', 'config', 'docs', 'tests', '.claude')
            modules                 = @{ config = @('config/**') }
            over_breadth_fraction   = 0.25
        }
        foreach ($key in $Override.Keys) { $config[$key] = $Override[$key] }
        return $config
    }

    function Format-TestTask {
        param([string] $Title, [int] $Number = 1)
        return "- [ ] [P1-T$Number] $Title"
    }

    function Get-TestDerivedRadius {
        param([string] $PlanText, [hashtable] $Config, [string] $SpecText = '', [string] $Folder = 'demo-feature-1')
        return Get-BlastRadius -PlanText $PlanText -SpecText $SpecText -FeatureFolder $Folder -Config $Config -ComputedAt '2026-09-27T00-00'
    }

    function Get-TestRecordedRadius {
        param([string[]] $Paths)
        return @{ paths = $Paths; modules = @(); shared_surfaces = @(); contracts = @(); source = 'declared'; computed_at = '2026-09-27T00-00' }
    }

    function Read-TestFixture {
        param([string] $Path)
        return (Get-Content -Path $Path -Raw | ConvertFrom-Json -AsHashtable)
    }

    # Apply a case's overrides and removals to a deep copy of the fixture config.
    function Get-TestCaseConfig {
        param([hashtable] $Fixture, [hashtable] $Case)
        $config = ConvertTo-Json -InputObject $Fixture['config'] -Depth 20 | ConvertFrom-Json -AsHashtable
        foreach ($key in $Case['config_overrides'].Keys) { $config[$key] = $Case['config_overrides'][$key] }
        foreach ($key in @($Case['remove_keys'])) { if ($null -ne $key) { $config.Remove($key) } }
        return $config
    }

    function Join-TestValue {
        param([object] $Value)
        return (@($Value) -join '|')
    }

    # Read one vocabulary tuple from the Python module source: the quoted
    # segments between the constant's tuple( and .split() are joined and split.
    function Get-PythonVocabulary {
        param([string] $Text, [string] $Name)
        $pattern = "(?s)$Name`: tuple\[str, \.\.\.\] = tuple\((.*?)\.split\(\)"
        $body = [regex]::Match($Text, $pattern).Groups[1].Value
        $joined = (@([regex]::Matches($body, '"([^"]*)"') | ForEach-Object { $_.Groups[1].Value }) -join '')
        return @($joined -split '\s+' | Where-Object { $_.Length -gt 0 })
    }
}

Describe 'BlastRadiusWriteIntent' {
    Context 'Rules W1 through W6' {
        It 'drops glob-mention tokens (W1)' {
            $plan = Format-TestTask 'Update `src/app.py`, `src/**/*.py`, and `src/a?.py`.'
            $result = @(Get-WriteIntentPlanPath -PlanText $plan)
            @(Get-PlanPaths -PlanText $plan) | Should -Contain 'src/**/*.py' -Because 'current extraction keeps the glob'
            Join-TestValue $result | Should -BeExactly 'src/app.py'
        }

        It 'never drops the feature-folder glob (W1)' {
            $radius = Get-TestDerivedRadius -PlanText (Format-TestTask 'Update `src/app.py`.') -Config (Get-TestConfig -Override @{ path_roots = @('src') })
            $kept = @(Select-WriteIntentPathEntry -Entry @($script:FolderGlob) -PathRoot @('src'))
            @($radius['paths']) | Should -Contain $script:FolderGlob
            Join-TestValue $kept | Should -BeExactly $script:FolderGlob
        }

        It 'drops every token of a multi-word span (W2)' {
            $plan = Format-TestTask 'Update `src/app.py`, then run `git add src/other.py`.'
            @(Get-PlanPaths -PlanText $plan) | Should -Contain 'src/other.py'
            Join-TestValue @(Get-WriteIntentPlanPath -PlanText $plan) | Should -BeExactly 'src/app.py'
        }

        It 'drops the tokens of a read task (W3)' {
            $plan = @(
                (Format-TestTask 'Read `src/policy.py` in full.'),
                '      Also cite `src/policy_detail.py`.',
                '### Phase 2 - Next',
                'Prose citing `src/after_heading.py`.',
                (Format-TestTask '**Baseline:** Read `src/base.py`.' 2)
            ) -join "`n"
            Join-TestValue @(Get-WriteIntentPlanPath -PlanText $plan) | Should -BeExactly 'src/after_heading.py'
            foreach ($verb in @('read', 'verify', 'confirm', 'inspect', 'review', 'baseline')) {
                @(Get-WriteIntentPlanPath -PlanText (Format-TestTask "$verb ``src/app.py``.")).Count | Should -Be 0 -Because "$verb is a read verb"
            }
        }

        It 'lets a write verb override a read verb (W3)' {
            $plan = Format-TestTask 'Verify and fix `src/fixme.py`.'
            Join-TestValue @(Get-WriteIntentPlanPath -PlanText $plan) | Should -BeExactly 'src/fixme.py'
            Join-TestValue @(Get-WriteIntentPlanPath -PlanText (Format-TestTask 'Review and UPDATE `src/app.py`.')) | Should -BeExactly 'src/app.py'
            @(Get-WriteIntentPlanPath -PlanText (Format-TestTask 'Review the fixme notes in `src/app.py`.')).Count | Should -Be 0
        }

        It 'drops tokens outside path_roots unless they are root surfaces (W4)' {
            $plan = Format-TestTask 'Update `src/app.py`, `./src/beta.py`, `research/notes.md`, and `poetry.lock`.'
            $result = @(Get-WriteIntentPlanPath -PlanText $plan -RootSurface @('poetry.lock') -PathRoot @('src'))
            Join-TestValue $result | Should -BeExactly './src/beta.py|poetry.lock|src/app.py'
        }

        It 'disables root anchoring when path_roots is empty (W4)' {
            $plan = Format-TestTask 'Update `src/app.py` and `research/notes.md`.'
            $config = Get-TestConfig
            $config.Remove('path_roots')
            Join-TestValue @(Get-WriteIntentPlanPath -PlanText $plan) | Should -BeExactly 'research/notes.md|src/app.py'
            @((Get-TestDerivedRadius -PlanText $plan -Config $config)['paths']) | Should -Contain 'research/notes.md'
        }

        It 'lets the spec contribute contracts only (W5)' {
            $spec = "## Public API`n`n- ``computeWidget```n- ``src/spec_only.py```n- ``*.ts```n- ``git add widget```n"
            $radius = Get-TestDerivedRadius -PlanText (Format-TestTask 'Update `src/app.py`.') -Config (Get-TestConfig) -SpecText $spec
            Join-TestValue $radius['paths'] | Should -BeExactly "$($script:FolderGlob)|src/app.py"
            Join-TestValue $radius['contracts'] | Should -BeExactly 'computeWidget'
            Join-TestValue @(Get-WriteIntentSpecContract -SpecText $spec) | Should -BeExactly 'computeWidget'
        }

        It 'drops placeholder-stem tokens (W6)' {
            $plan = Format-TestTask 'Update `src/app.py`, `src/X.ts`, `tests/foo.py`, `tests/Example.md`, and `src/foo_bar.py`.'
            Join-TestValue @(Get-WriteIntentPlanPath -PlanText $plan) | Should -BeExactly 'src/app.py|src/foo_bar.py'
        }
    }

    Context 'Flag behavior and selector' {
        It 'does not make a shared-surface read citation hard' {
            $config = Get-TestConfig
            $readerPlan = @((Format-TestTask 'Read `config/blast-radius.json` in full.'), (Format-TestTask 'Update `src/alpha.py`.' 2)) -join "`n"
            $reader = Get-TestDerivedRadius -PlanText $readerPlan -Config $config -Folder 'demo-reader'
            $writer = Get-TestDerivedRadius -PlanText (Format-TestTask 'Update `config/blast-radius.json` to add a key.') -Config $config -Folder 'demo-writer'
            $second = Get-TestDerivedRadius -PlanText (Format-TestTask 'Update `config/blast-radius.json` again.') -Config $config -Folder 'demo-second'
            @($reader['shared_surfaces']).Count | Should -Be 0
            @($reader['paths']) | Should -Contain 'src/alpha.py'
            (Get-BlastRadiusPairDecision -RadiusA $reader -RadiusB $writer -Config $config -Relation $script:ConflictRelation)['conflict'] | Should -BeFalse
            (Get-BlastRadiusPairDecision -RadiusA $writer -RadiusB $second -Config $config -Relation $script:ConflictRelation)['hard'] | Should -BeTrue
        }

        It 'matches current behavior when the flag is absent' {
            $plan = Format-TestTask 'Update `src/app.py`; run `git add src/other.py`; see `src/**/*.py`.'
            $config = Get-TestConfig
            $config.Remove('write_intent_extraction')
            $baseline = Get-TestConfig
            $baseline.Remove('write_intent_extraction')
            $baseline.Remove('path_roots')
            $radius = Get-TestDerivedRadius -PlanText $plan -Config $config
            $recorded = Get-TestRecordedRadius -Paths @('src/**/*.py', 'src/x.ts')
            Join-TestValue $radius['paths'] | Should -BeExactly (Join-TestValue (Get-TestDerivedRadius -PlanText $plan -Config $baseline)['paths'])
            @($radius['paths']) | Should -Contain 'src/other.py'
            Join-TestValue (Get-NormalizedDeclaredRadius -Radius $recorded -Config $config)['paths'] | Should -BeExactly 'src/**/*.py|src/x.ts'
            @(Test-BlastRadius -Radius $radius -PlanText $plan -Config $config -TrackedFileCount 1000).Count | Should -Be 0
        }

        It 'matches current behavior when the flag is false' {
            $plan = Format-TestTask 'Update `src/app.py`; run `git add src/other.py`; see `src/**/*.py`.'
            $config = Get-TestConfig -Override @{ write_intent_extraction = $false }
            $baseline = Get-TestConfig
            $baseline.Remove('write_intent_extraction')
            $baseline.Remove('path_roots')
            $recorded = Get-TestRecordedRadius -Paths @('research/x.md', 'src/x.ts')
            Join-TestValue (Get-TestDerivedRadius -PlanText $plan -Config $config)['paths'] | Should -BeExactly (Join-TestValue (Get-TestDerivedRadius -PlanText $plan -Config $baseline)['paths'])
            Join-TestValue (Get-NormalizedDeclaredRadius -Radius $recorded -Config $config)['paths'] | Should -BeExactly 'research/x.md|src/x.ts'
            Join-TestValue @(Get-PlanPathForConfig -PlanText $plan -Config $config) | Should -BeExactly (Join-TestValue @(Get-PlanPaths -PlanText $plan))
        }

        It 'derives radii that pass V1 and V2 in write-intent mode' {
            $checked = 0
            foreach ($path in @(Get-ChildItem -Path $script:FixtureDirectory -Filter '*.json' -File | Sort-Object -Property Name)) {
                $fixture = Read-TestFixture -Path $path.FullName
                $config = Get-TestCaseConfig -Fixture $fixture -Case $fixture['cases'][0]
                foreach ($item in @($fixture['items'])) {
                    $radius = Get-TestDerivedRadius -PlanText $item['plan_text'] -Config $config -SpecText $item['spec_text'] -Folder $item['feature_folder']
                    $blocking = @(Test-BlastRadius -Radius $radius -PlanText $item['plan_text'] -Config $config -TrackedFileCount 1000 | Where-Object { $_['rule'] -in @('V1', 'V2') })
                    $blocking.Count | Should -Be 0 -Because "$($path.BaseName) item $($item['key'])"
                    $checked++
                }
            }
            $checked | Should -Be 11 -Because 'every fixture item must be validated'
        }

        It 'pins the same read-verb, write-verb, and placeholder-stem sets as the Python module' {
            $pythonText = Get-Content -Path $script:PythonModulePath -Raw
            $pairs = @(
                @{ Python = 'READ_VERBS'; PowerShell = 'WriteIntentReadVerb' },
                @{ Python = 'WRITE_VERBS'; PowerShell = 'WriteIntentWriteVerb' },
                @{ Python = 'PLACEHOLDER_STEMS'; PowerShell = 'WriteIntentPlaceholderStem' }
            )
            foreach ($pair in $pairs) {
                $pythonSet = @(Get-PythonVocabulary -Text $pythonText -Name $pair['Python'])
                $powerShellSet = @(& $script:WriteIntentModule { param($Name) (Get-Variable -Name $Name -Scope Script).Value } $pair['PowerShell'])
                $pythonSet.Count | Should -BeGreaterThan 5 -Because "$($pair['Python']) must be read from the Python source"
                ($powerShellSet -join ' ') | Should -BeExactly ($pythonSet -join ' ') -Because "$($pair['PowerShell']) must equal $($pair['Python'])"
            }
        }

        It 'never adds a token under the write-intent rules' {
            $titles = @('Update', 'Read', 'Verify and fix', '**Baseline:** Read', 'Inspect')
            $pool = @('`src/app.py`', '`src/**/*.py`', '`git add src/other.py`', '`research/notes.md`', '`tests/foo.py`', '`./src/b.py`', '`poetry.lock`', '`src/x.ts`')
            $smaller = 0
            $equalNonEmpty = 0
            # Every title, unordered span pair, and path_roots setting is one input.
            foreach ($title in $titles) {
                for ($first = 0; $first -lt $pool.Count; $first++) {
                    for ($second = $first + 1; $second -lt $pool.Count; $second++) {
                        foreach ($roots in @(, @()) + @(, @('src', 'tests'))) {
                            $plan = Format-TestTask "$title $($pool[$first]) and $($pool[$second])."
                            $current = @(Get-PlanPaths -PlanText $plan -RootSurface @('poetry.lock'))
                            $narrowed = @(Get-WriteIntentPlanPath -PlanText $plan -RootSurface @('poetry.lock') -PathRoot $roots)
                            $filtered = @(Select-WriteIntentPathEntry -Entry $current -RootSurface @('poetry.lock') -PathRoot $roots)
                            foreach ($token in $narrowed + $filtered) { $current | Should -Contain $token -Because $plan }
                            if ($narrowed.Count -lt $current.Count) { $smaller++ }
                            if ($narrowed.Count -gt 0 -and $narrowed.Count -eq $current.Count) { $equalNonEmpty++ }
                        }
                    }
                }
            }
            $smaller | Should -BeGreaterThan 0 -Because 'the domain must exercise a dropped token'
            $equalNonEmpty | Should -BeGreaterThan 0 -Because 'the domain must exercise a kept token'
        }
    }

    Context 'Committed fixtures and readers' {
        It 'reproduces the expected radius for <FixtureName>' -ForEach $writeIntentCase {
            $fixture = Read-TestFixture -Path $FixturePath
            $items = @{}
            foreach ($item in @($fixture['items'])) { $items[[long]$item['key']] = $item }
            foreach ($case in @($fixture['cases'])) {
                $config = Get-TestCaseConfig -Fixture $fixture -Case $case
                $derived = [System.Collections.Generic.List[object]]::new()
                foreach ($expected in @($case['expected_radii'])) {
                    $item = $items[[long]$expected['key']]
                    $radius = Get-TestDerivedRadius -PlanText $item['plan_text'] -Config $config -SpecText $item['spec_text'] -Folder $item['feature_folder']
                    $derived.Add(@{ key = [long]$expected['key']; radius = $radius })
                    foreach ($level in @('paths', 'modules', 'shared_surfaces', 'contracts')) {
                        Join-TestValue $radius[$level] | Should -BeExactly (Join-TestValue $expected[$level]) -Because "$FixtureName/$($case['name'])/$($expected['key'])/$level"
                    }
                    if ($case.ContainsKey('expected_findings')) {
                        $subject = @(Test-BlastRadius -Radius $radius -PlanText $item['plan_text'] -Config $config -TrackedFileCount 1000 | ForEach-Object { $_['subject'] })
                        Join-TestValue $subject | Should -BeExactly (Join-TestValue $case['expected_findings'])
                    }
                }
                if ($case.ContainsKey('expected_edges')) {
                    $result = Get-BlastRadiusConflictEdge -Item $derived.ToArray() -Config $config -Relation $script:ConflictRelation
                    $edges = @($result['edges'] | ForEach-Object { '{0}-{1}|{2}|{3}|{4}|{5}' -f $_['a'], $_['b'], $_['reason'], $_['hard'], $_['cost'], $_['benefit'] })
                    $expectedEdges = @($case['expected_edges'] | ForEach-Object { '{0}-{1}|{2}|{3}|{4}|{5}' -f $_['a'], $_['b'], $_['reason'], $_['hard'], $_['cost'], $_['benefit'] })
                    Join-TestValue $edges | Should -BeExactly (Join-TestValue $expectedEdges)
                    @($result['tolerated_overlaps']).Count | Should -Be @($case['expected_tolerated']).Count
                }
                if ($case.ContainsKey('normalization')) {
                    $recorded = Get-TestRecordedRadius -Paths $case['normalization']['paths']
                    Join-TestValue (Get-NormalizedDeclaredRadius -Radius $recorded -Config $config)['paths'] | Should -BeExactly (Join-TestValue $case['normalization']['expected_paths'])
                }
            }
        }

        It 'rejects the invalid shape <Case>' -ForEach $readerCase {
            $config = Get-TestConfig -Override @{ $Key = $Value }
            $reader = if ($Key -eq 'path_roots') { { Get-ConfigPathRoot -Config $config } } else { { Test-WriteIntentExtractionEnabled -Config $config } }
            $reader | Should -Throw -ExpectedMessage "*$Key*"
        }

        It 'keeps the feature-folder glob in write-intent normalization' {
            $recorded = Get-TestRecordedRadius -Paths @($script:FolderGlob, 'src/**/*.py', 'research/x.md', 'src/x.ts', 'src/app.py')
            $normalized = Get-NormalizedDeclaredRadius -Radius $recorded -Config (Get-TestConfig -Override @{ path_roots = @('src') })
            Join-TestValue $normalized['paths'] | Should -BeExactly "$($script:FolderGlob)|src/app.py"
        }
    }
}
