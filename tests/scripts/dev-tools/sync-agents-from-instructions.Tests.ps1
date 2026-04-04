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
        It "Get-AgentContent throws when .github/copilot-instructions.md is missing" {
            Mock -CommandName Test-Path -MockWith {
                param($LiteralPath)

                if ($LiteralPath -eq (Join-Path -Path "/repo" -ChildPath ".github/copilot-instructions.md")) {
                    return $false
                }

                return $true
            }

            { Get-AgentContent -RepoRootParam "/repo" } | Should -Throw -ExpectedMessage "Required AGENTS preamble file not found: /repo/.github/copilot-instructions.md"
        }
    }

    Context "Get-DiscoveredInstructionFiles" {
        It "Get-DiscoveredInstructionFiles throws when no supported instruction files are discovered" {
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-ChildItem -MockWith { @() }

            { Get-DiscoveredInstructionFiles -RepoRootParam "/repo" } | Should -Throw -ExpectedMessage "No supported instruction files were discovered under /repo/.github"
        }

        It "Get-DiscoveredInstructionFiles sorts normalized relative paths ordinally" {
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
                    Path = $Path
                    RelativePath = $relativePath
                    Body = ''
                    FrontMatterName = $null
                    FirstHeading = $null
                }
            }

            $result = Get-DiscoveredInstructionFiles -RepoRootParam 'C:\repo'
            $result.RelativePath | Should -Be @(
                '.github/B.instructions.md'
                '.github/a.instructions.md'
                '.github/sub/c.instructions.md'
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
            Mock -CommandName Get-DiscoveredInstructionFiles -MockWith { $script:discoveredInstructionFiles }
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

    Context "Invoke-SyncAgentInstruction" {
        It "Invoke-SyncAgentInstruction produces identical content on repeated runs when inputs are unchanged" {
            $copilotPath = Join-Path -Path "/repo" -ChildPath ".github/copilot-instructions.md"
            $instructionsDir = Join-Path -Path "/repo" -ChildPath ".github/instructions"
            $newInstructionPath = Join-Path -Path $instructionsDir -ChildPath "new-surface.instructions.md"
            $writes = [System.Collections.Generic.List[string]]::new()

            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-DiscoveredInstructionFiles -MockWith {
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

    Context "Bundled parity" {
        It "Bundled sync-agents template matches the repo-root script exactly" {
            $bundledTemplatePath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\extensions\drm-copilot\resources\templates\sync-agents-from-instructions.ps1"

            (Test-Path -LiteralPath $bundledTemplatePath) | Should -BeTrue
            (Get-Content -Raw -LiteralPath $bundledTemplatePath) | Should -Be (Get-Content -Raw -LiteralPath $script:scriptPath)
        }
    }
}
