#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsAnalyzerTypeScriptCli.psm1 (typescript-cli).

.DESCRIPTION
    In-memory Commander and yargs fixtures yield the expected cli-command and cli-option
    elements (declaration, name, parent_id, properties and line_range), the root name sources,
    and the CLI_DYNAMIC_REGISTRATION, CLI_UNBOUND_REGISTRATION and
    CLI_COMMAND_MODULE_UNRESOLVED precision-limit diagnostics, plus the input selection, the
    captured-input and lexical blocking diagnostics and the duplicate rule. No file is written
    and no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.ScannerTestSupport.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerTypeScriptCli.psm1') -Force -ErrorAction Stop

    function Get-TestElement {
        param([object[]] $Element, [string] $Declaration)
        $found = @($Element | Where-Object { [string] $_['declaration'] -ceq $Declaration })
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

    $script:CommanderText = @'
import { Command, Option } from 'commander';

const program = new Command('tool');
program
  .command('serve <dir> [port]')
  .description('serve files')
  .option('-p, --port <n>', 'port')
  .requiredOption('--host <h>', 'host')
  .addOption(new Option('-v, --verbose', 'verbose'))
  .argument('<file>')
  .action(() => {});
program.command('list', 'list things');
const sub = program.command('db');
sub.option('--url <u>');
const migrate = new Command('migrate');
migrate.option('--dry-run');
sub.addCommand(migrate);
program.parse();
'@

    $script:YargsText = @'
import yargs from 'yargs';
import { hideBin } from 'yargs/helpers';
import { build } from './build';

yargs(hideBin(process.argv))
  .scriptName('tool')
  .option('verbose', { alias: 'v', demandOption: true })
  .command('serve [port]', 'start', (y) => y.option('host', { type: 'string' }).positional('port', { type: 'number' }), () => {})
  .command({ command: ['build <target>', 'b'], builder: { out: { type: 'string' }, k: {} } })
  .command(build)
  .command(require('./other'))
  .commandDir('cmds')
  .options({ q: {}, ['computed']: {} })
  .command(dynamicName, 'desc')
  .parse();
'@

    $script:ModuleRootText = @'
import { program } from 'commander';
import { other } from './other';
program.command('run');
for (const name of names) {
  program.command(name);
}
program.command(`dyn-${x}`);
program.command(...args);
program.addCommand(other);
cli.command('x');
'@
}

