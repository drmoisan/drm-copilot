#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsLedgerBatch.psm1 (issue #1173 B2, B3).

.DESCRIPTION
    Covers the operations document: the MCP field-name mapping, each rejection of B2.1 with its
    /operations/<i> pointer, the claim rule of B3 and the batch-level -Operations option checks.
    Item validation runs through the real Test-DocsUpdateLedgerArgument, or through a recording
    stub where only the mapping is checked. Every document is an in-memory string; no file is
    read or written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsLedgerCommands', 'DocsLedgerBatch') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    $script:Element = 'cli-command-' + ('a' * 64)
    $script:Validate = ${function:Test-DocsUpdateLedgerArgument}

    function ConvertFrom-TestOperation {
        # Parses an operations array (given as PowerShell values) with the real validator and the batch actor.
        param([object[]] $Operation, [scriptblock] $Validate = $script:Validate)
        $text = ConvertTo-DocsJsonText -Value ([ordered]@{ operations = $Operation })
        ConvertFrom-DocsLedgerOperationText -Text $text -ActorKind 'tool' -ActorId 'fixture-tool' -ProfilePath 'estate/docs-profile.json' -ValidateArgument $Validate
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
    Remove-Item -Path Function:\ConvertFrom-TestOperation -ErrorAction SilentlyContinue
}

Describe 'ConvertFrom-DocsLedgerOperationText (B2.1)' {
    It 'maps every MCP field name to its update-ledger argument name and adds the batch actor and profile' {
        # Arrange (a recording stub accepts every map, so the mapping alone is checked)
        $seen = [System.Collections.Generic.List[object]]::new()
        $stub = { param($Argument) $seen.Add($Argument); $null }.GetNewClosure()
        $item = [ordered]@{ operation = 'set-dimension'; element = $script:Element; limit = 'diagnostic-x'; disposition = 'documented'; pages = @('docs/a.md'); rationale = 'r'; owner = 'docs-team'; target = 't'; dimension = 'accurate'; state = 'pass'; claim = 'The page states the flag.' }

        # Act
        $result = ConvertFrom-TestOperation -Operation @($item) -Validate $stub

        # Assert
        $result.Finding | Should -BeNullOrEmpty
        $argument = $result.Item[0].Argument
        [string[]] $keys = @($argument.Keys)
        [Array]::Sort($keys, [System.StringComparer]::Ordinal)
        $keys | Should -Be @('ActorId', 'ActorKind', 'Dimension', 'Disposition', 'Element', 'Limit', 'Operation', 'Owner', 'Page', 'Profile', 'Rationale', 'State', 'Target')
        $argument['Page'] | Should -Be @('docs/a.md')
        $argument['Profile'] | Should -BeExactly 'estate/docs-profile.json'
        $result.Item[0].Claim | Should -BeExactly 'The page states the flag.'
        $result.Item[0].Index | Should -Be 0
        $seen.Count | Should -Be 1
    }

    It 'accepts valid items in input order with the real validator' {
        # Act
        $result = ConvertFrom-TestOperation -Operation @(
            [ordered]@{ operation = 'set-disposition'; element = $script:Element; disposition = 'documented'; pages = @('docs/a.md') }
            [ordered]@{ operation = 'pin'; element = $script:Element; pages = @('docs/a.md') }
        )

        # Assert
        $result.Finding | Should -BeNullOrEmpty
        @($result.Item | ForEach-Object { "$($_.Index) $($_.Argument['Operation'])" }) | Should -Be @('0 set-disposition', '1 pin')
    }

    It 'rejects <Case> with one DOCS_CLI_ARGUMENTS finding at <Pointer>' -ForEach @(
        @{ Case = 'text that is not JSON'; Text = '{"operations": ['; Pointer = '' }
        @{ Case = 'a root without an operations array'; Text = '{"items": []}'; Pointer = '/operations' }
        @{ Case = 'an operations value that is not an array'; Text = '{"operations": {}}'; Pointer = '/operations' }
        @{ Case = 'an empty operations array'; Text = '{"operations": []}'; Pointer = '/operations' }
        @{ Case = 'an item that is not an object'; Text = '{"operations": [{"operation": "remove-entry", "element": "ELEMENT"}, 7]}'; Pointer = '/operations/1' }
        @{ Case = 'an unknown key'; Text = '{"operations": [{"operation": "remove-entry", "element": "ELEMENT", "actor_id": "x"}]}'; Pointer = '/operations/0' }
        @{ Case = 'a key in another letter case'; Text = '{"operations": [{"operation": "remove-entry", "Element": "ELEMENT"}]}'; Pointer = '/operations/0' }
        @{ Case = 'a sync-refs item'; Text = '{"operations": [{"operation": "remove-entry", "element": "ELEMENT"}, {"operation": "sync-refs"}]}'; Pointer = '/operations/1' }
        @{ Case = 'an item the validator rejects'; Text = '{"operations": [{"operation": "set-dimension", "element": "ELEMENT", "pages": ["docs/a.md"], "state": "pass"}]}'; Pointer = '/operations/0' }
        @{ Case = 'a pages value that is not a string array'; Text = '{"operations": [{"operation": "pin", "element": "ELEMENT", "pages": "docs/a.md"}]}'; Pointer = '/operations/0' }
        @{ Case = 'a non-string field'; Text = '{"operations": [{"operation": "remove-entry", "element": 5}]}'; Pointer = '/operations/0' }
    ) {
        # Act
        $result = ConvertFrom-DocsLedgerOperationText -Text $Text.Replace('ELEMENT', $script:Element) -ActorKind 'tool' -ActorId 'fixture-tool' -ValidateArgument $script:Validate

        # Assert
        @($result.Item).Count | Should -Be 0
        $result.Finding['code'] | Should -BeExactly 'DOCS_CLI_ARGUMENTS'
        $result.Finding['severity'] | Should -BeExactly 'error'
        $result.Finding['pointer'] | Should -BeExactly $Pointer
    }

    It 'names the item index and the validator message for a rejected item' {
        # Act
        $result = ConvertFrom-TestOperation -Operation @(
            [ordered]@{ operation = 'remove-entry'; element = $script:Element }
            [ordered]@{ operation = 'set-dimension'; element = $script:Element; pages = @('docs/a.md'); state = 'pass' }
        )

        # Assert
        $result.Finding['message'] | Should -BeLike 'Operations item 1: *requires -Dimension*'
    }
}

