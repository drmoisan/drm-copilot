#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsAnalyzerTypeScriptHttp.psm1 (typescript-http).

.DESCRIPTION
    In-memory Express and Fastify fixtures yield the expected http-route elements: the method
    set with ANY for all, path arrays, route() chains, a router in a second file mounted through
    a relative import with the composed prefix, a router mounted twice, an unmounted router with
    mounted false, Fastify route objects with method arrays and url or path, register prefixes for
    inline, same-file and relative-import plugins and fp(fn), no implicit HEAD, and the
    HTTP_DYNAMIC_ROUTE, HTTP_PREFIX_DYNAMIC and HTTP_MOUNT_UNRESOLVED precision-limit
    diagnostics. No file is written and no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.ScannerTestSupport.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerTypeScriptHttp.psm1') -Force -ErrorAction Stop

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

    function Get-TestDeclaration {
        param([hashtable] $Output)
        [string[]] $declarations = @($Output['Elements'] | ForEach-Object { [string] $_['declaration'] })
        [Array]::Sort($declarations, [System.StringComparer]::Ordinal)
        $declarations
    }

    $script:ExpressAppText = @'
import express, { Router } from 'express';
import itemsRouter from './routes/items';
import { adminRouter } from './routes/admin';
import cors from 'cors';

const app = express();
app.get('/', home);
app.post(['/a', '/b'], create);
app.all('/any', anyHandler);
app
  .route('/things')
  .get(list)
  .post(add);
app.use('/items', itemsRouter);
app.use('/v2/items', itemsRouter);
app.use('/admin', auth(), adminRouter);
app.use(cors());
app.use('/missing', unknownRouter);
app.use(dynamicPrefix, itemsRouter);
app.get(/^\/regex/, h);
app.get(computedPath, h);
const local = Router();
local.delete('/gone', remove);
app.use(local);
const orphan = Router();
orphan.put('/alone', fix);
export default app;
'@

    $script:ItemsRouterText = @'
import { Router } from 'express';
const router = Router();
router.get('/:id', getItem);
router.patch('/:id', patchItem);
export default router;
'@

    $script:AdminRouterText = @'
import express from 'express';
export const adminRouter = express.Router();
adminRouter.options('/settings', settings);
adminRouter.head('/ping', ping);
'@

    $script:FastifyAppText = @'
import Fastify from 'fastify';
import fp from 'fastify-plugin';
import usersPlugin from './plugins/users';
import cors from '@fastify/cors';

const app = Fastify();
app.get('/health', health);
app.route({ method: ['GET', 'POST'], url: '/multi', handler: multi });
app.route({ method: 'PUT', path: '/alt' });
app.register(usersPlugin, { prefix: '/users' });
app.register(fp(localPlugin), { prefix: '/local' });
app.register(async (instance) => {
  instance.get('/inline', inline);
  instance.register(nested, { prefix: '/deep' });
}, { prefix: '/v1' });
app.register(cors);
app.register(require('./legacy'));
app.register(usersPlugin, { prefix: computed });
app.route({ method: dynamicMethod, url: '/x' });
app.get(`/tpl/${id}`, h);
app.register(unregistered);

async function localPlugin(f) {
  f.post('/create', create);
}

const nested = async (n) => {
  n.delete('/item', del);
};
'@

    $script:UsersPluginText = @'
import type { FastifyInstance } from 'fastify';
export default async function users(fastify: FastifyInstance) {
  fastify.get('/', listUsers);
  fastify.all('/catch', catchAll);
}
'@
}

