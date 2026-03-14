Set-StrictMode -Version Latest

BeforeAll {
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
    . (Resolve-Path -Path (Join-Path -Path $scriptRoot -ChildPath "../powershell/Support/TestHelpers.ps1"))
}

Describe "new-potential-entry.ps1 - Test-ValidShortName" {
    BeforeAll {
        $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/new-potential-entry.ps1"
    }

    Context "Valid short names" {
        BeforeEach {
            . (Import-ScriptFunction -Path $script:scriptPath -Name "Test-ValidShortName")
        }

        It "accepts single lowercase word" {
            Test-ValidShortName -Name "feature" | Should -Be $true
        }

        It "accepts kebab-case with two words" {
            Test-ValidShortName -Name "my-feature" | Should -Be $true
        }

        It "accepts kebab-case with multiple words" {
            Test-ValidShortName -Name "my-new-feature" | Should -Be $true
        }

        It "accepts numbers in the name" {
            Test-ValidShortName -Name "feature-v2" | Should -Be $true
        }

        It "accepts name with only numbers" {
            Test-ValidShortName -Name "123" | Should -Be $true
        }

        It "accepts mixed alphanumeric kebab-case" {
            Test-ValidShortName -Name "abc123-def456" | Should -Be $true
        }
    }

    Context "Invalid short names" {
        BeforeEach {
            . (Import-ScriptFunction -Path $script:scriptPath -Name "Test-ValidShortName")
        }

        It "rejects uppercase letters" {
            Test-ValidShortName -Name "MyFeature" | Should -Be $false
        }

        It "rejects spaces" {
            Test-ValidShortName -Name "my feature" | Should -Be $false
        }

        It "rejects underscores" {
            Test-ValidShortName -Name "my_feature" | Should -Be $false
        }

        It "rejects trailing hyphen" {
            Test-ValidShortName -Name "feature-" | Should -Be $false
        }

        It "rejects leading hyphen" {
            Test-ValidShortName -Name "-feature" | Should -Be $false
        }

        It "rejects double hyphens" {
            Test-ValidShortName -Name "my--feature" | Should -Be $false
        }

        It "rejects special characters" {
            Test-ValidShortName -Name "my@feature" | Should -Be $false
        }

        It "rejects empty string" {
            Test-ValidShortName -Name "" | Should -Be $false
        }
    }
}

Describe "new-potential-entry.ps1 - Get-AuthorName" {
    BeforeAll {
        $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/new-potential-entry.ps1"
    }

    Context "Author name retrieval" {
        BeforeEach {
            . (Import-ScriptFunction -Path $script:scriptPath -Name "Get-AuthorName")
        }

        It "returns git config user.name when available" {
            $result = Get-AuthorName -GetGitConfig { param($Key) $null = $Key; "John Doe" }
            $result | Should -Be "John Doe"
        }

        It "falls back to USERNAME environment variable when git fails" {
            $result = Get-AuthorName `
                -GetGitConfig { param($Key) $null = $Key; $null } `
                -GetEnvironmentVariable { param($Name) $null = $Name; "WindowsUser" }
            $result | Should -Be "WindowsUser"
        }

        It "returns 'Unknown' when git returns empty and no USERNAME" {
            $result = Get-AuthorName `
                -GetGitConfig { param($Key) $null = $Key; "" } `
                -GetEnvironmentVariable { param($Name) $null = $Name; $null }
            $result | Should -Be "Unknown"
        }

        It "returns 'Unknown' when git returns whitespace only" {
            $result = Get-AuthorName `
                -GetGitConfig { param($Key) $null = $Key; "   " } `
                -GetEnvironmentVariable { param($Name) $null = $Name; $null }
            $result | Should -Be "Unknown"
        }
    }
}

