#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsTypeScriptHttpSupport.psm1 (typescript-http pass 1).

.DESCRIPTION
    Covers the file scan over Express and Fastify token streams: receiver kinds, routes with
    handlers, use() and register() mounts in every supported form, export maps for default,
    named, module.exports and exports.name forms, and the pass-1 diagnostics. No file is written
    and no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsTypeScriptTokens.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsScannerCommon.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsTypeScriptHttpSupport.psm1') -Force -ErrorAction Stop

    function Get-TestScan {
        param([string] $Text, [string] $Path = 'src/a.ts', [string[]] $Captured = @('src/a.ts', 'src/b.ts', 'src/routes/items.ts'))
        $result = ConvertTo-DocsTypeScriptToken -Text $Text
        $result['Diagnostics'].Count | Should -Be 0
        $set = New-DocsScannerDiagnosticSet
        $scan = Get-DocsHttpFileScan -Tokens $result['Tokens'] -Path $Path -CapturedPath $Captured -Set $set
        $scan['Set'] = $set
        $scan
    }

    function Get-TestReceiver {
        param([hashtable] $Scan, [string] $Name)
        $found = @($Scan['Receiver'] | Where-Object { [string] $_['Name'] -ceq $Name })
        $found.Count | Should -Be 1 -Because "receiver '$Name'"
        $found[0]
    }

    function Get-TestRoute {
        param([hashtable] $Receiver)
        @($Receiver['Route'] | ForEach-Object { "$($_['Method']) $($_['Template'])" })
    }

    function Get-TestCode {
        param([hashtable] $Scan)
        @($Scan['Set'].Values | ForEach-Object { "$($_['Code']):$($_['Count'])@$($_['FirstLine'])" } | Sort-Object { $_ })
    }
}

