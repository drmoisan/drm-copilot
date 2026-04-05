Set-StrictMode -Version Latest

Describe "sync-agents-from-instructions.ps1" {
    BeforeAll {
        $env:POSHQC_SKIP_SCRIPT_EXECUTION = '1'
        $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\scripts\dev-tools\sync-agents-from-instructions.ps1"
        . $script:scriptPath
    }

    Context "Get-InstructionsBody" {
        It "throws when file is missing" {
            Mock -CommandName Test-Path -MockWith { $false }

            { Get-InstructionsBody -Path "missing.md" } | Should -Throw -ExpectedMessage "Instructions file not found: missing.md"
        }

        It "returns trimmed content without frontmatter" {
            $content = @"
---
applyTo: "**"
---

line1
line2
"@
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-Content -MockWith { $content }

            $result = Get-InstructionsBody -Path "dummy.md"
            $normalized = $result -replace "`r`n", "`n"
            $normalized | Should -Be "line1`nline2"
        }

        It "returns empty string for empty file" {
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-Content -MockWith { $null }

            $result = Get-InstructionsBody -Path "empty.md"
            $result | Should -Be ""
        }

        It "returns empty string for file with only frontmatter" {
            $content = @"
---
applyTo: "**"
---
"@
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-Content -MockWith { $content }

            $result = Get-InstructionsBody -Path "frontmatter-only.md"
            $result | Should -Be ""
        }
    }

    Context "Get-AgentContent failure paths" {
        It "Get-AgentContent succeeds when .github/copilot-instructions.md is missing" {
            Mock -CommandName Test-Path -MockWith {
                param($LiteralPath)

                if ($LiteralPath -eq (Join-Path -Path "/repo" -ChildPath ".github/copilot-instructions.md")) {
                    return $false
                }

                return $true
            }

            $minimalFiles = @(
                [pscustomobject]@{
                    Path            = "/repo/.github/instructions/general-code-change.instructions.md"
                    RelativePath    = ".github/instructions/general-code-change.instructions.md"
                    Body            = "general code body"
                    FrontMatterName = $null
                    FirstHeading    = "General Code Change Policy"
                }
            )
            Mock -CommandName Get-DiscoveredInstructionFile -MockWith { $minimalFiles }

            $result = Get-AgentContent -RepoRootParam "/repo"
            $result.Content | Should -Not -Match 'copilot-instructions'
        }
    }

    Context "Get-DiscoveredInstructionFile" {
        It "Get-DiscoveredInstructionFile throws when no supported instruction files are discovered" {
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-ChildItem -MockWith { @() }

            { Get-DiscoveredInstructionFile -RepoRootParam "/repo" } | Should -Throw -ExpectedMessage "No supported instruction files were discovered under /repo/.github"
        }

        It "Get-DiscoveredInstructionFile sorts normalized relative paths ordinally" {
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-ChildItem -MockWith {
                @(
                    [pscustomobject]@{ FullName = 'C:\repo\.github\a.instructions.md' }
                    [pscustomobject]@{ FullName = 'C:\repo\.github\B.instructions.md' }
                    [pscustomobject]@{ FullName = 'C:\repo\.github\sub\c.instructions.md' }
                )
            }
            Mock -CommandName Get-InstructionFileData -MockWith {
                param($Path, $RepoRootParam)

                [void]$RepoRootParam
                $relativePath = $Path.Substring('C:\repo\'.Length) -replace '\\', '/'
                [pscustomobject]@{
                    Path            = $Path
                    RelativePath    = $relativePath
                    Body            = ''
                    FrontMatterName = $null
                    FirstHeading    = $null
                }
            }

            $result = Get-DiscoveredInstructionFile -RepoRootParam 'C:\repo'
            $result.RelativePath | Should -Be @(
                '.github/B.instructions.md'
                '.github/a.instructions.md'
                '.github/sub/c.instructions.md'
            )
        }

        It "Get-DiscoveredInstructionFile preserves deterministic ordering within the general and language-specific groups" {
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-ChildItem -MockWith {
                @(
                    [pscustomobject]@{ FullName = 'C:\repo\.github\instructions\python-code-change.instructions.md' }
                    [pscustomobject]@{ FullName = 'C:\repo\.github\instructions\general-unit-test.instructions.md' }
                    [pscustomobject]@{ FullName = 'C:\repo\.github\instructions\typescript-code-change.instructions.md' }
                    [pscustomobject]@{ FullName = 'C:\repo\.github\instructions\csharp-code-change.instructions.md' }
                    [pscustomobject]@{ FullName = 'C:\repo\.github\instructions\general-code-change.instructions.md' }
                    [pscustomobject]@{ FullName = 'C:\repo\.github\instructions\powershell-code-change.instructions.md' }
                )
            }
            Mock -CommandName Get-InstructionFileData -MockWith {
                param($Path, $RepoRootParam)

                [void]$RepoRootParam
                $relativePath = $Path.Substring('C:\repo\'.Length) -replace '\\', '/'
                [pscustomobject]@{
                    Path            = $Path
                    RelativePath    = $relativePath
                    Body            = ''
                    FrontMatterName = $null
                    FirstHeading    = $null
                }
            }

            $result = Get-DiscoveredInstructionFile -RepoRootParam 'C:\repo'
            $result.RelativePath | Should -Be @(
                '.github/instructions/general-code-change.instructions.md'
                '.github/instructions/general-unit-test.instructions.md'
                '.github/instructions/csharp-code-change.instructions.md'
                '.github/instructions/powershell-code-change.instructions.md'
                '.github/instructions/python-code-change.instructions.md'
                '.github/instructions/typescript-code-change.instructions.md'
            )
        }
    }

    Context "Get-AgentContent" {
        BeforeEach {
            $script:copilotPath = Join-Path -Path "/repo" -ChildPath ".github/copilot-instructions.md"
            $script:instructionsDir = Join-Path -Path "/repo" -ChildPath ".github/instructions"
            $script:discoveredInstructionFiles = @(
                [pscustomobject]@{ Path = (Join-Path -Path $script:instructionsDir -ChildPath "general-code-change.instructions.md"); RelativePath = ".github/instructions/general-code-change.instructions.md"; Body = "general code"; FrontMatterName = $null; FirstHeading = $null }
                [pscustomobject]@{ Path = (Join-Path -Path $script:instructionsDir -ChildPath "general-unit-test.instructions.md"); RelativePath = ".github/instructions/general-unit-test.instructions.md"; Body = "general unit"; FrontMatterName = $null; FirstHeading = $null }
                [pscustomobject]@{ Path = (Join-Path -Path $script:instructionsDir -ChildPath "github-actions.instructions.md"); RelativePath = ".github/instructions/github-actions.instructions.md"; Body = "gh actions"; FrontMatterName = $null; FirstHeading = $null }
                [pscustomobject]@{ Path = (Join-Path -Path $script:instructionsDir -ChildPath "python-code-change.instructions.md"); RelativePath = ".github/instructions/python-code-change.instructions.md"; Body = "python code"; FrontMatterName = $null; FirstHeading = $null }
                [pscustomobject]@{ Path = (Join-Path -Path $script:instructionsDir -ChildPath "python-unit-test.instructions.md"); RelativePath = ".github/instructions/python-unit-test.instructions.md"; Body = "python unit"; FrontMatterName = $null; FirstHeading = $null }
                [pscustomobject]@{ Path = (Join-Path -Path $script:instructionsDir -ChildPath "python-suppressions.instructions.md"); RelativePath = ".github/instructions/python-suppressions.instructions.md"; Body = "python suppressions policy content"; FrontMatterName = "Python Suppression Policy (noqa and type: ignore)"; FirstHeading = $null }
                [pscustomobject]@{ Path = (Join-Path -Path $script:instructionsDir -ChildPath "powershell-code-change.instructions.md"); RelativePath = ".github/instructions/powershell-code-change.instructions.md"; Body = "ps code"; FrontMatterName = $null; FirstHeading = $null }
                [pscustomobject]@{ Path = (Join-Path -Path $script:instructionsDir -ChildPath "powershell-unit-test.instructions.md"); RelativePath = ".github/instructions/powershell-unit-test.instructions.md"; Body = "ps unit"; FrontMatterName = $null; FirstHeading = $null }
                [pscustomobject]@{ Path = (Join-Path -Path $script:instructionsDir -ChildPath "codexer.instructions.md"); RelativePath = ".github/instructions/codexer.instructions.md"; Body = "codexer unit"; FrontMatterName = "Codexer Policy"; FirstHeading = $null }
                [pscustomobject]@{ Path = (Join-Path -Path $script:instructionsDir -ChildPath "self-explanatory-code-commenting.instructions.md"); RelativePath = ".github/instructions/self-explanatory-code-commenting.instructions.md"; Body = "self-explanatory-code-commenting unit"; FrontMatterName = "Code Commenting and Docstring Policy"; FirstHeading = $null }
            )
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-DiscoveredInstructionFile -MockWith { $script:discoveredInstructionFiles }
            Mock -CommandName Get-InstructionsBody -MockWith {
                param($Path)
                switch ($Path) {
                    { $_ -eq $script:copilotPath } { return "copilot body" }
                    default { throw "Unexpected path $Path" }
                }
            }
        }

        It "Get-AgentContent includes a newly added .instructions.md file without a section allowlist update" {
            $newInstructionPath = Join-Path -Path $script:instructionsDir -ChildPath "new-surface.instructions.md"
            $script:discoveredInstructionFiles = @(
                [pscustomobject]@{ Path = (Join-Path -Path $script:instructionsDir -ChildPath "general-code-change.instructions.md"); RelativePath = ".github/instructions/general-code-change.instructions.md"; Body = "general code"; FrontMatterName = $null; FirstHeading = $null }
                [pscustomobject]@{ Path = $newInstructionPath; RelativePath = ".github/instructions/new-surface.instructions.md"; Body = "new surface body"; FrontMatterName = $null; FirstHeading = $null }
            )

            $result = Get-AgentContent -RepoRootParam "/repo"

            $result.Content | Should -Match "new-surface.instructions.md"
            $result.Content | Should -Match "new surface body"
        }

        It "builds AGENTS content with all sections" {
            $result = Get-AgentContent -RepoRootParam "/repo"

            $expectedPath = Join-Path -Path "/repo" -ChildPath "AGENTS.md"
            $result.Path | Should -Be $expectedPath
            $result.Content | Should -Match "# AGENTS.md"
            $result.Content | Should -Match "copilot body"
            $result.Content | Should -Match "general code"
            $result.Content | Should -Match "ps unit"
            $result.Content | Should -Match "codexer unit"
            $result.Content | Should -Match "self-explanatory-code-commenting unit"
        }
    }

    Context "Get-AgentContent ordering" {
        BeforeEach {
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-InstructionsBody -MockWith {
                param($Path)

                if ($Path -eq (Join-Path -Path 'C:\repo' -ChildPath '.github/copilot-instructions.md')) {
                    return 'copilot body'
                }

                throw "Unexpected path $Path"
            }
            Mock -CommandName Get-ChildItem -MockWith {
                @(
                    [pscustomobject]@{ FullName = 'C:\repo\.github\instructions\python-code-change.instructions.md' }
                    [pscustomobject]@{ FullName = 'C:\repo\.github\instructions\general-unit-test.instructions.md' }
                    [pscustomobject]@{ FullName = 'C:\repo\.github\instructions\csharp-code-change.instructions.md' }
                    [pscustomobject]@{ FullName = 'C:\repo\.github\instructions\general-code-change.instructions.md' }
                )
            }
            Mock -CommandName Get-InstructionFileData -MockWith {
                param($Path, $RepoRootParam)

                [void]$RepoRootParam
                $relativePath = $Path.Substring('C:\repo\'.Length) -replace '\\', '/'

                return [pscustomobject]@{
                    Path            = $Path
                    RelativePath    = $relativePath
                    Body            = "body for $relativePath"
                    FrontMatterName = $null
                    FirstHeading    = $null
                }
            }
        }

        It "emits general instruction files before language-specific instruction files in generated AGENTS.md output" {
            $result = Get-AgentContent -RepoRootParam 'C:\repo'

            $generalCodeIndex = $result.Content.IndexOf('> - .github/instructions/general-code-change.instructions.md', [System.StringComparison]::Ordinal)
            $generalUnitIndex = $result.Content.IndexOf('> - .github/instructions/general-unit-test.instructions.md', [System.StringComparison]::Ordinal)
            $csharpIndex = $result.Content.IndexOf('> - .github/instructions/csharp-code-change.instructions.md', [System.StringComparison]::Ordinal)
            $pythonIndex = $result.Content.IndexOf('> - .github/instructions/python-code-change.instructions.md', [System.StringComparison]::Ordinal)

            $generalCodeIndex | Should -BeLessThan $csharpIndex
            $generalCodeIndex | Should -BeLessThan $pythonIndex
            $generalUnitIndex | Should -BeLessThan $csharpIndex
            $generalUnitIndex | Should -BeLessThan $pythonIndex
        }
    }

    Context "Invoke-SyncAgentInstruction" {
        It "Invoke-SyncAgentInstruction produces identical content on repeated runs when inputs are unchanged" {
            $copilotPath = Join-Path -Path "/repo" -ChildPath ".github/copilot-instructions.md"
            $instructionsDir = Join-Path -Path "/repo" -ChildPath ".github/instructions"
            $newInstructionPath = Join-Path -Path $instructionsDir -ChildPath "new-surface.instructions.md"
            $writes = [System.Collections.Generic.List[string]]::new()

            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-DiscoveredInstructionFile -MockWith {
                @(
                    [pscustomobject]@{ Path = (Join-Path -Path $instructionsDir -ChildPath "general-code-change.instructions.md"); RelativePath = ".github/instructions/general-code-change.instructions.md"; Body = "general code"; FrontMatterName = $null; FirstHeading = $null }
                    [pscustomobject]@{ Path = $newInstructionPath; RelativePath = ".github/instructions/new-surface.instructions.md"; Body = "new surface body"; FrontMatterName = $null; FirstHeading = $null }
                )
            }
            Mock -CommandName Get-InstructionsBody -MockWith {
                param($Path)

                switch ($Path) {
                    { $_ -eq $copilotPath } { return "copilot body" }
                    default { throw "Unexpected path $Path" }
                }
            }
            Mock -CommandName Set-Content -MockWith {
                param($LiteralPath, $Value)

                [void]$LiteralPath
                $writes.Add($Value)
            }
            Mock -CommandName Write-Output -MockWith { }

            Invoke-SyncAgentInstruction -RepoRootParam "/repo"
            Invoke-SyncAgentInstruction -RepoRootParam "/repo"

            $writes.Count | Should -Be 2
            $writes[0] | Should -Be $writes[1]
            $writes[0] | Should -Match "new-surface.instructions.md"
        }

        It "writes generated content to AGENTS.md" {
            $expected = [pscustomobject]@{ Path = "/work/AGENTS.md"; Content = "content" }
            Mock -CommandName Get-AgentContent -MockWith { param($RepoRootParam) [void]$RepoRootParam; $expected }
            Mock -CommandName Set-Content -MockWith { }
            Mock -CommandName Write-Output -MockWith { }

            Invoke-SyncAgentInstruction -RepoRootParam "/work"

            Should -Invoke -CommandName Get-AgentContent -Times 1 -ParameterFilter { $RepoRootParam -eq "/work" }
            Should -Invoke -CommandName Set-Content -Times 1 -ParameterFilter { $LiteralPath -eq "/work/AGENTS.md" -and $Value -eq "content" -and $NoNewline }
            Should -Invoke -CommandName Write-Output -Times 1
        }
    }

    Context "Get-AgentContent optional preamble" {
        It "Get-AgentContent succeeds when copilot-instructions.md is absent" {
            Mock -CommandName Test-Path -MockWith {
                param($LiteralPath)

                if ($LiteralPath -eq (Join-Path -Path "/repo" -ChildPath ".github/copilot-instructions.md")) {
                    return $false
                }

                return $true
            }

            $minimalFiles = @(
                [pscustomobject]@{
                    Path            = "/repo/.github/instructions/general-code-change.instructions.md"
                    RelativePath    = ".github/instructions/general-code-change.instructions.md"
                    Body            = "general code body"
                    FrontMatterName = $null
                    FirstHeading    = "General Code Change Policy"
                }
            )
            Mock -CommandName Get-DiscoveredInstructionFile -MockWith { $minimalFiles }

            $result = Get-AgentContent -RepoRootParam "/repo"
            $result.Content | Should -Not -Match '<!-- BEGIN: copilot-instructions -->'
        }

        It "header omits copilot-instructions.md from source list when preamble is absent" {
            Mock -CommandName Test-Path -MockWith {
                param($LiteralPath)

                if ($LiteralPath -eq (Join-Path -Path "/repo" -ChildPath ".github/copilot-instructions.md")) {
                    return $false
                }

                return $true
            }

            $minimalFiles = @(
                [pscustomobject]@{
                    Path            = "/repo/.github/instructions/general-code-change.instructions.md"
                    RelativePath    = ".github/instructions/general-code-change.instructions.md"
                    Body            = "general code body"
                    FrontMatterName = $null
                    FirstHeading    = "General Code Change Policy"
                }
                [pscustomobject]@{
                    Path            = "/repo/.github/instructions/python-code-change.instructions.md"
                    RelativePath    = ".github/instructions/python-code-change.instructions.md"
                    Body            = "python code body"
                    FrontMatterName = $null
                    FirstHeading    = "Python Code Change Policy"
                }
            )
            Mock -CommandName Get-DiscoveredInstructionFile -MockWith { $minimalFiles }

            $result = Get-AgentContent -RepoRootParam "/repo"
            $result.Content | Should -Not -Match '> - .github/copilot-instructions.md'
            $result.Content | Should -Match '.github/instructions/general-code-change.instructions.md'
            $result.Content | Should -Match '.github/instructions/python-code-change.instructions.md'
        }
    }

    Context "Get-AgentContent compaction" {
        BeforeEach {
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-InstructionsBody -MockWith {
                param($Path)

                [void]$Path
                return "copilot body"
            }
        }

        It "compacted output strips cross-reference boilerplate" {
            $bodyWithBoilerplate = @"
# Python Code Change Policy

This policy **extends** general-code-change.instructions.md and applies to all Python code.

Some unique content here.

halt and notify the user.
"@
            $minimalFiles = @(
                [pscustomobject]@{
                    Path            = "/repo/.github/instructions/python-code-change.instructions.md"
                    RelativePath    = ".github/instructions/python-code-change.instructions.md"
                    Body            = $bodyWithBoilerplate
                    FrontMatterName = $null
                    FirstHeading    = "Python Code Change Policy"
                }
            )
            Mock -CommandName Get-DiscoveredInstructionFile -MockWith { $minimalFiles }

            $result = Get-AgentContent -RepoRootParam "/repo"
            $result.Content | Should -Not -Match 'This policy \*\*extends\*\*'
            $result.Content | Should -Not -Match 'halt and notify the user'
            $result.Content | Should -Match 'Some unique content here'
        }

        It "compacted output removes repeated reading-order statements" {
            $bodyWithReadingOrder = @"
# General Code Change Policy

Apply this general policy first, then any language-specific code-change instructions.

Some actual policy content.
"@
            $minimalFiles = @(
                [pscustomobject]@{
                    Path            = "/repo/.github/instructions/general-code-change.instructions.md"
                    RelativePath    = ".github/instructions/general-code-change.instructions.md"
                    Body            = $bodyWithReadingOrder
                    FrontMatterName = $null
                    FirstHeading    = "General Code Change Policy"
                }
            )
            Mock -CommandName Get-DiscoveredInstructionFile -MockWith { $minimalFiles }

            $result = Get-AgentContent -RepoRootParam "/repo"
            $result.Content | Should -Not -Match 'Apply this general policy first'
            $result.Content | Should -Match 'Some actual policy content'
        }

        It "compacted output condenses suppression examples" {
            $bodyWithCodeBlock = @"
# Suppression Policy

### S603: subprocess call

**Required pattern:**

$('```')python
def example():
    pass
$('```')

**Justification:** This is the rationale.
"@
            $minimalFiles = @(
                [pscustomobject]@{
                    Path            = "/repo/.github/instructions/python-suppressions.instructions.md"
                    RelativePath    = ".github/instructions/python-suppressions.instructions.md"
                    Body            = $bodyWithCodeBlock
                    FrontMatterName = $null
                    FirstHeading    = "Suppression Policy"
                }
            )
            Mock -CommandName Get-DiscoveredInstructionFile -MockWith { $minimalFiles }

            $result = Get-AgentContent -RepoRootParam "/repo"
            $result.Content | Should -Not -Match 'def example\(\):'
            $result.Content | Should -Match 'This is the rationale'
        }

        It "compacted output strips approved-command lines" {
            $bodyWithApproved = @"
# Python Code Change Policy

1. **Formatting**
   - Approved command: poetry run black .

2. **Linting**
   - Approved command: poetry run ruff check

Some unique policy text.
"@
            $minimalFiles = @(
                [pscustomobject]@{
                    Path            = "/repo/.github/instructions/python-code-change.instructions.md"
                    RelativePath    = ".github/instructions/python-code-change.instructions.md"
                    Body            = $bodyWithApproved
                    FrontMatterName = $null
                    FirstHeading    = "Python Code Change Policy"
                }
            )
            Mock -CommandName Get-DiscoveredInstructionFile -MockWith { $minimalFiles }

            $result = Get-AgentContent -RepoRootParam "/repo"
            $result.Content | Should -Not -Match 'Approved command:'
            $result.Content | Should -Match 'Some unique policy text'
        }
    }

    Context "Bundled parity" {
        It "Bundled sync-agents template matches the repo-root script exactly" {
            $bundledTemplatePath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\extensions\drm-copilot\resources\templates\sync-agents-from-instructions.ps1"

            (Test-Path -LiteralPath $bundledTemplatePath) | Should -BeTrue
            (Get-Content -Raw -LiteralPath $bundledTemplatePath) | Should -Be (Get-Content -Raw -LiteralPath $script:scriptPath)
        }
    }
}

