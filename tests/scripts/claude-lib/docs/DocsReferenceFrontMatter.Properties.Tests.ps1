#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Seeded property tests for every exported function of DocsReferenceFrontMatter.psm1.

.DESCRIPTION
    One case per seed in 11, 23, 47, 101 and 211. Each case builds [System.Random]::new($Seed),
    draws value sets, bodies and profiles through DocsReference.TestSupport.psm1, asserts
    relations rather than drawn values, and passes -Because "seed $Seed".
    ConvertFrom-DocsReferencePageText is called with COMPOSED-SET from
    New-DocsReferenceComposedSchemaSet and the drawn profile's audiences[].id values. BOM and CRLF
    variants are built in memory.
#>

BeforeAll {
    $script:LibRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsReferenceFrontMatter.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReference.TestSupport.psm1') -Force -ErrorAction Stop

    $script:ComposedSet = New-DocsReferenceComposedSchemaSet
    $script:PagePath = 'docs/reference/api-reference.md'
    $script:FieldOrder = @('owner', 'last_reviewed', 'audience', 'diataxis_mode', 'surface_refs', 'title', 'extensions')

    function Get-TestAudienceId {
        param([System.Collections.IDictionary] $Drawn)
        return , [string[]] @($Drawn['audiences'] | ForEach-Object { [string] $_['id'] })
    }

    function Get-TestDrawnValue {
        # Draws a valid front-matter value set whose audience is a non-empty subset of AudienceId.
        param([System.Random] $Random, [string[]] $AudienceId)
        $value = [ordered]@{}
        $value['owner'] = @('docs-team', 'a1', 'core.writers', 'x_y-z')[$Random.Next(0, 4)]
        $value['last_reviewed'] = '{0:D4}-{1:D2}-{2:D2}' -f $Random.Next(2000, 2031), $Random.Next(1, 13), $Random.Next(1, 29)
        [object[]] $shuffled = Get-DocsReferenceShuffled -Random $Random -Item $AudienceId
        $value['audience'] = [string[]] @($shuffled | Select-Object -First $Random.Next(1, $AudienceId.Count + 1))
        $value['diataxis_mode'] = 'reference'
        $refs = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
        $refCount = $Random.Next(0, 4)
        for ($index = 0; $index -lt $refCount; $index++) { [void]$refs.Add([string] (New-DocsReferenceRandomElement -Random $Random)['element_id']) }
        $value['surface_refs'] = [string[]] @($refs)
        if ($Random.Next(0, 2) -eq 0) { $value['title'] = Get-DocsReferenceRandomText -Random $Random -ForIdentity }
        if ($Random.Next(0, 3) -eq 0) { $value['extensions'] = [ordered]@{ 'acme.note' = (Get-DocsReferenceRandomText -Random $Random -ForIdentity); 'acme.count' = [long] $Random.Next(0, 99) } }
        return $value
    }

    function Get-TestDrawnBody {
        # Draws author prose lines and returns them joined with LF plus a final LF.
        param([System.Random] $Random)
        return ((New-DocsReferenceRandomProse -Random $Random) -join "`n") + "`n"
    }

    function Get-TestFieldJson {
        # Returns the canonical JSON of each field present, keyed by field name, for comparison.
        param([System.Collections.IDictionary] $Value)
        return (@($script:FieldOrder | Where-Object { $Value.Contains($_) } | ForEach-Object { $_ + '=' + (ConvertTo-DocsCanonicalJson -Value $Value[$_]).TrimEnd("`n") }) -join "`n")
    }

    function Get-TestVariant {
        # Returns the BOM and CRLF variant of a text.
        param([string] $Text)
        return [string][char]0xFEFF + $Text.Replace("`n", "`r`n")
    }
}

AfterAll {
    Get-Module -Name 'Docs*', 'DiscoveryEncoding' | Remove-Module -Force -ErrorAction SilentlyContinue
}

