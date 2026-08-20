#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the quote-aware Mermaid line scanner (issue #491).

.DESCRIPTION
    Each Context corresponds to one false-positive rule from the feature research:
    quote-aware bracket balance, backslash as an ordinary character, comment
    stripping outside quoted spans only, directive recognition before comment
    stripping, angle brackets never structural, Unicode tolerance, statement-keyword
    classification, and pre-colon segmentation for statement labels.

    All fixtures are single-quoted string literals. The suite reads no file, starts
    no process, creates no temporary file, and mocks nothing.
#>

BeforeAll {
    $script:ScannerModulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/mermaid/MermaidLineScanner.psm1").Path
    Import-Module $script:ScannerModulePath -Force
}

Describe 'MermaidLineScanner quote-aware scanning' {

    Context 'quoted spans excluded from bracket balance' {
        It 'balances a node label whose quoted text contains brackets' {
            $scan = Get-MermaidLineScan -Line '    A["foo[bar](baz)"] --> B'
            $scan.BracketDelta.Square | Should -Be 0
            $scan.BracketDelta.Round | Should -Be 0
            $scan.BracketDelta.Curly | Should -Be 0
        }

        It 'balances a Markdown-string label held in backticks inside quotes' {
            $scan = Get-MermaidLineScan -Line '    A["`**bold [x]**`"] --> B'
            Test-MermaidLineBracketBalanced -Line $scan.Raw | Should -BeTrue
        }

        It 'masks the quoted span in the structural text with spaces' {
            $scan = Get-MermaidLineScan -Line 'A["xy"]'
            $scan.Structural | Should -Be 'A[    ]'
        }
    }

    Context 'backslash is an ordinary character' {
        It 'closes a quoted span at a quote preceded by a backslash' {
            # Mermaid has no backslash escape; the documented mechanism is #quot;.
            # Treating \" as an escape would produce a spurious unterminated quote.
            $scan = Get-MermaidLineScan -Line '    A["a\"] --> B["b"]'
            $scan.HasUnterminatedQuote | Should -BeFalse
            $scan.BracketDelta.Square | Should -Be 0
        }

        It 'treats a backslash in unquoted text as an ordinary character' {
            $scan = Get-MermaidLineScan -Line '    A[C:\temp] --> B'
            $scan.HasUnterminatedQuote | Should -BeFalse
            $scan.BracketDelta.Square | Should -Be 0
        }
    }

    Context 'comment stripping outside quoted spans only' {
        It 'preserves a percent pair that falls inside a quoted label' {
            $scan = Get-MermaidLineScan -Line '    A["50%% off"] --> B'
            $scan.IsComment | Should -BeFalse
            @(Get-MermaidArrowCandidate -Text $scan.ArrowText) | Should -Contain '-->'
        }

        It 'strips an unquoted trailing comment from the structural text' {
            $scan = Get-MermaidLineScan -Line '    A --> B %% wire A to B'
            $scan.Structural | Should -Not -Match 'wire'
            @(Get-MermaidArrowCandidate -Text $scan.ArrowText) | Should -Contain '-->'
        }

        It 'classifies a whole-line comment as a comment' {
            Get-MermaidLineClass -Line '    %% this is a note' | Should -Be 'Comment'
        }

        It 'classifies an empty line as blank' {
            Get-MermaidLineClass -Line '     ' | Should -Be 'Blank'
        }
    }

    Context 'directive recognition before comment stripping' {
        It 'classifies an init directive as a directive rather than a comment' {
            $line = '%%{init: {"theme":"dark"}}%%'
            Get-MermaidLineClass -Line $line | Should -Be 'Directive'
            Test-MermaidDirectiveLine -Line $line | Should -BeTrue
            Test-MermaidCommentLine -Line $line | Should -BeFalse
        }

        It 'excludes a directive line from the bracket balance' {
            # The braces inside a directive are configuration syntax, not diagram
            # brackets, so they must never enter the balance count.
            $scan = Get-MermaidLineScan -Line '  %%{init: {"flowchart": {"curve": "linear"}}}%%'
            $scan.BracketDelta.Curly | Should -Be 0
        }
    }

    Context 'bracket imbalance detection on a structural line' {
        It 'detects an unclosed square bracket' {
            (Get-MermaidLineScan -Line '    A[Start --> B').BracketDelta.Square | Should -Be 1
            Test-MermaidLineBracketBalanced -Line '    A[Start --> B' | Should -BeFalse
        }

        It 'detects an unclosed round bracket' {
            (Get-MermaidLineScan -Line '    A(Start --> B').BracketDelta.Round | Should -Be 1
            Test-MermaidLineBracketBalanced -Line '    A(Start --> B' | Should -BeFalse
        }

        It 'detects an unclosed curly bracket' {
            (Get-MermaidLineScan -Line '    A{Start --> B').BracketDelta.Curly | Should -Be 1
            Test-MermaidLineBracketBalanced -Line '    A{Start --> B' | Should -BeFalse
        }

        It 'reports a balanced line as balanced' {
            Test-MermaidLineBracketBalanced -Line '    A[Start] --> B(End)' | Should -BeTrue
        }

        It 'excludes ER cardinality braces from the bracket balance' {
            # `||--o{` is one arrow token; its brace is not a bracket. Counting it
            # would reject every valid ER relationship line.
            $scan = Get-MermaidLineScan -Line '    CUSTOMER ||--o{ ORDER : places'
            $scan.BracketDelta.Curly | Should -Be 0
        }

        It 'excludes class relation pipes from the bracket balance' {
            $scan = Get-MermaidLineScan -Line '    Vehicle <|-- Car'
            Test-MermaidLineBracketBalanced -Line $scan.Raw | Should -BeTrue
        }
    }

    Context 'unterminated quote detection' {
        It 'detects a quoted span left open at end of line' {
            (Get-MermaidLineScan -Line '    A["unterminated --> B').HasUnterminatedQuote | Should -BeTrue
        }

        It 'reports a closed quoted span as terminated' {
            (Get-MermaidLineScan -Line '    A["closed"] --> B').HasUnterminatedQuote | Should -BeFalse
        }
    }

    Context 'angle brackets are never structural' {
        It 'balances a label containing an HTML line break' {
            $scan = Get-MermaidLineScan -Line '    A[Node<br/>Two] --> B'
            Test-MermaidLineBracketBalanced -Line $scan.Raw | Should -BeTrue
            @(Get-MermaidArrowCandidate -Text $scan.ArrowText) | Should -Contain '-->'
        }

        It 'does not read an HTML tag as an arrow token' {
            $scan = Get-MermaidLineScan -Line '    A["<b>bold</b>"] --> B'
            @(Get-MermaidArrowCandidate -Text $scan.ArrowText) | Should -Be @('-->')
        }
    }

    Context 'Unicode content is scanned without error' {
        It 'scans a label of non-ASCII text and reports it balanced' {
            $scan = Get-MermaidLineScan -Line '    A["Ubersicht - resume - grosse"] --> B'
            $scan.HasUnterminatedQuote | Should -BeFalse
            Test-MermaidLineBracketBalanced -Line $scan.Raw | Should -BeTrue
        }

        It 'scans an unquoted label of non-ASCII text and finds the edge token' {
            $scan = Get-MermaidLineScan -Line '    Anfang --> Ende'
            @(Get-MermaidArrowCandidate -Text $scan.ArrowText) | Should -Be @('-->')
        }
    }

    Context 'statement-keyword classification' {
        It 'classifies the statement keyword <Token> as a statement line' -ForEach @(
            @{ Token = 'click'; Line = 'click A "https://example.test/a[b]" _blank' }
            @{ Token = 'style'; Line = 'style A fill:#f9f,stroke:#333,stroke-width:4px' }
            @{ Token = 'classDef'; Line = 'classDef warn fill:#fcc,stroke:#900' }
            @{ Token = 'linkStyle'; Line = 'linkStyle 0 stroke:#f66,stroke-width:2px' }
            @{ Token = 'class'; Line = 'class A,B warn' }
            @{ Token = 'accTitle'; Line = 'accTitle: A short accessible title' }
            @{ Token = 'accDescr'; Line = 'accDescr: A longer accessible description' }
            @{ Token = 'title'; Line = 'title Deployment overview' }
        ) {
            $scan = Get-MermaidLineScan -Line "    $Line"
            $scan.FirstToken | Should -Be $Token
            $scan.Class | Should -Be 'StatementKeyword'
        }

        It 'classifies a line carrying an edge token as an edge line' {
            Get-MermaidLineClass -Line '    A --> B' | Should -Be 'Edge'
        }

        It 'classifies a line with no edge token and no keyword as unclassifiable' {
            # Fail-open item 3: an unclassifiable line is skipped, never rejected.
            Get-MermaidLineClass -Line '    participant Alice' | Should -Be 'Unclassifiable'
        }
    }

    Context 'arrow candidate tokenization' {
        It 'tokenizes the flowchart edge token <Expected> from <Line>' -ForEach @(
            @{ Line = 'A --> B'; Expected = '-->' }
            @{ Line = 'A --- B'; Expected = '---' }
            @{ Line = 'A -.-> B'; Expected = '-.->' }
            @{ Line = 'A ==> B'; Expected = '==>' }
            @{ Line = 'A ~~~ B'; Expected = '~~~' }
            @{ Line = 'A --o B'; Expected = '--o' }
            @{ Line = 'A --x B'; Expected = '--x' }
            @{ Line = 'A o--o B'; Expected = 'o--o' }
            @{ Line = 'A x--x B'; Expected = 'x--x' }
            @{ Line = 'A <--> B'; Expected = '<-->' }
            @{ Line = 'Alice->>John'; Expected = '->>' }
            @{ Line = 'Alice-->>John'; Expected = '-->>' }
            @{ Line = 'Alice<<->>John'; Expected = '<<->>' }
            @{ Line = 'Alice-)John'; Expected = '-)' }
            @{ Line = 'Vehicle <|-- Car'; Expected = '<|--' }
            @{ Line = 'Car --|> Vehicle'; Expected = '--|>' }
            @{ Line = 'A ..> B'; Expected = '..>' }
            @{ Line = 'CUSTOMER ||--o{ ORDER'; Expected = '||--o{' }
            @{ Line = 'CUSTOMER }|..|{ ORDER'; Expected = '}|..|{' }
        ) {
            $scan = Get-MermaidLineScan -Line "    $Line"
            @(Get-MermaidArrowCandidate -Text $scan.ArrowText) | Should -Contain $Expected
        }

        It 'does not absorb a word-internal letter into an arrow token' {
            # The `x` of `Box` must not extend the `--` core into `ox--`.
            $scan = Get-MermaidLineScan -Line '    Box--Bar'
            @(Get-MermaidArrowCandidate -Text $scan.ArrowText) | Should -Be @('--')
        }

        It 'does not read the tilde delimiters of a class generic as arrow tokens' {
            $scan = Get-MermaidLineScan -Line '    Shape~int~ : radius'
            @(Get-MermaidArrowCandidate -Text $scan.ArrowText) | Should -HaveCount 0
        }

        It 'stops the edge-text pipe from joining the arrow token' {
            $scan = Get-MermaidLineScan -Line '    A -->|yes| C'
            @(Get-MermaidArrowCandidate -Text $scan.ArrowText) | Should -Be @('-->')
        }

        It 'tokenizes both halves of a flowchart text-form edge' {
            $scan = Get-MermaidLineScan -Line '    A -- yes --> B'
            $tokens = @(Get-MermaidArrowCandidate -Text $scan.ArrowText)
            $tokens | Should -Contain '--'
            $tokens | Should -Contain '-->'
        }

        It 'masks arrow-like text held inside a node label' {
            # A bracketed label is free text; an arrow inside it is not an edge.
            $scan = Get-MermaidLineScan -Line '    A[step 1 ->> step 2] --> B'
            @(Get-MermaidArrowCandidate -Text $scan.ArrowText) | Should -Be @('-->')
        }

        It 'returns no candidate for empty text' {
            @(Get-MermaidArrowCandidate -Text '') | Should -HaveCount 0
        }
    }

    Context 'pre-colon segmentation for statement labels' {
        It 'excludes sequence message text after the first colon' {
            $split = Split-MermaidStatementLabel -Line 'Alice->>John: does A -> B work?'
            $split.HasLabel | Should -BeTrue
            $split.Statement | Should -Be 'Alice->>John'
            $split.Label | Should -Be ' does A -> B work?'
        }

        It 'splits at the first colon only' {
            $split = Split-MermaidStatementLabel -Line 'Alice->>John: time: 10:30'
            $split.Statement | Should -Be 'Alice->>John'
        }

        It 'ignores a colon that falls inside a quoted span' {
            $split = Split-MermaidStatementLabel -Line 'state "Ready: armed" as ready'
            $split.HasLabel | Should -BeFalse
            $split.Statement | Should -Be 'state "Ready: armed" as ready'
        }

        It 'returns the whole line when there is no colon' {
            $split = Split-MermaidStatementLabel -Line '[*] --> Idle'
            $split.HasLabel | Should -BeFalse
            $split.Statement | Should -Be '[*] --> Idle'
            $split.Label | Should -Be ''
        }
    }

    Context 'masking helpers used by the validator' {
        It 'keeps bracket characters while masking label contents' {
            Get-MermaidLabelMaskedText -Text 'A[abc] --> B' | Should -Be 'A[   ] --> B'
        }

        It 'preserves a sequence async arrow whose closing paren has no opener' {
            Get-MermaidLabelMaskedText -Text 'Alice-)John' | Should -Be 'Alice-)John'
        }

        It 'blanks an arrow token so bracket counting ignores it' {
            Get-MermaidArrowMaskedText -Text 'A-->B' | Should -Be 'A   B'
        }

        It 'returns empty text unchanged from the arrow mask' {
            Get-MermaidArrowMaskedText -Text '' | Should -Be ''
        }

        It 'counts each bracket class independently' {
            $delta = Get-MermaidBracketDelta -Text '[[(({'
            $delta.Square | Should -Be 2
            $delta.Round | Should -Be 2
            $delta.Curly | Should -Be 1
        }

        It 'classifies an underscore as a word character' {
            Test-MermaidWordCharacter -Character '_' | Should -BeTrue
            Test-MermaidWordCharacter -Character 'a' | Should -BeTrue
            Test-MermaidWordCharacter -Character '-' | Should -BeFalse
        }

        It 'reports no quoted span or colon for an empty line' {
            $masked = Get-MermaidQuoteMaskedText -Line ''
            $masked.Text | Should -Be ''
            $masked.HasUnterminatedQuote | Should -BeFalse
            $masked.ColonIndex | Should -Be -1
        }

        It 'reports no directive or comment for an empty line' {
            Test-MermaidDirectiveLine -Line '' | Should -BeFalse
            Test-MermaidCommentLine -Line '' | Should -BeFalse
        }
    }
}
