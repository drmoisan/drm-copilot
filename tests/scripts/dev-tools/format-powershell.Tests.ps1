Describe "format-powershell entrypoint" {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot "..\..\..\scripts\dev-tools\format-powershell.ps1"
        . $scriptPath
    }

    BeforeEach {
        $script:originalSkip = $env:POSHQC_SKIP_SCRIPT_EXECUTION
        Remove-Item Env:POSHQC_SKIP_SCRIPT_EXECUTION -ErrorAction SilentlyContinue
    }

    AfterEach {
        if ($null -ne $script:originalSkip) {
            $env:POSHQC_SKIP_SCRIPT_EXECUTION = $script:originalSkip
        } else {
            Remove-Item Env:POSHQC_SKIP_SCRIPT_EXECUTION -ErrorAction SilentlyContinue
        }
    }

    It "runs the formatter when invoked" {
        Mock -CommandName Import-Module
        Mock -CommandName Invoke-PoshQCFormat

        $result = Invoke-FormatPowerShell -ExitOnError:$false

        $result | Should -BeTrue
        Should -Invoke -CommandName Import-Module -Times 1 -Exactly
        Should -Invoke -CommandName Invoke-PoshQCFormat -Times 1 -Exactly
    }

    It "returns false and reports errors when formatting fails" {
        Mock -CommandName Import-Module
        Mock -CommandName Invoke-PoshQCFormat -MockWith { throw "formatting failed" }
        Mock -CommandName Write-Error

        $result = Invoke-FormatPowerShell -ExitOnError:$false

        $result | Should -BeFalse
        Should -Invoke -CommandName Write-Error -Times 1 -Exactly
    }

    It "exits through the wrapper when ExitOnError is true" {
        Mock -CommandName Import-Module
        Mock -CommandName Invoke-PoshQCFormat -MockWith { throw "formatting failed" }
        Mock -CommandName Write-Error
        Mock -CommandName Exit-WithCode

        $result = Invoke-FormatPowerShell -ExitOnError:$true

        $result | Should -BeFalse
        Should -Invoke -CommandName Exit-WithCode -Times 1 -Exactly -ParameterFilter { $ExitCode -eq 1 }
    }

    It "uses the provided exit action" {
        $script:capturedExit = $null

        Exit-WithCode -ExitCode 7 -ExitAction { param([int] $ExitCode) $script:capturedExit = $ExitCode }

        $script:capturedExit | Should -Be 7
    }

    It "skips execution when POSHQC_SKIP_SCRIPT_EXECUTION is set" {
        Mock -CommandName Invoke-FormatPowerShell
        $env:POSHQC_SKIP_SCRIPT_EXECUTION = "1"

        & $scriptPath

        Should -Invoke -CommandName Invoke-FormatPowerShell -Times 0
    }

    It "invokes the formatter when the script runs normally" {
        Mock -CommandName Invoke-FormatPowerShell

        & $scriptPath

        Should -Invoke -CommandName Invoke-FormatPowerShell -Times 1 -Exactly
    }
}