Describe 'Split-DocsReferenceFrontMatter' {
    It 'rejoins to the LF-normalized input with the delimiter offset, and agrees on BOM and CRLF variants (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 30; $draw++) {
            $body = Get-TestDrawnBody -Random $random
            $shape = $random.Next(0, 4)
            $text = switch ($shape) {
                0 { $body }
                1 { (@(' ---', '--- ', 'title')[$random.Next(0, 3)]) + "`n" + $body }
                2 { "---`n" + (@(1..$random.Next(1, 4) | ForEach-Object { "key${_}: value" }) -join "`n") + "`n" + (@('---', '...')[$random.Next(0, 2)]) + "`n" + $body }
                default { "---`nowner: `"a`"`n" + $body.Replace('---', '-x-').Replace('...', '.x.') }
            }

            # Act
            $split = Split-DocsReferenceFrontMatter -Text $text
            $variant = Split-DocsReferenceFrontMatter -Text (Get-TestVariant -Text $text)

            # Assert
            $parts = [System.Collections.Generic.List[string]]::new()
            if ($split.HasFrontMatter) {
                $parts.Add('---'); $parts.AddRange($split.FrontMatterLine)
                if ($split.Terminated) { $parts.Add($split.ClosingDelimiter) }
                $split.BodyLineOffset | Should -Be ($split.FrontMatterLine.Count + $(if ($split.Terminated) { 2 } else { 1 })) -Because "seed $Seed"
            } else {
                $split.BodyLineOffset | Should -Be 0 -Because "seed $Seed"
                ($split.BodyLine -join "`n") | Should -BeExactly $text -Because "seed $Seed"
            }
            $parts.AddRange($split.BodyLine)
            ($parts -join "`n") | Should -BeExactly $text -Because "seed $Seed"
            $split.HasFrontMatter | Should -Be ($shape -ge 2) -Because "seed $Seed"
            $split.Terminated | Should -Be ($shape -eq 2) -Because "seed $Seed"
            ($variant.FrontMatterLine -join "`n") | Should -BeExactly ($split.FrontMatterLine -join "`n") -Because "seed $Seed"
            ($variant.BodyLine -join "`n") | Should -BeExactly ($split.BodyLine -join "`n") -Because "seed $Seed"
            $variant.BodyLineOffset | Should -Be $split.BodyLineOffset -Because "seed $Seed"
        }
    }
}

Describe 'ConvertFrom-DocsReferencePageText' {
    It 'returns the drawn values and body, agrees on BOM and CRLF variants, and locates an inserted marker (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 6; $draw++) {
            [string[]] $audienceId = Get-TestAudienceId -Drawn (New-DocsReferenceRandomProfile -Random $random)
            $value = Get-TestDrawnValue -Random $random -AudienceId $audienceId
            $block = ConvertTo-DocsReferenceFrontMatterText -Value $value
            $body = Get-TestDrawnBody -Random $random
            [string[]] $blockLine = $block.TrimEnd("`n").Split("`n")
            $at = $random.Next(1, $blockLine.Count)
            $marked = (@($blockLine[0..($at - 1)]) + @('<!-- docs:generated:start id=x -->') + @($blockLine[$at..($blockLine.Count - 1)])) -join "`n"

            # Act
            $result = ConvertFrom-DocsReferencePageText -Text ($block + $body) -PagePath $script:PagePath -ComposedSchemaSet $script:ComposedSet -AudienceId $audienceId
            $variant = ConvertFrom-DocsReferencePageText -Text (Get-TestVariant -Text ($block + $body)) -PagePath $script:PagePath -ComposedSchemaSet $script:ComposedSet -AudienceId $audienceId
            $withMarker = ConvertFrom-DocsReferencePageText -Text ($marked + "`n" + $body) -PagePath $script:PagePath -ComposedSchemaSet $script:ComposedSet -AudienceId $audienceId

            # Assert
            $result.Finding.Count | Should -Be 0 -Because "seed $Seed"
            (Get-TestFieldJson -Value $result.Value) | Should -BeExactly (Get-TestFieldJson -Value $value) -Because "seed $Seed"
            ($result.BodyLine -join "`n") | Should -BeExactly $body -Because "seed $Seed"
            $variant.Finding.Count | Should -Be 0 -Because "seed $Seed"
            (Get-TestFieldJson -Value $variant.Value) | Should -BeExactly (Get-TestFieldJson -Value $result.Value) -Because "seed $Seed"
            ($variant.BodyLine -join "`n") | Should -BeExactly $body -Because "seed $Seed"
            @($withMarker.Finding | ForEach-Object { $_['code'] }) | Should -Be @('REFERENCE_MARKER_IN_FRONT_MATTER') -Because "seed $Seed"
            $withMarker.Finding[0]['message'] | Should -Match "^line $($at + 1): " -Because "seed $Seed"
        }
    }
}

