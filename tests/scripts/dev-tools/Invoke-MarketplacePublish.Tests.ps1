Set-StrictMode -Version Latest

$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
. (Resolve-Path -Path (Join-Path -Path $scriptRoot -ChildPath "../powershell/Support/TestHelpers.ps1"))

Describe "Invoke-MarketplacePublish.ps1 - Invoke-MarketplacePublishGuarded" {
    BeforeAll {
        $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-MarketplacePublish.ps1"
    }

    BeforeEach {
        . (Import-ScriptFunction -Path $script:scriptPath -Name "Write-StderrLine")
        . (Import-ScriptFunction -Path $script:scriptPath -Name "Invoke-PublishScript")
        . (Import-ScriptFunction -Path $script:scriptPath -Name "Invoke-MarketplacePublishGuarded")
        $script:capturedMessage = $null
        $script:capturedScriptPath = $null
    }

    It "returns 2 and emits the not-confirmed message when ConfirmToken is 'no'" {
        Mock -CommandName Write-StderrLine -MockWith {
            param([string]$Message)
            $script:capturedMessage = $Message
        }
        Mock -CommandName Invoke-PublishScript -MockWith {
            param([string]$ScriptPath)
            $null = $ScriptPath
            throw "publish script should not be invoked"
        }

        $result = Invoke-MarketplacePublishGuarded -ConfirmToken "no" -RepoRoot "/repo"

        $result | Should -Be 2
        $script:capturedMessage | Should -Match "Marketplace publish not confirmed \(got 'no'\)"
        Should -Invoke -CommandName Invoke-PublishScript -Times 0 -Exactly
    }

    It "returns 2 when ConfirmToken is an arbitrary non-'yes' value" {
        Mock -CommandName Write-StderrLine -MockWith {
            param([string]$Message)
            $null = $Message
        }
        Mock -CommandName Invoke-PublishScript -MockWith {
            param([string]$ScriptPath)
            $null = $ScriptPath
            throw "publish script should not be invoked"
        }

        $result = Invoke-MarketplacePublishGuarded -ConfirmToken "maybe" -RepoRoot "/repo"

        $result | Should -Be 2
        Should -Invoke -CommandName Invoke-PublishScript -Times 0 -Exactly
    }

    It "is case-sensitive: ConfirmToken 'YES' is rejected" {
        Mock -CommandName Write-StderrLine -MockWith {
            param([string]$Message)
            $null = $Message
        }
        Mock -CommandName Invoke-PublishScript -MockWith {
            param([string]$ScriptPath)
            $null = $ScriptPath
            throw "publish script should not be invoked"
        }

        $result = Invoke-MarketplacePublishGuarded -ConfirmToken "YES" -RepoRoot "/repo"

        $result | Should -Be 2
        Should -Invoke -CommandName Invoke-PublishScript -Times 0 -Exactly
    }

    It "returns 1 when ConfirmToken is 'yes' but the publish script is missing" {
        Mock -CommandName Test-Path -MockWith {
            param([string]$LiteralPath)
            $null = $LiteralPath
            return $false
        }
        Mock -CommandName Write-StderrLine -MockWith {
            param([string]$Message)
            $script:capturedMessage = $Message
        }
        Mock -CommandName Invoke-PublishScript -MockWith {
            param([string]$ScriptPath)
            $null = $ScriptPath
            throw "publish script should not be invoked"
        }

        $result = Invoke-MarketplacePublishGuarded -ConfirmToken "yes" -RepoRoot "/nonexistent/repo"

        $result | Should -Be 1
        $script:capturedMessage | Should -Match "Publish script not found"
        Should -Invoke -CommandName Invoke-PublishScript -Times 0 -Exactly
    }

    It "invokes the publish script and returns its exit code when ConfirmToken is 'yes' and script exists" {
        Mock -CommandName Test-Path -MockWith {
            param([string]$LiteralPath)
            $null = $LiteralPath
            return $true
        }
        Mock -CommandName Invoke-PublishScript -MockWith {
            param([string]$ScriptPath)
            $script:capturedScriptPath = $ScriptPath
            return 0
        }

        $result = Invoke-MarketplacePublishGuarded -ConfirmToken "yes" -RepoRoot "/repo"

        $result | Should -Be 0
        $script:capturedScriptPath | Should -Be (Join-Path -Path "/repo" -ChildPath "scripts/powershell/Publish-DrmCopilotExtension.ps1")
        Should -Invoke -CommandName Invoke-PublishScript -Times 1 -Exactly
    }

    It "propagates a non-zero exit code from the publish script" {
        Mock -CommandName Test-Path -MockWith {
            param([string]$LiteralPath)
            $null = $LiteralPath
            return $true
        }
        Mock -CommandName Invoke-PublishScript -MockWith {
            param([string]$ScriptPath)
            $null = $ScriptPath
            return 42
        }

        $result = Invoke-MarketplacePublishGuarded -ConfirmToken "yes" -RepoRoot "/repo"

        $result | Should -Be 42
    }
}
