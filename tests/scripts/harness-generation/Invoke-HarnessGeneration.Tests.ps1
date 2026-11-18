Set-StrictMode -Version Latest

# Unit suite for the entry script scripts/harness-generation/Invoke-HarnessGeneration.ps1 (issue #1028).
#
# The entry script is dot-sourced, so its guard skips the process exit and Invoke-HarnessGenerationEntry is
# called directly with in-memory seams: surface providers, a reader, a lister, a reparse probe, a writer
# that records its calls and an output writer that collects the printed lines. No temporary file, process or
# network call is made.

Describe 'Invoke-HarnessGeneration.ps1 entry script' {
    BeforeAll {
        $script:EntryPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/harness-generation/Invoke-HarnessGeneration.ps1'
        . $script:EntryPath

        function New-EntryHarness {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
            param([System.Collections.IDictionary] $Files = @{}, [System.Collections.IDictionary] $Rendered = @{})
            $store = [ordered]@{}
            foreach ($key in $Files.Keys) { $store[$key] = $Files[$key] }
            $map = [ordered]@{}
            foreach ($key in $Rendered.Keys) { $map[$key] = $Rendered[$key] }
            $lines = [System.Collections.Generic.List[string]]::new()
            $writes = [System.Collections.Generic.List[string]]::new()
            $calls = [System.Collections.Generic.List[string]]::new()
            $providers = @{}
            foreach ($name in @('instructions', 'mcp', 'skills', 'rules', 'agents')) {
                $surfaceName = $name
                $providers[$name] = { $calls.Add($surfaceName); [pscustomobject]@{ Files = $(if ($surfaceName -eq 'mcp') { $map } else { [ordered]@{} }); ManagedFolders = @(); Findings = @() } }.GetNewClosure()
            }
            return [pscustomobject]@{
                Store       = $store
                Lines       = $lines
                Writes      = $writes
                Calls       = $calls
                Providers   = $providers
                ReadFile    = { param([string] $Path) if ($store.Contains($Path)) { $store[$Path] } else { $null } }.GetNewClosure()
                ListFiles   = { @() }
                TestReparse = { $false }
                WriteFile   = { param([string] $Path, [string] $Text) $writes.Add($Path); $store[$Path] = $Text }.GetNewClosure()
                Output      = { param([string] $Line) $lines.Add($Line) }.GetNewClosure()
            }
        }

        function Invoke-Entry {
            param([pscustomobject] $Harness, [string] $Surface, [switch] $Check)
            return Invoke-HarnessGenerationEntry -Surface $Surface -Check:$Check -Root 'fake-root' -Providers $Harness.Providers `
                -ReadFile $Harness.ReadFile -ListFiles $Harness.ListFiles -TestReparse $Harness.TestReparse -WriteFile $Harness.WriteFile -OutputWriter $Harness.Output
        }
    }

    AfterAll {
        Remove-Module -Name HarnessGeneration -Force -ErrorAction SilentlyContinue
    }

    It 'exits 0 and prints the no-drift line when check mode finds nothing' {
        $harness = New-EntryHarness -Files @{ '.mcp.json' = "{}`n" } -Rendered @{ '.mcp.json' = "{}`n" }
        Invoke-Entry -Harness $harness -Surface 'mcp' -Check | Should -Be 0
        $harness.Lines.ToArray() | Should -Be @('harness-generation: no drift')
        $harness.Writes.Count | Should -Be 0
    }

    It 'exits 1 and prints one line per drifted path in check mode' {
        $harness = New-EntryHarness -Files @{ '.mcp.json' = "old`n" } -Rendered @{ '.mcp.json' = "new`n" }
        Invoke-Entry -Harness $harness -Surface 'mcp' -Check | Should -Be 1
        $harness.Lines[0] | Should -BeExactly 'DRIFT .mcp.json (content differs)'
        $harness.Writes.Count | Should -Be 0
    }

    It 'writes the rendered targets without -Check and exits 0' {
        $harness = New-EntryHarness -Files @{ '.mcp.json' = "old`n" } -Rendered @{ '.mcp.json' = "new`n" }
        Invoke-Entry -Harness $harness -Surface 'mcp' | Should -Be 0
        $harness.Writes.ToArray() | Should -Be @('.mcp.json')
        $harness.Store['.mcp.json'] | Should -BeExactly "new`n"
    }

    It 'passes -Surface through, so only the named surface runs' {
        $harness = New-EntryHarness
        $null = Invoke-Entry -Harness $harness -Surface 'rules' -Check
        $harness.Calls.ToArray() | Should -Be @('rules')
    }

    It 'runs every surface for all' {
        $harness = New-EntryHarness
        Invoke-Entry -Harness $harness -Surface 'all' -Check | Should -Be 0
        $harness.Calls.ToArray() | Should -Be @('instructions', 'mcp', 'skills', 'rules', 'agents')
    }

    It 'rejects instructions without -Check with exit 2 and runs no surface' {
        $harness = New-EntryHarness
        Invoke-Entry -Harness $harness -Surface 'instructions' | Should -Be 2
        $harness.Lines[0] | Should -BeLike "ERROR: surface 'instructions' is check-only*"
        $harness.Calls.Count | Should -Be 0
    }

    It 'accepts instructions with -Check' {
        $harness = New-EntryHarness
        Invoke-Entry -Harness $harness -Surface 'instructions' -Check | Should -Be 0
        $harness.Calls.ToArray() | Should -Be @('instructions')
    }

    It 'prints through the information stream when no output writer is injected' {
        Mock Write-Information { }
        $harness = New-EntryHarness
        Invoke-HarnessGenerationEntry -Surface 'rules' -Check -Root 'fake-root' -Providers $harness.Providers -ReadFile $harness.ReadFile -ListFiles $harness.ListFiles -TestReparse $harness.TestReparse | Should -Be 0
        Should -Invoke Write-Information -Times 1 -Exactly -ParameterFilter { $MessageData -eq 'harness-generation: no drift' }
    }

    It 'exits 1 with the source path and writes nothing when a source is malformed' {
        $harness = New-EntryHarness -Rendered @{ '.mcp.json' = "x`n" }
        $harness.Providers['skills'] = { throw "Malformed source 'sources/skills/bad.substitutions.json'." }
        Invoke-Entry -Harness $harness -Surface 'all' | Should -Be 1
        $harness.Lines[0] | Should -BeLike '*sources/skills/bad.substitutions.json*'
        $harness.Writes.Count | Should -Be 0
    }
}
