#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Cross-analyzer contract tests for the seven 1033 analyzers (determinism, bounds, precision
    limit, element contract).

.DESCRIPTION
    Every analyzer runs over in-memory fixtures that exercise its precision-limit rows. Two runs
    over identical inputs and three seeded shuffled input orders give byte-identical canonical
    JSON; oversize, undecodable, lexically invalid and empty inputs yield the specified blocking
    diagnostics and leave other files' elements intact; every precision-limit row is emitted
    with the docs.precision-limit marker and no other code carries it; every built-in element
    records analysis_method scanner and the 1020 declaration-lines digest, and passes
    Invoke-DocsAnalyzer through the -ImportModule seam. No file is written and no process is
    started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    $script:DocsRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $script:LibraryRoot -ChildPath 'docs'))
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.ScannerTestSupport.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:DocsRoot -ChildPath 'DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:DocsRoot -ChildPath 'DocsScannerCommon.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:DocsRoot -ChildPath 'DocsAnalyzerRegistry.psm1') -Force -ErrorAction Stop
    foreach ($leaf in 'DocsAnalyzerTypeScriptCli', 'DocsAnalyzerTypeScriptHttp', 'DocsAnalyzerTypeScriptExports', 'DocsAnalyzerDotnetHttp', 'DocsAnalyzerDotnetConfig', 'DocsAnalyzerDotnetApi', 'DocsAnalyzerExtensionImport') {
        Import-Module -Name (Join-Path -Path $script:DocsRoot -ChildPath ($leaf + '.psm1')) -Force -ErrorAction Stop
    }

    $script:Row = @{
        'typescript-cli'     = @{ Leaf = 'DocsAnalyzerTypeScriptCli.psm1'; Function = 'Invoke-DocsAnalyzerTypeScriptCli'; Kinds = @('cli-command', 'cli-option') }
        'typescript-http'    = @{ Leaf = 'DocsAnalyzerTypeScriptHttp.psm1'; Function = 'Invoke-DocsAnalyzerTypeScriptHttp'; Kinds = @('http-route') }
        'typescript-exports' = @{ Leaf = 'DocsAnalyzerTypeScriptExports.psm1'; Function = 'Invoke-DocsAnalyzerTypeScriptExports'; Kinds = @('public-symbol') }
        'dotnet-http'        = @{ Leaf = 'DocsAnalyzerDotnetHttp.psm1'; Function = 'Invoke-DocsAnalyzerDotnetHttp'; Kinds = @('http-route') }
        'dotnet-config'      = @{ Leaf = 'DocsAnalyzerDotnetConfig.psm1'; Function = 'Invoke-DocsAnalyzerDotnetConfig'; Kinds = @('config-key') }
        'dotnet-public-api'  = @{ Leaf = 'DocsAnalyzerDotnetApi.psm1'; Function = 'Invoke-DocsAnalyzerDotnetApi'; Kinds = @('public-symbol') }
        'extension-import'   = @{ Leaf = 'DocsAnalyzerExtensionImport.psm1'; Function = 'Invoke-DocsAnalyzerExtensionImport'; Kinds = @('cli-command', 'cli-option', 'http-route', 'config-key', 'public-symbol', 'architecture-component') }
    }
    $script:BuiltIn = @('typescript-cli', 'typescript-http', 'typescript-exports', 'dotnet-http', 'dotnet-config', 'dotnet-public-api')
    $script:NotPrecision = @('INPUT_OVER_BOUND', 'INPUT_UNDECODABLE', 'TS_LEXICAL_INVALID', 'CSHARP_LEXICAL_INVALID', 'TOKEN_LIMIT', 'JSON_INVALID', 'INPUT_KEY_LIMIT', 'DECLARATION_INVALID', 'DUPLICATE_DECLARATION', 'EXTENSION_FINDING_SKIPPED', 'EXTENSION_REPOSITORY_UNVERIFIED', 'EXTENSION_REVISION_UNVERIFIED', 'EXTENSION_MANIFEST_INVALID', 'EXTENSION_MANIFEST_DIGEST_MISMATCH', 'EXTENSION_REPOSITORY_MISMATCH', 'EXTENSION_ADAPTER_INVALID', 'EXTENSION_INPUT_NOT_CAPTURED', 'EXTENSION_INPUT_DIGEST_MISMATCH', 'EXTENSION_RESULT_DIGEST_MISMATCH', 'EXTENSION_RESULT_INVALID', 'EXTENSION_FINDING_SOURCE_MISMATCH')

    function Invoke-TestAnalyzer {
        # Dispatches to the analyzer function by registered identifier (static names only).
        param([string] $Id, [AllowEmptyCollection()] [object[]] $CapturedInput, [AllowNull()] [object] $Selection)
        switch ($Id) {
            'typescript-cli' { Invoke-DocsAnalyzerTypeScriptCli -CapturedInput $CapturedInput -Selection $Selection }
            'typescript-http' { Invoke-DocsAnalyzerTypeScriptHttp -CapturedInput $CapturedInput -Selection $Selection }
            'typescript-exports' { Invoke-DocsAnalyzerTypeScriptExports -CapturedInput $CapturedInput -Selection $Selection }
            'dotnet-http' { Invoke-DocsAnalyzerDotnetHttp -CapturedInput $CapturedInput -Selection $Selection }
            'dotnet-config' { Invoke-DocsAnalyzerDotnetConfig -CapturedInput $CapturedInput -Selection $Selection }
            'dotnet-public-api' { Invoke-DocsAnalyzerDotnetApi -CapturedInput $CapturedInput -Selection $Selection }
            'extension-import' { Invoke-DocsAnalyzerExtensionImport -CapturedInput $CapturedInput -Selection $Selection }
            default { throw "unknown analyzer $Id" }
        }
    }

    $script:CliMainText = @'
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
    $script:CliYargsText = @'
