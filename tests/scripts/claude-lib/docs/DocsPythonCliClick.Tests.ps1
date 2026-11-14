#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPythonCliClick.psm1 (issue #1022).

.DESCRIPTION
    Covers group and command naming with the default-name suffix rule, add_command with and
    without name=, from click import command, option strings split at '/', header and decorator
    spans, the Click diagnostic rows with survival of the other sites, and a seeded property
    test over the default-name rule. Inputs are in-memory strings.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonBindings.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonCliClick.psm1') -Force -ErrorAction Stop

    function Get-TestSite {
        param([string] $Text)
        $frontEnd = Get-DocsPythonFrontEnd -Text $Text
        $frontEnd['Blocked'] | Should -BeFalse -Because 'the fixture passes the front-end'
        return Get-DocsClickCommandSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
    }

    function Get-TestProperty {
        param([hashtable] $Site)
        [string[]] $names = @($Site['Property'].Keys | ForEach-Object { [string] $_ })
        [Array]::Sort($names, [System.StringComparer]::Ordinal)
        return (@($names | ForEach-Object { $_ + '=' + [string] $Site['Property'][$_] }) -join ';')
    }

    $script:TreeText = @(
        'import click'
        'from click import command'
        ''
        ''
        '@click.group(name="main")'
        '@click.option("--debug/--no-debug", default=False, help="Debug")'
        'def cli_group():'
        '    pass'
        ''
        ''
        '@cli_group.command()'
        '@click.option("-n", "--name", required=True)'
        '@click.argument("target")'
        'def sync_command(name, target):'
        '    pass'
        ''
        ''
        '@cli_group.group("nested")'
        'def nested_grp():'
        '    pass'
        ''
        ''
        '@nested_grp.command('
        '    name="deep",'
        ')'
        'def deep_cmd():'
        '    pass'
        ''
        ''
        '@nested_grp.group()'
        'def third_group():'
        '    pass'
        ''
        ''
        '@third_group.command()'
        'def leaf_cmd():'
        '    pass'
        ''
        ''
        '@command'
        'def plain_cmd():'
        '    pass'
        ''
        ''
        '@click.command()'
        'def extra_command():'
        '    pass'
        ''
        ''
        'cli_group.add_command(plain_cmd)'
        'cli_group.add_command(extra_command, name="extra")'
    ) -join "`n"
}

