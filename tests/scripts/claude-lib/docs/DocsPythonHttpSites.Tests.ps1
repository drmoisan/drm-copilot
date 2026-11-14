#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPythonHttpSites.psm1 (issue #1022).

.DESCRIPTION
    Covers the FastAPI and Flask receivers, every route decorator and call form of spec
    python-http (default GET, WEBSOCKET with protocol websocket, converters kept verbatim, no
    automatic HEAD or OPTIONS), the mount sites, the pass-1 diagnostic rows with survival of
    the other sites, and a seeded property test per exported function. Inputs are in-memory
    strings.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonBindings.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonHttpSites.psm1') -Force -ErrorAction Stop

    function Get-TestFrontEnd {
        param([string] $Text)
        $frontEnd = Get-DocsPythonFrontEnd -Text $Text
        $frontEnd['Blocked'] | Should -BeFalse -Because 'the fixture passes the front-end'
        return $frontEnd
    }

    function ConvertTo-TestRoute {
        param([hashtable] $Site)
        return ($Site['Receiver'] + '|' + ($Site['Method'] -join ',') + '|' + $Site['Path'] + '|' + $Site['Name'] + '|' + ($Site['Span'] -join '-') + '|' + $Site['Protocol'])
    }

    $script:FastApiText = @(
        'from fastapi import FastAPI, APIRouter'
        'from fastapi import APIRouter as Router'
        'from pkg.config import settings'
        ''
        'app = FastAPI()'
        'items = APIRouter(prefix="/items")'
        'plain = Router()'
        'dynamic = APIRouter(prefix=settings.prefix)'
        ''
        ''
        '@app.get("/")'
        'def root():'
        '    pass'
        ''
        ''
        '@app.api_route("/ping", methods=["get", "POST", "GET"])'
        'async def ping():'
        '    pass'
        ''
        ''
        '@app.websocket("/ws")'
        'async def socket():'
        '    pass'
        ''
        ''
        '@items.post("/{item_id}")'
        '@other_decorator'
        'def create_item(item_id: int):'
        '    pass'
        ''
        ''
        '@plain.trace('
        '    "/t",'
        ')'
        'def traced():'
        '    pass'
        ''
        ''
        'app.add_api_route("/health", root, methods=["HEAD"])'
        'app.add_api_route("/default", root)'
        'app.include_router(items)'
        'app.include_router(items, prefix="/v2")'
        'app.include_router(plain, prefix=settings.prefix)'
        'app.mount("/static", StaticFiles(directory="s"))'
    ) -join "`n"

    $script:FlaskText = @(
        'from flask import Flask, Blueprint'
        'from flask.views import MethodView'
        ''
        'app = Flask(__name__)'
        'bp = Blueprint("bp", __name__, url_prefix="/bp")'
        'bare = Blueprint("bare", __name__)'
        ''
        ''
        'class ItemView(MethodView):'
        '    pass'
        ''
        ''
        '@app.route("/")'
        'def index():'
        '    pass'
        ''
        ''
        '@app.route("/multi", methods=["GET", "POST"])'
        'def multi():'
        '    pass'
        ''
        ''
        '@bp.get("/items/<int:item_id>")'
        'def item(item_id):'
        '    pass'
        ''
        ''
        '@bare.delete("/gone")'
        'def gone():'
        '    pass'
        ''
        ''
        'app.register_blueprint(bp)'
        'app.register_blueprint(bp, url_prefix="/other/")'
        'app.register_blueprint(bare, url_prefix=PREFIX)'
        'app.add_url_rule("/rule", view_func=index, methods=["PUT"])'
        'app.add_url_rule("/view", view_func=ItemView.as_view("item"))'
        'app.add_url_rule("/typed", view_func=ItemView.as_view("item"), methods=["GET"])'
    ) -join "`n"
}