AfterAll {
    Remove-Module -Name DocsAnalyzerTypeScriptHttp, DocsTypeScriptHttpSupport, DocsTypeScriptHttpDeclaration, DocsTypeScriptSyntax, DocsTypeScriptTokens, DocsScannerCommon, Docs.ScannerTestSupport, DocsAnalyzerRegistry, DocsSurface, DocsJson, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsAnalyzerTypeScriptHttp' {
    Context 'Express' {
        BeforeAll {
            $script:ExpressOutput = Invoke-DocsAnalyzerTypeScriptHttp -CapturedInput @(
                (New-DocsTestCapturedInput -Path 'src/app.ts' -Text $script:ExpressAppText),
                (New-DocsTestCapturedInput -Path 'src/routes/items.ts' -Text $script:ItemsRouterText),
                (New-DocsTestCapturedInput -Path 'src/routes/admin.ts' -Text $script:AdminRouterText)
            ) -Selection $null
            $script:ExpressElement = @($script:ExpressOutput['Elements'])
        }

        It 'emits the method set with ANY for all, path arrays and route() chains on the app' {
            # Assert
            $homeRoute = Get-TestElement -Element $script:ExpressElement -Declaration 'GET /' -Path 'src/app.ts'
            $homeRoute['kind'] | Should -Be 'http-route'
            $homeRoute['name'] | Should -Be 'home'
            $homeRoute['analyzer_id'] | Should -Be 'typescript-http'
            $homeRoute['analysis_method'] | Should -Be 'scanner'
            $homeRoute['line_range']['start'] | Should -Be 7
            $homeRoute['line_range']['end'] | Should -Be 7
            $homeRoute['properties'].Count | Should -Be 0
            (Get-TestElement -Element $script:ExpressElement -Declaration 'POST /a')['name'] | Should -Be 'create'
            (Get-TestElement -Element $script:ExpressElement -Declaration 'POST /b')['line_range']['start'] | Should -Be 8
            $any = Get-TestElement -Element $script:ExpressElement -Declaration 'ANY /any'
            Get-TestProperty -Element $any -Name 'framework_method' | Should -Be 'all'
            $things = Get-TestElement -Element $script:ExpressElement -Declaration 'GET /things'
            $things['name'] | Should -Be 'list'
            $things['line_range']['start'] | Should -Be 10
            $things['line_range']['end'] | Should -Be 12
            (Get-TestElement -Element $script:ExpressElement -Declaration 'POST /things')['line_range']['end'] | Should -Be 13
            @($script:ExpressElement | Where-Object { [string] $_['declaration'] -clike 'HEAD *' -and [string] $_['path'] -ceq 'src/app.ts' }).Count | Should -Be 0
        }

        It 'mounts a relative-import router with composed prefixes, twice, and a named export router' {
            $first = Get-TestElement -Element $script:ExpressElement -Declaration 'GET /items/:id'
            $first['path'] | Should -Be 'src/routes/items.ts'
            $first['name'] | Should -Be 'getItem'
            $first['line_range']['start'] | Should -Be 3
            Get-TestProperty -Element $first -Name 'mounted' | Should -BeNullOrEmpty
            Get-TestProperty -Element $first -Name 'prefix_resolved' | Should -BeNullOrEmpty
            (Get-TestElement -Element $script:ExpressElement -Declaration 'GET /v2/items/:id')['path'] | Should -Be 'src/routes/items.ts'
            (Get-TestElement -Element $script:ExpressElement -Declaration 'PATCH /v2/items/:id')['name'] | Should -Be 'patchItem'
            (Get-TestElement -Element $script:ExpressElement -Declaration 'OPTIONS /admin/settings')['path'] | Should -Be 'src/routes/admin.ts'
            (Get-TestElement -Element $script:ExpressElement -Declaration 'HEAD /admin/ping')['name'] | Should -Be 'ping'
            (Get-TestElement -Element $script:ExpressElement -Declaration 'DELETE /gone')['name'] | Should -Be 'remove'
        }

        It 'keeps an unmounted router with mounted false and renders a dynamic prefix as the dynamic segment' {
            $orphan = Get-TestElement -Element $script:ExpressElement -Declaration 'PUT /alone'
            Get-TestProperty -Element $orphan -Name 'mounted' | Should -BeFalse
            $dynamic = Get-TestElement -Element $script:ExpressElement -Declaration 'GET /<dynamic>/:id'
            $dynamic['path'] | Should -Be 'src/routes/items.ts'
            Get-TestProperty -Element $dynamic -Name 'prefix_resolved' | Should -BeFalse
            (Get-TestElement -Element $script:ExpressElement -Declaration 'PATCH /<dynamic>/:id')['name'] | Should -Be 'patchItem'
            Get-TestDeclaration -Output $script:ExpressOutput | Should -Be @('ANY /any', 'DELETE /gone', 'GET /', 'GET /<dynamic>/:id', 'GET /items/:id', 'GET /things', 'GET /v2/items/:id', 'HEAD /admin/ping', 'OPTIONS /admin/settings', 'PATCH /<dynamic>/:id', 'PATCH /items/:id', 'PATCH /v2/items/:id', 'POST /a', 'POST /b', 'POST /things', 'PUT /alone')
        }

        It 'reports dynamic routes, dynamic prefixes and unresolved mounts with the precision-limit marker' {
            $dynamicRoute = Get-TestDiagnostic -Diagnostic @($script:ExpressOutput['Diagnostics']) -Code 'HTTP_DYNAMIC_ROUTE'
            $dynamicRoute['message'] | Should -Match '2 occurrence'
            $dynamicRoute['message'] | Should -Match 'line 20'
            $dynamicRoute['severity'] | Should -Be 'warning'
            $dynamicRoute['path'] | Should -Be 'src/app.ts'
            $dynamicRoute['extensions']['docs.precision-limit']['element_kind'] | Should -Be 'http-route'
            $prefix = Get-TestDiagnostic -Diagnostic @($script:ExpressOutput['Diagnostics']) -Code 'HTTP_PREFIX_DYNAMIC'
            $prefix['message'] | Should -Match '1 occurrence'
            $prefix['message'] | Should -Match 'line 19'
            $unresolved = Get-TestDiagnostic -Diagnostic @($script:ExpressOutput['Diagnostics']) -Code 'HTTP_MOUNT_UNRESOLVED'
            $unresolved['message'] | Should -Match '1 occurrence'
            $unresolved['message'] | Should -Match 'line 18'
            $unresolved['blocking'] | Should -BeFalse
            $script:ExpressOutput['Diagnostics'].Count | Should -Be 3
        }
    }

    Context 'Fastify' {
        BeforeAll {
            $script:FastifyOutput = Invoke-DocsAnalyzerTypeScriptHttp -CapturedInput @(
                (New-DocsTestCapturedInput -Path 'api/server.ts' -Text $script:FastifyAppText),
                (New-DocsTestCapturedInput -Path 'api/plugins/users.ts' -Text $script:UsersPluginText)
            ) -Selection $null
            $script:FastifyElement = @($script:FastifyOutput['Elements'])
        }

        It 'emits method calls, route objects with method arrays and url or path, and no implicit HEAD' {
            (Get-TestElement -Element $script:FastifyElement -Declaration 'GET /health')['name'] | Should -Be 'health'
            $multi = Get-TestElement -Element $script:FastifyElement -Declaration 'GET /multi'
            $multi['name'] | Should -Be 'multi'
            $multi['line_range']['start'] | Should -Be 8
            (Get-TestElement -Element $script:FastifyElement -Declaration 'POST /multi')['line_range']['end'] | Should -Be 8
            (Get-TestElement -Element $script:FastifyElement -Declaration 'PUT /alt')['name'] | Should -Be '/alt'
            @($script:FastifyElement | Where-Object { [string] $_['declaration'] -clike 'HEAD *' }).Count | Should -Be 0
        }

        It 'composes register prefixes for relative-import, fp-wrapped same-file, inline and nested plugins' {
            $users = Get-TestElement -Element $script:FastifyElement -Declaration 'GET /users'
            $users['path'] | Should -Be 'api/plugins/users.ts'
            $users['name'] | Should -Be 'listUsers'
            $users['line_range']['start'] | Should -Be 3
            Get-TestProperty -Element (Get-TestElement -Element $script:FastifyElement -Declaration 'ANY /users/catch') -Name 'framework_method' | Should -Be 'all'
            (Get-TestElement -Element $script:FastifyElement -Declaration 'POST /local/create')['line_range']['start'] | Should -Be 24
            $inline = Get-TestElement -Element $script:FastifyElement -Declaration 'GET /v1/inline'
            $inline['line_range']['start'] | Should -Be 13
            $inline['line_range']['end'] | Should -Be 13
            (Get-TestElement -Element $script:FastifyElement -Declaration 'DELETE /v1/deep/item')['name'] | Should -Be 'del'
            $dynamic = Get-TestElement -Element $script:FastifyElement -Declaration 'GET /<dynamic>'
            Get-TestProperty -Element $dynamic -Name 'prefix_resolved' | Should -BeFalse
            Get-TestProperty -Element (Get-TestElement -Element $script:FastifyElement -Declaration 'ANY /<dynamic>/catch') -Name 'prefix_resolved' | Should -BeFalse
            Get-TestDeclaration -Output $script:FastifyOutput | Should -Be @('ANY /<dynamic>/catch', 'ANY /users/catch', 'DELETE /v1/deep/item', 'GET /<dynamic>', 'GET /health', 'GET /multi', 'GET /users', 'GET /v1/inline', 'POST /local/create', 'POST /multi', 'PUT /alt')
        }

        It 'reports package plugins, require registrations, unknown plugins, dynamic prefixes and dynamic routes' {
            $unresolved = Get-TestDiagnostic -Diagnostic @($script:FastifyOutput['Diagnostics']) -Code 'HTTP_MOUNT_UNRESOLVED'
            $unresolved['message'] | Should -Match '3 occurrence'
            $unresolved['message'] | Should -Match 'line 16'
            $unresolved['extensions']['docs.precision-limit']['element_kind'] | Should -Be 'http-route'
            $prefix = Get-TestDiagnostic -Diagnostic @($script:FastifyOutput['Diagnostics']) -Code 'HTTP_PREFIX_DYNAMIC'
            $prefix['message'] | Should -Match 'line 18'
            $dynamic = Get-TestDiagnostic -Diagnostic @($script:FastifyOutput['Diagnostics']) -Code 'HTTP_DYNAMIC_ROUTE'
            $dynamic['message'] | Should -Match '2 occurrence'
            $dynamic['message'] | Should -Match 'line 19'
            $script:FastifyOutput['Diagnostics'].Count | Should -Be 3
        }
    }

    Context 'selection, bounds and duplicates' {
        It 'returns no element and no diagnostic for an empty input set, an empty file and a file without a framework import' {
            $empty = Invoke-DocsAnalyzerTypeScriptHttp -CapturedInput @() -Selection $null
            $empty['Elements'].Count | Should -Be 0
            $empty['Diagnostics'].Count | Should -Be 0
            $plain = Invoke-DocsAnalyzerTypeScriptHttp -CapturedInput @((New-DocsTestCapturedInput -Path 'x.ts' -Text ''), (New-DocsTestCapturedInput -Path 'y.ts' -Text "const app = express();`napp.get('/no-import', h);"), (New-DocsTestCapturedInput -Path 'z.tsx' -Text "import express from 'express';`nconst app = express();`napp.get('/tsx', h);")) -Selection @{ source_roots = @('src') }
            $plain['Elements'].Count | Should -Be 0
            $plain['Diagnostics'].Count | Should -Be 0
        }

        It 'reports oversize, undecodable and lexically invalid inputs as blocking and keeps other files' {
            $inputs = @(
                (New-DocsTestOversizeInput -Path 'big.ts'),
                (New-DocsTestUndecodableInput -Path 'bad.mts'),
                (New-DocsTestCapturedInput -Path 'lex.cts' -Text "import express from 'express';`nconst app = express();`napp.get('/x', h); const s = 'unterminated"),
                (New-DocsTestCapturedInput -Path 'ok.ts' -Text "import express from 'express';`nconst app = express();`napp.get('/fine', h);")
            )
            $output = Invoke-DocsAnalyzerTypeScriptHttp -CapturedInput $inputs -Selection $null
            Get-TestDeclaration -Output $output | Should -Be @('GET /fine')
            foreach ($code in @('INPUT_OVER_BOUND', 'INPUT_UNDECODABLE', 'TS_LEXICAL_INVALID')) {
                $diagnostic = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code $code
                $diagnostic['blocking'] | Should -BeTrue
                $diagnostic['extensions'].Contains('docs.precision-limit') | Should -BeFalse
            }
            (Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'INPUT_UNDECODABLE')['path'] | Should -Be 'bad.mts'
            $output['Diagnostics'].Count | Should -Be 3
        }

        It 'reports a router mounted twice under the same prefix and a repeated route as DUPLICATE_DECLARATION' {
            $text = "import express, { Router } from 'express';`nconst app = express();`nconst r = Router();`nr.get('/x', a);`nr.get('/x', b);`napp.use('/p', r);`napp.use('/p', r);"
            $output = Invoke-DocsAnalyzerTypeScriptHttp -CapturedInput @(New-DocsTestCapturedInput -Path 'dup.ts' -Text $text) -Selection $null
            Get-TestDeclaration -Output $output | Should -Be @('GET /p/x')
            (Get-TestElement -Element @($output['Elements']) -Declaration 'GET /p/x')['name'] | Should -Be 'a'
            $duplicate = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'DUPLICATE_DECLARATION'
            $duplicate['message'] | Should -Match '3 occurrence'
            $duplicate['blocking'] | Should -BeFalse
            $duplicate['extensions'].Contains('docs.precision-limit') | Should -BeFalse
        }

        It 'stops a mount cycle and resolves module.exports and exports.name routers through require' {
            $a = "const express = require('express');`nconst { b } = require('./b');`nconst a = express.Router();`na.get('/a', ha);`na.use('/to-b', b);`nmodule.exports = a;"
            $b = "const express = require('express');`nconst a = require('./a');`nconst b = express.Router();`nb.get('/b', hb);`nb.use('/to-a', a);`nexports.b = b;"
            $output = Invoke-DocsAnalyzerTypeScriptHttp -CapturedInput @((New-DocsTestCapturedInput -Path 'a.ts' -Text $a), (New-DocsTestCapturedInput -Path 'b.ts' -Text $b)) -Selection $null
            $output['Diagnostics'].Count | Should -Be 0
            Get-TestDeclaration -Output $output | Should -Be @('GET /a', 'GET /to-b/b')
            Get-TestProperty -Element (Get-TestElement -Element @($output['Elements']) -Declaration 'GET /to-b/b') -Name 'mounted' | Should -BeFalse
            Get-TestProperty -Element (Get-TestElement -Element @($output['Elements']) -Declaration 'GET /a') -Name 'mounted' | Should -BeFalse
        }

        It 'throws for a null captured-input list' {
            { Invoke-DocsAnalyzerTypeScriptHttp -CapturedInput $null -Selection $null } | Should -Throw
        }
    }
}
