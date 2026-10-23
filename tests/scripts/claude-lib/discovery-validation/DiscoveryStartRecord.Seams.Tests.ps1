#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Default read seams of DiscoveryStartRecord.psm1 over committed repository files (issue #980).
.DESCRIPTION
    The default ReadBytes seam of Read-DiscoveryAgentProfile and the ReadText and ListEntries seams of
    Get-DiscoveryStartStore read real paths; they are exercised against committed repository files and
    directories only. The WriteText and ReplaceText seams create or rewrite files and are not run here,
    because tests write no file.
#>

Describe 'DiscoveryStartRecord default read seams' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/discovery-validation/DiscoveryEncoding.psm1') -Force
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/discovery-validation/DiscoveryStartRecord.psm1') -Force
    }

    It 'reads a committed Claude Code agent profile through the default byte reader' {
        $record = Read-DiscoveryAgentProfile -HostName 'claude-code' -AgentType 'legacy-parity-analyst' -WorkspaceRoot $script:RepoRoot
        $record.ProfilePath | Should -Be '.claude/agents/legacy-parity-analyst.md'
        $record.ProfileSha256 | Should -Match '^[0-9a-f]{64}$'
    }

    It 'refuses the absent profile when the agent file does not exist under the workspace' {
        { Read-DiscoveryAgentProfile -HostName 'claude-code' -AgentType 'legacy-parity-analyst' -WorkspaceRoot 'C:/Users/Example/Repos/NoProfiles' } |
            Should -Throw -ExpectedMessage "AGENT_PROFILE_INVALID: '.claude/agents/legacy-parity-analyst.md' does not exist."
    }

    It 'reads committed text and lists committed entries through the store seams and returns nothing for absent paths' {
        $store = Get-DiscoveryStartStore
        $text = & $store.ReadText (Join-Path $script:RepoRoot '.github/hooks/discovery.json')
        $text | Should -Match '"'
        (& $store.ReadText 'C:/Users/Example/Repos/NoProfiles/missing.json') | Should -BeNullOrEmpty
        $entries = @(& $store.ListEntries (Join-Path $script:RepoRoot '.github/hooks'))
        $entries | Should -Contain 'discovery.json'
        @(& $store.ListEntries 'C:/Users/Example/Repos/NoProfiles').Count | Should -Be 0
    }
}
