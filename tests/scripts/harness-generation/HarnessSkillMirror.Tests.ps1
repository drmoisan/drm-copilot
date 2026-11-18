Set-StrictMode -Version Latest

# Unit suite for scripts/harness-generation/HarnessSkillMirror.psm1 (issue #1028).
#
# Each case renders against an in-memory tree (parity matrix, .agents skill sources, substitution sources, and
# generated Claude folders) read through the context seam. A recording lister proves that unselected folders are
# never listed. No temporary file, process or network call is made.

Describe 'HarnessSkillMirror module' {
    BeforeAll {
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/harness-generation/HarnessGeneration.psm1') -Force
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/harness-generation/HarnessSkillMirror.psm1') -Force

        $script:Matrix = @'
{"features":[
 {"id":"claude:skill:alpha","ecosystem":"claude","kind":"skill","name":"alpha","disposition":"generated","generated_from":".agents/skills/alpha/SKILL.md","owner_child":3},
 {"id":"claude:skill:beta","ecosystem":"claude","kind":"skill","name":"beta","disposition":"native","owner_child":3},
 {"id":"codex:skill:alpha","ecosystem":"codex","kind":"skill","name":"alpha","disposition":"shared","owner_child":3},
 {"id":"claude:skill:gamma","ecosystem":"claude","kind":"skill","name":"gamma","disposition":"generated","generated_from":"pending-source:skill","owner_child":3}
]}
'@
        $script:ClaudeAlpha = '.claude/skills/alpha'
        $script:BundleAlpha = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/alpha'

        function New-SkillTree {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
            param([System.Collections.IDictionary] $Override = @{})
            $store = [ordered]@{
                'config/harness-parity-matrix.json'           = $script:Matrix
                '.agents/skills/alpha/SKILL.md'               = "---`nname: alpha`nallowed-tools: Read`n---`n`n# Alpha`n`nSee .agents/skills/alpha/scripts/run.sh.`n"
                '.agents/skills/alpha/scripts/run.sh'         = "#!/bin/sh`necho alpha`n"
                '.agents/skills/alpha/agents/openai.yaml'     = "interface: {}`n"
                '.agents/skills/alpha/references/standard.md' = "# Standard`n"
                '.agents/skills/beta/SKILL.md'                = "# Beta`n"
                '.claude/skills/beta/SKILL.md'                = "# Beta native`n"
            }
            foreach ($key in $Override.Keys) { if ($null -eq $Override[$key]) { $store.Remove($key) } else { $store[$key] = $Override[$key] } }
            $listed = [System.Collections.Generic.List[string]]::new()
            $writes = [System.Collections.Generic.List[string]]::new()
            $context = New-HarnessGenerationContext -Root 'fake-root' `
                -ReadFile { param([string] $Path) if ($store.Contains($Path)) { $store[$Path] } else { $null } }.GetNewClosure() `
                -ListFiles { param([string] $Folder) $listed.Add($Folder); @($store.Keys | Where-Object { $_.StartsWith("$Folder/") }) }.GetNewClosure() `
                -TestReparse { $false }
            return [pscustomobject]@{
                Store = $store; Listed = $listed; Writes = $writes; Context = $context
                Writer = { param([string] $Path, [string] $Text) $writes.Add($Path); $store[$Path] = $Text }.GetNewClosure()
            }
        }

        function Get-SkillProvider {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Returns an in-memory provider table; it changes no system state.')]
            param()
            return @{ skills = { param($Context) Get-HarnessSkillMirrorFileMap -Context $Context } }
        }
    }

    AfterAll {
        Remove-Module -Name HarnessSkillMirror, HarnessGeneration -Force -ErrorAction SilentlyContinue
    }

    It 'mirrors every source file of a selected skill to the Claude copy and its bundle copy' {
        $files = (Get-HarnessSkillMirrorFileMap -Context (New-SkillTree).Context).Files
        @($files.Keys) | Should -Be @("$script:ClaudeAlpha/SKILL.md", "$script:BundleAlpha/SKILL.md", "$script:ClaudeAlpha/scripts/run.sh", "$script:BundleAlpha/scripts/run.sh")
        $files["$script:BundleAlpha/scripts/run.sh"] | Should -BeExactly "#!/bin/sh`necho alpha`n"
    }

    It 'copies the superset frontmatter as written' {
        $files = (Get-HarnessSkillMirrorFileMap -Context (New-SkillTree).Context).Files
        $files["$script:ClaudeAlpha/SKILL.md"] | Should -BeLike "---`nname: alpha`nallowed-tools: Read`n---*"
    }

    It 'never mirrors agents/openai.yaml or references/standard.md' {
        $keys = @((Get-HarnessSkillMirrorFileMap -Context (New-SkillTree).Context).Files.Keys)
        ($keys | Where-Object { $_ -like '*openai.yaml' -or $_ -like '*references/standard.md' }) | Should -BeNullOrEmpty
        Get-HarnessSkillMirrorExcludedFile | Should -Be @('agents/openai.yaml', 'references/standard.md')
    }

    It 'never lists, writes or deletes an unselected skill folder' {
        $tree = New-SkillTree
        $result = Get-HarnessSkillMirrorFileMap -Context $tree.Context
        @($result.Files.Keys | Where-Object { $_ -like '*/beta/*' -or $_ -like '*/gamma/*' }) | Should -BeNullOrEmpty
        $tree.Listed | Should -Not -Contain '.claude/skills/beta'
        $tree.Listed | Should -Not -Contain '.agents/skills/beta'
        $result.ManagedFolders | Should -Be @($script:ClaudeAlpha, $script:BundleAlpha)
    }

    It 'applies ordered Claude substitutions that each occur exactly once' {
        $subs = '{"substitutions":[{"file":"SKILL.md","find":".agents/skills/alpha","replace":".claude/skills/alpha"},{"file":"SKILL.md","find":"# Alpha","replace":"# Alpha (Claude)"}]}'
        $files = (Get-HarnessSkillMirrorFileMap -Context (New-SkillTree -Override @{ 'scripts/harness-generation/sources/skills/alpha.substitutions.json' = $subs }).Context).Files
        $files["$script:ClaudeAlpha/SKILL.md"] | Should -BeExactly "---`nname: alpha`nallowed-tools: Read`n---`n`n# Alpha (Claude)`n`nSee .claude/skills/alpha/scripts/run.sh.`n"
        $files["$script:ClaudeAlpha/scripts/run.sh"] | Should -BeExactly "#!/bin/sh`necho alpha`n"
    }

    It 'applies a later substitution to the output of an earlier one' {
        $subs = '{"substitutions":[{"file":"SKILL.md","find":"# Alpha","replace":"# Beta-ish"},{"file":"SKILL.md","find":"Beta-ish","replace":"Renamed"}]}'
        $files = (Get-HarnessSkillMirrorFileMap -Context (New-SkillTree -Override @{ 'scripts/harness-generation/sources/skills/alpha.substitutions.json' = $subs }).Context).Files
        $files["$script:ClaudeAlpha/SKILL.md"] | Should -Match '# Renamed'
    }

    It 'fails before any write when a substitution is malformed' -ForEach @(
        @{ Name = 'find absent'; Subs = '{"substitutions":[{"file":"SKILL.md","find":"not present","replace":"x"}]}'; Pattern = '*substitution 1 find occurs 0 time(s)*' }
        @{ Name = 'find twice'; Subs = '{"substitutions":[{"file":"SKILL.md","find":"alpha","replace":"x"}]}'; Pattern = '*occurs 2 time(s)*' }
        @{ Name = 'unknown file'; Subs = '{"substitutions":[{"file":"missing.md","find":"a","replace":"b"}]}'; Pattern = "*substitution file 'missing.md' is not a file*" }
        @{ Name = 'empty find'; Subs = '{"substitutions":[{"file":"SKILL.md","find":"","replace":"b"}]}'; Pattern = "*has an empty 'find'*" }
        @{ Name = 'missing replace'; Subs = '{"substitutions":[{"file":"SKILL.md","find":"a"}]}'; Pattern = "*has no string 'replace'*" }
        @{ Name = 'no substitutions key'; Subs = '{"x":[]}'; Pattern = "*missing 'substitutions'*" }
        @{ Name = 'invalid JSON'; Subs = '{not json'; Pattern = '*not valid JSON*' }
    ) {
        $tree = New-SkillTree -Override @{ 'scripts/harness-generation/sources/skills/alpha.substitutions.json' = $Subs }
        { Invoke-HarnessGeneration -Surface 'skills' -Context $tree.Context -Providers (Get-SkillProvider) -WriteFile $tree.Writer } | Should -Throw -ExpectedMessage $Pattern -Because $Name
        $tree.Writes.Count | Should -Be 0
    }

    It 'fails when a selected skill has no source files' {
        $tree = New-SkillTree -Override @{ '.agents/skills/alpha/SKILL.md' = $null; '.agents/skills/alpha/scripts/run.sh' = $null; '.agents/skills/alpha/agents/openai.yaml' = $null; '.agents/skills/alpha/references/standard.md' = $null }
        { Get-HarnessSkillMirrorFileMap -Context $tree.Context } | Should -Throw -ExpectedMessage "*'.agents/skills/alpha': the selected skill has no source files*"
    }

    It 'reports an extra file in a generated folder' {
        $tree = New-SkillTree
        $null = Invoke-HarnessGeneration -Surface 'skills' -Context $tree.Context -Providers (Get-SkillProvider) -WriteFile $tree.Writer
        $tree.Store["$script:ClaudeAlpha/stray.md"] = "stray`n"
        $result = Invoke-HarnessGeneration -Surface 'skills' -Context $tree.Context -Check -Providers (Get-SkillProvider)
        $result.Report | Should -Contain "EXTRA $script:ClaudeAlpha/stray.md"
        $result.ExitCode | Should -Be 1
    }

    It 'reports no drift after a write run' {
        $tree = New-SkillTree
        $null = Invoke-HarnessGeneration -Surface 'skills' -Context $tree.Context -Providers (Get-SkillProvider) -WriteFile $tree.Writer
        (Invoke-HarnessGeneration -Surface 'skills' -Context $tree.Context -Check -Providers (Get-SkillProvider)).ExitCode | Should -Be 0
        $tree.Store['.claude/skills/beta/SKILL.md'] | Should -BeExactly "# Beta native`n"
    }

    It 'counts ordinal non-overlapping occurrences' {
        Get-HarnessOccurrenceCount -Text 'aaaa' -Value 'aa' | Should -Be 2
        Get-HarnessOccurrenceCount -Text 'abc' -Value 'x' | Should -Be 0
    }
}
