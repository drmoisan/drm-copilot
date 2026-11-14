<#
.SYNOPSIS
    Pester tests for the executable resolution and process start spec of
    .claude/lib/regeneration/Invoke-RegenerationPath.ps1 (issue #1156, finding R2).

.DESCRIPTION
    Get-RegenerationProcessStartSpec is pure and is called with literal resolved
    paths and literal ComSpec values. Resolve-RegenerationExecutable is called with
    injected -Resolver scriptblocks. The Invoke-RegenerationProcessStep cases mock
    the resolution or the spec to throw, so the default invoker stops before any
    process start. No process, file, PATH read, or environment write is used.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Resolver stubs mirror the production -Resolver signature.')]
param()

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../../.claude/lib/regeneration/Invoke-RegenerationPath.ps1')
    $script:ComSpecPath = '/windows/system32/cmd.exe'
}

Describe 'Get-RegenerationProcessStartSpec' {
    It 'starts <Path> directly with the arguments unchanged' -ForEach @(
        @{ Path = '/opt/tools/gen.exe' },
        @{ Path = '/opt/tools/gen' }
    ) {
        $spec = Get-RegenerationProcessStartSpec -ResolvedPath $Path -ArgumentList @('run', 'a b', '--x="1"') -ComSpec $script:ComSpecPath
        $spec.FileName | Should -BeExactly $Path
        $spec.ArgumentList -join '|' | Should -BeExactly 'run|a b|--x="1"'
    }

    It 'starts a direct path with an empty argument list as an empty list' {
        $spec = Get-RegenerationProcessStartSpec -ResolvedPath '/opt/tools/gen' -ArgumentList @() -ComSpec $null
        $spec.FileName | Should -BeExactly '/opt/tools/gen'
        @($spec.ArgumentList).Count | Should -Be 0
    }

    It 'routes <Path> through ComSpec with /d, /c, the path, then each argument in order' -ForEach @(
        @{ Path = '/opt/node/npm.cmd' },
        @{ Path = '/opt/node/BUILD.BAT' }
    ) {
        $spec = Get-RegenerationProcessStartSpec -ResolvedPath $Path -ArgumentList @('run', 'gen', '--force') -ComSpec $script:ComSpecPath
        $spec.FileName | Should -BeExactly $script:ComSpecPath
        $spec.ArgumentList -join '|' | Should -BeExactly "/d|/c|$Path|run|gen|--force"
    }

    It 'keeps a batch path containing a space as one item' {
        $spec = Get-RegenerationProcessStartSpec -ResolvedPath '/opt/node js/npm.cmd' -ArgumentList @('--version') -ComSpec $script:ComSpecPath
        @($spec.ArgumentList).Count | Should -Be 4
        $spec.ArgumentList[2] | Should -BeExactly '/opt/node js/npm.cmd'
    }

    It 'throws for a <Label> ComSpec on a batch path' -ForEach @(
        @{ Label = 'null'; Value = $null },
        @{ Label = 'empty'; Value = '' }
    ) {
        { Get-RegenerationProcessStartSpec -ResolvedPath '/opt/node/npm.cmd' -ArgumentList @('x') -ComSpec $Value } |
            Should -Throw -ExpectedMessage '*ComSpec is not set*'
    }

    It 'throws for a batch argument holding <Label>' -ForEach @(
        @{ Label = 'a space'; Argument = 'a b' },
        @{ Label = 'a double quote'; Argument = 'say"hi' },
        @{ Label = 'an ampersand'; Argument = 'a&b' }
    ) {
        { Get-RegenerationProcessStartSpec -ResolvedPath '/opt/node/npm.cmd' -ArgumentList @('ok', $Argument) -ComSpec $script:ComSpecPath } |
            Should -Throw -ExpectedMessage '*cmd.exe metacharacter*'
    }
}

Describe 'Resolve-RegenerationExecutable' {
    It 'returns the path the resolver returns' {
        Resolve-RegenerationExecutable -Name 'npm' -Resolver { param($Name) "/opt/node/$Name.cmd" } | Should -BeExactly '/opt/node/npm.cmd'
    }

    It 'passes Name to the resolver unchanged' {
        $seen = [System.Collections.Generic.List[string]]::new()
        $resolver = { param($Name) $seen.Add($Name); '/opt/tools/x' }.GetNewClosure()
        $null = Resolve-RegenerationExecutable -Name 'poetry.EXE' -Resolver $resolver
        $seen -join '|' | Should -BeExactly 'poetry.EXE'
    }

    It 'throws cannot be resolved for a <Label> resolver result' -ForEach @(
        @{ Label = 'null'; Result = $null },
        @{ Label = 'empty'; Result = '' }
    ) {
        $resolver = { param($Name) $Result }.GetNewClosure()
        { Resolve-RegenerationExecutable -Name 'missing-tool' -Resolver $resolver } |
            Should -Throw -ExpectedMessage 'executable missing-tool cannot be resolved'
    }
}

Describe 'Invoke-RegenerationProcessStep with the default invoker' {
    It 'returns Started false and a null ExitCode when the executable cannot be resolved' {
        Mock Resolve-RegenerationExecutable { throw "executable $Name cannot be resolved" }
        Mock Get-RegenerationProcessStartSpec { throw 'not reached' }
        $run = Invoke-RegenerationProcessStep -Argv @('missing-tool', '--version')
        $run.Started | Should -BeFalse
        $run.ExitCode | Should -BeNullOrEmpty
        Should -Invoke Resolve-RegenerationExecutable -Times 1 -Exactly -ParameterFilter { $Name -ceq 'missing-tool' }
        Should -Invoke Get-RegenerationProcessStartSpec -Times 0 -Exactly
    }

    It 'returns Started false when the start spec refuses a batch argument' {
        Mock Resolve-RegenerationExecutable { '/opt/node/npm.cmd' }
        Mock Get-RegenerationProcessStartSpec { throw 'refused' }
        $run = Invoke-RegenerationProcessStep -Argv @('npm', 'a b')
        $run.Started | Should -BeFalse
        $run.ExitCode | Should -BeNullOrEmpty
        Should -Invoke Get-RegenerationProcessStartSpec -Times 1 -Exactly -ParameterFilter {
            $ResolvedPath -ceq '/opt/node/npm.cmd' -and ($ArgumentList -join '|') -ceq 'a b'
        }
    }
}
