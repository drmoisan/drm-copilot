#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsAnalyzerDotnetHttp.psm1 (dotnet-http).

.DESCRIPTION
    In-memory C# fixtures yield the expected http-route elements for attribute routing (class
    prefix, [controller], [action] without Async, literal [area], '/' and '~/' overrides,
    multiple verbs and routes as combinations, AcceptVerbs, literal '+' folding) and minimal
    APIs (MapGet through MapPatch, MapMethods with array and collection expressions, Map as
    ANY, nested MapGroup variables and chains), and every diagnostic code the spec assigns to
    this analyzer. No file is written and no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.ScannerTestSupport.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerDotnetHttp.psm1') -Force -ErrorAction Stop

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

    function Get-TestDeclaration {
        param([hashtable] $Output)
        [string[]] $declarations = @($Output['Elements'] | ForEach-Object { [string] $_['declaration'] })
        [Array]::Sort($declarations, [System.StringComparer]::Ordinal)
        $declarations
    }

    $script:ControllerText = @'
using Microsoft.AspNetCore.Mvc;

namespace Demo.Api
{
    [ApiController]
    [Route("api/[controller]")]
    [Route("v2/[controller]")]
    public class ItemsController : ControllerBase
    {
        [HttpGet]
        public IActionResult List() => Ok();

        [HttpGet("{id:int}", Name = "GetItem")]
        [HttpHead("{id:int}")]
        public async Task<IActionResult> GetAsync(int id)
        {
            return Ok(id);
        }

        [HttpPost]
        [Route("create")]
        [Route("/absolute/" + "create")]
        public IActionResult Create([FromBody] Item item) => Ok();

        [HttpPut("~/root/[action]")]
        public IActionResult Replace(int id) => Ok();

        [AcceptVerbs("GET", "POST", Route = "multi")]
        public IActionResult Multi() => Ok();

        [HttpDelete(Constants.DeletePath)]
        public IActionResult Remove() => Ok();

        [HttpPatch($"patch/{nameof(Item)}")]
        public IActionResult Patch() => Ok();

        [NonAction]
        [HttpGet("ignored")]
        public IActionResult Hidden() => Ok();

        public IActionResult NotAnAction() => Ok();

        private class Nested
        {
            [HttpGet("nested")]
            public void Inner() { }
        }
    }

    [Area("Admin")]
    [Route("[area]/[controller]/[action]")]
    public class UsersController : Controller
    {
        [HttpGet]
        public IActionResult Index() => View();
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

    [Controller]
    public class Plain
    {
        [HttpOptions("opts")]
        public IActionResult Options() => Ok();
    }

    public class PlainService
    {
        [HttpGet("never")]
        public IActionResult Get() => Ok();
    }
}
'@

    $script:MinimalText = @'
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "root");
app.MapPost("/items", CreateItem);
app.MapPut("/items/{id}", (int id) => id);
app.MapDelete("/items/{id}", DeleteItem).RequireAuthorization();
app.MapPatch("/items/{id}", PatchItem);
app.MapMethods("/multi", new[] { "GET", "HEAD" }, Multi);
app.MapMethods("/collection", ["put", "OPTIONS"], Multi);
app.MapMethods("/dynamic", methods, Multi);
app.Map("/any", Any);
var api = app.MapGroup("/api");
var v1 = api.MapGroup("/v1").MapGroup("/inner");
v1.MapGet("/users", ListUsers);
api.MapGroup("/v2").MapGet("/users", ListUsersV2);
var dyn = app.MapGroup(prefix);
dyn.MapGet("/d", D);
app.MapGet(path, H);
app.MapHub<ChatHub>("/chat");
app.MapHub<OtherHub>("/other");
app.MapGrpcService<Greeter>();
app.MapHealthChecks("/health");
app.MapFallback(Fallback);
app.MapRazorPages();
app.MapControllerRoute(name: "default", pattern: "{controller=Home}/{action=Index}/{id?}");
app.MapDefaultControllerRoute();
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
}

