#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsAnalyzerDotnetConfig.psm1 (dotnet-config).

.DESCRIPTION
    In-memory appsettings.json and appsettings.Development.json with comments and trailing
    commas yield one config-key per member path with bare and quoted segments and [] array
    segments, value_type, configuration_path and environment; every configuration value is a
    distinctive string absent from the canonical JSON output; each element's source_sha256 is
    1020's declaration-lines digest of the raw key line; JSON_INVALID, DUPLICATE_DECLARATION and
    INPUT_KEY_LIMIT are emitted as specified. No file is written and no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.ScannerTestSupport.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerDotnetConfig.psm1') -Force -ErrorAction Stop

    function Get-TestElement {
        param([object[]] $Element, [string] $Declaration, [string] $Path)
        $found = @($Element | Where-Object { [string] $_['declaration'] -ceq $Declaration -and ([string]::IsNullOrEmpty($Path) -or [string] $_['path'] -ceq $Path) })
        $found.Count | Should -Be 1 -Because "exactly one element '$Declaration' is expected"
        $found[0]
    }

    function Get-TestProperty {
        param([System.Collections.IDictionary] $Element, [string] $Name)
        $found = @($Element['properties'] | Where-Object { [string] $_['name'] -ceq $Name })
        if ($found.Count -eq 0) { return $null }
        $found[0]['value']
    }

    function Get-TestDiagnostic {
        param([object[]] $Diagnostic, [string] $Code)
        $found = @($Diagnostic | Where-Object { [string] $_['code'] -ceq $Code })
        $found.Count | Should -Be 1 -Because "exactly one '$Code' diagnostic is expected"
        $found[0]
    }

    $script:SettingsText = @'
{
  // line comment
  "Logging": {
    "LogLevel": {
      "Default": "VALUE_ONE_x9q",
      "Microsoft.AspNetCore": "VALUE_TWO_x9q", /* trailing block */
    },
  },
  "ConnectionStrings": { "Main": "VALUE_THREE_x9q" },
  "Retry Count": 41,
  "quo\"ted\\key": true,
  "Nested": null,
  "Items": [
    { "Name": "VALUE_FOUR_x9q", "Size": 1.5 },
    { "Name": "VALUE_FIVE_x9q", "Extra": false, },
    "VALUE_SIX_x9q",
  ],
  "Matrix": [[{ "Cell": "VALUE_SEVEN_x9q" }]],
  "Empty": {},
}
'@

    $script:DevelopmentText = @'
{
  "Logging": { "LogLevel": { "Default": "VALUE_EIGHT_x9q" } },
  "Feature": { "Enabled": true }
}
'@
}

