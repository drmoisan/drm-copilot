#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsJson.psm1.

.DESCRIPTION
    Covers ordinal object keys, number types, string preservation, the three parse finding codes
    with their pointers, the depth bound, LF normalization of serialized text, delegation of
    canonical JSON and SHA-256 to DiscoveryEncoding.psm1, and ConvertFrom-DocsUtf8Bytes. Every
    input is an in-memory string or byte array; no file is read or written.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'The ordinal key-order test needs keys that differ only in case; the @{} literal is case-insensitive.')]
param()

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'discovery-validation/DiscoveryEncoding.psm1') -Force -ErrorAction Stop
    $script:Bom = [byte[]]@(0xEF, 0xBB, 0xBF)
}

AfterAll {
    Remove-Module -Name DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertFrom-DocsJsonText' {
    It 'keeps object keys that differ only in case as separate ordinal keys' {
        # Act
        $parsed = ConvertFrom-DocsJsonText -Text '{"a":1,"A":2}'

        # Assert
        $parsed.Findings.Count | Should -Be 0
        $parsed.Value['a'] | Should -Be 1
        $parsed.Value['A'] | Should -Be 2
        $parsed.Value.Count | Should -Be 2
    }

    It 'returns Int64 for integral numbers and Double for other numbers' {
        # Act
        $parsed = ConvertFrom-DocsJsonText -Text '{"i":7,"f":1.5,"e":1e2}'

        # Assert
        $parsed.Value['i'] | Should -BeOfType ([long])
        $parsed.Value['f'] | Should -BeOfType ([double])
        $parsed.Value['e'] | Should -BeOfType ([double])
        $parsed.Value['f'] | Should -Be 1.5
    }

    It 'keeps a timestamp-shaped string as a string' {
        # Act
        $parsed = ConvertFrom-DocsJsonText -Text '{"t":"2026-10-30T12:00:00Z"}'

        # Assert
        $parsed.Value['t'] | Should -BeOfType ([string])
        $parsed.Value['t'] | Should -BeExactly '2026-10-30T12:00:00Z'
    }

    It 'returns arrays, booleans and null in order' {
        # Act
        $parsed = ConvertFrom-DocsJsonText -Text '[true,false,null,"x",[1]]'

        # Assert
        $parsed.Findings.Count | Should -Be 0
        $parsed.Value.Count | Should -Be 5
        $parsed.Value[0] | Should -BeTrue
        $parsed.Value[1] | Should -BeFalse
        $null -eq $parsed.Value[2] | Should -BeTrue
        $parsed.Value[3] | Should -BeExactly 'x'
        $parsed.Value[4][0] | Should -Be 1
    }

    It 'ignores one leading byte order mark' {
        # Act
        $parsed = ConvertFrom-DocsJsonText -Text ([string][char]0xFEFF + '{"a":true}')

        # Assert
        $parsed.Findings.Count | Should -Be 0
        $parsed.Value['a'] | Should -BeTrue
    }

    It 'reports DOCS_JSON_INVALID with an empty pointer for malformed text' {
        # Act
        $parsed = ConvertFrom-DocsJsonText -Text '{"a":' -ArtifactPath 'docs/profile.json'

        # Assert
        $null -eq $parsed.Value | Should -BeTrue
        $parsed.Findings.Count | Should -Be 1
        $parsed.Findings[0].code | Should -BeExactly 'DOCS_JSON_INVALID'
        $parsed.Findings[0].pointer | Should -BeExactly ''
        $parsed.Findings[0].artifact_path | Should -BeExactly 'docs/profile.json'
    }

    It 'reports DOCS_JSON_INVALID for empty and whitespace-only text' -TestCases @(
        @{ Text = '' }
        @{ Text = "  `n" }
    ) {
        param($Text)

        # Act
        $parsed = ConvertFrom-DocsJsonText -Text $Text

        # Assert
        $parsed.Findings.Count | Should -Be 1
        $parsed.Findings[0].code | Should -BeExactly 'DOCS_JSON_INVALID'
        $null -eq $parsed.Findings[0].artifact_path | Should -BeTrue
    }

    It 'reports DOCS_JSON_DUPLICATE_KEY at the pointer of the repeated member' {
        # Act
        $parsed = ConvertFrom-DocsJsonText -Text '{"a":{"b":1,"b":2}}'

        # Assert
        $null -eq $parsed.Value | Should -BeTrue
        $parsed.Findings.Count | Should -Be 1
        $parsed.Findings[0].code | Should -BeExactly 'DOCS_JSON_DUPLICATE_KEY'
        $parsed.Findings[0].pointer | Should -BeExactly '/a/b'
        $parsed.Findings[0].message | Should -BeLike '*b*'
    }

    It 'escapes tilde and slash in the duplicate-key pointer' {
        # Act
        $parsed = ConvertFrom-DocsJsonText -Text '{"x/y":[{"~":1,"~":2}]}'

        # Assert
        $parsed.Findings[0].pointer | Should -BeExactly '/x~1y/0/~0'
    }

    It 'reports DOCS_JSON_TOO_DEEP when nesting exceeds MaxDepth' {
        # Act
        $parsed = ConvertFrom-DocsJsonText -Text '[[[1]]]' -MaxDepth 2

        # Assert
        $null -eq $parsed.Value | Should -BeTrue
        $parsed.Findings[0].code | Should -BeExactly 'DOCS_JSON_TOO_DEEP'
        $parsed.Findings[0].pointer | Should -BeExactly '/0/0'
    }

    It 'accepts nesting exactly at MaxDepth' {
        # Act
        $parsed = ConvertFrom-DocsJsonText -Text '[[[1]]]' -MaxDepth 3

        # Assert
        $parsed.Findings.Count | Should -Be 0
        $parsed.Value[0][0][0] | Should -Be 1
    }

    It 'reports DOCS_JSON_TOO_DEEP when the reader bound itself is exceeded' {
        # Arrange: deeper than MaxDepth plus the reader margin of 64.
        $text = ('[' * 70) + (']' * 70)

        # Act
        $parsed = ConvertFrom-DocsJsonText -Text $text -MaxDepth 1

        # Assert
        $parsed.Findings[0].code | Should -BeExactly 'DOCS_JSON_TOO_DEEP'
    }

    It 'returns every finding key of the docs common finding shape' {
        # Act
        $finding = (ConvertFrom-DocsJsonText -Text '{').Findings[0]

        # Assert
        @($finding.Keys) | Should -Be @('code', 'severity', 'artifact_path', 'pointer', 'related_ids', 'related_paths', 'message', 'next_action')
        $finding.severity | Should -BeExactly 'error'
    }
}