AfterAll {
    Remove-Module -Name DocsAnalyzerTypeScriptCli, DocsTypeScriptCliSupport, DocsTypeScriptSyntax, DocsTypeScriptTokens, DocsScannerCommon, Docs.ScannerTestSupport, DocsAnalyzerRegistry, DocsSurface, DocsJson, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsAnalyzerTypeScriptCli' {
    Context 'Commander' {
        BeforeAll {
            $script:CommanderOutput = Invoke-DocsAnalyzerTypeScriptCli -CapturedInput @(New-DocsTestCapturedInput -Path 'src/cli.ts' -Text $script:CommanderText) -Selection $null
            $script:CommanderElement = @($script:CommanderOutput['Elements'])
        }

        It 'emits the literal-named root, subcommands across a multi-line chain and the two-argument parent form' {
            # Assert
            [string[]] $ids = @($script:CommanderElement | ForEach-Object { [string] $_['element_id'] })
            [string[]] $sortedIds = [string[]] $ids.Clone()
            [Array]::Sort($sortedIds, [System.StringComparer]::Ordinal)
            $ids | Should -Be $sortedIds
            $root = Get-TestElement -Element $script:CommanderElement -Declaration 'tool'
            $root['kind'] | Should -Be 'cli-command'
            $root['name'] | Should -Be 'tool'
            $root['parent_id'] | Should -BeNullOrEmpty
            Get-TestProperty -Element $root -Name 'name_source' | Should -Be 'literal'
            $root['line_range']['start'] | Should -Be 3
            $root['line_range']['end'] | Should -Be 3
            $root['analysis_method'] | Should -Be 'scanner'
            $root['analyzer_id'] | Should -Be 'typescript-cli'
            $serve = Get-TestElement -Element $script:CommanderElement -Declaration 'tool serve'
            $serve['name'] | Should -Be 'serve'
            $serve['parent_id'] | Should -Be $root['element_id']
            $serve['line_range']['start'] | Should -Be 4
            $serve['line_range']['end'] | Should -Be 5
            (Get-TestElement -Element $script:CommanderElement -Declaration 'tool list')['parent_id'] | Should -Be $root['element_id']
            $script:CommanderOutput['Diagnostics'].Count | Should -Be 0
        }

        It 'emits positional, short, required, inline Option and argument options parented to the subcommand' {
            $serve = Get-TestElement -Element $script:CommanderElement -Declaration 'tool serve'
            $dir = Get-TestElement -Element $script:CommanderElement -Declaration 'tool serve dir'
            $dir['kind'] | Should -Be 'cli-option'
            $dir['name'] | Should -Be 'dir'
            $dir['parent_id'] | Should -Be $serve['element_id']
            Get-TestProperty -Element $dir -Name 'positional' | Should -BeTrue
            (Get-TestElement -Element $script:CommanderElement -Declaration 'tool serve port')['line_range']['end'] | Should -Be 5
            $port = Get-TestElement -Element $script:CommanderElement -Declaration 'tool serve --port'
            $port['name'] | Should -Be '--port'
            Get-TestProperty -Element $port -Name 'short' | Should -Be '-p'
            Get-TestProperty -Element $port -Name 'required' | Should -BeNullOrEmpty
            $port['line_range']['start'] | Should -Be 4
            $port['line_range']['end'] | Should -Be 7
            $hostOption = Get-TestElement -Element $script:CommanderElement -Declaration 'tool serve --host'
            Get-TestProperty -Element $hostOption -Name 'required' | Should -BeTrue
            @($hostOption['properties'] | Where-Object { [string] $_['name'] -ceq 'short' }).Count | Should -Be 0
            $hostOption['line_range']['end'] | Should -Be 8
            $verbose = Get-TestElement -Element $script:CommanderElement -Declaration 'tool serve --verbose'
            Get-TestProperty -Element $verbose -Name 'short' | Should -Be '-v'
            $file = Get-TestElement -Element $script:CommanderElement -Declaration 'tool serve file'
            Get-TestProperty -Element $file -Name 'positional' | Should -BeTrue
            $file['line_range']['end'] | Should -Be 10
        }

        It 'tracks an assigned subcommand variable and parents an added command under it' {
            $db = Get-TestElement -Element $script:CommanderElement -Declaration 'tool db'
            $db['line_range']['start'] | Should -Be 13
            (Get-TestElement -Element $script:CommanderElement -Declaration 'tool db --url')['parent_id'] | Should -Be $db['element_id']
            $migrate = Get-TestElement -Element $script:CommanderElement -Declaration 'tool db migrate'
            $migrate['parent_id'] | Should -Be $db['element_id']
            $migrate['line_range']['start'] | Should -Be 15
            Get-TestProperty -Element $migrate -Name 'name_source' | Should -BeNullOrEmpty
            (Get-TestElement -Element $script:CommanderElement -Declaration 'tool db migrate --dry-run')['name'] | Should -Be '--dry-run'
            $script:CommanderElement.Count | Should -Be 13
        }

        It 'uses the module path as the root name and reports dynamic and unbound registrations' {
            # Arrange
            $captured = New-DocsTestCapturedInput -Path 'src/cli/main.ts' -Text $script:ModuleRootText

            # Act
            $output = Invoke-DocsAnalyzerTypeScriptCli -CapturedInput @($captured) -Selection @{ source_roots = @('src') }

            # Assert
            @($output['Elements'] | ForEach-Object { $_['declaration'] } | Sort-Object { $_ }) | Should -Be @('cli/main', 'cli/main run')
            $root = Get-TestElement -Element @($output['Elements']) -Declaration 'cli/main'
            Get-TestProperty -Element $root -Name 'name_source' | Should -Be 'module'
            $dynamic = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'CLI_DYNAMIC_REGISTRATION'
            $dynamic['message'] | Should -Match '3 occurrence'
            $dynamic['message'] | Should -Match 'line 5'
            $dynamic['severity'] | Should -Be 'warning'
            $dynamic['blocking'] | Should -BeFalse
            $dynamic['path'] | Should -Be 'src/cli/main.ts'
            $dynamic['extensions']['docs.precision-limit']['element_kind'] | Should -Be 'cli-command'
            $unbound = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'CLI_UNBOUND_REGISTRATION'
            $unbound['message'] | Should -Match '2 occurrence'
            $unbound['message'] | Should -Match 'line 9'
            $output['Diagnostics'].Count | Should -Be 2
            $withoutRoots = Invoke-DocsAnalyzerTypeScriptCli -CapturedInput @($captured) -Selection $null
            @($withoutRoots['Elements'] | ForEach-Object { $_['declaration'] } | Sort-Object { $_ }) | Should -Be @('src/cli/main', 'src/cli/main run')
        }
    }

    Context 'yargs' {
        BeforeAll {
            $script:YargsOutput = Invoke-DocsAnalyzerTypeScriptCli -CapturedInput @(New-DocsTestCapturedInput -Path 'bin/tool.ts' -Text $script:YargsText) -Selection $null
            $script:YargsElement = @($script:YargsOutput['Elements'])
        }

        It 'emits the scriptName root, root options and the string-form command with its builder function' {
            $root = Get-TestElement -Element $script:YargsElement -Declaration 'tool'
            Get-TestProperty -Element $root -Name 'name_source' | Should -Be 'literal'
            $root['line_range']['start'] | Should -Be 5
            $root['line_range']['end'] | Should -Be 5
            $verbose = Get-TestElement -Element $script:YargsElement -Declaration 'tool --verbose'
            $verbose['parent_id'] | Should -Be $root['element_id']
            Get-TestProperty -Element $verbose -Name 'short' | Should -Be '-v'
            Get-TestProperty -Element $verbose -Name 'required' | Should -BeTrue
            $verbose['line_range']['end'] | Should -Be 7
            $serve = Get-TestElement -Element $script:YargsElement -Declaration 'tool serve'
            $serve['parent_id'] | Should -Be $root['element_id']
            $serve['line_range']['end'] | Should -Be 8
            Get-TestProperty -Element (Get-TestElement -Element $script:YargsElement -Declaration 'tool serve port') -Name 'positional' | Should -BeTrue
            (Get-TestElement -Element $script:YargsElement -Declaration 'tool serve --host')['parent_id'] | Should -Be $serve['element_id']
        }

        It 'emits the object-form command with an object builder and the options key rules' {
            $build = Get-TestElement -Element $script:YargsElement -Declaration 'tool build'
            $build['line_range']['end'] | Should -Be 9
            Get-TestProperty -Element (Get-TestElement -Element $script:YargsElement -Declaration 'tool build target') -Name 'positional' | Should -BeTrue
            (Get-TestElement -Element $script:YargsElement -Declaration 'tool build --out')['name'] | Should -Be '--out'
            (Get-TestElement -Element $script:YargsElement -Declaration 'tool build -k')['parent_id'] | Should -Be $build['element_id']
            (Get-TestElement -Element $script:YargsElement -Declaration 'tool -q')['line_range']['end'] | Should -Be 13
            $script:YargsElement.Count | Should -Be 10
        }

        It 'reports module-loaded commands and dynamic names and keys' {
            $unresolved = Get-TestDiagnostic -Diagnostic @($script:YargsOutput['Diagnostics']) -Code 'CLI_COMMAND_MODULE_UNRESOLVED'
            $unresolved['message'] | Should -Match '3 occurrence'
            $unresolved['message'] | Should -Match 'line 10'
            $unresolved['extensions']['docs.precision-limit']['element_kind'] | Should -Be 'cli-command'
            $dynamic = Get-TestDiagnostic -Diagnostic @($script:YargsOutput['Diagnostics']) -Code 'CLI_DYNAMIC_REGISTRATION'
            $dynamic['message'] | Should -Match '2 occurrence'
            $dynamic['message'] | Should -Match 'line 13'
            $script:YargsOutput['Diagnostics'].Count | Should -Be 2
        }
    }

    Context 'selection, bounds and duplicates' {
        It 'selects .ts, .mts and .cts and skips declaration files, .tsx and files without a CLI import' {
            $inputs = @(
                (New-DocsTestCapturedInput -Path 'a.mts' -Text "import { program } from 'commander';`nprogram.command('m');"),
                (New-DocsTestCapturedInput -Path 'b.cts' -Text "import { program } from 'commander';`nprogram.command('c');"),
                (New-DocsTestCapturedInput -Path 'c.d.ts' -Text "import { program } from 'commander';`nprogram.command('d');"),
                (New-DocsTestCapturedInput -Path 'd.tsx' -Text "import { program } from 'commander';`nprogram.command('t');"),
                (New-DocsTestCapturedInput -Path 'e.ts' -Text "const x = 1;`nprogram.command('e');")
            )
            $output = Invoke-DocsAnalyzerTypeScriptCli -CapturedInput $inputs -Selection $null
            @($output['Elements'] | ForEach-Object { $_['declaration'] } | Sort-Object { $_ }) | Should -Be @('a', 'a m', 'b', 'b c')
            $output['Diagnostics'].Count | Should -Be 0
        }

        It 'returns no element and no diagnostic for an empty input set and an empty file' {
            $empty = Invoke-DocsAnalyzerTypeScriptCli -CapturedInput @() -Selection $null
            $empty['Elements'].Count | Should -Be 0
            $empty['Diagnostics'].Count | Should -Be 0
            $blank = Invoke-DocsAnalyzerTypeScriptCli -CapturedInput @(New-DocsTestCapturedInput -Path 'x.ts' -Text '') -Selection $null
            $blank['Elements'].Count | Should -Be 0
            $blank['Diagnostics'].Count | Should -Be 0
        }

        It 'reports oversize, undecodable and lexically invalid inputs as blocking and keeps other files' {
            $inputs = @(
                (New-DocsTestOversizeInput -Path 'big.ts'),
                (New-DocsTestUndecodableInput -Path 'bad.ts'),
                (New-DocsTestCapturedInput -Path 'lex.ts' -Text "import { program } from 'commander';`nprogram.command('x'); const s = 'unterminated"),
                (New-DocsTestCapturedInput -Path 'ok.ts' -Text "import { program } from 'commander';`nprogram.command('fine');")
            )
            $output = Invoke-DocsAnalyzerTypeScriptCli -CapturedInput $inputs -Selection $null
            @($output['Elements'] | ForEach-Object { $_['path'] } | Sort-Object { $_ } -Unique) | Should -Be @('ok.ts')
            foreach ($code in @('INPUT_OVER_BOUND', 'INPUT_UNDECODABLE', 'TS_LEXICAL_INVALID')) {
                $diagnostic = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code $code
                $diagnostic['blocking'] | Should -BeTrue
                $diagnostic['extensions'].Contains('docs.precision-limit') | Should -BeFalse
            }
            (Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'INPUT_OVER_BOUND')['path'] | Should -Be 'big.ts'
            (Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'TS_LEXICAL_INVALID')['path'] | Should -Be 'lex.ts'
            $output['Diagnostics'].Count | Should -Be 3
        }

        It 'keeps the first of two identical declarations and reports DUPLICATE_DECLARATION without the marker' {
            $text = "import { program } from 'commander';`nprogram.command('x');`nprogram.command('x');"
            $output = Invoke-DocsAnalyzerTypeScriptCli -CapturedInput @(New-DocsTestCapturedInput -Path 'dup.ts' -Text $text) -Selection $null
            $x = Get-TestElement -Element @($output['Elements']) -Declaration 'dup x'
            $x['line_range']['start'] | Should -Be 2
            $duplicate = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'DUPLICATE_DECLARATION'
            $duplicate['blocking'] | Should -BeFalse
            $duplicate['message'] | Should -Match 'line 3'
            $duplicate['extensions'].Contains('docs.precision-limit') | Should -BeFalse
        }

        It 'throws for a null captured-input list' {
            { Invoke-DocsAnalyzerTypeScriptCli -CapturedInput $null -Selection $null } | Should -Throw
        }
    }
}