AfterAll {
    Remove-Module -Name DocsPythonHttpSites, DocsPythonBindings, DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsFastApiRouteSite' {
    BeforeAll {
        $frontEnd = Get-TestFrontEnd -Text $script:FastApiText
        $script:FastApi = Get-DocsFastApiRouteSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
    }

    It 'tracks FastAPI applications and routers with literal, absent and dynamic prefixes and no diagnostic' {
        $script:FastApi['Diagnostics'].Count | Should -Be 0
        @($script:FastApi['Receiver'] | ForEach-Object { $_['Name'] + ':' + $_['Kind'] + ':' + $_['Prefix'] + ':' + $_['PrefixDynamic'] }) | Should -Be @('app:app::False', 'items:router:/items:False', 'plain:router::False', 'dynamic:router::True')
        $script:FastApi['Receiver'][0]['Framework'] | Should -BeExactly 'fastapi'
    }

    It 'classifies every decorator form with default GET, deduplicated upper-case methods, WEBSOCKET and header spans from the route decorator' {
        $routes = @($script:FastApi['Site'] | Where-Object { $_['Name'] -cne $_['Path'] } | ForEach-Object { ConvertTo-TestRoute -Site $_ })
        $routes | Should -Be @('app|GET|/|root|11-12|http', 'app|GET,POST|/ping|ping|16-17|http', 'app|WEBSOCKET|/ws|socket|21-22|websocket', 'items|POST|/{item_id}|create_item|26-28|http', 'plain|TRACE|/t|traced|32-35|http')
    }

    It 'classifies add_api_route with literal methods and the default method, named by the template with the statement span' {
        $calls = @($script:FastApi['Site'] | Where-Object { $_['Name'] -ceq $_['Path'] } | ForEach-Object { ConvertTo-TestRoute -Site $_ })
        $calls | Should -Be @('app|HEAD|/health|/health|39-39|http', 'app|GET|/default|/default|40-40|http')
        @($script:FastApi['Site'] | Where-Object { $_['Method'] -ccontains 'OPTIONS' }).Count | Should -Be 0
    }

    It 'reports HTTP_DYNAMIC_ROUTE for a non-literal path and method list while the other sites survive' {
        $frontEnd = Get-TestFrontEnd -Text "from fastapi import FastAPI`napp = FastAPI()`nPATH = '/d'`n@app.get(PATH)`ndef a():`n    pass`n@app.api_route('/m', methods=METHODS)`ndef b():`n    pass`n@app.get(f'/{PATH}')`ndef c():`n    pass`napp.add_api_route(PATH, a)`n@app.get('/fine')`ndef d():`n    pass`n"
        $result = Get-DocsFastApiRouteSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('HTTP_DYNAMIC_ROUTE', 'HTTP_DYNAMIC_ROUTE', 'HTTP_DYNAMIC_ROUTE', 'HTTP_DYNAMIC_ROUTE')
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(4, 7, 10, 13)
        $result['Diagnostics'][0]['Severity'] | Should -BeExactly 'warning'
        $result['Diagnostics'][0]['Blocking'] | Should -BeFalse
        @($result['Site'] | ForEach-Object { $_['Path'] }) | Should -Be @('/fine')
    }

    It 'reports HTTP_ROUTE_IN_LOOP for a decorator and a call inside a loop while the other sites survive' {
        $frontEnd = Get-TestFrontEnd -Text "from fastapi import FastAPI`napp = FastAPI()`nfor route in ('/a', '/b'):`n    @app.get(route)`n    def looped():`n        pass`n    app.add_api_route('/x', looped)`n@app.get('/fine')`ndef fine():`n    pass`n"
        $result = Get-DocsFastApiRouteSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('HTTP_ROUTE_IN_LOOP', 'HTTP_ROUTE_IN_LOOP')
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(4, 7)
        @($result['Site'] | ForEach-Object { $_['Path'] }) | Should -Be @('/fine')
    }

    It 'reports HTTP_UNBOUND_ROUTE only for an untracked receiver with a literal path beginning with a slash and ignores receivers of other frameworks' {
        $frontEnd = Get-TestFrontEnd -Text "from fastapi import FastAPI`nfrom flask import Flask`nimport click`nflask_app = Flask(__name__)`napp = FastAPI()`ndef make(router):`n    @router.get('/unbound')`n    def u():`n        pass`n    @router.get(name)`n    def v():`n        pass`n@flask_app.get('/flask')`ndef f():`n    pass`n@click.command()`ndef c():`n    pass`n@app.get('/fine')`ndef fine():`n    pass`n"
        $result = Get-DocsFastApiRouteSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('HTTP_UNBOUND_ROUTE')
        $result['Diagnostics'][0]['Line'] | Should -Be 7
        @($result['Site'] | ForEach-Object { $_['Path'] }) | Should -Be @('/fine')
    }

    It 'property: Get-DocsFastApiRouteSite yields one site per generated decorator with its method and path' {
        $seed = 102270
        $random = [System.Random]::new($seed)
        $shortcuts = @('get', 'post', 'put', 'patch', 'delete', 'options', 'head', 'trace')
        for ($iteration = 0; $iteration -lt 40; $iteration++) {
            $count = $random.Next(0, 6)
            $lines = [System.Collections.Generic.List[string]]::new()
            $lines.Add('from fastapi import FastAPI')
            $lines.Add('app = FastAPI()')
            $expected = [System.Collections.Generic.List[string]]::new()
            for ($i = 0; $i -lt $count; $i++) {
                $method = $shortcuts[$random.Next($shortcuts.Count)]
                $path = '/p' + $random.Next(100) + $(if ($random.Next(2) -eq 0) { '/{id}' } else { '' })
                $lines.Add("@app.$method('$path')")
                $lines.Add("def h$i():")
                $lines.Add('    pass')
                $expected.Add($method.ToUpperInvariant() + ' ' + $path + ' h' + $i)
            }
            $frontEnd = Get-TestFrontEnd -Text ($lines -join "`n")
            $result = Get-DocsFastApiRouteSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
            $result['Diagnostics'].Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
            @($result['Site'] | ForEach-Object { ($_['Method'] -join ',') + ' ' + $_['Path'] + ' ' + $_['Name'] }) | Should -Be $expected.ToArray() -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Get-DocsFlaskRouteSite' {
    BeforeAll {
        $frontEnd = Get-TestFrontEnd -Text $script:FlaskText
        $script:Flask = Get-DocsFlaskRouteSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
    }

    It 'tracks Flask applications and blueprints with their url_prefix' {
        @($script:Flask['Receiver'] | ForEach-Object { $_['Name'] + ':' + $_['Kind'] + ':' + $_['Prefix'] }) | Should -Be @('app:app:', 'bp:blueprint:/bp', 'bare:blueprint:')
    }

    It 'classifies route, shortcuts and add_url_rule with converters verbatim and no automatic HEAD or OPTIONS' {
        @($script:Flask['Site'] | ForEach-Object { ConvertTo-TestRoute -Site $_ }) | Should -Be @('app|GET|/|index|13-14|http', 'app|GET,POST|/multi|multi|18-19|http', 'bp|GET|/items/<int:item_id>|item|23-24|http', 'bare|DELETE|/gone|gone|28-29|http', 'app|PUT|/rule|/rule|36-36|http', 'app|GET|/typed|/typed|38-38|http')
        @($script:Flask['Site'] | Where-Object { $_['Method'] -ccontains 'HEAD' -or $_['Method'] -ccontains 'OPTIONS' }).Count | Should -Be 0
    }

    It 'reports HTTP_METHOD_VIEW_UNRESOLVED for add_url_rule with an as_view view_func and no literal methods' {
        @($script:Flask['Diagnostics'] | ForEach-Object { $_['Code'] + ':' + $_['Line'] }) | Should -Be @('HTTP_METHOD_VIEW_UNRESOLVED:37')
        $script:Flask['Diagnostics'][0]['Severity'] | Should -BeExactly 'warning'
        $script:Flask['Diagnostics'][0]['Blocking'] | Should -BeFalse
    }

    It 'reports HTTP_DYNAMIC_ROUTE, HTTP_ROUTE_IN_LOOP and HTTP_UNBOUND_ROUTE for Flask forms while the other sites survive' {
        $frontEnd = Get-TestFrontEnd -Text "from flask import Flask`napp = Flask(__name__)`nRULE = '/r'`n@app.route(RULE)`ndef a():`n    pass`nwhile x:`n    @app.get('/loop')`n    def b():`n        pass`ndef make(bp):`n    @bp.route('/unbound')`n    def c():`n        pass`n@app.route('/fine', methods=['PATCH'])`ndef d():`n    pass`n"
        $result = Get-DocsFlaskRouteSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] + ':' + $_['Line'] }) | Should -Be @('HTTP_DYNAMIC_ROUTE:4', 'HTTP_ROUTE_IN_LOOP:8', 'HTTP_UNBOUND_ROUTE:12')
        @($result['Site'] | ForEach-Object { ConvertTo-TestRoute -Site $_ }) | Should -Be @('app|PATCH|/fine|d|15-16|http')
    }

    It 'property: Get-DocsFlaskRouteSite yields one site per generated route with its methods' {
        $seed = 102271
        $random = [System.Random]::new($seed)
        $methods = @('GET', 'POST', 'PUT', 'PATCH', 'DELETE')
        for ($iteration = 0; $iteration -lt 40; $iteration++) {
            $count = $random.Next(0, 6)
            $lines = [System.Collections.Generic.List[string]]::new()
            $lines.Add('from flask import Flask')
            $lines.Add('app = Flask(__name__)')
            $expected = [System.Collections.Generic.List[string]]::new()
            for ($i = 0; $i -lt $count; $i++) {
                $chosen = @($methods | Sort-Object -Property @{ Expression = { $random.Next() } } | Select-Object -First $random.Next(1, 4))
                $path = '/p' + $random.Next(100)
                $lines.Add("@app.route('$path', methods=[" + (($chosen | ForEach-Object { "'$_'" }) -join ', ') + '])')
                $lines.Add("def h$i():")
                $lines.Add('    pass')
                $expected.Add(($chosen -join ',') + ' ' + $path)
            }
            $frontEnd = Get-TestFrontEnd -Text ($lines -join "`n")
            $result = Get-DocsFlaskRouteSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
            $result['Diagnostics'].Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
            @($result['Site'] | ForEach-Object { ($_['Method'] -join ',') + ' ' + $_['Path'] }) | Should -Be $expected.ToArray() -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Get-DocsHttpMountSite' {
    It 'records include_router and register_blueprint sites with literal, absent and dynamic prefixes and reports mount as HTTP_MOUNT_UNRESOLVED' {
        $frontEnd = Get-TestFrontEnd -Text $script:FastApiText
        $result = Get-DocsHttpMountSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
        @($result['Site'] | ForEach-Object { $_['Parent'] + '>' + $_['Child'] + ':' + $_['Prefix'] + ':' + $_['PrefixGiven'] + ':' + $_['PrefixDynamic'] + ':' + $_['Kind'] + ':' + $_['Line'] }) | Should -Be @('app>items::False:False:include:41', 'app>items:/v2:True:False:include:42', 'app>plain::True:True:include:43')
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] + ':' + $_['Line'] }) | Should -Be @('HTTP_MOUNT_UNRESOLVED:44')
        $result['Diagnostics'][0]['Severity'] | Should -BeExactly 'warning'
        $result['Diagnostics'][0]['Blocking'] | Should -BeFalse
        $flaskFrontEnd = Get-TestFrontEnd -Text $script:FlaskText
        $flask = Get-DocsHttpMountSite -Line $flaskFrontEnd['Lines'] -Import $flaskFrontEnd['Import'] -Receiver $flaskFrontEnd['Receiver']
        @($flask['Site'] | ForEach-Object { $_['Parent'] + '>' + $_['Child'] + ':' + $_['Prefix'] + ':' + $_['PrefixGiven'] + ':' + $_['PrefixDynamic'] + ':' + $_['Kind'] }) | Should -Be @('app>bp::False:False:register', 'app>bp:/other/:True:False:register', 'app>bare::True:True:register')
        $flask['Diagnostics'].Count | Should -Be 0
    }

    It 'records a dotted child expression, reports a call child as HTTP_MOUNT_UNRESOLVED and ignores untracked parents' {
        $frontEnd = Get-TestFrontEnd -Text "from fastapi import FastAPI`nfrom . import routers`napp = FastAPI()`napp.include_router(routers.users, prefix='/users')`napp.include_router(make_router())`nother.include_router(routers.users)`n"
        $result = Get-DocsHttpMountSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
        @($result['Site'] | ForEach-Object { $_['Child'] + ':' + $_['Prefix'] }) | Should -Be @('routers.users:/users')
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] + ':' + $_['Line'] }) | Should -Be @('HTTP_MOUNT_UNRESOLVED:5')
    }

    It 'property: Get-DocsHttpMountSite records every generated include with its prefix in order' {
        $seed = 102272
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 40; $iteration++) {
            $count = $random.Next(0, 6)
            $lines = [System.Collections.Generic.List[string]]::new()
            $lines.Add('from fastapi import FastAPI, APIRouter')
            $lines.Add('app = FastAPI()')
            $expected = [System.Collections.Generic.List[string]]::new()
            for ($i = 0; $i -lt $count; $i++) {
                $lines.Add("r$i = APIRouter()")
                $prefix = if ($random.Next(2) -eq 0) { '/x' + $random.Next(100) } else { $null }
                $lines.Add("app.include_router(r$i" + $(if ($null -ne $prefix) { ", prefix='$prefix'" } else { '' }) + ')')
                $expected.Add("app>r${i}:" + [string] $prefix + ':' + ($null -ne $prefix))
            }
            $frontEnd = Get-TestFrontEnd -Text ($lines -join "`n")
            $result = Get-DocsHttpMountSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
            $result['Diagnostics'].Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
            @($result['Site'] | ForEach-Object { $_['Parent'] + '>' + $_['Child'] + ':' + $_['Prefix'] + ':' + $_['PrefixGiven'] }) | Should -Be $expected.ToArray() -Because "seed $seed, iteration $iteration"
        }
    }
}