Describe 'ConvertTo-DocsJsonText' {
    It 'sorts keys by ordinal order at every depth and ends with exactly one LF' {
        # Arrange: an ordinal table holds keys that differ only in case.
        $inner = [hashtable]::new([System.StringComparer]::Ordinal)
        $inner['z'] = $true
        $inner['B'] = $null
        $value = [hashtable]::new([System.StringComparer]::Ordinal)
        $value['b'] = 1
        $value['a'] = $inner
        $value['A'] = 'x'

        # Act
        $text = ConvertTo-DocsJsonText -Value $value

        # Assert
        $text | Should -BeExactly ('{"A":"x","a":{"B":null,"z":true},"b":1}' + "`n")
    }

    It 'writes indented text with LF line endings only' {
        # Act
        $text = ConvertTo-DocsJsonText -Value ([ordered]@{ a = @(1, 2); b = 'c' }) -Indented

        # Assert
        $text.Contains("`r") | Should -BeFalse
        $text.EndsWith("`n") | Should -BeTrue
        $text.EndsWith("`n`n") | Should -BeFalse
        $text.Split("`n").Count | Should -BeGreaterThan 3
    }

    It 'keeps non-ASCII text literal and round-trips through the parser' {
        # Arrange
        $accented = 'caf' + [char]0x00E9
        $value = [ordered]@{ name = $accented; n = [long]3; d = 2.5; list = @('a', $null, $false) }

        # Act
        $text = ConvertTo-DocsJsonText -Value $value
        $parsed = ConvertFrom-DocsJsonText -Text $text

        # Assert
        $text.Contains($accented) | Should -BeTrue
        $parsed.Value['name'] | Should -BeExactly $accented
        $parsed.Value['n'] | Should -Be 3
        $parsed.Value['d'] | Should -Be 2.5
        $parsed.Value['list'].Count | Should -Be 3
    }

    It 'writes the properties of a PSCustomObject' {
        # Act
        $text = ConvertTo-DocsJsonText -Value ([pscustomobject]@{ b = 2; a = 1 })

        # Assert
        $text | Should -BeExactly ('{"a":1,"b":2}' + "`n")
    }

    It 'throws for a value that is not representable as JSON' {
        # Act / Assert
        { ConvertTo-DocsJsonText -Value ([guid]::Empty) } | Should -Throw -ExpectedMessage 'DOCS_JSON_UNSUPPORTED_VALUE*'
    }
}

