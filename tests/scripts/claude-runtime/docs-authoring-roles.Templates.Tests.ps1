#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Front matter and body rules of the eight docs-author-page templates in all six skill locations (issue #1037).

.DESCRIPTION
    Each template's front matter is parsed line by line with every value parsed as JSON. No test
    writes a file.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'DocsAuthoringRoles.Helpers.ps1')
    $set = Get-DocsAuthoringNamedSet
    $roots = Get-DocsAuthoringSkillRoot
    $script:TemplateRows = @(foreach ($key in $roots.Keys) {
            foreach ($template in $set.Templates) { @{ Template = $template; Mode = $set.TemplateModes[$template]; Path = "$($roots[$key])/docs-author-page/templates/$template.md" } }
        })
}

BeforeAll {
    . (Join-Path $PSScriptRoot 'DocsAuthoringRoles.Helpers.ps1')

    function Get-TemplatePart {
        # Splits a template into its front-matter lines and its body.
        param([string] $Text)
        $lines = @(($Text -replace "`r`n", "`n") -split "`n")
        $end = [array]::IndexOf($lines, '---', 1)
        return @{ FrontMatter = @($lines[1..($end - 1)]); Body = (@($lines[($end + 1)..($lines.Count - 1)]) -join "`n"); StartsWithFence = $lines[0] -eq '---' }
    }
}

AfterAll {
    foreach ($name in 'Get-TemplatePart', 'Get-DocsAuthoringRepoRoot', 'Read-DocsAuthoringText', 'Get-DocsAuthoringNamedSet', 'Get-DocsAuthoringAgentPath', 'Get-DocsAuthoringSkillRoot', 'Get-DocsFrontMatterList', 'Get-DocsCodexEmbeddedText', 'Get-DocsCommandRowOption', 'Get-DocsMcpToolNameDefinition', 'Get-DocsPackManifestPath') {
        Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue
    }
}

Describe 'docs-author-page templates' {
    It 'covers 48 template files' -TestCases @(@{ RowCount = $script:TemplateRows.Count }) {
        # Assert
        $RowCount | Should -Be 48
    }

    It 'gives <Path> the five front-matter fields with JSON values and diataxis_mode <Mode>' -ForEach $script:TemplateRows {
        # Arrange
        $part = Get-TemplatePart -Text (Read-DocsAuthoringText -RelativePath $Path)

        # Act
        $fields = @{}
        foreach ($line in $part.FrontMatter) {
            $match = [regex]::Match($line, '^(?<key>[a-z_]+): (?<value>.+)$')
            $match.Success | Should -BeTrue -Because "front-matter line '$line'"
            $fields[$match.Groups['key'].Value] = ConvertFrom-Json -InputObject $match.Groups['value'].Value -NoEnumerate
        }

        # Assert
        $part.StartsWithFence | Should -BeTrue
        @($fields.Keys | Sort-Object) | Should -Be @('audience', 'diataxis_mode', 'last_reviewed', 'owner', 'surface_refs')
        $fields['diataxis_mode'] | Should -BeExactly $Mode
    }

    It 'gives <Path> the body rules of the <Mode> mode' -ForEach $script:TemplateRows {
        # Arrange
        $body = (Get-TemplatePart -Text (Read-DocsAuthoringText -RelativePath $Path)).Body

        # Act
        $hasStep = [regex]::IsMatch($body, '(?m)^ {0,3}[0-9]{1,9}[.)] +\S')
        $instructionalHeading = [regex]::IsMatch($body, '(?im)^#{1,6}[ \t]+(?:how to |step\s+[0-9]+\b)')
        $starts = [regex]::Matches($body, '(?m)^<!-- docs:generated:start id=\S+ -->[ \t]*$').Count
        $ends = [regex]::Matches($body, '(?m)^<!-- docs:generated:end id=\S+ -->[ \t]*$').Count

        # Assert
        if ($Mode -in 'tutorial', 'how-to') { $hasStep | Should -BeTrue } else { $instructionalHeading | Should -BeFalse }
        if ($Mode -eq 'reference') { $starts | Should -Be 1; $ends | Should -Be 1 } else { $starts + $ends | Should -Be 0 }
    }
}
