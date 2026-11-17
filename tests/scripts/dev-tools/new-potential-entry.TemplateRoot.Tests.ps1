Set-StrictMode -Version Latest

Describe "new-potential-entry.ps1 - template root resolution" {
    BeforeAll {
        $script:scriptPath = (
            Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/new-potential-entry.ps1")
        ).Path
        $script:scriptDirectory = Split-Path -Parent $script:scriptPath
        $script:workspaceRoot = Split-Path -Parent (Split-Path -Parent $script:scriptDirectory)
        $targetPath = Join-Path $script:workspaceRoot "docs/features/potential/2026-03-15-my-feature.md"
        $script:expectedPaths = [ordered]@{
            DefaultTemplatePath = Join-Path $script:workspaceRoot "docs/features/potential/template.md"
            TargetPath          = $targetPath
            TargetDirectory     = Split-Path -Parent $targetPath
        }
    }

    It "uses the supplied template root when the bundled potential template exists" {
        $templateRoot = Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) 'bundled-feature-templates'
        $bundledTemplatePath = Join-Path $templateRoot "potential/template.md"
        $bundledTemplateExists = $true
        $defaultTemplatePath = $script:expectedPaths['DefaultTemplatePath']
        $targetPath = $script:expectedPaths['TargetPath']
        $targetDirectory = $script:expectedPaths['TargetDirectory']

        Mock -CommandName Get-Date -MockWith {
            param([string] $Format)

            switch ($Format) {
                "yyyy-MM-dd" { return "2026-03-15" }
                "yyyy-MM-ddTHH-mm" { return "2026-03-15T00-00" }
                default { throw "Unexpected date format: $Format" }
            }
        }
        Mock -CommandName Test-Path -MockWith {
            param([string] $Path)

            if ($Path -like "*bundled-feature-templates*potential*template.md") {
                return $bundledTemplateExists
            }

            if ($Path -eq $defaultTemplatePath) {
                return $true
            }

            if ($Path -eq $targetDirectory) {
                return $true
            }

            return $true
        }
        Mock -CommandName Copy-Item -MockWith { }
        Mock -CommandName New-Item -MockWith { }
        Mock -CommandName Get-Content -MockWith { "# <feature-name> (Potential)`n- Date captured: YYYY-MM-DD`n- Author: name" }
        Mock -CommandName Set-Content -MockWith { }
        Mock -CommandName Get-Command -MockWith { $null }
        Mock -CommandName Get-Process -MockWith { $null }
        Mock -CommandName Write-Output -MockWith { }
        Mock -CommandName Write-Warning -MockWith { }

        & $script:scriptPath -ShortName "my-feature" -TemplateRoot $templateRoot

        Should -Invoke -CommandName Copy-Item -Times 1 -Exactly -ParameterFilter {
            $Path -eq $bundledTemplatePath -and
            $Destination -eq $targetPath
        }
        Should -Invoke -CommandName Set-Content -Times 1 -Exactly -ParameterFilter {
            $Path -eq $targetPath -and
            $Value -match "my-feature" -and
            "$Encoding" -match "UTF8"
        }
    }

    It "falls back to the workspace template when the supplied template root lacks the potential template" {
        $templateRoot = Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) 'bundled-feature-templates'
        $bundledTemplateExists = $false
        $defaultTemplatePath = $script:expectedPaths['DefaultTemplatePath']
        $targetPath = $script:expectedPaths['TargetPath']
        $targetDirectory = $script:expectedPaths['TargetDirectory']

        Mock -CommandName Get-Date -MockWith {
            param([string] $Format)

            switch ($Format) {
                "yyyy-MM-dd" { return "2026-03-15" }
                "yyyy-MM-ddTHH-mm" { return "2026-03-15T00-00" }
                default { throw "Unexpected date format: $Format" }
            }
        }
        Mock -CommandName Test-Path -MockWith {
            param([string] $Path)

            if ($Path -like "*bundled-feature-templates*potential*template.md") {
                return $bundledTemplateExists
            }

            if ($Path -eq $defaultTemplatePath) {
                return $true
            }

            if ($Path -eq $targetDirectory) {
                return $true
            }

            return $true
        }
        Mock -CommandName Copy-Item -MockWith { }
        Mock -CommandName New-Item -MockWith { }
        Mock -CommandName Get-Content -MockWith { "# <feature-name> (Potential)`n- Date captured: YYYY-MM-DD`n- Author: name" }
        Mock -CommandName Set-Content -MockWith { }
        Mock -CommandName Get-Command -MockWith { $null }
        Mock -CommandName Get-Process -MockWith { $null }
        Mock -CommandName Write-Output -MockWith { }
        Mock -CommandName Write-Warning -MockWith { }

        & $script:scriptPath -ShortName "my-feature" -TemplateRoot $templateRoot

        Should -Invoke -CommandName Copy-Item -Times 1 -Exactly -ParameterFilter {
            $Path -eq $defaultTemplatePath -and
            $Destination -eq $targetPath
        }
        Should -Invoke -CommandName Write-Warning -Times 1 -Exactly -ParameterFilter {
            $Message -eq "VS Code CLI command not found (expected 'code' or 'code-insiders'). Open files manually:"
        }
    }

    It "writes under the .dev potential area and names the .dev backlog when -DevelopmentDocsRoot is .dev (issue #1035)" {
        $devTemplate = Join-Path $script:workspaceRoot ".dev/potential/template.md"
        $devTarget = Join-Path $script:workspaceRoot ".dev/potential/2026-03-15-my-feature.md"
        $devBacklog = Join-Path $script:workspaceRoot ".dev/backlog.md"

        Mock -CommandName Get-Date -MockWith {
            param([string] $Format)
            switch ($Format) {
                "yyyy-MM-dd" { return "2026-03-15" }
                "yyyy-MM-ddTHH-mm" { return "2026-03-15T00-00" }
                default { throw "Unexpected date format: $Format" }
            }
        }
        Mock -CommandName Test-Path -MockWith { $true }
        Mock -CommandName Copy-Item -MockWith { }
        Mock -CommandName New-Item -MockWith { }
        Mock -CommandName Get-Content -MockWith { "# <feature-name> (Potential)`n- Date captured: YYYY-MM-DD`n- Author: name" }
        Mock -CommandName Set-Content -MockWith { }
        Mock -CommandName Get-Command -MockWith { $null }
        Mock -CommandName Get-Process -MockWith { $null }
        Mock -CommandName Write-Output -MockWith { }
        Mock -CommandName Write-Warning -MockWith { }

        & $script:scriptPath -ShortName "my-feature" -DevelopmentDocsRoot '.dev'

        Should -Invoke -CommandName Copy-Item -Times 1 -Exactly -ParameterFilter {
            $Path -eq $devTemplate -and $Destination -eq $devTarget
        }
        Should -Invoke -CommandName Write-Output -Times 1 -Exactly -ParameterFilter { $InputObject -eq "  $devBacklog" }
    }

    It "resolves the bundled copy's workspace from the current location (issue #1035)" {
        $bundledScript = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../extensions/drm-copilot/resources/templates/new-potential-entry.ps1")).Path
        $location = Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) 'synthetic-destination'
        $expectedTemplate = Join-Path $location "docs/features/potential/template.md"
        $expectedTarget = Join-Path $location "docs/features/potential/2026-03-15-my-feature.md"

        Mock -CommandName Get-Location -MockWith { [pscustomobject]@{ Path = $location } }
        Mock -CommandName Get-Date -MockWith {
            param([string] $Format)
            switch ($Format) {
                "yyyy-MM-dd" { return "2026-03-15" }
                "yyyy-MM-ddTHH-mm" { return "2026-03-15T00-00" }
                default { throw "Unexpected date format: $Format" }
            }
        }
        Mock -CommandName Test-Path -MockWith { $true }
        Mock -CommandName Copy-Item -MockWith { }
        Mock -CommandName New-Item -MockWith { }
        Mock -CommandName Get-Content -MockWith { "# <feature-name> (Potential)`n- Date captured: YYYY-MM-DD`n- Author: name" }
        Mock -CommandName Set-Content -MockWith { }
        Mock -CommandName Get-Command -MockWith { $null }
        Mock -CommandName Get-Process -MockWith { $null }
        Mock -CommandName Write-Output -MockWith { }
        Mock -CommandName Write-Warning -MockWith { }

        & $bundledScript -ShortName "my-feature"

        Should -Invoke -CommandName Get-Location -Times 1 -Exactly
        Should -Invoke -CommandName Copy-Item -Times 1 -Exactly -ParameterFilter {
            $Path -eq $expectedTemplate -and $Destination -eq $expectedTarget
        }
    }
}
