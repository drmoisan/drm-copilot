#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPythonBindings.psm1 (issue #1022).

.DESCRIPTION
    Covers the import alias table (every import form and placement, PYTHON_IMPORT_STAR_FRAMEWORK,
    PYTHON_IMPORT_NESTED_FRAMEWORK and PYTHON_BINDING_AMBIGUOUS with survival of other bindings),
    the receiver table, definition headers (decorators, parameters, spans and the
    non-ASCII identifier mark for PYTHON_IDENTIFIER_NON_ASCII), qualified-name resolution and
    the shared Python front-end, each with a seeded property test. Inputs are in-memory strings.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonTokens.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonSyntax.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonBindings.psm1') -Force -ErrorAction Stop

    function Get-TestLine {
        param([string] $Text)
        $lexed = Get-DocsPythonToken -Text $Text
        $lexed.Diagnostics.Count | Should -Be 0 -Because 'the fixture lexes cleanly'
        $grouped = Get-DocsPythonLogicalLine -Token $lexed.Tokens
        $grouped.Diagnostics.Count | Should -Be 0 -Because 'the fixture indents cleanly'
        return $grouped.Lines
    }
}

AfterAll {
    Remove-Module -Name DocsPythonBindings, DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsPythonImportTable' {
    It 'binds every import form at indentation 0 and inside top-level branches' {
        # Arrange
        $text = @(
            'import argparse'
            'import click as c'
            'import fastapi.routing'
            'import os.path as osp'
            'from typer import Typer'
            'from flask import Flask as F, Blueprint'
            'from fastapi import ('
            '    APIRouter,'
            '    FastAPI as Api,'
            ')'
            'from . import sibling'
            'from ..pkg.mod import thing'
            'if cond:'
            '    import json'
            'else:'
            '    try:'
            '        from yaml import safe_load'
            '    except ImportError:'
            '        safe_load = None'
            'for i in x:'
            '    import csv'
        ) -join "`n"

        # Act
        $table = Get-DocsPythonImportTable -Line (Get-TestLine -Text $text)

        # Assert
        $table.Diagnostics.Count | Should -Be 0
        $table.Alias['argparse']['Full'] | Should -BeExactly 'argparse'
        $table.Alias['c']['Full'] | Should -BeExactly 'click'
        $table.Alias['fastapi']['Full'] | Should -BeExactly 'fastapi'
        $table.Alias['fastapi']['Module'] | Should -BeExactly 'fastapi.routing'
        $table.Alias['osp']['Full'] | Should -BeExactly 'os.path'
        $table.Alias['Typer']['Full'] | Should -BeExactly 'typer.Typer'
        $table.Alias['F']['Full'] | Should -BeExactly 'flask.Flask'
        $table.Alias['Blueprint']['Full'] | Should -BeExactly 'flask.Blueprint'
        $table.Alias['APIRouter']['Full'] | Should -BeExactly 'fastapi.APIRouter'
        $table.Alias['Api']['Full'] | Should -BeExactly 'fastapi.FastAPI'
        $table.Alias['sibling']['Full'] | Should -BeExactly '.sibling'
        $table.Alias['sibling']['Level'] | Should -Be 1
        $table.Alias['thing']['Full'] | Should -BeExactly '..pkg.mod.thing'
        $table.Alias['thing']['Level'] | Should -Be 2
        $table.Alias['json']['Full'] | Should -BeExactly 'json'
        $table.Alias['safe_load']['Full'] | Should -BeExactly 'yaml.safe_load'
        $table.Alias.ContainsKey('csv') | Should -BeFalse
        $table.Statements.Count | Should -Be 12
        @($table.Statements | Where-Object { $_['Module'] -ceq 'fastapi' -and $_['Kind'] -ceq 'from' })[0]['EndLine'] | Should -Be 10
        $table.Alias['Api']['Line'] | Should -Be 7
    }

    It 'reports PYTHON_IMPORT_STAR_FRAMEWORK for a framework star import and keeps other bindings' {
        $table = Get-DocsPythonImportTable -Line (Get-TestLine -Text "from click import *`nfrom os import *`nimport typer")
        $table.Diagnostics.Count | Should -Be 1
        $table.Diagnostics[0]['Code'] | Should -BeExactly 'PYTHON_IMPORT_STAR_FRAMEWORK'
        $table.Diagnostics[0]['Severity'] | Should -BeExactly 'warning'
        $table.Diagnostics[0]['Blocking'] | Should -BeFalse
        $table.Diagnostics[0]['Line'] | Should -Be 1
        $table.Star | Should -Be @('click')
        $table.Alias['typer']['Full'] | Should -BeExactly 'typer'
    }

    It 'reports PYTHON_IMPORT_NESTED_FRAMEWORK for a framework import inside a def or class body and keeps other bindings' {
        $text = "import click`ndef f():`n    import argparse`n    import os`nclass C:`n    from flask import Flask"
        $table = Get-DocsPythonImportTable -Line (Get-TestLine -Text $text)
        @($table.Diagnostics | ForEach-Object { $_['Code'] }) | Should -Be @('PYTHON_IMPORT_NESTED_FRAMEWORK', 'PYTHON_IMPORT_NESTED_FRAMEWORK')
        @($table.Diagnostics | ForEach-Object { $_['Line'] }) | Should -Be @(3, 6)
        $table.Diagnostics[0]['Blocking'] | Should -BeFalse
        $table.Alias.Count | Should -Be 1
        $table.Alias['click']['Full'] | Should -BeExactly 'click'
        @($table.Statements | Where-Object { $_['Nested'] }).Count | Should -Be 3
    }

    It 'reports PYTHON_BINDING_AMBIGUOUS for a name bound to two targets, removes it and keeps other names' {
        $table = Get-DocsPythonImportTable -Line (Get-TestLine -Text "from a import x`nfrom b import x`nfrom a import x`nfrom c import y")
        $table.Diagnostics.Count | Should -Be 1
        $table.Diagnostics[0]['Code'] | Should -BeExactly 'PYTHON_BINDING_AMBIGUOUS'
        $table.Diagnostics[0]['Name'] | Should -BeExactly 'x'
        $table.Diagnostics[0]['Line'] | Should -Be 2
        $table.Alias.ContainsKey('x') | Should -BeFalse
        $table.Ambiguous.Contains('x') | Should -BeTrue
        $table.Alias['y']['Full'] | Should -BeExactly 'c.y'
    }

    It 'keeps a repeated identical binding and distinguishes names by case' {
        $table = Get-DocsPythonImportTable -Line (Get-TestLine -Text "import click`nimport click`nfrom a import App`nfrom b import app")
        $table.Diagnostics.Count | Should -Be 0
        $table.Alias['App']['Full'] | Should -BeExactly 'a.App'
        $table.Alias['app']['Full'] | Should -BeExactly 'b.app'
    }

    It 'property: Get-DocsPythonImportTable binds each generated alias to its module and member' {
        $seed = 102240
        $random = [System.Random]::new($seed)
        $modules = @('pkg', 'pkg.sub', 'other')
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $count = $random.Next(1, 8)
            $lines = [System.Collections.Generic.List[string]]::new()
            $expected = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::Ordinal)
            for ($i = 0; $i -lt $count; $i++) {
                $module = $modules[$random.Next($modules.Length)]
                $member = "m$i"
                $bound = if ($random.Next(2) -eq 0) { "alias$i" } else { $member }
                $lines.Add("from $module import $member" + $(if ($bound -cne $member) { " as $bound" } else { '' }))
                $expected[$bound] = "$module.$member"
            }
            $table = Get-DocsPythonImportTable -Line (Get-TestLine -Text ($lines -join "`n"))
            $table.Diagnostics.Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
            $table.Alias.Count | Should -Be $expected.Count -Because "seed $seed, iteration $iteration"
            foreach ($key in $expected.Keys) { $table.Alias[$key]['Full'] | Should -BeExactly $expected[$key] -Because "seed $seed, iteration $iteration" }
        }
    }
}

