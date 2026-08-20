#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    False-positive accept matrix for the structural Mermaid validator (issue #491).

.DESCRIPTION
    One accept-case per construct that naive validators reject wrongly, taken row
    by row from the feature research false-positive analysis. Blocking a valid
    diagram is worse than missing an invalid one, so each construct here is a
    first-class deliverable rather than an incidental case.

    Every case asserts the verdict is `Valid` or `NotJudged` and that no finding
    was raised. A construct that starts producing a finding is a regression in
    false-positive safety even if the verdict word happens to change.

    All fixtures are here-strings; the suite reads no file, starts no process,
    creates no temporary file, and mocks nothing.
#>

BeforeAll {
    $script:ValidationModulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/mermaid/MermaidValidation.psm1").Path
    Import-Module $script:ValidationModulePath -Force

    function Assert-MermaidAccepted {
        <#
        .SYNOPSIS
            Fails the calling test unless the diagram is accepted with no finding.
        #>
        param([Parameter(Mandatory)][string] $Diagram)

        $result = Test-MermaidDiagram -Content $Diagram
        $reported = @($result.Findings | ForEach-Object { "$($_.Class) at line $($_.Line)" }) -join '; '
        $result.Verdict | Should -Not -Be 'Invalid' -Because "the construct must be accepted, but it reported: $reported"
        $result.Verdict | Should -BeIn @('Valid', 'NotJudged')
        $result.Findings | Should -HaveCount 0 -Because "an accepted construct must raise no finding, but it reported: $reported"
    }
}

Describe 'MermaidValidation accept matrix' {

    Context 'quoted-label constructs' {
        It 'accepts structural brackets inside a quoted node label' {
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    A["foo[bar](baz)"] --> B
'@
        }

        It 'accepts quote entities and a trailing backslash before the closing quote' {
            # Mermaid has no backslash escape: the `"` after the backslash closes
            # the span. A validator that treated `\"` as an escape would see an
            # unterminated quote here and reject a valid diagram.
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    A["He said #quot;stop#quot; loudly"] --> B
    B["ends with a backslash \"] --> C
'@
        }

        It 'accepts numeric and named HTML entities in a label' {
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    A["Item #35;1 &amp; more"] --> B
'@
        }

        It 'accepts a Markdown string label delimited by backticks' {
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    A["`**bold** label`"] --> B
'@
        }

        It 'accepts non-ASCII label text' {
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    A["Ünicode — 日本語 ✓"] --> B["Ω"]
'@
        }

        It 'accepts a percent sequence inside a quoted span' {
            # `%%` starts a comment outside quotes only; inside a label it is content.
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    A["50%% off"] --> B["100% done"]
'@
        }

        It 'accepts a line-break tag and inline HTML in a label' {
            # Angle brackets are never structural: arrows contain `>` themselves.
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    A["Line one<br/>Line two <b>bold</b>"] --> B
'@
        }

        It 'accepts backslashes as ordinary characters in a path label' {
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    A["C:\path\to\file"] --> B
'@
        }
    }

    Context 'block and statement constructs' {
        It 'accepts a subgraph block with a direction statement and a free-text title' {
            Assert-MermaidAccepted -Diagram @'
flowchart LR
    subgraph one [Phase 1 (setup): step-by-step]
        direction TB
        A --> B
    end
    B --> C
'@
        }

        It 'accepts a click statement carrying a URL with query parameters' {
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    A --> B
    click A "https://example.com/a?x=1&y=2" "Open A"
'@
        }

        It 'accepts a style statement carrying CSS declarations' {
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    A --> B
    style A fill:#f9f,stroke:#333,stroke-width:4px
'@
        }

        It 'accepts a classDef statement carrying a dash-array property' {
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    A --> B
    classDef important fill:#f96,stroke-dasharray: 5 5
'@
        }

        It 'accepts a linkStyle statement carrying a colour list' {
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    A --> B
    linkStyle 0 stroke:#ff3,stroke-width:4px,color:red
'@
        }

        It 'accepts a class statement naming several nodes' {
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    A --> B
    class A,B important
'@
        }

        It 'accepts an accTitle statement carrying free text with an arrow' {
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    accTitle: A flow of A -> B (draft)
    A --> B
'@
        }

        It 'accepts an accDescr statement carrying free text with brackets' {
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    accDescr: Describes A -> B [step 1] {x}
    A --> B
'@
        }

        It 'accepts a title statement carrying free text with an arrow' {
            Assert-MermaidAccepted -Diagram @'
flowchart TD
    title A -> B (draft) [v1]
    A --> B
'@
        }
    }

    Context 'free-text constructs' {
        It 'accepts sequence message text after the first colon' {
            # Everything after the first colon is free text and may contain dashes,
            # angle brackets, and brackets.
            Assert-MermaidAccepted -Diagram @'
sequenceDiagram
    Alice->>Bob: 3 - 2 > 1 [check] (yes) -- always
    Bob-->>Alice: ok --> done
'@
        }

        It 'accepts an unbalanced-looking task line in a free-text diagram type' {
            # A gantt task named 'Deploy (phase 1' is ugly but the parser tolerates
            # it, so brackets are not structural for a free-text type.
            Assert-MermaidAccepted -Diagram @'
gantt
    dateFormat YYYY-MM-DD
    section Rollout
    Deploy (phase 1 :a1, 2026-01-01, 3d
'@
        }
    }

    Context 'documented grammar variants' {
        It 'accepts class-diagram generics written with tilde runs' {
            Assert-MermaidAccepted -Diagram @'
classDiagram
    class List~T~ {
        +add(T item)
    }
    List~T~ <|-- Stack~T~
'@
        }

        It 'accepts ER cardinality expressed with the documented word aliases' {
            Assert-MermaidAccepted -Diagram @'
erDiagram
    CUSTOMER one to zero or more ORDER : places
'@
        }

        It 'accepts a flowchart edge carrying a mid-arrow text form' {
            Assert-MermaidAccepted -Diagram @'
flowchart LR
    A -- yes --> B
    B == weighted ==> C
    C -. dotted .-> D
'@
        }
    }
}
