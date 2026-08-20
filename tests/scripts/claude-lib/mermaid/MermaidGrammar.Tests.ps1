#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the pinned Mermaid grammar reference data (issue #491).

.DESCRIPTION
    Verifies that every keyword row of the Mermaid 11.17.0 grammar table resolves,
    that the deep-checked type set is exactly the five arrow-judged types, that the
    per-type arrow token sets match the documented reference, and that the
    statement-keyword exemption list is the documented eight.

    All fixtures are string literals. The suite reads no file, starts no process,
    creates no temporary file, and mocks nothing.
#>

BeforeAll {
    # Resolve the module four levels up: mermaid -> claude-lib -> scripts -> tests
    # -> repo root, then into .claude/lib/mermaid. Resolve-Path normalizes the
    # separators so Pester's coverage breakpoints bind to the same on-disk path
    # the run settings name.
    $script:GrammarModulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/mermaid/MermaidGrammar.psm1").Path
    Import-Module $script:GrammarModulePath -Force
}

Describe 'MermaidGrammar reference data' {

    Context 'pinned documentation metadata' {
        It 'records the pinned Mermaid documentation version in the accessor' {
            Get-MermaidGrammarVersion | Should -Be '11.17.0'
        }

        It 'records the documentation source URL in the accessor' {
            Get-MermaidGrammarSourceUrl | Should -Match '^https://mermaid\.js\.org/'
        }

        It 'records the pinned version and source URL in the module header' {
            $header = Get-Content -LiteralPath $script:GrammarModulePath -Raw
            $header | Should -Match 'Mermaid 11\.17\.0'
            $header | Should -Match 'https://mermaid\.js\.org/'
        }
    }

    Context 'first-line keyword allowlist' {
        # One row per keyword form in the research grammar table.
        $keywordRows = @(
            @{ Keyword = 'flowchart'; Type = 'flowchart' }
            @{ Keyword = 'graph'; Type = 'flowchart' }
            @{ Keyword = 'flowchart-elk'; Type = 'flowchart' }
            @{ Keyword = 'sequenceDiagram'; Type = 'sequence' }
            @{ Keyword = 'classDiagram'; Type = 'class' }
            @{ Keyword = 'classDiagram-v2'; Type = 'class' }
            @{ Keyword = 'stateDiagram-v2'; Type = 'state' }
            @{ Keyword = 'stateDiagram'; Type = 'state' }
            @{ Keyword = 'erDiagram'; Type = 'er' }
            @{ Keyword = 'journey'; Type = 'journey' }
            @{ Keyword = 'gantt'; Type = 'gantt' }
            @{ Keyword = 'pie'; Type = 'pie' }
            @{ Keyword = 'quadrantChart'; Type = 'quadrant' }
            @{ Keyword = 'requirementDiagram'; Type = 'requirement' }
            @{ Keyword = 'gitGraph'; Type = 'gitgraph' }
            @{ Keyword = 'mindmap'; Type = 'mindmap' }
            @{ Keyword = 'timeline'; Type = 'timeline' }
            @{ Keyword = 'zenuml'; Type = 'zenuml' }
            @{ Keyword = 'sankey-beta'; Type = 'sankey' }
            @{ Keyword = 'xychart-beta'; Type = 'xychart' }
            @{ Keyword = 'block-beta'; Type = 'block' }
            @{ Keyword = 'packet'; Type = 'packet' }
            @{ Keyword = 'packet-beta'; Type = 'packet' }
            @{ Keyword = 'kanban'; Type = 'kanban' }
            @{ Keyword = 'architecture-beta'; Type = 'architecture' }
            @{ Keyword = 'radar-beta'; Type = 'radar' }
            @{ Keyword = 'treemap-beta'; Type = 'treemap' }
            @{ Keyword = 'C4Context'; Type = 'c4' }
            @{ Keyword = 'C4Container'; Type = 'c4' }
            @{ Keyword = 'C4Component'; Type = 'c4' }
            @{ Keyword = 'C4Dynamic'; Type = 'c4' }
            @{ Keyword = 'C4Deployment'; Type = 'c4' }
            @{ Keyword = 'info'; Type = 'info' }
            @{ Keyword = 'swimlanes'; Type = 'swimlanes' }
            @{ Keyword = 'eventmodeling'; Type = 'eventmodeling' }
            @{ Keyword = 'venn'; Type = 'venn' }
            @{ Keyword = 'ishikawa'; Type = 'ishikawa' }
            @{ Keyword = 'wardley'; Type = 'wardley' }
            @{ Keyword = 'cynefin'; Type = 'cynefin' }
            @{ Keyword = 'treeView'; Type = 'treeview' }
            @{ Keyword = 'railroad'; Type = 'railroad' }
            @{ Keyword = 'railroad-beta'; Type = 'railroad' }
        )

        It 'resolves the documented keyword <Keyword> to type <Type>' -ForEach $keywordRows {
            # Arrange / Act
            $resolved = Resolve-MermaidDiagramType -FirstLine $Keyword

            # Assert
            $resolved.IsKnown | Should -BeTrue
            $resolved.Type | Should -Be $Type
            $resolved.Token | Should -Be $Keyword
        }

        It 'resolves the C4 keyword only with its documented capital-C4 capitalization' {
            (Resolve-MermaidDiagramType -FirstLine 'C4Context').Type | Should -Be 'c4'
            (Resolve-MermaidDiagramType -FirstLine 'c4context').IsKnown | Should -BeFalse
        }

        It 'resolves a gitGraph first line carrying a direction suffix and trailing colon' {
            (Resolve-MermaidDiagramType -FirstLine 'gitGraph LR:').Type | Should -Be 'gitgraph'
            (Resolve-MermaidDiagramType -FirstLine 'gitGraph TB:').Type | Should -Be 'gitgraph'
            (Resolve-MermaidDiagramType -FirstLine 'gitGraph BT:').Type | Should -Be 'gitgraph'
            (Resolve-MermaidDiagramType -FirstLine 'gitGraph:').Type | Should -Be 'gitgraph'
        }

        It 'resolves a pie first line carrying the showData modifier' {
            (Resolve-MermaidDiagramType -FirstLine 'pie showData').Type | Should -Be 'pie'
        }

        It 'resolves an xychart first line carrying the horizontal modifier' {
            (Resolve-MermaidDiagramType -FirstLine 'xychart-beta horizontal').Type | Should -Be 'xychart'
        }

        It 'resolves a flowchart first line carrying a direction and trailing semicolon' {
            (Resolve-MermaidDiagramType -FirstLine 'flowchart TD').Type | Should -Be 'flowchart'
            (Resolve-MermaidDiagramType -FirstLine 'graph LR;').Type | Should -Be 'flowchart'
        }

        It 'reports no match for a keyword-shaped token outside the allowlist' {
            # The version-drift safety valve: unknown but plausible must not resolve,
            # so the validator can warn instead of rejecting.
            $resolved = Resolve-MermaidDiagramType -FirstLine 'sunburstChart wide'
            $resolved.IsKnown | Should -BeFalse
            $resolved.Type | Should -BeNullOrEmpty
            $resolved.IsPlausibleKeyword | Should -BeTrue
        }

        It 'reports no match and no keyword shape for a line starting with an arrow' {
            $resolved = Resolve-MermaidDiagramType -FirstLine '--> B'
            $resolved.IsKnown | Should -BeFalse
            $resolved.IsPlausibleKeyword | Should -BeFalse
        }

        It 'reports no match and no keyword shape for a line starting with a bracket' {
            $resolved = Resolve-MermaidDiagramType -FirstLine '[Start] --> B'
            $resolved.IsKnown | Should -BeFalse
            $resolved.IsPlausibleKeyword | Should -BeFalse
        }

        It 'reports no match for an empty first line' {
            $resolved = Resolve-MermaidDiagramType -FirstLine ''
            $resolved.IsKnown | Should -BeFalse
            $resolved.IsPlausibleKeyword | Should -BeFalse
            $resolved.Token | Should -Be ''
        }
    }

    Context 'verified versus keyword-accept rows' {
        It 'marks a keyword read from the pinned documentation as verified' {
            (Resolve-MermaidDiagramType -FirstLine 'flowchart TD').IsVerified | Should -BeTrue
        }

        It 'marks an unverified 11.x sidebar row as keyword-accept only' {
            # The sidebar rows resolve so they never cost a false rejection, but
            # their exact keyword form was not verified against the pinned docs, so
            # the validator must still warn about drift.
            $resolved = Resolve-MermaidDiagramType -FirstLine 'venn'
            $resolved.IsKnown | Should -BeTrue
            $resolved.IsVerified | Should -BeFalse
        }
    }

    Context 'deep-checked diagram type set' {
        It 'contains exactly the five arrow-judged diagram types' {
            $deep = @(Get-MermaidDeepCheckedType)
            $deep | Should -HaveCount 5
            ($deep | Sort-Object) -join ',' | Should -Be 'class,er,flowchart,sequence,state'
        }

        It 'reports each of the five deep types as deep-checked' -ForEach @(
            @{ Type = 'flowchart' }
            @{ Type = 'sequence' }
            @{ Type = 'class' }
            @{ Type = 'state' }
            @{ Type = 'er' }
        ) {
            Test-MermaidDeepCheckedType -DiagramType $Type | Should -BeTrue
        }

        It 'reports a free-text diagram type as not deep-checked' {
            Test-MermaidDeepCheckedType -DiagramType 'gantt' | Should -BeFalse
            Test-MermaidDeepCheckedType -DiagramType 'journey' | Should -BeFalse
        }

        It 'reports a plugin-backed diagram type as not deep-checked' {
            # ZenUML bodies use the external plugin grammar (fail-open item 7).
            Test-MermaidDeepCheckedType -DiagramType 'zenuml' | Should -BeFalse
        }

        It 'reports an unknown diagram type as not deep-checked' {
            Test-MermaidDeepCheckedType -DiagramType 'sunburst' | Should -BeFalse
        }
    }

    Context 'per-type arrow token sets' {
        It 'returns the documented flowchart edge token set' {
            $tokens = @(Get-MermaidArrowToken -DiagramType 'flowchart')
            $tokens | Should -Contain '-->'
            $tokens | Should -Contain '---'
            $tokens | Should -Contain '-.->'
            $tokens | Should -Contain '==>'
            $tokens | Should -Contain '~~~'
            $tokens | Should -Contain 'o--o'
            $tokens | Should -Contain 'x--x'
            $tokens | Should -Contain '<-->'
        }

        It 'returns the documented sequence message token set' {
            $tokens = @(Get-MermaidArrowToken -DiagramType 'sequence')
            $tokens | Should -Contain '->'
            $tokens | Should -Contain '->>'
            $tokens | Should -Contain '-->>'
            $tokens | Should -Contain '<<->>'
            $tokens | Should -Contain '-x'
            $tokens | Should -Contain '-)'
        }

        It 'returns the documented class relation token set' {
            $tokens = @(Get-MermaidArrowToken -DiagramType 'class')
            $tokens | Should -Contain '<|--'
            $tokens | Should -Contain '--|>'
            $tokens | Should -Contain '*--'
            $tokens | Should -Contain 'o--'
            $tokens | Should -Contain '..>'
            $tokens | Should -Contain '<|..'
        }

        It 'returns the single documented state transition token' {
            @(Get-MermaidArrowToken -DiagramType 'state') | Should -Be @('-->')
        }

        It 'returns the documented ER cardinality token set' {
            $tokens = @(Get-MermaidArrowToken -DiagramType 'er')
            $tokens | Should -Contain '||--||'
            $tokens | Should -Contain '}o--o{'
            $tokens | Should -Contain '}|..|{'
        }

        It 'returns an empty token set for a keyword-only diagram type' {
            @(Get-MermaidArrowToken -DiagramType 'pie') | Should -HaveCount 0
        }

        It 'returns an empty token set for an unknown diagram type' {
            @(Get-MermaidArrowToken -DiagramType 'sunburst') | Should -HaveCount 0
        }

        It 'accepts every documented token of the type against that type pattern' -ForEach @(
            @{ Type = 'flowchart' }
            @{ Type = 'sequence' }
            @{ Type = 'class' }
            @{ Type = 'state' }
            @{ Type = 'er' }
        ) {
            $pattern = Get-MermaidArrowPattern -DiagramType $Type
            $pattern | Should -Not -BeNullOrEmpty
            foreach ($token in @(Get-MermaidArrowToken -DiagramType $Type)) {
                $token | Should -Match $pattern -Because "'$token' is documented for $Type"
            }
        }

        It 'rejects a sequence arrow against the flowchart pattern' {
            '->>' | Should -Not -Match (Get-MermaidArrowPattern -DiagramType 'flowchart')
        }

        It 'rejects a flowchart open-circle arrow against the sequence pattern' {
            '--o' | Should -Not -Match (Get-MermaidArrowPattern -DiagramType 'sequence')
        }

        It 'rejects a single-dash arrow against the state pattern' {
            '->' | Should -Not -Match (Get-MermaidArrowPattern -DiagramType 'state')
        }

        It 'returns no arrow pattern for a diagram type with no arrow grammar' {
            Get-MermaidArrowPattern -DiagramType 'gantt' | Should -BeNullOrEmpty
            Get-MermaidArrowPattern -DiagramType 'sunburst' | Should -BeNullOrEmpty
        }
    }

    Context 'statement-keyword exemption list' {
        It 'contains exactly the eight documented statement keywords' {
            $keywords = @(Get-MermaidStatementKeyword)
            $keywords | Should -HaveCount 8
            ($keywords | Sort-Object) -join ',' |
                Should -Be 'accDescr,accTitle,class,classDef,click,linkStyle,style,title'
        }

        It 'recognizes the exempt statement keyword <Token>' -ForEach @(
            @{ Token = 'click' }
            @{ Token = 'style' }
            @{ Token = 'classDef' }
            @{ Token = 'linkStyle' }
            @{ Token = 'class' }
            @{ Token = 'accTitle' }
            @{ Token = 'accDescr' }
            @{ Token = 'title' }
        ) {
            Test-MermaidStatementKeyword -Token $Token | Should -BeTrue
        }

        It 'does not recognize an ordinary node identifier as a statement keyword' {
            Test-MermaidStatementKeyword -Token 'A' | Should -BeFalse
            Test-MermaidStatementKeyword -Token '' | Should -BeFalse
        }

        It 'recognizes a block-opening keyword as a non-edge keyword' {
            Test-MermaidNonEdgeKeyword -Token 'subgraph' | Should -BeTrue
            Test-MermaidNonEdgeKeyword -Token 'end' | Should -BeTrue
            Test-MermaidNonEdgeKeyword -Token 'direction' | Should -BeTrue
            Test-MermaidNonEdgeKeyword -Token 'participant' | Should -BeTrue
        }

        It 'does not recognize a node identifier as a non-edge keyword' {
            Test-MermaidNonEdgeKeyword -Token 'A' | Should -BeFalse
            Test-MermaidNonEdgeKeyword -Token '' | Should -BeFalse
        }
    }

    Context 'bracket-structural and post-colon classification' {
        It 'treats the bracket-bearing deep types as bracket-structural' {
            Test-MermaidBracketStructuralType -DiagramType 'flowchart' | Should -BeTrue
            Test-MermaidBracketStructuralType -DiagramType 'class' | Should -BeTrue
            Test-MermaidBracketStructuralType -DiagramType 'state' | Should -BeTrue
            Test-MermaidBracketStructuralType -DiagramType 'er' | Should -BeTrue
        }

        It 'does not treat a free-text diagram type as bracket-structural' {
            # A gantt task named 'Deploy (phase 1' must never be blocked.
            Test-MermaidBracketStructuralType -DiagramType 'gantt' | Should -BeFalse
            Test-MermaidBracketStructuralType -DiagramType 'sequence' | Should -BeFalse
            Test-MermaidBracketStructuralType -DiagramType 'sunburst' | Should -BeFalse
        }

        It 'marks the four types whose statements carry free text after a colon' {
            Test-MermaidPostColonLabelType -DiagramType 'sequence' | Should -BeTrue
            Test-MermaidPostColonLabelType -DiagramType 'class' | Should -BeTrue
            Test-MermaidPostColonLabelType -DiagramType 'state' | Should -BeTrue
            Test-MermaidPostColonLabelType -DiagramType 'er' | Should -BeTrue
            Test-MermaidPostColonLabelType -DiagramType 'flowchart' | Should -BeFalse
        }
    }

    Context 'keyword shape rule' {
        It 'accepts a hyphenated keyword-shaped token' {
            Test-MermaidPlausibleKeyword -Token 'sankey-beta' | Should -BeTrue
        }

        It 'rejects a token that does not begin with a letter' {
            Test-MermaidPlausibleKeyword -Token '-->' | Should -BeFalse
            Test-MermaidPlausibleKeyword -Token '3d' | Should -BeFalse
            Test-MermaidPlausibleKeyword -Token '' | Should -BeFalse
        }
    }

    Context 'type table accessors' {
        It 'exposes an entry for every canonical type name' {
            $names = @(Get-MermaidDiagramTypeName)
            $names.Count | Should -BeGreaterThan 25
            foreach ($name in $names) {
                (Get-MermaidDiagramTypeEntry -DiagramType $name) | Should -Not -BeNullOrEmpty
            }
        }

        It 'returns no entry for an unknown canonical type name' {
            Get-MermaidDiagramTypeEntry -DiagramType 'sunburst' | Should -BeNullOrEmpty
        }
    }
}
