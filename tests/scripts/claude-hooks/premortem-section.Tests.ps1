#Requires -Version 7.0
<#
.SYNOPSIS
    Unit tests for .claude/hooks/premortem-section.ps1 (issue #964).

.DESCRIPTION
    Test-PreMortemSection is a pure function over Markdown text. Every fixture is an in-memory string
    with LF line endings; no test creates, reads, or deletes a file.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/premortem-section.ps1')

    function Get-PreMortemFixture {
        # Returns a plan-like document whose Pre-Mortem section carries the given bullet lines.
        param([string[]] $Bullet, [string] $Trailer = '## Phases')
        $body = @('# Plan', '', '## Pre-Mortem', '') + $Bullet + @('', $Trailer, '', '- [ ] [P0-T1] Read policy.')
        return ($body -join "`n")
    }

    function Get-CompleteBullet {
        # Returns one valid bullet per required label.
        return @(Get-PreMortemLabel | ForEach-Object { "- ${_}: mitigated by the plan." })
    }
}

Describe 'Test-PreMortemSection (issue #964)' {
    It 'rejects a document without a Pre-Mortem heading' {
        # Arrange
        $content = "# Plan`n`n## Phases`n`n- [ ] [P0-T1] Read policy."

        # Act
        $result = Test-PreMortemSection -Content $content

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -Match 'no `## Pre-Mortem` section'
        @($result.MissingLabels).Count | Should -Be 7
    }

    It 'accepts a section with one bullet per label' {
        # Arrange
        $content = Get-PreMortemFixture -Bullet (Get-CompleteBullet)

        # Act
        $result = Test-PreMortemSection -Content $content

        # Assert
        $result.Ok | Should -BeTrue
        $result.Message | Should -BeNullOrEmpty
        @($result.MissingLabels).Count | Should -Be 0
    }

    It 'rejects a section missing the <Label> bullet' -ForEach @(
        @{ Label = 'Review checklists' }
        @{ Label = 'Coverage' }
        @{ Label = 'Mirror parity' }
        @{ Label = 'File size' }
        @{ Label = 'Test isolation' }
        @{ Label = 'CI-only behavior' }
        @{ Label = 'Evidence' }
    ) {
        # Arrange
        $bullets = @(Get-CompleteBullet | Where-Object { -not $_.StartsWith("- ${Label}:") })
        $content = Get-PreMortemFixture -Bullet $bullets

        # Act
        $result = Test-PreMortemSection -Content $content

        # Assert
        $result.Ok | Should -BeFalse
        @($result.MissingLabels) | Should -Be @($Label)
        $result.Message | Should -Match ([regex]::Escape($Label))
    }

    It 'accepts labels in any letter case and in bold' {
        # Arrange
        $bullets = @(Get-PreMortemLabel | ForEach-Object { "- **$($_.ToUpperInvariant())**: covered." })
        $content = Get-PreMortemFixture -Bullet $bullets

        # Act
        $result = Test-PreMortemSection -Content $content

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'accepts "not applicable" followed by a reason' {
        # Arrange
        $bullets = @(Get-CompleteBullet | Where-Object { -not $_.StartsWith('- Mirror parity:') }) + '- Mirror parity: not applicable; no mirrored file changes.'
        $content = Get-PreMortemFixture -Bullet $bullets

        # Act
        $result = Test-PreMortemSection -Content $content

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'rejects "not applicable" without a reason' {
        # Arrange
        $bullets = @(Get-CompleteBullet | Where-Object { -not $_.StartsWith('- File size:') }) + '- File size: Not applicable.'
        $content = Get-PreMortemFixture -Bullet $bullets

        # Act
        $result = Test-PreMortemSection -Content $content

        # Assert
        $result.Ok | Should -BeFalse
        @($result.MissingLabels) | Should -Be @('File size')
    }

    It 'rejects a label bullet that carries no text' {
        # Arrange
        $bullets = @(Get-CompleteBullet | Where-Object { -not $_.StartsWith('- Evidence:') }) + '- Evidence:'
        $content = Get-PreMortemFixture -Bullet $bullets

        # Act
        $result = Test-PreMortemSection -Content $content

        # Assert
        $result.Ok | Should -BeFalse
        @($result.MissingLabels) | Should -Be @('Evidence')
    }

    It 'ignores label bullets that sit outside the Pre-Mortem section' {
        # Arrange
        $outside = @(Get-CompleteBullet) -join "`n"
        $content = "# Plan`n`n$outside`n`n## Pre-Mortem`n`n- Coverage: measured.`n`n## Phases`n`n$outside"

        # Act
        $result = Test-PreMortemSection -Content $content

        # Assert
        $result.Ok | Should -BeFalse
        @($result.MissingLabels).Count | Should -Be 6
        @($result.MissingLabels) | Should -Not -Contain 'Coverage'
    }

    It 'does not treat a longer word as the label' {
        # Arrange
        $bullets = @(Get-CompleteBullet | Where-Object { -not $_.StartsWith('- Coverage:') }) + '- Coverages: listed.'
        $content = Get-PreMortemFixture -Bullet $bullets

        # Act
        $result = Test-PreMortemSection -Content $content

        # Assert
        $result.Ok | Should -BeFalse
        @($result.MissingLabels) | Should -Be @('Coverage')
    }

    It 'ends the section at a level-one heading and keeps level-three headings inside it' {
        # Arrange
        $content = Get-PreMortemFixture -Bullet (@('### Notes') + (Get-CompleteBullet)) -Trailer '# Appendix'

        # Act
        $result = Test-PreMortemSection -Content $content

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'returns the seven labels in canonical order' {
        # Arrange / Act
        $labels = Get-PreMortemLabel

        # Assert
        $labels | Should -Be @('Review checklists', 'Coverage', 'Mirror parity', 'File size', 'Test isolation', 'CI-only behavior', 'Evidence')
    }
}