Describe 'claim rule (B3)' {
    It 'accepts a claim on set-dimension accurate pass and validates the item without it' {
        # Act
        $result = ConvertFrom-TestOperation -Operation @([ordered]@{ operation = 'set-dimension'; element = $script:Element; pages = @('docs/a.md'); dimension = 'accurate'; state = 'pass'; claim = 'The page states the flag.' })

        # Assert
        $result.Finding | Should -BeNullOrEmpty
        $result.Item[0].Claim | Should -BeExactly 'The page states the flag.'
        $result.Item[0].Argument.Contains('Claim') | Should -BeFalse
    }

    It 'rejects a claim on <Case> with the item index' -ForEach @(
        @{ Case = 'a pin item'; Item = [ordered]@{ operation = 'pin'; pages = @('docs/a.md'); claim = 'c' } }
        @{ Case = 'set-dimension accurate fail'; Item = [ordered]@{ operation = 'set-dimension'; pages = @('docs/a.md'); dimension = 'accurate'; state = 'fail'; claim = 'c' } }
        @{ Case = 'set-dimension exists pass'; Item = [ordered]@{ operation = 'set-dimension'; pages = @('docs/a.md'); dimension = 'exists'; state = 'pass'; claim = 'c' } }
        @{ Case = 'a blank claim'; Item = [ordered]@{ operation = 'set-dimension'; pages = @('docs/a.md'); dimension = 'accurate'; state = 'pass'; claim = '  ' } }
    ) {
        # Arrange
        $Item['element'] = $script:Element

        # Act
        $result = ConvertFrom-TestOperation -Operation @([ordered]@{ operation = 'remove-entry'; element = $script:Element }, $Item)

        # Assert
        $result.Finding['pointer'] | Should -BeExactly '/operations/1'
        $result.Finding['message'] | Should -BeLike '*claim*'
    }
}

