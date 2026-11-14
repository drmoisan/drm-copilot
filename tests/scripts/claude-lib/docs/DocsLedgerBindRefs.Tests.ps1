#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit and command tests for .claude/lib/docs/DocsLedgerBindRefs.psm1 and the bind-page-refs operation (issue #1173 B2.4).

.DESCRIPTION
    Covers page-reference collection from front-matter surface_refs, binding a referenced element
    as documented with the union of its bindings, the unknown-id warning, no removal of a
    binding, idempotence, the single -Operation bind-page-refs command run, the exit-2 element
    target, and bind-page-refs as a batch item compared with the sequential path. Pages and the
    estate are in-memory; no file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsLedger', 'DocsLedgerRules', 'DocsParity', 'DocsEvidencePins', 'DocsLedgerCommands', 'DocsLedgerBatch', 'DocsLedgerBindRefs') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerBatch.TestSupport.psm1') -Force -ErrorAction Stop
    . (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/Invoke-DocsCommand.ps1')

    $script:Estate = New-DocsLedgerBatchTestEstate
    $script:Actor = @{ kind = 'tool'; id = 'fixture-tool' }
    $script:Unknown = 'cli-command-' + ('f' * 64)

    function New-TestPageText {
        # Returns a page whose front matter lists the given surface_refs.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string[]] $Ref)
        $list = (@($Ref | ForEach-Object { "`"$_`"" }) -join ', ')
        return "---`nowner: `"docs-team`"`nsurface_refs: [$list]`n---`n# Page`n"
    }

    function Get-TestBinding {
        # Returns '<disposition> <page>#<anchor>,...' for the ledger entry of one element.
        param([System.Collections.IDictionary] $Ledger, [string] $ElementId)
        $entry = @(@($Ledger['entries']) | Where-Object { $_['element_id'] -ceq $ElementId })
        if ($entry.Count -eq 0) { return '<none>' }
        return "$($entry[0]['disposition']) " + (@($entry[0]['page_bindings'] | ForEach-Object { "$($_['page_path'])#$($_['anchor'])" }) -join ',')
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
    Remove-Item -Path Function:\New-TestPageText, Function:\Get-TestBinding -ErrorAction SilentlyContinue
}

Describe 'Get-DocsLedgerPageReference' {
    It 'collects the referencing Markdown pages of each surface_refs id, sorted, and skips other files and pages without front matter' {
        # Arrange
        $pages = @{
            'docs/a.md'        = New-TestPageText -Ref @('id-two', 'id-one')
            'docs/b.md'        = New-TestPageText -Ref @('id-one')
            'docs/plain.md'    = "# No front matter`n"
            'docs/config.json' = '{"surface_refs": ["id-three"]}'
        }
        $read = { param($Path) $pages[[string] $Path] }.GetNewClosure()

        # Act
        $reference = Get-DocsLedgerPageReference -PagePath @('docs/b.md', 'docs/a.md', 'docs/plain.md', 'docs/config.json') -ReadText $read

        # Assert
        @($reference.Keys | Sort-Object) | Should -Be @('id-one', 'id-two')
        $reference['id-one'] | Should -Be @('docs/a.md', 'docs/b.md')
        $reference['id-two'] | Should -Be @('docs/a.md')
    }
}

Describe 'Update-DocsLedgerPageBinding and the unknown-id warning' {
    BeforeAll {
        $script:Documents = Get-DocsLedgerBatchTestDocument -File $script:Estate.Files
    }

    It 'binds a referenced element as documented with the union of its existing and referencing pages, removing no binding' {
        # Arrange
        $element = $script:Estate.Ids[0]
        $reference = @{ $element = [string[]] @($script:Estate.OtherPage, $script:Estate.Page) }

        # Act
        $ledger = Update-DocsLedgerPageBinding -Ledger $script:Documents.Ledger -View $script:Documents.View -Reference $reference -Actor $script:Actor

        # Assert
        Get-TestBinding -Ledger $ledger -ElementId $element | Should -BeExactly "documented $($script:Estate.Page)#,$($script:Estate.OtherPage)#"
        foreach ($other in $script:Estate.Ids[1..5]) { Get-TestBinding -Ledger $ledger -ElementId $other | Should -BeExactly (Get-TestBinding -Ledger $script:Documents.Ledger -ElementId $other) }
    }

    It 'turns an excluded or absent entry into a documented entry bound to the referencing page' {
        # Arrange
        $excluded = $script:Estate.Ids[1]
        $absent = $script:Estate.Ids[2]
        $ledger = Merge-DocsLedgerEntry -Ledger $script:Documents.Ledger -Entry (New-DocsLedgerEntry -Element $script:Documents.View.Element[$excluded] -Disposition 'excluded' -Rationale 'Internal.' -Actor $script:Actor)
        $ledger = Get-DocsLedgerWithoutEntry -Ledger $ledger -ElementId $absent
        $reference = @{ $excluded = [string[]] @($script:Estate.OtherPage); $absent = [string[]] @($script:Estate.OtherPage) }

        # Act
        $bound = Update-DocsLedgerPageBinding -Ledger $ledger -View $script:Documents.View -Reference $reference -Actor $script:Actor

        # Assert
        Get-TestBinding -Ledger $bound -ElementId $excluded | Should -BeExactly "documented $($script:Estate.OtherPage)#"
        Get-TestBinding -Ledger $bound -ElementId $absent | Should -BeExactly "documented $($script:Estate.OtherPage)#"
        @(@($bound['entries']) | Where-Object { $_['element_id'] -ceq $excluded })[0]['rationale'] | Should -BeNullOrEmpty
    }

    It 'keeps an anchored binding and binds only the element named by -ElementId' {
        # Arrange
        $first = $script:Estate.Ids[3]
        $second = $script:Estate.Ids[4]
        $anchored = Merge-DocsLedgerEntry -Ledger $script:Documents.Ledger -Entry (New-DocsLedgerEntry -Element $script:Documents.View.Element[$first] -Disposition 'documented' -PageBinding @(@{ page_path = $script:Estate.Page; anchor = 'usage' }) -Actor $script:Actor)
        $reference = @{ $first = [string[]] @($script:Estate.Page, $script:Estate.OtherPage); $second = [string[]] @($script:Estate.OtherPage) }

        # Act
        $bound = Update-DocsLedgerPageBinding -Ledger $anchored -View $script:Documents.View -Reference $reference -ElementId $first -Actor $script:Actor

        # Assert
        Get-TestBinding -Ledger $bound -ElementId $first | Should -BeExactly "documented $($script:Estate.Page)#usage,$($script:Estate.OtherPage)#"
        Get-TestBinding -Ledger $bound -ElementId $second | Should -BeExactly (Get-TestBinding -Ledger $anchored -ElementId $second)
    }

    It 'is idempotent: a second application returns the same bytes and an already bound element is unchanged' {
        # Arrange
        $reference = @{ $script:Estate.Ids[5] = [string[]] @($script:Estate.OtherPage); $script:Estate.Ids[0] = [string[]] @($script:Estate.Page) }

        # Act
        $once = Update-DocsLedgerPageBinding -Ledger $script:Documents.Ledger -View $script:Documents.View -Reference $reference -Actor $script:Actor
        $twice = Update-DocsLedgerPageBinding -Ledger $once -View $script:Documents.View -Reference $reference -Actor $script:Actor
        $bound = Update-DocsLedgerPageBinding -Ledger $script:Documents.Ledger -View $script:Documents.View -Reference @{ $script:Estate.Ids[0] = [string[]] @($script:Estate.Page) } -Actor $script:Actor

        # Assert
        (ConvertTo-DocsJsonText -Value $twice -Indented) | Should -BeExactly (ConvertTo-DocsJsonText -Value $once -Indented)
        (ConvertTo-DocsJsonText -Value $bound -Indented) | Should -BeExactly (ConvertTo-DocsJsonText -Value $script:Documents.Ledger -Indented)
    }

    It 'warns for a surface_refs id that is not in the snapshot and binds nothing for it' {
        # Arrange
        $reference = @{ $script:Unknown = [string[]] @($script:Estate.OtherPage) }

        # Act
        $warnings = @(Get-DocsLedgerPageReferenceWarning -Reference $reference -View $script:Documents.View)
        $ledger = Update-DocsLedgerPageBinding -Ledger $script:Documents.Ledger -View $script:Documents.View -Reference $reference -Actor $script:Actor

        # Assert
        @($warnings | ForEach-Object { "$($_['code']) $($_['severity'])" }) | Should -Be @('DOCS_LEDGER_BIND_REF_UNKNOWN warning')
        $warnings[0]['related_paths'] | Should -Be @($script:Estate.OtherPage)
        (ConvertTo-DocsJsonText -Value $ledger -Indented) | Should -BeExactly (ConvertTo-DocsJsonText -Value $script:Documents.Ledger -Indented)
    }
}

Describe 'update-ledger -Operation bind-page-refs' {
    BeforeAll {
        $script:BindFiles = [ordered]@{}
        foreach ($key in $script:Estate.Files.Keys) { $script:BindFiles[$key] = $script:Estate.Files[$key] }
        $script:BindFiles[$script:Estate.OtherPage] = New-TestPageText -Ref @($script:Estate.Ids[0], $script:Unknown)
        $script:Common = @('-ActorKind', 'tool', '-ActorId', 'fixture-tool')
    }

    It 'binds the referenced element on a single command run with -Write, warns for the unknown id, and skips every write on a second run' {
        # Arrange
        $test = New-DocsLedgerTestContext -File $script:BindFiles

        # Act
        $first = Invoke-DocsCommandCli -Command 'update-ledger' -CommandArgument (@('-Operation', 'bind-page-refs', '-Write') + $script:Common) -Context $test.Context -Json
        $second = Invoke-DocsCommandCli -Command 'update-ledger' -CommandArgument (@('-Operation', 'bind-page-refs', '-Write') + $script:Common) -Context $test.Context -Json
        $firstEnvelope = (ConvertFrom-DocsJsonText -Text $first.Stdout).Value
        $secondEnvelope = (ConvertFrom-DocsJsonText -Text $second.Stdout).Value
        $ledger = (ConvertFrom-DocsJsonText -Text ([System.Text.Encoding]::UTF8.GetString($test.Files['estate/docs-coverage-ledger.json']))).Value

        # Assert
        $first.ExitCode | Should -Be 0
        Get-TestBinding -Ledger $ledger -ElementId $script:Estate.Ids[0] | Should -BeExactly "documented $($script:Estate.Page)#,$($script:Estate.OtherPage)#"
        @($firstEnvelope['findings'] | ForEach-Object { $_['code'] }) | Should -Contain 'DOCS_LEDGER_BIND_REF_UNKNOWN'
        @($firstEnvelope['result']['writes'] | Where-Object { $_['path'] -ceq 'estate/docs-coverage-ledger.json' })[0]['status'] | Should -BeExactly 'updated'
        $second.ExitCode | Should -Be 0
        @($secondEnvelope['result']['writes'] | ForEach-Object { $_['status'] } | Sort-Object -Unique) | Should -Be @('skipped')
    }

    It 'exits 2 when an element target is supplied with bind-page-refs' {
        # Act
        $outcome = Invoke-DocsCommandCli -Command 'update-ledger' -CommandArgument (@('-Operation', 'bind-page-refs', '-Element', $script:Estate.Ids[0]) + $script:Common) -Context (New-DocsLedgerTestContext -File $script:BindFiles).Context -Json

        # Assert
        $outcome.ExitCode | Should -Be 2
        @((ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value['findings'] | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_CLI_ARGUMENTS')
    }
}

Describe 'bind-page-refs as a batch item (D-2)' {
    It 'expands into per-element binds in input order and equals the sequential path' {
        # Arrange
        $documents = Get-DocsLedgerBatchTestDocument -File $script:Estate.Files
        $documents['PageReference'] = @{ $script:Estate.Ids[0] = [string[]] @($script:Estate.OtherPage); $script:Estate.Ids[2] = [string[]] @($script:Estate.OtherPage) }
        $items = @(
            (New-DocsLedgerBatchTestItem -Index 0 -Argument ([ordered]@{ Operation = 'set-disposition'; Element = $script:Estate.Ids[0]; Disposition = 'excluded'; Rationale = 'Internal.' }))
            (New-DocsLedgerBatchTestItem -Index 1 -Argument ([ordered]@{ Operation = 'bind-page-refs' }))
            (New-DocsLedgerBatchTestItem -Index 2 -Argument ([ordered]@{ Operation = 'pin'; Element = $script:Estate.Ids[2]; Page = [string[]] @($script:Estate.OtherPage) }))
        )
        $sequential = Invoke-DocsLedgerBatchTestSequential -Document $documents -Item $items -IssuedAt $script:Estate.IssuedAt

        # Act
        $batch = Invoke-DocsLedgerBatch -Item $items -LoadDocument { $documents }.GetNewClosure() -ApplyOperation (Get-DocsLedgerBatchTestApply) -CompareRule { param($Documents, $After) [void] $Documents; [void] $After; @{ NewErrors = @() } } -IssuedAt $script:Estate.IssuedAt

        # Assert
        @($batch.Finding).Count | Should -Be 0
        ConvertTo-DocsLedgerBatchTestText -Result $batch.After | Should -BeExactly (ConvertTo-DocsLedgerBatchTestText -Result $sequential)
        Get-TestBinding -Ledger $batch.After.Ledger -ElementId $script:Estate.Ids[0] | Should -BeExactly "documented $($script:Estate.OtherPage)#"
    }
}
