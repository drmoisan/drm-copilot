#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPythonCliArgparse.psm1 (issue #1022).

.DESCRIPTION
    Covers every argparse form of spec python-cli (literal prog=, nested add_parser, long, short
    and positional add_argument, group receivers, literal required, action and help, no default
    value), the statement spans, the four argparse diagnostic rows with survival of the other
    sites, that aliases= and --help are not emitted, and a seeded property test. Inputs are
    in-memory strings.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonBindings.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonCliArgparse.psm1') -Force -ErrorAction Stop

    function Get-TestSite {
        param([string] $Text)
        $frontEnd = Get-DocsPythonFrontEnd -Text $Text
        $frontEnd['Blocked'] | Should -BeFalse -Because 'the fixture passes the front-end'
        return Get-DocsArgparseCommandSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
    }

    function Get-TestProperty {
        param([hashtable] $Site)
        [string[]] $names = @($Site['Property'].Keys | ForEach-Object { [string] $_ })
        [Array]::Sort($names, [System.StringComparer]::Ordinal)
        return (@($names | ForEach-Object { $_ + '=' + [string] $Site['Property'][$_] }) -join ';')
    }

    $script:TreeText = @(
        'import argparse'
        ''
        ''
        'def build():'
        '    parser = argparse.ArgumentParser(prog="argtool", description="d")'
        '    parser.add_argument("--verbose", "-v", action="store_true", help="Verbose output")'
        '    parser.add_argument("path")'
        '    sub = parser.add_subparsers(dest="command")'
        '    run = sub.add_parser("run", help="Run it", aliases=["r"])'
        '    run.add_argument("--count", type=int, default=3, required=False)'
        '    group = run.add_mutually_exclusive_group()'
        '    group.add_argument("--fast", action="store_true")'
        '    named = run.add_argument_group("named")'
        '    named.add_argument("-s", "--slow", required=True)'
        '    nested = run.add_subparsers()'
        '    deep = nested.add_parser("deep")'
        '    deep.add_argument("--level", "-l")'
        '    deep.add_argument('
        '        "-q",'
        '    )'
        '    return parser'
    ) -join "`n"
}