Describe 'Test-DocsLedgerBatchArgument' {
    It 'returns null for a relative path or - with the batch options only' {
        Test-DocsLedgerBatchArgument -Argument @{ Operations = '-'; ActorKind = 'tool'; ActorId = 'x'; Write = $true } | Should -BeNullOrEmpty
        Test-DocsLedgerBatchArgument -Argument @{ Operations = 'docs/ops.json'; Profile = 'p.json' } | Should -BeNullOrEmpty
    }

    It 'rejects <Case>' -ForEach @(
        @{ Case = 'a non-relative path'; Argument = @{ Operations = '/abs/ops.json' }; Fragment = 'not' }
        @{ Case = '-Operation together with -Operations'; Argument = @{ Operations = '-'; Operation = 'pin' }; Fragment = '-Operation and -Operations' }
        @{ Case = 'a per-operation option'; Argument = @{ Operations = '-'; Element = 'x' }; Fragment = '-Element' }
    ) {
        $finding = Test-DocsLedgerBatchArgument -Argument $Argument
        $finding['code'] | Should -BeExactly 'DOCS_CLI_ARGUMENTS'
        $finding['message'] | Should -BeLike "*$Fragment*"
    }
}

Describe 'Invoke-DocsLedgerBatch (B2.2, B3)' {
    BeforeAll {
        foreach ($name in 'DocsLedger', 'DocsLedgerRules', 'DocsParity', 'DocsEvidencePins') {
            Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -ErrorAction Stop
        }
        Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop
        Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerBatch.TestSupport.psm1') -Force -ErrorAction Stop
        $script:Estate = New-DocsLedgerBatchTestEstate
        $script:Apply = Get-DocsLedgerBatchTestApply
        $script:NoError = { param($Documents, $After) [void] $Documents; [void] $After; @{ NewErrors = @() } }
        # A rule comparison over the matrix rules only: the errors present after the batch and absent before it.
        $script:MatrixCompare = {
            param($Documents, $After)
            $key = { param($Finding) "$($Finding['code'])|$(@($Finding['related_ids']) -join ',')|$(@($Finding['related_paths']) -join ',')" }
            # Get-DocsMatrixFinding returns its array with a comma, so each result is assigned before it is filtered.
            $beforeFound = Get-DocsMatrixFinding -Matrix $Documents.Matrix -Ledger $Documents.Ledger -PinSet $Documents.PinSet -PagePath $Documents.PagePath -PageOwner @() -LedgerSha256 ('0' * 64) -ArtifactPath 'm'
            $afterFound = Get-DocsMatrixFinding -Matrix $After.Matrix -Ledger $After.Ledger -PinSet $After.PinSet -PagePath $Documents.PagePath -PageOwner @() -LedgerSha256 ('0' * 64) -ArtifactPath 'm'
            $before = @($beforeFound | Where-Object { $_['severity'] -ceq 'error' } | ForEach-Object { & $key $_ })
            $afterErrors = @($afterFound | Where-Object { $_['severity'] -ceq 'error' })
            @{ NewErrors = @($afterErrors | Where-Object { $before -cnotcontains (& $key $_) }) }
        }

        function Invoke-TestBatch {
            # Runs the batch over freshly loaded documents with counting loader and comparison wrappers.
            param([object[]] $Item, [scriptblock] $Compare = $script:NoError)
            $counter = @{ Load = 0; Compare = 0 }
            $documents = Get-DocsLedgerBatchTestDocument -File $script:Estate.Files
            $load = { $counter.Load++; $documents }.GetNewClosure()
            $inner = $Compare
            $comparison = { param($Documents, $After) $counter.Compare++; & $inner $Documents $After }.GetNewClosure()
            $result = Invoke-DocsLedgerBatch -Item $Item -LoadDocument $load -ApplyOperation $script:Apply -CompareRule $comparison -IssuedAt $script:Estate.IssuedAt
            @{ Result = $result; Counter = $counter; Documents = $documents }
        }
    }

    AfterAll {
        Remove-Item -Path Function:\Invoke-TestBatch -ErrorAction SilentlyContinue
    }

    It 'writes the same ledger, matrix and pin bytes as sequential single-operation application of the sample' {
        # Arrange
        $items = New-DocsLedgerBatchTestSample -Estate $script:Estate
        $sequential = Invoke-DocsLedgerBatchTestSequential -Document (Get-DocsLedgerBatchTestDocument -File $script:Estate.Files) -Item $items -IssuedAt $script:Estate.IssuedAt

        # Act
        $run = Invoke-TestBatch -Item $items

        # Assert
        $sequential.Finding | Should -BeNullOrEmpty
        @($run.Result.Finding).Count | Should -Be 0
        ConvertTo-DocsLedgerBatchTestText -Result $run.Result.After | Should -BeExactly (ConvertTo-DocsLedgerBatchTestText -Result $sequential)
        @(@($run.Result.After.Ledger['entries']) | ForEach-Object { $_['element_id'] }) | Should -Not -Contain $script:Estate.Ids[3]
    }

    It 'invokes the loader and the rule comparison exactly once for a batch of several items' {
        # Act
        $run = Invoke-TestBatch -Item (New-DocsLedgerBatchTestSample -Estate $script:Estate)

        # Assert
        $run.Counter.Load | Should -Be 1
        $run.Counter.Compare | Should -Be 1
    }

    It 'keeps an unchanged document as loaded' {
        # Act
        $run = Invoke-TestBatch -Item @(New-DocsLedgerBatchTestItem -Index 0 -Argument ([ordered]@{ Operation = 'set-dimension'; Element = $script:Estate.Ids[5]; Page = [string[]] @($script:Estate.Page); Dimension = 'exists'; State = 'fail'; Rationale = 'Missing.' }))

        # Assert
        [object]::ReferenceEquals($run.Result.After.Ledger, $run.Documents.Ledger) | Should -BeTrue
        [object]::ReferenceEquals($run.Result.After.PinSet, $run.Documents.PinSet) | Should -BeTrue
        [object]::ReferenceEquals($run.Result.After.Matrix, $run.Documents.Matrix) | Should -BeFalse
    }

    It 'rejects the whole batch with the item index for a DOCS_UPDATE_TARGET_INVALID item' {
        # Arrange (item 2 unpins a page the element has no pin on)
        $items = @(
            (New-DocsLedgerBatchTestItem -Index 0 -Argument ([ordered]@{ Operation = 'remove-entry'; Element = $script:Estate.Ids[3] }))
            (New-DocsLedgerBatchTestItem -Index 1 -Argument ([ordered]@{ Operation = 'pin'; Element = $script:Estate.Ids[4]; Page = [string[]] @($script:Estate.Page) }))
            (New-DocsLedgerBatchTestItem -Index 2 -Argument ([ordered]@{ Operation = 'unpin'; Element = $script:Estate.Ids[1]; Page = [string[]] @($script:Estate.OtherPage) }))
        )

        # Act
        $run = Invoke-TestBatch -Item $items

        # Assert
        $run.Result.After | Should -BeNullOrEmpty
        @($run.Result.Finding).Count | Should -Be 1
        $run.Result.Finding[0]['code'] | Should -BeExactly 'DOCS_UPDATE_TARGET_INVALID'
        $run.Result.Finding[0]['message'] | Should -BeLike 'Operations item 2: *'
        $run.Counter.Compare | Should -Be 0
    }

    It 'rejects the whole batch with the item index for an introduced error' {
        # Arrange (a comparison stub reports one error related to the element of item 1)
        # The finding is built here: a GetNewClosure scriptblock cannot see a module imported into the PoshQC session state.
        $element = $script:Estate.Ids[4]
        $sample = New-DocsFinding -Code 'DOCS_SAMPLE_ERROR' -Severity 'error' -Message 'sample' -NextAction 'fix' -RelatedId @($element)
        $compare = { param($Documents, $After) [void] $Documents; [void] $After; @{ NewErrors = @($sample) } }.GetNewClosure()
        $items = @(
            (New-DocsLedgerBatchTestItem -Index 0 -Argument ([ordered]@{ Operation = 'remove-entry'; Element = $script:Estate.Ids[3] }))
            (New-DocsLedgerBatchTestItem -Index 1 -Argument ([ordered]@{ Operation = 'pin'; Element = $element; Page = [string[]] @($script:Estate.Page) }))
        )

        # Act
        $run = Invoke-TestBatch -Item $items -Compare $compare

        # Assert
        $run.Result.After | Should -BeNullOrEmpty
        @($run.Result.Finding | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_SAMPLE_ERROR')
        $run.Result.Finding[0]['message'] | Should -BeLike 'Operations item 1: *'
    }

    It 'applies an accurate-pass claim as a pin first, with no DOCS_MATRIX_ACCURACY_UNPINNED (B3)' {
        # Arrange
        $element = $script:Estate.Ids[2]
        $items = @(
            (New-DocsLedgerBatchTestItem -Index 0 -Argument ([ordered]@{ Operation = 'set-disposition'; Element = $element; Disposition = 'documented'; Page = [string[]] @($script:Estate.Page, $script:Estate.OtherPage) }))
            (New-DocsLedgerBatchTestItem -Index 1 -Argument ([ordered]@{ Operation = 'set-dimension'; Element = $element; Page = [string[]] @($script:Estate.OtherPage); Dimension = 'accurate'; State = 'pass' }) -Claim 'The page states the behavior.')
        )

        # Act
        $run = Invoke-TestBatch -Item $items -Compare $script:MatrixCompare

        # Assert
        @($run.Result.Finding).Count | Should -Be 0
        $pins = @(@($run.Result.After.PinSet['pins']) | Where-Object { $_['element_id'] -ceq $element -and $_['page_path'] -ceq $script:Estate.OtherPage })
        $pins.Count | Should -Be 1
        $pins[0]['claim'] | Should -BeExactly 'The page states the behavior.'
    }

    It 'rejects an accurate-pass item without a claim or prior pin with DOCS_MATRIX_ACCURACY_UNPINNED and the item index (B3)' {
        # Arrange
        $element = $script:Estate.Ids[2]
        $items = @(
            (New-DocsLedgerBatchTestItem -Index 0 -Argument ([ordered]@{ Operation = 'set-disposition'; Element = $element; Disposition = 'documented'; Page = [string[]] @($script:Estate.Page, $script:Estate.OtherPage) }))
            (New-DocsLedgerBatchTestItem -Index 1 -Argument ([ordered]@{ Operation = 'set-dimension'; Element = $element; Page = [string[]] @($script:Estate.OtherPage); Dimension = 'accurate'; State = 'pass' }))
        )

        # Act
        $run = Invoke-TestBatch -Item $items -Compare $script:MatrixCompare

        # Assert
        $run.Result.After | Should -BeNullOrEmpty
        @($run.Result.Finding | ForEach-Object { $_['code'] }) | Should -Contain 'DOCS_MATRIX_ACCURACY_UNPINNED'
        @($run.Result.Finding | Where-Object { $_['code'] -ceq 'DOCS_MATRIX_ACCURACY_UNPINNED' })[0]['message'] | Should -BeLike 'Operations item 1: *'
    }

    It 'returns the loader result without applying any item when the documents do not load' {
        # Arrange
        $failed = @{ Result = [pscustomobject]@{ ExitCode = 1 } }
        $applied = @{ Count = 0 }
        $apply = { param($Argument, $Documents, $IssuedAt) [void] $Argument; [void] $Documents; [void] $IssuedAt; $applied.Count++ }.GetNewClosure()

        # Act
        $result = Invoke-DocsLedgerBatch -Item (New-DocsLedgerBatchTestSample -Estate $script:Estate) -LoadDocument { $failed }.GetNewClosure() -ApplyOperation $apply -CompareRule $script:NoError -IssuedAt $script:Estate.IssuedAt

        # Assert
        [object]::ReferenceEquals($result.Documents, $failed) | Should -BeTrue
        $result.After | Should -BeNullOrEmpty
        $applied.Count | Should -Be 0
    }
}

Describe 'module wiring of the batch path (D-1)' {
    It 'imports DocsLedgerBatch.psm1 and DocsLedgerBindRefs.psm1 from DocsLedgerCommands.psm1, and DocsLedgerCommands.psm1 from neither' {
        # Arrange (the module texts are parsed read-only; a global test import cannot mask a missing module import)
        $childOf = {
            param([string] $Name)
            $text = [System.IO.File]::ReadAllText((Join-Path -Path $script:LibraryRoot -ChildPath "docs/$Name"))
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($text, [ref] $null, [ref] $null)
            @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and [string] $node.GetCommandName() -eq 'Import-Module' }, $true) | ForEach-Object { [regex]::Match($_.Extent.Text, "-ChildPath '(?<child>[^']+)'").Groups['child'].Value })
        }

        # Act
        $commands = & $childOf 'DocsLedgerCommands.psm1'
        $batch = & $childOf 'DocsLedgerBatch.psm1'
        $bind = & $childOf 'DocsLedgerBindRefs.psm1'

        # Assert
        $commands | Should -Contain 'DocsLedgerBatch.psm1'
        $commands | Should -Contain 'DocsLedgerBindRefs.psm1'
        $batch | Should -Not -Contain 'DocsLedgerCommands.psm1'
        $bind | Should -Not -Contain 'DocsLedgerCommands.psm1'
    }
}

