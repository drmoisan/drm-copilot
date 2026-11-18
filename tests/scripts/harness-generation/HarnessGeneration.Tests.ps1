Set-StrictMode -Version Latest

# Unit suite for scripts/harness-generation/HarnessGeneration.psm1 (issue #1028).
#
# Every case runs against an in-memory file system: a dictionary of repository-relative POSIX paths to text,
# a set of reparse-point paths, and a writer that records its calls. The default file-system seams are covered
# by read-only reads of files that already exist in this repository and by mocked cmdlets for the writer.
# No temporary file, process or network call is made.

Describe 'HarnessGeneration module' {
    BeforeAll {
        $script:ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/harness-generation/HarnessGeneration.psm1'
        Import-Module $script:ModulePath -Force
        $script:RepoRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../..'))

        function New-FakeTree {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
            param([System.Collections.IDictionary] $Files = @{}, [string[]] $Reparse = @())
            $store = [ordered]@{}
            foreach ($key in $Files.Keys) { $store[$key] = $Files[$key] }
            $reparseSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$Reparse, [System.StringComparer]::Ordinal)
            $writes = [System.Collections.Generic.List[string]]::new()
            $context = New-HarnessGenerationContext -Root 'fake-root' `
                -ReadFile { param([string] $Path) if ($store.Contains($Path)) { $store[$Path] } else { $null } }.GetNewClosure() `
                -ListFiles { param([string] $Folder) @($store.Keys | Where-Object { $_.StartsWith("$Folder/") }) }.GetNewClosure() `
                -TestReparse { param([string] $Path) $reparseSet.Contains($Path) }.GetNewClosure()
            $writer = { param([string] $Path, [string] $Text) $writes.Add($Path); $store[$Path] = $Text }.GetNewClosure()
            return [pscustomobject]@{ Store = $store; Writes = $writes; Context = $context; Writer = $writer }
        }

        function New-FakeProvider {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
            param([System.Collections.IDictionary] $Files = @{}, [string[]] $Managed = @(), [object[]] $Findings = @())
            $map = [ordered]@{}
            foreach ($key in $Files.Keys) { $map[$key] = $Files[$key] }
            $managedFolders = $Managed
            $surfaceFindings = $Findings
            # The provider receives the generation context as its first argument and does not need it.
            return { [pscustomobject]@{ Files = $map; ManagedFolders = $managedFolders; Findings = $surfaceFindings } }.GetNewClosure()
        }
    }

    AfterAll {
        Remove-Module -Name HarnessGeneration -Force -ErrorAction SilentlyContinue
    }

    Context 'Get-HarnessMatrixSelection' {
        BeforeAll {
            $script:Matrix = [pscustomobject]@{ features = @(
                    [pscustomobject]@{ id = 'claude:skill:a'; ecosystem = 'claude'; kind = 'skill'; disposition = 'generated'; owner_child = 3 }
                    [pscustomobject]@{ id = 'claude:skill:b'; ecosystem = 'claude'; kind = 'skill'; disposition = 'native'; owner_child = 3 }
                    [pscustomobject]@{ id = 'codex:skill:a'; ecosystem = 'codex'; kind = 'skill'; disposition = 'generated'; owner_child = 3 }
                    [pscustomobject]@{ id = 'claude:agent:c'; ecosystem = 'claude'; kind = 'agent'; disposition = 'generated'; owner_child = 4 }
                    [pscustomobject]@{ id = 'claude:skill:generated:3'; ecosystem = 'claude'; kind = 'skill'; disposition = 'shared'; owner_child = $null }
                ) }
        }

        It 'selects by ecosystem, kind, disposition and owner_child' {
            $ids = @(Get-HarnessMatrixSelection -Matrix $script:Matrix -Ecosystem 'claude' -Kind 'skill' -Disposition 'generated' -OwnerChild 3 | ForEach-Object id)
            $ids | Should -Be @('claude:skill:a')
        }

        It 'never selects a native entry for a generated selection' {
            $ids = @(Get-HarnessMatrixSelection -Matrix $script:Matrix -Disposition 'generated' | ForEach-Object id)
            $ids | Should -Not -Contain 'claude:skill:b'
            $ids.Count | Should -Be 3
        }

        It 'decides by fields only and never by the id text' {
            $ids = @(Get-HarnessMatrixSelection -Matrix $script:Matrix -Kind 'skill' -OwnerChild 3 | ForEach-Object id)
            $ids | Should -Not -Contain 'claude:skill:generated:3' -Because 'owner_child is null although the id names 3'
        }

        It 'returns an empty array when nothing matches' {
            @(Get-HarnessMatrixSelection -Matrix $script:Matrix -Kind 'hook-registration').Count | Should -Be 0
        }
    }

    Context 'Import-HarnessGenerationMatrix and Get-HarnessBundlePath' {
        It 'parses the matrix through the context reader' {
            $tree = New-FakeTree -Files @{ 'config/harness-parity-matrix.json' = '{"features":[{"id":"claude:skill:a"}]}' }
            (Import-HarnessGenerationMatrix -Context $tree.Context).features[0].id | Should -BeExactly 'claude:skill:a'
        }

        It 'throws when the matrix is absent' {
            $tree = New-FakeTree
            { Import-HarnessGenerationMatrix -Context $tree.Context } | Should -Throw -ExpectedMessage '*harness-parity-matrix.json*does not exist*'
        }

        It 'maps each target root to its bundle copy' -ForEach @(
            @{ Path = '.mcp.json'; Expected = 'extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json' }
            @{ Path = '.claude/skills/x/SKILL.md'; Expected = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/x/SKILL.md' }
            @{ Path = '.agents/skills/x/SKILL.md'; Expected = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/x/SKILL.md' }
            @{ Path = '.codex/config.toml'; Expected = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml' }
            @{ Path = 'AGENTS.md'; Expected = 'extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md' }
            @{ Path = '.github/instructions/a.instructions.md'; Expected = 'extensions/drm-copilot/resources/customizations/.github/instructions/a.instructions.md' }
        ) {
            Get-HarnessBundlePath -Path $Path | Should -BeExactly $Expected
        }

        It 'returns null for a path with no bundle copy' {
            Get-HarnessBundlePath -Path 'README.md' | Should -BeNullOrEmpty
        }
    }

    Context 'ConvertTo-HarnessGeneratedText and Test-HarnessGeneratedPath' {
        It 'converts CRLF and CR to LF and removes a leading byte order mark' {
            ConvertTo-HarnessGeneratedText -Text ([string][char]0xFEFF + "a`r`nb`rc`n") | Should -BeExactly "a`nb`nc`n"
        }

        It 'keeps the first character of text that has no byte order mark' {
            [string]::Equals((ConvertTo-HarnessGeneratedText -Text "---`nname: x`n"), "---`nname: x`n", [System.StringComparison]::Ordinal) | Should -BeTrue
            [string]::Equals((ConvertTo-HarnessGeneratedText -Text 'alpha'), 'alpha', [System.StringComparison]::Ordinal) | Should -BeTrue
            ConvertTo-HarnessGeneratedText -Text '' | Should -BeExactly ''
        }

        It 'accepts repository-relative POSIX paths and rejects other forms' -ForEach @(
            @{ Path = '.claude/skills/x/SKILL.md'; Expected = $true }
            @{ Path = '/abs/path'; Expected = $false }
            @{ Path = 'C:/x'; Expected = $false }
            @{ Path = 'a\b'; Expected = $false }
            @{ Path = 'a/../b'; Expected = $false }
            @{ Path = 'a//b'; Expected = $false }
            @{ Path = ''; Expected = $false }
        ) {
            Test-HarnessGeneratedPath -Path $Path | Should -Be $Expected
        }

        It 'rejects a non-string path' {
            Test-HarnessGeneratedPath -Path 5 | Should -BeFalse
        }
    }

    Context 'Compare-HarnessFileMap' {
        It 'reports no finding when every target equals its rendered text' {
            $tree = New-FakeTree -Files @{ 'a/one.md' = "x`n" }
            @(Compare-HarnessFileMap -FileMap ([ordered]@{ 'a/one.md' = "x`n" }) -Context $tree.Context -ManagedFolders @('a')).Count | Should -Be 0
        }

        It 'reports DRIFT, MISSING and EXTRA by repository-relative POSIX path' {
            $tree = New-FakeTree -Files @{ 'a/one.md' = "old`n"; 'a/extra.md' = "e`n" }
            $findings = @(Compare-HarnessFileMap -FileMap ([ordered]@{ 'a/one.md' = "new`n"; 'a/two.md' = "t`n" }) -Context $tree.Context -ManagedFolders @('a'))
            ($findings | ForEach-Object { "$($_.Kind) $($_.Path)" }) | Should -Be @('DRIFT a/one.md', 'MISSING a/two.md', 'EXTRA a/extra.md')
            $findings[0].Detail | Should -BeExactly 'content differs'
        }

        It 'reports a CRLF target as drift' {
            $tree = New-FakeTree -Files @{ 'a.md' = "x`r`n" }
            $finding = @(Compare-HarnessFileMap -FileMap ([ordered]@{ 'a.md' = "x`n" }) -Context $tree.Context)[0]
            "$($finding.Kind) $($finding.Detail)" | Should -BeExactly 'DRIFT CRLF line endings'
        }

        It 'reports a byte-order-mark target as drift' {
            $tree = New-FakeTree -Files @{ 'a.md' = ([string][char]0xFEFF + "x`n") }
            $finding = @(Compare-HarnessFileMap -FileMap ([ordered]@{ 'a.md' = "x`n" }) -Context $tree.Context)[0]
            "$($finding.Kind) $($finding.Detail)" | Should -BeExactly 'DRIFT byte order mark'
        }

        It 'reports a reparse-point target as drift even when its text matches' {
            $tree = New-FakeTree -Files @{ 'a.md' = "x`n" } -Reparse @('a.md')
            $finding = @(Compare-HarnessFileMap -FileMap ([ordered]@{ 'a.md' = "x`n" }) -Context $tree.Context)[0]
            "$($finding.Kind) $($finding.Detail)" | Should -BeExactly 'DRIFT reparse point or symbolic link'
        }

        It 'never lists a folder that is not managed' {
            $tree = New-FakeTree -Files @{ 'other/x.md' = "x`n" }
            @(Compare-HarnessFileMap -FileMap ([ordered]@{}) -Context $tree.Context -ManagedFolders @('a')).Count | Should -Be 0
        }
    }

    Context 'Write-HarnessFileMap' {
        It 'writes LF text without a byte order mark and skips unchanged files' {
            $tree = New-FakeTree -Files @{ 'same.md' = "s`n" }
            $written = Write-HarnessFileMap -FileMap ([ordered]@{ 'same.md' = "s`n"; 'dir/new.md' = "n`n" }) -Context $tree.Context -WriteFile $tree.Writer
            $written | Should -Be @('dir/new.md')
            $tree.Store['dir/new.md'] | Should -BeExactly "n`n"
        }

        It 'rewrites a reparse-point target' {
            $tree = New-FakeTree -Files @{ 'link.md' = "s`n" } -Reparse @('link.md')
            Write-HarnessFileMap -FileMap ([ordered]@{ 'link.md' = "s`n" }) -Context $tree.Context -WriteFile $tree.Writer | Should -Be @('link.md')
        }

        It 'fails before any write when an entry is malformed' -ForEach @(
            @{ Name = 'path'; Map = [ordered]@{ 'ok.md' = "a`n"; '../bad.md' = "b`n" }; Pattern = '*not a repository-relative POSIX path*' }
            @{ Name = 'CRLF'; Map = [ordered]@{ 'ok.md' = "a`n"; 'crlf.md' = "b`r`n" }; Pattern = '*not LF without a byte order mark*' }
            @{ Name = 'BOM'; Map = [ordered]@{ 'ok.md' = "a`n"; 'bom.md' = ([string][char]0xFEFF + 'b') }; Pattern = '*not LF without a byte order mark*' }
            @{ Name = 'non-string'; Map = [ordered]@{ 'ok.md' = "a`n"; 'num.md' = 7 }; Pattern = '*is not a string*' }
        ) {
            $tree = New-FakeTree
            { Write-HarnessFileMap -FileMap $Map -Context $tree.Context -WriteFile $tree.Writer } | Should -Throw -ExpectedMessage $Pattern
            $tree.Writes.Count | Should -Be 0 -Because "a malformed $Name entry stops the run before the writer is called"
        }
    }

    Context 'Format-HarnessDriftReport' {
        It 'prints one line per finding, sorted by path, and a summary line' {
            $lines = Format-HarnessDriftReport -Findings @(
                (New-HarnessFinding -Kind 'MISSING' -Path 'b.md'),
                (New-HarnessFinding -Kind 'DRIFT' -Path 'a.md' -Detail 'content differs'))
            $lines | Should -Be @('DRIFT a.md (content differs)', 'MISSING b.md', 'harness-generation: 2 finding(s)')
        }

        It 'prints the no-drift line for no finding' {
            Format-HarnessDriftReport -Findings @() | Should -Be @('harness-generation: no drift')
        }
    }

    Context 'Invoke-HarnessGeneration' {
        It 'returns exit 0 in check mode when no target drifts, and writes nothing' {
            $tree = New-FakeTree -Files @{ 'm/x.json' = "{}`n" }
            $result = Invoke-HarnessGeneration -Surface 'mcp' -Context $tree.Context -Check -Providers @{ mcp = (New-FakeProvider -Files @{ 'm/x.json' = "{}`n" }) } -WriteFile $tree.Writer
            $result.ExitCode | Should -Be 0
            $result.Report | Should -Be @('harness-generation: no drift')
            $tree.Writes.Count | Should -Be 0
        }

        It 'returns exit 1 in check mode on drift and names the path' {
            $tree = New-FakeTree -Files @{ 'm/x.json' = "old`n" }
            $result = Invoke-HarnessGeneration -Surface 'mcp' -Context $tree.Context -Check -Providers @{ mcp = (New-FakeProvider -Files @{ 'm/x.json' = "new`n" }) } -WriteFile $tree.Writer
            $result.ExitCode | Should -Be 1
            $result.Report[0] | Should -BeExactly 'DRIFT m/x.json (content differs)'
            $tree.Writes.Count | Should -Be 0
        }

        It 'writes every drifted target in write mode and then reports no drift' {
            $tree = New-FakeTree -Files @{ 'm/x.json' = "old`n" }
            $result = Invoke-HarnessGeneration -Surface 'mcp' -Context $tree.Context -Providers @{ mcp = (New-FakeProvider -Files @{ 'm/x.json' = "new`n"; 'm/y.json' = "y`n" }) } -WriteFile $tree.Writer
            $result.ExitCode | Should -Be 0
            @($result.Written | Sort-Object) | Should -Be @('m/x.json', 'm/y.json')
            $tree.Store['m/x.json'] | Should -BeExactly "new`n"
        }

        It 'runs the surfaces of all in the order instructions, mcp, skills, rules, agents' {
            $order = [System.Collections.Generic.List[string]]::new()
            $providers = @{}
            foreach ($name in @('agents', 'rules', 'skills', 'mcp', 'instructions')) {
                $surfaceName = $name
                $providers[$name] = { $order.Add($surfaceName); [pscustomobject]@{ Files = [ordered]@{}; ManagedFolders = @(); Findings = @() } }.GetNewClosure()
            }
            $tree = New-FakeTree
            $null = Invoke-HarnessGeneration -Surface 'all' -Context $tree.Context -Check -Providers $providers
            $order.ToArray() | Should -Be @('instructions', 'mcp', 'skills', 'rules', 'agents')
            Get-HarnessSurfaceOrder | Should -Be @('instructions', 'mcp', 'skills', 'rules', 'agents')
        }

        It 'fails before any write when a later surface has a malformed source' {
            $tree = New-FakeTree
            $providers = @{
                mcp    = (New-FakeProvider -Files @{ 'm/x.json' = "x`n" })
                skills = { throw "Malformed source 'skills/bad.json': missing frontmatter." }
            }
            { Invoke-HarnessGeneration -Surface 'all' -Context $tree.Context -Providers ($providers + @{ instructions = (New-FakeProvider); rules = (New-FakeProvider); agents = (New-FakeProvider) }) -WriteFile $tree.Writer } |
                Should -Throw -ExpectedMessage '*skills/bad.json*'
            $tree.Writes.Count | Should -Be 0
        }

        It 'rejects a path produced by two surfaces before any write' {
            $tree = New-FakeTree
            $providers = @{ instructions = (New-FakeProvider); mcp = (New-FakeProvider -Files @{ 'same.md' = "a`n" }); skills = (New-FakeProvider -Files @{ 'same.md' = "a`n" }); rules = (New-FakeProvider); agents = (New-FakeProvider) }
            { Invoke-HarnessGeneration -Surface 'all' -Context $tree.Context -Providers $providers -WriteFile $tree.Writer } | Should -Throw -ExpectedMessage '*more than one surface*'
            $tree.Writes.Count | Should -Be 0
        }

        It 'carries surface check findings into the result' {
            $tree = New-FakeTree
            $providers = @{ instructions = (New-FakeProvider -Findings @((New-HarnessFinding -Kind 'IMPORT' -Path 'CLAUDE.md' -Detail 'first line'))) }
            $result = Invoke-HarnessGeneration -Surface 'instructions' -Context $tree.Context -Check -Providers $providers
            $result.ExitCode | Should -Be 1
            $result.Report[0] | Should -BeExactly 'IMPORT CLAUDE.md (first line)'
        }

        It 'rejects instructions without -Check' {
            $tree = New-FakeTree
            { Invoke-HarnessGeneration -Surface 'instructions' -Context $tree.Context } | Should -Throw -ExpectedMessage '*check-only*'
        }

        It 'reports an EXTRA file in a managed folder' {
            $tree = New-FakeTree -Files @{ 'g/keep.md' = "k`n"; 'g/stray.md' = "s`n" }
            $result = Invoke-HarnessGeneration -Surface 'skills' -Context $tree.Context -Check -Providers @{ skills = (New-FakeProvider -Files @{ 'g/keep.md' = "k`n" } -Managed @('g')) }
            $result.Report[0] | Should -BeExactly 'EXTRA g/stray.md'
        }

        It 'uses the default writer bound to the context root when none is injected' {
            Mock -ModuleName HarnessGeneration Write-HarnessRepositoryFile { }
            $tree = New-FakeTree
            $null = Invoke-HarnessGeneration -Surface 'mcp' -Context $tree.Context -Providers @{ mcp = (New-FakeProvider -Files @{ 'm/z.json' = "z`n" }) }
            Should -Invoke -ModuleName HarnessGeneration Write-HarnessRepositoryFile -Times 1 -Exactly -ParameterFilter { $Root -eq 'fake-root' -and $Path -eq 'm/z.json' -and $Text -eq "z`n" }
        }
    }

    Context 'Get-HarnessRepositoryDrift' {
        It 'returns the findings of every surface in check mode' {
            $tree = New-FakeTree -Files @{ 'r/a.md' = "x`n" }
            $providers = @{ instructions = (New-FakeProvider); mcp = (New-FakeProvider); skills = (New-FakeProvider); agents = (New-FakeProvider); rules = (New-FakeProvider -Files @{ 'r/a.md' = "y`n" }) }
            $findings = Get-HarnessRepositoryDrift -Context $tree.Context -Providers $providers
            @($findings | ForEach-Object { "$($_.Kind) $($_.Path)" }) | Should -Be @('DRIFT r/a.md')
            $tree.Store['r/a.md'] | Should -BeExactly "x`n"
        }
    }

    Context 'Get-HarnessSurfaceProvider' {
        It 'maps each surface to its generator module and entry function' {
            (Get-HarnessSurfaceModuleMap)['mcp'].Function | Should -BeExactly 'Get-HarnessMcpFileMap'
            @((Get-HarnessSurfaceModuleMap).Keys) | Should -Be @('instructions', 'mcp', 'skills', 'rules', 'agents')
        }

        It 'throws naming the surface when its module file does not exist' {
            $provider = Get-HarnessSurfaceProvider -Surface 'agents' -ModuleRoot (Join-Path -Path $script:RepoRoot -ChildPath 'no-such-folder')
            { & $provider ([pscustomobject]@{}) } | Should -Throw -ExpectedMessage "*Surface 'agents' has no generator module*"
        }
    }

    Context 'default file-system seams' {
        It 'reads an existing repository file and returns null for an absent one' {
            Read-HarnessRepositoryFile -Root $script:RepoRoot -Path 'scripts/harness-generation/HarnessGeneration.psm1' | Should -Match 'Get-HarnessRepositoryDrift'
            Read-HarnessRepositoryFile -Root $script:RepoRoot -Path 'scripts/harness-generation/absent.md' | Should -BeNullOrEmpty
        }

        It 'lists repository-relative POSIX paths under a folder and nothing for an absent folder' {
            Get-HarnessRepositoryFileList -Root $script:RepoRoot -Folder 'scripts/harness-generation' | Should -Contain 'scripts/harness-generation/HarnessGeneration.psm1'
            @(Get-HarnessRepositoryFileList -Root $script:RepoRoot -Folder 'scripts/no-such-folder').Count | Should -Be 0
        }

        It 'reports a regular file and an absent path as not reparse points' {
            Test-HarnessReparsePoint -Root $script:RepoRoot -Path 'scripts/harness-generation/HarnessGeneration.psm1' | Should -BeFalse
            Test-HarnessReparsePoint -Root $script:RepoRoot -Path 'scripts/harness-generation/absent.md' | Should -BeFalse
        }

        It 'binds the default context seams to the root' {
            $context = New-HarnessGenerationContext -Root $script:RepoRoot
            & $context.ReadFile 'scripts/harness-generation/HarnessGeneration.psm1' | Should -Match 'Set-StrictMode'
            & $context.ListFiles 'scripts/harness-generation' | Should -Contain 'scripts/harness-generation/Invoke-HarnessGeneration.ps1'
            & $context.TestReparse 'scripts/harness-generation/HarnessGeneration.psm1' | Should -BeFalse
        }

        It 'writes UTF-8 without a byte order mark and creates the parent folder' {
            Mock -ModuleName HarnessGeneration Test-Path { $false }
            Mock -ModuleName HarnessGeneration New-Item { }
            Mock -ModuleName HarnessGeneration Set-Content { }
            Write-HarnessRepositoryFile -Root 'fake-root' -Path 'd/f.md' -Text "t`n"
            Should -Invoke -ModuleName HarnessGeneration New-Item -Times 1 -Exactly -ParameterFilter { $ItemType -eq 'Directory' }
            Should -Invoke -ModuleName HarnessGeneration Set-Content -Times 1 -Exactly -ParameterFilter { $Value -eq "t`n" -and $NoNewline -and "$Encoding" -match 'UTF8' }
        }

        It 'writes nothing under -WhatIf' {
            Mock -ModuleName HarnessGeneration Set-Content { }
            Write-HarnessRepositoryFile -Root 'fake-root' -Path 'd/f.md' -Text "t`n" -WhatIf
            Should -Invoke -ModuleName HarnessGeneration Set-Content -Times 0 -Exactly
        }
    }
}