AfterAll {
    Remove-Module -Name DocsPythonCliArgparse, DocsPythonBindings, DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsArgparseCommandSite' {
    BeforeAll {
        $script:Tree = Get-TestSite -Text $script:TreeText
        $script:ByName = @{}
        foreach ($site in $script:Tree['Site']) { $script:ByName[$site['Kind'] + ':' + $site['Name']] = $site }
    }

    It 'classifies the root with a literal prog, its enclosing function and no diagnostic' {
        $script:Tree['Diagnostics'].Count | Should -Be 0
        $root = $script:ByName['root:argtool']
        $root['Id'] | Should -BeExactly 'parser'
        $root['NameSource'] | Should -BeExactly 'literal'
        $root['Attach'] | Should -BeExactly 'build'
        $root['Span'] | Should -Be @(5, 5)
        $root['ParentId'] | Should -BeNullOrEmpty
        Get-TestProperty -Site $root | Should -BeExactly 'framework=argparse'
    }

    It 'classifies nested add_parser subcommands with literal help and ignores aliases' {
        $run = $script:ByName['command:run']
        $run['ParentId'] | Should -BeExactly 'parser'
        $run['Span'] | Should -Be @(9, 9)
        Get-TestProperty -Site $run | Should -BeExactly 'framework=argparse;help=Run it'
        $deep = $script:ByName['command:deep']
        $deep['ParentId'] | Should -BeExactly 'run'
        $deep['Span'] | Should -Be @(16, 16)
        @($script:Tree['Site'] | Where-Object { $_['Name'] -ceq 'r' }).Count | Should -Be 0
        @($script:Tree['Site'] | Where-Object { $_['Kind'] -ceq 'command' }).Count | Should -Be 2
    }

    It 'classifies long, short and positional options with literal required, action and help and no default value' {
        $verbose = $script:ByName['option:--verbose']
        $verbose['ParentId'] | Should -BeExactly 'parser'
        $verbose['Span'] | Should -Be @(6, 6)
        Get-TestProperty -Site $verbose | Should -BeExactly 'action=store_true;framework=argparse;has_default=False;help=Verbose output;positional=False;short=-v'
        Get-TestProperty -Site $script:ByName['option:path'] | Should -BeExactly 'framework=argparse;has_default=False;positional=True'
        $count = $script:ByName['option:--count']
        $count['ParentId'] | Should -BeExactly 'run'
        Get-TestProperty -Site $count | Should -BeExactly 'framework=argparse;has_default=True;positional=False;required=False'
        (Get-TestProperty -Site $count) | Should -Not -Match '3'
        Get-TestProperty -Site $script:ByName['option:--level'] | Should -BeExactly 'framework=argparse;has_default=False;positional=False;short=-l'
        $script:ByName['option:-q']['Span'] | Should -Be @(18, 20)
        Get-TestProperty -Site $script:ByName['option:-q'] | Should -BeExactly 'framework=argparse;has_default=False;positional=False'
    }

    It 'maps group receivers to their parser' {
        $script:ByName['option:--fast']['ParentId'] | Should -BeExactly 'run'
        $slow = $script:ByName['option:--slow']
        $slow['ParentId'] | Should -BeExactly 'run'
        Get-TestProperty -Site $slow | Should -BeExactly 'framework=argparse;has_default=False;positional=False;required=True;short=-s'
    }

    It 'emits no --help option and no site for add_subparsers or group calls' {
        @($script:Tree['Site'] | Where-Object { $_['Name'] -ceq '--help' }).Count | Should -Be 0
        $script:Tree['Site'].Count | Should -Be 10
    }

    It 'resolves from argparse import ArgumentParser and a module-level root with Attach equal to its receiver' {
        $result = Get-TestSite -Text "from argparse import ArgumentParser as AP`nparser = AP()`nparser.add_argument('x')`n"
        $result['Site'][0]['Kind'] | Should -BeExactly 'root'
        $result['Site'][0]['Name'] | Should -BeNullOrEmpty
        $result['Site'][0]['NameSource'] | Should -BeNullOrEmpty
        $result['Site'][0]['Attach'] | Should -BeExactly 'parser'
        $result['Site'][1]['Name'] | Should -BeExactly 'x'
    }

    It 'reports CLI_DYNAMIC_REGISTRATION for a variable, an f-string and a non-literal prog while the other sites survive' {
        $result = Get-TestSite -Text "import argparse`nNAME = 'dyn'`nparser = argparse.ArgumentParser(prog='diag')`nparser.add_argument(NAME)`nparser.add_argument(f'--{NAME}')`nparser.add_argument('--fine')`nother = argparse.ArgumentParser(prog=NAME)`nsub = parser.add_subparsers()`nsub.add_parser(NAME)`n"
        $codes = @($result['Diagnostics'] | ForEach-Object { $_['Code'] })
        $codes | Should -Be @('CLI_DYNAMIC_REGISTRATION', 'CLI_DYNAMIC_REGISTRATION', 'CLI_DYNAMIC_REGISTRATION', 'CLI_DYNAMIC_REGISTRATION')
        $result['Diagnostics'][0]['Severity'] | Should -BeExactly 'warning'
        $result['Diagnostics'][0]['Blocking'] | Should -BeFalse
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(4, 5, 7, 9)
        @($result['Site'] | ForEach-Object { $_['Name'] }) | Should -Be @('diag', '--fine')
    }

    It 'reports CLI_REGISTRATION_IN_LOOP for for, while and comprehension bodies while the other sites survive' {
        $result = Get-TestSite -Text "import argparse`nparser = argparse.ArgumentParser()`nfor item in items:`n    parser.add_argument('--loop')`nwhile x:`n    sub = parser.add_subparsers()`n    sub.add_parser('w')`n[parser.add_argument(n) for n in names]`nparser.add_argument('--kept')`n"
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('CLI_REGISTRATION_IN_LOOP', 'CLI_REGISTRATION_IN_LOOP', 'CLI_REGISTRATION_IN_LOOP')
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(4, 7, 8)
        @($result['Site'] | ForEach-Object { $_['Name'] }) | Should -Be @($null, '--kept')
    }

    It 'reports CLI_UNBOUND_REGISTRATION for a parameter, an attribute and a call result and ignores receivers of other frameworks' {
        $result = Get-TestSite -Text "import argparse`nimport click`napp = click.Group()`ndef build(parser_arg):`n    parser_arg.add_argument('--unbound')`n    self.parser.add_argument('--attr')`n    argparse.ArgumentParser().add_argument('--call')`n    app.add_argument('--other')`n    sub = parser_arg.add_subparsers()`n    sub.add_parser('x')`n    parser = argparse.ArgumentParser(prog='p')`n    parser.add_argument('--kept')`n"
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('CLI_UNBOUND_REGISTRATION', 'CLI_UNBOUND_REGISTRATION', 'CLI_UNBOUND_REGISTRATION', 'CLI_UNBOUND_REGISTRATION', 'CLI_UNBOUND_REGISTRATION')
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(5, 6, 7, 9, 10)
        @($result['Site'] | ForEach-Object { $_['Name'] }) | Should -Be @('p', '--kept')
    }

    It 'reports CLI_PARENTS_UNRESOLVED on ArgumentParser and add_parser while classifying the parser itself' {
        $result = Get-TestSite -Text "import argparse`nbase = argparse.ArgumentParser(add_help=False)`nchild = argparse.ArgumentParser(prog='child', parents=[base])`nchild.add_argument('--own')`nsub = child.add_subparsers()`nleaf = sub.add_parser('leaf', parents=[base])`n"
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] }) | Should -Be @('CLI_PARENTS_UNRESOLVED', 'CLI_PARENTS_UNRESOLVED')
        @($result['Diagnostics'] | ForEach-Object { $_['Line'] }) | Should -Be @(3, 6)
        @($result['Site'] | ForEach-Object { $_['Id'] }) | Should -Be @('base', 'child', '#option-1', 'leaf')
        $result['Site'][3]['ParentId'] | Should -BeExactly 'child'
    }

    It 'returns no site and no diagnostic for an input without argparse and does not mutate the lines' {
        $frontEnd = Get-DocsPythonFrontEnd -Text "import click`n@click.command()`ndef c():`n    pass`n"
        $before = [string] (ConvertTo-Json -InputObject $frontEnd['Lines'] -Depth 6 -Compress)
        $result = Get-DocsArgparseCommandSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
        $result['Site'].Count | Should -Be 0
        $result['Diagnostics'].Count | Should -Be 0
        [string] (ConvertTo-Json -InputObject $frontEnd['Lines'] -Depth 6 -Compress) | Should -BeExactly $before
    }

    It 'property: Get-DocsArgparseCommandSite is deterministic under unrelated statement insertion' {
        $seed = 102250
        $random = [System.Random]::new($seed)
        $baseline = @((Get-TestSite -Text $script:TreeText)['Site'] | ForEach-Object { $_['Kind'] + '|' + $_['Name'] + '|' + $_['ParentId'] + '|' + (Get-TestProperty -Site $_) })
        $lines = $script:TreeText -split "`n"
        for ($iteration = 0; $iteration -lt 40; $iteration++) {
            $mutated = [System.Collections.Generic.List[string]]::new($lines)
            $insertions = $random.Next(1, 5)
            for ($i = 0; $i -lt $insertions; $i++) {
                $position = $random.Next(5, $mutated.Count)
                $indent = if ($mutated[$position - 1].StartsWith('    ') -and -not $mutated[$position - 1].EndsWith(',')) { '    ' } else { '' }
                if ($mutated[$position - 1].TrimEnd().EndsWith('(') -or $mutated[$position - 1].TrimEnd().EndsWith(',')) { continue }
                $mutated.Insert($position, $indent + 'unrelated_' + $random.Next(0, 100) + ' = ' + $random.Next(0, 100))
            }
            $text = $mutated -join "`n"
            $frontEnd = Get-DocsPythonFrontEnd -Text $text
            if ($frontEnd['Blocked']) { continue }
            $result = Get-DocsArgparseCommandSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
            $result['Diagnostics'].Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
            @($result['Site'] | ForEach-Object { $_['Kind'] + '|' + $_['Name'] + '|' + $_['ParentId'] + '|' + (Get-TestProperty -Site $_) }) | Should -Be $baseline -Because "seed $seed, iteration $iteration"
        }
    }
}
