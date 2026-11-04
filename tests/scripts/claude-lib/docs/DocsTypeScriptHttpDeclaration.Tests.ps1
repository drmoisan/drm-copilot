#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsTypeScriptHttpDeclaration.psm1 (typescript-http receiver declarations).

.DESCRIPTION
    Covers receiver creation and resolution (plugin parameters by body range before file-level
    names), function-expression receivers, fp(...) unwrapping and the declaration
    pre-pass over Express and Fastify token streams (receiver kinds, typed declarations, default,
    named, module.exports and exports.name export maps). No file is written and no process is
    started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsTypeScriptTokens.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsTypeScriptHttpDeclaration.psm1') -Force -ErrorAction Stop

    function Get-TestState {
        param([string] $Text, [string] $Framework = 'express', [string] $ExpressName = 'express', [string] $RouterName = 'Router', [string] $FastifyName = 'Fastify', [string] $FpName = 'fp')
        $result = ConvertTo-DocsTypeScriptToken -Text $Text
        $result['Diagnostics'].Count | Should -Be 0
        @{ Tokens = [object[]] $result['Tokens']; Path = 'src/a.ts'; Framework = $Framework; ExpressName = $ExpressName; RouterName = $RouterName; FastifyName = $FastifyName; FpName = $FpName; Receiver = [System.Collections.Generic.List[object]]::new(); Export = @{ Default = $null; Named = @{} } }
    }

    function Get-TestReceiverSummary {
        param([hashtable] $State)
        @($State['Receiver'] | ForEach-Object { "$($_['Name']):$($_['Kind']):$($_['Framework']):$($_['Parameter'])" })
    }
}

