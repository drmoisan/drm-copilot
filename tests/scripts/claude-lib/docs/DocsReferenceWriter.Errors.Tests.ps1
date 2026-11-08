#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Command tests for generate-reference exit codes, loading and planning errors, finding
    pass-through and page blocking.

.DESCRIPTION
    Every test runs Invoke-DocsCommandCli -Command generate-reference (Invoke-DocsCommand.ps1 is
    dot-sourced) against an in-memory command context from DocsReference.TestSupport.psm1, whose
    UtcNow and InvokeProcess members throw. Exit 2 usage errors are detected before any context
    call; exit 1 covers an absent profile or snapshot and every loading or planning error, with no
    recorded write in either mode; exit 3 covers a read failure other than absence and an
    uncomposable schema set. Each marker error class blocks only its page.
#>

BeforeAll {
    $script:LibRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReference.TestSupport.psm1') -Force -ErrorAction Stop
    . (Join-Path -Path $script:LibRoot -ChildPath 'Invoke-DocsCommand.ps1')

    $script:SchemaText = Get-DocsReferenceSchemaTextMap
    $script:CommandElement = New-DocsReferenceFixedElement -Kind 'cli-command' -Declaration 'tool run'
    $script:OptionElement = New-DocsReferenceFixedElement -Kind 'cli-option' -Declaration '--fast' -ParentId $script:CommandElement['element_id']
    $script:CommandId = [string] $script:CommandElement['element_id']
    $script:OptionId = [string] $script:OptionElement['element_id']
    $script:Element = [object[]]@(
        $script:CommandElement
        $script:OptionElement
        (New-DocsReferenceFixedElement -Kind 'config-key' -Declaration 'tool.level' -Path 'conf/tool.toml')
    )
    $script:Cli = 'docs/reference/cli-reference.md'
    $script:Config = 'docs/reference/config-reference.md'
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'

    function Invoke-TestGenerate {
        # Runs generate-reference -Json over File; returns @{ Outcome; Memory; Envelope; Code }.
        param(
            [string[]] $Argument = @(),
            [AllowNull()] [System.Collections.IDictionary] $File,
            [AllowNull()] [string[]] $ReadFailure
        )
        $map = if ($null -eq $File) { New-DocsReferenceFileMap -ProfileValue (New-DocsReferenceFixedProfile) -Element $script:Element -SchemaTextMap $script:SchemaText } else { $File }
        $memory = New-DocsReferenceMemoryContext -File $map -ReadTextFailurePath $ReadFailure
        $outcome = Invoke-DocsCommandCli -Command 'generate-reference' -CommandArgument $Argument -Context $memory.Context -Json:$true
        $envelope = (ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value
        [string[]] $code = @($envelope['findings'] | ForEach-Object { [string] $_['code'] })
        return @{ Outcome = $outcome; Memory = $memory; Envelope = $envelope; Code = $code }
    }

    function Get-TestLoadingErrorFile {
        # Returns the repository map of one loading or planning error case.
        param([string] $Case)
        $docsProfile = New-DocsReferenceFixedProfile
        switch ($Case) {
            'profile that is not JSON' { return New-DocsReferenceFileMap -ProfileText '{' -Element $script:Element -SchemaTextMap $script:SchemaText }
            'snapshot that fails its schema' {
                $snapshot = (ConvertFrom-DocsJsonText -Text (ConvertTo-DocsReferenceSnapshotText -Element $script:Element)).Value
                $snapshot.Remove('captured_at')
                return New-DocsReferenceFileMap -ProfileValue $docsProfile -SnapshotText (ConvertTo-DocsJsonText -Value $snapshot) -SchemaTextMap $script:SchemaText
            }
            'profile without a non-glob reference entry' {
                $globOnly = New-DocsReferenceFixedProfile -DirectoryMode @([ordered]@{ path_or_glob = 'docs/ref*'; mode = 'reference' })
                return New-DocsReferenceFileMap -ProfileValue $globOnly -Element $script:Element -SchemaTextMap $script:SchemaText
            }
            default { return New-DocsReferenceFileMap -ProfileValue $docsProfile -Element $script:Element -Page @{ 'docs/reference/cli-reference.md' = " <!-- docs:generated:start id=x -->`n" } -SchemaTextMap $script:SchemaText }
        }
    }

    function Get-TestMarkerPage {
        # Returns an existing CLI page text that triggers one marker or fence error class.
        param([string] $Code)
        $start = "<!-- docs:generated:start id=$($script:CommandId) -->"
        $end = "<!-- docs:generated:end id=$($script:CommandId) -->"
        switch ($Code) {
            'REFERENCE_MARKER_MALFORMED' { return "# CLI reference`n`n $start`n" }
            'REFERENCE_MARKER_DUPLICATE' { return "# CLI reference`n`n$start`n`n$end`n`n$start`n`n$end`n" }
            'REFERENCE_MARKER_UNBALANCED' { return "# CLI reference`n`n$end`n" }
            'REFERENCE_MARKER_MISMATCH' { return "# CLI reference`n`n$start`n`n<!-- docs:generated:end id=$($script:OptionId) -->`n" }
            'REFERENCE_MARKER_IN_FRONT_MATTER' { return "---`n$start`n---`n# CLI reference`n" }
            default { return "# CLI reference`n`n" + '```text' + "`ncode`n" }
        }
    }
}

AfterAll {
    Get-Module -Name 'Docs*', 'DiscoveryEncoding' | Remove-Module -Force -ErrorAction SilentlyContinue
}

Describe 'generate-reference usage errors' {
    It 'exits 2 with only DOCS_CLI_ARGUMENTS, result null and no context call for <Case>' -ForEach @(
        @{ Case = 'an unknown option'; Argument = @('-Bogus', 'x') }
        @{ Case = 'a missing option value'; Argument = @('-Profile') }
        @{ Case = 'a repeated value option'; Argument = @('-Snapshot', 'a.json', '-Snapshot', 'b.json') }
        @{ Case = 'a non-relative -Profile'; Argument = @('-Profile', '/abs/profile.json') }
        @{ Case = 'a non-relative -Snapshot'; Argument = @('-Snapshot', '../snapshot.json') }
        @{ Case = 'a non-relative -OutputDirectory'; Argument = @('-OutputDirectory', '/docs/reference') }
        @{ Case = 'an -OutputDirectory ending in a slash'; Argument = @('-OutputDirectory', 'docs/reference/') }
    ) {
        # Act
        $run = Invoke-TestGenerate -Argument $Argument

        # Assert
        $run.Outcome.ExitCode | Should -Be 2
        $run.Code | Should -Be @('DOCS_CLI_ARGUMENTS')
        $run.Envelope['result'] | Should -BeNullOrEmpty
        $run.Envelope['command'] | Should -BeExactly 'generate-reference'
        $run.Memory.CallLog.Count | Should -Be 0
    }
}

Describe 'generate-reference loading outcomes' {
    It 'exits 1 with DOCS_PROFILE_MISSING and result null when the profile is absent' {
        # Act
        $run = Invoke-TestGenerate -File (New-DocsReferenceFileMap -Element $script:Element -SchemaTextMap $script:SchemaText)

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $run.Code | Should -Be @('DOCS_PROFILE_MISSING')
        $run.Envelope['findings'][0]['artifact_path'] | Should -BeExactly $script:ProfilePath
        $run.Envelope['result'] | Should -BeNullOrEmpty
    }

    It 'exits 1 with REFERENCE_SNAPSHOT_MISSING and a result with no pages when the snapshot is absent' {
        # Act
        $run = Invoke-TestGenerate -File (New-DocsReferenceFileMap -ProfileValue (New-DocsReferenceFixedProfile) -SchemaTextMap $script:SchemaText)

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $run.Code | Should -Be @('REFERENCE_SNAPSHOT_MISSING')
        $run.Envelope['result']['mode'] | Should -BeExactly 'dry-run'
        @($run.Envelope['result']['pages']).Count | Should -Be 0
    }

    It 'exits 3 with only DOCS_CLI_RUNTIME, result null and one stderr line when ReadText fails other than by absence' {
        # Act
        $run = Invoke-TestGenerate -ReadFailure @($script:ProfilePath)

        # Assert
        $run.Outcome.ExitCode | Should -Be 3
        $run.Code | Should -Be @('DOCS_CLI_RUNTIME')
        $run.Envelope['result'] | Should -BeNullOrEmpty
        $run.Outcome.Stderr | Should -BeExactly "Invoke-DocsCommand.ps1: exit 3 (DOCS_CLI_RUNTIME)`n"
    }

    It 'exits 3 with exactly one finding and result null when the schema set does not compose' {
        # Arrange: the docs common schema text is not JSON.
        $schemaText = [ordered]@{}
        foreach ($key in @($script:SchemaText.Keys)) { $schemaText[$key] = $script:SchemaText[$key] }
        $schemaText['.claude/lib/docs/schemas/v1/common.schema.json'] = '{'
        $file = New-DocsReferenceFileMap -ProfileValue (New-DocsReferenceFixedProfile) -Element $script:Element -SchemaTextMap $schemaText

        # Act
        $run = Invoke-TestGenerate -File $file

        # Assert
        $run.Outcome.ExitCode | Should -Be 3
        $run.Code.Count | Should -Be 1
        $run.Envelope['result'] | Should -BeNullOrEmpty
        $run.Outcome.Stderr | Should -BeExactly "Invoke-DocsCommand.ps1: exit 3 ($($run.Code[0]))`n"
    }

    It 'exits 1 with <Expected> and no recorded write in <Mode> mode for a <Case>' -ForEach @(
        foreach ($mode in @('dry-run', 'write')) {
            @{ Mode = $mode; Case = 'profile that is not JSON'; Expected = 'DOCS_JSON_' }
            @{ Mode = $mode; Case = 'snapshot that fails its schema'; Expected = 'DOCS_SCHEMA_' }
            @{ Mode = $mode; Case = 'profile without a non-glob reference entry'; Expected = 'REFERENCE_OUTPUT_DIR_UNRESOLVED' }
            @{ Mode = $mode; Case = 'page with a malformed marker'; Expected = 'REFERENCE_MARKER_MALFORMED' }
        }
    ) {
        # Arrange
        [string[]] $argument = if ($Mode -ceq 'write') { @('-Write') } else { @() }

        # Act
        $run = Invoke-TestGenerate -Argument $argument -File (Get-TestLoadingErrorFile -Case $Case)

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        @($run.Code | Where-Object { $_.StartsWith($Expected, [System.StringComparison]::Ordinal) }).Count | Should -BeGreaterThan 0
        $run.Memory.WriteLog.Count | Should -Be 0
        @($run.Memory.CallLog | Where-Object { $_.StartsWith('WriteText ', [System.StringComparison]::Ordinal) }).Count | Should -Be 0
    }
}

Describe 'generate-reference finding pass-through' {
    It 'exits 1 with REFERENCE_REPOSITORY_MISMATCH at /repository when the snapshot repository differs' {
        # Arrange
        $file = New-DocsReferenceFileMap -ProfileValue (New-DocsReferenceFixedProfile) -SnapshotText (ConvertTo-DocsReferenceSnapshotText -Element $script:Element -Repository 'other-repo') -SchemaTextMap $script:SchemaText

        # Act
        $run = Invoke-TestGenerate -File $file

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $run.Code | Should -Be @('REFERENCE_REPOSITORY_MISMATCH')
        $run.Envelope['findings'][0]['pointer'] | Should -BeExactly '/repository'
        $run.Envelope['findings'][0]['severity'] | Should -BeExactly 'error'
    }

    It 'passes <Prefix> findings through unchanged with severity error' -ForEach @(
        @{ Prefix = 'DOCS_JSON_'; Case = 'json' }
        @{ Prefix = 'DOCS_SCHEMA_'; Case = 'schema' }
        @{ Prefix = 'DOCS_PROFILE_'; Case = 'profile' }
    ) {
        # Arrange
        $file = switch ($Case) {
            'json' { Get-TestLoadingErrorFile -Case 'profile that is not JSON' }
            'schema' { Get-TestLoadingErrorFile -Case 'snapshot that fails its schema' }
            default {
                $docsProfile = New-DocsReferenceFixedProfile
                $docsProfile['documentation_roots'][0]['audience_ids'] = [string[]]@('ghost')
                New-DocsReferenceFileMap -ProfileValue $docsProfile -Element $script:Element -SchemaTextMap $script:SchemaText
            }
        }

        # Act
        $run = Invoke-TestGenerate -File $file
        $matched = @($run.Envelope['findings'] | Where-Object { ([string] $_['code']).StartsWith($Prefix, [System.StringComparison]::Ordinal) })

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $matched.Count | Should -BeGreaterThan 0
        foreach ($finding in $matched) { $finding['severity'] | Should -BeExactly 'error' }
    }

    It 'reports REFERENCE_PARENT_MISSING as a warning and exits 0' {
        # Arrange: an option whose parent command is not in the snapshot.
        $orphan = New-DocsReferenceFixedElement -Kind 'cli-option' -Declaration '--slow' -ParentId (New-DocsReferenceFixedElement -Kind 'cli-command' -Declaration 'absent').element_id
        $file = New-DocsReferenceFileMap -ProfileValue (New-DocsReferenceFixedProfile) -Element @($script:CommandElement, $orphan) -SchemaTextMap $script:SchemaText

        # Act
        $run = Invoke-TestGenerate -File $file

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $run.Code | Should -Be @('REFERENCE_PARENT_MISSING')
        $run.Envelope['findings'][0]['severity'] | Should -BeExactly 'warning'
        @($run.Envelope['findings'][0]['related_ids']) | Should -Be @([string] $orphan['element_id'])
    }

    It 'blocks only the CLI page for <Code> while the configuration page is computed' -ForEach @(
        @{ Code = 'REFERENCE_MARKER_MALFORMED' }
        @{ Code = 'REFERENCE_MARKER_DUPLICATE' }
        @{ Code = 'REFERENCE_MARKER_UNBALANCED' }
        @{ Code = 'REFERENCE_MARKER_MISMATCH' }
        @{ Code = 'REFERENCE_MARKER_IN_FRONT_MATTER' }
        @{ Code = 'REFERENCE_FENCE_UNCLOSED' }
    ) {
        # Arrange
        $file = New-DocsReferenceFileMap -ProfileValue (New-DocsReferenceFixedProfile) -Element $script:Element -Page @{ $script:Cli = (Get-TestMarkerPage -Code $Code) } -SchemaTextMap $script:SchemaText

        # Act
        $run = Invoke-TestGenerate -File $file
        $pages = @($run.Envelope['result']['pages'])
        $finding = @($run.Envelope['findings'] | Where-Object { $_['code'] -ceq $Code })

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $finding.Count | Should -BeGreaterThan 0
        $finding[0]['severity'] | Should -BeExactly 'error'
        $finding[0]['artifact_path'] | Should -BeExactly $script:Cli
        @($pages | ForEach-Object { "$($_['path'])=$($_['action'])/$($_['status'])" }) | Should -Be @("$($script:Cli)=blocked/blocked", "$($script:Config)=create/planned")
        $pages[0]['sha256_after'] | Should -BeNullOrEmpty
        @($pages[0]['blocks']['added']).Count | Should -Be 0
    }

    It 'prints a blocked page line with zero block counts in the text report' {
        # Arrange
        $file = New-DocsReferenceFileMap -ProfileValue (New-DocsReferenceFixedProfile) -Element $script:Element -Page @{ $script:Cli = (Get-TestMarkerPage -Code 'REFERENCE_MARKER_UNBALANCED') } -SchemaTextMap $script:SchemaText
        $memory = New-DocsReferenceMemoryContext -File $file

        # Act
        $outcome = Invoke-DocsCommandCli -Command 'generate-reference' -CommandArgument @('-Write') -Context $memory.Context
        [string[]] $lines = $outcome.Stdout.TrimEnd("`n").Split("`n")

        # Assert
        $outcome.ExitCode | Should -Be 1
        $lines | Should -Contain "blocked $($script:Cli) (+0 ~0 -0)"
        $lines | Should -Contain "create $($script:Config) (+1 ~0 -0)"
        $lines | Should -Contain 'nothing written'
        $memory.WriteLog.Count | Should -Be 0
    }
}
