#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPythonCliTyper.psm1 (issue #1022).

.DESCRIPTION
    Covers explicit and default command names, add_typer subgroups, callbacks, typer.run
    targets, annotated and plain parameters (typer.Option and typer.Argument as a default or
    inside Annotated[...], plain default, no default), the absence of a --no-x element, Typer
    parameter spans, the Typer diagnostic rows with survival of the other sites, and a seeded
    property test over default names. Inputs are in-memory strings.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonBindings.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonCliTyper.psm1') -Force -ErrorAction Stop

    function Get-TestSite {
        param([string] $Text)
        $frontEnd = Get-DocsPythonFrontEnd -Text $Text
        $frontEnd['Blocked'] | Should -BeFalse -Because 'the fixture passes the front-end'
        return Get-DocsTyperCommandSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
    }

    function Get-TestProperty {
        param([hashtable] $Site)
        [string[]] $names = @($Site['Property'].Keys | ForEach-Object { [string] $_ })
        [Array]::Sort($names, [System.StringComparer]::Ordinal)
        return (@($names | ForEach-Object { $_ + '=' + [string] $Site['Property'][$_] }) -join ';')
    }

    $script:TreeText = @(
        'import typer'
        'from typing import Annotated'
        'from typer import Option as Opt'
        ''
        'app = typer.Typer(name="typ")'
        'sub = typer.Typer()'
        'app.add_typer(sub, name="sub")'
        ''
        ''
        '@app.callback()'
        'def main_callback(verbose: bool = False):'
        '    pass'
        ''
        ''
        '@app.command()'
        'def run_task('
        '    name: str,'
        '    count: int = 3,'
        '    flag: bool = typer.Option(False, "--flag", "-f", help="Flag it"),'
        '    tag: Annotated[str, typer.Option()] = "x",'
        '    pick: Annotated[str, Opt("--pick", "-p")] = "y",'
        '    rest: list[str] = [],'
        '    none: str = typer.Option(..., "--none"),'
        '):'
        '    pass'
        ''
        ''
        '@app.command("explicit-name")'
        'def other():'
        '    pass'
        ''
        ''
        '@sub.command()'
        'def inner_thing(item: Annotated[str, typer.Argument()], second: str = typer.Argument("s")):'
        '    pass'
        ''
        ''
        'def standalone(value: int = 1):'
        '    pass'
        ''
        ''
        'typer.run(standalone)'
    ) -join "`n"
}