Describe 'Get-DocsPythonReceiverTable' {
    It 'tracks plain and annotated constructor bindings at any indentation and ignores other statements' {
        $text = "app = FastAPI(title='x')`nrouter: APIRouter = APIRouter(prefix='/a')`ndef f():`n    sub = click.Group()`nvalue = 1`nother = g(1) + 2`nApp = Flask(__name__)"
        $table = Get-DocsPythonReceiverTable -Line (Get-TestLine -Text $text)
        $table.Diagnostics.Count | Should -Be 0
        $table.Receiver.Count | Should -Be 4
        $table.Receiver['app']['Callee'] | Should -BeExactly 'FastAPI'
        $table.Receiver['app']['Call']['Keyword']['title']['Value'] | Should -BeExactly 'x'
        $table.Receiver['router']['Callee'] | Should -BeExactly 'APIRouter'
        $table.Receiver['router']['Line'] | Should -Be 2
        $table.Receiver['sub']['Callee'] | Should -BeExactly 'click.Group'
        $table.Receiver['sub']['Nested'] | Should -BeTrue
        $table.Receiver['sub']['Indent'] | Should -Be 4
        $table.Receiver['App']['Callee'] | Should -BeExactly 'Flask'
        $table.Receiver.ContainsKey('value') | Should -BeFalse
        $table.Receiver.ContainsKey('other') | Should -BeFalse
    }

    It 'reports PYTHON_BINDING_AMBIGUOUS for a receiver bound to two different calls and keeps other receivers' {
        $text = "r = APIRouter(prefix='/a')`nr = APIRouter(prefix='/b')`nr = APIRouter(prefix='/c')`ns = Flask(__name__)`ns = Flask(__name__)"
        $table = Get-DocsPythonReceiverTable -Line (Get-TestLine -Text $text)
        $table.Diagnostics.Count | Should -Be 1
        $table.Diagnostics[0]['Code'] | Should -BeExactly 'PYTHON_BINDING_AMBIGUOUS'
        $table.Diagnostics[0]['Severity'] | Should -BeExactly 'warning'
        $table.Diagnostics[0]['Blocking'] | Should -BeFalse
        $table.Diagnostics[0]['Line'] | Should -Be 2
        $table.Receiver.ContainsKey('r') | Should -BeFalse
        $table.Ambiguous.Contains('r') | Should -BeTrue
        $table.Receiver['s']['Callee'] | Should -BeExactly 'Flask'
    }

    It 'property: Get-DocsPythonReceiverTable tracks each generated distinct receiver once' {
        $seed = 102241
        $random = [System.Random]::new($seed)
        $constructors = @('FastAPI', 'APIRouter', 'flask.Flask', 'argparse.ArgumentParser')
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $count = $random.Next(1, 8)
            $lines = [System.Collections.Generic.List[string]]::new()
            for ($i = 0; $i -lt $count; $i++) {
                $indent = '    ' * $random.Next(0, 2)
                if ($indent.Length -gt 0) { $lines.Add("if c${i}:") }
                $lines.Add($indent + "r$i = " + $constructors[$random.Next($constructors.Length)] + "(x=$i)")
            }
            $table = Get-DocsPythonReceiverTable -Line (Get-TestLine -Text ($lines -join "`n"))
            $table.Receiver.Count | Should -Be $count -Because "seed $seed, iteration $iteration"
            $table.Diagnostics.Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Get-DocsPythonDefinitionHeader' {
    It 'reads decorators, name, parameters and spans of a decorated async def' {
        # Arrange
        $text = @(
            'x = 1'
            '@app.command("run",'
            '    help="h")'
            '@other'
            'async def run_it(name: str, count: int = 3, *, flag: bool = typer.Option(False), **extra) -> None:'
            '    pass'
        ) -join "`n"
        $lines = Get-TestLine -Text $text

        # Act
        $header = Get-DocsPythonDefinitionHeader -Line $lines -Index 3

        # Assert
        $header['Kind'] | Should -BeExactly 'async def'
        $header['Name'] | Should -BeExactly 'run_it'
        $header['NameNonAscii'] | Should -BeFalse
        $header['Decorator'].Count | Should -Be 2
        $header['Decorator'][0]['Callee'] | Should -BeExactly 'app.command'
        $header['Decorator'][0]['IsCall'] | Should -BeTrue
        $header['Decorator'][0]['Call']['Positional'][0]['Value'] | Should -BeExactly 'run'
        $header['Decorator'][0]['StartLine'] | Should -Be 2
        $header['Decorator'][0]['EndLine'] | Should -Be 3
        $header['Decorator'][1]['Callee'] | Should -BeExactly 'other'
        $header['Decorator'][1]['IsCall'] | Should -BeFalse
        $header['HeaderStart'] | Should -Be 2
        $header['DefLine'] | Should -Be 5
        $header['HeaderEnd'] | Should -Be 5
        @($header['Parameter'] | ForEach-Object { $_['Name'] }) | Should -Be @('name', 'count', $null, 'flag', 'extra')
        @($header['Parameter'] | ForEach-Object { $_['Kind'] }) | Should -Be @('normal', 'normal', 'star', 'normal', 'starstar')
        @($header['Parameter'] | ForEach-Object { $_['HasDefault'] }) | Should -Be @($false, $true, $false, $true, $false)
        (@($header['Parameter'][3]['AnnotationTokens'] | ForEach-Object { $_['Text'] })) -join '' | Should -BeExactly 'bool'
        (@($header['Parameter'][3]['DefaultTokens'] | ForEach-Object { $_['Text'] })) -join '' | Should -BeExactly 'typer.Option(False)'
        $header['Parameter'][1]['StartLine'] | Should -Be 5
    }

    It 'reads a class header with bases, an undecorated def, and returns $null for other lines' {
        $lines = Get-TestLine -Text "class C(Base, metaclass=M):`n    pass`ndef f():`n    pass`nx = 1`n@d`ny = 2"
        $class = Get-DocsPythonDefinitionHeader -Line $lines -Index 0
        $class['Kind'] | Should -BeExactly 'class'
        $class['Name'] | Should -BeExactly 'C'
        (@($class['Base'] | ForEach-Object { $_['Text'] })) -join '' | Should -BeExactly 'Base,metaclass=M'
        $class['Decorator'].Count | Should -Be 0
        $def = Get-DocsPythonDefinitionHeader -Line $lines -Index 2
        $def['Kind'] | Should -BeExactly 'def'
        $def['HeaderStart'] | Should -Be 3
        $def['Parameter'].Count | Should -Be 0
        Get-DocsPythonDefinitionHeader -Line $lines -Index 4 | Should -BeNullOrEmpty
        Get-DocsPythonDefinitionHeader -Line $lines -Index 6 | Should -BeNullOrEmpty
    }

    It 'marks a non-ASCII definition or parameter name for PYTHON_IDENTIFIER_NON_ASCII and leaves ASCII names unmarked' {
        $name = 'caf' + [char]0xE9
        $lines = Get-TestLine -Text "def $name(x, $name=1):`n    pass`ndef plain(y):`n    pass"
        $header = Get-DocsPythonDefinitionHeader -Line $lines -Index 0
        $header['NameNonAscii'] | Should -BeTrue
        $header['Parameter'][0]['NonAscii'] | Should -BeFalse
        $header['Parameter'][1]['NonAscii'] | Should -BeTrue
        (Get-DocsPythonDefinitionHeader -Line $lines -Index 2)['NameNonAscii'] | Should -BeFalse
    }

    It 'spans a header whose parameters continue across lines to the colon line' {
        $lines = Get-TestLine -Text "def f(`n    a,`n    b=2,`n) -> int:`n    pass"
        $header = Get-DocsPythonDefinitionHeader -Line $lines -Index 0
        $header['HeaderEnd'] | Should -Be 4
        $header['Parameter'][0]['StartLine'] | Should -Be 2
        $header['Parameter'][1]['EndLine'] | Should -Be 3
    }

    It 'property: Get-DocsPythonDefinitionHeader recovers the generated decorators and parameter names' {
        $seed = 102242
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $decoratorCount = $random.Next(0, 4)
            $parameterCount = $random.Next(0, 5)
            $lines = [System.Collections.Generic.List[string]]::new()
            for ($i = 0; $i -lt $decoratorCount; $i++) { $lines.Add("@dec$i" + $(if ($random.Next(2) -eq 0) { '()' } else { '' })) }
            $parameters = @(if ($parameterCount -gt 0) { 1..$parameterCount | ForEach-Object { "p$_" + $(if ($random.Next(2) -eq 0) { ': int' } else { '' }) + $(if ($random.Next(2) -eq 0) { ' = 1' } else { '' }) } })
            $lines.Add('def target(' + ($parameters -join ', ') + '):')
            $lines.Add('    pass')
            $header = Get-DocsPythonDefinitionHeader -Line (Get-TestLine -Text ($lines -join "`n")) -Index $decoratorCount
            $header['Name'] | Should -BeExactly 'target' -Because "seed $seed, iteration $iteration"
            $header['Decorator'].Count | Should -Be $decoratorCount -Because "seed $seed, iteration $iteration"
            $header['HeaderStart'] | Should -Be 1 -Because "seed $seed, iteration $iteration"
            $header['DefLine'] | Should -Be ($decoratorCount + 1) -Because "seed $seed, iteration $iteration"
            @($header['Parameter'] | ForEach-Object { $_['Name'] }) | Should -Be @(if ($parameterCount -gt 0) { 1..$parameterCount | ForEach-Object { "p$_" } }) -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Resolve-DocsPythonQualifiedName' {
    It 'resolves module, member and aliased bindings, keeps unbound names and returns $null for an ambiguous name' {
        # Arrange
        $table = Get-DocsPythonImportTable -Line (Get-TestLine -Text "import argparse`nfrom click import group as g`nimport fastapi.routing`nfrom pkg.util import helper`nfrom pkg.config import helper`nfrom . import mod")

        # Act / Assert
        Resolve-DocsPythonQualifiedName -Name 'argparse.ArgumentParser' -Import $table | Should -BeExactly 'argparse.ArgumentParser'
        Resolve-DocsPythonQualifiedName -Name 'g' -Import $table | Should -BeExactly 'click.group'
        Resolve-DocsPythonQualifiedName -Name 'fastapi.APIRouter' -Import $table | Should -BeExactly 'fastapi.APIRouter'
        Resolve-DocsPythonQualifiedName -Name 'mod.router' -Import $table | Should -BeExactly '.mod.router'
        Resolve-DocsPythonQualifiedName -Name 'parser.add_argument' -Import $table | Should -BeExactly 'parser.add_argument'
        Resolve-DocsPythonQualifiedName -Name 'helper' -Import $table | Should -BeNullOrEmpty
        Resolve-DocsPythonQualifiedName -Name '' -Import $table | Should -BeExactly ''
    }

    It 'property: Resolve-DocsPythonQualifiedName replaces exactly the bound first segment' {
        $seed = 102243
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $module = 'm' + $random.Next(0, 1000)
            $member = 'f' + $random.Next(0, 1000)
            $alias = 'a' + $random.Next(0, 1000)
            $tailCount = $random.Next(0, 4)
            $tail = @(if ($tailCount -gt 0) { 1..$tailCount | ForEach-Object { 't' + $random.Next(0, 100) } })
            $table = Get-DocsPythonImportTable -Line (Get-TestLine -Text "from $module import $member as $alias")
            $suffix = if ($tail.Count -gt 0) { '.' + ($tail -join '.') } else { '' }
            Resolve-DocsPythonQualifiedName -Name ($alias + $suffix) -Import $table | Should -BeExactly ($module + '.' + $member + $suffix) -Because "seed $seed, iteration $iteration"
            Resolve-DocsPythonQualifiedName -Name ('z' + $alias + $suffix) -Import $table | Should -BeExactly ('z' + $alias + $suffix) -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Get-DocsPythonFrontEnd' {
    It 'returns lines, import and receiver tables and no diagnostic for a clean input' {
        $frontEnd = Get-DocsPythonFrontEnd -Text "import click`napp = click.Group()`n"
        $frontEnd['Blocked'] | Should -BeFalse
        $frontEnd['Diagnostics'].Count | Should -Be 0
        $frontEnd['Lines'].Count | Should -Be 2
        $frontEnd['Import']['Alias']['click']['Full'] | Should -BeExactly 'click'
        $frontEnd['Receiver']['Receiver']['app']['Callee'] | Should -BeExactly 'click.Group'
    }

    It 'blocks on a lexer diagnostic and on an indentation diagnostic with no tables' {
        $lexed = Get-DocsPythonFrontEnd -Text 'x = "open'
        $lexed['Blocked'] | Should -BeTrue
        $lexed['Diagnostics'][0]['Code'] | Should -BeExactly 'PYTHON_LEXER_UNTERMINATED'
        $lexed['Import'] | Should -BeNullOrEmpty
        $indented = Get-DocsPythonFrontEnd -Text "if a:`n        b = 1`n    c = 2"
        $indented['Blocked'] | Should -BeTrue
        $indented['Diagnostics'][0]['Code'] | Should -BeExactly 'PYTHON_INDENTATION_INVALID'
        $indented['Receiver'] | Should -BeNullOrEmpty
    }

    It 'collects the non-blocking import and receiver diagnostics without blocking' {
        $frontEnd = Get-DocsPythonFrontEnd -Text "from click import *`nfrom a import x`nfrom b import x`nr = A()`nr = B()`n"
        $frontEnd['Blocked'] | Should -BeFalse
        @($frontEnd['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('PYTHON_IMPORT_STAR_FRAMEWORK', 'PYTHON_BINDING_AMBIGUOUS', 'PYTHON_BINDING_AMBIGUOUS')
        $frontEnd['Lines'].Count | Should -Be 5
    }

    It 'property: Get-DocsPythonFrontEnd yields one logical line and one receiver per generated binding' {
        $seed = 102244
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 60; $iteration++) {
            $count = $random.Next(0, 8)
            $lines = @(if ($count -gt 0) { 1..$count | ForEach-Object { "r$_ = C$_(" + $random.Next(0, 9) + ')' } })
            $frontEnd = Get-DocsPythonFrontEnd -Text (($lines -join "`n") + $(if ($random.Next(2) -eq 0) { "`n" } else { '' }))
            $frontEnd['Blocked'] | Should -BeFalse -Because "seed $seed, iteration $iteration"
            $frontEnd['Lines'].Count | Should -Be $count -Because "seed $seed, iteration $iteration"
            $frontEnd['Receiver']['Receiver'].Count | Should -Be $count -Because "seed $seed, iteration $iteration"
            $frontEnd['Diagnostics'].Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
        }
    }
}
