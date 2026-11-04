#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Contract tests for the committed docs v1 schemas, examples and runtime schema copies.

.DESCRIPTION
    Validates every committed example against its composed schema with the real Test-Json (never
    mocked in this suite) and Test-DocsArtifactText; checks that the composed committed set holds
    no self-referential definition; rejects in-memory mutations of each example with a finding
    that locates the mutated field; and pins the runtime copies, the common-definition parity
    with discovery v2 common, the reference rules and the example element identifiers. Mutations
    are applied to in-memory copies; no file is written.
#>

BeforeAll {
    $script:RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    $script:LibraryRoot = Join-Path -Path $script:RepositoryRoot -ChildPath '.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:SchemaText = Get-DocsTestSchemaText
    $script:ExampleText = Get-DocsTestExampleText
    $script:ComposedResult = Get-DocsComposedSchemaSet -SchemaSet $script:SchemaText
    $script:Composed = $script:ComposedResult.Schemas

    function Get-TestExampleValue {
        param([string] $Kind)
        (ConvertFrom-DocsJsonText -Text $script:ExampleText[$Kind]).Value
    }

    function Get-TestPointerParent {
        # Returns @{ Parent; Key } for the last segment of a JSON pointer inside Value.
        param([object] $Value, [string] $Pointer)
        $segments = @($Pointer.Substring(1).Split('/') | ForEach-Object { $_.Replace('~1', '/').Replace('~0', '~') })
        $node = $Value
        for ($index = 0; $index -lt $segments.Count - 1; $index++) {
            $segment = $segments[$index]
            # Direct assignment keeps the array reference; an if-expression would copy it.
            if ($node -is [System.Collections.IDictionary]) { $node = $node[$segment] } else { $node = $node[[int] $segment] }
        }
        @{ Parent = $node; Key = $segments[-1] }
    }

    function Get-TestMutatedText {
        # Applies one mutation to an in-memory copy of an example and returns its JSON text.
        param([string] $Kind, [string] $Pointer, [switch] $Remove, [AllowNull()] [object] $NewValue)
        $value = Get-TestExampleValue -Kind $Kind
        $location = Get-TestPointerParent -Value $value -Pointer $Pointer
        if ($Remove) { $location.Parent.Remove($location.Key) }
        elseif ($location.Parent -is [System.Collections.IDictionary]) { $location.Parent[$location.Key] = $NewValue }
        else { $location.Parent[[int] $location.Key] = $NewValue }
        ConvertTo-DocsJsonText -Value $value
    }

    function Invoke-TestArtifact {
        param([string] $Kind, [string] $Text)
        @{
            TestJson = [bool] (Test-Json -Json $Text -Schema $script:Composed[$Kind].Text -ErrorAction SilentlyContinue)
            Findings = Test-DocsArtifactText -ArtifactKind $Kind -JsonText $Text -ComposedSchemaSet $script:Composed
        }
    }

    function Test-TestSelfReference {
        param([AllowNull()] [object] $Node, [string] $Ref)
        if ($Node -is [System.Collections.IDictionary]) {
            foreach ($key in @($Node.Keys)) {
                if ($key -ceq '$ref' -and $Node[$key] -is [string] -and $Node[$key] -ceq $Ref) { return $true }
                if (Test-TestSelfReference -Node $Node[$key] -Ref $Ref) { return $true }
            }
        } elseif ($Node -is [System.Collections.IList]) {
            foreach ($item in $Node) { if (Test-TestSelfReference -Node $item -Ref $Ref) { return $true } }
        }
        return $false
    }

    function Get-TestRefValue {
        param([AllowNull()] [object] $Node)
        if ($Node -is [System.Collections.IDictionary]) {
            foreach ($key in @($Node.Keys)) {
                if ($key -ceq '$ref' -and $Node[$key] -is [string]) { $Node[$key] }
                Get-TestRefValue -Node $Node[$key]
            }
        } elseif ($Node -is [System.Collections.IList]) {
            foreach ($item in $Node) { Get-TestRefValue -Node $item }
        }
    }

    $script:ArtifactKinds = @('docs-profile', 'surface-inventory-snapshot', 'docs-coverage-ledger', 'docs-parity-matrix', 'docs-evidence-pin', 'docs-validation-receipt')
}

