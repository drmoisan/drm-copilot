Set-StrictMode -Version Latest

$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
. (Resolve-Path -Path (Join-Path -Path $scriptRoot -ChildPath "../powershell/Support/TestHelpers.ps1"))

BeforeAll {
    $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\scripts\dev-tools\tree.ps1"
    . (Import-ScriptFunction -Path $script:scriptPath -Name "Show-Tree")
}

Describe "Show-Tree function" {
    Context "Basic file and directory listing" {
        It "lists files and directories with proper formatting" {
            # Arrange
            $items = @(
                [pscustomobject]@{ Name = "file.txt"; FullName = "/root\file.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal },
                [pscustomobject]@{ Name = "folder"; FullName = "/root\folder"; PSIsContainer = $true; Attributes = [IO.FileAttributes]::Directory }
            )

            Mock -CommandName Get-ChildItem -MockWith {
                param($LiteralPath, $Force)
                $null = $Force
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @() -IncludeHiddenEntries:$false -DirectoriesOnly:$false

            # Assert
            $outputText = $output -join "`n"
            $outputText | Should -Match "file\.txt"
            $outputText | Should -Match "\[dir\]"
            $outputText | Should -Match "folder"
        }

        It "formats directory entries with [dir] prefix in mixed mode" {
            # Arrange
            $items = @([pscustomobject]@{ Name = "mydir"; FullName = "/root\mydir"; PSIsContainer = $true; Attributes = [IO.FileAttributes]::Directory })

            Mock -CommandName Get-ChildItem -MockWith {
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @() -IncludeHiddenEntries:$false -DirectoriesOnly:$false

            # Assert
            $output | Should -Contain "[dir] mydir"
        }

        It "formats file entries with space prefix in mixed mode" {
            # Arrange
            $items = @([pscustomobject]@{ Name = "readme.md"; FullName = "/root\readme.md"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal })

            Mock -CommandName Get-ChildItem -MockWith {
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @() -IncludeHiddenEntries:$false -DirectoriesOnly:$false

            # Assert
            $output | Should -Match "^\s{6}readme\.md$"
        }
    }

    Context "Hidden file handling" {
        It "excludes hidden files when IncludeHiddenEntries is false" {
            # Arrange
            $items = @(
                [pscustomobject]@{ Name = "visible.txt"; FullName = "/root\visible.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal },
                [pscustomobject]@{ Name = "hidden.txt"; FullName = "/root\hidden.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Hidden }
            )

            Mock -CommandName Get-ChildItem -MockWith {
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @() -IncludeHiddenEntries:$false -DirectoriesOnly:$false

            # Assert
            $outputText = $output -join "`n"
            $outputText | Should -Match "visible\.txt"
            $outputText | Should -Not -Match "hidden\.txt"
        }

        It "includes hidden files when IncludeHiddenEntries is true" {
            # Arrange
            $items = @(
                [pscustomobject]@{ Name = "visible.txt"; FullName = "/root\visible.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal },
                [pscustomobject]@{ Name = "hidden.txt"; FullName = "/root\hidden.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Hidden }
            )

            Mock -CommandName Get-ChildItem -MockWith {
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @() -IncludeHiddenEntries:$true -DirectoriesOnly:$false

            # Assert
            $outputText = $output -join "`n"
            $outputText | Should -Match "visible\.txt"
            $outputText | Should -Match "hidden\.txt"
        }

        It "excludes hidden directories when IncludeHiddenEntries is false" {
            # Arrange
            $items = @([pscustomobject]@{ Name = ".hidden-dir"; FullName = "/root\.hidden-dir"; PSIsContainer = $true; Attributes = ([IO.FileAttributes]::Hidden -bor [IO.FileAttributes]::Directory) })

            Mock -CommandName Get-ChildItem -MockWith {
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @() -IncludeHiddenEntries:$false -DirectoriesOnly:$false

            # Assert
            ($output -join "`n") | Should -Not -Match "\.hidden-dir"
        }
    }

    Context "Exclusion filtering" {
        It "excludes items by exact name match" {
            # Arrange
            $items = @(
                [pscustomobject]@{ Name = "keep.txt"; FullName = "/root\keep.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal },
                [pscustomobject]@{ Name = "node_modules"; FullName = "/root\node_modules"; PSIsContainer = $true; Attributes = [IO.FileAttributes]::Directory }
            )

            Mock -CommandName Get-ChildItem -MockWith {
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @("node_modules") -IncludeHiddenEntries:$false -DirectoriesOnly:$false

            # Assert
            $outputText = $output -join "`n"
            $outputText | Should -Match "keep\.txt"
            $outputText | Should -Not -Match "node_modules"
        }

        It "excludes multiple items from the exclusion list" {
            # Arrange
            $items = @(
                [pscustomobject]@{ Name = "keep.txt"; FullName = "/root\keep.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal },
                [pscustomobject]@{ Name = ".git"; FullName = "/root\.git"; PSIsContainer = $true; Attributes = [IO.FileAttributes]::Directory },
                [pscustomobject]@{ Name = "node_modules"; FullName = "/root\node_modules"; PSIsContainer = $true; Attributes = [IO.FileAttributes]::Directory }
            )

            Mock -CommandName Get-ChildItem -MockWith {
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @(".git", "node_modules") -IncludeHiddenEntries:$false -DirectoriesOnly:$false

            # Assert
            $outputText = $output -join "`n"
            $outputText | Should -Match "keep\.txt"
            $outputText | Should -Not -Match "\.git"
            $outputText | Should -Not -Match "node_modules"
        }

        It "handles empty exclusion list" {
            # Arrange
            $items = @([pscustomobject]@{ Name = "file.txt"; FullName = "/root\file.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal })

            Mock -CommandName Get-ChildItem -MockWith {
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @() -IncludeHiddenEntries:$false -DirectoriesOnly:$false

            # Assert
            ($output -join "`n") | Should -Match "file\.txt"
        }
    }

    Context "DirectoriesOnly mode" {
        It "shows only directories with backslash suffix when DirectoriesOnly is true" {
            # Arrange
            $items = @(
                [pscustomobject]@{ Name = "file.txt"; FullName = "/root\file.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal },
                [pscustomobject]@{ Name = "folder"; FullName = "/root\folder"; PSIsContainer = $true; Attributes = [IO.FileAttributes]::Directory }
            )

            Mock -CommandName Get-ChildItem -MockWith {
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @() -IncludeHiddenEntries:$false -DirectoriesOnly:$true

            # Assert
            $outputText = $output -join "`n"
            $outputText | Should -Match "folder\\"
            $outputText | Should -Not -Match "file\.txt"
        }

        It "omits [dir] prefix in DirectoriesOnly mode" {
            # Arrange
            $items = @([pscustomobject]@{ Name = "mydir"; FullName = "/root\mydir"; PSIsContainer = $true; Attributes = [IO.FileAttributes]::Directory })

            Mock -CommandName Get-ChildItem -MockWith {
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @() -IncludeHiddenEntries:$false -DirectoriesOnly:$true

            # Assert
            ($output -join "`n") | Should -Not -Match "\[dir\]"
            ($output -join "`n") | Should -Match "mydir\\"
        }

        It "skips files entirely in DirectoriesOnly mode" {
            # Arrange
            $items = @(
                [pscustomobject]@{ Name = "readme.md"; FullName = "/root\readme.md"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal },
                [pscustomobject]@{ Name = "another.txt"; FullName = "/root\another.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal }
            )

            Mock -CommandName Get-ChildItem -MockWith {
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @() -IncludeHiddenEntries:$false -DirectoriesOnly:$true

            # Assert
            $output | Should -BeNullOrEmpty
        }
    }

    Context "Recursive traversal" {
        It "recursively traverses subdirectories" {
            # Arrange
            $rootItems = @([pscustomobject]@{ Name = "subdir"; FullName = "/root\subdir"; PSIsContainer = $true; Attributes = [IO.FileAttributes]::Directory })
            $subItems = @([pscustomobject]@{ Name = "nested.txt"; FullName = "/root\subdir\nested.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal })

            Mock -CommandName Get-ChildItem -MockWith {
                param($LiteralPath, $Force)
                $null = $Force
                if ($LiteralPath -eq "/root") { return $rootItems }
                if ($LiteralPath -eq "/root\subdir") { return $subItems }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @() -IncludeHiddenEntries:$false -DirectoriesOnly:$false

            # Assert
            $outputText = $output -join "`n"
            $outputText | Should -Match "subdir"
            $outputText | Should -Match "nested\.txt"
        }

        It "applies correct indentation for nested items" {
            # Arrange
            $rootItems = @([pscustomobject]@{ Name = "level1"; FullName = "/root\level1"; PSIsContainer = $true; Attributes = [IO.FileAttributes]::Directory })
            $level1Items = @([pscustomobject]@{ Name = "level2"; FullName = "/root\level1\level2"; PSIsContainer = $true; Attributes = [IO.FileAttributes]::Directory })
            $level2Items = @([pscustomobject]@{ Name = "deep.txt"; FullName = "/root\level1\level2\deep.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal })

            Mock -CommandName Get-ChildItem -MockWith {
                param($LiteralPath, $Force)
                $null = $Force
                if ($LiteralPath -eq "/root") { return $rootItems }
                if ($LiteralPath -eq "/root\level1") { return $level1Items }
                if ($LiteralPath -eq "/root\level1\level2") { return $level2Items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @() -IncludeHiddenEntries:$false -DirectoriesOnly:$false

            # Assert
            $output | Should -Not -BeNullOrEmpty
            $outputText = $output -join "`n"
            $outputText | Should -Match "deep"
            # Check that deep.txt has proper indentation (8+ spaces for depth 2)
            $outputText | Should -Match "\s{8,}.*deep\.txt"
        }

        It "stops recursion at excluded directories" {
            # Arrange
            $rootItems = @(
                [pscustomobject]@{ Name = "allowed"; FullName = "/root\allowed"; PSIsContainer = $true; Attributes = [IO.FileAttributes]::Directory },
                [pscustomobject]@{ Name = "node_modules"; FullName = "/root\node_modules"; PSIsContainer = $true; Attributes = [IO.FileAttributes]::Directory }
            )
            $allowedItems = @([pscustomobject]@{ Name = "file.txt"; FullName = "/root\allowed\file.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal })

            Mock -CommandName Get-ChildItem -MockWith {
                param($LiteralPath, $Force)
                $null = $Force
                if ($LiteralPath -eq "/root") { return $rootItems }
                if ($LiteralPath -eq "/root\allowed") { return $allowedItems }
                if ($LiteralPath -eq "/root\node_modules") {
                    throw "Should not traverse excluded directory"
                }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @("node_modules") -IncludeHiddenEntries:$false -DirectoriesOnly:$false

            # Assert
            $outputText = $output -join "`n"
            $outputText | Should -Match "allowed"
            $outputText | Should -Match "file\.txt"
            $outputText | Should -Not -Match "node_modules"
        }
    }

    Context "Empty and edge cases" {
        It "handles empty directories gracefully" {
            # Arrange
            Mock -CommandName Get-ChildItem -MockWith { return @() }

            # Act
            $output = Show-Tree -Path "/empty" -ExcludeNames @() -IncludeHiddenEntries:$false -DirectoriesOnly:$false

            # Assert
            $output | Should -BeNullOrEmpty
        }

        It "handles paths with special characters" {
            # Arrange
            $items = @([pscustomobject]@{ Name = "file (1).txt"; FullName = "/root\file (1).txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal })

            Mock -CommandName Get-ChildItem -MockWith {
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @() -IncludeHiddenEntries:$false -DirectoriesOnly:$false

            # Assert
            ($output -join "`n") | Should -Match "file \(1\)\.txt"
        }

        It "sorts items alphabetically by name" {
            # Arrange
            $items = @(
                [pscustomobject]@{ Name = "zebra.txt"; FullName = "/root\zebra.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal },
                [pscustomobject]@{ Name = "apple.txt"; FullName = "/root\apple.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal },
                [pscustomobject]@{ Name = "banana.txt"; FullName = "/root\banana.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal }
            )

            Mock -CommandName Get-ChildItem -MockWith {
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @() -IncludeHiddenEntries:$false -DirectoriesOnly:$false

            # Assert
            $output[0] | Should -Match "apple"
            $output[1] | Should -Match "banana"
            $output[2] | Should -Match "zebra"
        }
    }

    Context "Combined filters" {
        It "applies both exclusion and hidden filters together" {
            # Arrange
            $items = @(
                [pscustomobject]@{ Name = "visible.txt"; FullName = "/root\visible.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal },
                [pscustomobject]@{ Name = "hidden.txt"; FullName = "/root\hidden.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Hidden },
                [pscustomobject]@{ Name = "exclude-me"; FullName = "/root\exclude-me"; PSIsContainer = $true; Attributes = [IO.FileAttributes]::Directory }
            )

            Mock -CommandName Get-ChildItem -MockWith {
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @("exclude-me") -IncludeHiddenEntries:$false -DirectoriesOnly:$false

            # Assert
            $outputText = $output -join "`n"
            $outputText | Should -Match "visible\.txt"
            $outputText | Should -Not -Match "hidden\.txt"
            $outputText | Should -Not -Match "exclude-me"
        }

        It "applies DirectoriesOnly with exclusions and hidden filters" {
            # Arrange
            $items = @(
                [pscustomobject]@{ Name = "visible-dir"; FullName = "/root\visible-dir"; PSIsContainer = $true; Attributes = [IO.FileAttributes]::Directory },
                [pscustomobject]@{ Name = ".hidden-dir"; FullName = "/root\.hidden-dir"; PSIsContainer = $true; Attributes = ([IO.FileAttributes]::Hidden -bor [IO.FileAttributes]::Directory) },
                [pscustomobject]@{ Name = "node_modules"; FullName = "/root\node_modules"; PSIsContainer = $true; Attributes = [IO.FileAttributes]::Directory },
                [pscustomobject]@{ Name = "file.txt"; FullName = "/root\file.txt"; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal }
            )

            Mock -CommandName Get-ChildItem -MockWith {
                if ($LiteralPath -eq "/root") { return $items }
                return @()
            }

            # Act
            $output = Show-Tree -Path "/root" -ExcludeNames @("node_modules") -IncludeHiddenEntries:$false -DirectoriesOnly:$true

            # Assert
            $outputText = $output -join "`n"
            $outputText | Should -Match "visible-dir\\"
            $outputText | Should -Not -Match "\.hidden-dir"
            $outputText | Should -Not -Match "node_modules"
            $outputText | Should -Not -Match "file\.txt"
        }
    }
}

Describe "tree.ps1 script integration" {
    BeforeAll {
        $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\scripts\dev-tools\tree.ps1"
    }

    Context "Parameter handling and output" {
        It "executes the main script flow with a resolved root" {
            Mock -CommandName Resolve-Path -MockWith { [pscustomobject]@{ Path = '/repo' } }
            Mock -CommandName Get-ChildItem -MockWith { @() }

            $output = & $script:scriptPath -Root '/repo' -Exclude @()

            $output | Should -Contain 'Tree for repo'
        }

        It "resolves the root path correctly" {
            # Verify script uses Resolve-Path for root path
            $scriptContent = Get-Content -Path $script:scriptPath -Raw
            $scriptContent | Should -Match "Resolve-Path"
            $scriptContent | Should -Match "\`$Root"
        }

        It "includes the repository name in output header" {
            # Verify script extracts and displays repo name
            $scriptContent = Get-Content -Path $script:scriptPath -Raw
            $scriptContent | Should -Match "Split-Path.*-Leaf"
            $scriptContent | Should -Match 'Write-Output "Tree for'
        }

        It "adds mode suffix for DirectoriesOnly output" {
            # Verify conditional suffix logic exists
            $scriptContent = Get-Content -Path $script:scriptPath -Raw
            $scriptContent | Should -Match '\(directories only\)'
            $scriptContent | Should -Match '\$DirectoriesOnly'
        }

        It "passes parameters correctly to Show-Tree" {
            # Verify parameter forwarding
            $scriptContent = Get-Content -Path $script:scriptPath -Raw
            $scriptContent | Should -Match 'Show-Tree.*-Path'
            $scriptContent | Should -Match '-ExcludeNames.*\$Exclude'
            $scriptContent | Should -Match '-IncludeHiddenEntries'
            $scriptContent | Should -Match '-DirectoriesOnly'
        }
    }

    Context "Default parameter values" {
        It "defaults Root to script parent directory" {
            $scriptContent = Get-Content -Path $script:scriptPath -Raw
            $scriptContent | Should -Match '\[string\]\$Root\s*=\s*"\$PSScriptRoot/\.\./\.\."'
        }

        It "defaults Exclude to common directories" {
            $scriptContent = Get-Content -Path $script:scriptPath -Raw
            $scriptContent | Should -Match '\[string\[\]\]\$Exclude\s*=\s*@\('
            $scriptContent | Should -Match '\.git'
            $scriptContent | Should -Match 'node_modules'
        }

        It "defaults IncludeHidden to false" {
            $scriptContent = Get-Content -Path $script:scriptPath -Raw
            $scriptContent | Should -Match '\[switch\]\$IncludeHidden\s*=\s*\$false'
        }

        It "defines DirectoriesOnly as a switch parameter" {
            $scriptContent = Get-Content -Path $script:scriptPath -Raw
            $scriptContent | Should -Match '\[switch\]\$DirectoriesOnly'
        }
    }
}