import yargs from 'yargs';
import { build } from './build';

yargs(process.argv)
  .scriptName('tool')
  .option('verbose', { alias: 'v' })
  .command('serve [port]', 'start')
  .command(build)
  .command(require('./other'))
  .commandDir('cmds')
  .parse();
'@
    $script:HttpAppText = @'
import express, { Router } from 'express';
import itemsRouter from './routes/items';

const app = express();
app.get('/', home);
app.use('/items', itemsRouter);
app.use('/missing', unknownRouter);
app.use(dynamicPrefix, itemsRouter);
app.get(computedPath, h);
app.get(/^\/regex/, h);
'@
    $script:HttpItemsText = @'
import { Router } from 'express';
const router = Router();
router.get('/:id', getItem);
export default router;
'@
    $script:ExportsText = @'
export function plain(a: string): void;
export function plain(a: number): void;
export function plain(a: any) {
  return a;
}
export const { e = 1, ...rest } = obj;
export * from 'some-package';
export = Widget;
declare module 'ambient' {
  export const inside: number;
}
module.exports = plain;
'@
    $script:ControllerText = @'
using Microsoft.AspNetCore.Mvc;

namespace Demo.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class ItemsController : ControllerBase
    {
        [HttpGet]
        public IActionResult List() => Ok();

        [HttpDelete(Constants.DeletePath)]
        public IActionResult Remove() => Ok();
    }

    [Route("[area]/things")]
    public class ThingsController : Controller
    {
        [HttpGet]
        public IActionResult Index() => View();
    }

    public class LegacyController : BaseController
    {
        [HttpGet("legacy")]
        public IActionResult Get() => Ok();
    }
}
'@
    $script:MinimalText = @'
var app = builder.Build();
app.MapGet("/", () => "root");
var dyn = app.MapGroup(prefix);
dyn.MapGet("/d", D);
app.MapHub<ChatHub>("/chat");
app.MapControllerRoute(name: "default", pattern: "{controller=Home}/{action=Index}/{id?}");
app.Run();

public static class Extensions
{
    public static IEndpointRouteBuilder MapOrders(this IEndpointRouteBuilder routes)
    {
        routes.MapGet("/orders", ListOrders);
        return routes;
    }
}
'@
    $script:HttpConditionalText = "using X;`n#if DEBUG`npublic class AController : ControllerBase { [HttpGet(`"a`")] public IActionResult Get() => Ok(); }`n#else`npublic class AController : ControllerBase { [HttpGet(`"a`")] public IActionResult Get() => Ok(); }`n#endif"
    $script:ApiText = @'