AfterAll {
    Remove-Module -Name DocsSchema, DocsSchemaWalk, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'Committed examples' {
    It 'validates the <_> example with Test-Json True and no Test-DocsArtifactText finding' -ForEach @('docs-profile', 'surface-inventory-snapshot', 'docs-coverage-ledger', 'docs-parity-matrix', 'docs-evidence-pin', 'docs-validation-receipt', 'docs-command-envelope') {
        # Act
        $outcome = Invoke-TestArtifact -Kind $_ -Text $script:ExampleText[$_]

        # Assert
        $outcome.TestJson | Should -BeTrue
        $outcome.Findings.Count | Should -Be 0
    }
}

Describe 'Composition of the committed set' {
    It 'returns no composition finding' {
        @($script:ComposedResult.Findings).Count | Should -Be 0
    }

    It 'replaces common.json-value with {} and leaves no self-referential $defs entry in the composed <_> schema' -ForEach @('docs-profile', 'surface-inventory-snapshot', 'docs-coverage-ledger', 'docs-parity-matrix', 'docs-evidence-pin', 'docs-validation-receipt', 'docs-command-envelope') {
        # Arrange
        $defs = $script:Composed[$_].Value['$defs']

        # Assert
        (ConvertTo-DocsCanonicalJson -Value $defs['common.json-value']) | Should -BeExactly "{}`n"
        foreach ($key in @($defs.Keys)) {
            Test-TestSelfReference -Node $defs[$key] -Ref ('#/$defs/' + $key) | Should -BeFalse -Because "composed `$defs entry '$key' must not reference itself"
        }
    }
}

Describe 'Artifact schema rejections' {
    It 'rejects <Kind> with <Pointer> removed by <Code> at that pointer' -ForEach @(
        @{ Kind = 'docs-profile'; Pointer = '/audiences'; Code = 'DOCS_SCHEMA_REQUIRED_MISSING' }
        @{ Kind = 'surface-inventory-snapshot'; Pointer = '/elements/0/declaration'; Code = 'DOCS_SCHEMA_REQUIRED_MISSING' }
        @{ Kind = 'docs-coverage-ledger'; Pointer = '/entries/0/disposition'; Code = 'DOCS_SCHEMA_REQUIRED_MISSING' }
        @{ Kind = 'docs-parity-matrix'; Pointer = '/rows/0/page_path'; Code = 'DOCS_SCHEMA_REQUIRED_MISSING' }
        @{ Kind = 'docs-evidence-pin'; Pointer = '/pins/0/claim'; Code = 'DOCS_SCHEMA_REQUIRED_MISSING' }
        @{ Kind = 'docs-validation-receipt'; Pointer = '/validation_result'; Code = 'DOCS_SCHEMA_REQUIRED_MISSING' }
    ) {
        # Act
        $outcome = Invoke-TestArtifact -Kind $Kind -Text (Get-TestMutatedText -Kind $Kind -Pointer $Pointer -Remove)

        # Assert
        $outcome.TestJson | Should -BeFalse
        @($outcome.Findings | Where-Object { $_.severity -eq 'error' -and $_.code -eq $Code -and $_.pointer -eq $Pointer }).Count | Should -BeGreaterThan 0
    }

    It 'rejects <Kind> with an unknown value at <Pointer> by <Code>' -ForEach @(
        @{ Kind = 'docs-profile'; Pointer = '/surface_selection/element_kinds/0'; Code = 'DOCS_SCHEMA_VALUE_NOT_ALLOWED' }
        @{ Kind = 'surface-inventory-snapshot'; Pointer = '/elements/0/kind'; Code = 'DOCS_SCHEMA_VALUE_NOT_ALLOWED' }
        @{ Kind = 'docs-coverage-ledger'; Pointer = '/entries/0/disposition'; Code = 'DOCS_SCHEMA_VALUE_NOT_ALLOWED' }
        @{ Kind = 'docs-parity-matrix'; Pointer = '/rows/0/kind'; Code = 'DOCS_SCHEMA_VALUE_NOT_ALLOWED' }
        @{ Kind = 'docs-evidence-pin'; Pointer = '/pins/0/element_kind'; Code = 'DOCS_SCHEMA_VALUE_NOT_ALLOWED' }
        @{ Kind = 'docs-validation-receipt'; Pointer = '/counts/by_kind/unknown-kind'; Code = 'DOCS_SCHEMA_PROPERTY_UNKNOWN' }
    ) {
        # Arrange
        $newValue = if ($Code -eq 'DOCS_SCHEMA_PROPERTY_UNKNOWN') { 0L } else { 'unknown-kind' }

        # Act
        $outcome = Invoke-TestArtifact -Kind $Kind -Text (Get-TestMutatedText -Kind $Kind -Pointer $Pointer -NewValue $newValue)

        # Assert
        $outcome.TestJson | Should -BeFalse
        @($outcome.Findings | Where-Object { $_.severity -eq 'error' -and $_.code -eq $Code -and $_.pointer -eq $Pointer }).Count | Should -BeGreaterThan 0
    }

    It 'accepts <_> with the root extensions member vendor.note and rejects the member note at /extensions/note' -ForEach @('docs-profile', 'surface-inventory-snapshot', 'docs-coverage-ledger', 'docs-parity-matrix', 'docs-evidence-pin', 'docs-validation-receipt') {
        # Act
        $accepted = Test-DocsArtifactText -ArtifactKind $_ -JsonText (Get-TestMutatedText -Kind $_ -Pointer '/extensions' -NewValue @{ 'vendor.note' = 'x' }) -ComposedSchemaSet $script:Composed
        $rejected = Test-DocsArtifactText -ArtifactKind $_ -JsonText (Get-TestMutatedText -Kind $_ -Pointer '/extensions' -NewValue @{ note = 'x' }) -ComposedSchemaSet $script:Composed

        # Assert
        $accepted.Count | Should -Be 0
        $rejected.Count | Should -Be 1
        $rejected[0].code | Should -BeExactly 'DOCS_SCHEMA_PROPERTY_UNKNOWN'
        $rejected[0].pointer | Should -BeExactly '/extensions/note'
    }

    It 'rejects an excluded ledger entry without rationale at that entry''s field' {
        # Act
        $outcome = Invoke-TestArtifact -Kind 'docs-coverage-ledger' -Text (Get-TestMutatedText -Kind 'docs-coverage-ledger' -Pointer '/entries/2/rationale' -NewValue $null)

        # Assert
        $outcome.TestJson | Should -BeFalse
        @($outcome.Findings | Where-Object { $_.pointer -eq '/entries/2/rationale' }).Count | Should -BeGreaterThan 0
    }

    It 'rejects a missing and an unknown analysis_method at <Pointer>' -ForEach @(
        @{ Kind = 'surface-inventory-snapshot'; Pointer = '/elements/0/analysis_method' }
        @{ Kind = 'surface-inventory-snapshot'; Pointer = '/analyzers/0/analysis_method' }
        @{ Kind = 'docs-coverage-ledger'; Pointer = '/entries/0/analysis_method' }
    ) {
        # Act
        $missing = Test-DocsArtifactText -ArtifactKind $Kind -JsonText (Get-TestMutatedText -Kind $Kind -Pointer $Pointer -Remove) -ComposedSchemaSet $script:Composed
        $unknown = Test-DocsArtifactText -ArtifactKind $Kind -JsonText (Get-TestMutatedText -Kind $Kind -Pointer $Pointer -NewValue 'heuristic') -ComposedSchemaSet $script:Composed

        # Assert
        @($missing | Where-Object { $_.code -eq 'DOCS_SCHEMA_REQUIRED_MISSING' -and $_.pointer -like '*analysis_method' }).Count | Should -BeGreaterThan 0
        @($unknown | Where-Object { $_.code -eq 'DOCS_SCHEMA_VALUE_NOT_ALLOWED' -and $_.pointer -like '*analysis_method' }).Count | Should -BeGreaterThan 0
    }

    It 'rejects a null line_range on the cli-command element with DOCS_SCHEMA_TYPE_MISMATCH' {
        # Act
        $result = Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot' -JsonText (Get-TestMutatedText -Kind 'surface-inventory-snapshot' -Pointer '/elements/0/line_range' -NewValue $null) -ComposedSchemaSet $script:Composed

        # Assert
        @($result | Where-Object { $_.code -eq 'DOCS_SCHEMA_TYPE_MISMATCH' -and $_.pointer -eq '/elements/0/line_range' }).Count | Should -BeGreaterThan 0
    }
}

Describe 'Envelope schema mutations' {
    It 'rejects <Case> with <Code> at <Pointer>' -ForEach @(
        @{ Case = 'ok true with exit_code 1'; Code = 'DOCS_SCHEMA_VALUE_NOT_ALLOWED'; Pointer = '/ok' }
        @{ Case = 'an extra key'; Code = 'DOCS_SCHEMA_PROPERTY_UNKNOWN'; Pointer = '/extra' }
        @{ Case = 'exit_code 2 with two findings'; Code = 'DOCS_SCHEMA_ITEM_COUNT'; Pointer = '/findings' }
        @{ Case = 'exit_code 0 with an error finding'; Code = 'DOCS_SCHEMA_VALUE_NOT_ALLOWED'; Pointer = '/findings/0/severity' }
        @{ Case = 'a missing result'; Code = 'DOCS_SCHEMA_REQUIRED_MISSING'; Pointer = '/result' }
    ) {
        # Arrange
        $envelope = Get-TestExampleValue -Kind 'docs-command-envelope'
        switch ($Case) {
            'ok true with exit_code 1' { $envelope['ok'] = $true }
            'an extra key' { $envelope['extra'] = 1L }
            'exit_code 2 with two findings' {
                $second = (ConvertFrom-DocsJsonText -Text (ConvertTo-DocsJsonText -Value $envelope['findings'][0])).Value
                $second['code'] = 'DOCS_CLI_ARGUMENTS'
                $envelope['exit_code'] = 2L
                $envelope['result'] = $null
                $envelope['findings'] = @($envelope['findings'][0], $second)
            }
            'exit_code 0 with an error finding' { $envelope['exit_code'] = 0L; $envelope['ok'] = $true }
            'a missing result' { $envelope.Remove('result') }
        }

        # Act
        $result = Test-DocsArtifactText -ArtifactKind 'docs-command-envelope' -JsonText (ConvertTo-DocsJsonText -Value $envelope) -ComposedSchemaSet $script:Composed

        # Assert
        @($result | Where-Object { $_.code -eq $Code -and $_.pointer -eq $Pointer }).Count | Should -BeGreaterThan 0
    }
}

Describe 'Audience identifier definitions' {
    It 'defines audience-id with the fixed pattern and audience-ids over it' {
        # Arrange
        $defs = (ConvertFrom-DocsJsonText -Text $script:SchemaText['common']).Value['$defs']

        # Assert
        $defs['audience-id']['pattern'] | Should -BeExactly '^[a-z0-9][a-z0-9-]*$(?![\s\S])'
        $defs['audience-ids']['items']['$ref'] | Should -BeExactly '#/$defs/audience-id'
    }

    It 'references them from audiences[].id and documentation_roots[].audience_ids in the profile schema' {
        # Arrange
        $defs = (ConvertFrom-DocsJsonText -Text $script:SchemaText['docs-profile']).Value['$defs']

        # Assert
        $defs['audience']['properties']['id']['$ref'] | Should -BeExactly 'urn:drm-copilot:docs:1.0.0:common#/$defs/audience-id'
        $defs['documentation-root']['properties']['audience_ids']['$ref'] | Should -BeExactly 'urn:drm-copilot:docs:1.0.0:common#/$defs/audience-ids'
    }
}

Describe 'Runtime copies, parity and references' {
    It 'keeps the runtime schema file set equal to schemas/docs/v1 with byte-identical pairs' {
        # Arrange
        $canonical = Join-Path -Path $script:RepositoryRoot -ChildPath 'schemas/docs/v1'
        $runtime = Join-Path -Path $script:RepositoryRoot -ChildPath '.claude/lib/docs/schemas/v1'
        [string[]] $canonicalNames = @(Get-ChildItem -LiteralPath $canonical -File | ForEach-Object { $_.Name })
        [string[]] $runtimeNames = @(Get-ChildItem -LiteralPath $runtime -File | ForEach-Object { $_.Name })
        [Array]::Sort($canonicalNames, [System.StringComparer]::Ordinal)
        [Array]::Sort($runtimeNames, [System.StringComparer]::Ordinal)
        $schemaNames = Get-DocsSchemaName
        [string[]] $registeredNames = @($schemaNames | ForEach-Object { "$_.schema.json" })
        [Array]::Sort($registeredNames, [System.StringComparer]::Ordinal)

        # Assert
        $canonicalNames | Should -Be $registeredNames
        $runtimeNames | Should -Be $canonicalNames
        foreach ($name in $canonicalNames) {
            $left = Get-DocsBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes((Join-Path -Path $canonical -ChildPath $name)))
            $right = Get-DocsBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes((Join-Path -Path $runtime -ChildPath $name)))
            $right | Should -BeExactly $left -Because "$name must be byte-identical"
        }
    }

    It 'keeps each copied common definition equal to discovery v2 common, timestamp excluded' {
        # Arrange
        $docsDefs = (ConvertFrom-DocsJsonText -Text (Get-Content -LiteralPath (Join-Path -Path $script:RepositoryRoot -ChildPath 'schemas/docs/v1/common.schema.json') -Raw)).Value['$defs']
        $discoveryDefs = (ConvertFrom-DocsJsonText -Text (Get-Content -LiteralPath (Join-Path -Path $script:RepositoryRoot -ChildPath 'schemas/discovery/v2/common.schema.json') -Raw)).Value['$defs']
        $copied = @('text', 'identifier', 'identifiers', 'relative-path', 'paths', 'path-or-glob', 'exclusion', 'exclusions', 'revision', 'sha256', 'extensions', 'json-value', 'validation-outcome')

        # Assert
        foreach ($name in $copied) {
            $discoveryDefs.Contains($name) | Should -BeTrue -Because "discovery v2 common defines '$name'"
            (ConvertTo-DocsCanonicalJson -Value $docsDefs[$name]) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value $discoveryDefs[$name]) -Because "'$name' is copied unchanged"
        }
        $docsDefs['timestamp']['pattern'] | Should -Not -BeNullOrEmpty
    }

    It 'references only docs common definitions or local definitions from every docs schema' {
        foreach ($name in $script:SchemaText.Keys) {
            $refs = @(Get-TestRefValue -Node (ConvertFrom-DocsJsonText -Text $script:SchemaText[$name]).Value)
            foreach ($ref in $refs) {
                ($ref.StartsWith('urn:drm-copilot:docs:1.0.0:common#/$defs/') -or $ref.StartsWith('#')) | Should -BeTrue -Because "$name ref '$ref' must not name a discovery URN or a file"
            }
        }
    }

    It 'derives each snapshot example element_id from its kind, path and declaration' {
        # Arrange
        $elements = (Get-TestExampleValue -Kind 'surface-inventory-snapshot')['elements']

        # Assert
        $elements.Count | Should -BeGreaterThan 0
        foreach ($element in $elements) {
            $element['element_id'] | Should -BeExactly (Get-DocsElementId -Kind $element['kind'] -Path $element['path'] -Declaration $element['declaration'])
        }
    }
}