Describe 'update-ledger -Operations (B2.3)' {
    BeforeAll {
        . (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/Invoke-DocsCommand.ps1')
        $script:Common = @('-ActorKind', 'tool', '-ActorId', 'fixture-tool')
        $script:Artifacts = @('estate/docs-coverage-ledger.json', 'estate/docs-evidence-pins.json', 'estate/docs-parity-matrix.json', 'estate/surface-inventory-snapshot.json')
        $script:Operations = ConvertTo-DocsJsonText -Value ([ordered]@{ operations = @(
                    [ordered]@{ operation = 'set-disposition'; element = $script:Estate.Ids[0]; disposition = 'excluded'; rationale = 'Internal helper.' }
                    [ordered]@{ operation = 'set-dimension'; element = $script:Estate.Ids[1]; pages = @($script:Estate.Page); dimension = 'exists'; state = 'fail'; rationale = 'Missing.' }
                ) })

        function New-TestCommandContext {
            # Returns the recording ledger context over the estate, with the operations document at estate/ops.json and as in-memory standard input.
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
            param([string] $Operations = $script:Operations)
            $files = [ordered]@{}
            foreach ($key in $script:Estate.Files.Keys) { $files[$key] = $script:Estate.Files[$key] }
            $files['estate/ops.json'] = $Operations
            $test = New-DocsLedgerTestContext -File $files
            $stdin = $Operations
            $test.Context | Add-Member -NotePropertyName 'ReadStdin' -NotePropertyValue ({ $stdin }.GetNewClosure())
            return $test
        }

        function Invoke-TestBatchCli {
            param([string[]] $Argument, [hashtable] $Test)
            $outcome = Invoke-DocsCommandCli -Command 'update-ledger' -CommandArgument ($Argument + $script:Common) -Context $Test.Context -Json
            @{ Outcome = $outcome; Envelope = (ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value }
        }
    }

    AfterAll {
        Remove-Item -Path Function:\New-TestCommandContext, Function:\Invoke-TestBatchCli -ErrorAction SilentlyContinue
    }

    It 'applies the operations document read from a path and from standard input with the same result' {
        # Act
        $fromPath = Invoke-TestBatchCli -Argument @('-Operations', 'estate/ops.json') -Test (New-TestCommandContext)
        $fromStdin = Invoke-TestBatchCli -Argument @('-Operations', '-') -Test (New-TestCommandContext)

        # Assert
        $fromPath.Outcome.ExitCode | Should -Be 0
        $fromStdin.Outcome.ExitCode | Should -Be 0
        @($fromPath.Envelope['result']['writes'] | ForEach-Object { "$($_['path']) $($_['status']) $($_['sha256'])" }) | Should -Be @($fromStdin.Envelope['result']['writes'] | ForEach-Object { "$($_['path']) $($_['status']) $($_['sha256'])" })
        @($fromPath.Envelope['result']['writes'] | Where-Object { $_['status'] -ceq 'planned' }).Count | Should -BeGreaterThan 0
    }

    It 'exits 2 with one DOCS_CLI_ARGUMENTS finding for <Case>' -ForEach @(
        @{ Case = 'a non-relative -Operations path'; Argument = @('-Operations', '/abs/ops.json') }
        @{ Case = '-Operation with -Operations'; Argument = @('-Operations', '-', '-Operation', 'sync-refs') }
        @{ Case = 'a per-operation option with -Operations'; Argument = @('-Operations', '-', '-Disposition', 'documented') }
        @{ Case = 'an empty operations array'; Argument = @('-Operations', 'estate/ops.json'); Document = '{"operations": []}' }
    ) {
        # Arrange
        $test = if ($_.ContainsKey('Document')) { New-TestCommandContext -Operations $_['Document'] } else { New-TestCommandContext }

        # Act
        $run = Invoke-TestBatchCli -Argument $Argument -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 2
        @($run.Envelope['findings'] | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_CLI_ARGUMENTS')
        @($test.CallLog | Where-Object { $_.Member -ceq 'WriteText' }).Count | Should -Be 0
    }

    It 'reads each estate artifact once on a dry run of several items' {
        # Arrange
        $test = New-TestCommandContext

        # Act
        $run = Invoke-TestBatchCli -Argument @('-Operations', 'estate/ops.json') -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        foreach ($path in $script:Artifacts) { @($test.CallLog | Where-Object { $_.Member -ceq 'ReadBytes' -and $_.RelativePath -ceq $path }).Count | Should -Be 1 -Because $path }
    }

    It 'makes one WriteText call per changed artifact with -Write' {
        # Arrange
        $test = New-TestCommandContext

        # Act
        $run = Invoke-TestBatchCli -Argument @('-Operations', '-', '-Write') -Test $test
        $updated = @($run.Envelope['result']['writes'] | Where-Object { $_['status'] -ceq 'updated' } | ForEach-Object { [string] $_['path'] })

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $updated.Count | Should -BeGreaterThan 0
        @($test.CallLog | Where-Object { $_.Member -ceq 'WriteText' } | ForEach-Object { $_.RelativePath }) | Should -Be $updated
    }

    It 'writes nothing and exits 1 with the item index when an item is rejected' {
        # Arrange (item 1 unpins a page that the element has no pin on)
        $operations = ConvertTo-DocsJsonText -Value ([ordered]@{ operations = @(
                    [ordered]@{ operation = 'remove-entry'; element = $script:Estate.Ids[3] }
                    [ordered]@{ operation = 'unpin'; element = $script:Estate.Ids[1]; pages = @($script:Estate.OtherPage) }
                ) })
        $test = New-TestCommandContext -Operations $operations

        # Act
        $run = Invoke-TestBatchCli -Argument @('-Operations', '-', '-Write') -Test $test

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        $run.Envelope['findings'][0]['message'] | Should -BeLike 'Operations item 1: *'
        @($test.CallLog | Where-Object { $_.Member -ceq 'WriteText' }).Count | Should -Be 0
    }
}
