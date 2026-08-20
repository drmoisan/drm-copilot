#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the Markdown fence tracker and opt-out marker (issue #491).

.DESCRIPTION
    Covers each of the fence-tracker rules: plain backtick fences, tilde fences,
    up-to-three-space indentation, blockquote prefixes, the fence stack that
    classifies a nested Mermaid fence as example text, unclosed-fence tolerance,
    case-insensitive info strings, and the three-part opt-out marker contract
    (immediately preceding line, no intervening line, one block of scope).

    All fixtures are here-strings. The suite reads no file, starts no process,
    creates no temporary file, and mocks nothing.
#>

BeforeAll {
    $script:FenceModulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/mermaid/MermaidMarkdownFences.psm1").Path
    Import-Module $script:FenceModulePath -Force
}

Describe 'MermaidMarkdownFences extraction' {

    Context 'plain fence recognition' {
        It 'extracts a backtick-fenced Mermaid block' {
            $document = @'
# Heading

```mermaid
flowchart TD
    A --> B
```

Trailing prose.
'@
            $blocks = @(Get-MermaidFenceBlock -Content $document)
            $blocks | Should -HaveCount 1
            $blocks[0].Content | Should -Be "flowchart TD`n    A --> B"
            $blocks[0].StartLine | Should -Be 3
            $blocks[0].BodyStartLine | Should -Be 4
            $blocks[0].IsClosed | Should -BeTrue
            $blocks[0].IsNested | Should -BeFalse
            $blocks[0].IsOptedOut | Should -BeFalse
        }

        It 'extracts a tilde-fenced Mermaid block' {
            $document = @'
~~~mermaid
sequenceDiagram
    Alice->>John: Hello
~~~
'@
            $blocks = @(Get-MermaidFenceBlock -Content $document)
            $blocks | Should -HaveCount 1
            $blocks[0].Content | Should -Match 'sequenceDiagram'
            $blocks[0].IsClosed | Should -BeTrue
        }

        It 'extracts a fence indented by three spaces' {
            $document = @'
   ```mermaid
graph LR
   ```
'@
            $blocks = @(Get-MermaidFenceBlock -Content $document)
            $blocks | Should -HaveCount 1
            $blocks[0].Content | Should -Be 'graph LR'
        }

        It 'does not treat a fence indented by four spaces as a fence' {
            # Four spaces of indentation is an indented code block, not a fence.
            $document = @'
    ```mermaid
graph LR
    ```
'@
            @(Get-MermaidFenceBlock -Content $document) | Should -HaveCount 0
        }

        It 'extracts a blockquote-prefixed fence and strips the quote marker' {
            $document = @'
> ```mermaid
> flowchart TD
>     Q --> R
> ```
'@
            $blocks = @(Get-MermaidFenceBlock -Content $document)
            $blocks | Should -HaveCount 1
            $blocks[0].Content | Should -Be "flowchart TD`n    Q --> R"
        }

        It 'accepts a mermaid info string in mixed case' {
            $document = @'
```Mermaid
flowchart TD
    A --> B
```
'@
            @(Get-MermaidFenceBlock -Content $document) | Should -HaveCount 1
        }

        It 'ignores a fence whose info string names another language' {
            $document = @'
```powershell
Write-Output 'not a diagram'
```
'@
            @(Get-MermaidFenceBlock -Content $document) | Should -HaveCount 0
        }

        It 'ignores a fence with no info string' {
            $document = @'
```
plain code block
```
'@
            @(Get-MermaidFenceBlock -Content $document) | Should -HaveCount 0
        }

        It 'extracts two independent Mermaid blocks in document order' {
            $document = @'
```mermaid
flowchart TD
    A --> B
```

```mermaid
graph LR
    C --> D
```
'@
            $blocks = @(Get-MermaidFenceBlock -Content $document)
            $blocks | Should -HaveCount 2
            $blocks[0].StartLine | Should -Be 1
            $blocks[1].StartLine | Should -Be 6
        }
    }

    Context 'nested fence classification' {
        It 'flags a Mermaid fence nested inside a longer outer fence as nested' {
            # Fail-open item 6: documentation showing example Mermaid is not a
            # diagram, so the validator must skip it.
            $document = @'
````
```mermaid
this is quoted example text
```
````
'@
            $blocks = @(Get-MermaidFenceBlock -Content $document)
            $blocks | Should -HaveCount 1
            $blocks[0].IsNested | Should -BeTrue
        }

        It 'flags a Mermaid fence nested inside a tilde outer fence as nested' {
            $document = @'
~~~~
```mermaid
also quoted example text
```
~~~~
'@
            $blocks = @(Get-MermaidFenceBlock -Content $document)
            $blocks | Should -HaveCount 1
            $blocks[0].IsNested | Should -BeTrue
        }

        It 'does not flag a top-level Mermaid fence as nested' {
            $document = @'
```mermaid
flowchart TD
    A --> B
```
'@
            (@(Get-MermaidFenceBlock -Content $document))[0].IsNested | Should -BeFalse
        }
    }

    Context 'unclosed fence tolerance' {
        It 'reports the collected body of an unclosed Mermaid fence' {
            $document = @'
# Truncated document

```mermaid
flowchart TD
    A --> B
'@
            $blocks = @(Get-MermaidFenceBlock -Content $document)
            $blocks | Should -HaveCount 1
            $blocks[0].IsClosed | Should -BeFalse
            $blocks[0].Content | Should -Match 'flowchart TD'
        }

        It 'returns no block for text containing no fence at all' {
            @(Get-MermaidFenceBlock -Content "# Just prose`n`nNo diagrams here.") | Should -HaveCount 0
        }

        It 'returns no block for empty or null content' {
            @(Get-MermaidFenceBlock -Content '') | Should -HaveCount 0
            @(Get-MermaidFenceBlock -Content $null) | Should -HaveCount 0
        }
    }

    Context 'opt-out marker contract' {
        It 'flags a block whose immediately preceding line carries the marker' {
            $document = @'
Prose introducing a counter-example.
<!-- mermaid-validator: ignore -->
```mermaid
deliberately invalid
```
'@
            $blocks = @(Get-MermaidFenceBlock -Content $document)
            $blocks | Should -HaveCount 1
            $blocks[0].IsOptedOut | Should -BeTrue
        }

        It 'does not flag a block whose marker is separated by a blank line' {
            # Placement is exact: the marker must be on the immediately preceding
            # line, with no intervening line, blank or otherwise.
            $document = @'
<!-- mermaid-validator: ignore -->

```mermaid
deliberately invalid
```
'@
            (@(Get-MermaidFenceBlock -Content $document))[0].IsOptedOut | Should -BeFalse
        }

        It 'applies the marker to exactly one block' {
            $document = @'
<!-- mermaid-validator: ignore -->
```mermaid
first block, marked
```

```mermaid
second block, unmarked
```
'@
            $blocks = @(Get-MermaidFenceBlock -Content $document)
            $blocks | Should -HaveCount 2
            $blocks[0].IsOptedOut | Should -BeTrue
            $blocks[1].IsOptedOut | Should -BeFalse
        }

        It 'accepts leading and trailing whitespace on the marker line' {
            Test-MermaidOptOutMarker -Line '   <!-- mermaid-validator: ignore -->   ' | Should -BeTrue
            Test-MermaidOptOutMarker -Line '<!--mermaid-validator: ignore-->' | Should -BeTrue
        }

        It 'accepts a blockquote-prefixed marker line' {
            Test-MermaidOptOutMarker -Line '> <!-- mermaid-validator: ignore -->' | Should -BeTrue
        }

        It 'rejects a marker whose text differs in letter case' {
            # The marker text is case-sensitive so the opt-out is explicit.
            Test-MermaidOptOutMarker -Line '<!-- Mermaid-Validator: Ignore -->' | Should -BeFalse
        }

        It 'rejects a marker with different text inside the comment' {
            Test-MermaidOptOutMarker -Line '<!-- mermaid-validator: skip -->' | Should -BeFalse
            Test-MermaidOptOutMarker -Line '<!-- ignore mermaid -->' | Should -BeFalse
        }

        It 'rejects a marker that is not an HTML comment' {
            Test-MermaidOptOutMarker -Line 'mermaid-validator: ignore' | Should -BeFalse
        }

        It 'rejects an empty or null marker line' {
            Test-MermaidOptOutMarker -Line '' | Should -BeFalse
            Test-MermaidOptOutMarker -Line $null | Should -BeFalse
        }
    }

    Context 'fence line parsing helpers' {
        It 'parses the fence character, run length, and info string' {
            $fence = Get-MermaidFenceLine -Line '````mermaid'
            $fence.FenceCharacter | Should -Be '`'
            $fence.FenceLength | Should -Be 4
            $fence.Info | Should -Be 'mermaid'
            $fence.IsMermaid | Should -BeTrue
            $fence.QuoteDepth | Should -Be 0
        }

        It 'counts the blockquote depth of a quoted fence line' {
            (Get-MermaidFenceLine -Line '> > ~~~mermaid').QuoteDepth | Should -Be 2
        }

        It 'returns no parse for a line that is not a fence' {
            Get-MermaidFenceLine -Line 'flowchart TD' | Should -BeNullOrEmpty
            Get-MermaidFenceLine -Line '``inline code``' | Should -BeNullOrEmpty
            Get-MermaidFenceLine -Line '' | Should -BeNullOrEmpty
        }

        It 'treats an info string carrying attributes as a mermaid fence' {
            (Get-MermaidFenceLine -Line '```mermaid {theme=dark}').IsMermaid | Should -BeTrue
        }

        It 'closes an open fence with an equal or longer run of the same character' {
            $open = Get-MermaidFenceLine -Line '```mermaid'
            Test-MermaidFenceClose -Fence (Get-MermaidFenceLine -Line '```') -OpenFence $open | Should -BeTrue
            Test-MermaidFenceClose -Fence (Get-MermaidFenceLine -Line '`````') -OpenFence $open | Should -BeTrue
        }

        It 'does not close an open fence with a different character or an info string' {
            $open = Get-MermaidFenceLine -Line '````mermaid'
            Test-MermaidFenceClose -Fence (Get-MermaidFenceLine -Line '~~~~') -OpenFence $open | Should -BeFalse
            Test-MermaidFenceClose -Fence (Get-MermaidFenceLine -Line '```') -OpenFence $open | Should -BeFalse
            Test-MermaidFenceClose -Fence (Get-MermaidFenceLine -Line '````text') -OpenFence $open | Should -BeFalse
        }

        It 'does not close an open fence from a different blockquote depth' {
            $open = Get-MermaidFenceLine -Line '> ```mermaid'
            Test-MermaidFenceClose -Fence (Get-MermaidFenceLine -Line '```') -OpenFence $open | Should -BeFalse
        }
    }

    Context 'line splitting and quote-prefix helpers' {
        It 'splits CRLF, LF, and CR line endings identically' {
            @(Split-MermaidTextLine -Text "a`r`nb") | Should -Be @('a', 'b')
            @(Split-MermaidTextLine -Text "a`nb") | Should -Be @('a', 'b')
            @(Split-MermaidTextLine -Text "a`rb") | Should -Be @('a', 'b')
        }

        It 'returns no line for empty or null text' {
            @(Split-MermaidTextLine -Text '') | Should -HaveCount 0
            @(Split-MermaidTextLine -Text $null) | Should -HaveCount 0
        }

        It 'strips one blockquote marker per level of depth' {
            Get-MermaidUnquotedLine -Line '> > flowchart TD' -QuoteDepth 2 | Should -Be 'flowchart TD'
            Get-MermaidUnquotedLine -Line '> flowchart TD' -QuoteDepth 1 | Should -Be 'flowchart TD'
        }

        It 'returns the line unchanged when the depth is zero or the line is empty' {
            Get-MermaidUnquotedLine -Line '> kept' -QuoteDepth 0 | Should -Be '> kept'
            Get-MermaidUnquotedLine -Line '' -QuoteDepth 2 | Should -Be ''
        }

        It 'stops stripping when no further blockquote marker is present' {
            Get-MermaidUnquotedLine -Line '> flowchart TD' -QuoteDepth 3 | Should -Be 'flowchart TD'
        }
    }
}