AfterAll {
    Remove-Module -Name DocsTypeScriptHttpSupport, DocsTypeScriptHttpDeclaration, DocsTypeScriptSyntax, DocsTypeScriptTokens, DocsScannerCommon, DocsSurface, DocsJson, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsHttpFileScan' {
    It 'returns no framework for a file without express or fastify imports' {
        $scan = Get-TestScan -Text "import x from 'y';`nconst app = express();`napp.get('/a', h);"
        $scan['HasFramework'] | Should -BeFalse
        $scan['Receiver'].Count | Should -Be 0
    }

    It 'records express app and router receivers, routes, mounts and the export map' {
        # Arrange
        $text = @'
import express, { Router as R } from 'express';
import items from './routes/items';
import { other } from './b';
import pkg from 'some-package';
const app = express();
export const r1 = R();
let r2 = express.Router();
const typed: Express = express();
app.get('/a', ha).post('/b');
r1.route('/c').get(hc).put();
r2.route(dyn).get(hd);
app.use('/items', items).use(['/x', '/y'], r1).use(r2).use('/pkg', pkg).use('/m', mw(), other).use(mw()).use(dynamic, r1).use('/no-target', missing);
app.get();
export { r2 as second, app };
'@

        # Act
        $scan = Get-TestScan -Text $text

        # Assert
        $scan['HasFramework'] | Should -BeTrue
        @($scan['Receiver'] | ForEach-Object { "$($_['Name']):$($_['Kind'])" }) | Should -Be @('app:app', 'r1:router', 'r2:router', 'typed:app')
        $app = Get-TestReceiver -Scan $scan -Name 'app'
        Get-TestRoute -Receiver $app | Should -Be @('GET /a', 'POST /b')
        $app['Route'][0]['Handler'] | Should -Be 'ha'
        $app['Route'][1]['Handler'] | Should -BeNullOrEmpty
        $app['Route'][0]['FrameworkMethod'] | Should -Be 'get'
        Get-TestRoute -Receiver (Get-TestReceiver -Scan $scan -Name 'r1') | Should -Be @('GET /c', 'PUT /c')
        @(Get-TestRoute -Receiver (Get-TestReceiver -Scan $scan -Name 'r2')).Count | Should -Be 0
        @($app['Mount'] | ForEach-Object { "$($_['Prefix'])|$($_['Local'])|$($_['ImportPath'])|$($_['ImportName'])" }) | Should -Be @('/items||src/routes/items.ts|default', '/x|r1||', '/y|r1||', '|r2||', '/m||src/b.ts|other', '|r1||')
        $app['Mount'][5]['Prefix'] | Should -BeNullOrEmpty
        $scan['Export']['Default'] | Should -BeNullOrEmpty
        $scan['Export']['Named']['r1'] | Should -Be 'r1'
        $scan['Export']['Named']['second'] | Should -Be 'r2'
        $scan['Export']['Named']['app'] | Should -Be 'app'
        Get-TestCode -Scan $scan | Should -Be @('HTTP_DYNAMIC_ROUTE:2@11', 'HTTP_MOUNT_UNRESOLVED:2@12', 'HTTP_PREFIX_DYNAMIC:1@12')
    }

    It 'records fastify receivers, route objects, register forms and default exports' {
        # Arrange
        $text = @'
import fastify from 'fastify';
import fp from 'fastify-plugin';
import users from './b';
const app = fastify();
app.get('/h', h);
app.route({ method: ['get', 'POST'], url: '/m', handler: hm });
app.route({ method: 'PUT', path: '/p' });
app.route({ url: '/no-method' });
app.route(notAnObject);
app.register(users, { prefix: '/u' }).register(fp(plug)).register((i, o, d) => { i.get('/i', hi); }).register(require('x')).register(import('./y')).register(users, { prefix: p }).register(fp(users));
async function plug(f) { f.post('/plug', hp); }
export default fp(async function (f2) { f2.delete('/d', hd); });
'@

        # Act
        $scan = Get-TestScan -Text $text

        # Assert
        @($scan['Receiver'] | ForEach-Object { "$($_['Name']):$($_['Kind']):$($_['Parameter'])" }) | Should -Be @('app:app:', 'plug:plugin:f', '#default:plugin:f2', '#plugin1:plugin:i')
        $app = Get-TestReceiver -Scan $scan -Name 'app'
        Get-TestRoute -Receiver $app | Should -Be @('GET /h', 'GET /m', 'POST /m', 'PUT /p')
        $app['Route'][1]['Handler'] | Should -Be 'hm'
        @($app['Mount'] | ForEach-Object { "$($_['Prefix'])|$($_['Local'])|$($_['ImportPath'])|$($_['ImportName'])" }) | Should -Be @('/u||src/b.ts|default', '|plug||', '|#plugin1||', '||src/b.ts|default', '||src/b.ts|default')
        $app['Mount'][3]['Prefix'] | Should -BeNullOrEmpty
        Get-TestRoute -Receiver (Get-TestReceiver -Scan $scan -Name 'plug') | Should -Be @('POST /plug')
        Get-TestRoute -Receiver (Get-TestReceiver -Scan $scan -Name '#plugin1') | Should -Be @('GET /i')
        Get-TestRoute -Receiver (Get-TestReceiver -Scan $scan -Name '#default') | Should -Be @('DELETE /d')
        $scan['Export']['Default'] | Should -Be '#default'
        Get-TestCode -Scan $scan | Should -Be @('HTTP_DYNAMIC_ROUTE:2@8', 'HTTP_MOUNT_UNRESOLVED:2@10', 'HTTP_PREFIX_DYNAMIC:1@10')
    }

    It 'records default export identifiers, function declarations, arrow plugins and CommonJS exports' {
        $declared = Get-TestScan -Text "import type { FastifyInstance } from 'fastify';`nexport default async function routes(f: FastifyInstance) {`n  f.get('/r', hr);`n}`nexport async function* gen() {}`nexport function noParam() {}"
        $declared['Export']['Default'] | Should -Be 'routes'
        Get-TestRoute -Receiver (Get-TestReceiver -Scan $declared -Name 'routes') | Should -Be @('GET /r')
        $declared['Receiver'].Count | Should -Be 1
        $arrow = Get-TestScan -Text "import Fastify from 'fastify';`nexport const plugin = async (f) => {`n  f.get('/arrow', ha);`n};`nconst notPlugin = 1;`nconst a = b;`nexport default plugin;"
        $arrow['Export']['Default'] | Should -Be 'plugin'
        $arrow['Export']['Named']['plugin'] | Should -Be 'plugin'
        Get-TestRoute -Receiver (Get-TestReceiver -Scan $arrow -Name 'plugin') | Should -Be @('GET /arrow')
        $commonJs = Get-TestScan -Text "const express = require('express');`nconst r = express.Router();`nr.get('/c', hc);`nmodule.exports = r;`nexports.named = r;`nexport default (f) => { f.get('/anon', ha); };"
        $commonJs['Export']['Default'] | Should -Be '#default'
        $commonJs['Export']['Named']['named'] | Should -Be 'r'
        Get-TestRoute -Receiver (Get-TestReceiver -Scan $commonJs -Name '#default') | Should -Be @('GET /anon')
        $exportsFirst = Get-TestScan -Text "const express = require('express');`nconst r = express.Router();`nmodule.exports = r;"
        $exportsFirst['Export']['Default'] | Should -Be 'r'
    }
}
