Set-StrictMode -Version Latest

# Unit suite for scripts/harness-generation/HarnessRuleGeneration.psm1 (issue #1028, spec D-4, OQ-2, OQ-3, PQ-1).
#
# Each case renders against an in-memory tree (parity matrix, rule sources, Claude skills) read through the context
# seam. No temporary file, process or network call is made.

Describe 'HarnessRuleGeneration module' {
    BeforeAll {
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/harness-generation/HarnessGeneration.psm1') -Force
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/harness-generation/HarnessRuleGeneration.psm1') -Force

        $script:Matrix = @'
{"features":[
 {"id":"claude:path-scoped-rule:python","ecosystem":"claude","kind":"path-scoped-rule","name":"python","disposition":"generated","target_paths":[".claude/rules/python.md"],"owner_child":3},
 {"id":"copilot:path-scoped-rule:python-code-change","ecosystem":"copilot","kind":"path-scoped-rule","name":"python-code-change","disposition":"generated","target_paths":[".github/instructions/python-code-change.instructions.md"],"owner_child":3},
 {"id":"claude:path-scoped-rule:old","ecosystem":"claude","kind":"path-scoped-rule","name":"old","disposition":"native","target_paths":[".claude/rules/old.md"],"owner_child":3}
]}
'@
        $script:Body = "<!-- harness-section: intro -->`n# Python`n`nShared text.`n<!-- harness-section: claude-only -->`n`nClaude toolchain.`n<!-- harness-section: copilot-only -->`n`nCopilot toolchain.`n"
        $script:Source = @'
{"targets":[
 {"kind":"claude","path":".claude/rules/python.md","frontmatter":[{"key":"paths","value":"\n  - \"**/*.py\""},{"key":"description","value":" Python rules."}],"sections":["intro","claude-only"],"substitutions":[{"find":"Shared text.","replace":"Claude text."}]},
 {"kind":"copilot","path":".github/instructions/python-code-change.instructions.md","frontmatter":[{"key":"applyTo","value":" \"**/*.py\""}],"sections":["intro","copilot-only"]}
]}
'@

        function New-RuleTree {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
            param([System.Collections.IDictionary] $Override = @{})
            $store = [ordered]@{
                'config/harness-parity-matrix.json'                    = $script:Matrix
                'scripts/harness-generation/sources/rules/python.json' = $script:Source
                'scripts/harness-generation/sources/rules/python.md'   = $script:Body
            }
            foreach ($key in $Override.Keys) { if ($null -eq $Override[$key]) { $store.Remove($key) } else { $store[$key] = $Override[$key] } }
            $context = New-HarnessGenerationContext -Root 'fake-root' `
                -ReadFile { param([string] $Path) if ($store.Contains($Path)) { $store[$Path] } else { $null } }.GetNewClosure() `
                -ListFiles { param([string] $Folder) @($store.Keys | Where-Object { $_.StartsWith("$Folder/") }) }.GetNewClosure() `
                -TestReparse { $false }
            $writer = { param([string] $Path, [string] $Text) $store[$Path] = $Text }.GetNewClosure()
            return [pscustomobject]@{ Store = $store; Context = $context; Writer = $writer }
        }

        function ConvertTo-Target {
            param([string] $Json)
            return ($Json | ConvertFrom-Json)
        }
    }

    AfterAll {
        Remove-Module -Name HarnessRuleGeneration, HarnessGeneration -Force -ErrorAction SilentlyContinue
    }

    Context 'Get-HarnessRuleSection' {
        It 'splits a body into ordered named sections' {
            $sections = Get-HarnessRuleSection -Text $script:Body -SourcePath 's.md'
            @($sections.Keys) | Should -Be @('intro', 'claude-only', 'copilot-only')
            $sections['intro'] | Should -BeExactly "# Python`n`nShared text.`n"
        }

        It 'rejects a body with no marker' {
            { Get-HarnessRuleSection -Text "# Plain`n" -SourcePath 's.md' } | Should -Throw "*'s.md': no section marker*"
        }

        It 'rejects text before the first marker' {
            { Get-HarnessRuleSection -Text "lead`n<!-- harness-section: a -->`nx`n" -SourcePath 's.md' } | Should -Throw '*text before the first section marker*'
        }

        It 'rejects a section defined twice' {
            { Get-HarnessRuleSection -Text "<!-- harness-section: a -->`nx`n<!-- harness-section: a -->`ny`n" -SourcePath 's.md' } | Should -Throw "*section 'a' is defined twice*"
        }
    }

    Context 'Test-HarnessRuleTargetPath' {
        It 'returns the stem for <Kind> path <Path>' -ForEach @(
            @{ Kind = 'claude'; Path = '.claude/rules/python.md'; Stem = 'python' }
            @{ Kind = 'copilot'; Path = '.github/instructions/general-unit-test.instructions.md'; Stem = 'general-unit-test' }
            @{ Kind = 'codex'; Path = '.agents/skills/tonality/SKILL.md'; Stem = 'tonality' }
        ) {
            Test-HarnessRuleTargetPath -Kind $Kind -Path $Path | Should -BeExactly $Stem
        }

        It 'returns null for <Kind> path <Path>' -ForEach @(
            @{ Kind = 'claude'; Path = '.github/instructions/python.instructions.md' }
            @{ Kind = 'copilot'; Path = '.github/instructions/python.md' }
            @{ Kind = 'other'; Path = '.claude/rules/python.md' }
        ) {
            Test-HarnessRuleTargetPath -Kind $Kind -Path $Path | Should -BeNullOrEmpty
        }
    }

    Context 'Format-HarnessRuleFrontmatter' {
        It 'renders ordered keys with raw values between --- lines' {
            $items = @([pscustomobject]@{ key = 'applyTo'; value = ' "**"' }, [pscustomobject]@{ key = 'name'; value = ' x' })
            Format-HarnessRuleFrontmatter -Frontmatter $items | Should -BeExactly "---`napplyTo: `"**`"`nname: x`n---`n"
        }

        It 'renders nothing for an empty list' {
            Format-HarnessRuleFrontmatter -Frontmatter @() | Should -BeExactly ''
        }
    }

    Context 'Assert-HarnessRuleTarget' {
        BeforeAll {
            $script:Sections = Get-HarnessRuleSection -Text $script:Body -SourcePath 's.md'
        }

        It 'rejects a target without <Field>' -ForEach @(
            @{ Field = 'kind'; Json = '{"path":".claude/rules/python.md","frontmatter":[],"sections":[]}' }
            @{ Field = 'sections'; Json = '{"kind":"claude","path":".claude/rules/python.md","frontmatter":[]}' }
        ) {
            $tree = New-RuleTree
            { Assert-HarnessRuleTarget -Target (ConvertTo-Target $Json) -Sections $script:Sections -ClaudeUnconditional $false -Context $tree.Context -SourcePath 'r.json' } |
                Should -Throw "*a target has no '$Field'*"
        }

        It 'rejects an unknown target path' {
            $tree = New-RuleTree
            $target = ConvertTo-Target '{"kind":"claude","path":"docs/python.md","frontmatter":[],"sections":[]}'
            { Assert-HarnessRuleTarget -Target $target -Sections $script:Sections -ClaudeUnconditional $true -Context $tree.Context -SourcePath 'r.json' } | Should -Throw '*unknown target*'
        }

        It 'rejects a codex rule-skill whose stem has a Claude skill (OQ-2)' {
            $tree = New-RuleTree -Override @{ '.claude/skills/tonality/SKILL.md' = "# T`n" }
            $target = ConvertTo-Target '{"kind":"codex","path":".agents/skills/tonality/SKILL.md","frontmatter":[],"sections":["intro"]}'
            { Assert-HarnessRuleTarget -Target $target -Sections $script:Sections -ClaudeUnconditional $false -Context $tree.Context -SourcePath 'r.json' } | Should -Throw '*names a stem that has a Claude skill*'
        }

        It 'accepts a codex rule-skill whose stem has no Claude skill' {
            $tree = New-RuleTree
            $target = ConvertTo-Target '{"kind":"codex","path":".agents/skills/tonality/SKILL.md","frontmatter":[],"sections":["intro"]}'
            { Assert-HarnessRuleTarget -Target $target -Sections $script:Sections -ClaudeUnconditional $false -Context $tree.Context -SourcePath 'r.json' } | Should -Not -Throw
        }

        It 'rejects a frontmatter item without a key' {
            $tree = New-RuleTree
            $target = ConvertTo-Target '{"kind":"copilot","path":".github/instructions/x.instructions.md","frontmatter":[{"value":" y"}],"sections":[]}'
            { Assert-HarnessRuleTarget -Target $target -Sections $script:Sections -ClaudeUnconditional $false -Context $tree.Context -SourcePath 'r.json' } | Should -Throw '*frontmatter item without key or value*'
        }

        It 'rejects a copilot target with no frontmatter' {
            $tree = New-RuleTree
            $target = ConvertTo-Target '{"kind":"copilot","path":".github/instructions/x.instructions.md","frontmatter":[],"sections":[]}'
            { Assert-HarnessRuleTarget -Target $target -Sections $script:Sections -ClaudeUnconditional $false -Context $tree.Context -SourcePath 'r.json' } | Should -Throw '*has no frontmatter*'
        }

        It 'rejects a claude target with no paths key unless claudeUnconditional' {
            $tree = New-RuleTree
            $target = ConvertTo-Target '{"kind":"claude","path":".claude/rules/tonality.md","frontmatter":[{"key":"description","value":" d"}],"sections":["intro"]}'
            { Assert-HarnessRuleTarget -Target $target -Sections $script:Sections -ClaudeUnconditional $false -Context $tree.Context -SourcePath 'r.json' } | Should -Throw "*has no 'paths' key*"
            { Assert-HarnessRuleTarget -Target $target -Sections $script:Sections -ClaudeUnconditional $true -Context $tree.Context -SourcePath 'r.json' } | Should -Not -Throw
        }

        It 'rejects a claude target with a ** glob unless claudeUnconditional' {
            $tree = New-RuleTree
            $target = ConvertTo-Target '{"kind":"claude","path":".claude/rules/general.md","frontmatter":[{"key":"paths","value":"\n  - \"**\""}],"sections":["intro"]}'
            { Assert-HarnessRuleTarget -Target $target -Sections $script:Sections -ClaudeUnconditional $false -Context $tree.Context -SourcePath 'r.json' } | Should -Throw "*glob and the source does not declare claudeUnconditional*"
            { Assert-HarnessRuleTarget -Target $target -Sections $script:Sections -ClaudeUnconditional $true -Context $tree.Context -SourcePath 'r.json' } | Should -Not -Throw
        }

        It 'rejects an unknown section key' {
            $tree = New-RuleTree
            $target = ConvertTo-Target '{"kind":"claude","path":".claude/rules/python.md","frontmatter":[{"key":"paths","value":" x"}],"sections":["missing"]}'
            { Assert-HarnessRuleTarget -Target $target -Sections $script:Sections -ClaudeUnconditional $false -Context $tree.Context -SourcePath 'r.json' } | Should -Throw "*unknown section 'missing'*"
        }
    }

    Context 'ConvertTo-HarnessRuleTargetText' {
        BeforeAll {
            $script:Sections = Get-HarnessRuleSection -Text $script:Body -SourcePath 's.md'
        }

        It 'renders frontmatter, the listed sections in order, then the substitutions' {
            $target = ConvertTo-Target '{"kind":"claude","path":".claude/rules/python.md","frontmatter":[{"key":"paths","value":" x"}],"sections":["claude-only","intro"],"substitutions":[{"find":"Shared","replace":"Own"}]}'
            ConvertTo-HarnessRuleTargetText -Target $target -Sections $script:Sections -SourcePath 'r.json' |
                Should -BeExactly "---`npaths: x`n---`n`nClaude toolchain.`n# Python`n`nOwn text.`n"
        }

        It 'rejects a substitution whose find occurs <Count> times' -ForEach @(
            @{ Count = 0; Find = 'Absent' }
            @{ Count = 2; Find = 'toolchain' }
        ) {
            $target = [pscustomobject]@{ path = '.claude/rules/python.md'; frontmatter = @(); sections = @('claude-only', 'copilot-only'); substitutions = @([pscustomobject]@{ find = $Find; replace = 'y' }) }
            { ConvertTo-HarnessRuleTargetText -Target $target -Sections $script:Sections -SourcePath 'r.json' } | Should -Throw "*occurs $Count time(s)*"
        }

        It 'rejects an empty find' {
            $target = [pscustomobject]@{ path = '.claude/rules/python.md'; frontmatter = @(); sections = @('intro'); substitutions = @([pscustomobject]@{ find = ''; replace = 'y' }) }
            { ConvertTo-HarnessRuleTargetText -Target $target -Sections $script:Sections -SourcePath 'r.json' } | Should -Throw "*empty 'find'*"
        }
    }

    Context 'Get-HarnessRuleFileMap' {
        It 'renders each target and its bundle copy with no finding' {
            $tree = New-RuleTree
            $result = Get-HarnessRuleFileMap -Context $tree.Context
            @($result.Files.Keys) | Should -Be @(
                '.claude/rules/python.md',
                'extensions/drm-copilot/resources/claude-customizations/.claude/rules/python.md',
                '.github/instructions/python-code-change.instructions.md',
                'extensions/drm-copilot/resources/customizations/.github/instructions/python-code-change.instructions.md'
            )
            $result.Files['.claude/rules/python.md'] | Should -BeExactly "---`npaths:`n  - `"**/*.py`"`ndescription: Python rules.`n---`n# Python`n`nClaude text.`n`nClaude toolchain.`n"
            $result.Files['.github/instructions/python-code-change.instructions.md'] | Should -BeExactly "---`napplyTo: `"**/*.py`"`n---`n# Python`n`nShared text.`n`nCopilot toolchain.`n"
            $result.Findings.Count | Should -Be 0
            $result.ManagedFolders.Count | Should -Be 0
        }

        It 'reports a selected target with no source as NO-SOURCE' {
            $source = '{"targets":[{"kind":"claude","path":".claude/rules/python.md","frontmatter":[{"key":"paths","value":" x"}],"sections":["intro"]}]}'
            $tree = New-RuleTree -Override @{ 'scripts/harness-generation/sources/rules/python.json' = $source }
            $result = Get-HarnessRuleFileMap -Context $tree.Context
            @($result.Findings | ForEach-Object { "$($_.Kind) $($_.Path)" }) | Should -Be @('NO-SOURCE .github/instructions/python-code-change.instructions.md')
        }

        It 'rejects a claude or copilot target that is not a selected matrix target' {
            $source = '{"targets":[{"kind":"claude","path":".claude/rules/old.md","frontmatter":[{"key":"paths","value":" x"}],"sections":["intro"]}]}'
            $tree = New-RuleTree -Override @{ 'scripts/harness-generation/sources/rules/python.json' = $source }
            { Get-HarnessRuleFileMap -Context $tree.Context } | Should -Throw '*is not a selected parity-matrix target*'
        }

        It 'renders a codex rule-skill target that the matrix does not list' {
            $source = '{"targets":[{"kind":"codex","path":".agents/skills/python/SKILL.md","frontmatter":[],"sections":["intro"]}]}'
            $tree = New-RuleTree -Override @{ 'scripts/harness-generation/sources/rules/python.json' = $source }
            $result = Get-HarnessRuleFileMap -Context $tree.Context
            $result.Files['extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python/SKILL.md'] | Should -BeExactly "# Python`n`nShared text.`n"
        }

        It 'rejects a target produced by two sources' {
            $tree = New-RuleTree -Override @{
                'scripts/harness-generation/sources/rules/second.json' = '{"targets":[{"kind":"claude","path":".claude/rules/python.md","frontmatter":[{"key":"paths","value":" x"}],"sections":["a"]}]}'
                'scripts/harness-generation/sources/rules/second.md'   = "<!-- harness-section: a -->`nA`n"
            }
            { Get-HarnessRuleFileMap -Context $tree.Context } | Should -Throw '*produced by more than one source*'
        }

        It 'rejects a source that is <Case>' -ForEach @(
            @{ Case = 'not JSON'; Json = '{bad'; Message = '*not valid JSON*' }
            @{ Case = 'without targets'; Json = '{"targets":[]}'; Message = "*missing 'targets'*" }
        ) {
            $tree = New-RuleTree -Override @{ 'scripts/harness-generation/sources/rules/python.json' = $Json }
            { Get-HarnessRuleFileMap -Context $tree.Context } | Should -Throw $Message
        }

        It 'rejects a source whose section body is missing' {
            $tree = New-RuleTree -Override @{ 'scripts/harness-generation/sources/rules/python.md' = $null }
            { Get-HarnessRuleFileMap -Context $tree.Context } | Should -Throw '*the section body does not exist*'
        }

        It 'normalizes a CRLF body before splitting it' {
            $tree = New-RuleTree -Override @{ 'scripts/harness-generation/sources/rules/python.md' = $script:Body.Replace("`n", "`r`n") }
            $result = Get-HarnessRuleFileMap -Context $tree.Context
            $result.Files['.github/instructions/python-code-change.instructions.md'] | Should -Not -Match "`r"
        }
    }

    Context 'Invoke-HarnessGeneration with the rules surface' {
        It 'writes every target once and then reports no drift' {
            $tree = New-RuleTree
            $providers = @{ rules = { param($Context) Get-HarnessRuleFileMap -Context $Context } }
            $write = Invoke-HarnessGeneration -Surface rules -Context $tree.Context -Providers $providers -WriteFile $tree.Writer
            $write.Written.Count | Should -Be 4
            $tree.Store['extensions/drm-copilot/resources/customizations/.github/instructions/python-code-change.instructions.md'] | Should -BeLike '---*'
            $check = Invoke-HarnessGeneration -Surface rules -Context $tree.Context -Providers $providers -Check
            $check.ExitCode | Should -Be 0
        }
    }
}