Describe 'Resolve-DocsReferenceFrontMatterValue' {
    It 'sets reference mode and the sorted page identifiers, and preserves existing values (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 20; $draw++) {
            [string[]] $audienceId = Get-TestAudienceId -Drawn (New-DocsReferenceRandomProfile -Random $random)
            $drawnValue = Get-TestDrawnValue -Random $random -AudienceId $audienceId
            $existing = $null
            if ($random.Next(0, 4) -ne 0) {
                $existing = [ordered]@{}
                foreach ($key in $drawnValue.Keys) { if ($random.Next(0, 2) -eq 0) { $existing[$key] = $drawnValue[$key] } }
            }
            $pagePlan = [ordered]@{ Path = $script:PagePath; Title = 'API reference'; Owner = 'plan-owner'; Audience = [string[]] @($audienceId[0]) }
            $pageRef = [object[]] @(1..3 | ForEach-Object { [string] (New-DocsReferenceRandomElement -Random $random)['element_id'] })
            [string[]] $sortedRef = @($pageRef | Sort-Object -Unique -CaseSensitive)
            [Array]::Sort($sortedRef, [System.StringComparer]::Ordinal)
            $capturedAt = '{0:D4}-{1:D2}-{2:D2}T0{3}:00:00Z' -f $random.Next(2000, 2031), $random.Next(1, 13), $random.Next(1, 29), $random.Next(0, 10)
            $isNew = $random.Next(0, 2) -eq 0

            # Act
            $result = Resolve-DocsReferenceFrontMatterValue -Existing $existing -PagePlan $pagePlan -SurfaceRef ([string[]] (Get-DocsReferenceShuffled -Random $random -Item $pageRef)) -CapturedAt $capturedAt -IsNewPage $isNew

            # Assert
            $result.Finding.Count | Should -Be 0 -Because "seed $Seed"
            $result.Value['diataxis_mode'] | Should -BeExactly 'reference' -Because "seed $Seed"
            ($result.Value['surface_refs'] -join ',') | Should -BeExactly ($sortedRef -join ',') -Because "seed $Seed"
            foreach ($key in @('owner', 'audience', 'last_reviewed', 'title', 'extensions')) {
                if ($null -ne $existing -and $existing.Contains($key)) {
                    (ConvertTo-DocsCanonicalJson -Value $result.Value[$key]) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value $existing[$key]) -Because "seed $Seed"
                }
            }
            if ($null -eq $existing -or -not $existing.Contains('last_reviewed')) { $result.Value['last_reviewed'] | Should -BeExactly $capturedAt.Substring(0, 10) -Because "seed $Seed" }
            if ($null -eq $existing -or -not $existing.Contains('owner')) { $result.Value['owner'] | Should -BeExactly 'plan-owner' -Because "seed $Seed" }
        }
    }
}

Describe 'ConvertTo-DocsReferenceFrontMatterText' {
    It 'writes fields in the fixed order on single lines that parse back to the input values (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)

        for ($draw = 0; $draw -lt 6; $draw++) {
            [string[]] $audienceId = Get-TestAudienceId -Drawn (New-DocsReferenceRandomProfile -Random $random)
            $drawnValue = Get-TestDrawnValue -Random $random -AudienceId $audienceId
            $shuffledKey = Get-DocsReferenceShuffled -Random $random -Item @($drawnValue.Keys)
            $value = [ordered]@{}
            foreach ($key in $shuffledKey) { $value[$key] = $drawnValue[$key] }

            # Act
            $text = ConvertTo-DocsReferenceFrontMatterText -Value $value
            $parsed = ConvertFrom-DocsReferencePageText -Text ($text + "Body.`n") -PagePath $script:PagePath -ComposedSchemaSet $script:ComposedSet -AudienceId $audienceId

            # Assert
            [string[]] $lines = $text.TrimEnd("`n").Split("`n")
            $lines.Count | Should -Be ($value.Count + 2) -Because "seed $Seed"
            [string[]] $keys = @($lines[1..($lines.Count - 2)] | ForEach-Object { $_.Substring(0, $_.IndexOf(':')) })
            [string[]] $expectedKeys = @($script:FieldOrder | Where-Object { $value.Contains($_) })
            ($keys -join ',') | Should -BeExactly ($expectedKeys -join ',') -Because "seed $Seed"
            $text | Should -Not -Match '[\r\x85\p{Zl}\p{Zp}]' -Because "seed $Seed"
            $parsed.Finding.Count | Should -Be 0 -Because "seed $Seed"
            (Get-TestFieldJson -Value $parsed.Value) | Should -BeExactly (Get-TestFieldJson -Value $value) -Because "seed $Seed"
        }
    }
}