AfterAll {
    Remove-Module -Name DocsAnalyzerDotnetHttp, DocsCSharpSyntax, DocsCSharpTokens, DocsScannerCommon, Docs.ScannerTestSupport, DocsAnalyzerRegistry, DocsSurface, DocsJson, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsAnalyzerDotnetHttp' {
    Context 'attribute routing' {
        BeforeAll {
            $script:ControllerOutput = Invoke-DocsAnalyzerDotnetHttp -CapturedInput @(New-DocsTestCapturedInput -Path 'src/Controllers.cs' -Text $script:ControllerText) -Selection $null
            $script:ControllerElement = @($script:ControllerOutput['Elements'])
            $script:ControllerDiagnostic = @($script:ControllerOutput['Diagnostics'])
        }

        It 'composes class prefixes with [controller], verb templates, multiple routes and verbs as combinations' {
            $list = Get-TestElement -Element $script:ControllerElement -Declaration 'GET /api/Items'
            $list['kind'] | Should -Be 'http-route'
            $list['name'] | Should -Be 'List'
            $list['analyzer_id'] | Should -Be 'dotnet-http'
            $list['analysis_method'] | Should -Be 'scanner'
            $list['line_range']['start'] | Should -Be 10
            $list['line_range']['end'] | Should -Be 11
            $list['properties'].Count | Should -Be 0
            (Get-TestElement -Element $script:ControllerElement -Declaration 'GET /v2/Items')['name'] | Should -Be 'List'
            $get = Get-TestElement -Element $script:ControllerElement -Declaration 'GET /api/Items/{id:int}'
            $get['name'] | Should -Be 'GetAsync'
            $get['line_range']['start'] | Should -Be 13
            $get['line_range']['end'] | Should -Be 15
            (Get-TestElement -Element $script:ControllerElement -Declaration 'HEAD /v2/Items/{id:int}')['name'] | Should -Be 'GetAsync'
            (Get-TestElement -Element $script:ControllerElement -Declaration 'POST /api/Items/create')['name'] | Should -Be 'Create'
            (Get-TestElement -Element $script:ControllerElement -Declaration 'POST /v2/Items/create')['line_range']['start'] | Should -Be 20
        }

        It 'applies slash and tilde overrides, [action] without Async, AcceptVerbs and literal folding' {
            (Get-TestElement -Element $script:ControllerElement -Declaration 'POST /absolute/create')['name'] | Should -Be 'Create'
            (Get-TestElement -Element $script:ControllerElement -Declaration 'PUT /root/Replace')['name'] | Should -Be 'Replace'
            (Get-TestElement -Element $script:ControllerElement -Declaration 'GET /api/Items')['name'] | Should -Be 'List'
            (Get-TestElement -Element $script:ControllerElement -Declaration 'GET /api/Items/multi')['name'] | Should -Be 'Multi'
            (Get-TestElement -Element $script:ControllerElement -Declaration 'POST /v2/Items/multi')['name'] | Should -Be 'Multi'
            (Get-TestElement -Element $script:ControllerElement -Declaration 'GET /Admin/Users/Index')['name'] | Should -Be 'Index'
            (Get-TestElement -Element $script:ControllerElement -Declaration 'OPTIONS /opts')['name'] | Should -Be 'Options'
            @($script:ControllerElement | Where-Object { [string] $_['declaration'] -clike '*ignored*' -or [string] $_['declaration'] -clike '*nested*' -or [string] $_['declaration'] -clike '*never*' -or [string] $_['declaration'] -clike '*legacy*' }).Count | Should -Be 0
            Get-TestDeclaration -Output $script:ControllerOutput | Should -Be @('GET /Admin/Users/Index', 'GET /api/Items', 'GET /api/Items/multi', 'GET /api/Items/{id:int}', 'GET /v2/Items', 'GET /v2/Items/multi', 'GET /v2/Items/{id:int}', 'HEAD /api/Items/{id:int}', 'HEAD /v2/Items/{id:int}', 'OPTIONS /opts', 'POST /absolute/create', 'POST /api/Items/create', 'POST /api/Items/multi', 'POST /v2/Items/create', 'POST /v2/Items/multi', 'PUT /root/Replace')
        }

        It 'reports dynamic templates, an unresolved area token and an inherited route prefix with the marker' {
            $dynamic = Get-TestDiagnostic -Diagnostic $script:ControllerDiagnostic -Code 'HTTP_DYNAMIC_ROUTE'
            $dynamic['message'] | Should -Match '2 occurrence'
            $dynamic['message'] | Should -Match 'line 31'
            $dynamic['severity'] | Should -Be 'warning'
            $dynamic['extensions']['docs.precision-limit']['element_kind'] | Should -Be 'http-route'
            $token = Get-TestDiagnostic -Diagnostic $script:ControllerDiagnostic -Code 'HTTP_ROUTE_TOKEN_UNRESOLVED'
            $token['message'] | Should -Match '1 occurrence'
            $token['message'] | Should -Match 'line 61'
            $inherited = Get-TestDiagnostic -Diagnostic $script:ControllerDiagnostic -Code 'DOTNET_ROUTE_INHERITED_UNRESOLVED'
            $inherited['message'] | Should -Match 'line 67'
            $inherited['extensions']['docs.precision-limit']['element_kind'] | Should -Be 'http-route'
            $script:ControllerDiagnostic.Count | Should -Be 3
        }
    }

    Context 'minimal APIs' {
        BeforeAll {
            $script:MinimalOutput = Invoke-DocsAnalyzerDotnetHttp -CapturedInput @(New-DocsTestCapturedInput -Path 'src/Program.cs' -Text $script:MinimalText) -Selection $null
            $script:MinimalElement = @($script:MinimalOutput['Elements'])
            $script:MinimalDiagnostic = @($script:MinimalOutput['Diagnostics'])
        }

        It 'emits MapGet through MapPatch, MapMethods with array and collection expressions, and Map as ANY' {
            $root = Get-TestElement -Element $script:MinimalElement -Declaration 'GET /'
            $root['name'] | Should -Be '/'
            $root['line_range']['start'] | Should -Be 4
            $root['line_range']['end'] | Should -Be 4
            (Get-TestElement -Element $script:MinimalElement -Declaration 'POST /items')['name'] | Should -Be 'CreateItem'
            (Get-TestElement -Element $script:MinimalElement -Declaration 'PUT /items/{id}')['name'] | Should -Be '/items/{id}'
            (Get-TestElement -Element $script:MinimalElement -Declaration 'DELETE /items/{id}')['name'] | Should -Be 'DeleteItem'
            (Get-TestElement -Element $script:MinimalElement -Declaration 'PATCH /items/{id}')['name'] | Should -Be 'PatchItem'
            (Get-TestElement -Element $script:MinimalElement -Declaration 'GET /multi')['name'] | Should -Be 'Multi'
            (Get-TestElement -Element $script:MinimalElement -Declaration 'HEAD /multi')['line_range']['start'] | Should -Be 9
            (Get-TestElement -Element $script:MinimalElement -Declaration 'PUT /collection')['name'] | Should -Be 'Multi'
            (Get-TestElement -Element $script:MinimalElement -Declaration 'OPTIONS /collection')['line_range']['start'] | Should -Be 10
            $any = Get-TestElement -Element $script:MinimalElement -Declaration 'ANY /any'
            Get-TestProperty -Element $any -Name 'framework_method' | Should -Be 'Map'
            $any['name'] | Should -Be 'Any'
        }

        It 'composes nested MapGroup variables and chains, renders a dynamic group as the dynamic segment, and keeps a parameter receiver without prefix' {
            (Get-TestElement -Element $script:MinimalElement -Declaration 'GET /api/v1/inner/users')['name'] | Should -Be 'ListUsers'
            (Get-TestElement -Element $script:MinimalElement -Declaration 'GET /api/v2/users')['name'] | Should -Be 'ListUsersV2'
            $dynamic = Get-TestElement -Element $script:MinimalElement -Declaration 'GET /<dynamic>/d'
            Get-TestProperty -Element $dynamic -Name 'prefix_resolved' | Should -BeFalse
            $orders = Get-TestElement -Element $script:MinimalElement -Declaration 'GET /orders'
            Get-TestProperty -Element $orders -Name 'prefix_resolved' | Should -BeFalse
            $orders['line_range']['start'] | Should -Be 34
            Get-TestDeclaration -Output $script:MinimalOutput | Should -Be @('ANY /any', 'DELETE /items/{id}', 'GET /', 'GET /<dynamic>/d', 'GET /api/v1/inner/users', 'GET /api/v2/users', 'GET /multi', 'GET /orders', 'HEAD /multi', 'OPTIONS /collection', 'PATCH /items/{id}', 'POST /items', 'PUT /collection', 'PUT /items/{id}')
        }

        It 'reports dynamic routes and method lists, dynamic prefixes, unresolved receivers, unsupported endpoint kinds and conventional routing' {
            $dynamic = Get-TestDiagnostic -Diagnostic $script:MinimalDiagnostic -Code 'HTTP_DYNAMIC_ROUTE'
            $dynamic['message'] | Should -Match '2 occurrence'
            $dynamic['message'] | Should -Match 'line 11'
            $prefix = Get-TestDiagnostic -Diagnostic $script:MinimalDiagnostic -Code 'HTTP_PREFIX_DYNAMIC'
            $prefix['message'] | Should -Match 'line 17'
            $receiver = Get-TestDiagnostic -Diagnostic $script:MinimalDiagnostic -Code 'HTTP_RECEIVER_UNRESOLVED'
            $receiver['message'] | Should -Match 'line 34'
            $receiver['extensions']['docs.precision-limit']['element_kind'] | Should -Be 'http-route'
            $unsupported = Get-TestDiagnostic -Diagnostic $script:MinimalDiagnostic -Code 'HTTP_ENDPOINT_KIND_UNSUPPORTED'
            $unsupported['message'] | Should -Match '6 occurrence'
            $unsupported['message'] | Should -Match 'line 20'
            $conventional = Get-TestDiagnostic -Diagnostic $script:MinimalDiagnostic -Code 'DOTNET_CONVENTIONAL_ROUTING_UNRESOLVED'
            $conventional['message'] | Should -Match '2 occurrence'
            $conventional['message'] | Should -Match 'line 26'
            $script:MinimalDiagnostic.Count | Should -Be 5
        }
    }

    Context 'conditional compilation, selection, bounds and duplicates' {
        It 'scans both branches of #if, reports CSHARP_CONDITIONAL_COMPILATION at the first directive and duplicates as DUPLICATE_DECLARATION' {
            $text = "using X;`n#if DEBUG`npublic class AController : ControllerBase { [HttpGet(`"a`")] public IActionResult Get() => Ok(); }`n#else`npublic class AController : ControllerBase { [HttpGet(`"a`")] public IActionResult Get() => Ok(); }`n#endif"
            $output = Invoke-DocsAnalyzerDotnetHttp -CapturedInput @(New-DocsTestCapturedInput -Path 'cond.cs' -Text $text) -Selection $null
            Get-TestDeclaration -Output $output | Should -Be @('GET /a')
            (Get-TestElement -Element @($output['Elements']) -Declaration 'GET /a')['line_range']['start'] | Should -Be 3
            $conditional = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'CSHARP_CONDITIONAL_COMPILATION'
            $conditional['message'] | Should -Match 'line 2'
            $conditional['blocking'] | Should -BeFalse
            $conditional['extensions']['docs.precision-limit']['element_kind'] | Should -Be 'http-route'
            $duplicate = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'DUPLICATE_DECLARATION'
            $duplicate['message'] | Should -Match 'line 5'
            $duplicate['extensions'].Contains('docs.precision-limit') | Should -BeFalse
            $output['Diagnostics'].Count | Should -Be 2
        }

        It 'selects only .cs inputs and returns nothing for an empty set, an empty file and a file without routes' {
            $empty = Invoke-DocsAnalyzerDotnetHttp -CapturedInput @() -Selection $null
            $empty['Elements'].Count | Should -Be 0
            $empty['Diagnostics'].Count | Should -Be 0
            $plain = Invoke-DocsAnalyzerDotnetHttp -CapturedInput @((New-DocsTestCapturedInput -Path 'x.cs' -Text ''), (New-DocsTestCapturedInput -Path 'y.cs' -Text "namespace N;`npublic class Service { public int Add(int a, int b) => a + b; }"), (New-DocsTestCapturedInput -Path 'z.ts' -Text "app.MapGet('/x', h);")) -Selection @{ source_roots = @('src') }
            $plain['Elements'].Count | Should -Be 0
            $plain['Diagnostics'].Count | Should -Be 0
        }

        It 'reports oversize, undecodable and lexically invalid inputs as blocking and keeps other files' {
            $inputs = @(
                (New-DocsTestOversizeInput -Path 'big.cs'),
                (New-DocsTestUndecodableInput -Path 'bad.cs'),
                (New-DocsTestCapturedInput -Path 'lex.cs' -Text "app.MapGet(`"/x`", h); var s = `"unterminated"),
                (New-DocsTestCapturedInput -Path 'ok.cs' -Text "app.MapGet(`"/fine`", h);")
            )
            $output = Invoke-DocsAnalyzerDotnetHttp -CapturedInput $inputs -Selection $null
            Get-TestDeclaration -Output $output | Should -Be @('GET /fine')
            foreach ($code in @('INPUT_OVER_BOUND', 'INPUT_UNDECODABLE', 'CSHARP_LEXICAL_INVALID')) {
                $diagnostic = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code $code
                $diagnostic['blocking'] | Should -BeTrue
                $diagnostic['extensions'].Contains('docs.precision-limit') | Should -BeFalse
            }
            $output['Diagnostics'].Count | Should -Be 3
        }

        It 'recognizes verb attributes and Map* methods by their exact case and ignores a wrong-case name' {
            # Arrange: C# names are case-sensitive, so Httpget, HTTPPOST, Mapget and MapPOST are not routes.
            $controller = "public class ItemsController : ControllerBase`n{`n    [Httpget(`"a`")] public IActionResult A() => Ok();`n    [HTTPPOST(`"b`")] public IActionResult B() => Ok();`n    [HttpGet(`"c`")] public IActionResult C() => Ok();`n}"
            $program = "app.Mapget(`"/lower`", h);`napp.MapPOST(`"/upper`", h);`napp.MapGet(`"/ok`", h);"
            $inputs = @((New-DocsTestCapturedInput -Path 'src/ItemsController.cs' -Text $controller), (New-DocsTestCapturedInput -Path 'src/Program.cs' -Text $program))

            # Act
            $output = Invoke-DocsAnalyzerDotnetHttp -CapturedInput $inputs -Selection $null

            # Assert
            Get-TestDeclaration -Output $output | Should -Be @('GET /c', 'GET /ok') -Because 'only the exact-case HttpGet attribute and MapGet call are routes'
            $output['Diagnostics'].Count | Should -Be 0
        }

        It 'throws for a null captured-input list' {
            { Invoke-DocsAnalyzerDotnetHttp -CapturedInput $null -Selection $null } | Should -Throw
        }
    }
}