namespace Outer
{
    public static class Util
    {
        public static int Twice(int x) => x * 2;
        public broken = 1;
    }
}
'@
    $script:ApiConditionalText = "namespace N;`npublic class C`n{`n#if DEBUG`n    public int A;`n#else`n    public int A;`n#endif`n}"
    $script:ConfigText = @'
{
  // comment
  "Logging": { "LogLevel": { "Default": "VALUE_x9q" } },
  "Items": [ { "Name": "VALUE2_x9q" } ],
}
'@
    $script:ExtensionSelection = @{ repository_id = 'example-repo'; revision = ('a' * 40); registered_analyzer_ids = @('typescript-cli') }

    function Get-TestFixture {
        # Returns @{ CapturedInput; Selection } for one analyzer: the fixture set that exercises its precision-limit rows.
        param([string] $Id)
        switch ($Id) {
            'typescript-cli' { return @{ CapturedInput = @((New-DocsTestCapturedInput -Path 'src/cli/main.ts' -Text $script:CliMainText), (New-DocsTestCapturedInput -Path 'bin/tool.ts' -Text $script:CliYargsText)); Selection = $null } }
            'typescript-http' { return @{ CapturedInput = @((New-DocsTestCapturedInput -Path 'src/app.ts' -Text $script:HttpAppText), (New-DocsTestCapturedInput -Path 'src/routes/items.ts' -Text $script:HttpItemsText)); Selection = $null } }
            'typescript-exports' { return @{ CapturedInput = @(New-DocsTestCapturedInput -Path 'src/lib/forms.ts' -Text $script:ExportsText); Selection = @{ source_roots = @('src') } } }
            'dotnet-http' { return @{ CapturedInput = @((New-DocsTestCapturedInput -Path 'src/Controllers.cs' -Text $script:ControllerText), (New-DocsTestCapturedInput -Path 'src/Program.cs' -Text $script:MinimalText), (New-DocsTestCapturedInput -Path 'src/Cond.cs' -Text $script:HttpConditionalText)); Selection = $null } }
            'dotnet-config' { return @{ CapturedInput = @((New-DocsTestCapturedInput -Path 'appsettings.json' -Text $script:ConfigText), (New-DocsTestCapturedInput -Path 'appsettings.Development.json' -Text '{ "Feature": { "Enabled": true } }')); Selection = $null } }
            'dotnet-public-api' { return @{ CapturedInput = @((New-DocsTestCapturedInput -Path 'src/Util.cs' -Text $script:ApiText), (New-DocsTestCapturedInput -Path 'src/Cond.cs' -Text $script:ApiConditionalText)); Selection = $null } }
            'extension-import' {
                $fixture = New-DocsTestExtensionManifest -Finding {
                    param($Source)
                    @(
                        (New-DocsTestFinding -FindingId 'finding-handle' -Kind 'public-symbol' -RepositoryId 'example-repo' -Revision ('a' * 40) -Path 'src/other/service.rb' -Sha256 $Source['sha256'] -AdapterId 'ruby-adapter' -AdapterVersion '1.2.3' -Symbol 'Service.handle' -LineRange @(2, 2)),
                        (New-DocsTestFinding -FindingId 'finding-thing' -Kind 'ruby-thing' -RepositoryId 'example-repo' -Revision ('a' * 40) -Path 'src/other/service.rb' -Sha256 $Source['sha256'] -AdapterId 'ruby-adapter' -AdapterVersion '1.2.3' -Symbol 'Thing' -LineRange @(1, 1))
                    )
                }
                return @{ CapturedInput = @($fixture['CapturedInput']); Selection = $script:ExtensionSelection }
            }
            default { throw "unknown analyzer $Id" }
        }
    }

    function Get-TestOutputText {
        param([string] $Id, [object[]] $CapturedInput, [AllowNull()] [object] $Selection)
        ConvertTo-DocsTestOutputText -Output (Invoke-TestAnalyzer -Id $Id -CapturedInput $CapturedInput -Selection $Selection)
    }
}

