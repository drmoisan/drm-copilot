Set-StrictMode -Version Latest

# Unit suite for scripts/harness-generation/HarnessAgentGeneration.psm1 (issue #1028, spec D-11, OQ-5, OQ-9).
#
# Each case renders against an in-memory tree (parity matrix, routing config, agent sources) read through the
# context seam. No temporary file, process or network call is made.

Describe 'HarnessAgentGeneration module' {
    BeforeAll {
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/harness-generation/HarnessGeneration.psm1') -Force
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/harness-generation/HarnessAgentGeneration.psm1') -Force

        $script:Matrix = @'
{"features":[
 {"id":"claude:agent:alpha","ecosystem":"claude","kind":"agent","name":"alpha","disposition":"generated","target_paths":[".claude/agents/alpha.md"],"owner_child":3},
 {"id":"codex:agent:alpha","ecosystem":"codex","kind":"agent","name":"alpha","disposition":"generated","target_paths":[".codex/agents/alpha.toml"],"owner_child":3},
 {"id":"claude:agent:beta","ecosystem":"claude","kind":"agent","name":"beta","disposition":"generated","target_paths":[".claude/agents/beta.md"],"owner_child":3},
 {"id":"codex:agent:beta","ecosystem":"codex","kind":"agent","name":"beta","disposition":"generated","target_paths":[".codex/agents/beta.toml"],"owner_child":3},
 {"id":"codex:agent:solo","ecosystem":"codex","kind":"agent","name":"solo","disposition":"native","owner_child":3}
]}
'@
        $script:Routing = '{"codex_model_policy":{"complexity_to_profile":{"C3":{"suffix":"c3","model":"m-sol","model_reasoning_effort":"high"}},"generated_agent_families":["alpha"]}}'
        $script:Body = "<!-- harness-section: intro -->`nYou are alpha.`n<!-- harness-section: claude-tail -->`nUse Write(/artifacts/**).`n<!-- harness-section: codex-tail -->`nUse the Codex path.`n"
        $script:Source = @'
{"claude":{"path":".claude/agents/alpha.md","frontmatter":[{"key":"name","value":" alpha"},{"key":"description","value":" Alpha agent."},{"key":"tools","value":"\n  - \"Write(/artifacts/**)\""}],"sections":["intro","claude-tail"]},
 "codex":{"path":".codex/agents/alpha.toml","keys":[{"key":"name","value":"\"alpha\""},{"key":"description","value":"\"Alpha agent.\""}],"delimiter":"'''","sections":["intro","codex-tail"],"substitutions":[{"find":"alpha.","replace":"the Codex alpha."}],"separator":"\n","trailer":"\n[skills]\nconfig = []\n"}}
'@
        $script:BetaSource = @'
{"claude":{"path":".claude/agents/beta.md","frontmatter":[{"key":"name","value":" beta"},{"key":"description","value":" Beta."}],"sections":["intro"]},
 "codex":{"path":".codex/agents/beta.toml","keys":[{"key":"name","value":"\"beta\""},{"key":"description","value":"\"Beta.\""},{"key":"model","value":"\"m-x\""}],"delimiter":"\"\"\"","sections":["intro"]}}
'@

        function New-AgentTree {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
            param([System.Collections.IDictionary] $Override = @{})
            $store = [ordered]@{
                'config/harness-parity-matrix.json'                    = $script:Matrix
                'config/orchestration-routing.json'                    = $script:Routing
                'scripts/harness-generation/sources/agents/alpha.json' = $script:Source
                'scripts/harness-generation/sources/agents/alpha.md'   = $script:Body
                'scripts/harness-generation/sources/agents/beta.json'  = $script:BetaSource
                'scripts/harness-generation/sources/agents/beta.md'    = "<!-- harness-section: intro -->`nBeta body.`n"
            }
            foreach ($key in $Override.Keys) { if ($null -eq $Override[$key]) { $store.Remove($key) } else { $store[$key] = $Override[$key] } }
            $context = New-HarnessGenerationContext -Root 'fake-root' `
                -ReadFile { param([string] $Path) if ($store.Contains($Path)) { $store[$Path] } else { $null } }.GetNewClosure() `
                -ListFiles { param([string] $Folder) @($store.Keys | Where-Object { $_.StartsWith("$Folder/") }) }.GetNewClosure() `
                -TestReparse { $false }
            $writes = [System.Collections.Generic.List[string]]::new()
            $writer = { param([string] $Path, [string] $Text) $writes.Add($Path); $store[$Path] = $Text }.GetNewClosure()
            return [pscustomobject]@{ Store = $store; Context = $context; Writer = $writer; Writes = $writes }
        }
    }

    AfterAll {
        Remove-Module -Name HarnessAgentGeneration, HarnessGeneration -Force -ErrorAction SilentlyContinue
    }

    Context 'Get-HarnessAgentSection' {
        It 'splits a body into ordered named sections' {
            $sections = Get-HarnessAgentSection -Text $script:Body -SourcePath 'a.md'
            @($sections.Keys) | Should -Be @('intro', 'claude-tail', 'codex-tail')
        }

        It 'rejects <Case>' -ForEach @(
            @{ Case = 'a body without a marker'; Text = "plain`n"; Message = '*no section marker*' }
            @{ Case = 'text before the first marker'; Text = "x`n<!-- harness-section: a -->`ny`n"; Message = '*text before the first section marker*' }
            @{ Case = 'a duplicated section'; Text = "<!-- harness-section: a -->`nx`n<!-- harness-section: a -->`ny`n"; Message = "*section 'a' is defined twice*" }
        ) {
            { Get-HarnessAgentSection -Text $Text -SourcePath 'a.md' } | Should -Throw $Message
        }
    }

    Context 'Get-HarnessAgentAliasPolicy' {
        It 'reads the families and the C3 model and effort' {
            $policy = Get-HarnessAgentAliasPolicy -Context (New-AgentTree).Context
            $policy.Families | Should -Be @('alpha')
            $policy.Model | Should -BeExactly 'm-sol'
            $policy.Effort | Should -BeExactly 'high'
        }

        It 'rejects a missing routing config' {
            { Get-HarnessAgentAliasPolicy -Context (New-AgentTree -Override @{ 'config/orchestration-routing.json' = $null }).Context } | Should -Throw '*does not exist*'
        }

        It 'rejects a routing config without the family list' {
            $tree = New-AgentTree -Override @{ 'config/orchestration-routing.json' = '{"codex_model_policy":{"complexity_to_profile":{"C3":{"model":"m"}}}}' }
            { Get-HarnessAgentAliasPolicy -Context $tree.Context } | Should -Throw '*no codex_model_policy generated_agent_families*'
        }
    }

    Context 'Get-HarnessAgentFileMap' {
        It 'renders the Claude agent with raw frontmatter and Write( literals verbatim' {
            $result = Get-HarnessAgentFileMap -Context (New-AgentTree).Context
            $result.Files['.claude/agents/alpha.md'] | Should -BeExactly "---`nname: alpha`ndescription: Alpha agent.`ntools:`n  - `"Write(/artifacts/**)`"`n---`nYou are alpha.`nUse Write(/artifacts/**).`n"
        }

        It 'renders a generated family in the C3 alias form with substitutions and the trailer' {
            $result = Get-HarnessAgentFileMap -Context (New-AgentTree).Context
            $result.Files['.codex/agents/alpha.toml'] | Should -BeExactly "name = `"alpha`"`ndescription = `"Alpha agent.`"`nmodel = `"m-sol`"`nmodel_reasoning_effort = `"high`"`n`ndeveloper_instructions = '''`nYou are the Codex alpha.`nUse the Codex path.`n'''`n`n[skills]`nconfig = []`n"
        }

        It 'keeps the declared model keys of an agent outside the families, with no separator' {
            $result = Get-HarnessAgentFileMap -Context (New-AgentTree).Context
            $result.Files['.codex/agents/beta.toml'] | Should -BeExactly "name = `"beta`"`ndescription = `"Beta.`"`nmodel = `"m-x`"`ndeveloper_instructions = `"`"`"`nBeta body.`n`"`"`"`n"
        }

        It 'writes the bundle copy of every target and reports no finding' {
            $result = Get-HarnessAgentFileMap -Context (New-AgentTree).Context
            $result.Files.Count | Should -Be 8
            $result.Files['extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/alpha.toml'] | Should -BeExactly $result.Files['.codex/agents/alpha.toml']
            $result.Files['extensions/drm-copilot/resources/claude-customizations/.claude/agents/beta.md'] | Should -BeExactly $result.Files['.claude/agents/beta.md']
            $result.Findings.Count | Should -Be 0
        }

        It 'reports a selected agent without a source as NO-SOURCE' {
            $tree = New-AgentTree -Override @{ 'scripts/harness-generation/sources/agents/beta.json' = $null; 'scripts/harness-generation/sources/agents/beta.md' = $null }
            $result = Get-HarnessAgentFileMap -Context $tree.Context
            @($result.Findings | ForEach-Object { "$($_.Kind) $($_.Path)" }) | Should -Be @('NO-SOURCE .claude/agents/beta.md', 'NO-SOURCE .codex/agents/beta.toml')
        }

        It 'rejects a source for an agent that is not selected' {
            $tree = New-AgentTree -Override @{ 'scripts/harness-generation/sources/agents/solo.json' = $script:BetaSource; 'scripts/harness-generation/sources/agents/solo.md' = "<!-- harness-section: intro -->`nx`n" }
            { Get-HarnessAgentFileMap -Context $tree.Context } | Should -Throw "*'.claude/agents/solo.md' is not a selected parity-matrix target*"
        }

        It 'rejects a target path that does not match the source name' {
            $tree = New-AgentTree -Override @{ 'scripts/harness-generation/sources/agents/beta.json' = $script:BetaSource.Replace('.claude/agents/beta.md', '.claude/agents/other.md') }
            { Get-HarnessAgentFileMap -Context $tree.Context } | Should -Throw "*the claude target path must be '.claude/agents/beta.md'*"
        }

        It 'rejects a source missing <Field> before any write' -ForEach @(
            @{ Field = 'the claude description'; Find = '{"key":"description","value":" Beta."}'; Replace = '{"key":"summary","value":" Beta."}'; Message = "*the claude frontmatter has no required key 'description'*" }
            @{ Field = 'the codex name'; Find = '{"key":"name","value":"\"beta\""},'; Replace = ''; Message = "*the codex keys has no required key 'name'*" }
            @{ Field = 'the codex delimiter'; Find = ',"delimiter":"\"\"\""'; Replace = ''; Message = "*the codex target has no 'delimiter'*" }
            @{ Field = 'the codex target'; Find = '"codex":'; Replace = '"other":'; Message = "*the source has no 'codex'*" }
        ) {
            $tree = New-AgentTree -Override @{ 'scripts/harness-generation/sources/agents/beta.json' = $script:BetaSource.Replace($Find, $Replace) }
            $providers = @{ agents = { param($Context) Get-HarnessAgentFileMap -Context $Context } }
            { Invoke-HarnessGeneration -Surface agents -Context $tree.Context -Providers $providers -WriteFile $tree.Writer } | Should -Throw $Message
            $tree.Writes.Count | Should -Be 0
        }

        It 'rejects <Case>' -ForEach @(
            @{ Case = 'a frontmatter item without a key'; Find = '{"key":"description","value":" Beta."}'; Replace = '{"value":" Beta."}'; Message = '*has an item without key or value*' }
            @{ Case = 'an unknown delimiter'; Find = '"delimiter":"\"\"\""'; Replace = '"delimiter":"x"'; Message = '*the codex delimiter must be*' }
            @{ Case = 'an unknown section'; Find = '"sections":["intro"]}}'; Replace = '"sections":["missing"]}}'; Message = "*lists unknown section 'missing'*" }
            @{ Case = 'a substitution that does not occur once'; Find = '"sections":["intro"]}}'; Replace = '"sections":["intro"],"substitutions":[{"find":"absent","replace":"x"}]}}'; Message = '*occurs 0 time(s)*' }
            @{ Case = 'an empty substitution find'; Find = '"sections":["intro"]}}'; Replace = '"sections":["intro"],"substitutions":[{"find":"","replace":"x"}]}}'; Message = "*empty 'find'*" }
            @{ Case = 'invalid JSON'; Find = '"sections":["intro"]}}'; Replace = '"sections":["intro"'; Message = '*not valid JSON*' }
        ) {
            $tree = New-AgentTree -Override @{ 'scripts/harness-generation/sources/agents/beta.json' = $script:BetaSource.Replace($Find, $Replace) }
            { Get-HarnessAgentFileMap -Context $tree.Context } | Should -Throw $Message
        }

        It 'rejects a generated family that declares model keys' {
            $source = $script:Source.Replace('{"key":"description","value":"\"Alpha agent.\""}', '{"key":"description","value":"\"Alpha agent.\""},{"key":"model","value":"\"m\""}')
            $tree = New-AgentTree -Override @{ 'scripts/harness-generation/sources/agents/alpha.json' = $source }
            { Get-HarnessAgentFileMap -Context $tree.Context } | Should -Throw "*generated family 'alpha' must not declare model keys*"
        }

        It 'rejects a codex body that contains its delimiter' {
            $tree = New-AgentTree -Override @{ 'scripts/harness-generation/sources/agents/beta.md' = "<!-- harness-section: intro -->`nSee `"`"`" here.`n" }
            { Get-HarnessAgentFileMap -Context $tree.Context } | Should -Throw '*contains its delimiter*'
        }

        It 'rejects a source whose body is missing' {
            $tree = New-AgentTree -Override @{ 'scripts/harness-generation/sources/agents/beta.md' = $null }
            { Get-HarnessAgentFileMap -Context $tree.Context } | Should -Throw '*the section body does not exist*'
        }
    }

    Context 'Invoke-HarnessGeneration with the agents surface' {
        It 'writes every target once and then reports no drift' {
            $tree = New-AgentTree
            $providers = @{ agents = { param($Context) Get-HarnessAgentFileMap -Context $Context } }
            $write = Invoke-HarnessGeneration -Surface agents -Context $tree.Context -Providers $providers -WriteFile $tree.Writer
            $write.Written.Count | Should -Be 8
            (Invoke-HarnessGeneration -Surface agents -Context $tree.Context -Providers $providers -Check).ExitCode | Should -Be 0
        }
    }
}
