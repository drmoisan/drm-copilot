# [P1-T3] Pester gate: DocsPythonSyntax and DocsPythonBindings (issue #1022)

Timestamp: 2026-11-03T23-23
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsPythonSyntax.Tests.ps1,tests/scripts/claude-lib/docs/DocsPythonBindings.Tests.ps1 -CoverageFile .claude/lib/docs/DocsPythonSyntax.psm1,.claude/lib/docs/DocsPythonBindings.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the two modules; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsPythonSyntax.Tests.ps1: 35 passed, 0 failed, 0 errored, 0 skipped; tests/scripts/claude-lib/docs/DocsPythonBindings.Tests.ps1: 14 passed, 0 failed, 0 errored, 0 skipped (JUnit testsuite elements; result object Passed=49 Failed=0 Skipped=0). Line execution: .claude/lib/docs/DocsPythonSyntax.psm1 176 of 177 analyzed lines (99.44%); .claude/lib/docs/DocsPythonBindings.psm1 141 of 141 (100%). The JUnit file is well-formed; counts were read from it.

## Module split (Pre-Mortem, File size)

The first draft of `DocsPythonSyntax.psm1` reached 578 physical lines, above the 500-line rule of spec `### Module layout` and the plan's `## Pre-Mortem` (File size). It was split: `DocsPythonSyntax.psm1` (370 lines) keeps `Get-DocsPythonLogicalLine`, `Get-DocsPythonEnclosingBlock`, `ConvertFrom-DocsPythonStringToken`, `Read-DocsPythonCall` and exports the two token utilities the sibling needs, `Read-DocsPythonDottedChain` and `Split-DocsPythonTokenList`; the new `DocsPythonBindings.psm1` (243 lines) carries `Get-DocsPythonImportTable`, `Get-DocsPythonReceiverTable` and `Get-DocsPythonDefinitionHeader`. The seven functions of the spec module-layout row are all present across the two modules. A classification row for `LIB/DocsPythonBindings.psm1` was added to the plan's `## Artifact Classification` table; per that table's trailing paragraph the split adds one to the counts of new modules (eighteen), mirror pairs (twenty), `CORE` entries (18) and added `core.json` lines (19 with `CORE_TAIL` `last`).

## Toolchain for the new files

- Formatter: `Already formatted:` for `.claude/lib/docs/DocsPythonSyntax.psm1`, `.claude/lib/docs/DocsPythonBindings.psm1`, `tests/scripts/claude-lib/docs/DocsPythonSyntax.Tests.ps1` and `tests/scripts/claude-lib/docs/DocsPythonBindings.Tests.ps1`; 0 files rewritten on the final pass.
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings for the four files on the final pass (one intermittent engine NullReferenceException was retried with a module reload, as `Invoke-PoshQCAnalyze` does).
- Physical line counts: `DocsPythonSyntax.psm1` 370; `DocsPythonBindings.psm1` 243; `DocsPythonSyntax.Tests.ps1` 346; `DocsPythonBindings.Tests.ps1` 294.
- A defect found and fixed during this task: a local `$token` in a function with a `-Token` parameter is the same variable in PowerShell; the locals were renamed. A test-generator defect (`1..$n` with `$n` 0 yields two values) was fixed in three property tests.

## Behavior covered

- `Get-DocsPythonLogicalLine`: StartLine, EndLine, Indent (tabs to multiples of 8, form feed reset), per-token Level, bracket continuation, backslash continuation, `;` splitting, comment-only and blank lines skipped, lexer tokens not mutated; `PYTHON_INDENTATION_INVALID` with code, severity `error`, blocking `$true` and line, and the accepted dedent cases; property (seed 102230).
- `Get-DocsPythonEnclosingBlock`: kinds chain, `InLoop`, `InDef`, `InClass`, `TopLevelOnly`, same-line loop body after the colon, comprehension restricted to the site's bracket group; property (seed 102231).
- `ConvertFrom-DocsPythonStringToken`: plain, raw with backslash, triple, concatenation, `u` prefix; `$null` for escaped non-raw, bytes, f-string, concatenation with an f-string part, non-string token, no token; property (seed 102232).
- `Read-DocsPythonDottedChain` (stops at a keyword, so `from . import x` reads no module) and `Split-DocsPythonTokenList`; properties (seeds 102233, 102234).
- `Read-DocsPythonCall`: callee parts, positional, keyword, star, list with items, dynamic f-string value, name, attribute, number, call, tuple and other kinds, multi-line spans, `$null` for a non-call; property (seed 102235).
- `Get-DocsPythonImportTable`: `import m`, `import m as a`, `import m.sub`, `import m.sub as a`, `from m import n`, `from m import n as a`, parenthesized multi-line from-imports, `from . import x`, `from ..pkg.mod import x`, placements at indentation 0 and inside top-level `if`/`else`/`try`/`except`, exclusion of a `for`-body import; `PYTHON_IMPORT_STAR_FRAMEWORK`, `PYTHON_IMPORT_NESTED_FRAMEWORK` and `PYTHON_BINDING_AMBIGUOUS` each with code, severity `warning`, blocking `$false`, line and survival of the other bindings; case-distinct names; property (seed 102240).
- `Get-DocsPythonReceiverTable`: plain and annotated bindings at any indentation, nested flag, non-call statements ignored, `PYTHON_BINDING_AMBIGUOUS` with survival; property (seed 102241).
- `Get-DocsPythonDefinitionHeader`: decorators (call and bare, multi-line), `async def`, parameter kinds, annotations, defaults, spans, class bases, `$null` for non-headers, the non-ASCII mark consumed by `PYTHON_IDENTIFIER_NON_ASCII`; property (seed 102242).

CI: `poshqc / PowerShell QC` (windows-latest shards).