Describe "new-potential-entry.ps1 - Convert-TemplateContent" {
    BeforeAll {
        $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/new-potential-entry.ps1"
    }

    Context "Template content replacement" {
        BeforeEach {
            . (Import-ScriptFunction -Path $script:scriptPath -Name "Convert-TemplateContent")
        }

        It "replaces feature-name placeholder" {
            $content = '# <feature-name> (Potential)'
            $result = Convert-TemplateContent -Content $content -ShortName "my-feature" -Date "2025-12-10" -Author "Test User"
            $result | Should -Be "# my-feature (Potential)"
        }

        It "replaces date placeholder" {
            $content = '- Date captured: YYYY-MM-DD'
            $result = Convert-TemplateContent -Content $content -ShortName "my-feature" -Date "2025-12-10" -Author "Test User"
            $result | Should -Be "- Date captured: 2025-12-10"
        }

        It "replaces author placeholder" {
            $content = '- Author: name'
            $result = Convert-TemplateContent -Content $content -ShortName "my-feature" -Date "2025-12-10" -Author "Test User"
            $result | Should -Be "- Author: Test User"
        }

        It "replaces frontmatter owner placeholder" {
            $content = 'owner: "<name>"'
            $result = Convert-TemplateContent -Content $content -ShortName "my-feature" -Date "2025-12-10" -Author "Test User"
            $result | Should -Be 'owner: "Test User"'
        }

        It "replaces frontmatter last_updated placeholder" {
            $content = 'last_updated: "<yyyy-MM-ddTHH-mm>"'
            $result = Convert-TemplateContent -Content $content -ShortName "my-feature" -Date "2025-12-10" -Author "Test User" -LastUpdated "2026-02-03T09-15"
            $result | Should -Be 'last_updated: "2026-02-03T09-15"'
        }

        It "replaces frontmatter status placeholder" {
            $content = 'status: "<status>"'
            $result = Convert-TemplateContent -Content $content -ShortName "my-feature" -Date "2025-12-10" -Author "Test User" -Status "Draft"
            $result | Should -Be 'status: "Draft"'
        }

        It "replaces frontmatter status_color placeholder" {
            $content = 'status_color: "<color>"'
            $result = Convert-TemplateContent -Content $content -ShortName "my-feature" -Date "2025-12-10" -Author "Test User" -StatusColor "lightgrey"
            $result | Should -Be 'status_color: "lightgrey"'
        }

        It "replaces frontmatter issue placeholder" {
            $content = 'issue: "<issue>"'
            $result = Convert-TemplateContent -Content $content -ShortName "my-feature" -Date "2025-12-10" -Author "Test User" -Issue "TBD"
            $result | Should -Be 'issue: "TBD"'
        }

        It "replaces frontmatter parent placeholder" {
            $content = 'parent: "<parent-id>"'
            $result = Convert-TemplateContent -Content $content -ShortName "my-feature" -Date "2025-12-10" -Author "Test User" -Parent "none"
            $result | Should -Be 'parent: "none"'
        }

        It "replaces frontmatter version placeholder" {
            $content = 'version: "<version_number>"'
            $result = Convert-TemplateContent -Content $content -ShortName "my-feature" -Date "2025-12-10" -Author "Test User" -Version "0.1"
            $result | Should -Be 'version: "0.1"'
        }

        It "replaces all placeholders in complete template" {
            $content = @"
# <feature-name> (Potential)

- Date captured: YYYY-MM-DD
- Author: name
- Status: Draft
"@
            $result = Convert-TemplateContent -Content $content -ShortName "my-feature" -Date "2025-12-10" -Author "Test User" -LastUpdated "2026-02-03T09-15" -Status "Draft" -StatusColor "lightgrey" -Issue "TBD" -Parent "none" -Version "0.1"
            $result | Should -Match "# my-feature \(Potential\)"
            $result | Should -Match "- Date captured: 2025-12-10"
            $result | Should -Match "- Author: Test User"
            $result | Should -Not -Match "<feature-name>"
            $result | Should -Not -Match "YYYY-MM-DD"
            $result | Should -Not -Match "- Author: name"
        }

        It "handles multiple occurrences of feature-name" {
            $content = "<feature-name> and <feature-name>"
            $result = Convert-TemplateContent -Content $content -ShortName "test" -Date "2025-12-10" -Author "Test User"
            $result | Should -Be "test and test"
        }
    }
}

