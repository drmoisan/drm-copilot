#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
    Issue #697 (AC-4.9): unit tests for .codex/scripts/codex-routing-cli-common.ps1,
    the helper shared by the two Codex routing wrappers. Covers module-candidate
    construction and resolution, the GNU-style token parser, and the
    Python-compatible JSON serializer. No temporary file is created; missing
    candidates are non-existent path strings.
#>

Describe 'codex-routing-cli-common.ps1 (issue #697)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/scripts/codex-routing-cli-common.ps1')

        # A parser specification exercising every token kind the wrappers use.
        $script:ParserSpecification = [ordered]@{
            '--name'  = @{ Key = 'name'; Kind = 'value'; Required = $false; Default = $null }
            '--item'  = @{ Key = 'item'; Kind = 'append'; Required = $false; Default = $null }
            '--flag'  = @{ Key = 'flag'; Kind = 'switch'; Required = $false; Default = $false }
            '--mode'  = @{ Key = 'mode'; Kind = 'value'; Required = $true; Choices = @('a', 'b'); Default = $null }
            '--count' = @{ Key = 'count'; Kind = 'int'; Required = $false; Default = 0 }
        }
    }

    Context 'module candidates' {
        It 'selects the first candidate when both candidates exist' {
            $first = Join-Path $script:RepoRoot '.claude/lib/codex-routing/CodexTopology.psm1'
            $second = Join-Path $script:RepoRoot 'extensions/drm-copilot/resources/lib/codex-routing/CodexTopology.psm1'

            Resolve-CodexRoutingModulePath -Candidate @($first, $second) | Should -Be $first
        }

        It 'selects the second candidate when the first does not exist' {
            $first = Join-Path $script:RepoRoot '.codex/lib/codex-routing/CodexTopology.psm1'
            $second = Join-Path $script:RepoRoot '.claude/lib/codex-routing/CodexTopology.psm1'

            Resolve-CodexRoutingModulePath -Candidate @($first, $second) | Should -Be $second
        }

        It 'returns a non-zero exit and names every candidate when no candidate exists' {
            . (Join-Path $script:RepoRoot '.codex/scripts/Resolve-CodexTopology.ps1')
            $missingA = Join-Path $script:RepoRoot 'tests/fixtures/codex_routing/absent-a/CodexTopology.psm1'
            $missingB = Join-Path $script:RepoRoot 'tests/fixtures/codex_routing/absent-b/CodexTopology.psm1'

            $result = Invoke-CodexTopologyCli -Arguments @('--execution-context', 'standalone') -ModuleCandidates @($missingA, $missingB)

            $result.ExitCode | Should -Not -Be 0
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeLike '*CODEX_ROUTING_MODULE_NOT_FOUND*'
            $result.Stderr.Contains($missingA) | Should -BeTrue
            $result.Stderr.Contains($missingB) | Should -BeTrue
        }

        It 'returns a non-zero exit from the deployment wrapper when no candidate exists' {
            . (Join-Path $script:RepoRoot '.codex/scripts/Resolve-CodexDeployment.ps1')
            $missing = Join-Path $script:RepoRoot 'tests/fixtures/codex_routing/absent-a/CodexDeployment.psm1'
            $arguments = @('--logical-agent', 'orchestrator', '--complexity-band', 'C1', '--execution-context', 'standalone', '--orchestration-complexity-ceiling', 'C1')

            $result = Invoke-CodexDeploymentCli -Arguments $arguments -ModuleCandidates @($missing)

            $result.ExitCode | Should -Be 1
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeLike '*CODEX_ROUTING_MODULE_NOT_FOUND*'
            $result.Stderr.Contains($missing) | Should -BeTrue
        }

        It 'builds the destination-then-self-hosting candidate order' {
            $scriptRoot = Join-Path $script:RepoRoot '.codex/scripts'

            $candidates = @(Get-CodexRoutingModuleCandidate -ScriptRoot $scriptRoot -ModuleName 'CodexTopology.psm1')

            $candidates.Count | Should -Be 2
            $candidates[0] | Should -Be (Join-Path $scriptRoot '../lib/codex-routing/CodexTopology.psm1')
            $candidates[1] | Should -Be (Join-Path $scriptRoot '../../.claude/lib/codex-routing/CodexTopology.psm1')
        }
    }

    Context 'token parser' {
        It 'parses <Label>' -ForEach @(
            @{ Label = 'a value with the last occurrence winning'; Arguments = @('--mode', 'a', '--name', 'x', '--name', 'z'); Key = 'name'; Expected = 'z'; ErrorPattern = $null }
            @{ Label = 'an equals-sign value'; Arguments = @('--mode=b', '--name=y'); Key = 'mode'; Expected = 'b'; ErrorPattern = $null }
            @{ Label = 'a repeated append'; Arguments = @('--mode', 'a', '--item', 'p', '--item', 'q'); Key = 'item'; Expected = @('p', 'q'); ErrorPattern = $null }
            @{ Label = 'a switch'; Arguments = @('--mode', 'a', '--flag'); Key = 'flag'; Expected = $true; ErrorPattern = $null }
            @{ Label = 'a default integer'; Arguments = @('--mode', 'a'); Key = 'count'; Expected = 0; ErrorPattern = $null }
            @{ Label = 'an integer value'; Arguments = @('--mode', 'a', '--count', '7'); Key = 'count'; Expected = 7; ErrorPattern = $null }
            @{ Label = 'an unknown flag'; Arguments = @('--mode', 'a', '--bogus'); Key = $null; Expected = $null; ErrorPattern = '*error: unrecognized arguments: --bogus*' }
            @{ Label = 'a positional token'; Arguments = @('--mode', 'a', 'stray'); Key = $null; Expected = $null; ErrorPattern = '*error: unrecognized arguments: stray*' }
            @{ Label = 'a missing value'; Arguments = @('--mode'); Key = $null; Expected = $null; ErrorPattern = '*error: argument --mode: expected one argument*' }
            @{ Label = 'a missing required flag'; Arguments = @('--name', 'x'); Key = $null; Expected = $null; ErrorPattern = '*error: the following arguments are required: --mode*' }
            @{ Label = 'an invalid choice'; Arguments = @('--mode', 'c'); Key = $null; Expected = $null; ErrorPattern = "*error: argument --mode: invalid choice: 'c'*" }
            @{ Label = 'a non-integer count'; Arguments = @('--mode', 'a', '--count', 'two'); Key = $null; Expected = $null; ErrorPattern = "*error: argument --count: invalid int value: 'two'*" }
            @{ Label = 'a value on a switch'; Arguments = @('--mode', 'a', '--flag=yes'); Key = $null; Expected = $null; ErrorPattern = '*error: argument --flag: ignored explicit argument*' }
            @{ Label = 'a negative-number value'; Arguments = @('--mode', 'a', '--count', '-5'); Key = 'count'; Expected = -5; ErrorPattern = $null }
            @{ Label = 'an option-like value'; Arguments = @('--mode', 'a', '--name', '-x'); Key = $null; Expected = $null; ErrorPattern = '*error: argument --name: expected one argument*' }
            @{ Label = 'tokens after a double-dash separator'; Arguments = @('--mode', 'a', '--', '--name', 'x'); Key = $null; Expected = $null; ErrorPattern = '*error: unrecognized arguments: --name x*' }
        ) {
            $parsed = ConvertFrom-CodexRoutingArgument -Arguments ([string[]]$Arguments) -Specification $script:ParserSpecification

            if ($null -ne $ErrorPattern) {
                $parsed.Error | Should -BeLike $ErrorPattern
                return
            }
            $parsed.Error | Should -BeNullOrEmpty
            if ($Expected -is [array]) {
                @($parsed.Values[$Key]) | Should -Be $Expected
            } else {
                $parsed.Values[$Key] | Should -Be $Expected
            }
        }

        It 'parses an empty argument list into defaults except the required flag' {
            $parsed = ConvertFrom-CodexRoutingArgument -Arguments ([string[]]@()) -Specification $script:ParserSpecification

            $parsed.Error | Should -BeLike '*required: --mode*'
        }
    }

    Context 'JSON serializer' {
        It 'serializes <Label> like Python json.dumps' -ForEach @(
            @{ Label = 'an empty array'; Value = @{ k = [string[]]@() }; Expected = "{`n  `"k`": []`n}" }
            @{ Label = 'a single-element array'; Value = @{ k = [string[]]@('x') }; Expected = "{`n  `"k`": [`n    `"x`"`n  ]`n}" }
            @{ Label = 'null'; Value = @{ k = $null }; Expected = "{`n  `"k`": null`n}" }
            @{ Label = 'booleans'; Value = @{ t = $true; f = $false }; Expected = "{`n  `"f`": false,`n  `"t`": true`n}" }
            @{ Label = 'an integer'; Value = @{ n = 42 }; Expected = "{`n  `"n`": 42`n}" }
            @{ Label = 'a quote and a backslash'; Value = @{ s = 'a"b\c' }; Expected = "{`n  `"s`": `"a\`"b\\c`"`n}" }
            @{ Label = 'control characters'; Value = @{ s = "`t`n`r`b`f" + [char]1 }; Expected = "{`n  `"s`": `"\t\n\r\b\f\u0001`"`n}" }
            @{ Label = 'a non-ASCII character'; Value = @{ s = [string][char]0x00E9 }; Expected = ("{`n  `"s`": `"" + [char]92 + "u00e9`"`n}") }
            @{ Label = 'an astral character as two escapes'; Value = @{ s = [char]::ConvertFromUtf32(0x1F600) }; Expected = ("{`n  `"s`": `"" + [char]92 + "ud83d" + [char]92 + "ude00`"`n}") }
            @{
                Label    = 'ordinal key order'
                # Hashtable literals are case-insensitive, so case-distinct keys
                # need an ordinal dictionary.
                Value    = & {
                    $ordinal = [System.Collections.Hashtable]::new([System.StringComparer]::Ordinal)
                    $ordinal['b'] = 1
                    $ordinal['a'] = 2
                    $ordinal['B'] = 3
                    , $ordinal
                }
                Expected = "{`n  `"B`": 3,`n  `"a`": 2,`n  `"b`": 1`n}"
            }
            @{ Label = 'an empty object'; Value = @{ o = @{} }; Expected = "{`n  `"o`": {}`n}" }
        ) {
            ConvertTo-CodexRoutingJson -InputObject $Value | Should -BeExactly $Expected
        }

        It 'rejects an unsupported value type' {
            { ConvertTo-CodexRoutingJson -InputObject @{ d = 1.5 } } | Should -Throw -ExpectedMessage '*unsupported*'
        }

        It 'builds a CLI result with the three stream fields' {
            $result = New-CodexRoutingCliResult -ExitCode 3 -Stdout 'out' -Stderr 'err'

            $result.ExitCode | Should -Be 3
            $result.Stdout | Should -Be 'out'
            $result.Stderr | Should -Be 'err'
        }
    }
}