AfterAll {
    Remove-Module -Name DocsAnalyzerExtensionImport, DocsExtensionShape, DocsAnalyzerDotnetApi, DocsCSharpMember, DocsAnalyzerDotnetConfig, DocsAnalyzerDotnetHttp, DocsCSharpSyntax, DocsCSharpTokens, DocsAnalyzerTypeScriptExports, DocsAnalyzerTypeScriptHttp, DocsTypeScriptHttpSupport, DocsTypeScriptHttpDeclaration, DocsAnalyzerTypeScriptCli, DocsTypeScriptCliSupport, DocsTypeScriptSyntax, DocsTypeScriptTokens, DocsScannerCommon, Docs.ScannerTestSupport, DocsAnalyzerRegistry, DocsSurface, DocsJson, DocsFinding, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Scanner contract' {
    Context 'determinism' {
        It 'gives byte-identical output for <Id> over two identical runs and three seeded shuffled input orders' -ForEach @(
            @{ Id = 'typescript-cli' }
            @{ Id = 'typescript-http' }
            @{ Id = 'typescript-exports' }
            @{ Id = 'dotnet-http' }
            @{ Id = 'dotnet-config' }
            @{ Id = 'dotnet-public-api' }
            @{ Id = 'extension-import' }
        ) {
            # Arrange
            $fixture = Get-TestFixture -Id $Id
            $first = Get-TestOutputText -Id $Id -CapturedInput $fixture['CapturedInput'] -Selection $fixture['Selection']

            # Act / Assert: an identical second run, then three shuffled orders (the seed is printed on failure).
            $first.Length | Should -BeGreaterThan 40
            Get-TestOutputText -Id $Id -CapturedInput $fixture['CapturedInput'] -Selection $fixture['Selection'] | Should -Be $first
            foreach ($seed in 1033, 20261030, 7) {
                $shuffled = Get-DocsTestShuffled -Item $fixture['CapturedInput'] -Seed $seed
                Get-TestOutputText -Id $Id -CapturedInput $shuffled -Selection $fixture['Selection'] | Should -Be $first -Because "the output must not depend on the input order (seed $seed)"
            }
        }
    }

    Context 'bounds' {
        It 'reports an oversize and an undecodable selected input for <Id> as blocking under its own identifier with no element from those paths' -ForEach @(
            @{ Id = 'typescript-cli'; Big = 'big.ts'; Bad = 'bad.ts' }
            @{ Id = 'typescript-http'; Big = 'big.ts'; Bad = 'bad.ts' }
            @{ Id = 'typescript-exports'; Big = 'big.ts'; Bad = 'bad.ts' }
            @{ Id = 'dotnet-http'; Big = 'big.cs'; Bad = 'bad.cs' }
            @{ Id = 'dotnet-config'; Big = 'big/appsettings.json'; Bad = 'bad/appsettings.json' }
            @{ Id = 'dotnet-public-api'; Big = 'big.cs'; Bad = 'bad.cs' }
        ) {
            # Arrange
            $fixture = Get-TestFixture -Id $Id
            $inputs = @($fixture['CapturedInput']) + @((New-DocsTestOversizeInput -Path $Big), (New-DocsTestUndecodableInput -Path $Bad))

            # Act
            $output = Invoke-TestAnalyzer -Id $Id -CapturedInput $inputs -Selection $fixture['Selection']

            # Assert
            @($output['Elements'] | Where-Object { [string] $_['path'] -ceq $Big -or [string] $_['path'] -ceq $Bad }).Count | Should -Be 0
            foreach ($case in @(@($Big, 'INPUT_OVER_BOUND'), @($Bad, 'INPUT_UNDECODABLE'))) {
                $found = @($output['Diagnostics'] | Where-Object { [string] $_['code'] -ceq $case[1] })
                $found.Count | Should -Be 1 -Because "exactly one $($case[1]) is expected"
                $found[0]['path'] | Should -Be $case[0]
                $found[0]['analyzer_id'] | Should -Be $Id
                $found[0]['blocking'] | Should -BeTrue
                $found[0]['severity'] | Should -Be 'error'
                $found[0]['extensions'].Contains('docs.precision-limit') | Should -BeFalse
            }
        }

        It 'does not select an oversize or undecodable JSON input for extension-import (no parsed manifest root) and emits nothing for it' {
            # Arrange
            $fixture = Get-TestFixture -Id 'extension-import'
            $inputs = @($fixture['CapturedInput']) + @((New-DocsTestOversizeInput -Path 'discovery/big.json'), (New-DocsTestUndecodableInput -Path 'discovery/bad.json'))

            # Act
            $output = Invoke-TestAnalyzer -Id 'extension-import' -CapturedInput $inputs -Selection $fixture['Selection']

            # Assert
            @($output['Diagnostics'] | Where-Object { [string] $_['path'] -clike 'discovery/b*.json' }).Count | Should -Be 0
            @($output['Elements']).Count | Should -Be 1
        }

        It 'keeps the elements of another file when one file of <Id> has a lexical or structural error' -ForEach @(
            @{ Id = 'typescript-cli'; LexPath = 'lex.ts'; LexText = "import { program } from 'commander';`nprogram.command('x'); const s = 'unterminated"; OkPath = 'ok.ts'; OkText = "import { program } from 'commander';`nprogram.command('fine');"; Code = 'TS_LEXICAL_INVALID' }
            @{ Id = 'typescript-http'; LexPath = 'lex.ts'; LexText = "import express from 'express';`nconst app = express();`napp.get('/x', h); const s = 'unterminated"; OkPath = 'ok.ts'; OkText = "import express from 'express';`nconst app = express();`napp.get('/fine', h);"; Code = 'TS_LEXICAL_INVALID' }
            @{ Id = 'typescript-exports'; LexPath = 'lex.ts'; LexText = "export const a = 1; const s = 'unterminated"; OkPath = 'ok.ts'; OkText = 'export const fine = 1;'; Code = 'TS_LEXICAL_INVALID' }
            @{ Id = 'dotnet-http'; LexPath = 'lex.cs'; LexText = "public class LController : ControllerBase { [HttpGet(`"l`")] public IActionResult G() => Ok(); } var s = `"unterminated"; OkPath = 'ok.cs'; OkText = "public class OkController : ControllerBase { [HttpGet(`"fine`")] public IActionResult G() => Ok(); }"; Code = 'CSHARP_LEXICAL_INVALID' }
            @{ Id = 'dotnet-config'; LexPath = 'lex/appsettings.json'; LexText = '{ "A": '; OkPath = 'ok/appsettings.json'; OkText = '{ "Fine": 1 }'; Code = 'JSON_INVALID' }
            @{ Id = 'dotnet-public-api'; LexPath = 'lex.cs'; LexText = "public class L { } var s = `"unterminated"; OkPath = 'ok.cs'; OkText = 'public class Fine { }'; Code = 'CSHARP_LEXICAL_INVALID' }
        ) {
            # Arrange
            $inputs = @((New-DocsTestCapturedInput -Path $LexPath -Text $LexText), (New-DocsTestCapturedInput -Path $OkPath -Text $OkText))

            # Act
            $output = Invoke-TestAnalyzer -Id $Id -CapturedInput $inputs -Selection $null

            # Assert
            @($output['Elements'] | Where-Object { [string] $_['path'] -ceq $OkPath }).Count | Should -BeGreaterThan 0
            @($output['Elements'] | Where-Object { [string] $_['path'] -ceq $LexPath }).Count | Should -Be 0
            $found = @($output['Diagnostics'] | Where-Object { [string] $_['code'] -ceq $Code })
            $found.Count | Should -Be 1
            $found[0]['path'] | Should -Be $LexPath
            $found[0]['blocking'] | Should -BeTrue
            $found[0]['extensions'].Contains('docs.precision-limit') | Should -BeFalse
        }

        It 'keeps the elements of a valid manifest when another manifest is structurally invalid (extension-import)' {
            # Arrange
            $valid = Get-TestFixture -Id 'extension-import'
            $broken = New-DocsTestExtensionManifest -AdapterId 'other-adapter' -ManifestId 'other-run' -ManifestPath 'discovery/extensions/other.manifest.json' -ResultPath 'discovery/extensions/other.inventory.json' -ResultId 'other-inventory' -SourcePath 'src/other/second.rb' -MutateManifest { param($Manifest) $Manifest['extra'] = 'x' }

            # Act
            $output = Invoke-TestAnalyzer -Id 'extension-import' -CapturedInput (@($valid['CapturedInput']) + @($broken['CapturedInput'])) -Selection $valid['Selection']

            # Assert
            @($output['Elements'] | ForEach-Object { [string] $_['path'] }) | Should -Be @('src/other/service.rb')
            $invalid = @($output['Diagnostics'] | Where-Object { [string] $_['code'] -ceq 'EXTENSION_MANIFEST_INVALID' })
            $invalid.Count | Should -Be 1
            $invalid[0]['path'] | Should -Be 'discovery/extensions/other.manifest.json'
            $invalid[0]['blocking'] | Should -BeTrue
        }

        It 'yields no element and no diagnostic for an empty input set (<Id>)' -ForEach @(
            @{ Id = 'typescript-cli' }
            @{ Id = 'typescript-http' }
            @{ Id = 'typescript-exports' }
            @{ Id = 'dotnet-http' }
            @{ Id = 'dotnet-config' }
            @{ Id = 'dotnet-public-api' }
            @{ Id = 'extension-import' }
        ) {
            $output = Invoke-TestAnalyzer -Id $Id -CapturedInput @() -Selection $null
            @($output['Elements']).Count | Should -Be 0
            @($output['Diagnostics']).Count | Should -Be 0
        }

        It 'yields no element and no blocking diagnostic for an empty selected file (<Id>)' -ForEach @(
            @{ Id = 'typescript-cli'; Path = 'empty.ts' }
            @{ Id = 'typescript-http'; Path = 'empty.ts' }
            @{ Id = 'typescript-exports'; Path = 'empty.ts' }
            @{ Id = 'dotnet-http'; Path = 'empty.cs' }
            @{ Id = 'dotnet-public-api'; Path = 'empty.cs' }
        ) {
            $output = Invoke-TestAnalyzer -Id $Id -CapturedInput @(New-DocsTestCapturedInput -Path $Path -Text '') -Selection $null
            @($output['Elements']).Count | Should -Be 0
            @($output['Diagnostics'] | Where-Object { $_['blocking'] }).Count | Should -Be 0
        }

        It 'yields exactly one blocking JSON_INVALID and no element for an empty appsettings.json (dotnet-config)' {
            $output = Invoke-TestAnalyzer -Id 'dotnet-config' -CapturedInput @(New-DocsTestCapturedInput -Path 'appsettings.json' -Text '') -Selection $null
            @($output['Elements']).Count | Should -Be 0
            @($output['Diagnostics']).Count | Should -Be 1
            $output['Diagnostics'][0]['code'] | Should -Be 'JSON_INVALID'
            $output['Diagnostics'][0]['blocking'] | Should -BeTrue
        }

        It 'does not select an empty .json input for extension-import and yields nothing' {
            $output = Invoke-TestAnalyzer -Id 'extension-import' -CapturedInput @(New-DocsTestCapturedInput -Path 'discovery/empty.json' -Text '') -Selection $script:ExtensionSelection
            @($output['Elements']).Count | Should -Be 0
            @($output['Diagnostics']).Count | Should -Be 0
        }
    }
}

