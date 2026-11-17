Set-StrictMode -Version Latest

<#
.SYNOPSIS
    Entry-guard tests for scripts/dev-tools/new-potential-entry.ps1 (issue #1035, remediation F1).

.DESCRIPTION
    Invokes the script with the mock set of new-potential-entry.TemplateRoot.Tests.ps1 plus a
    Write-Error mock, and covers the three abort paths (empty name, non-kebab-case name, missing
    template) and the creation of a missing potential directory. Every file-system cmdlet the
    script calls is mocked, so no row reads or writes a file. The native exit code that the
    script's `exit 1` sets is restored after each row.
#>

Describe "new-potential-entry.ps1 - entry guards" {
    BeforeAll {
        $script:scriptPath = (
            Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/new-potential-entry.ps1")
        ).Path
        $script:workspaceRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $script:scriptPath))
        $script:defaultTemplate = Join-Path $script:workspaceRoot "docs/features/potential/template.md"
        $script:targetDirectory = Split-Path -Parent (Join-Path $script:workspaceRoot "docs/features/potential/2026-03-15-my-feature.md")
    }

    BeforeEach {
        $script:priorExitCode = $global:LASTEXITCODE
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
        Mock -CommandName Write-Error -MockWith { }
    }

    AfterEach {
        $global:LASTEXITCODE = $script:priorExitCode
    }

    It "aborts without copying when -ShortName is empty" {
        & $script:scriptPath -ShortName ''

        Should -Invoke -CommandName Write-Error -Times 1 -Exactly -ParameterFilter { "$Message" -like 'Aborted: no name provided.*' }
        Should -Invoke -CommandName Copy-Item -Times 0 -Exactly
        $global:LASTEXITCODE | Should -Be 1
    }

    It "aborts without copying when -ShortName is not kebab-case" {
        & $script:scriptPath -ShortName 'Not_Kebab'

        Should -Invoke -CommandName Write-Error -Times 1 -Exactly -ParameterFilter { "$Message" -like "Aborted: 'Not_Kebab' is invalid.*" }
        Should -Invoke -CommandName Copy-Item -Times 0 -Exactly
        $global:LASTEXITCODE | Should -Be 1
    }

    It "aborts without copying when the template is missing" {
        $missingTemplate = $script:defaultTemplate
        Mock -CommandName Test-Path -MockWith { param([string] $Path) $Path -ne $missingTemplate }.GetNewClosure()

        & $script:scriptPath -ShortName 'my-feature'

        Should -Invoke -CommandName Write-Error -Times 1 -Exactly -ParameterFilter { "$Message" -eq "Template not found: $missingTemplate" }
        Should -Invoke -CommandName Copy-Item -Times 0 -Exactly
        $global:LASTEXITCODE | Should -Be 1
    }

    It "creates the potential directory when it is missing" {
        $missingDirectory = $script:targetDirectory
        Mock -CommandName Test-Path -MockWith { param([string] $Path) $Path -ne $missingDirectory }.GetNewClosure()

        & $script:scriptPath -ShortName 'my-feature'

        Should -Invoke -CommandName New-Item -Times 1 -Exactly -ParameterFilter { $ItemType -eq 'Directory' -and $Path -eq $missingDirectory }
        Should -Invoke -CommandName Copy-Item -Times 1 -Exactly
        Should -Invoke -CommandName Write-Error -Times 0 -Exactly
    }
}