AfterAll {
    Remove-Module -Name DocsTypeScriptHttpDeclaration, DocsTypeScriptSyntax, DocsTypeScriptTokens, DocsScannerCommon, DocsSurface, DocsJson, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'New-DocsHttpReceiver and Resolve-DocsHttpReceiver' {
    It 'resolves the innermost plugin parameter by body range before a file-level name' {
        # Arrange
        $state = @{ Path = 'p.ts'; Receiver = [System.Collections.Generic.List[object]]::new() }
        $app = New-DocsHttpReceiver -State $state -Name 'f' -Kind 'app' -Framework 'fastify'
        $outer = New-DocsHttpReceiver -State $state -Name 'outer' -Kind 'plugin' -Framework 'fastify' -Parameter 'f' -BodyStart 10 -BodyEnd 50
        $inner = New-DocsHttpReceiver -State $state -Name 'inner' -Kind 'plugin' -Framework 'fastify' -Parameter 'f' -BodyStart 20 -BodyEnd 30
        $null = New-DocsHttpReceiver -State $state -Name 'shadow' -Kind 'plugin' -Framework 'fastify' -Parameter 'x' -BodyStart 0 -BodyEnd 5
        $null = New-DocsHttpReceiver -State $state -Name 'shadow' -Kind 'router' -Framework 'express'

        # Act / Assert
        (Resolve-DocsHttpReceiver -State $state -Name 'f' -Index 25)['Name'] | Should -Be 'inner'
        (Resolve-DocsHttpReceiver -State $state -Name 'f' -Index 40)['Name'] | Should -Be 'outer'
        (Resolve-DocsHttpReceiver -State $state -Name 'f' -Index 5)['Name'] | Should -Be 'f'
        (Resolve-DocsHttpReceiver -State $state -Name 'outer' -Index 5)['Name'] | Should -Be 'outer'
        (Resolve-DocsHttpReceiver -State $state -Name 'shadow' -Index 99)['Kind'] | Should -Be 'router'
        Resolve-DocsHttpReceiver -State $state -Name 'none' -Index 5 | Should -BeNullOrEmpty
        $app['Kind'] | Should -Be 'app'
        $outer['BodyEnd'] | Should -Be 50
        $inner['Path'] | Should -Be 'p.ts'
        $state['Receiver'].Count | Should -Be 5
    }
}

Describe 'Add-DocsHttpFunctionReceiver and Get-DocsHttpUnwrappedSpan' {
    It 'creates a plugin receiver for a function with a parameter and unwraps fp(...)' {
        $state = Get-TestState -Text "fp(async (f) => { f.get('/a'); }) (g) => 1 () => 2 fp()" -Framework 'fastify'
        $state['Tokens'][16]['Text'] | Should -Be ')'
        $unwrapped = Get-DocsHttpUnwrappedSpan -State $state -Span @{ Start = 0; End = 16 }
        $state['Tokens'][$unwrapped['Start']]['Text'] | Should -Be 'async'
        $receiver = Add-DocsHttpFunctionReceiver -State $state -Name 'p' -Span $unwrapped
        $receiver['Parameter'] | Should -Be 'f'
        $receiver['Kind'] | Should -Be 'plugin'
        $receiver['Framework'] | Should -Be 'fastify'
        $state['Tokens'][$receiver['BodyStart']]['Text'] | Should -Be '{'
        (Add-DocsHttpFunctionReceiver -State $state -Name 'q' -Span @{ Start = 17; End = 21 })['Parameter'] | Should -Be 'g'
        Add-DocsHttpFunctionReceiver -State $state -Name 'r' -Span @{ Start = 22; End = 25 } | Should -BeNullOrEmpty
        $plain = Get-DocsHttpUnwrappedSpan -State $state -Span @{ Start = 17; End = 21 }
        $plain['Start'] | Should -Be 17
        $plain['End'] | Should -Be 21
        $emptyFp = Get-DocsHttpUnwrappedSpan -State $state -Span @{ Start = 26; End = 28 }
        $emptyFp['Start'] | Should -Be 26
        $state['FpName'] = $null
        (Get-DocsHttpUnwrappedSpan -State $state -Span @{ Start = 0; End = 16 })['Start'] | Should -Be 0
    }
}

Describe 'Register-DocsHttpDeclaration' {
    It 'records express app and router declarations, typed declarations and the named export map' {
        # Arrange
        $state = Get-TestState -Text @'
const app = express();
export const r1 = Router();
let r2 = express.Router();
const typed: Express = express();
var notReceiver = other();
const value = 1;
const broken: X;
export { r2 as second, app };
export { re } from './x';
export const handler = (req) => req;
'@

        # Act
        Register-DocsHttpDeclaration -State $state

        # Assert
        Get-TestReceiverSummary -State $state | Should -Be @('app:app:express:', 'r1:router:express:', 'r2:router:express:', 'typed:app:express:', 'handler:plugin:express:req')
        $state['Export']['Default'] | Should -BeNullOrEmpty
        $state['Export']['Named']['r1'] | Should -Be 'r1'
        $state['Export']['Named']['second'] | Should -Be 'r2'
        $state['Export']['Named']['app'] | Should -Be 'app'
        $state['Export']['Named']['handler'] | Should -Be 'handler'
        $state['Export']['Named'].Count | Should -Be 4
    }

    It 'records fastify declarations, function declarations, default exports and CommonJS exports' {
        $declared = Get-TestState -Framework 'fastify' -Text "const app = Fastify();`nexport default async function routes(f: FastifyInstance) {`n  f.get('/r', hr);`n}`nexport async function* gen() {}`nexport function noParam() {}`nfunction plug(p) {}"
        Register-DocsHttpDeclaration -State $declared
        Get-TestReceiverSummary -State $declared | Should -Be @('app:app:fastify:', 'routes:plugin:fastify:f', 'plug:plugin:fastify:p')
        $declared['Export']['Default'] | Should -Be 'routes'
        $arrow = Get-TestState -Framework 'fastify' -Text "export const plugin = async (f) => {`n  f.get('/arrow', ha);`n};`nconst wrapped = fp(function (w) {});`nconst a = b;`nexport default plugin;"
        Register-DocsHttpDeclaration -State $arrow
        Get-TestReceiverSummary -State $arrow | Should -Be @('plugin:plugin:fastify:f', 'wrapped:plugin:fastify:w')
        $arrow['Export']['Default'] | Should -Be 'plugin'
        $arrow['Export']['Named']['plugin'] | Should -Be 'plugin'
        $anonymous = Get-TestState -Framework 'fastify' -Text "export default fp(async function (f2) { f2.delete('/d', hd); });"
        Register-DocsHttpDeclaration -State $anonymous
        Get-TestReceiverSummary -State $anonymous | Should -Be @('#default:plugin:fastify:f2')
        $anonymous['Export']['Default'] | Should -Be '#default'
        $arrowDefault = Get-TestState -Framework 'fastify' -Text "export default (f) => { f.get('/anon', ha); };"
        Register-DocsHttpDeclaration -State $arrowDefault
        $arrowDefault['Export']['Default'] | Should -Be '#default'
        $commonJs = Get-TestState -Text "const r = express.Router();`nmodule.exports = fp(r);`nexports.named = r;`nexports.bad = 1;`nmodule.exports = notDeclared;" -Framework 'express' -FpName 'fp'
        Register-DocsHttpDeclaration -State $commonJs
        $commonJs['Export']['Default'] | Should -Be 'notDeclared'
        $commonJs['Export']['Named']['named'] | Should -Be 'r'
        $commonJs['Export']['Named'].Count | Should -Be 1
        $noDefault = Get-TestState -Text "export default 42;`nexport default;" -Framework 'express'
        Register-DocsHttpDeclaration -State $noDefault
        $noDefault['Export']['Default'] | Should -BeNullOrEmpty
    }
}