AfterAll {
    Remove-Module -Name DocsPythonCliClick, DocsPythonBindings, DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsClickCommandSite' {
    BeforeAll {
        $script:Tree = Get-TestSite -Text $script:TreeText
        $script:ById = @{}
        foreach ($site in $script:Tree['Site']) { $script:ById[$site['Id']] = $site }
    }

    It 'classifies the group root with a literal name, its header span and no diagnostic' {
        $script:Tree['Diagnostics'].Count | Should -Be 0
        $root = $script:ById['cli_group']
        $root['Kind'] | Should -BeExactly 'root'
        $root['Name'] | Should -BeExactly 'main'
        $root['NameSource'] | Should -BeExactly 'literal'
        $root['IsGroup'] | Should -BeTrue
        $root['Attach'] | Should -BeExactly 'cli_group'
        $root['Span'] | Should -Be @(5, 7)
        $root['ParentId'] | Should -BeNullOrEmpty
    }

    It 'classifies commands and groups on a tracked group with default names following the suffix rule' {
        $sync = $script:ById['sync_command']
        $sync['Kind'] | Should -BeExactly 'command'
        $sync['ParentId'] | Should -BeExactly 'cli_group'
        $sync['Name'] | Should -BeNullOrEmpty
        $sync['DefaultName'] | Should -BeExactly 'sync'
        $sync['NameSource'] | Should -BeNullOrEmpty
        $sync['Span'] | Should -Be @(11, 14)
        $script:ById['nested_grp']['Name'] | Should -BeExactly 'nested'
        $script:ById['nested_grp']['DefaultName'] | Should -BeExactly 'nested'
        $script:ById['nested_grp']['Span'] | Should -Be @(18, 19)
        $deep = $script:ById['deep_cmd']
        $deep['ParentId'] | Should -BeExactly 'nested_grp'
        $deep['Name'] | Should -BeExactly 'deep'
        $deep['Span'] | Should -Be @(23, 26)
        $script:ById['third_group']['ParentId'] | Should -BeExactly 'nested_grp'
        $script:ById['third_group']['DefaultName'] | Should -BeExactly 'third'
        $script:ById['leaf_cmd']['ParentId'] | Should -BeExactly 'third_group'
        $script:ById['leaf_cmd']['DefaultName'] | Should -BeExactly 'leaf'
    }

    It 'splits option strings at the slash, records short, required, help and has_default, and spans the decorator' {
        $options = @($script:Tree['Site'] | Where-Object { $_['Kind'] -ceq 'option' })
        $options.Count | Should -Be 3
        $options[0]['Name'] | Should -BeExactly '--debug'
        $options[0]['ParentId'] | Should -BeExactly 'cli_group'
        $options[0]['Span'] | Should -Be @(6, 6)
        Get-TestProperty -Site $options[0] | Should -BeExactly 'framework=click;has_default=True;help=Debug;positional=False'
        $options[1]['Name'] | Should -BeExactly '--name'
        $options[1]['ParentId'] | Should -BeExactly 'sync_command'
        Get-TestProperty -Site $options[1] | Should -BeExactly 'framework=click;has_default=False;positional=False;required=True;short=-n'
        $options[2]['Name'] | Should -BeExactly 'target'
        Get-TestProperty -Site $options[2] | Should -BeExactly 'framework=click;has_default=False;positional=True'
    }

    It 'attaches add_command targets with and without name= and resolves from click import command' {
        $plain = $script:ById['plain_cmd']
        $plain['Kind'] | Should -BeExactly 'command'
        $plain['ParentId'] | Should -BeExactly 'cli_group'
        $plain['Name'] | Should -BeNullOrEmpty
        $plain['DefaultName'] | Should -BeExactly 'plain'
        $plain['Attach'] | Should -BeNullOrEmpty
        $plain['Span'] | Should -Be @(40, 41)
        $extra = $script:ById['extra_command']
        $extra['ParentId'] | Should -BeExactly 'cli_group'
        $extra['Name'] | Should -BeExactly 'extra'
        $extra['NameSource'] | Should -BeNullOrEmpty
        @($script:Tree['Site'] | Where-Object { $_['Kind'] -ceq 'root' }).Count | Should -Be 1
    }

    It 'reports CLI_CUSTOM_CLASS for cls= and constructed Group, Command and CommandCollection while the other sites survive' {
        $result = Get-TestSite -Text "import click`nclass CustomGroup(click.Group):`n    pass`n@click.group(cls=CustomGroup)`ndef custom():`n    pass`ncollection = click.CommandCollection(sources=[custom])`ncmd = click.Command('x')`nclick.Group('g')`n@click.command(name='ok')`ndef fine():`n    pass`n"
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('CLI_CUSTOM_CLASS', 'CLI_CUSTOM_CLASS', 'CLI_CUSTOM_CLASS', 'CLI_CUSTOM_CLASS')
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(7, 8, 9, 4)
        $result['Diagnostics'][0]['Severity'] | Should -BeExactly 'warning'
        $result['Diagnostics'][0]['Blocking'] | Should -BeFalse
        @($result['Site'] | ForEach-Object { $_['Id'] }) | Should -Be @('fine')
    }

    It 'reports CLI_DECORATOR_INDIRECT for a bound decorator name, a bound list and a decorator applied by call while the other sites survive' {
        $result = Get-TestSite -Text "import click`nshortcut = click.command`ncommon = [click.option('--a'), click.option('--b')]`n@shortcut()`ndef indirect():`n    pass`n@common`ndef listed():`n    pass`ndef wrapped():`n    pass`nwrapped = click.command()(wrapped)`n@click.command()`ndef fine():`n    pass`n"
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('CLI_DECORATOR_INDIRECT', 'CLI_DECORATOR_INDIRECT', 'CLI_DECORATOR_INDIRECT')
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(12, 4, 7)
        @($result['Site'] | ForEach-Object { $_['Id'] }) | Should -Be @('fine')
    }

    It 'reports CLI_UNBOUND_REGISTRATION for a decorator and an add_command on an untracked receiver and ignores receivers of other frameworks' {
        $result = Get-TestSite -Text "import click`nimport typer`napp = typer.Typer()`n@app.command()`ndef typer_cmd():`n    pass`n@missing.command()`ndef unbound():`n    pass`n@click.command()`ndef fine():`n    pass`ndef attach(group):`n    group.add_command(fine)`n    app.add_command(fine)`n"
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('CLI_UNBOUND_REGISTRATION', 'CLI_UNBOUND_REGISTRATION')
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(7, 14)
        @($result['Site'] | ForEach-Object { $_['Id'] }) | Should -Be @('fine')
        $result['Site'][0]['Kind'] | Should -BeExactly 'root'
    }

    It 'reports CLI_DYNAMIC_REGISTRATION for a non-literal name, option string and add_command name while the other sites survive' {
        $result = Get-TestSite -Text "import click`nNAME = 'x'`n@click.group(name=NAME)`ndef dyn():`n    pass`n@click.group()`ndef g():`n    pass`n@g.command(f'{NAME}')`ndef dyn2():`n    pass`n@g.command()`n@click.option(NAME)`n@click.option('--kept')`ndef fine():`n    pass`ng.add_command(fine, name=NAME)`n"
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('CLI_DYNAMIC_REGISTRATION', 'CLI_DYNAMIC_REGISTRATION', 'CLI_DYNAMIC_REGISTRATION', 'CLI_DYNAMIC_REGISTRATION')
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(3, 9, 13, 17)
        @($result['Site'] | ForEach-Object { $_['Id'] + ':' + $_['Name'] }) | Should -Be @('g:', 'fine:', '#option-1:--kept')
    }

    It 'reports CLI_REGISTRATION_IN_LOOP for a decorated def and an add_command inside a loop while the other sites survive' {
        $result = Get-TestSite -Text "import click`n@click.group()`ndef g():`n    pass`n@click.command(name='ok')`ndef fine():`n    pass`nfor alias in ('a', 'b'):`n    g.add_command(fine, name=alias)`n    @click.command()`n    def looped():`n        pass`n"
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('CLI_REGISTRATION_IN_LOOP', 'CLI_REGISTRATION_IN_LOOP')
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(10, 9)
        @($result['Site'] | ForEach-Object { $_['Id'] }) | Should -Be @('g', 'fine')
        $result['Site'][1]['Kind'] | Should -BeExactly 'root'
    }

    It 'reports PYTHON_IDENTIFIER_NON_ASCII for a non-ASCII function name without a literal name and keeps a literal-named one' {
        $name = 'caf' + [char]0xE9
        $result = Get-TestSite -Text "import click`n@click.command()`ndef $name():`n    pass`n@click.command(name='cafe')`ndef ${name}_2():`n    pass`n"
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('PYTHON_IDENTIFIER_NON_ASCII')
        $result['Diagnostics'][0]['Line'] | Should -Be 2
        @($result['Site'] | ForEach-Object { $_['Name'] }) | Should -Be @('cafe')
    }

    It 'returns no site and no diagnostic for an input without Click and does not mutate the lines' {
        $frontEnd = Get-DocsPythonFrontEnd -Text "import argparse`nparser = argparse.ArgumentParser()`n@other`ndef f():`n    pass`n"
        $before = [string] (ConvertTo-Json -InputObject $frontEnd['Lines'] -Depth 6 -Compress)
        $result = Get-DocsClickCommandSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
        $result['Site'].Count | Should -Be 0
        $result['Diagnostics'].Count | Should -Be 0
        [string] (ConvertTo-Json -InputObject $frontEnd['Lines'] -Depth 6 -Compress) | Should -BeExactly $before
    }

    It 'property: Get-DocsClickCommandSite default names follow the suffix rule' {
        $seed = 102251
        $random = [System.Random]::new($seed)
        $suffixes = @('_command', '_cmd', '_group', '_grp', '')
        for ($iteration = 0; $iteration -lt 60; $iteration++) {
            $segmentCount = $random.Next(1, 4)
            $segments = @(1..$segmentCount | ForEach-Object { $letters = @('a', 'B', 'c', 'D', 'e', 'F', 'x', 'Y', 'z'); (1..$random.Next(1, 5) | ForEach-Object { $letters[$random.Next($letters.Count)] }) -join '' })
            $suffix = $suffixes[$random.Next($suffixes.Count)]
            $functionName = ($segments -join '_') + $suffix
            $expected = ($segments | ForEach-Object { $_.ToLowerInvariant() }) -join '-'
            $result = Get-TestSite -Text "import click`n@click.group()`ndef root_group():`n    pass`n@root_group.command()`ndef $functionName():`n    pass`n"
            $result['Diagnostics'].Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
            $result['Site'][1]['DefaultName'] | Should -BeExactly $expected -Because "seed $seed, iteration $iteration, function $functionName"
            $result['Site'][0]['DefaultName'] | Should -BeExactly 'root' -Because "seed $seed, iteration $iteration"
        }
    }
}