Describe 'Canonical JSON and SHA-256 delegation' {
    It 'returns the DiscoveryEncoding canonical JSON for the same value' {
        # Arrange
        $value = [ordered]@{ path = 'a/b'; kind = 'cli-command'; declaration = 'tool x' }

        # Act / Assert
        ConvertTo-DocsCanonicalJson -Value $value | Should -BeExactly (ConvertTo-DiscoveryCanonicalJson -Value $value)
    }

    It 'returns the DiscoveryEncoding digest of text and of bytes' {
        # Arrange
        $bytes = [byte[]]@(1, 2, 3)

        # Act / Assert
        Get-DocsSha256Hex -Text 'abc' | Should -BeExactly (Get-DiscoverySha256Hex -Text 'abc')
        Get-DocsSha256Hex -Text '' | Should -BeExactly 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
        Get-DocsBytesSha256Hex -Bytes $bytes | Should -BeExactly (Get-DiscoveryBytesSha256Hex -Bytes $bytes)
    }
}

Describe 'Get-DocsTextSha256Hex (issue #1173 B11)' {
    It 'returns one hash for the LF, CRLF and lone-CR byte forms of one text' {
        # Arrange (byte forms built in memory, because committed text fixtures are normalized to LF)
        $utf8 = [System.Text.UTF8Encoding]::new($false)
        $lf = $utf8.GetBytes("{`n  `"a`": 1,`n  `"b`": `"x`"`n}`n")
        $crlf = $utf8.GetBytes("{`r`n  `"a`": 1,`r`n  `"b`": `"x`"`r`n}`r`n")
        $cr = $utf8.GetBytes("{`r  `"a`": 1,`r  `"b`": `"x`"`r}`r")
        $mixed = $utf8.GetBytes("{`r`n  `"a`": 1,`r  `"b`": `"x`"`n}`r`n")

        # Act
        $hashes = @($lf, $crlf, $cr, $mixed | ForEach-Object { Get-DocsTextSha256Hex -Bytes $_ })

        # Assert
        @($hashes | Sort-Object -Unique).Count | Should -Be 1
        $hashes[0] | Should -BeExactly (Get-DocsBytesSha256Hex -Bytes $lf)
        (Get-DocsBytesSha256Hex -Bytes $crlf) | Should -Not -BeExactly $hashes[0] -Because 'the raw-byte hash still differs'
    }

    It 'equals Get-DocsBytesSha256Hex for LF-only content, empty content and content that keeps a BOM' {
        # Arrange
        $bom = [byte[]]@(0xEF, 0xBB, 0xBF) + [System.Text.UTF8Encoding]::new($false).GetBytes("x`n")
        $bomCrlf = [byte[]]@(0xEF, 0xBB, 0xBF) + [System.Text.UTF8Encoding]::new($false).GetBytes("x`r`n")

        # Act / Assert
        foreach ($bytes in @([byte[]]@(), [byte[]]@(0x61, 0x0A, 0x62), $bom)) {
            Get-DocsTextSha256Hex -Bytes $bytes | Should -BeExactly (Get-DocsBytesSha256Hex -Bytes $bytes)
        }
        Get-DocsTextSha256Hex -Bytes $bomCrlf | Should -BeExactly (Get-DocsBytesSha256Hex -Bytes $bom) -Because 'the BOM is kept and only line endings change'
    }
}

Describe 'ConvertFrom-DocsUtf8Bytes' {
    It 'returns a non-null empty string for zero bytes' {
        # Act
        $text = ConvertFrom-DocsUtf8Bytes -Bytes ([byte[]]@())

        # Assert
        $null -eq $text | Should -BeFalse
        $text | Should -BeOfType ([string])
        $text | Should -BeExactly ''
    }

    It 'returns a non-null empty string for a byte order mark alone' {
        # Act
        $text = ConvertFrom-DocsUtf8Bytes -Bytes $script:Bom

        # Assert
        $null -eq $text | Should -BeFalse
        $text | Should -BeOfType ([string])
        $text | Should -BeExactly ''
    }

    It 'removes one leading byte order mark' {
        # Act / Assert
        ConvertFrom-DocsUtf8Bytes -Bytes ([byte[]]($script:Bom + [System.Text.Encoding]::UTF8.GetBytes('abc'))) | Should -BeExactly 'abc'
    }

    It 'keeps the second of two leading byte order marks' {
        # Act
        $text = ConvertFrom-DocsUtf8Bytes -Bytes ([byte[]]($script:Bom + $script:Bom + [System.Text.Encoding]::UTF8.GetBytes('abc')))

        # Assert
        $text | Should -BeExactly ([string][char]0xFEFF + 'abc')
    }

    It 'decodes plain UTF-8 bytes unchanged' {
        # Act / Assert
        ConvertFrom-DocsUtf8Bytes -Bytes ([System.Text.Encoding]::UTF8.GetBytes('abc')) | Should -BeExactly 'abc'
    }

    It 'throws for an invalid UTF-8 sequence' {
        # Act / Assert
        { ConvertFrom-DocsUtf8Bytes -Bytes ([byte[]]@(0x61, 0xFF)) } | Should -Throw
    }
}
