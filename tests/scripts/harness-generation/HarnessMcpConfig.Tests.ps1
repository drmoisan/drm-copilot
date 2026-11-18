Set-StrictMode -Version Latest

# Unit suite for scripts/harness-generation/HarnessMcpConfig.psm1 (issue #1028).
#
# Every case renders against an in-memory tree: the parity matrix, the MCP source, the package version
# source and the targets are strings in a dictionary read through the context seam. No temporary file,
# process or network call is made.

Describe 'HarnessMcpConfig module' {
    BeforeAll {
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/harness-generation/HarnessGeneration.psm1') -Force
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/harness-generation/HarnessMcpConfig.psm1') -Force

        $script:Matrix = @'
{"features":[
 {"id":"claude:mcp-server:srv","ecosystem":"claude","kind":"mcp-server","name":"srv","disposition":"generated","target_paths":[".mcp.json"],"owner_child":3},
 {"id":"codex:mcp-server:srv","ecosystem":"codex","kind":"mcp-server","name":"srv","disposition":"generated","target_paths":[".codex/config.toml"],"owner_child":3},
 {"id":"claude:mcp-server:other","ecosystem":"claude","kind":"mcp-server","name":"other","disposition":"native","target_paths":[".mcp.json"],"owner_child":3}
]}
'@
        $script:Source = @'
{"servers":[{"name":"srv","command":"npx","package":"@scope/pkg","args":["-y"],
 "claude":{"pin_version":false},
 "codex":{"pin_version":true,"version_source":"packages/mcp-server/package.json","required":true,
  "enabled_tools":["tool_a","tool_b"],"default_tools_approval_mode":"prompt",
  "tool_approval_modes":[{"tool":"tool_a","approval_mode":"approve"}]}}]}
'@
        $script:TomlBefore = "default_permissions = `":danger-full-access`"`n`n"
        $script:TomlAfter = "[permissions.ws]`ndescription = `"d`"`n`n[features]`nx = true`n`n[agents]`ny = 1`n`n[[hooks.PreToolUse]]`nmatcher = `"*`"`n"
        $script:Region = "[mcp_servers.srv]`ncommand = `"npx`"`nargs = [`"-y`", `"@scope/pkg@9.8.7`"]`nrequired = true`nenabled_tools = [`n    `"tool_a`",`n    `"tool_b`",`n]`ndefault_tools_approval_mode = `"prompt`"`n`n[mcp_servers.srv.tools.tool_a]`napproval_mode = `"approve`"`n`n"

        function New-McpTree {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
            param([System.Collections.IDictionary] $Override = @{})
            $store = [ordered]@{
                'config/harness-parity-matrix.json'                                                   = $script:Matrix
                'scripts/harness-generation/sources/mcp-servers.json'                                 = $script:Source
                'packages/mcp-server/package.json'                                                    = '{"name":"pkg","version":"9.8.7"}'
                '.mcp.json'                                                                           = "{}`n"
                'extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json'                = "{}`n"
                '.codex/config.toml'                                                                  = $script:TomlBefore + "[mcp_servers.srv]`ncommand = `"old`"`n`n" + $script:TomlAfter
                'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml' = $script:TomlBefore + "[mcp_servers.srv]`ncommand = `"old`"`n`n" + $script:TomlAfter
            }
            foreach ($key in $Override.Keys) { if ($null -eq $Override[$key]) { $store.Remove($key) } else { $store[$key] = $Override[$key] } }
            $writes = [System.Collections.Generic.List[string]]::new()
            $context = New-HarnessGenerationContext -Root 'fake-root' `
                -ReadFile { param([string] $Path) if ($store.Contains($Path)) { $store[$Path] } else { $null } }.GetNewClosure() `
                -ListFiles { @() } -TestReparse { $false }
            return [pscustomobject]@{ Store = $store; Context = $context; Writes = $writes; Writer = { param([string] $Path, [string] $Text) $writes.Add($Path); $store[$Path] = $Text }.GetNewClosure() }
        }
    }

    AfterAll {
        Remove-Module -Name HarnessMcpConfig, HarnessGeneration -Force -ErrorAction SilentlyContinue
    }

    It 'renders .mcp.json with the unpinned Claude args on one line' {
        $files = (Get-HarnessMcpFileMap -Context (New-McpTree).Context).Files
        $files['.mcp.json'] | Should -BeExactly "{`n  `"mcpServers`": {`n    `"srv`": {`n      `"command`": `"npx`",`n      `"args`": [`"-y`", `"@scope/pkg`"]`n    }`n  }`n}`n"
    }

    It 'renders the Codex args on one line pinned to the version source version' {
        $toml = (Get-HarnessMcpFileMap -Context (New-McpTree).Context).Files['.codex/config.toml']
        ($toml -split "`n") | Should -Contain 'args = ["-y", "@scope/pkg@9.8.7"]'
    }

    It 'replaces only the [mcp_servers.*] region and keeps every byte before and after it' {
        $toml = (Get-HarnessMcpFileMap -Context (New-McpTree).Context).Files['.codex/config.toml']
        $toml | Should -BeExactly ($script:TomlBefore + $script:Region + $script:TomlAfter)
    }

    It 'writes the bundle copy of every target' {
        $files = (Get-HarnessMcpFileMap -Context (New-McpTree).Context).Files
        @($files.Keys) | Should -Be @('.mcp.json', 'extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json', '.codex/config.toml', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml')
        $files['extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json'] | Should -BeExactly $files['.mcp.json']
    }

    It 'reports a drifted region in check mode and writes nothing' {
        $tree = New-McpTree
        $result = Invoke-HarnessGeneration -Surface 'mcp' -Context $tree.Context -Check -Providers @{ mcp = { param($Context) Get-HarnessMcpFileMap -Context $Context } } -WriteFile $tree.Writer
        $result.ExitCode | Should -Be 1
        $result.Report | Should -Contain 'DRIFT .codex/config.toml (content differs)'
        $tree.Writes.Count | Should -Be 0
    }

    It 'reports no drift after a write run' {
        $tree = New-McpTree
        $provider = @{ mcp = { param($Context) Get-HarnessMcpFileMap -Context $Context } }
        $null = Invoke-HarnessGeneration -Surface 'mcp' -Context $tree.Context -Providers $provider -WriteFile $tree.Writer
        (Invoke-HarnessGeneration -Surface 'mcp' -Context $tree.Context -Check -Providers $provider).ExitCode | Should -Be 0
        $tree.Store['.codex/config.toml'] | Should -BeExactly ($script:TomlBefore + $script:Region + $script:TomlAfter)
    }

    It 'fails before any write when a server has no command' {
        $tree = New-McpTree -Override @{ 'scripts/harness-generation/sources/mcp-servers.json' = '{"servers":[{"name":"srv","package":"p","args":[]}]}' }
        { Invoke-HarnessGeneration -Surface 'mcp' -Context $tree.Context -Providers @{ mcp = { param($Context) Get-HarnessMcpFileMap -Context $Context } } -WriteFile $tree.Writer } |
            Should -Throw -ExpectedMessage "*sources/mcp-servers.json*missing 'command'*"
        $tree.Writes.Count | Should -Be 0
    }

    It 'fails for a malformed source or target' -ForEach @(
        @{ Name = 'absent source'; Override = @{ 'scripts/harness-generation/sources/mcp-servers.json' = $null }; Pattern = '*does not exist*' }
        @{ Name = 'no servers key'; Override = @{ 'scripts/harness-generation/sources/mcp-servers.json' = '{"x":1}' }; Pattern = "*missing 'servers'*" }
        @{ Name = 'selected server absent'; Override = @{ 'scripts/harness-generation/sources/mcp-servers.json' = '{"servers":[{"name":"zz","command":"c","package":"p","args":[]}]}' }; Pattern = "*no single server named 'srv'*" }
        @{ Name = 'no codex block'; Override = @{ 'scripts/harness-generation/sources/mcp-servers.json' = '{"servers":[{"name":"srv","command":"c","package":"p","args":[],"claude":{}}]}' }; Pattern = "*has no 'codex' block*" }
        @{ Name = 'no version source'; Override = @{ 'scripts/harness-generation/sources/mcp-servers.json' = '{"servers":[{"name":"srv","command":"c","package":"p","args":[],"claude":{},"codex":{"pin_version":true}}]}' }; Pattern = "*no 'version_source'*" }
        @{ Name = 'absent version file'; Override = @{ 'packages/mcp-server/package.json' = $null }; Pattern = '*packages/mcp-server/package.json*does not exist*' }
        @{ Name = 'no version'; Override = @{ 'packages/mcp-server/package.json' = '{"name":"pkg"}' }; Pattern = "*has no 'version'*" }
        @{ Name = 'absent toml'; Override = @{ '.codex/config.toml' = $null }; Pattern = "*'.codex/config.toml' does not exist*" }
        @{ Name = 'no region'; Override = @{ '.codex/config.toml' = "[features]`nx = 1`n" }; Pattern = '*has no `[mcp_servers.`*`] region*' }
    ) {
        { Get-HarnessMcpFileMap -Context (New-McpTree -Override $Override).Context } | Should -Throw -ExpectedMessage $Pattern -Because $Name
    }

    It 'renders an unpinned Codex block without optional keys' {
        $server = [pscustomobject]@{ name = 'srv'; command = 'node'; package = 'p'; args = @(); codex = [pscustomobject]@{} }
        Format-HarnessCodexMcpRegion -Servers @($server) -Version '1.0.0' | Should -BeExactly "[mcp_servers.srv]`ncommand = `"node`"`nargs = [`"p`"]`n`n"
    }

    It 'separates several Claude servers with a comma' {
        $servers = @(
            [pscustomobject]@{ name = 'a'; command = 'c'; package = 'p'; args = @() }
            [pscustomobject]@{ name = 'b'; command = 'c'; package = 'q'; args = @() })
        (Format-HarnessClaudeMcpJson -Servers $servers) | Should -Match '(?s)"a": \{.*\},\n    "b": \{'
    }

    It 'replaces a region that runs to the end of the text' {
        Merge-HarnessCodexMcpRegion -Text "a = 1`n[mcp_servers.x]`nold = 1`n" -Region "[mcp_servers.x]`nnew = 2`n" -TargetPath 't.toml' | Should -BeExactly "a = 1`n[mcp_servers.x]`nnew = 2`n"
    }
}