Describe "new-potential-entry.ps1 - Invoke-VSCodeOpen" {
    BeforeAll {
        $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/new-potential-entry.ps1"
        $script:vscodeHelperPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/vscode-cli.helpers.ps1"
    }

    Context "VS Code command detection and execution" {
        BeforeEach {
            . (Import-ScriptFunction -Path $script:vscodeHelperPath -Name "Test-IsVSCodeInsidersSession")
            . (Import-ScriptFunction -Path $script:vscodeHelperPath -Name "Resolve-VSCodeCliCommand")
            . (Import-ScriptFunction -Path $script:scriptPath -Name "Invoke-VSCodeOpen")
        }

        It "returns true when code command is available" {
            $result = Invoke-VSCodeOpen -Files @("file1.md", "file2.md") `
                -GetCommand { param($Name) $null = $Name; [pscustomobject]@{ Name = "code" } } `
                -InvokeCommand { param($Exe, $CmdArgs) $null = $Exe; $null = $CmdArgs }

            $result | Should -Be $true
        }

        It "returns false when code command is not available" {
            $result = Invoke-VSCodeOpen -Files @("file1.md", "file2.md") `
                -GetCommand { param($Name) $null = $Name; $null }

            $result | Should -Be $false
        }

        It "invokes command with --reuse-window and correct executable" {
            $files = @("file1.md", "file2.md")
            $result = Invoke-VSCodeOpen -Files $files `
                -GetCommand { param($Name) $null = $Name; [pscustomobject]@{ Name = "code" } } `
                -InvokeCommand { param($Exe, $CmdArgs) $Exe | Should -Be 'code'; $CmdArgs | Should -Be (@('--reuse-window') + $files) }

            $result | Should -Be $true
        }

        It "prefers code-insiders when running in an Insiders session and both commands are available" {
            $files = @("file1.md", "file2.md")
            $originalTermProgramVersion = $env:TERM_PROGRAM_VERSION

            try {
                $env:TERM_PROGRAM_VERSION = "1.110.0-insider"
                $result = Invoke-VSCodeOpen -Files $files `
                    -GetCommand {
                    param($Name)
                    if ($Name -in @("code-insiders", "code")) {
                        return [pscustomobject]@{ Name = $Name }
                    }
                    return $null
                } `
                    -InvokeCommand {
                    param($Exe, $CmdArgs)
                    $Exe | Should -Be 'code-insiders'
                    $CmdArgs | Should -Be (@('--reuse-window') + $files)
                }

                $result | Should -Be $true
            }
            finally {
                $env:TERM_PROGRAM_VERSION = $originalTermProgramVersion
            }
        }
    }
}

Describe "vscode-cli.helpers.ps1 - Resolve-VSCodeCliCommand" {
    BeforeAll {
        $script:vscodeHelperPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/vscode-cli.helpers.ps1"
    }

    Context "Explicit command preference" {
        BeforeEach {
            . (Import-ScriptFunction -Path $script:vscodeHelperPath -Name "Test-IsVSCodeInsidersSession")
            . (Import-ScriptFunction -Path $script:vscodeHelperPath -Name "Resolve-VSCodeCliCommand")
        }

        It "returns the explicitly requested command when available" {
            $result = Resolve-VSCodeCliCommand -PreferredCommand "code" -GetCommand {
                param($Name)
                if ($Name -eq "code") {
                    return [pscustomobject]@{ Name = $Name }
                }

                return $null
            }

            $result | Should -Be "code"
        }

        It "throws when the explicitly requested command is unavailable" {
            {
                Resolve-VSCodeCliCommand -PreferredCommand "code" -GetCommand { param($Name) $null = $Name; $null }
            } | Should -Throw "*explicitly requested*"
        }
    }

    Context "Automatic command selection" {
        BeforeEach {
            . (Import-ScriptFunction -Path $script:vscodeHelperPath -Name "Test-IsVSCodeInsidersSession")
            . (Import-ScriptFunction -Path $script:vscodeHelperPath -Name "Resolve-VSCodeCliCommand")
        }

        It "prefers code-insiders when TERM_PROGRAM_VERSION indicates insiders" {
            $result = Resolve-VSCodeCliCommand `
                -GetCommand {
                param($Name)
                if ($Name -in @("code-insiders", "code")) {
                    return [pscustomobject]@{ Name = $Name }
                }

                return $null
            } `
                -GetEnvironmentVariable {
                param($Name)
                if ($Name -eq "TERM_PROGRAM_VERSION") {
                    return "1.110.0-insider"
                }

                return $null
            }

            $result | Should -Be "code-insiders"
        }

        It "falls back to code when insiders is preferred but unavailable" {
            $result = Resolve-VSCodeCliCommand `
                -GetCommand {
                param($Name)
                if ($Name -eq "code") {
                    return [pscustomobject]@{ Name = $Name }
                }

                return $null
            } `
                -GetEnvironmentVariable {
                param($Name)
                if ($Name -eq "TERM_PROGRAM_VERSION") {
                    return "1.110.0-insider"
                }

                return $null
            }

            $result | Should -Be "code"
        }

        It "returns null when no VS Code command is available" {
            $result = Resolve-VSCodeCliCommand -GetCommand { param($Name) $null = $Name; $null }
            $result | Should -Be $null
        }
    }
}

Describe "new-potential-entry.ps1 - Integration validation" {
    Context "Script structure validation" {
        It "contains all expected function definitions" {
            $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/new-potential-entry.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw

            $scriptContent | Should -Match "function Test-ValidShortName"
            $scriptContent | Should -Match "function Get-AuthorName"
            $scriptContent | Should -Match "function Convert-TemplateContent"
            $scriptContent | Should -Match "function Invoke-VSCodeOpen"
        }

        It "validates parameter declaration" {
            $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/new-potential-entry.ps1"
            $scriptContent = Get-Content -Path $scriptPath -Raw

            $scriptContent | Should -Match "param\(\s*\[string\]\s*\`$ShortName\s*\)"
        }

        It "contains the parent-directory guard block before copying the template in both production scripts" {
            $scriptPaths = @(
                (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/new-potential-entry.ps1"),
                (Join-Path -Path $PSScriptRoot -ChildPath "../../../extensions/drm-copilot/resources/templates/new-potential-entry.ps1")
            )

            # (?s) enables dot-all mode so .*? matches across newlines.
            $guardPattern = '(?s)' +
            [regex]::Escape('$targetDir = Split-Path -Parent $target') +
            '[\s\S]*?' +
            [regex]::Escape('if (-not (Test-Path $targetDir)) {') +
            '[\s\S]*?' +
            [regex]::Escape('New-Item -ItemType Directory -Path $targetDir -Force | Out-Null') +
            '[\s\S]*?' +
            [regex]::Escape('}') +
            '[\s\S]*?' +
            [regex]::Escape('Copy-Item $template $target -Force')

            foreach ($scriptPath in $scriptPaths) {
                $scriptContent = Get-Content -Path $scriptPath -Raw

                $scriptContent | Should -Match 'Split-Path -Parent \$target'
                $scriptContent | Should -Match 'Test-Path \$targetDir'
                $scriptContent | Should -Match 'New-Item -ItemType Directory -Path \$targetDir -Force \| Out-Null'
                $scriptContent | Should -Match $guardPattern
            }
        }

        It "uses reuse-window CLI invocation without Start-Process inside Invoke-VSCodeOpen in both production scripts" {
            $scriptPaths = @(
                (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/new-potential-entry.ps1"),
                (Join-Path -Path $PSScriptRoot -ChildPath "../../../extensions/drm-copilot/resources/templates/new-potential-entry.ps1")
            )

            foreach ($scriptPath in $scriptPaths) {
                $scriptContent = Get-Content -Path $scriptPath -Raw
                $invokeVsCodeOpenMatch = [regex]::Match(
                    $scriptContent,
                    'function Invoke-VSCodeOpen \{(?<body>.*?)\n\}',
                    [System.Text.RegularExpressions.RegexOptions]::Singleline
                )

                $invokeVsCodeOpenMatch.Success | Should -BeTrue
                $invokeVsCodeOpenBody = $invokeVsCodeOpenMatch.Groups['body'].Value

                $invokeVsCodeOpenBody | Should -Match '--reuse-window'
                $invokeVsCodeOpenBody | Should -Match 'VSCODE_IPC_HOOK_CLI|Get-Process.+insider'
                $invokeVsCodeOpenBody | Should -Not -Match 'Start-Process'
            }
        }
    }
}