AfterAll {
    Remove-Module -Name DocsAnalyzerDotnetConfig, DocsScannerCommon, Docs.ScannerTestSupport, DocsAnalyzerRegistry, DocsSurface, DocsJson, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsAnalyzerDotnetConfig' {
    Context 'keys, shapes and environments' {
        BeforeAll {
            $script:Settings = New-DocsTestCapturedInput -Path 'src/App/appsettings.json' -Text $script:SettingsText
            $script:Development = New-DocsTestCapturedInput -Path 'src/App/appsettings.Development.json' -Text $script:DevelopmentText
            $script:Output = Invoke-DocsAnalyzerDotnetConfig -CapturedInput @($script:Development, $script:Settings) -Selection $null
            $script:Element = @($script:Output['Elements'])
            $script:SettingsElement = @($script:Element | Where-Object { [string] $_['path'] -ceq 'src/App/appsettings.json' })
        }

        It 'emits one config-key per member path with bare, quoted and [] segments and the value shapes' {
            [string[]] $declarations = @($script:SettingsElement | ForEach-Object { [string] $_['declaration'] })
            [Array]::Sort($declarations, [System.StringComparer]::Ordinal)
            $declarations | Should -Be @('"Retry Count"', '"quo\"ted\\key"', 'ConnectionStrings', 'ConnectionStrings.Main', 'Empty', 'Items', 'Items.[].Extra', 'Items.[].Name', 'Items.[].Size', 'Logging', 'Logging.LogLevel', 'Logging.LogLevel."Microsoft.AspNetCore"', 'Logging.LogLevel.Default', 'Matrix', 'Matrix.[].[].Cell', 'Nested')
            $default = Get-TestElement -Element $script:SettingsElement -Declaration 'Logging.LogLevel.Default'
            $default['kind'] | Should -Be 'config-key'
            $default['name'] | Should -Be 'Default'
            $default['analyzer_id'] | Should -Be 'dotnet-config'
            $default['analysis_method'] | Should -Be 'scanner'
            Get-TestProperty -Element $default -Name 'value_type' | Should -Be 'string'
            Get-TestProperty -Element $default -Name 'configuration_path' | Should -Be 'Logging:LogLevel:Default'
            Get-TestProperty -Element $default -Name 'environment' | Should -BeNullOrEmpty
            $default['line_range']['start'] | Should -Be 5
            $default['line_range']['end'] | Should -Be 5
            Get-TestProperty -Element (Get-TestElement -Element $script:SettingsElement -Declaration 'Logging') -Name 'value_type' | Should -Be 'object'
            Get-TestProperty -Element (Get-TestElement -Element $script:SettingsElement -Declaration 'Items') -Name 'value_type' | Should -Be 'array'
            Get-TestProperty -Element (Get-TestElement -Element $script:SettingsElement -Declaration '"Retry Count"') -Name 'value_type' | Should -Be 'number'
            Get-TestProperty -Element (Get-TestElement -Element $script:SettingsElement -Declaration '"quo\"ted\\key"') -Name 'value_type' | Should -Be 'boolean'
            Get-TestProperty -Element (Get-TestElement -Element $script:SettingsElement -Declaration 'Nested') -Name 'value_type' | Should -Be 'null'
            (Get-TestElement -Element $script:SettingsElement -Declaration '"quo\"ted\\key"')['name'] | Should -Be 'quo"ted\key'
            $dotted = Get-TestElement -Element $script:SettingsElement -Declaration 'Logging.LogLevel."Microsoft.AspNetCore"'
            $dotted['name'] | Should -Be 'Microsoft.AspNetCore'
            Get-TestProperty -Element $dotted -Name 'configuration_path' | Should -Be 'Logging:LogLevel:Microsoft.AspNetCore'
            $dotted['line_range']['start'] | Should -Be 6
        }

        It 'unions keys of objects inside arrays under [] keeping the first site and the environment segment' {
            $name = Get-TestElement -Element $script:SettingsElement -Declaration 'Items.[].Name'
            $name['line_range']['start'] | Should -Be 14
            Get-TestProperty -Element $name -Name 'configuration_path' | Should -Be 'Items:[]:Name'
            (Get-TestElement -Element $script:SettingsElement -Declaration 'Items.[].Extra')['line_range']['start'] | Should -Be 15
            Get-TestProperty -Element (Get-TestElement -Element $script:SettingsElement -Declaration 'Items.[].Size') -Name 'value_type' | Should -Be 'number'
            (Get-TestElement -Element $script:SettingsElement -Declaration 'Matrix.[].[].Cell')['name'] | Should -Be 'Cell'
            $development = Get-TestElement -Element $script:Element -Declaration 'Logging.LogLevel.Default' -Path 'src/App/appsettings.Development.json'
            Get-TestProperty -Element $development -Name 'environment' | Should -Be 'Development'
            $development['line_range']['start'] | Should -Be 2
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Feature.Enabled') -Name 'value_type' | Should -Be 'boolean'
            @($script:Element | Where-Object { [string] $_['path'] -ceq 'src/App/appsettings.Development.json' }).Count | Should -Be 5
            $script:Output['Diagnostics'].Count | Should -Be 0
        }

        It 'emits no configuration value and digests the raw key line through 1020' {
            $canonical = ConvertTo-DocsTestOutputText -Output $script:Output
            foreach ($value in @('VALUE_ONE_x9q', 'VALUE_TWO_x9q', 'VALUE_THREE_x9q', 'VALUE_FOUR_x9q', 'VALUE_FIVE_x9q', 'VALUE_SIX_x9q', 'VALUE_SEVEN_x9q', 'VALUE_EIGHT_x9q')) {
                $canonical.Contains($value) | Should -BeFalse -Because "the value '$value' must not appear in the output"
            }
            foreach ($element in $script:Element) {
                $text = if ([string] $element['path'] -ceq 'src/App/appsettings.json') { $script:SettingsText } else { $script:DevelopmentText }
                $line = [int] $element['line_range']['start']
                $element['line_range']['end'] | Should -Be $line
                $element['source_sha256'] | Should -Be (Get-DocsDeclarationSha256 -Text $text -LineRange @($line, $line))
                { ConvertFrom-DocsSurfaceElement -Record $element } | Should -Not -Throw
            }
            [string[]] $ids = @($script:Element | ForEach-Object { [string] $_['element_id'] })
            [string[]] $sortedIds = [string[]] $ids.Clone()
            [Array]::Sort($sortedIds, [System.StringComparer]::Ordinal)
            $ids | Should -Be $sortedIds
        }
    }

    Context 'validity gate, duplicates and bounds' {
        It 'reports invalid JSON, an empty file, a non-object root and excessive depth as blocking JSON_INVALID with no element' {
            $deep = ('{"a":' * 70) + '1' + ('}' * 70)
            $inputs = @(
                (New-DocsTestCapturedInput -Path 'a/appsettings.json' -Text '{ "a": '),
                (New-DocsTestCapturedInput -Path 'b/appsettings.json' -Text ''),
                (New-DocsTestCapturedInput -Path 'c/appsettings.json' -Text '   '),
                (New-DocsTestCapturedInput -Path 'd/appsettings.json' -Text '[1, 2]'),
                (New-DocsTestCapturedInput -Path 'e/appsettings.json' -Text $deep),
                (New-DocsTestCapturedInput -Path 'f/appsettings.json' -Text "{`n  `"ok`": 1,`n  `"bad`": }")
            )
            $output = Invoke-DocsAnalyzerDotnetConfig -CapturedInput $inputs -Selection $null
            $output['Elements'].Count | Should -Be 0
            $invalid = @($output['Diagnostics'] | Where-Object { [string] $_['code'] -ceq 'JSON_INVALID' })
            @($invalid | ForEach-Object { $_['path'] } | Sort-Object { $_ }) | Should -Be @('a/appsettings.json', 'b/appsettings.json', 'c/appsettings.json', 'd/appsettings.json', 'e/appsettings.json', 'f/appsettings.json')
            foreach ($diagnostic in $invalid) {
                $diagnostic['blocking'] | Should -BeTrue
                $diagnostic['extensions'].Contains('docs.precision-limit') | Should -BeFalse
            }
            @($invalid | Where-Object { [string] $_['path'] -ceq 'f/appsettings.json' })[0]['message'] | Should -Match 'line 3'
            $output['Diagnostics'].Count | Should -Be 6
            (Invoke-DocsAnalyzerDotnetConfig -CapturedInput @(New-DocsTestCapturedInput -Path 'g/appsettings.json' -Text $deep) -Selection $null -MaxDepth 80)['Elements'].Count | Should -Be 70
        }

        It 'reports a duplicate member at one path as DUPLICATE_DECLARATION and keeps the first line' {
            $text = "{`n  `"A`": { `"x`": 1 },`n  `"B`": 2,`n  `"A`": { `"y`": 3 }`n}"
            $output = Invoke-DocsAnalyzerDotnetConfig -CapturedInput @(New-DocsTestCapturedInput -Path 'appsettings.json' -Text $text) -Selection $null
            $a = Get-TestElement -Element @($output['Elements']) -Declaration 'A'
            $a['line_range']['start'] | Should -Be 2
            @($output['Elements'] | ForEach-Object { $_['declaration'] } | Sort-Object { $_ }) | Should -Be @('A', 'A.x', 'A.y', 'B')
            $duplicate = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'DUPLICATE_DECLARATION'
            $duplicate['message'] | Should -Match '1 occurrence'
            $duplicate['message'] | Should -Match 'line 4'
            $duplicate['blocking'] | Should -BeFalse
            $output['Diagnostics'].Count | Should -Be 1
        }

        It 'reports INPUT_KEY_LIMIT above the key bound with no element from the file' {
            $text = '{ "a": 1, "b": { "c": 2 }, "d": 3 }'
            $output = Invoke-DocsAnalyzerDotnetConfig -CapturedInput @((New-DocsTestCapturedInput -Path 'x/appsettings.json' -Text $text), (New-DocsTestCapturedInput -Path 'y/appsettings.json' -Text '{ "one": 1 }')) -Selection $null -MaxKey 3
            @($output['Elements'] | ForEach-Object { $_['path'] } | Sort-Object { $_ } -Unique) | Should -Be @('y/appsettings.json')
            $limit = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'INPUT_KEY_LIMIT'
            $limit['path'] | Should -Be 'x/appsettings.json'
            $limit['blocking'] | Should -BeTrue
            (Invoke-DocsAnalyzerDotnetConfig -CapturedInput @(New-DocsTestCapturedInput -Path 'x/appsettings.json' -Text $text) -Selection $null -MaxKey 4)['Elements'].Count | Should -Be 4
        }

        It 'selects only appsettings basenames, ignores other JSON, and handles empty sets, BOM and CRLF inputs' {
            $inputs = @(
                (New-DocsTestCapturedInput -Path 'cfg/appsettings.Production.json' -Text "{`"K`": `"v`"}" -LineEnding 'CRLF' -Bom),
                (New-DocsTestCapturedInput -Path 'cfg/APPSETTINGS.JSON' -Text '{"U": 1}'),
                (New-DocsTestCapturedInput -Path 'cfg/settings.json' -Text '{"Other": 1}'),
                (New-DocsTestCapturedInput -Path 'cfg/appsettings.json.bak' -Text '{"Bak": 1}'),
                (New-DocsTestCapturedInput -Path 'cfg/myappsettings.json' -Text '{"My": 1}')
            )
            $output = Invoke-DocsAnalyzerDotnetConfig -CapturedInput $inputs -Selection @{ source_roots = @('cfg') }
            @($output['Elements'] | ForEach-Object { $_['declaration'] } | Sort-Object { $_ }) | Should -Be @('K', 'U')
            Get-TestProperty -Element (Get-TestElement -Element @($output['Elements']) -Declaration 'K') -Name 'environment' | Should -Be 'Production'
            $output['Diagnostics'].Count | Should -Be 0
            $empty = Invoke-DocsAnalyzerDotnetConfig -CapturedInput @() -Selection $null
            $empty['Elements'].Count | Should -Be 0
            $empty['Diagnostics'].Count | Should -Be 0
        }

        It 'reports oversize and undecodable inputs as blocking and keeps other files' {
            $output = Invoke-DocsAnalyzerDotnetConfig -CapturedInput @((New-DocsTestOversizeInput -Path 'big/appsettings.json'), (New-DocsTestUndecodableInput -Path 'bad/appsettings.json'), (New-DocsTestCapturedInput -Path 'ok/appsettings.json' -Text '{"Fine": 1}')) -Selection $null
            @($output['Elements'] | ForEach-Object { $_['declaration'] }) | Should -Be @('Fine')
            (Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'INPUT_OVER_BOUND')['blocking'] | Should -BeTrue
            (Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'INPUT_UNDECODABLE')['path'] | Should -Be 'bad/appsettings.json'
            $output['Diagnostics'].Count | Should -Be 2
        }

        It 'throws for a null captured-input list' {
            { Invoke-DocsAnalyzerDotnetConfig -CapturedInput $null -Selection $null } | Should -Throw
        }
    }
}
