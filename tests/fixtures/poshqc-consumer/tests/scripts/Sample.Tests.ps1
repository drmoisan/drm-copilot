BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '../../scripts/Sample.psm1') -Force
}

AfterAll {
    Remove-Module -Name 'Sample' -Force -ErrorAction SilentlyContinue
}

Describe 'Get-SampleGreeting' {
    It 'returns a greeting for the supplied name' {
        Get-SampleGreeting -Name 'Ada' | Should -Be 'Hello, Ada.'
    }
}