AfterAll {
    Remove-Module -Name DocsPythonCliTyper, DocsPythonBindings, DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsTyperCommandSite' {
    BeforeAll {
        $script:Tree = Get-TestSite -Text $script:TreeText
        $script:ById = @{}
        foreach ($site in $script:Tree['Site']) { $script:ById[$site['Id']] = $site }
        $script:Options = @($script:Tree['Site'] | Where-Object { $_['Kind'] -ceq 'option' })
    }

    It 'classifies the Typer root with a literal name, the add_typer subgroup and no diagnostic' {
        $script:Tree['Diagnostics'].Count | Should -Be 0
        $root = $script:ById['app']
        $root['Kind'] | Should -BeExactly 'root'
        $root['Name'] | Should -BeExactly 'typ'
        $root['NameSource'] | Should -BeExactly 'literal'
        $root['Span'] | Should -Be @(5, 5)
        $root['Attach'] | Should -BeExactly 'app'
        $sub = $script:ById['sub']
        $sub['Kind'] | Should -BeExactly 'command'
        $sub['ParentId'] | Should -BeExactly 'app'
        $sub['Name'] | Should -BeExactly 'sub'
        $sub['Span'] | Should -Be @(7, 7)
        $sub['Attach'] | Should -BeNullOrEmpty
    }

    It 'classifies explicit and default command names with header spans' {
        $run = $script:ById['run_task']
        $run['Kind'] | Should -BeExactly 'command'
        $run['ParentId'] | Should -BeExactly 'app'
        $run['Name'] | Should -BeNullOrEmpty
        $run['DefaultName'] | Should -BeExactly 'run-task'
        $run['Span'] | Should -Be @(15, 24)
        $script:ById['other']['Name'] | Should -BeExactly 'explicit-name'
        $script:ById['other']['Span'] | Should -Be @(28, 29)
        $script:ById['inner_thing']['ParentId'] | Should -BeExactly 'sub'
        $script:ById['inner_thing']['DefaultName'] | Should -BeExactly 'inner-thing'
    }

    It 'turns callback parameters into root options and declares --x only for a boolean' {
        $verbose = @($script:Options | Where-Object { $_['Name'] -ceq '--verbose' })
        $verbose.Count | Should -Be 1
        $verbose[0]['ParentId'] | Should -BeExactly 'app'
        $verbose[0]['Span'] | Should -Be @(11, 11)
        Get-TestProperty -Site $verbose[0] | Should -BeExactly 'framework=typer;has_default=True;positional=False'
        @($script:Options | Where-Object { $_['Name'] -clike '--no-*' }).Count | Should -Be 0
    }

    It 'classifies annotated and plain parameters with spans, short, help and has_default' {
        $byName = @{}
        foreach ($option in @($script:Options | Where-Object { $_['ParentId'] -ceq 'run_task' })) { $byName[$option['Name']] = $option }
        @($byName.Keys | Sort-Object) | Should -Be @('--count', '--flag', '--none', '--pick', '--rest', '--tag', 'name')
        Get-TestProperty -Site $byName['name'] | Should -BeExactly 'framework=typer;has_default=False;positional=True'
        $byName['name']['Span'] | Should -Be @(17, 17)
        Get-TestProperty -Site $byName['--count'] | Should -BeExactly 'framework=typer;has_default=True;positional=False'
        Get-TestProperty -Site $byName['--flag'] | Should -BeExactly 'framework=typer;has_default=True;help=Flag it;positional=False;short=-f'
        $byName['--flag']['Span'] | Should -Be @(19, 19)
        Get-TestProperty -Site $byName['--tag'] | Should -BeExactly 'framework=typer;has_default=True;positional=False'
        Get-TestProperty -Site $byName['--pick'] | Should -BeExactly 'framework=typer;has_default=True;positional=False;short=-p'
        Get-TestProperty -Site $byName['--rest'] | Should -BeExactly 'framework=typer;has_default=True;positional=False'
        Get-TestProperty -Site $byName['--none'] | Should -BeExactly 'framework=typer;has_default=False;positional=False'
        $inner = @($script:Options | Where-Object { $_['ParentId'] -ceq 'inner_thing' })
        @($inner | ForEach-Object { $_['Name'] }) | Should -Be @('item', 'second')
        Get-TestProperty -Site $inner[0] | Should -BeExactly 'framework=typer;has_default=False;positional=True'
        Get-TestProperty -Site $inner[1] | Should -BeExactly 'framework=typer;has_default=True;positional=True'
        (Get-TestProperty -Site $byName['--count']) | Should -Not -Match '3'
    }

    It 'classifies a typer.run target as a root spanning its def with its parameters as options' {
        $standalone = $script:ById['standalone']
        $standalone['Kind'] | Should -BeExactly 'root'
        $standalone['Name'] | Should -BeNullOrEmpty
        $standalone['NameSource'] | Should -BeNullOrEmpty
        $standalone['Span'] | Should -Be @(38, 38)
        $standalone['Attach'] | Should -BeExactly 'standalone'
        $value = @($script:Options | Where-Object { $_['ParentId'] -ceq 'standalone' })
        $value.Count | Should -Be 1
        $value[0]['Name'] | Should -BeExactly '--value'
        $value[0]['Span'] | Should -Be @(38, 38)
    }

    It 'reports CLI_TYPER_PARAMETER_UNRESOLVED for a call, an attribute and a nested call default while the other parameters survive' {
        $result = Get-TestSite -Text "import typer`napp = typer.Typer(name='t')`n@app.command()`ndef unresolved(value: dict = make_default(), attr: str = settings.x, wrapped: str = str(typer.Option('x')), other: str = 's'):`n    pass`n"
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('CLI_TYPER_PARAMETER_UNRESOLVED', 'CLI_TYPER_PARAMETER_UNRESOLVED', 'CLI_TYPER_PARAMETER_UNRESOLVED')
        $result['Diagnostics'][0]['Severity'] | Should -BeExactly 'warning'
        $result['Diagnostics'][0]['Blocking'] | Should -BeFalse
        $result['Diagnostics'][0]['Line'] | Should -Be 4
        @($result['Site'] | ForEach-Object { $_['Kind'] + ':' + $_['Name'] }) | Should -Be @('root:t', 'command:', 'option:--other')
    }

    It 'reports CLI_CUSTOM_CLASS for cls= on the constructor and on a command decorator while the other sites survive' {
        $result = Get-TestSite -Text "import typer`nclass MyTyper(typer.Typer):`n    pass`ncustom = typer.Typer(name='custom', cls=MyTyper)`napp = typer.Typer(name='tdiag')`n@app.command(cls=MyTyper)`ndef special():`n    pass`n@app.command()`ndef fine():`n    pass`n"
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('CLI_CUSTOM_CLASS', 'CLI_CUSTOM_CLASS')
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(4, 6)
        @($result['Site'] | ForEach-Object { $_['Id'] }) | Should -Be @('app', 'fine')
    }

    It 'reports CLI_DYNAMIC_REGISTRATION for a non-literal Typer name, command name and add_typer name while the other sites survive' {
        $result = Get-TestSite -Text "import typer`nNAME = 'x'`ndyn = typer.Typer(name=NAME)`napp = typer.Typer(name='a')`nsub = typer.Typer()`n@app.command(NAME)`ndef dyn_cmd():`n    pass`napp.add_typer(sub, name=NAME)`n@app.command()`ndef fine():`n    pass`n"
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('CLI_DYNAMIC_REGISTRATION', 'CLI_DYNAMIC_REGISTRATION', 'CLI_DYNAMIC_REGISTRATION')
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(3, 6, 9)
        @($result['Site'] | ForEach-Object { $_['Id'] + ':' + $_['Kind'] }) | Should -Be @('app:root', 'sub:root', 'fine:command')
    }

    It 'reports CLI_UNBOUND_REGISTRATION for a decorator and an add_typer on an untracked receiver and ignores receivers of other frameworks' {
        $result = Get-TestSite -Text "import typer`nimport click`ncli = click.Group()`napp = typer.Typer(name='a')`n@missing.command()`ndef unbound():`n    pass`n@cli.command()`ndef click_cmd():`n    pass`ndef attach(parent):`n    parent.add_typer(app, name='x')`n    cli.add_typer(app, name='y')`n@app.command()`ndef fine():`n    pass`n@click.command()`ndef imported_decorator():`n    pass`n"
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('CLI_UNBOUND_REGISTRATION', 'CLI_UNBOUND_REGISTRATION')
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(5, 12)
        @($result['Site'] | ForEach-Object { $_['Id'] }) | Should -Be @('app', 'fine')
    }

    It 'reports CLI_REGISTRATION_IN_LOOP for a constructor, a decorated def, an add_typer and a typer.run inside a loop while the other sites survive' {
        $result = Get-TestSite -Text "import typer`napp = typer.Typer(name='a')`nsub = typer.Typer(name='s')`ndef target():`n    pass`nfor i in x:`n    looped = typer.Typer(name='l')`n    app.add_typer(sub, name='n')`n    typer.run(target)`n    @app.command()`n    def inner():`n        pass`n@app.command()`ndef fine():`n    pass`n"
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('CLI_REGISTRATION_IN_LOOP', 'CLI_REGISTRATION_IN_LOOP', 'CLI_REGISTRATION_IN_LOOP', 'CLI_REGISTRATION_IN_LOOP')
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(7, 8, 9, 10)
        @($result['Site'] | ForEach-Object { $_['Id'] + ':' + $_['Kind'] }) | Should -Be @('app:root', 'sub:root', 'fine:command')
    }

    It 'reports PYTHON_IDENTIFIER_NON_ASCII for a non-ASCII command function, typer.run target and parameter name' {
        $name = 'caf' + [char]0xE9
        $result = Get-TestSite -Text "import typer`napp = typer.Typer(name='a')`n@app.command()`ndef $name():`n    pass`n@app.command('named')`ndef ${name}_2(${name}_p: int = 1, fine: int = 2):`n    pass`ndef ${name}_3():`n    pass`ntyper.run(${name}_3)`n"
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('PYTHON_IDENTIFIER_NON_ASCII', 'PYTHON_IDENTIFIER_NON_ASCII', 'PYTHON_IDENTIFIER_NON_ASCII')
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(3, 7, 9)
        @($result['Site'] | ForEach-Object { $_['Name'] }) | Should -Be @('a', 'named', '--fine')
    }

    It 'returns no site and no diagnostic for an input without Typer and does not mutate the lines' {
        $frontEnd = Get-DocsPythonFrontEnd -Text "import click`n@click.command()`ndef c(x: int = 1):`n    pass`n"
        $before = [string] (ConvertTo-Json -InputObject $frontEnd['Lines'] -Depth 6 -Compress)
        $result = Get-DocsTyperCommandSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
        $result['Site'].Count | Should -Be 0
        $result['Diagnostics'].Count | Should -Be 0
        [string] (ConvertTo-Json -InputObject $frontEnd['Lines'] -Depth 6 -Compress) | Should -BeExactly $before
    }

    It 'property: Get-DocsTyperCommandSite default names are lower-cased and hyphenated' {
        $seed = 102252
        $random = [System.Random]::new($seed)
        $letters = @('a', 'B', 'c', 'D', 'e', 'F', 'x', 'Y', 'z')
        for ($iteration = 0; $iteration -lt 60; $iteration++) {
            $segmentCount = $random.Next(1, 4)
            $segments = @(1..$segmentCount | ForEach-Object { (1..$random.Next(1, 5) | ForEach-Object { $letters[$random.Next($letters.Count)] }) -join '' })
            $functionName = $segments -join '_'
            $parameterName = ($segments | ForEach-Object { $_ + 'p' }) -join '_'
            $result = Get-TestSite -Text "import typer`napp = typer.Typer()`n@app.command()`ndef $functionName(${parameterName}: int = 0):`n    pass`n"
            $result['Diagnostics'].Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
            $result['Site'][1]['DefaultName'] | Should -BeExactly (($segments | ForEach-Object { $_.ToLowerInvariant() }) -join '-') -Because "seed $seed, iteration $iteration, function $functionName"
            $result['Site'][2]['Name'] | Should -BeExactly ('--' + $parameterName.Replace('_', '-')) -Because "seed $seed, iteration $iteration"
        }
    }
}
