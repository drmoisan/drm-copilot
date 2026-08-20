#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the structural Mermaid validator (issue #491).

.DESCRIPTION
    Covers the defect classes the gate is contracted to reject — missing or
    non-keyword first line, misspelled keyword, malformed frontmatter, empty body,
    unbalanced brackets, unterminated quotes, per-type invalid arrow tokens, and
    `subgraph`/`end` imbalance — and the fail-open items that must allow instead.
    Finding assertions check the line number as well as the class, because a deny
    reason that cannot name the line is not actionable. All fixtures are
    here-strings; the suite reads no file except the module under test, starts no
    process, creates no temporary file, and mocks nothing.
#>

BeforeAll {
    # Resolve the module four levels up: mermaid -> claude-lib -> scripts -> tests
    # -> repo root, then into .claude/lib/mermaid.
    $script:ValidationModulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/mermaid/MermaidValidation.psm1").Path
    Import-Module $script:ValidationModulePath -Force

    function Get-FindingClass {
        param($Result)
        return @($Result.Findings | ForEach-Object { $_.Class })
    }

    function Get-FindingLine {
        param($Result, [string] $Class)
        return @($Result.Findings | Where-Object { $_.Class -eq $Class } | ForEach-Object { $_.Line })
    }
}

Describe 'Test-MermaidDiagram structural verdicts' {

    Context 'accepted diagrams of each checked type' {
        It 'accepts a valid flowchart with node shapes and an edge label' {
            $result = Test-MermaidDiagram -Content @'
flowchart TD
    A[Start] --> B{Choice}
    B -->|yes| C(Done)
'@
            $result.Verdict | Should -Be 'Valid'
            $result.DiagramType | Should -Be 'flowchart'
            $result.Findings | Should -HaveCount 0
        }

        It 'accepts a valid sequence diagram with free message text' {
            $result = Test-MermaidDiagram -Content @'
sequenceDiagram
    participant Alice
    Alice->>Bob: Does 3 - 2 > 0 hold [yes]?
    Bob-->>Alice: It does
'@
            $result.Verdict | Should -Be 'Valid'
            $result.DiagramType | Should -Be 'sequence'
        }

        It 'accepts a valid class diagram with a member block' {
            $result = Test-MermaidDiagram -Content @'
classDiagram
    class Animal {
        +String name
        +eat()
    }
    Animal <|-- Dog
'@
            $result.Verdict | Should -Be 'Valid'
            $result.DiagramType | Should -Be 'class'
        }

        It 'accepts a valid state diagram with pseudo-states' {
            $result = Test-MermaidDiagram -Content @'
stateDiagram-v2
    [*] --> Idle
    Idle --> Running: start
    Running --> [*]
'@
            $result.Verdict | Should -Be 'Valid'
            $result.DiagramType | Should -Be 'state'
        }

        It 'accepts a valid ER diagram with cardinalities and an attribute block' {
            $result = Test-MermaidDiagram -Content @'
erDiagram
    CUSTOMER ||--o{ ORDER : places
    ORDER {
        int id PK
    }
'@
            $result.Verdict | Should -Be 'Valid'
            $result.DiagramType | Should -Be 'er'
        }

        It 'accepts a free-text gantt body that only looks unbalanced' {
            # A gantt task named 'Deploy (phase 1' is ugly but legal; brackets are
            # not structural for a free-text type.
            $result = Test-MermaidDiagram -Content @'
gantt
    title Release plan
    section Rollout
    Deploy (phase 1 :a1, 2026-01-01, 3d
'@
            $result.Verdict | Should -Be 'Valid'
            $result.DiagramType | Should -Be 'gantt'
        }

        It 'accepts a keyword-only pie diagram carrying the showData modifier' {
            $result = Test-MermaidDiagram -Content @'
pie showData
    "Covered" : 85
    "Uncovered" : 15
'@
            $result.Verdict | Should -Be 'Valid'
            $result.DiagramType | Should -Be 'pie'
        }
    }

    Context 'first-line keyword defects' {
        It 'rejects content whose first line is missing entirely' {
            $result = Test-MermaidDiagram -Content "`n`n"
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingClass -Result $result | Should -Contain 'EmptyDiagram'
        }

        It 'rejects a first line that begins with an arrow token' {
            $result = Test-MermaidDiagram -Content @'
--> B
    B --> C
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingClass -Result $result | Should -Contain 'MissingDiagramType'
            Get-FindingLine -Result $result -Class 'MissingDiagramType' | Should -Be @(1)
        }

        It 'rejects a first line that begins with a bracket' {
            $result = Test-MermaidDiagram -Content @'
[Start] --> B
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingClass -Result $result | Should -Contain 'MissingDiagramType'
        }

        It 'rejects a misspelled diagram keyword and names the intended keyword' {
            $result = Test-MermaidDiagram -Content @'
flowchar TD
    A --> B
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingClass -Result $result | Should -Contain 'MisspelledDiagramType'
            Get-FindingLine -Result $result -Class 'MisspelledDiagramType' | Should -Be @(1)
            $result.Findings[0].Message | Should -Match "flowchart"
        }

        It 'rejects content whose only lines are comments and directives' {
            $result = Test-MermaidDiagram -Content @'
%%{init: {'theme':'dark'}}%%
%% a comment and nothing else
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingClass -Result $result | Should -Contain 'MissingDiagramType'
        }
    }

    Context 'per-type invalid arrow tokens' {
        It 'rejects a sequence arrow used in a flowchart and reports its line' {
            $result = Test-MermaidDiagram -Content @'
flowchart TD
    A --> B
    B ->> C
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingLine -Result $result -Class 'InvalidArrowToken' | Should -Be @(3)
        }

        It 'rejects a flowchart open-circle arrow used in a sequence diagram' {
            $result = Test-MermaidDiagram -Content @'
sequenceDiagram
    Alice->>Bob: hello
    Bob --o Alice: not a sequence arrow
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingLine -Result $result -Class 'InvalidArrowToken' | Should -Be @(3)
        }

        It 'rejects a sequence arrow used in a class diagram' {
            $result = Test-MermaidDiagram -Content @'
classDiagram
    Animal <|-- Dog
    Cat ->> Mouse
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingLine -Result $result -Class 'InvalidArrowToken' | Should -Be @(3)
        }

        It 'rejects a single-dash transition in a state diagram' {
            $result = Test-MermaidDiagram -Content @'
stateDiagram-v2
    [*] --> Idle
    Idle -> Running
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingLine -Result $result -Class 'InvalidArrowToken' | Should -Be @(3)
        }

        It 'rejects an invalid cardinality token in an ER diagram' {
            $result = Test-MermaidDiagram -Content @'
erDiagram
    CUSTOMER ||--o{ ORDER : places
    ORDER |x--x| ITEM : contains
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingLine -Result $result -Class 'InvalidArrowToken' | Should -Be @(3)
        }
    }

    Context 'bracket balance and quote termination' {
        It 'rejects an unclosed square bracket and reports its opening line' {
            $result = Test-MermaidDiagram -Content @'
flowchart TD
    A[Start --> B
    B --> C
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingLine -Result $result -Class 'UnbalancedBracket' | Should -Be @(2)
        }

        It 'rejects an unclosed round bracket' {
            $result = Test-MermaidDiagram -Content @'
flowchart TD
    A(Start --> B
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingLine -Result $result -Class 'UnbalancedBracket' | Should -Be @(2)
        }

        It 'rejects an unclosed curly bracket' {
            $result = Test-MermaidDiagram -Content @'
flowchart TD
    A{Start --> B
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingLine -Result $result -Class 'UnbalancedBracket' | Should -Be @(2)
        }

        It 'rejects an unterminated double-quoted label' {
            $result = Test-MermaidDiagram -Content @'
flowchart TD
    A["Start] --> B
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingLine -Result $result -Class 'UnterminatedQuote' | Should -Be @(2)
        }
    }

    Context 'subgraph pairing' {
        It 'rejects a subgraph that is never closed by an end statement' {
            $result = Test-MermaidDiagram -Content @'
flowchart TD
    subgraph one
    A --> B
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingLine -Result $result -Class 'UnclosedSubgraph' | Should -Be @(2)
        }

        It 'accepts a closed subgraph carrying a direction statement and a free-text title' {
            $result = Test-MermaidDiagram -Content @'
flowchart TD
    subgraph one [Phase 1 (setup)]
        direction LR
        A --> B
    end
    B --> C
'@
            $result.Verdict | Should -Be 'Valid'
        }
    }

    Context 'empty and whitespace-only content' {
        It 'rejects an empty string' {
            $result = Test-MermaidDiagram -Content ''
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingClass -Result $result | Should -Contain 'EmptyDiagram'
        }

        It 'rejects whitespace-only content' {
            $result = Test-MermaidDiagram -Content "   `n  `t `n"
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingClass -Result $result | Should -Contain 'EmptyDiagram'
        }

        It 'rejects a keyword line with no statements after it' {
            $result = Test-MermaidDiagram -Content @'
flowchart TD

%% nothing but a comment
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingClass -Result $result | Should -Contain 'EmptyDiagramBody'
        }
    }

    Context 'line endings and frontmatter' {
        It 'returns the same verdict for CRLF and LF forms of a valid diagram' {
            $lf = "flowchart TD`n    A[Start] --> B`n"
            $crlf = "flowchart TD`r`n    A[Start] --> B`r`n"
            (Test-MermaidDiagram -Content $crlf).Verdict |
                Should -Be (Test-MermaidDiagram -Content $lf).Verdict
        }

        It 'returns the same verdict and line number for CRLF and LF forms of an invalid diagram' {
            $lf = "flowchart TD`n    A --> B`n    B ->> C`n"
            $crlf = "flowchart TD`r`n    A --> B`r`n    B ->> C`r`n"
            $lfResult = Test-MermaidDiagram -Content $lf
            $crlfResult = Test-MermaidDiagram -Content $crlf
            $crlfResult.Verdict | Should -Be $lfResult.Verdict
            (Get-FindingLine -Result $crlfResult -Class 'InvalidArrowToken') |
                Should -Be (Get-FindingLine -Result $lfResult -Class 'InvalidArrowToken')
        }

        It 'validates past a title frontmatter block' {
            $result = Test-MermaidDiagram -Content @'
---
title: Deployment flow
---
flowchart LR
    A --> B
'@
            $result.Verdict | Should -Be 'Valid'
            $result.DiagramType | Should -Be 'flowchart'
        }

        It 'validates past a nested config frontmatter block' {
            $result = Test-MermaidDiagram -Content @'
---
config:
  theme: dark
  look: handDrawn
---
flowchart LR
    A --> B
'@
            $result.Verdict | Should -Be 'Valid'
        }

        It 'validates past an id frontmatter block and still reports body line numbers' {
            $result = Test-MermaidDiagram -Content @'
---
id: 8f2c1a90-managed
---
flowchart LR
    A --> B
    B ->> C
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingLine -Result $result -Class 'InvalidArrowToken' | Should -Be @(6)
        }

        It 'rejects frontmatter that opens but is never closed' {
            $result = Test-MermaidDiagram -Content @'
---
title: broken
flowchart LR
    A --> B
'@
            $result.Verdict | Should -Be 'Invalid'
            Get-FindingClass -Result $result | Should -Contain 'MalformedFrontmatter'
        }

        It 'applies the line offset to every reported finding line' {
            $result = Test-MermaidDiagram -Content @'
flowchart TD
    A ->> B
'@ -LineOffset 10
            Get-FindingLine -Result $result -Class 'InvalidArrowToken' | Should -Be @(12)
        }
    }

    Context 'fail-open policy' {
        It 'warns and declines to judge an unknown but plausible keyword' {
            # Fail-open item 1, the Mermaid version-drift safety valve.
            $result = Test-MermaidDiagram -Content @'
sunburstChart wide
    A --> B
'@
            $result.Verdict | Should -Be 'NotJudged'
            $result.Findings | Should -HaveCount 0
            $result.Warnings | Should -HaveCount 1
            $result.Warnings[0] | Should -Match '11\.17\.0'
        }

        It 'warns and declines to judge an unverified keyword-accept diagram type' {
            $result = Test-MermaidDiagram -Content @'
venn
    A and B
'@
            $result.Verdict | Should -Be 'NotJudged'
            $result.Findings | Should -HaveCount 0
            $result.Warnings | Should -HaveCount 1
        }

        It 'checks only the keyword for a diagram type outside the deep-checked set' {
            # Fail-open item 2: a timeline body carries free text that would fail
            # both the arrow and the bracket rules if they were applied.
            $result = Test-MermaidDiagram -Content @'
timeline
    2026 : shipped (phase 1 ->> done
'@
            $result.Verdict | Should -Be 'Valid'
            $result.DiagramType | Should -Be 'timeline'
        }

        It 'skips a body line the classifier cannot categorize' {
            # Fail-open item 3: a bare identifier line is neither an edge nor a
            # statement keyword and must not produce a finding.
            $result = Test-MermaidDiagram -Content @'
flowchart TD
    A --> B
    C
    %% a trailing comment
'@
            $result.Verdict | Should -Be 'Valid'
            $result.Findings | Should -HaveCount 0
        }

        It 'checks only the keyword for a ZenUML body' {
            # Fail-open item 7: ZenUML uses an external plugin grammar.
            $result = Test-MermaidDiagram -Content @'
zenuml
    title Order
    Alice->Bob.method() {
      return
    }
'@
            $result.Verdict | Should -Be 'Valid'
            $result.DiagramType | Should -Be 'zenuml'
        }
    }
}

Describe 'Test-MermaidManagedDiagram detector' {
    It 'reports a managed diagram when the frontmatter carries a non-empty id' {
        Test-MermaidManagedDiagram -Content @'
---
id: 8f2c1a90-managed
title: Managed flow
---
flowchart LR
    A --> B
'@ | Should -BeTrue
    }

    It 'does not report a managed diagram when the id value is empty' {
        Test-MermaidManagedDiagram -Content @'
---
id:
---
flowchart LR
    A --> B
'@ | Should -BeFalse
    }

    It 'does not report a managed diagram when the frontmatter carries no id key' {
        Test-MermaidManagedDiagram -Content @'
---
title: Unmanaged flow
---
flowchart LR
    A --> B
'@ | Should -BeFalse
    }

    It 'does not report a managed diagram for an id-shaped body line outside frontmatter' {
        Test-MermaidManagedDiagram -Content @'
flowchart LR
    A --> B
    id: not frontmatter
'@ | Should -BeFalse
    }

    It 'does not report a managed diagram for empty or whitespace content' {
        Test-MermaidManagedDiagram -Content '' | Should -BeFalse
        Test-MermaidManagedDiagram -Content "  `n " | Should -BeFalse
    }
}