Describe 'Scanner contract (precision limit and element contract)' {
    BeforeAll {
        # One run per analyzer over its fixture set, with the captured text of every path.
        $script:Run = @{}
        $script:Text = @{}
        foreach ($id in @($script:Row.Keys)) {
            $fixture = Get-TestFixture -Id $id
            $script:Run[$id] = Invoke-TestAnalyzer -Id $id -CapturedInput $fixture['CapturedInput'] -Selection $fixture['Selection']
            $texts = @{}
            foreach ($captured in $fixture['CapturedInput']) { $texts[[string] $captured['path']] = $captured['text'] }
            $script:Text[$id] = $texts
        }
        [object[]] $script:LimitRow = Get-DocsScannerPrecisionLimit

        function Get-TestElementProperty {
            param([System.Collections.IDictionary] $Element, [string] $Name)
            $found = @($Element['properties'] | Where-Object { [string] $_['name'] -ceq $Name })
            if ($found.Count -eq 0) { return $null }
            $found[0]['value']
        }
    }

    Context 'precision limit' {
        It 'emits every (analyzer_id, code) row of Get-DocsScannerPrecisionLimit from a fixture as a marked non-blocking warning with the stated consequence' {
            $script:LimitRow.Count | Should -BeGreaterThan 0
            foreach ($row in $script:LimitRow) {
                $id = [string] $row['analyzer_id']
                $code = [string] $row['code']
                $because = "row ($id, $code) must be emitted by a fixture"
                $found = @($script:Run[$id]['Diagnostics'] | Where-Object { [string] $_['code'] -ceq $code })
                $found.Count | Should -BeGreaterThan 0 -Because $because
                @($found | ForEach-Object { [string] $_['path'] } | Sort-Object -Unique).Count | Should -Be $found.Count -Because "($id, $code) is emitted at most once per path"
                foreach ($diagnostic in $found) {
                    $diagnostic['analyzer_id'] | Should -Be $id
                    $diagnostic['severity'] | Should -Be 'warning' -Because $because
                    $diagnostic['blocking'] | Should -BeFalse -Because $because
                    [string]::IsNullOrEmpty([string] $diagnostic['path']) | Should -BeFalse -Because $because
                    $diagnostic['extensions'].Contains('docs.precision-limit') | Should -BeTrue -Because $because
                    $marker = $diagnostic['extensions']['docs.precision-limit']
                    @($marker.Keys) | Should -Be @('element_kind') -Because $because
                    $marker['element_kind'] | Should -Be ([string] $row['element_kind']) -Because $because
                    # The message carries the code, the count and the first line only (no fixture text).
                    $diagnostic['message'] | Should -Match ('^' + [regex]::Escape($code) + ': [0-9]+ occurrence\(s\); first at line [0-9]+\.$') -Because $because
                    $firstLine = [int] [regex]::Match([string] $diagnostic['message'], 'line ([0-9]+)\.$').Groups[1].Value
                    $all = @($script:Run[$id]['Elements'])
                    $atPath = @($all | Where-Object { [string] $_['path'] -ceq [string] $diagnostic['path'] })
                    $consequence = [string] $row['consequence']
                    if ($consequence.StartsWith('Element with a <dynamic>', [System.StringComparison]::Ordinal)) {
                        # A mounted router's routes carry the <dynamic> prefix at the router file's path.
                        @($all | Where-Object { ([string] $_['declaration']).Contains('<dynamic>') -and (Get-TestElementProperty -Element $_ -Name 'prefix_resolved') -eq $false }).Count | Should -BeGreaterThan 0 -Because "$because with a <dynamic> element"
                    } elseif ($consequence.StartsWith('Element without prefix', [System.StringComparison]::Ordinal)) {
                        @($all | Where-Object { -not ([string] $_['declaration']).Contains('<dynamic>') -and (Get-TestElementProperty -Element $_ -Name 'prefix_resolved') -eq $false }).Count | Should -BeGreaterThan 0 -Because "$because with an unprefixed element"
                    } elseif ($consequence.StartsWith('Element default', [System.StringComparison]::Ordinal)) {
                        @($atPath | Where-Object { ([string] $_['declaration']).EndsWith('.default') -and (Get-TestElementProperty -Element $_ -Name 'export_form') -ceq 'assignment' }).Count | Should -Be 1 -Because "$because with the default element"
                    } else {
                        @($atPath | Where-Object { [int] $_['line_range']['start'] -eq $firstLine }).Count | Should -Be 0 -Because "$because with no element at line $firstLine"
                    }
                }
            }
        }

        It 'carries no docs.precision-limit key on any diagnostic whose code is not a precision limit, and every other non-blocking code is a table row' {
            $seen = 0
            foreach ($id in @($script:Row.Keys)) {
                foreach ($diagnostic in @($script:Run[$id]['Diagnostics'])) {
                    $code = [string] $diagnostic['code']
                    $isRow = @($script:LimitRow | Where-Object { [string] $_['analyzer_id'] -ceq $id -and [string] $_['code'] -ceq $code }).Count -gt 0
                    if ($script:NotPrecision -ccontains $code) {
                        $seen++
                        $isRow | Should -BeFalse -Because "$code is listed as not a precision limit"
                        $diagnostic['extensions'].Contains('docs.precision-limit') | Should -BeFalse -Because "$code under $id carries no marker"
                    } elseif (-not $diagnostic['blocking']) {
                        $isRow | Should -BeTrue -Because "non-blocking code $code under $id must be a precision-limit row"
                    }
                }
            }
            $seen | Should -BeGreaterThan 0 -Because 'the fixtures emit at least one non-precision code (DUPLICATE_DECLARATION or EXTENSION_FINDING_SKIPPED)'
        }
    }

    Context 'element contract' {
        It 'records analysis_method scanner, a non-null line_range and the 1020 digest on every element of <Id>, and each element passes ConvertFrom-DocsSurfaceElement' -ForEach @(
            @{ Id = 'typescript-cli' }
            @{ Id = 'typescript-http' }
            @{ Id = 'typescript-exports' }
            @{ Id = 'dotnet-http' }
            @{ Id = 'dotnet-config' }
            @{ Id = 'dotnet-public-api' }
        ) {
            $elements = @($script:Run[$Id]['Elements'])
            $elements.Count | Should -BeGreaterThan 0
            foreach ($element in $elements) {
                $element['analysis_method'] | Should -Be 'scanner'
                $element['analyzer_id'] | Should -Be $Id
                $element['line_range'] | Should -Not -BeNullOrEmpty
                $text = $script:Text[$Id][[string] $element['path']]
                $element['source_sha256'] | Should -Be (Get-DocsDeclarationSha256 -Text $text -LineRange @([int] $element['line_range']['start'], [int] $element['line_range']['end']))
                { ConvertFrom-DocsSurfaceElement -Record $element } | Should -Not -Throw
            }
        }

        It 'keeps the digest of <Id> under an edit outside line_range, changes it under an edit inside, and gives equal digests for LF and CRLF' -ForEach @(
            @{ Id = 'typescript-cli' }
            @{ Id = 'typescript-http' }
            @{ Id = 'typescript-exports' }
            @{ Id = 'dotnet-http' }
            @{ Id = 'dotnet-config' }
            @{ Id = 'dotnet-public-api' }
        ) {
            # Arrange: the first element whose file has a line outside its range.
            $chosen = $null
            foreach ($element in @($script:Run[$Id]['Elements'])) {
                $lines = ([string] $script:Text[$Id][[string] $element['path']]) -split "`n"
                if ([int] $element['line_range']['end'] -lt $lines.Count -or [int] $element['line_range']['start'] -gt 1) { $chosen = $element; break }
            }
            $chosen | Should -Not -BeNullOrEmpty
            $text = [string] $script:Text[$Id][[string] $chosen['path']]
            $start = [int] $chosen['line_range']['start']
            $end = [int] $chosen['line_range']['end']
            $lines = $text -split "`n"
            $outsideIndex = if ($end -lt $lines.Count) { $end } else { 0 }
            $outside = [string[]] $lines.Clone()
            $outside[$outsideIndex] = $outside[$outsideIndex] + ' edited'
            $inside = [string[]] $lines.Clone()
            $inside[$start - 1] = $inside[$start - 1] + ' edited'

            # Act / Assert
            $digest = Get-DocsDeclarationSha256 -Text $text -LineRange @($start, $end)
            $digest | Should -Be $chosen['source_sha256']
            Get-DocsDeclarationSha256 -Text ($outside -join "`n") -LineRange @($start, $end) | Should -Be $digest
            Get-DocsDeclarationSha256 -Text ($inside -join "`n") -LineRange @($start, $end) | Should -Not -Be $digest
            Get-DocsDeclarationSha256 -Text $text.Replace("`n", "`r`n") -LineRange @($start, $end) | Should -Be $digest
        }

        It 'returns the elements of <Id> through Invoke-DocsAnalyzer with an in-memory scanner row and the -ImportModule seam, with no rejection finding' -ForEach @(
            @{ Id = 'typescript-cli' }
            @{ Id = 'typescript-http' }
            @{ Id = 'typescript-exports' }
            @{ Id = 'dotnet-http' }
            @{ Id = 'dotnet-config' }
            @{ Id = 'dotnet-public-api' }
        ) {
            # Arrange
            $fixture = Get-TestFixture -Id $Id
            $row = [pscustomobject]@{ Id = $Id; Version = '1.0.0'; AnalysisMethod = 'scanner'; ElementKinds = $script:Row[$Id]['Kinds']; Module = (Join-Path -Path $script:DocsRoot -ChildPath $script:Row[$Id]['Leaf']); Function = $script:Row[$Id]['Function'] }
            $seam = { param($ModulePath) Import-Module -Name $ModulePath -Force -Global -ErrorAction Stop }

            # Act
            $result = Invoke-DocsAnalyzer -Registration $row -CapturedInput $fixture['CapturedInput'] -Selection $fixture['Selection'] -ImportModule $seam

            # Assert
            @($result['Findings']).Count | Should -Be 0
            @($result['Elements']).Count | Should -Be @($script:Run[$Id]['Elements']).Count
            @($result['Elements']).Count | Should -BeGreaterThan 0
            @($result['Diagnostics']).Count | Should -Be @($script:Run[$Id]['Diagnostics']).Count
            ConvertTo-DocsTestOutputText -Output $result | Should -Be (ConvertTo-DocsTestOutputText -Output $script:Run[$Id])
        }
    }
}
