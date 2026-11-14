# P2 Front-Matter Parser - Issue #1021

Timestamp: 2026-11-03T22-28
Task: [P2-T2]
Command: `sh SCRATCH/issue-1021-failnames.sh tests/scripts/claude-lib/docs/DocsPageFrontMatter.Tests.ps1 issue-1021-p2-fm.txt` (PowerShell 7 `Invoke-Pester` with the repository run settings over the branch-current suite; `Run.PassThru`)
EXIT_CODE: 0
Output Summary: TOTAL=76 PASSED=76 FAILED=0 SKIPPED=0 NOTRUN=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0. Property-test seed: 1021 (25 rounds). CI: CI-PESTER.

## Scope

- Module `.claude/lib/docs/DocsPageFrontMatter.psm1` parser functions `ConvertFrom-DocsPageFrontMatter` and `ConvertFrom-DocsPageYamlScalar`; imports `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1` and `DocsPageMarkdown.psm1` by literal `Join-Path -Path $PSScriptRoot -ChildPath` joins; `ConvertFrom-Json` is not used.
- Parser contexts: block detection (no block, BOM and CRLF built in memory, `...` terminator, unterminated block with `BodyStartLine` 1); each line-grammar row (blank, comment, key, block sequence, tab indentation, quoted key, complex key, indented line, `- key: value`, `- - x`, syntax); `DOCS_PAGE_FRONT_MATTER_DUPLICATE_KEY` at `/<key>`; each value-form row (null forms, booleans, `Int64`, `Double`, unquoted `2026-10-30` as a string, ` #` comments, single-quoted, JSON values of the 1024 shape, flow sequences, flow mapping, YAML escape, block scalar, anchor, alias, tag, reserved indicators, mapping in plain scalar, `Int64` overflow, `.inf`/`.nan`); `FieldLine` and `BodyStartLine`.
- Property test (seeded `[System.Random]` 1021, seed and round printed through `-Because` on failure): the parse result is unchanged under insertion of comment and blank lines inside the block.
