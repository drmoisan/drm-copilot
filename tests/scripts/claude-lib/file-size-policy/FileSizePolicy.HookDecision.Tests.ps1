#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for Resolve-FileSizeEditContent and Get-FileSizeHookDecision (issue #990).

.DESCRIPTION
    Drives the in-memory Edit replacement and the baseline-free pre-edit-size ratchet
    with the shared rows in FileSizePolicy.Cases.ps1, and asserts the tokens the deny
    reason must carry. In-memory strings only; no file, process, or clock access.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'FileSizePolicy.Cases.ps1')
}

BeforeAll {
    $script:ModulePath = Join-Path $PSScriptRoot '../../../../.claude/lib/file-size-policy/FileSizePolicy.psm1'
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop
}

AfterAll {
    Remove-Module -Name FileSizePolicy -Force -ErrorAction SilentlyContinue
}

Describe 'Resolve-FileSizeEditContent' {
    It 'resolves <Name>' -ForEach $script:FileSizeEditCases {
        # Act
        $result = Resolve-FileSizeEditContent -Content $Content -OldString $Old -NewString $New -ReplaceAll $ReplaceAll

        # Assert
        $result.Failure | Should -Be $Failure
        if ($null -eq $Failure) {
            $result.Content | Should -BeExactly $Expected
        } else {
            $result.Content | Should -BeNullOrEmpty
        }
    }

    It 'resolves a single replacement when replace_all is false and the match is unique' {
        # Act
        $result = Resolve-FileSizeEditContent -Content "one`ntwo`n" -OldString 'two' -NewString 'three' -ReplaceAll $false

        # Assert
        $result.Content | Should -BeExactly "one`nthree`n"
    }

    It 'treats an omitted new string as empty' {
        # Act
        $result = Resolve-FileSizeEditContent -Content 'keep drop' -OldString ' drop'

        # Assert
        $result.Content | Should -BeExactly 'keep'
    }
}

Describe 'Get-FileSizeHookDecision' {
    It 'decides: <Name>' -ForEach $script:FileSizeHookDecisionCases {
        # Act
        $decision = Get-FileSizeHookDecision -RelativePath $Path -ResultLineCount $Result -PreEditLineCount $PreEdit

        # Assert
        $decision.Allowed | Should -Be $Allowed
        if ($Allowed) {
            $decision.Reason | Should -BeNullOrEmpty
        } else {
            $decision.Reason | Should -Match '^FILE_SIZE_LIMIT_BLOCKED:'
        }
    }

    It 'names the tiers, the path, the count, and the split requirement in the deny reason' {
        # Act
        $decision = Get-FileSizeHookDecision -RelativePath 'scripts/new.py' -ResultLineCount 801 -PreEditLineCount $null

        # Assert
        $reason = $decision.Reason
        $reason | Should -Match 'FILE_SIZE_LIMIT_BLOCKED'
        $reason | Should -Match '500'
        $reason | Should -Match '700'
        $reason | Should -Match '800'
        $reason | Should -Match ([regex]::Escape('scripts/new.py'))
        $reason | Should -Match '801'
        $reason | Should -Match 'regardless of logical separability'
        $reason | Should -Match 'Split the file'
    }

    It 'names the pre-edit size when a large file would grow' {
        # Act
        $decision = Get-FileSizeHookDecision -RelativePath 'scripts/large.ps1' -ResultLineCount 815 -PreEditLineCount 810

        # Assert
        $decision.Reason | Should -Match 'It has 810 lines now'
    }

    It 'treats a null path as outside the repository and allows' {
        # Act
        $decision = Get-FileSizeHookDecision -RelativePath $null -ResultLineCount 9000

        # Assert
        $decision.Allowed | Should -BeTrue
    }

    It 'names no consuming product in the deny reason' {
        # Act
        $reason = (Get-FileSizeHookDecision -RelativePath 'a.py' -ResultLineCount 900).Reason

        # Assert: the reason ships to consumer repositories through push-down.
        $reason | Should -Not -Match 'drm-copilot'
    }
}
