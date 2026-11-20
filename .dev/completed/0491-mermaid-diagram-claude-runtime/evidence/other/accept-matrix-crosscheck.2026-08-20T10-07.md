# Accept-Matrix Completeness Cross-Check (issue #491, [P2-T7])

Timestamp: 2026-08-20T10-07

Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1 -Output Normal"`
EXIT_CODE: 0
Output Summary: Tests Passed: 22, Failed: 0. Discovery found 22 tests in one file
(`tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1`, 234 lines).

Source table: `research/mermaid-validation-technology.2026-08-19T08-39.md` section 4
("False-Positive Risk Analysis"), walked row by row. Every row maps to at least one named
`It` case asserting the verdict is `Valid` or `NotJudged` and that no finding was raised.

| Research section 4 construct | Accept-matrix `It` name | Result |
| --- | --- | --- |
| Brackets in quoted labels: `A["foo[bar](baz)"]` | accepts structural brackets inside a quoted node label | PASS |
| HTML entities `#quot;`, `#35;`, `&amp;`; `\"` never an escape | accepts quote entities and a trailing backslash before the closing quote; accepts numeric and named HTML entities in a label | PASS |
| Markdown strings in backticks | accepts a Markdown string label delimited by backticks | PASS |
| Unicode text | accepts non-ASCII label text | PASS |
| `%%` comments (content inside quoted spans) | accepts a percent sequence inside a quoted span | PASS |
| `subgraph` blocks with `direction` and free-text title | accepts a subgraph block with a direction statement and a free-text title | PASS |
| Statement keyword `click` | accepts a click statement carrying a URL with query parameters | PASS |
| Statement keyword `style` | accepts a style statement carrying CSS declarations | PASS |
| Statement keyword `classDef` | accepts a classDef statement carrying a dash-array property | PASS |
| Statement keyword `linkStyle` | accepts a linkStyle statement carrying a colour list | PASS |
| Statement keyword `class` | accepts a class statement naming several nodes | PASS |
| Statement keyword `accTitle` | accepts an accTitle statement carrying free text with an arrow | PASS |
| Statement keyword `accDescr` | accepts an accDescr statement carrying free text with brackets | PASS |
| Statement keyword `title` | accepts a title statement carrying free text with an arrow | PASS |
| Multi-line node text with `<br/>`; angle brackets never structural | accepts a line-break tag and inline HTML in a label | PASS |
| Sequence message text after the first `:` | accepts sequence message text after the first colon | PASS |
| Free-text diagram types (gantt task `Deploy (phase 1`) | accepts an unbalanced-looking task line in a free-text diagram type | PASS |
| Escaped characters generally: backslash is ordinary | accepts backslashes as ordinary characters in a path label | PASS |

Constructs missing from the matrix: NONE. All eighteen rows of the section 4 table (counting the
eight statement keywords individually) are covered by a named passing case.

## Additional cases beyond the section 4 table

Three cases were added from the section 3 grammar table because they are documented forms whose
characters would otherwise look structural. They extend the matrix; they do not substitute for
any section 4 row.

| Documented form | Accept-matrix `It` name | Result |
| --- | --- | --- |
| Class-diagram generics `~T~` | accepts class-diagram generics written with tilde runs | PASS |
| ER cardinality word aliases (`one to zero or more`) | accepts ER cardinality expressed with the documented word aliases | PASS |
| Flowchart mid-arrow text forms (`-- text -->`, `== text ==>`, `-. text .->`) | accepts a flowchart edge carrying a mid-arrow text form | PASS |

## Fixture correction recorded during the cross-check

The first draft of the entity case was `A["He said #quot;stop#quot; \" loudly"]`, which the
validator rejected with `UnterminatedQuote`. The rejection is CORRECT, not a false positive:
because Mermaid has no backslash escape, the `"` following the backslash closes the span and the
remaining ` loudly"` opens a span that is never closed. The fixture was therefore genuinely
invalid Mermaid. The case was rewritten to the two forms that actually demonstrate the rule — the
`#quot;` entity mechanism, and a label whose final character before the closing quote is a
backslash — and both are accepted. A control in `MermaidValidation.Tests.ps1`
("rejects an unterminated double-quoted label") shows the same rule still fires when a quote is
truly unterminated, so the accept case is not passing vacuously.

## Test-name uniqueness

Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1 -Output Normal"`
EXIT_CODE: 0
Output Summary: Tests Passed: 5, Failed: 0 — no sibling `Describe`/`Context`/`It` names in the new
suites differ only by letter case.
