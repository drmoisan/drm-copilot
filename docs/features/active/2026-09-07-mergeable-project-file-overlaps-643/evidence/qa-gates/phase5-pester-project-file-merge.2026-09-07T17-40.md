# Phase 5 QA gate — Pester, project-file merge library

Timestamp: 2026-09-07T17-40

Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-lib/project-file-merge, tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 -Output Detailed"`

EXIT_CODE: 0

Output Summary: 61 tests discovered in 5 files, all passed, none skipped. Every
`It` name enumerated in [P5-T8], [P5-T9], [P5-T10], and [P5-T11] appears in the
detailed output as passed, including the ten MSBuild item-type cases of [P5-T4],
the packages and app.config cases of [P5-T5], and the never-drop case of [P5-T7].
The `ClaudeLibModuleConvention` suite confirms the two new modules carry the
module-scope error-preference guard, the guarded sibling import, the convention
sentence, and the 500-line limit.

Verbatim `Tests Passed:` line:

`Tests Passed: 61, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`

## It results per suite file

| Suite file | Passed | Failed |
| --- | --- | --- |
| `tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1` | 3 | 0 |
| `tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1` | 26 | 0 |
| `tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1` | 17 | 0 |
| `tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1` | 9 | 0 |
| `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` | 6 | 0 |
| Total | 61 | 0 |

## No-XML assertion

Command: `grep -r -c -E "System\.Xml|\[xml\]" .claude/lib/project-file-merge`

Output (a printed `0` for every file listed; the directory is untracked at this
point, so plain `grep` is used rather than `git grep`):

```
.claude/lib/project-file-merge/ProjectFileMerge.psm1:0
.claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1:0
.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1:0
```

## Named cases confirmed passed

- [P5-T8] `Get-ProjectFileKind`: `classifies packages.config as the packages kind`, `classifies app.config as the appconfig kind`, `classifies a project extension as the msbuild kind`, `returns null for an unrecognised leaf name`. `Get-MergeableUnit`: `parses a single-line Compile item`, `... Analyzer ...`, `... None ...`, `... Content ...`, `... EmbeddedResource ...`, `parses the paired form with metadata children`, `parses a package line with its version`, `parses a dependentAssembly block keyed on the assembly name`, `returns null for a line outside the grammar`, `skips blank lines`. `Compare-UnitVersion`: `selects the higher four-part version`, `reports equal versions`, `escalates an unparseable version on either side`.
- [P5-T9] `Get-ConflictHunk`: `parses a merge-style hunk`, `parses a diff3-style hunk and skips its base section`, `returns null for an unterminated hunk`. `Merge-ConflictedText keyed union`: the thirteen `resolves <case> to the expected union` cases (the ten MSBuild item-type cases plus `diff3-compile`, `packages-disjoint`, `appconfig-disjoint`), `keeps the higher package version and records the resolution`, `keeps the higher newVersion and rewrites the oldVersion upper bound`, `escalates an unparseable package version`, `escalates a hunk line outside the grammar`, `escalates the same key at the same version with differing attributes`, `preserves CRLF terminators`, `preserves the byte prefix for a BOM fixture`. `Test-NeverDropPostCondition`: `passes when the merged key set is the union of both sides`, `fails when a theirs key is missing from the merged text`, `fails when a key present in base and both sides is missing`.
- [P5-T10] `Invoke-MergeableConflictResolution`: `resolves a csproj-only conflict set and reports the added entries`, `escalates when any conflicted path is outside mergeable_paths`, `escalates and writes nothing when the never-drop post-condition fails`, `classifies paths with the shared blast-radius matcher`, `never invokes a staging or commit git command`, `returns exactly the three documented result keys and one JSON call site`. `Byte-level seams`: `reads the byte-order mark and the retained terminators from a BOM fixture`, `reads a CRLF fixture with its terminators retained`, `assembles the merged bytes without writing under -WhatIf`.
- [P5-T11] `lists every discovered library file in core.json paths`, `ships a byte-identical bundled counterpart for every library file`.
